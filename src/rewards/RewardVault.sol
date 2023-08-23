// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {ERC677ReceiverInterface} from
  '@chainlink/contracts/src/v0.8/interfaces/ERC677ReceiverInterface.sol';
import {LinkTokenInterface} from '@chainlink/contracts/src/v0.8/interfaces/LinkTokenInterface.sol';
import {TypeAndVersionInterface} from
  '@chainlink/contracts/src/v0.8/interfaces/TypeAndVersionInterface.sol';

import {IERC165} from '@openzeppelin/contracts/interfaces/IERC165.sol';
import {Math} from '@openzeppelin/contracts/utils/math/Math.sol';
import {SafeCast} from '@openzeppelin/contracts/utils/math/SafeCast.sol';

import {FixedPointMathLib} from '@solmate/utils/FixedPointMathLib.sol';

import {IMigratable} from '../interfaces/IMigratable.sol';
import {IRewardVault} from '../interfaces/IRewardVault.sol';
import {IStakingPool} from '../interfaces/IStakingPool.sol';
import {Migratable} from '../Migratable.sol';
import {PausableWithAccessControl} from '../PausableWithAccessControl.sol';
import {CommunityStakingPool} from '../pools/CommunityStakingPool.sol';
import {OperatorStakingPool} from '../pools/OperatorStakingPool.sol';

