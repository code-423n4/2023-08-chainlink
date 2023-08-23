// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {AggregatorV3Interface} from
  '@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol';
import {LinkTokenInterface} from '@chainlink/contracts/src/v0.8/interfaces/LinkTokenInterface.sol';
import {Math} from '@openzeppelin/contracts/utils/math/Math.sol';
import {FixedPointMathLib} from '@solmate/utils/FixedPointMathLib.sol';
import {Strings} from '@openzeppelin/contracts/utils/Strings.sol';
import {Test} from 'forge-std/Test.sol';
import {CommunityStakingPool} from '../src/pools/CommunityStakingPool.sol';
import {Constants} from './Constants.t.sol';
import {MigrationProxy} from '../src/MigrationProxy.sol';
import {OperatorStakingPool} from '../src/pools/OperatorStakingPool.sol';
import {RewardVault} from '../src/rewards/RewardVault.sol';
import {StakingPoolBase} from '../src/pools/StakingPoolBase.sol';

contract BaseTest is Constants, Test {
  struct StakePeriod {
    uint256 time;
    uint256 stakerPrincipal;
    uint256 totalPrincipalInPool;
    uint256 rewardEmissionRate;
    uint256 rewardVestingTime;
  }

  OperatorStakingPool internal s_operatorStakingPool;
  CommunityStakingPool internal s_communityStakingPool;
  LinkTokenInterface internal s_LINK;
  MigrationProxy internal s_migrationProxy;
  RewardVault internal s_rewardVault;

  bytes32[] internal s_communityStakerOneProof;
  bytes32[] internal s_communityStakerTwoProof;
  uint256 s_stakedAtTime;

  struct ForfeitedRewardDistribution {
    uint256 vestedReward;
    uint256 vestedRewardPerToken;
    uint256 reclaimableReward;
  }

  function setUp() public virtual {
    // Start at T = 0
    vm.warp(TEST_START_TIME);
    vm.startPrank(OWNER);

    // Setup LINK token
    s_LINK = LinkTokenInterface(deployCode('LinkToken.sol'));
    s_LINK.transfer(COMMUNITY_STAKER_ONE, 2 * COMMUNITY_MAX_PRINCIPAL);
    s_LINK.transfer(COMMUNITY_STAKER_TWO, 2 * COMMUNITY_MAX_PRINCIPAL);
    s_LINK.transfer(PUBLIC_COMMUNITY_STAKER, 2 * COMMUNITY_MAX_PRINCIPAL);
    s_LINK.transfer(OPERATOR_STAKER_ONE, 2 * OPERATOR_MAX_PRINCIPAL);
    s_LINK.transfer(OPERATOR_STAKER_TWO, 2 * OPERATOR_MAX_PRINCIPAL);
    s_LINK.transfer(OPERATOR_STAKER_THREE, 2 * OPERATOR_MAX_PRINCIPAL);
    s_LINK.transfer(REWARDER, 10 * REWARD_AMOUNT);

    s_operatorStakingPool = new OperatorStakingPool(
      OperatorStakingPool.ConstructorParams({
        minInitialOperatorCount: MIN_INITIAL_OPERATOR_COUNT,
        baseParams: StakingPoolBase.ConstructorParamsBase({
          LINKAddress: s_LINK,
          initialMaxPoolSize: OPERATOR_MAX_POOL_SIZE,
          initialMaxPrincipalPerStaker: OPERATOR_MAX_PRINCIPAL,
          minPrincipalPerStaker: OPERATOR_MIN_PRINCIPAL,
          initialUnbondingPeriod: INITIAL_UNBONDING_PERIOD,
          maxUnbondingPeriod: MAX_UNBONDING_PERIOD,
          initialClaimPeriod: INITIAL_CLAIM_PERIOD,
          minClaimPeriod: MIN_CLAIM_PERIOD,
          maxClaimPeriod: MAX_CLAIM_PERIOD,
          adminRoleTransferDelay: ADMIN_ROLE_TRANSFER_DELAY
        })
      })
    );
    s_communityStakingPool = new CommunityStakingPool(
      CommunityStakingPool.ConstructorParams({
        operatorStakingPool: s_operatorStakingPool,
        baseParams: StakingPoolBase.ConstructorParamsBase({
          LINKAddress: s_LINK,
          initialMaxPoolSize: COMMUNITY_MAX_POOL_SIZE,
          initialMaxPrincipalPerStaker: COMMUNITY_MAX_PRINCIPAL,
          minPrincipalPerStaker: COMMUNITY_MIN_PRINCIPAL,
          initialUnbondingPeriod: INITIAL_UNBONDING_PERIOD,
          maxUnbondingPeriod: MAX_UNBONDING_PERIOD,
          initialClaimPeriod: INITIAL_CLAIM_PERIOD,
          minClaimPeriod: MIN_CLAIM_PERIOD,
          maxClaimPeriod: MAX_CLAIM_PERIOD,
          adminRoleTransferDelay: ADMIN_ROLE_TRANSFER_DELAY
        })
      })
    );
    s_communityStakingPool.setMerkleRoot(MERKLE_ROOT);

    // Proof generated off chain for address(1) of chain of address(1) and address(2)
    s_communityStakerOneProof.push(
      0x1ab0c6948a275349ae45a06aad66a8bd65ac18074615d53676c09b67809099e0
    );
    // Proof generated off chain for address(2) of chain of address(1) and address(2)
    s_communityStakerTwoProof.push(
      0xb5d9d894133a730aa651ef62d26b0ffa846233c74177a591a4a896adfda97d22
    );

    // deploy migration proxy
    s_migrationProxy = new MigrationProxy(
      MigrationProxy.ConstructorParams({
        LINKAddress: s_LINK,
        v01StakingAddress: MOCK_STAKING_V01,
        operatorStakingPool: s_operatorStakingPool,
        communityStakingPool: s_communityStakingPool,
        adminRoleTransferDelay: ADMIN_ROLE_TRANSFER_DELAY
      })
    );
    s_LINK.transfer(MOCK_STAKING_V01, 1_000_000 ether);

    // set migration proxy on both staking pools
    s_operatorStakingPool.setMigrationProxy(address(s_migrationProxy));
    s_communityStakingPool.setMigrationProxy(address(s_migrationProxy));

    s_rewardVault = new RewardVault(
      RewardVault.ConstructorParams({
        linkToken: s_LINK,
        communityStakingPool: s_communityStakingPool,
        operatorStakingPool: s_operatorStakingPool,
        delegationRateDenominator: DELEGATION_RATE_DENOMINATOR,
        initialMultiplierDuration: INITIAL_MULTIPLIER_DURATION,
        adminRoleTransferDelay: ADMIN_ROLE_TRANSFER_DELAY
      })
    );
    changePrank(REWARDER);
    s_LINK.approve(address(s_rewardVault), type(uint256).max);

    changePrank(OWNER);
    s_rewardVault.grantRole(s_rewardVault.REWARDER_ROLE(), REWARDER);
    s_rewardVault.grantRole(s_rewardVault.PAUSER_ROLE(), PAUSER);
    s_operatorStakingPool.grantRole(s_operatorStakingPool.PAUSER_ROLE(), PAUSER);
    s_communityStakingPool.grantRole(s_communityStakingPool.PAUSER_ROLE(), PAUSER);
    s_migrationProxy.grantRole(s_migrationProxy.PAUSER_ROLE(), PAUSER);

    changePrank(OWNER);
    s_LINK.approve(address(s_operatorStakingPool), INITIAL_ALERTING_BUCKET_BALANCE);
    s_operatorStakingPool.depositAlerterReward(INITIAL_ALERTING_BUCKET_BALANCE);
    s_communityStakingPool.setRewardVault(s_rewardVault);
    s_operatorStakingPool.setRewardVault(s_rewardVault);
  }

  function _calculateStakerExpectedReward(
    uint256 stakerPrincipal,
    uint256 totalPoolPrincipal,
    uint256 vestedBucketRewards
  ) internal pure returns (uint256) {
    return stakerPrincipal * vestedBucketRewards / totalPoolPrincipal;
  }

  function _calculateStakerMultiplier(
    uint256 startTime,
    uint256 endTime,
    uint256 multiplierDuration
  ) internal pure returns (uint256) {
    return
      Math.min((endTime - startTime) * FixedPointMathLib.WAD / multiplierDuration, MAX_MULTIPLIER);
  }

  function _calculateBucketVestedRewards(
    RewardVault.RewardBucket memory bucket,
    uint256 startTime,
    uint256 endTime
  ) internal pure returns (uint256) {
    uint256 elapsedTime = endTime - startTime;
    uint256 emissionRate = bucket.emissionRate;
    return emissionRate * elapsedTime;
  }

  function _getTotalUnvestedRewards(RewardVault rewardVault)
    internal
    view
    returns (uint256, uint256, uint256, uint256)
  {
    RewardVault.RewardBuckets memory buckets = rewardVault.getRewardBuckets();
    uint256 unvestedOperatorBaseRewards = _calculateUnvestedRewardsInBucket(buckets.operatorBase);
    uint256 unvestedCommunityBaseRewards = _calculateUnvestedRewardsInBucket(buckets.communityBase);
    uint256 unvestedOperatorDelegatedRewards =
      _calculateUnvestedRewardsInBucket(buckets.operatorDelegated);
    uint256 totalUnvestedRewards =
      unvestedOperatorBaseRewards + unvestedCommunityBaseRewards + unvestedOperatorDelegatedRewards;
    return (
      totalUnvestedRewards,
      unvestedOperatorBaseRewards,
      unvestedCommunityBaseRewards,
      unvestedOperatorDelegatedRewards
    );
  }

  function _calculateUnvestedRewardsInBucket(RewardVault.RewardBucket memory bucket)
    internal
    view
    returns (uint256)
  {
    return bucket.rewardDurationEndsAt <= block.timestamp
      ? 0
      : bucket.emissionRate * (bucket.rewardDurationEndsAt - block.timestamp);
  }

  function _calculateExpectedRewardOverMultiplePeriods(
    StakePeriod[] memory stakePeriods,
    uint256 multiplierRampUp,
    uint256 initialAverageStakedAtTime,
    uint256 startTime
  ) internal pure returns (uint256) {
    uint256 stakerAverageDepositTime = initialAverageStakedAtTime;
    uint256 currentTime = startTime;

    uint256 cummulativeClaimableRewards;
    uint256 currentStakerPrincipal;

    uint256 unclaimableRewards;

    for (uint256 i; i < stakePeriods.length; ++i) {
      // Calculate what the expected reward earned at the END of the stake period.
      StakePeriod memory stakePeriod = stakePeriods[i];
      // Update current time to the end of the stake period
      currentTime += stakePeriod.time;

      uint256 multiplier = Math.min(
        (currentTime - stakerAverageDepositTime) * FixedPointMathLib.WAD / multiplierRampUp,
        FixedPointMathLib.WAD
      );

      // stakerPrincipal * vestedRewards / totalPoolPrincipal
      uint256 fullRewards = stakePeriod.stakerPrincipal * stakePeriod.rewardEmissionRate
        * stakePeriod.rewardVestingTime / stakePeriod.totalPrincipalInPool;

      fullRewards += unclaimableRewards;

      // stakerPrincipal * vestedRewards * multiplier / totalPoolPrincipal
      uint256 claimableRewards = fullRewards * multiplier / FixedPointMathLib.WAD;

      unclaimableRewards = fullRewards - claimableRewards;

      // Claimable rewards from this period + multiplier * total unclaimable rewards from previous
      // rounds
      cummulativeClaimableRewards += claimableRewards;

      stakerAverageDepositTime = currentTime;
      currentStakerPrincipal = stakePeriod.stakerPrincipal;
    }
    return cummulativeClaimableRewards;
  }

  // This is needed so that "forge coverage" will ignore this contract
  function test() public virtual {}

  // =======
  // HELPERS
  // =======

  /// @notice 31 unique Operators
  /// @dev We use this instead of storage because high storage
  /// costs interfere with gas measurements of the tests
  function _getDefaultOperators() internal pure returns (address[] memory) {
    address[] memory operators = new address[](MIN_INITIAL_OPERATOR_COUNT);
    operators[0] = OPERATOR_STAKER_ONE;
    operators[1] = OPERATOR_STAKER_TWO;
    operators[2] = OPERATOR_STAKER_THREE;
    operators[3] = address(103);
    operators[4] = address(104);
    operators[5] = address(105);
    operators[6] = address(106);
    operators[7] = address(107);
    operators[8] = address(108);
    operators[9] = address(109);
    operators[10] = address(110);
    operators[11] = address(111);
    operators[12] = address(112);
    operators[13] = address(113);
    operators[14] = address(114);
    operators[15] = address(115);
    operators[16] = address(116);
    operators[17] = address(117);
    operators[18] = address(118);
    operators[19] = address(119);
    operators[20] = address(120);
    operators[21] = address(121);
    operators[22] = address(122);
    operators[23] = address(123);
    operators[24] = address(124);
    operators[25] = address(125);
    operators[26] = address(126);
    operators[27] = address(127);
    operators[28] = address(128);
    operators[29] = address(129);
    operators[30] = address(130);
    return operators;
  }

  /// @notice Calculate new available rewards earned per token
  /// @param vestedRewardPerToken The last calculated available reward per token
  /// @param rewardDurationEndsAt The timestamp when the reward duration ends
  /// @param rewardPerTokenUpdatedAt The time the reward per token was last updated
  /// @param emissionRate The aggregate reward rate of the reward bucket
  /// @param totalPrincipal The total staked LINK amount staked in a pool associated with the reward
  /// bucket
  /// @param timestamp The timestamp for which we calculate the available reward per token
  /// @return The available rewards earned per token
  function _calculateVestedRewardPerToken(
    uint256 vestedRewardPerToken,
    uint256 rewardDurationEndsAt,
    uint256 rewardPerTokenUpdatedAt,
    uint256 emissionRate,
    uint256 totalPrincipal,
    uint256 timestamp
  ) internal pure returns (uint256) {
    uint256 rewardEmittedUntil = Math.min(timestamp, rewardDurationEndsAt);
    if (rewardEmittedUntil <= rewardPerTokenUpdatedAt) return vestedRewardPerToken;
    uint256 timePassed = rewardEmittedUntil - rewardPerTokenUpdatedAt;
    return
      vestedRewardPerToken + FixedPointMathLib.divWadDown(timePassed * emissionRate, totalPrincipal);
  }

  /// @notice Calculates the newly accrued reward of a staker since the last time the staker's
  /// reward was updated
  /// @param principal The staker's staked LINK amount
  /// @param rewardPerToken The base or delegated reward per token of the staker
  /// @param vestedRewardPerToken The available reward per token of the staking pool
  /// @return The accrued reward amount
  function _calculateAccruedReward(
    uint256 principal,
    uint256 rewardPerToken,
    uint256 vestedRewardPerToken
  ) internal pure returns (uint256) {
    return principal * (vestedRewardPerToken - rewardPerToken) / DECIMALS;
  }

  /// @notice Calculates the available reward per token and the reclaimable reward
  /// @param staker The staker whose forfeited reward is being shared
  /// @param isOperator Whether the staker is an operator or community staker
  /// @param isPrincipalDecreased Whether the staker's staked LINK amount is being decreased. This
  /// is set to
  /// `true` when we calculate the expected distribution before unstaking or removing operators.
  function _calculateForfeitedRewardDistribution(
    address staker,
    bool isOperator,
    bool isPrincipalDecreased
  ) internal view returns (ForfeitedRewardDistribution memory) {
    ForfeitedRewardDistribution memory distribution;
    uint256 principal;
    uint256 maxReward;
    uint256 operatorTotalPrincipal = s_operatorStakingPool.getTotalPrincipal();
    uint256 communityTotalPrincipal = s_communityStakingPool.getTotalPrincipal();
    RewardVault.RewardBuckets memory buckets = s_rewardVault.getRewardBuckets();
    buckets.communityBase.vestedRewardPerToken = uint80(
      _calculateVestedRewardPerToken(
        buckets.communityBase.vestedRewardPerToken,
        buckets.communityBase.rewardDurationEndsAt,
        s_rewardVault.getRewardPerTokenUpdatedAt(),
        buckets.communityBase.emissionRate,
        communityTotalPrincipal,
        block.timestamp
      )
    );
    buckets.operatorBase.vestedRewardPerToken = uint80(
      _calculateVestedRewardPerToken(
        buckets.operatorBase.vestedRewardPerToken,
        buckets.operatorBase.rewardDurationEndsAt,
        s_rewardVault.getRewardPerTokenUpdatedAt(),
        buckets.operatorBase.emissionRate,
        operatorTotalPrincipal,
        block.timestamp
      )
    );
    buckets.operatorDelegated.vestedRewardPerToken = uint80(
      _calculateVestedRewardPerToken(
        buckets.operatorDelegated.vestedRewardPerToken,
        buckets.operatorDelegated.rewardDurationEndsAt,
        s_rewardVault.getRewardPerTokenUpdatedAt(),
        buckets.operatorDelegated.emissionRate,
        operatorTotalPrincipal,
        block.timestamp
      )
    );
    RewardVault.StakerReward memory stakerReward = s_rewardVault.getStoredReward(staker);
    if (isOperator) {
      principal = s_operatorStakingPool.getStakerPrincipal(staker);
      maxReward = stakerReward.finalizedBaseReward + stakerReward.storedBaseReward
        + _calculateAccruedReward(
          principal, stakerReward.baseRewardPerToken, buckets.operatorBase.vestedRewardPerToken
        )
        + _calculateAccruedReward(
          principal,
          stakerReward.operatorDelegatedRewardPerToken,
          buckets.operatorDelegated.vestedRewardPerToken
        );
    } else {
      principal = s_communityStakingPool.getStakerPrincipal(staker);
      maxReward = stakerReward.finalizedBaseReward + stakerReward.storedBaseReward
        + _calculateAccruedReward(
          principal, stakerReward.baseRewardPerToken, buckets.communityBase.vestedRewardPerToken
        );
    }

    (, uint256 forfeitedReward) = s_rewardVault.calculateLatestStakerReward(staker);

    if (forfeitedReward == 0) return distribution;

    uint256 totalPrincipal = isOperator
      ? s_operatorStakingPool.getTotalPrincipal()
      : s_communityStakingPool.getTotalPrincipal();

    if (isPrincipalDecreased) {
      totalPrincipal -= principal;
    }
    if (totalPrincipal > 0) {
      distribution.vestedReward = forfeitedReward;
      distribution.vestedRewardPerToken = (forfeitedReward * DECIMALS) / totalPrincipal;
    } else {
      distribution.reclaimableReward = forfeitedReward;
    }

    return distribution;
  }

  function _getExpectedMissingRoleErrorMessage(
    address account,
    bytes32 role
  ) internal pure returns (bytes memory) {
    return abi.encodePacked(
      'AccessControl: account ',
      Strings.toHexString(account),
      ' is missing role ',
      Strings.toHexString(uint256(role), 32)
    );
  }
}
