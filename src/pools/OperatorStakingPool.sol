// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {TypeAndVersionInterface} from
  '@chainlink/contracts/src/v0.8/interfaces/TypeAndVersionInterface.sol';

import {AccessControlDefaultAdminRules} from
  '@openzeppelin/contracts/access/AccessControlDefaultAdminRules.sol';
import {Checkpoints} from '@openzeppelin/contracts/utils/Checkpoints.sol';
import {Math} from '@openzeppelin/contracts/utils/math/Math.sol';

import {ISlashable} from '../interfaces/ISlashable.sol';
import {IRewardVault} from '../interfaces/IRewardVault.sol';
import {RewardVault} from '../rewards/RewardVault.sol';
import {StakingPoolBase} from './StakingPoolBase.sol';

/// @notice This contract manages the staking of LINK tokens for the operator stakers.
/// @dev This contract inherits the StakingPoolBase contract and interacts with the MigrationProxy,
/// PriceFeedAlertsController, CommunityStakingPool, and RewardVault contracts.
/// @dev invariant Only addresses added as operators by the contract manager can stake in this pool.
/// @dev invariant contract's LINK token balance should be greater than or equal to the sum of
/// totalPrincipal and s_alerterRewardFunds.
contract OperatorStakingPool is ISlashable, StakingPoolBase, TypeAndVersionInterface {
  using Checkpoints for Checkpoints.Trace224;

  /// @notice Error code for when the operator list is invalid
  error InvalidOperatorList();
  /// @notice Error code for when the staker is not an operator
  error StakerNotOperator();
  /// @notice This error is raised when an address is duplicated in the supplied list of operators.
  /// This can happen in addOperators and setFeedOperators functions.
  /// @param operator address of the operator
  error OperatorAlreadyExists(address operator);
  /// @notice This error is raised when removing an operator that doesn't exist.
  /// @param operator Address of the operator
  error OperatorDoesNotExist(address operator);
  /// @notice This error is raised when an operator to add has been removed previously.
  /// @param operator Address of the operator
  error OperatorHasBeenRemoved(address operator);
  /// @notice This error is raised when an operator to add is already a community staker.
  error OperatorCannotBeCommunityStaker(address operator);
  /// @notice This error is thrown whenever the max pool size is less than the
  /// reserved space for operators
  /// @param maxPoolSize The maximum pool size of the operator staking pool
  /// @param maxPrincipalPerStaker The maximum amount a operator can stake in the
  /// pool
  /// @param numOperators The number of operators in the pool
  error InsufficientPoolSpace(
    uint256 maxPoolSize, uint256 maxPrincipalPerStaker, uint256 numOperators
  );
  /// @notice This error is raised when attempting to open the staking pool with less
  /// than the minimum required node operators
  /// @param numOperators The current number of operators in the staking pool
  /// @param minInitialOperatorCount The minimum required number of operators
  /// in the staking pool before it can be opened
  error InadequateInitialOperatorCount(uint256 numOperators, uint256 minInitialOperatorCount);
  /// @notice This error is thrown when the contract manager tries to add a zero amount
  /// to the alerter reward funds
  error InvalidAlerterRewardFundAmount();
  /// @notice This error is thrown whenever the contract manager tries to withdraw
  /// more than the remaining balance in the alerter reward funds
  /// @param amountToWithdraw The amount that the contract manager tried to withdraw
  /// @param remainingBalance The remaining balance of the alerter reward funds
  error InsufficientAlerterRewardFunds(uint256 amountToWithdraw, uint256 remainingBalance);

  /// @notice This event is emitted when an operator is removed
  /// @param operator Address of the operator
  /// @param principal Operator's staked LINK amount
  event OperatorRemoved(address indexed operator, uint256 principal);
  /// @notice This event is emitted when an operator is added
  /// @param operator Address of the operator
  event OperatorAdded(address indexed operator);
  /// @notice This event is emitted whenever the alerter reward funds is funded
  /// @param amountFunded The amount added to the alerter reward funds
  /// @param totalBalance  The current balance of the alerter reward funds
  event AlerterRewardDeposited(uint256 amountFunded, uint256 totalBalance);
  /// @notice This event is emitted whenever the contract manager withdraws from the
  /// alerter reward funds
  /// @param amountWithdrawn The amount withdrawn from the alerter reward funds
  /// @param remainingBalance The remaining balance of the alerter reward funds
  event AlerterRewardWithdrawn(uint256 amountWithdrawn, uint256 remainingBalance);
  /// @notice This event is emitted whenever the alerter is paid the full
  /// alerter reward amount
  /// @param alerter The address of the alerter
  /// @param alerterRewardActual The amount of rewards sent to the alerter in juels.
  /// This can be lower than the expected value, if the reward fund is low or we aren't able to
  /// slash enough.
  /// @param alerterRewardExpected The amount of expected rewards for the alerter
  /// in juels
  event AlertingRewardPaid(
    address indexed alerter, uint256 alerterRewardActual, uint256 alerterRewardExpected
  );
  /// @notice This event is emitted when the slasher config is set
  /// @param slasher The address of the slasher
  /// @param refillRate The refill rate of the slasher
  /// @param slashCapacity The slash capacity of the slasher
  event SlasherConfigSet(address indexed slasher, uint256 refillRate, uint256 slashCapacity);
  /// @notice This event is emitted when an operator is slashed
  /// @param operator The address of the operator
  /// @param slashedAmount The amount slashed from the operator's staked LINK
  /// amount
  /// @param updatedStakerPrincipal The operator's updated staked LINK amount
  event Slashed(address indexed operator, uint256 slashedAmount, uint256 updatedStakerPrincipal);

  /// @notice This struct defines the params required by the Staking contract's
  /// constructor.
  struct ConstructorParams {
    /// @notice The base staking pool constructor parameters
    ConstructorParamsBase baseParams;
    /// @notice The minimum number of node operators required to open the
    /// staking pool.
    uint256 minInitialOperatorCount;
  }

  /// @notice This struct defines the operator-specific states.
  struct Operator {
    /// @notice The operator's staked LINK amount when they get removed.
    uint256 removedPrincipal;
    /// @notice Flag that signals whether the operator is an operator.
    bool isOperator;
    /// @notice Flag that signals whether the operator has been removed.
    bool isRemoved;
  }

  /// @notice Mapping of addresses to the Operator struct.
  mapping(address => Operator) private s_operators;
  /// @notice Mapping of the slashers to slasher config struct.
  mapping(address => ISlashable.SlasherConfig) private s_slasherConfigs;
  /// @notice Mapping of slashers to slasher state struct.
  mapping(address => ISlashable.SlasherState) private s_slasherState;
  /// @notice The number of node operators that have been set in the pool
  uint256 private s_numOperators;
  /// @notice Tracks the balance of the alerter reward funds.  This bucket holds all
  /// slashed funds and also funds alerter rewards.
  uint256 private s_alerterRewardFunds;
  /// @notice The minimum number of node operators required to open the
  /// staking pool.
  uint256 private immutable i_minInitialOperatorCount;
  /// @notice This is the ID for the slasher role, which will be given to the
  /// AlertsController contract.
  /// @dev Hash: 12b42e8a160f6064dc959c6f251e3af0750ad213dbecf573b4710d67d6c28e39
  bytes32 public constant SLASHER_ROLE = keccak256('SLASHER_ROLE');

  constructor(ConstructorParams memory params) StakingPoolBase(params.baseParams) {
    i_minInitialOperatorCount = params.minInitialOperatorCount;
  }

  /// @notice Adds LINK to the alerter reward funds
  /// @param amount The amount of LINK to add to the alerter reward funds
  /// @dev precondition The caller must have the default admin role.
  /// @dev precondition The caller must have at least `amount` LINK tokens.
  /// @dev precondition The caller must have approved this contract for the transfer of at least
  /// `amount` LINK tokens.
  function depositAlerterReward(uint256 amount)
    external
    onlyRole(DEFAULT_ADMIN_ROLE)
    whenBeforeClosing
  {
    if (amount == 0) revert InvalidAlerterRewardFundAmount();
    s_alerterRewardFunds += amount;
    // The return value is not checked since the call will revert if any balance, allowance or
    // receiver conditions fail.
    i_LINK.transferFrom({from: msg.sender, to: address(this), value: amount});
    emit AlerterRewardDeposited(amount, s_alerterRewardFunds);
  }

  /// @notice Withdraws LINK from the alerter reward funds
  /// @param amount The amount of LINK withdrawn from the alerter reward funds
  /// @dev precondition The caller must have the default admin role.
  /// @dev precondition This contract must have at least `amount` LINK tokens as the alerter reward
  /// funds.
  /// @dev precondition This contract must be closed (before opening or after closing).
  function withdrawAlerterReward(uint256 amount) external onlyRole(DEFAULT_ADMIN_ROLE) {
    if (s_isOpen) revert PoolNotClosed();
    if (amount > s_alerterRewardFunds) {
      revert InsufficientAlerterRewardFunds(amount, s_alerterRewardFunds);
    }
    s_alerterRewardFunds -= amount;
    // The return value is not checked since the call will revert if any balance, allowance or
    // receiver conditions fail.
    i_LINK.transfer(msg.sender, amount);
    emit AlerterRewardWithdrawn(amount, s_alerterRewardFunds);
  }

  /// @notice Returns the balance of the pool's alerter reward funds
  /// @return uint256 The balance of the pool's alerter reward funds
  function getAlerterRewardFunds() external view returns (uint256) {
    return s_alerterRewardFunds;
  }

  // ==============================
  // AccessControlDefaultAdminRules
  // ==============================

  /// @inheritdoc AccessControlDefaultAdminRules
  /// @notice Grants `role` to `account`. Reverts if the contract manager tries to grant the default
  /// admin or
  /// slasher role.
  /// @dev The default admin role must be granted through `beginDefaultAdminTransfer` and
  /// `acceptDefaultAdminTransfer`.
  /// @dev The slasher role must be granted through `addSlasher`.
  /// @param role The role to grant
  /// @param account The address to grant the role to
  function grantRole(
    bytes32 role,
    address account
  ) public virtual override(AccessControlDefaultAdminRules) {
    if (role == SLASHER_ROLE) revert InvalidRole();
    super.grantRole(role, account);
  }

  // =======================
  // ISlashable
  // =======================

  /// @inheritdoc ISlashable
  /// @dev precondition The caller must have the default admin role.
  function addSlasher(
    address slasher,
    SlasherConfig calldata config
  ) external override onlyRole(DEFAULT_ADMIN_ROLE) {
    _grantRole(SLASHER_ROLE, slasher);
    _setSlasherConfig(slasher, config);
  }

  /// @inheritdoc ISlashable
  /// @dev precondition The caller must have the default admin role.
  function setSlasherConfig(
    address slasher,
    SlasherConfig calldata config
  ) external override onlyRole(DEFAULT_ADMIN_ROLE) {
    if (!hasRole(SLASHER_ROLE, slasher)) {
      revert InvalidSlasher();
    }
    _setSlasherConfig(slasher, config);
  }

  /// @notice Helper function to set the slasher config
  /// @param slasher The slasher
  /// @param config The slasher config
  function _setSlasherConfig(address slasher, SlasherConfig calldata config) private {
    if (config.slashCapacity == 0 || config.refillRate == 0) {
      revert ISlashable.InvalidSlasherConfig();
    }

    s_slasherConfigs[slasher] = config;

    // refill capacity
    SlasherState storage state = s_slasherState[slasher];
    state.remainingSlashCapacityAmount = config.slashCapacity;
    state.lastSlashTimestamp = block.timestamp;

    emit SlasherConfigSet(slasher, config.refillRate, config.slashCapacity);
  }

  /// @inheritdoc ISlashable
  function getSlasherConfig(address slasher) external view override returns (SlasherConfig memory) {
    return s_slasherConfigs[slasher];
  }

  /// @inheritdoc ISlashable
  function getSlashCapacity(address slasher) external view override returns (uint256) {
    SlasherConfig memory slasherConfig = s_slasherConfigs[slasher];
    return _getRemainingSlashCapacity(slasherConfig, slasher);
  }

  /// @inheritdoc ISlashable
  /// @dev In the current implementation, on-feed operators can raise alerts to rescue a portion of
  /// their slashed staked LINK amount. All operators can raise alerts in the priority period. Note
  /// that this may change in the future as we add alerting for additional services.
  /// @dev We will operationally make sure to remove an operator from the slashable (on-feed)
  /// operators list in alerts controllers if they are removed from the operators list in this
  /// contract, so there won't be a case where we slash a removed operator.
  /// @dev precondition The caller must have the slasher role.
  /// @dev precondition This contract must be active (open and stakers are earning rewards).
  /// @dev precondition The slasher must have enough capacity to slash.
  function slashAndReward(
    address[] calldata stakers,
    address alerter,
    uint256 principalAmount,
    uint256 alerterRewardAmount
  ) external override onlySlasher whenActive {
    SlasherConfig storage slasherConfig = s_slasherConfigs[msg.sender];
    uint256 combinedSlashAmount = stakers.length * principalAmount;

    uint256 remainingSlashCapacity = _getRemainingSlashCapacity(slasherConfig, msg.sender);
    // check if the total slashed amount exceeds the slasher's capacity
    if (combinedSlashAmount > remainingSlashCapacity) {
      /// @dev If a slashing occurs with an amount to be slashed that is higher than the remaining
      /// slashing capacity, only an amount equal to the remaining capacity is slashed.
      principalAmount = remainingSlashCapacity / stakers.length;
    }

    uint256 totalSlashedAmount = _slashOperators(stakers, principalAmount);

    s_slasherState[msg.sender].remainingSlashCapacityAmount =
      remainingSlashCapacity - totalSlashedAmount;
    s_slasherState[msg.sender].lastSlashTimestamp = block.timestamp;

    _payAlerter({
      alerter: alerter,
      totalSlashedAmount: totalSlashedAmount,
      alerterRewardAmount: alerterRewardAmount
    });
  }

  /// @notice Helper function to slash operators
  /// @param operators The list of operators to slash
  /// @param principalAmount The amount to slash from each operator's staked
  /// LINK amount
  /// @return The total amount slashed from all operators
  function _slashOperators(
    address[] calldata operators,
    uint256 principalAmount
  ) private returns (uint256) {
    // perform the slash on all operators and add up the total slashed amount
    uint256 totalSlashedAmount;
    Staker storage staker;
    for (uint256 i; i < operators.length; ++i) {
      staker = s_stakers[operators[i]];
      uint224 history = staker.history.latest();
      uint256 operatorPrincipal = uint112(history >> 112);
      uint256 stakerStakedAtTime = uint112(history);
      uint256 slashedAmount =
        principalAmount > operatorPrincipal ? operatorPrincipal : principalAmount;
      uint256 updatedPrincipal = operatorPrincipal - slashedAmount;

      // update the staker's rewards
      s_rewardVault.updateReward(operators[i], operatorPrincipal);
      _updateStakerHistory({
        staker: staker,
        latestPrincipal: updatedPrincipal,
        latestStakedAtTime: stakerStakedAtTime
      });

      totalSlashedAmount += slashedAmount;

      emit Slashed(operators[i], slashedAmount, updatedPrincipal);
    }
    // update the pool state
    s_pool.state.totalPrincipal -= totalSlashedAmount;

    return totalSlashedAmount;
  }

  /// @notice Helper function to reward the alerter
  /// @param alerter The alerter
  /// @param totalSlashedAmount The total amount slashed from all the operators
  /// @param alerterRewardAmount The amount to reward the alerter
  function _payAlerter(
    address alerter,
    uint256 totalSlashedAmount,
    uint256 alerterRewardAmount
  ) private {
    uint256 newAlerterRewardFunds = s_alerterRewardFunds + totalSlashedAmount;
    uint256 alerterRewardActual =
      newAlerterRewardFunds < alerterRewardAmount ? newAlerterRewardFunds : alerterRewardAmount;
    s_alerterRewardFunds = newAlerterRewardFunds - alerterRewardActual;

    // We emit an event here instead of reverting so that the alerter can
    // immediately receive a portion of their rewards.  This event
    // will allow the contract manager to reimburse any remaining rewards to the
    // alerter.
    emit AlertingRewardPaid(alerter, alerterRewardActual, alerterRewardAmount);

    // The return value is not checked since the call will revert if any balance, allowance or
    // receiver conditions fail.
    i_LINK.transfer(alerter, alerterRewardActual);
  }

  /// @notice Helper function to return the current remaining slash capacity for a slasher
  /// @param slasherConfig The slasher's config
  /// @param slasher The slasher
  /// @return The remaining slashing capacity
  function _getRemainingSlashCapacity(
    SlasherConfig memory slasherConfig,
    address slasher
  ) private view returns (uint256) {
    SlasherState memory slasherState = s_slasherState[slasher];
    uint256 refilledAmount =
      (block.timestamp - slasherState.lastSlashTimestamp) * slasherConfig.refillRate;

    return Math.min(
      slasherConfig.slashCapacity, slasherState.remainingSlashCapacityAmount + refilledAmount
    );
  }

  // ===============
  // StakingPoolBase
  // ===============

  /// @inheritdoc StakingPoolBase
  function _validateOnTokenTransfer(address, address staker, bytes calldata) internal view override {
    // check if staker is an operator
    if (!s_operators[staker].isOperator) revert StakerNotOperator();
  }

  /// @inheritdoc StakingPoolBase
  /// @dev The access control is done in StakingPoolBase.
  function setPoolConfig(
    uint256 maxPoolSize,
    uint256 maxPrincipalPerStaker
  )
    external
    override
    validatePoolSpace(maxPoolSize, maxPrincipalPerStaker, s_numOperators)
    whenOpen
    onlyRole(DEFAULT_ADMIN_ROLE)
  {
    _setPoolConfig(maxPoolSize, maxPrincipalPerStaker);
  }

  /// @inheritdoc StakingPoolBase
  function _handleOpen() internal view override(StakingPoolBase) {
    if (s_numOperators < i_minInitialOperatorCount) {
      revert InadequateInitialOperatorCount(s_numOperators, i_minInitialOperatorCount);
    }
  }

  /// @notice Registers operators from a list of unique, sorted addresses
  /// Addresses must be provided in sorted order so that
  /// address(0xNext) > address(0xPrev)
  /// @dev Previously removed operators cannot be readded to the pool.
  /// @dev precondition The caller must have the default admin role.
  /// @param operators The sorted list of operator addresses
  function addOperators(address[] calldata operators)
    external
    validateRewardVaultSet
    validatePoolSpace(
      s_pool.configs.maxPoolSize,
      s_pool.configs.maxPrincipalPerStaker,
      s_numOperators + operators.length
    )
    onlyRole(DEFAULT_ADMIN_ROLE)
  {
    for (uint256 i; i < operators.length; ++i) {
      address operatorAddress = operators[i];
      IRewardVault.StakerReward memory stakerReward = s_rewardVault.getStoredReward(operatorAddress);
      if (stakerReward.stakerType == IRewardVault.StakerType.COMMUNITY) {
        revert OperatorCannotBeCommunityStaker(operatorAddress);
      }
      // verify input list is sorted and addresses are unique
      if (i < operators.length - 1 && operatorAddress >= operators[i + 1]) {
        revert InvalidOperatorList();
      }
      Operator storage operator = s_operators[operatorAddress];
      if (operator.isOperator) {
        revert OperatorAlreadyExists(operatorAddress);
      }
      if (operator.isRemoved) {
        revert OperatorHasBeenRemoved(operatorAddress);
      }
      operator.isOperator = true;
      emit OperatorAdded(operatorAddress);
    }

    s_numOperators += operators.length;
  }

  /// @notice Removes one or more operators from a list of operators.
  /// @dev Should only be callable by the owner when the pool is open.
  /// When an operator is removed, we store their staked LINK amount in a separate mapping to
  /// stop it from accruing reward.
  /// Removed operators are still slashable until they withdraw their removedPrincipal
  /// and exit the system. When they withdraw their removedPrincipal, they must
  /// go through the unbonding period.
  /// Note that the function doesn't check if the operators are still on-feed (slashable).
  /// This is so that we can slash the removed operators if an alert is raised against them.
  /// @param operators A list of operator addresses to remove
  /// @dev precondition The caller must have the default admin role.
  /// @dev precondition The pool must be open.
  /// @dev precondition The operators must be currently added operators.
  function removeOperators(address[] calldata operators)
    external
    onlyRole(DEFAULT_ADMIN_ROLE)
    whenOpen
  {
    Operator storage operator;
    Staker storage staker;
    for (uint256 i; i < operators.length; ++i) {
      address operatorAddress = operators[i];
      operator = s_operators[operatorAddress];
      if (!operator.isOperator) {
        revert OperatorDoesNotExist(operatorAddress);
      }

      staker = s_stakers[operatorAddress];
      uint224 history = staker.history.latest();
      uint256 principal = uint256(history >> 112);
      uint256 stakedAtTime = uint112(history);
      s_rewardVault.finalizeReward({
        staker: operatorAddress,
        oldPrincipal: principal,
        unstakedAmount: principal,
        shouldClaim: false,
        stakedAt: stakedAtTime
      });

      s_pool.state.totalPrincipal -= principal;
      operator.isOperator = false;
      operator.isRemoved = true;
      // Reset the staker's stakedAtTime to 0 so their multiplier resets to 0.
      _updateStakerHistory({staker: staker, latestPrincipal: 0, latestStakedAtTime: 0});
      // move the operator's staked LINK amount to removedPrincipal that stops earning rewards
      operator.removedPrincipal = principal;

      emit OperatorRemoved(operatorAddress, principal);
    }

    s_numOperators -= operators.length;
  }

  /// @notice Getter function to check if an address is registered as an operator
  /// @param staker The address of the staker
  /// @return bool True if the staker is an operator
  function isOperator(address staker) external view returns (bool) {
    return s_operators[staker].isOperator;
  }

  /// @notice Getter function to check if an address is a removed operator
  /// @param staker The address of the staker
  /// @return bool True if the operator has been removed
  function isRemoved(address staker) external view returns (bool) {
    return s_operators[staker].isRemoved;
  }

  /// @notice Getter function for a removed operator's total staked LINK amount
  /// @param staker The address of the staker
  /// @return uint256 The removed operator's staked LINK amount that hasn't been withdrawn
  function getRemovedPrincipal(address staker) external view returns (uint256) {
    return s_operators[staker].removedPrincipal;
  }

  /// @notice Called by removed operators to withdraw their removed stake
  /// @dev precondition The caller must be in the claim period or the pool must be closed or paused.
  /// @dev precondition The caller must be a removed operator with some removed
  /// staked LINK amount.
  function unstakeRemovedPrincipal() external {
    if (!_canUnstake(s_stakers[msg.sender])) {
      revert StakerNotInClaimPeriod(msg.sender);
    }

    uint256 withdrawableAmount = s_operators[msg.sender].removedPrincipal;
    if (withdrawableAmount == 0) {
      revert UnstakeExceedsPrincipal();
    }
    s_operators[msg.sender].removedPrincipal = 0;

    // The return value is not checked since the call will revert if any balance, allowance or
    // receiver conditions fail.
    i_LINK.transfer(msg.sender, withdrawableAmount);
    emit Unstaked(msg.sender, withdrawableAmount, 0);
  }

  /// @notice Returns the number of operators configured in the pool.
  /// @return uint256 The number of operators configured in the pool
  function getNumOperators() external view returns (uint256) {
    return s_numOperators;
  }

  /// @notice This function allows the calling contract to
  /// check if the contract deployed at this address is a valid
  /// LINKTokenReceiver.  A contract is a valid LINKTokenReceiver
  /// if it implements the onTokenTransfer function.
  /// @param interfaceID The ID of the interface to check against
  /// @return bool True if the contract is a valid LINKTokenReceiver.
  function supportsInterface(bytes4 interfaceID) public view override returns (bool) {
    return interfaceID == this.onTokenTransfer.selector || super.supportsInterface(interfaceID);
  }

  /// @dev Reverts if not sent by an address that has the SLASHER role
  modifier onlySlasher() {
    if (!hasRole(SLASHER_ROLE, msg.sender)) {
      revert AccessForbidden();
    }
    _;
  }

  /// @notice Checks that the maximum pool size is greater than or equal to
  /// the reserved space for operators.
  /// @param maxPoolSize The maximum pool size of the operator staking pool
  /// @param maxPrincipalPerStaker The maximum amount a operator can stake in the
  /// @param numOperators The number of operators in the pool
  /// @dev The reserved space is calculated by multiplying the number of
  /// operators and the maximum staked LINK amount per operator
  modifier validatePoolSpace(
    uint256 maxPoolSize,
    uint256 maxPrincipalPerStaker,
    uint256 numOperators
  ) {
    if (maxPoolSize < maxPrincipalPerStaker * numOperators) {
      revert InsufficientPoolSpace(maxPoolSize, maxPrincipalPerStaker, numOperators);
    }
    _;
  }

  // =======================
  // TypeAndVersionInterface
  // =======================

  /// @inheritdoc TypeAndVersionInterface
  function typeAndVersion() external pure virtual override returns (string memory) {
    return 'OperatorStakingPool 1.0.0';
  }
}