/// @notice This contract is the reward vault for the staking pools. Admin can deposit rewards into
/// the vault and set the aggregate reward rate for each pool to control the reward distribution.
/// @dev This contract interacts with the community and operator staking pools that it is connected
/// to. A reward vault is connected to only one community and operator staking pool during its
/// lifetime, which means when we upgrade either one of the pools or introduce a new type of pool,
/// we will need to update this contract and deploy a new reward vault.
/// @dev invariant LINK balance of the contract is greater than or equal to the sum of unavailable
/// rewards.
/// @dev invariant The sum of all stakers' rewards is less than or equal to the sum of available
/// rewards.
/// @dev invariant The reward bucket with zero aggregate reward rate has zero reward.
/// @dev invariant Stakers' multipliers are within 0 and the max value.
/// @dev We only support LINK token in v0.2 staking. Rebasing tokens, ERC777 tokens, fee-on-transfer
/// tokens or tokens that do not have 18 decimal places are not supported.
contract RewardVault is
  ERC677ReceiverInterface,
  IRewardVault,
  Migratable,
  PausableWithAccessControl,
  TypeAndVersionInterface
{
  using FixedPointMathLib for uint256;
  using SafeCast for uint256;

  /// @notice This error is thrown when the pool address is not one of the registered staking pools
  error InvalidPool();

  /// @notice This error is thrown when the reward amount is invalid when adding rewards
  error InvalidRewardAmount();

  /// @notice This error is thrown when the aggregate reward rate is invalid when adding rewards
  error InvalidEmissionRate();

  /// @notice This error is thrown when the delegation rate is invalid when setting delegation rate
  error InvalidDelegationRateDenominator();

  /// @notice This error is thrown when the owner tries to set the migration source to the
  /// zero address
  error InvalidMigrationSource();

  /// @notice This error is thrown when an address who doesn't have access tries to call a function
  /// For example, when the caller is not a rewarder and adds rewards to the vault, or
  /// when the caller is not a staking pool and tries to call updateRewardPerToken.
  error AccessForbidden();

  /// @notice This error is thrown whenever a zero-address is supplied when
  /// a non-zero address is required
  error InvalidZeroAddress();

  /// @notice This error is thrown when the reward duration is too short when adding rewards
  error RewardDurationTooShort();

  /// @notice this error is thrown when the rewards remaining are insufficient for the new
  /// delegation denominator
  error InsufficentRewardsForDelegationRate();

  /// @notice This error is thrown when calling an operation that is not allowed when the vault is
  /// closed.
  error VaultAlreadyClosed();

  /// @notice This error is thrown when the staker tries to claim rewards and the staker has no
  /// rewards to claim.
  error NoRewardToClaim();

  /// @notice This error is thrown when claiming rewards, the given staker parameter is not the
  /// msg.sender
  /// @param stakerArg The staker address given as a function argument
  /// @param msgSender The msg.sender of the call
  error InvalidStaker(address stakerArg, address msgSender);

  /// @notice This error is thrown whenever the sender is not the LINK token
  error SenderNotLinkToken();

  /// @notice This error is thrown when the vault is paused and the staker tries to claim rewards
  error CannotClaimRewardWhenPaused();

  /// @notice This event is emitted when the delegation rate is updated.
  /// @param oldDelegationRateDenominator The old delegationRateDenominator
  /// @param newDelegationRateDenominator The new delegationRateDenominator
  event DelegationRateDenominatorSet(
    uint256 oldDelegationRateDenominator, uint256 newDelegationRateDenominator
  );

  /// @notice This event is emitted when rewards are added to the vault
  /// @param pool The pool to which the rewards are added
  /// @param amount The reward amount
  /// @param emissionRate The target aggregate reward rate (token/second)
  event RewardAdded(address indexed pool, uint256 amount, uint256 emissionRate);

  /// @notice This event is emited when the vault is opened.
  event VaultOpened();

  /// @notice This event is emitted when the vault is closed.
  /// @param totalUnvestedRewards The total amount of unavailable rewards at the
  /// time the vault was closed
  event VaultClosed(uint256 totalUnvestedRewards);

  /// @notice This event is emitted when the staker claims rewards
  event RewardClaimed(address indexed staker, uint256 claimedRewards);

  /// @notice This event is emitted when the ramp up time for multipliers is changed.
  /// @param oldMultiplierDuration The old time to reach the max multiplier.
  /// @param newMultiplierDuration The new time to reach the max multiplier.
  event MultiplierDurationSet(uint256 oldMultiplierDuration, uint256 newMultiplierDuration);

  /// @notice This event is emitted when the forfeited rewards are shared back into the reward
  /// buckets.
  /// @param vestedReward The amount of forfeited rewards shared in juels
  /// @param vestedRewardPerToken The amount of forfeited rewards per token added.
  /// @param reclaimedReward The amount of forfeited rewards reclaimed.
  /// @param isOperatorReward True if the forfeited reward is from the operator staking pool.
  event ForfeitedRewardDistributed(
    uint256 vestedReward,
    uint256 vestedRewardPerToken,
    uint256 reclaimedReward,
    bool isOperatorReward
  );

  /// @notice This event is emitted when the owner migrates the rewards in the
  /// vault
  /// @param migrationTarget The migration target
  /// @param totalUnvestedRewards The total amount of unavailable rewards at the time the vault was
  /// closed
  /// @param totalEmissionRate The total aggregate reward rate of the vault at the time the vault
  /// was closed
  event VaultMigrated(
    address indexed migrationTarget, uint256 totalUnvestedRewards, uint256 totalEmissionRate
  );

  /// @notice This event is emitted when the tokens from the old vault is migrated to this contract.
  /// @param migrationSource The migration source
  /// @param totalUnvestedRewards The total amount of unavailable rewards at the time the vault was
  /// closed
  /// @param totalEmissionRate The total aggregate reward rate of the vault at the time the vault
  /// was closed
  event VaultMigrationProcessed(
    address indexed migrationSource, uint256 totalUnvestedRewards, uint256 totalEmissionRate
  );

  /// @notice This event is emitted when the migration source is set
  /// @param oldMigrationSource The previoud migration source
  /// @param newMigrationSource The updated migration source
  event MigrationSourceSet(address indexed oldMigrationSource, address indexed newMigrationSource);

  /// @notice This event is emitted when the pool rewards are updated
  /// @param communityBaseRewardPerToken The per-token base reward of the community staking pool
  /// @param operatorBaseRewardPerToken The per-token base reward of the operator staking pool
  /// @param operatorDelegatedRewardPerToken The per-token delegated reward of the operator staking
  /// pool
  event PoolRewardUpdated(
    uint256 communityBaseRewardPerToken,
    uint256 operatorBaseRewardPerToken,
    uint256 operatorDelegatedRewardPerToken
  );

  /// @notice This event is emitted when a staker's rewards are updated
  /// @param staker The staker address
  /// @param finalizedBaseReward The staker's finalized base reward
  /// @param finalizedDelegatedReward The staker's finalized delegated reward
  /// @param baseRewardPerToken The staker's base reward per token
  /// @param operatorDelegatedRewardPerToken The staker's delegated reward per token
  /// @param claimedBaseRewardsInPeriod The staker's claimed base rewards in the period
  event StakerRewardUpdated(
    address indexed staker,
    uint256 finalizedBaseReward,
    uint256 finalizedDelegatedReward,
    uint256 baseRewardPerToken,
    uint256 operatorDelegatedRewardPerToken,
    uint256 claimedBaseRewardsInPeriod
  );

  /// @notice This event is emitted when the staker rewards are finalized
  /// @param staker The staker address
  /// @param shouldForfeit True if the staker forfeited their rewards
  event RewardFinalized(address staker, bool shouldForfeit);

  /// @notice The constructor parameters.
  struct ConstructorParams {
    /// @notice The LINK token.
    LinkTokenInterface linkToken;
    /// @notice The community staking pool.
    CommunityStakingPool communityStakingPool;
    /// @notice The operator staking pool.
    OperatorStakingPool operatorStakingPool;
    /// @notice The delegation rate denominator.
    uint32 delegationRateDenominator;
    /// @notice The initial time it takes for a multiplier to reach its max value in seconds.
    uint32 initialMultiplierDuration;
    /// @notice The time it requires to transfer admin role
    uint48 adminRoleTransferDelay;
  }

  /// @notice This struct is used to store the reward information for a reward bucket.
  struct RewardBucket {
    /// @notice The reward aggregate reward rate of the reward bucket in Juels/second.
    uint80 emissionRate;
    /// @notice The timestamp when the reward duration ends.
    uint80 rewardDurationEndsAt;
    /// @notice The last updated available reward per token of the reward bucket.
    /// This value only increases over time as more rewards vest to the
    /// stakers.
    uint80 vestedRewardPerToken;
  }

  /// @notice This struct is used to store the reward buckets states.
  struct RewardBuckets {
    /// @notice The reward bucket for the operator staking pool.
    RewardBucket operatorBase;
    /// @notice The reward bucket for the community staking pool.
    RewardBucket communityBase;
    /// @notice The reward bucket for the delegated rewards.
    RewardBucket operatorDelegated;
  }

  /// @notice This struct is used to store the vault config.
  struct VaultConfig {
    /// @notice The delegation rate denominator.
    uint32 delegationRateDenominator;
    /// @notice The time it takes for a multiplier to reach its max value in seconds.
    uint32 multiplierDuration;
    /// @notice Flag that signals if the reward vault is open
    bool isOpen;
  }

  /// @notice This struct is used to store the checkpoint information at the time the reward vault
  /// is migrated or closed
  struct VestingCheckpointData {
    /// @notice The total staked LINK amount of the operator staking pool at the time
    /// the reward vault was migrated or closed
    uint256 operatorPoolTotalPrincipal;
    /// @notice The total staked LINK amount of the community staking pool at the time
    /// the reward vault was migrated or closed
    uint256 communityPoolTotalPrincipal;
    /// @notice The checkpoint ID of the operator staking pool at the time
    /// the reward vault was migrated or closed
    uint256 operatorPoolCheckpointId;
    /// @notice The checkpoint ID of the community staking pool at the time
    /// the reward vault was migrated or closed
    uint256 communityPoolCheckpointId;
  }

  /// @notice This struct is used for aggregating the return values of a function that calculates
  /// the reward aggregate reward rate splits.
  struct BucketRewardEmissionSplit {
    /// @notice The reward for the community staking pool
    uint256 communityReward;
    /// @notice The reward for the operator staking pool
    uint256 operatorReward;
    /// @notice The reward for the delegated staking pool
    uint256 operatorDelegatedReward;
    /// @notice The aggregate reward rate for the community staking pool
    uint256 communityRate;
    /// @notice The aggregate reward rate for the operator staking pool
    uint256 operatorRate;
    /// @notice The aggregate reward rate for the delegated staking pool
    uint256 delegatedRate;
  }

  /// @notice This is the ID for the rewarder role, which is given to the
  /// addresses that will add rewards to the vault.
  /// @dev Hash: beec13769b5f410b0584f69811bfd923818456d5edcf426b0e31cf90eed7a3f6
  bytes32 public constant REWARDER_ROLE = keccak256('REWARDER_ROLE');
  /// @notice The maximum possible value of a multiplier. Current implementation requires that this
  /// value is 1e18 (i.e. 100%).
  uint256 private constant MAX_MULTIPLIER = 1e18;
  /// @notice The LINK token
  LinkTokenInterface private immutable i_LINK;
  /// @notice The community staking pool.
  CommunityStakingPool private immutable i_communityStakingPool;
  /// @notice The operator staking pool.
  OperatorStakingPool private immutable i_operatorStakingPool;
  /// @notice The reward buckets.
  RewardBuckets private s_rewardBuckets;
  /// @notice The vault config.
  VaultConfig private s_vaultConfig;
  /// @notice The checkpoint information at the time the reward vault was closed
  /// or migrated
  VestingCheckpointData private s_finalVestingCheckpointData;
  /// @notice The time the reward per token was last updated
  uint256 private s_rewardPerTokenUpdatedAt;
  /// @notice The address of the vault that will be migrated to this vault
  address private s_migrationSource;
  /// @notice Stores reward information for each staker
  mapping(address => StakerReward) private s_rewards;

  constructor(ConstructorParams memory params)
    PausableWithAccessControl(params.adminRoleTransferDelay, msg.sender)
  {
    if (address(params.linkToken) == address(0)) revert InvalidZeroAddress();
    if (address(params.communityStakingPool) == address(0)) revert InvalidZeroAddress();
    if (address(params.operatorStakingPool) == address(0)) revert InvalidZeroAddress();

    i_LINK = params.linkToken;
    i_communityStakingPool = params.communityStakingPool;
    i_operatorStakingPool = params.operatorStakingPool;

    s_vaultConfig.delegationRateDenominator = params.delegationRateDenominator;
    emit DelegationRateDenominatorSet(0, params.delegationRateDenominator);

    s_vaultConfig.multiplierDuration = params.initialMultiplierDuration;
    emit MultiplierDurationSet(0, params.initialMultiplierDuration);

    s_vaultConfig.isOpen = true;
    emit VaultOpened();
  }

  /// @notice Adds more rewards into the reward vault
  /// Calculates the reward duration from the amount and aggregate reward rate
  /// @dev To add rewards to all pools use address(0) as the pool address
  /// @dev There is a possibility that a fraction of the added rewards can be locked in this
  /// contract as dust, specifically, when the amount is not divided by the aggregate reward rate
  /// evenly. We
  /// will handle this case operationally and make sure that the amount is large relative to the
  /// aggregate reward rate so there will only be small dust (less than 10^18 juels).
  /// @param pool The staking pool address
  /// @param amount The reward amount
  /// @param emissionRate The target aggregate reward rate (token/second)
  /// @dev precondition The caller must have the default admin role.
  /// @dev precondition This contract must be open and not paused.
  /// @dev precondition The caller must have at least `amount` LINK tokens.
  /// @dev precondition The caller must have approved this contract for the transfer of at least
  /// `amount` LINK tokens.
  function addReward(
    address pool,
    uint256 amount,
    uint256 emissionRate
  ) external onlyRewarder whenOpen whenNotPaused {
    // check if the pool is either community staking pool or operator staking pool
    // if the pool is the zero address, then the reward is split between all pools
    if (
      pool != address(0) && pool != address(i_communityStakingPool)
        && pool != address(i_operatorStakingPool)
    ) {
      revert InvalidPool();
    }
    _validateAddedRewards(amount, emissionRate);

    // update the reward per tokens
    _updateRewardPerToken();

    // update the reward buckets
    _updateRewardBuckets({pool: pool, amount: amount, emissionRate: emissionRate});

    // transfer the reward tokens to the reward vault
    // The return value is not checked since the call will revert if any balance, allowance or
    // receiver conditions fail.
    i_LINK.transferFrom({from: msg.sender, to: address(this), value: amount});

    emit RewardAdded(pool, amount, emissionRate);
  }

  /// @notice Returns the delegation rate denominator
  /// @return The delegation rate denominator
  function getDelegationRateDenominator() external view returns (uint256) {
    return s_vaultConfig.delegationRateDenominator;
  }

  /// @notice Updates the delegation rate
  /// @param newDelegationRateDenominator The delegation rate denominator.
  /// @dev precondition The caller must have the default admin role.
  function setDelegationRateDenominator(uint256 newDelegationRateDenominator)
    external
    onlyRole(DEFAULT_ADMIN_ROLE)
  {
    uint256 oldDelegationRateDenominator = s_vaultConfig.delegationRateDenominator;
    if (oldDelegationRateDenominator == newDelegationRateDenominator) {
      revert InvalidDelegationRateDenominator();
    }

    uint256 communityRateWithoutDelegation =
      s_rewardBuckets.communityBase.emissionRate + s_rewardBuckets.operatorDelegated.emissionRate;

    uint256 delegatedRate = newDelegationRateDenominator == 0
      ? 0
      : communityRateWithoutDelegation / newDelegationRateDenominator;

    if (
      delegatedRate == 0 && newDelegationRateDenominator != 0 && communityRateWithoutDelegation != 0
    ) {
      // delegated rate has rounded down to zero
      revert InsufficentRewardsForDelegationRate();
    }

    _updateRewardPerToken();

    uint256 unvestedRewards = _getUnvestedRewards(s_rewardBuckets.communityBase)
      + _getUnvestedRewards(s_rewardBuckets.operatorDelegated);
    uint256 communityRate = communityRateWithoutDelegation - delegatedRate;
    s_rewardBuckets.communityBase.emissionRate = communityRate.toUint80();
    s_rewardBuckets.operatorDelegated.emissionRate = delegatedRate.toUint80();

    // NOTE - the reward duration for both buckets need to be in sync.
    if (newDelegationRateDenominator == 0) {
      delete s_rewardBuckets.operatorDelegated.rewardDurationEndsAt;
      _updateRewardDurationEndsAt({
        bucket: s_rewardBuckets.communityBase,
        rewardAmount: unvestedRewards,
        emissionRate: communityRate
      });
    } else if (newDelegationRateDenominator == 1) {
      delete s_rewardBuckets.communityBase.rewardDurationEndsAt;
      _updateRewardDurationEndsAt({
        bucket: s_rewardBuckets.operatorDelegated,
        rewardAmount: unvestedRewards,
        emissionRate: delegatedRate
      });
    } else if (unvestedRewards != 0) {
      uint256 delegatedRewards = unvestedRewards / newDelegationRateDenominator;
      uint256 communityRewards = unvestedRewards - delegatedRewards;
      _updateRewardDurationEndsAt({
        bucket: s_rewardBuckets.communityBase,
        rewardAmount: communityRewards,
        emissionRate: communityRate
      });
      _updateRewardDurationEndsAt({
        bucket: s_rewardBuckets.operatorDelegated,
        rewardAmount: delegatedRewards,
        emissionRate: delegatedRate
      });
    }

    s_vaultConfig.delegationRateDenominator = newDelegationRateDenominator.toUint32();

    emit DelegationRateDenominatorSet(oldDelegationRateDenominator, newDelegationRateDenominator);
  }

  /// @notice Sets the new multiplier ramp up time.  This will impact the
  /// amount of rewards a staker can immediately claim.
  /// @param newMultiplierDuration The new multiplier ramp up time
  /// @dev precondition The caller must have the default admin role.
  function setMultiplierDuration(uint256 newMultiplierDuration)
    external
    onlyRole(DEFAULT_ADMIN_ROLE)
  {
    uint256 oldMultiplierDuration = s_vaultConfig.multiplierDuration;
    s_vaultConfig.multiplierDuration = newMultiplierDuration.toUint32();

    emit MultiplierDurationSet(oldMultiplierDuration, newMultiplierDuration);
  }

  /// @notice Sets the migration source for the vault
  /// @param newMigrationSource The new migration source
  /// @dev precondition The caller must have the default admin role.
  function setMigrationSource(address newMigrationSource) external onlyRole(DEFAULT_ADMIN_ROLE) {
    if (address(newMigrationSource) == address(0) || address(newMigrationSource) == address(this)) {
      revert InvalidMigrationSource();
    }
    address oldMigrationSource = s_migrationSource;
    s_migrationSource = newMigrationSource;
    emit MigrationSourceSet(oldMigrationSource, newMigrationSource);
  }

  /// @notice Returns the current migration source
  /// @return address The current migration source
  function getMigrationSource() external view returns (address) {
    return s_migrationSource;
  }

  // ===========
  // IMigratable
  // ===========

  /// @inheritdoc Migratable
  /// @dev precondition The caller must have the default admin role.
  function _validateMigrationTarget(address newMigrationTarget)
    internal
    override(Migratable)
    onlyRole(DEFAULT_ADMIN_ROLE)
  {
    Migratable._validateMigrationTarget(newMigrationTarget);
    if (
      !IERC165(newMigrationTarget).supportsInterface(
        ERC677ReceiverInterface.onTokenTransfer.selector
      )
    ) {
      revert InvalidMigrationTarget();
    }
  }

  /// @inheritdoc IMigratable
  /// @dev This will migrate the unavailable rewards and checkpoint the staking pools.
  /// @dev precondition The caller must have the default admin role.
  /// @dev precondition The reward vault must be open.
  /// @dev precondition The migration target must be set.
  /// @dev precondition The migration target must implement the onTokenTransfer function.
  function migrate(bytes calldata data)
    external
    override(IMigratable)
    onlyRole(DEFAULT_ADMIN_ROLE)
    whenOpen
    validateMigrationTargetSet
  {
    (
      uint256 totalEmissionRate,
      uint256 totalUnvestedRewards,
      uint256 unvestedOperatorBaseRewards,
      uint256 unvestedCommunityBaseRewards,
      uint256 unvestedOperatorDelegatedRewards
    ) = _stopVestingRewardsToBuckets();

    bytes memory migrationData = abi.encode(
      s_rewardBuckets.operatorBase.emissionRate,
      unvestedOperatorBaseRewards,
      s_rewardBuckets.communityBase.emissionRate,
      unvestedCommunityBaseRewards,
      s_rewardBuckets.operatorDelegated.emissionRate,
      unvestedOperatorDelegatedRewards,
      data
    );

    delete s_vaultConfig.isOpen;

    // The return value is not checked since the call will revert if any balance, allowance or
    // recipient conditions fail.
    i_LINK.transferAndCall({to: s_migrationTarget, value: totalUnvestedRewards, data: migrationData});
    emit VaultMigrated(s_migrationTarget, totalUnvestedRewards, totalEmissionRate);
  }

  // =================
  // IERC165
  // =================

  /// @notice This function allows the calling contract to
  /// check if the contract deployed at this address is a valid
  /// LINKTokenReceiver.  A contract is a valid LINKTokenReceiver
  /// if it implements the onTokenTransfer function.
  /// @param interfaceID The ID of the interface to check against
  /// @return bool True if the contract is a valid LINKTokenReceiver.
  function supportsInterface(bytes4 interfaceID) public view override returns (bool) {
    return interfaceID == this.onTokenTransfer.selector || super.supportsInterface(interfaceID);
  }

  // =================
  // IERC6677
  // =================

  /// @notice This function is called by the LINK token contract when the previous version reward
  /// vault transfers LINK tokens to this contract.
  /// @param sender The sender of the tokens
  /// @param amount The amount of tokens transferred
  /// @param data The data passed from the previous version reward vault
  /// @dev precondition The migration source must be set.
  function onTokenTransfer(address sender, uint256 amount, bytes calldata data) external override {
    if (msg.sender != address(i_LINK)) revert SenderNotLinkToken();
    if (sender != s_migrationSource) revert AccessForbidden();

    // Reset and prevent migration source from reentering
    delete s_migrationSource;

    // We do not validate that a bucket's aggregate reward rate and it's amount of
    // unavailable rewards are both 0 as there may be a case where one bucket
    // has emitted all of it's rewards and has an aggregate reward rate of 0 despite
    // another bucket having a non zero aggregate reward rate and is still vesting
    // rewards.
    (
      uint256 operatorBaseEmissionRate,
      uint256 unvestedOperatorBaseRewards,
      uint256 communityBaseEmissionRate,
      uint256 unvestedCommunityBaseRewards,
      uint256 operatorDelegatedEmissionRate,
      uint256 unvestedOperatorDelegatedRewards,
    ) = abi.decode(data, (uint256, uint256, uint256, uint256, uint256, uint256, bytes));

    uint256 totalUnvestedRewards =
      unvestedOperatorBaseRewards + unvestedCommunityBaseRewards + unvestedOperatorDelegatedRewards;
    if (totalUnvestedRewards != amount) revert InvalidRewardAmount();

    uint256 totalEmissionRate =
      operatorBaseEmissionRate + communityBaseEmissionRate + operatorDelegatedEmissionRate;

    _validateAddedRewards(totalUnvestedRewards, totalEmissionRate);

    _updateRewardPerToken();
    _updateRewardBucket({
      bucket: s_rewardBuckets.operatorBase,
      amount: unvestedOperatorBaseRewards,
      emissionRate: operatorBaseEmissionRate
    });
    _updateRewardBucket({
      bucket: s_rewardBuckets.communityBase,
      amount: unvestedCommunityBaseRewards,
      emissionRate: communityBaseEmissionRate
    });
    _updateRewardBucket({
      bucket: s_rewardBuckets.operatorDelegated,
      amount: unvestedOperatorDelegatedRewards,
      emissionRate: operatorDelegatedEmissionRate
    });

    emit VaultMigrationProcessed(sender, totalUnvestedRewards, totalEmissionRate);
  }

  // =================
  // IRewardVault
  // =================

  /// @inheritdoc IRewardVault
  /// @dev precondition This contract must not be paused.
  /// @dev precondition The caller must be a staker with a non-zero reward.
  function claimReward() external override whenNotPaused returns (uint256) {
    _updateRewardPerToken();

    bool isOperator = _isOperator(msg.sender);
    IStakingPool stakingPool =
      isOperator ? IStakingPool(i_operatorStakingPool) : IStakingPool(i_communityStakingPool);
    uint256 stakerPrincipal = _getStakerPrincipal(msg.sender, stakingPool);
    StakerReward memory stakerReward = _calculateStakerReward({
      staker: msg.sender,
      isOperator: isOperator,
      stakerPrincipal: stakerPrincipal
    });

    _applyMultiplier({
      stakerReward: stakerReward,
      shouldForfeit: false,
      stakerStakedAtTime: _getStakerStakedAtTime(msg.sender, stakingPool)
    });

    stakerReward.claimedBaseRewardsInPeriod += stakerReward.earnedBaseRewardInPeriod.toUint112();
    delete stakerReward.earnedBaseRewardInPeriod;

    uint256 claimableRewards = _transferRewards(msg.sender, stakerReward);
    s_rewards[msg.sender] = stakerReward;

    emit StakerRewardUpdated(
      msg.sender,
      stakerReward.finalizedBaseReward,
      stakerReward.finalizedDelegatedReward,
      stakerReward.baseRewardPerToken,
      stakerReward.operatorDelegatedRewardPerToken,
      stakerReward.claimedBaseRewardsInPeriod
    );

    return claimableRewards;
  }

  /// @notice Transfers a staker's finalized reward to the staker
  /// @param staker The address of the staker to send rewards to
  /// @param stakerReward The staker's reward data
  /// @return uint256 The amount of rewards transferred to the staker
  function _transferRewards(
    address staker,
    StakerReward memory stakerReward
  ) private returns (uint256) {
    uint256 claimableReward =
      stakerReward.finalizedBaseReward + stakerReward.finalizedDelegatedReward;
    if (claimableReward == 0) {
      revert NoRewardToClaim();
    }

    delete stakerReward.finalizedBaseReward;
    delete stakerReward.finalizedDelegatedReward;

    // The return value is not checked since the call will revert if any balance, allowance or
    // receiver conditions fail.
    i_LINK.transfer(staker, claimableReward);
    emit RewardClaimed(staker, claimableReward);

    return claimableReward;
  }

  /// @inheritdoc IRewardVault
  /// @dev precondition The caller must be a staking pool.
  function updateReward(address staker, uint256 stakerPrincipal) external override onlyStakingPool {
    // Pools' reward per tokens are updated before 1) adding rewards to the pool,
    // 2) claiming rewards, 3) staking, 4) unstaking, and 5) slashing operators.
    _updateRewardPerToken();

    // By passing in address 0, we only update pool reward per token values
    if (staker == address(0)) return;

    // Stakers' rewards are updated before 1) claiming reward, 2) staking, 3) unstaking,
    // and 4) slashing.
    StakerReward memory stakerReward = _calculateStakerReward({
      staker: staker,
      isOperator: msg.sender == address(i_operatorStakingPool),
      stakerPrincipal: stakerPrincipal
    });
    s_rewards[staker] = stakerReward;

    emit StakerRewardUpdated(
      staker,
      stakerReward.finalizedBaseReward,
      stakerReward.finalizedDelegatedReward,
      stakerReward.baseRewardPerToken,
      stakerReward.operatorDelegatedRewardPerToken,
      stakerReward.claimedBaseRewardsInPeriod
    );
  }

  /// @inheritdoc IRewardVault
  /// @dev This applies any final logic such as the multipliers to the staker's newly accrued and
  /// stored rewards and store the value.
  /// @dev The caller staking pool must update the total staked LINK amount of the pool AFTER
  /// calling this
  /// function.
  /// @dev precondition The caller must be a staking pool.
  function finalizeReward(
    address staker,
    uint256 oldPrincipal,
    uint256 stakedAt,
    uint256 unstakedAmount,
    bool shouldClaim
  ) external override onlyStakingPool returns (uint256) {
    if (paused() && shouldClaim) revert CannotClaimRewardWhenPaused();

    _updateRewardPerToken();

    // _isOperator is not used here to save gas.  The _isOperator function
    // currently checks for 2 things.  The first that the staker is currently
    // an operator and the other is that the staker is a removed operator.  As
    // this function will only be called by a staking pool, the contract can
    // safely assume that the staker is an operator if the msg.sender is the
    // operator staking pool as upgrading a pool/reward vault means that the operator
    // staking pool will point to a new reward vault.  Additionally the contract
    // assumes that it does not need to do the second check to determine whether
    // or not an operator had been removed as it is unlikely that an operator
    // is removed after the reward vault is closed.
    bool isOperator = msg.sender == address(i_operatorStakingPool);
    bool shouldForfeit = unstakedAmount != 0;
    StakerReward memory stakerReward = _calculateStakerReward({
      staker: staker,
      isOperator: isOperator,
      stakerPrincipal: oldPrincipal
    });
    uint256 fullForfeitedRewardAmount = _applyMultiplier({
      stakerReward: stakerReward,
      shouldForfeit: shouldForfeit,
      stakerStakedAtTime: stakedAt
    });

    if (fullForfeitedRewardAmount != 0) {
      _forfeitStakerBaseReward({
        stakerReward: stakerReward,
        fullForfeitedRewardAmount: fullForfeitedRewardAmount,
        unstakedAmount: unstakedAmount,
        oldPrincipal: oldPrincipal,
        isOperator: isOperator
      });
    }

    delete stakerReward.earnedBaseRewardInPeriod;
    delete stakerReward.claimedBaseRewardsInPeriod;

    uint256 claimedAmount;

    if (shouldClaim) {
      claimedAmount = _transferRewards(staker, stakerReward);
    }

    s_rewards[staker] = stakerReward;

    emit RewardFinalized(staker, shouldForfeit);
    emit StakerRewardUpdated(
      staker,
      stakerReward.finalizedBaseReward,
      stakerReward.finalizedDelegatedReward,
      stakerReward.baseRewardPerToken,
      stakerReward.operatorDelegatedRewardPerToken,
      stakerReward.claimedBaseRewardsInPeriod
    );

    return claimedAmount;
  }

  /// @inheritdoc IRewardVault
  /// @dev Withdraws any unavailable LINK rewards to the owner's address.
  /// @dev precondition The caller must have the default admin role.
  /// @dev precondition This contract must be open.
  function close() external override onlyRole(DEFAULT_ADMIN_ROLE) whenOpen {
    (, uint256 totalUnvestedRewards,,,) = _stopVestingRewardsToBuckets();
    delete s_vaultConfig.isOpen;
    // The return value is not checked since the call will revert if any balance, allowance or
    // receiver conditions fail.
    i_LINK.transfer(msg.sender, totalUnvestedRewards);
    emit VaultClosed(totalUnvestedRewards);
  }

  /// @inheritdoc IRewardVault
  function getReward(address staker) external view override returns (uint256) {
    (StakerReward memory stakerReward, uint256 forfeitedReward) = _getReward(staker);

    bool isOperator = _isOperator(staker);

    IStakingPool stakingPool =
      isOperator ? IStakingPool(i_operatorStakingPool) : IStakingPool(i_communityStakingPool);

    (,, uint256 reclaimableReward) =
      _calculateForfeitedRewardDistribution(forfeitedReward, _getTotalPrincipal(stakingPool));

    return
      stakerReward.finalizedBaseReward + stakerReward.finalizedDelegatedReward + reclaimableReward;
  }

  /// @inheritdoc IRewardVault
  function isOpen() external view override returns (bool) {
    return s_vaultConfig.isOpen;
  }

  /// @inheritdoc IRewardVault
  function hasRewardDurationEnded(address stakingPool) external view override returns (bool) {
    if (stakingPool == address(i_operatorStakingPool)) {
      return s_rewardBuckets.operatorBase.rewardDurationEndsAt <= block.timestamp
        && s_rewardBuckets.operatorDelegated.rewardDurationEndsAt <= block.timestamp;
    }
    if (stakingPool == address(i_communityStakingPool)) {
      return s_rewardBuckets.communityBase.rewardDurationEndsAt <= block.timestamp;
    }

    revert InvalidPool();
  }

  /// @inheritdoc IRewardVault
  function getStoredReward(address staker) external view override returns (StakerReward memory) {
    return s_rewards[staker];
  }

  /// @notice Returns the reward buckets within this vault
  /// @return The reward buckets
  function getRewardBuckets() external view returns (RewardBuckets memory) {
    return s_rewardBuckets;
  }

  /// @notice Returns the timestamp of the last reward per token update
  /// @return The timestamp of the last update
  function getRewardPerTokenUpdatedAt() external view returns (uint256) {
    return s_rewardPerTokenUpdatedAt;
  }

  /// @notice Returns the multiplier ramp up time
  /// @return uint256 The multiplier ramp up time
  function getMultiplierDuration() external view returns (uint256) {
    return s_vaultConfig.multiplierDuration;
  }

  /// @notice Returns the ramp up multiplier of the staker
  /// @dev Multipliers are in the range of 0 and 1, so we multiply them by 1e18 (WAD) to preserve
  /// the decimals.
  /// @param staker The address of the staker
  /// @return uint256 The staker's multiplier
  function getMultiplier(address staker) external view returns (uint256) {
    IStakingPool stakingPool = _isOperator(staker)
      ? IStakingPool(i_operatorStakingPool)
      : IStakingPool(i_communityStakingPool);

    return _getMultiplier(_getStakerStakedAtTime(staker, stakingPool));
  }

  /// @notice Calculates and returns the latest reward info of the staker
  /// @param staker The staker address
  /// @return StakerReward The staker's reward info
  /// @return uint256 The staker's forfeited reward in juels
  function calculateLatestStakerReward(address staker)
    external
    view
    returns (StakerReward memory, uint256)
  {
    return _getReward(staker);
  }

  /// @notice Returns the migration checkpoint data
  /// @return VestingCheckpointData The migration checkpoint
  function getVestingCheckpointData() external view returns (VestingCheckpointData memory) {
    return s_finalVestingCheckpointData;
  }

  /// @notice Returns the unavailable rewards
  /// @return unvestedCommunityBaseRewards The unavailable community base rewards
  /// @return unvestedOperatorBaseRewards The unavailable operator base rewards
  /// @return unvestedOperatorDelegatedRewards The unavailable operator delegated rewards
  function getUnvestedRewards() external view returns (uint256, uint256, uint256) {
    uint256 unvestedCommunityBaseRewards = _getUnvestedRewards(s_rewardBuckets.communityBase);
    uint256 unvestedOperatorBaseRewards = _getUnvestedRewards(s_rewardBuckets.operatorBase);
    uint256 unvestedOperatorDelegatedRewards =
      _getUnvestedRewards(s_rewardBuckets.operatorDelegated);
    return
      (unvestedCommunityBaseRewards, unvestedOperatorBaseRewards, unvestedOperatorDelegatedRewards);
  }

  /// @inheritdoc IRewardVault
  function isPaused() external view override(IRewardVault) returns (bool) {
    return paused();
  }

  // =========
  // Helpers
  // =========

  /// @notice Forfeits a proportion of the staker's full forfeited reward amount
  /// based on the amount of juels they unstake
  /// @param stakerReward The staker's reward struct
  /// @param fullForfeitedRewardAmount The amount of rewards the staker has
  /// forfeited because of their multiplier in juels
  /// @param unstakedAmount  The amount the staker has unstaked in juels
  /// @param oldPrincipal The staker's staked LINK amount before unstaking in juels
  /// @param isOperator True if the staker is an operator
  function _forfeitStakerBaseReward(
    StakerReward memory stakerReward,
    uint256 fullForfeitedRewardAmount,
    uint256 unstakedAmount,
    uint256 oldPrincipal,
    bool isOperator
  ) private {
    uint256 forfeitedRewardAmount;

    uint256 forfeitedRewardAmountTimesUnstakedAmount = fullForfeitedRewardAmount * unstakedAmount;

    // This handles the edge case when a staker has earned too little rewards and
    // unstakes a very small amount.  In this scenario the reward vault will
    // forfeit the full amount of unclaimable rewards instead of calculating
    // the proportion of the unclaimable rewards that should be forfeited.
    if (forfeitedRewardAmountTimesUnstakedAmount < oldPrincipal) {
      forfeitedRewardAmount = fullForfeitedRewardAmount;
    } else {
      forfeitedRewardAmount = forfeitedRewardAmountTimesUnstakedAmount / oldPrincipal;
    }

    IStakingPool stakingPool =
      isOperator ? IStakingPool(i_operatorStakingPool) : IStakingPool(i_communityStakingPool);

    uint256 stakerSubtractedTotalPrincipal = _getTotalPrincipal(stakingPool) - oldPrincipal;

    // the reclaimable reward is the forfeited reward that can be claimed by the last staker due
    // to empty pools
    (uint256 redistributedReward, uint256 reclaimableReward) =
      _distributeForfeitedReward(forfeitedRewardAmount, stakerSubtractedTotalPrincipal, isOperator);

    if (redistributedReward != 0) {
      _updateStakerRewardPerToken(stakerReward, isOperator);
    }
    if (reclaimableReward != 0) {
      stakerReward.finalizedBaseReward += reclaimableReward.toUint112();
    }

    stakerReward.storedBaseReward += fullForfeitedRewardAmount - forfeitedRewardAmount;
  }

  /// @notice Stops rewards in all buckets from vesting and close the vault.
  /// @dev This will also checkpoint the staking pools
  /// @return uint256 The total aggregate reward rate from all three buckets
  /// @return uint256 The total amount of available rewards in juels
  /// @return uint256 The amount of available operator base rewards in juels
  /// @return uint256 The amount of available community base rewards in juels
  /// @return uint256 The amount of available operator delegated rewards in juels
  function _stopVestingRewardsToBuckets()
    private
    returns (uint256, uint256, uint256, uint256, uint256)
  {
    _updateRewardPerToken();

    uint256 unvestedOperatorBaseRewards = _stopVestingBucketRewards(s_rewardBuckets.operatorBase);
    uint256 unvestedCommunityBaseRewards = _stopVestingBucketRewards(s_rewardBuckets.communityBase);
    uint256 unvestedOperatorDelegatedRewards =
      _stopVestingBucketRewards(s_rewardBuckets.operatorDelegated);
    uint256 totalUnvestedRewards =
      unvestedOperatorBaseRewards + unvestedCommunityBaseRewards + unvestedOperatorDelegatedRewards;

    _checkpointStakingPools();

    return (
      s_rewardBuckets.operatorBase.emissionRate + s_rewardBuckets.communityBase.emissionRate
        + s_rewardBuckets.operatorDelegated.emissionRate,
      totalUnvestedRewards,
      unvestedOperatorBaseRewards,
      unvestedCommunityBaseRewards,
      unvestedOperatorDelegatedRewards
    );
  }

  /// @notice Returns the total staked LINK amount staked in a staking pool.  This will
  /// return the staking pool's latest total staked LINK amount if the vault has not been
  /// migrated from and the pool's total staked LINK amount at the time the vault was
  /// migrated if the vault has already been migrated.
  /// @param stakingPool The staking pool to query the total staked LINK amount for
  /// @return uint256 The total staked LINK amount staked in the staking pool
  function _getTotalPrincipal(IStakingPool stakingPool) private view returns (uint256) {
    return s_vaultConfig.isOpen
      ? stakingPool.getTotalPrincipal()
      : _getMigratedAtTotalPoolPrincipal(stakingPool);
  }

  /// @notice Returns the staker's staked LINK amount in a staking pool.  This will
  /// return the staker's latest staked LINK amount if the vault has not been
  /// migrated from and the staker's staked LINK amount at the time the vault was
  /// migrated if the vault has already been migrated.
  /// @param staker The staker to query the total staked LINK amount for
  /// @param stakingPool The staking pool to query the total staked LINK amount for
  /// @return uint256 The staker's staked LINK amount in the staking pool in juels
  function _getStakerPrincipal(
    address staker,
    IStakingPool stakingPool
  ) private view returns (uint256) {
    return s_vaultConfig.isOpen
      ? stakingPool.getStakerPrincipal(staker)
      : stakingPool.getStakerPrincipalAt(staker, _getMigratedAtCheckpointId(stakingPool));
  }

  /// @notice Helper function to get a staker's current multiplier
  /// @param stakedAt The time the staker last staked at
  /// @return uint256 The staker's multiplier
  function _getMultiplier(uint256 stakedAt) private view returns (uint256) {
    if (stakedAt == 0) return 0;

    uint256 multiplierDuration = s_vaultConfig.multiplierDuration;
    if (multiplierDuration == 0) return MAX_MULTIPLIER;

    return Math.min(
      FixedPointMathLib.divWadDown(block.timestamp - stakedAt, multiplierDuration), MAX_MULTIPLIER
    );
  }

  /// @notice Returns the staker's staked at time in a staking pool.  This will
  /// return the staker's latest staked at time if the vault has not been
  /// migrated from and the staker's staked at time at the time the vault was
  /// migrated if the vault has already been migrated.
  /// @param staker The staker to query the staked at time for
  /// @param stakingPool The staking pool to query the staked at time for
  /// @return uint256 The staker's average staked at time in the staking pool
  function _getStakerStakedAtTime(
    address staker,
    IStakingPool stakingPool
  ) private view returns (uint256) {
    return s_vaultConfig.isOpen
      ? stakingPool.getStakerStakedAtTime(staker)
      : stakingPool.getStakerStakedAtTimeAt(staker, _getMigratedAtCheckpointId(stakingPool));
  }

  /// @notice Returns the migrated at checkpoint ID to use depending on which
  /// staking pool the staker is in
  /// @param stakingPool The stake pool to query the migrated at checkpoint ID for
  /// @return uint256 The checkpointId
  function _getMigratedAtCheckpointId(IStakingPool stakingPool) private view returns (uint256) {
    return address(stakingPool) == address(i_operatorStakingPool)
      ? s_finalVestingCheckpointData.operatorPoolCheckpointId
      : s_finalVestingCheckpointData.communityPoolCheckpointId;
  }

  /// @notice Return the staking pool's total staked LINK amount at the time the vault was
  /// migrated
  /// @param stakingPool The staking pool to query the total staked LINK amount for
  /// @return uint256 The pool's total staked LINK amount at the time the vault was
  /// upgraded
  function _getMigratedAtTotalPoolPrincipal(IStakingPool stakingPool)
    private
    view
    returns (uint256)
  {
    return address(stakingPool) == address(i_operatorStakingPool)
      ? s_finalVestingCheckpointData.operatorPoolTotalPrincipal
      : s_finalVestingCheckpointData.communityPoolTotalPrincipal;
  }

  /// @notice Records the current checkpoint IDs and the total staked LINK amount in the
  /// operator and community staking pools
  /// @dev This is called in the migrate function when upgrading the vault
  function _checkpointStakingPools() private {
    s_finalVestingCheckpointData.operatorPoolTotalPrincipal =
      i_operatorStakingPool.getTotalPrincipal();
    s_finalVestingCheckpointData.communityPoolTotalPrincipal =
      i_communityStakingPool.getTotalPrincipal();

    uint256 operatorPoolCheckpointId = i_operatorStakingPool.getCurrentCheckpointId();
    uint256 communityPoolCheckpointId = i_communityStakingPool.getCurrentCheckpointId();

    // We store the last checkpointId  used to record a staker's staked LINK amount as the
    // current checkpointId will be used to record the next staker action in
    // the staking pool after the reward vault is migrated.
    if (operatorPoolCheckpointId != 0) {
      s_finalVestingCheckpointData.operatorPoolCheckpointId = operatorPoolCheckpointId - 1;
    }

    if (communityPoolCheckpointId != 0) {
      s_finalVestingCheckpointData.communityPoolCheckpointId = communityPoolCheckpointId - 1;
    }
  }

  /// @notice Stops rewards in a bucket from vesting
  /// @param bucket The bucket to stop vesting rewards for
  /// @return uint256 The amount of unavailable rewards in juels
  function _stopVestingBucketRewards(RewardBucket storage bucket) private returns (uint256) {
    uint256 unvestedRewards = _getUnvestedRewards(bucket);
    bucket.rewardDurationEndsAt = block.timestamp.toUint80();
    return unvestedRewards;
  }

  /// @notice Updates the reward buckets
  /// @param pool The staking pool address
  /// @param amount The reward amount
  /// @param emissionRate The target aggregate reward rate (Juels/second)
  function _updateRewardBuckets(address pool, uint256 amount, uint256 emissionRate) private {
    // split the reward and aggregate reward rate for the different reward buckets
    BucketRewardEmissionSplit memory emissionSplitData = _getBucketRewardAndEmissionRateSplit({
      pool: pool,
      amount: amount,
      emissionRate: emissionRate,
      isDelegated: s_vaultConfig.delegationRateDenominator != 0
    });

    // If the aggregate reward rate is zero, we don't update the reward bucket
    // This is because we do not allow a zero aggregate reward rate
    // A zero aggregate reward rate means no rewards have been added
    if (emissionSplitData.communityRate != 0) {
      _updateRewardBucket({
        bucket: s_rewardBuckets.communityBase,
        amount: emissionSplitData.communityReward,
        emissionRate: emissionSplitData.communityRate
      });
    }
    if (emissionSplitData.operatorRate != 0) {
      _updateRewardBucket({
        bucket: s_rewardBuckets.operatorBase,
        amount: emissionSplitData.operatorReward,
        emissionRate: emissionSplitData.operatorRate
      });
    }
    if (emissionSplitData.delegatedRate != 0) {
      _updateRewardBucket({
        bucket: s_rewardBuckets.operatorDelegated,
        amount: emissionSplitData.operatorDelegatedReward,
        emissionRate: emissionSplitData.delegatedRate
      });
    }
  }

  /// @notice Updates the reward bucket
  /// @param bucket The reward bucket
  /// @param amount The reward amount
  /// @param emissionRate The target aggregate reward rate (token/second)
  function _updateRewardBucket(
    RewardBucket storage bucket,
    uint256 amount,
    uint256 emissionRate
  ) private {
    // calculate the remaining rewards
    uint256 remainingRewards = _getUnvestedRewards(bucket);

    // if the amount of rewards is less than what becomes available per second, we revert
    if (amount + remainingRewards < emissionRate) revert RewardDurationTooShort();

    _updateRewardDurationEndsAt({
      bucket: bucket,
      rewardAmount: amount + remainingRewards,
      emissionRate: emissionRate
    });
    bucket.emissionRate = emissionRate.toUint80();
  }

  /// @notice Updates the reward duration end time of the bucket
  /// @param bucket The reward bucket
  /// @param rewardAmount The reward amount
  /// @param emissionRate The aggregate reward rate
  function _updateRewardDurationEndsAt(
    RewardBucket storage bucket,
    uint256 rewardAmount,
    uint256 emissionRate
  ) private {
    if (emissionRate == 0) return;
    bucket.rewardDurationEndsAt = (block.timestamp + (rewardAmount / emissionRate)).toUint80();
  }

  /// @notice Splits the reward and aggregate reward rates between the different reward buckets
  /// @dev If the pool is not targeted, the returned reward and aggregate reward rate will be zero
  /// @param pool The staking pool address (or zero address if the reward is split between all
  /// pools)
  /// @param amount The reward amount
  /// @param emissionRate The aggregate reward rate (juels/second)
  /// @param isDelegated Whether the reward is delegated or not
  /// @return BucketRewardEmissionSplit The rewards and aggregate reward rates after
  /// distributing the reward amount to the buckets
  function _getBucketRewardAndEmissionRateSplit(
    address pool,
    uint256 amount,
    uint256 emissionRate,
    bool isDelegated
  ) private view returns (BucketRewardEmissionSplit memory) {
    // when splitting reward and rate, a pool's share is 0 if it is not targeted by the pool
    // address,
    // otherwise it is the pool's max size
    // a pool's share is used to split rewards and aggregate reward rates proportionally
    uint256 communityPoolShare =
      pool != address(i_operatorStakingPool) ? i_communityStakingPool.getMaxPoolSize() : 0;
    uint256 operatorPoolShare =
      pool != address(i_communityStakingPool) ? i_operatorStakingPool.getMaxPoolSize() : 0;
    uint256 totalPoolShare = communityPoolShare + operatorPoolShare;

    // prevent a possible rounding to zero error by validating inputs
    _checkForRoundingToZeroRewardAmountSplit({
      rewardAmount: amount,
      communityPoolShare: communityPoolShare,
      operatorPoolShare: operatorPoolShare,
      totalPoolShare: totalPoolShare
    });
    _checkForRoundingToZeroEmissionRateSplit({
      emissionRate: emissionRate,
      communityPoolShare: communityPoolShare,
      operatorPoolShare: operatorPoolShare,
      totalPoolShare: totalPoolShare
    });

    // if the operator pool is not targeted, the reward and aggregate reward rate is zero
    uint256 operatorReward = amount.mulWadDown(operatorPoolShare).divWadDown(totalPoolShare);
    uint256 operatorRate = emissionRate.mulWadDown(operatorPoolShare).divWadDown(totalPoolShare);
    // if the community staking pool is not targeted, the reward and aggregate reward rate is zero
    uint256 communityReward = amount - operatorReward;
    uint256 communityRate = emissionRate - operatorRate;

    uint256 operatorDelegatedReward;
    uint256 delegatedRate;
    // if there is no delegation or the community pool is not targeted, the delegated reward and
    // rate is zero
    if (isDelegated && communityPoolShare != 0) {
      // prevent a possible rounding to zero error by validating inputs
      _checkForRoundingToZeroDelegationSplit({
        communityReward: communityReward,
        communityRate: communityRate,
        delegationDenominator: s_vaultConfig.delegationRateDenominator
      });

      // calculate the delegated pool reward and remove from community reward
      operatorDelegatedReward = communityReward / s_vaultConfig.delegationRateDenominator;
      communityReward -= operatorDelegatedReward;

      // calculate the delegated pool aggregate reward rate and remove from community rate
      delegatedRate = communityRate / s_vaultConfig.delegationRateDenominator;
      communityRate -= delegatedRate;
    }

    return (
      BucketRewardEmissionSplit({
        communityReward: communityReward,
        operatorReward: operatorReward,
        operatorDelegatedReward: operatorDelegatedReward,
        communityRate: communityRate,
        operatorRate: operatorRate,
        delegatedRate: delegatedRate
      })
    );
  }

  /// @notice Validates the added reward amount after splitting to avoid a rounding error when
  /// dividing
  /// @param rewardAmount The reward amount
  /// @param communityPoolShare The size of the community staking pool to take into account
  /// @param operatorPoolShare The size of the operator staking pool to take into account
  /// @param totalPoolShare The total size of the pools to take into account
  function _checkForRoundingToZeroRewardAmountSplit(
    uint256 rewardAmount,
    uint256 communityPoolShare,
    uint256 operatorPoolShare,
    uint256 totalPoolShare
  ) private pure {
    if (
      rewardAmount != 0
        && (
          (
            operatorPoolShare != 0
              && rewardAmount.mulWadDown(operatorPoolShare) * FixedPointMathLib.WAD < totalPoolShare
          )
            || (
              communityPoolShare != 0
                && rewardAmount.mulWadDown(communityPoolShare) * FixedPointMathLib.WAD < totalPoolShare
            )
        )
    ) {
      revert InvalidRewardAmount();
    }
  }

  /// @notice Validates the aggregate reward rate after splitting to avoid a rounding error when
  /// dividing
  /// @param emissionRate The aggregate reward rate
  /// @param communityPoolShare The size of the community staking pool to take into account
  /// @param operatorPoolShare The size of the operator staking pool to take into account
  /// @param totalPoolShare The total size of the pools to take into account
  function _checkForRoundingToZeroEmissionRateSplit(
    uint256 emissionRate,
    uint256 communityPoolShare,
    uint256 operatorPoolShare,
    uint256 totalPoolShare
  ) private pure {
    if (
      (
        operatorPoolShare != 0
          && emissionRate.mulWadDown(operatorPoolShare) * FixedPointMathLib.WAD < totalPoolShare
      )
        || (
          communityPoolShare != 0
            && emissionRate.mulWadDown(communityPoolShare) * FixedPointMathLib.WAD < totalPoolShare
        )
    ) {
      revert InvalidEmissionRate();
    }
  }

  /// @notice Validates the delegation denominator after splitting to avoid a rounding error when
  /// dividing
  /// @param communityReward The reward for the community staking pool
  /// @param communityRate The aggregate reward rate for the community staking pool
  /// @param delegationDenominator The delegation denominator
  function _checkForRoundingToZeroDelegationSplit(
    uint256 communityReward,
    uint256 communityRate,
    uint256 delegationDenominator
  ) private pure {
    if (communityReward != 0 && communityReward < delegationDenominator) {
      revert InvalidRewardAmount();
    }

    if (communityRate != 0 && communityRate < delegationDenominator) {
      revert InvalidEmissionRate();
    }
  }

  /// @notice Private util function for updateRewardPerToken
  function _updateRewardPerToken() private {
    // if the pools were previously updated in the same block there is no recalculation of reward
    if (s_rewardPerTokenUpdatedAt < block.timestamp) {
      (
        uint256 communityRewardPerToken,
        uint256 operatorRewardPerToken,
        uint256 operatorDelegatedRewardPerToken
      ) = _calculatePoolsRewardPerToken();

      s_rewardBuckets.communityBase.vestedRewardPerToken = communityRewardPerToken.toUint80();
      s_rewardBuckets.operatorBase.vestedRewardPerToken = operatorRewardPerToken.toUint80();
      s_rewardBuckets.operatorDelegated.vestedRewardPerToken =
        operatorDelegatedRewardPerToken.toUint80();

      s_rewardPerTokenUpdatedAt = block.timestamp;

      emit PoolRewardUpdated(
        s_rewardBuckets.communityBase.vestedRewardPerToken,
        s_rewardBuckets.operatorBase.vestedRewardPerToken,
        s_rewardBuckets.operatorDelegated.vestedRewardPerToken
      );
    }
  }

  /// @notice Util function for calculating the current reward per token for the pools
  /// @return uint256 The community reward per token
  /// @return uint256 The operator reward per token
  /// @return uint256 The operator delegated reward per token
  function _calculatePoolsRewardPerToken() private view returns (uint256, uint256, uint256) {
    uint256 communityTotalPrincipal = _getTotalPrincipal(i_communityStakingPool);
    uint256 operatorTotalPrincipal = _getTotalPrincipal(i_operatorStakingPool);

    return (
      _calculateVestedRewardPerToken(s_rewardBuckets.communityBase, communityTotalPrincipal),
      _calculateVestedRewardPerToken(s_rewardBuckets.operatorBase, operatorTotalPrincipal),
      _calculateVestedRewardPerToken(s_rewardBuckets.operatorDelegated, operatorTotalPrincipal)
    );
  }

  /// @notice Calculate a bucket’s available rewards earned per token
  /// @param rewardBucket The reward bucket to calculate the vestedRewardPerToken for
  /// @param totalPrincipal The total staked LINK amount staked in a pool associated with the reward
  /// bucket
  /// @return uint256 The available rewards earned per token
  function _calculateVestedRewardPerToken(
    RewardBucket memory rewardBucket,
    uint256 totalPrincipal
  ) private view returns (uint256) {
    if (totalPrincipal == 0) return rewardBucket.vestedRewardPerToken;

    uint256 latestRewardEmittedAt = Math.min(rewardBucket.rewardDurationEndsAt, block.timestamp);
    if (latestRewardEmittedAt <= s_rewardPerTokenUpdatedAt) {
      return rewardBucket.vestedRewardPerToken;
    }

    uint256 elapsedTime = latestRewardEmittedAt - s_rewardPerTokenUpdatedAt;

    return rewardBucket.vestedRewardPerToken
      + (elapsedTime * rewardBucket.emissionRate).divWadDown(totalPrincipal);
  }

  /// @notice Calculates a stakers earned base reward
  /// @param stakerReward The staker's reward info
  /// @param stakerPrincipal The staker's staked LINK amount
  /// @param baseRewardPerToken The base reward per token of the staking pool
  /// @return uint256 The earned base reward
  function _calculateEarnedBaseReward(
    StakerReward memory stakerReward,
    uint256 stakerPrincipal,
    uint256 baseRewardPerToken
  ) private pure returns (uint256) {
    uint256 earnedBaseReward = _calculateAccruedReward({
      principal: stakerPrincipal,
      rewardPerToken: stakerReward.baseRewardPerToken,
      vestedRewardPerToken: baseRewardPerToken
    });

    return earnedBaseReward;
  }

  /// @notice Calculates a operators earned delegated reward
  /// @param stakerReward The staker's reward info
  /// @param stakerPrincipal The staker's staked LINK amount
  /// @param operatorDelegatedRewardPerToken The operator delegated reward per token
  /// @return uint256 The earned delegated reward
  function _calculateEarnedDelegatedReward(
    StakerReward memory stakerReward,
    uint256 stakerPrincipal,
    uint256 operatorDelegatedRewardPerToken
  ) private pure returns (uint256) {
    uint256 earnedDelegatedReward = _calculateAccruedReward({
      principal: stakerPrincipal,
      rewardPerToken: stakerReward.operatorDelegatedRewardPerToken,
      vestedRewardPerToken: operatorDelegatedRewardPerToken
    });

    return earnedDelegatedReward;
  }

  /// @notice Applies the multiplier to the staker's reward
  /// @dev Finalizes rewards by incrementing the staker's finalizedBaseReward
  /// @param stakerReward The staker's reward info
  /// @param shouldForfeit True if the staker should forfeit rewards if they haven't reach the max
  /// multiplier
  /// @param stakerStakedAtTime The time the staker last staked at
  /// @return uint256 The forfeited reward amount in juels
  function _applyMultiplier(
    StakerReward memory stakerReward,
    bool shouldForfeit,
    uint256 stakerStakedAtTime
  ) private view returns (uint256) {
    uint256 multiplier = _getMultiplier(stakerStakedAtTime);

    uint256 fullBaseRewards = (
      stakerReward.storedBaseReward + uint256(stakerReward.claimedBaseRewardsInPeriod)
    ).mulWadDown(MAX_MULTIPLIER);
    uint256 claimableBaseRewards = (
      stakerReward.storedBaseReward + uint256(stakerReward.claimedBaseRewardsInPeriod)
    ).mulWadDown(multiplier);

    // We need to handle the case where we increase the multiplier ramp up period and it leads to
    // the amount of claimable rewards being less than what the staker had already claimed
    uint112 newlyEarnedBaseRewards = claimableBaseRewards > stakerReward.claimedBaseRewardsInPeriod
      ? (claimableBaseRewards - stakerReward.claimedBaseRewardsInPeriod).toUint112()
      : 0;

    stakerReward.finalizedBaseReward += newlyEarnedBaseRewards;
    stakerReward.earnedBaseRewardInPeriod += newlyEarnedBaseRewards;
    uint256 forfeitedReward = fullBaseRewards - claimableBaseRewards;

    if (shouldForfeit) {
      delete stakerReward.storedBaseReward;
    } else {
      stakerReward.storedBaseReward = forfeitedReward;
      forfeitedReward = 0;
    }

    return forfeitedReward;
  }

  /// @notice Calculates the newly accrued reward of a staker since the last time the staker's
  /// reward was updated
  /// @param principal The staker's staked LINK amount
  /// @param rewardPerToken The base or delegated reward per token of the staker
  /// @param vestedRewardPerToken The available reward per token of the staking pool
  /// @return uint256 The accrued reward amount
  function _calculateAccruedReward(
    uint256 principal,
    uint256 rewardPerToken,
    uint256 vestedRewardPerToken
  ) private pure returns (uint256) {
    return principal.mulWadDown(vestedRewardPerToken - rewardPerToken);
  }

  /// @notice Calculates and updates a staker's rewards
  /// @param staker The staker's address
  /// @param isOperator True if the staker is an operator, false otherwise
  /// @param stakerPrincipal The staker's staked LINK amount
  /// @dev Staker rewards are forfeited when a staker unstakes before they
  /// have reached their maximum ramp up period multiplier.  Additionally an
  /// operator will also forfeit any unclaimed rewards if they are removed
  /// before they reach the maximum ramp up period multiplier.
  function _calculateStakerReward(
    address staker,
    bool isOperator,
    uint256 stakerPrincipal
  ) private view returns (StakerReward memory) {
    StakerReward memory stakerReward = s_rewards[staker];

    if (stakerReward.stakerType != StakerType.NOT_STAKED) {
      // do nothing
    } else {
      stakerReward.stakerType = isOperator ? StakerType.OPERATOR : StakerType.COMMUNITY;
    }

    // Calculate earned base rewards
    stakerReward.storedBaseReward += _calculateEarnedBaseReward({
      stakerReward: stakerReward,
      stakerPrincipal: stakerPrincipal,
      baseRewardPerToken: isOperator
        ? s_rewardBuckets.operatorBase.vestedRewardPerToken
        : s_rewardBuckets.communityBase.vestedRewardPerToken
    });

    // Calculate earned delegated rewards if the staker is an operator
    if (isOperator) {
      // Multipliers do not apply to the delegation reward, i.e. always treat them as
      // multiplied by the max multiplier, which is 1.
      stakerReward.finalizedDelegatedReward += _calculateEarnedDelegatedReward({
        stakerReward: stakerReward,
        stakerPrincipal: stakerPrincipal,
        operatorDelegatedRewardPerToken: s_rewardBuckets.operatorDelegated.vestedRewardPerToken
      }).toUint112();
    }

    // Update the staker's earned reward per token
    _updateStakerRewardPerToken(stakerReward, isOperator);

    return stakerReward;
  }

  /// @notice Distributes the forfeited reward immediately to the reward buckets
  /// @param forfeitedReward The amount of forfeited rewards in juels
  /// @param amountOfRecipientTokens The amount of tokens that the forfeited rewards should be
  /// shared to
  /// @param toOperatorPool Whether the forfeited reward should be shared to the operator pool
  /// @return uint256 The amount of forfeited reward that were shared
  /// @return uint256 The amount of forfeited reward that can be reclaimed due to empty pools
  function _distributeForfeitedReward(
    uint256 forfeitedReward,
    uint256 amountOfRecipientTokens,
    bool toOperatorPool
  ) private returns (uint256, uint256) {
    (uint256 vestedReward, uint256 vestedRewardPerToken, uint256 reclaimableReward) =
      _calculateForfeitedRewardDistribution(forfeitedReward, amountOfRecipientTokens);

    if (vestedRewardPerToken != 0) {
      if (toOperatorPool) {
        s_rewardBuckets.operatorBase.vestedRewardPerToken += vestedRewardPerToken.toUint80();
      } else {
        s_rewardBuckets.communityBase.vestedRewardPerToken += vestedRewardPerToken.toUint80();
      }
    }

    emit ForfeitedRewardDistributed(
      vestedReward, vestedRewardPerToken, reclaimableReward, toOperatorPool
    );

    return (vestedReward, reclaimableReward);
  }

  /// @notice Helper function for calculating the available reward per token and the reclaimable
  /// reward
  /// @dev If the pool the staker is in is empty and we can't calculate the reward per token, we
  /// allow the staker to reclaim the forfeited reward.
  /// @param forfeitedReward The amount of forfeited reward
  /// @param amountOfRecipientTokens The amount of tokens that the forfeited rewards should be
  /// shared to
  /// @return uint256 The amount of shared forfeited reward
  /// @return uint256 The shared forfeited reward per token
  /// @return uint256 The amount of reclaimable reward
  function _calculateForfeitedRewardDistribution(
    uint256 forfeitedReward,
    uint256 amountOfRecipientTokens
  ) private pure returns (uint256, uint256, uint256) {
    if (forfeitedReward == 0) return (0, 0, 0);

    uint256 vestedReward;
    uint256 vestedRewardPerToken;
    uint256 reclaimableReward;

    if (amountOfRecipientTokens != 0) {
      vestedReward = forfeitedReward;
      vestedRewardPerToken = forfeitedReward.divWadDown(amountOfRecipientTokens);
    } else {
      reclaimableReward = forfeitedReward;
    }

    return (vestedReward, vestedRewardPerToken, reclaimableReward);
  }

  /// @notice Updates the staker's base and/or delegated reward per token values
  /// @dev This function is called when staking, unstaking, claiming rewards, finalizing rewards for
  /// removed operators, and slashing operators.
  /// @param stakerReward The staker reward struct
  /// @param isOperator Whether the staker is an operator or not
  function _updateStakerRewardPerToken(
    StakerReward memory stakerReward,
    bool isOperator
  ) private view {
    if (isOperator) {
      stakerReward.baseRewardPerToken = s_rewardBuckets.operatorBase.vestedRewardPerToken;
      stakerReward.operatorDelegatedRewardPerToken =
        s_rewardBuckets.operatorDelegated.vestedRewardPerToken;
    } else {
      stakerReward.baseRewardPerToken = s_rewardBuckets.communityBase.vestedRewardPerToken;
    }
  }

  /// @notice Calculates a staker's earned rewards
  /// @param staker The staker
  /// @return The staker reward info
  /// @return The forfeited reward
  function _getReward(address staker) private view returns (StakerReward memory, uint256) {
    StakerReward memory stakerReward = s_rewards[staker];

    // Determine if staker is operator or community
    bool isOperator = _isOperator(staker);

    uint256 stakerPrincipal = _getStakerPrincipal(
      staker,
      isOperator ? IStakingPool(i_operatorStakingPool) : IStakingPool(i_communityStakingPool)
    );

    // Calculate latest reward per token for the pools
    (
      uint256 communityRewardPerToken,
      uint256 operatorRewardPerToken,
      uint256 operatorDelegatedRewardPerToken
    ) = _calculatePoolsRewardPerToken();

    // Calculate earned base rewards
    stakerReward.storedBaseReward += _calculateEarnedBaseReward({
      stakerReward: stakerReward,
      stakerPrincipal: stakerPrincipal,
      baseRewardPerToken: isOperator ? operatorRewardPerToken : communityRewardPerToken
    });

    // If operator Calculate earned delegated rewards
    if (isOperator) {
      // Multipliers do not apply to the delegation reward, i.e. always treat them as
      // multiplied by the max multiplier, which is 1.
      stakerReward.finalizedDelegatedReward += _calculateEarnedDelegatedReward({
        stakerReward: stakerReward,
        stakerPrincipal: stakerPrincipal,
        operatorDelegatedRewardPerToken: operatorDelegatedRewardPerToken
      }).toUint112();
    }

    uint256 forfeitedReward = _applyMultiplier({
      stakerReward: stakerReward,
      shouldForfeit: true,
      stakerStakedAtTime: _getStakerStakedAtTime(
        staker,
        isOperator ? IStakingPool(i_operatorStakingPool) : IStakingPool(i_communityStakingPool)
        )
    });

    return (stakerReward, forfeitedReward);
  }

  /// @notice Calculates the amount of unavailable rewards in a reward bucket
  /// @param bucket The bucket to calculate unavailable rewards for
  /// @return uint256 The amount of unavailable rewards in the bucket
  function _getUnvestedRewards(RewardBucket memory bucket) private view returns (uint256) {
    return bucket.rewardDurationEndsAt <= block.timestamp
      ? 0
      : bucket.emissionRate * (bucket.rewardDurationEndsAt - block.timestamp);
  }

  /// @notice Validates that the amount of rewards added and the aggregate reward rate
  /// are valid and enough to cover the delegation rate
  /// @param addedRewardAmount The amount of added rewards
  /// @param totalEmissionRate The aggregate reward rate to the entire vault
  function _validateAddedRewards(uint256 addedRewardAmount, uint256 totalEmissionRate) private view {
    // check if reward amount is greater than the delegation rate denominator to avoid a
    // rounding towards zero when dividing by the delegation rate denominator
    if (addedRewardAmount != 0 && addedRewardAmount < s_vaultConfig.delegationRateDenominator) {
      revert InvalidRewardAmount();
    }
    // check if the aggregate reward rate is greater than zero
    // or if the aggregate reward rate is less than the delegation rate denominator to avoid a
    // rounding
    // towards zero when dividing by the delegation rate denominator
    if (totalEmissionRate == 0 || totalEmissionRate < s_vaultConfig.delegationRateDenominator) {
      revert InvalidEmissionRate();
    }
  }

  /// @notice Returns whether or not an address is currently an operator or
  /// is a removed operator, if the vault is closed.
  /// @return bool True if the vault is open and the staker is an operator; if the vault is closed,
  /// returns True if the staker is either an operator or a removed operator.
  function _isOperator(address staker) private view returns (bool) {
    bool isCurrentOperator = i_operatorStakingPool.isOperator(staker);
    return s_vaultConfig.isOpen
      ? isCurrentOperator
      : isCurrentOperator || i_operatorStakingPool.isRemoved(staker);
  }

  // =========
  // Modifiers
  // =========

  /// @dev Reverts if the msg.sender doesn't have the rewarder role.
  modifier onlyRewarder() {
    if (!hasRole(REWARDER_ROLE, msg.sender)) {
      revert AccessForbidden();
    }
    _;
  }

  /// @dev Reverts if the msg.sender is not a valid staking pool
  modifier onlyStakingPool() {
    if (
      msg.sender != address(i_operatorStakingPool) && msg.sender != address(i_communityStakingPool)
    ) {
      revert AccessForbidden();
    }
    _;
  }

  /// @dev Reverts if the reward vault has been closed
  modifier whenOpen() {
    if (!s_vaultConfig.isOpen) revert VaultAlreadyClosed();
    _;
  }

  // =======================
  // TypeAndVersionInterface
  // =======================

  /// @inheritdoc TypeAndVersionInterface
  function typeAndVersion() external pure virtual override returns (string memory) {
    return 'RewardVault 1.0.0';
  }
}
