// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {FixedPointMathLib} from '@solmate/utils/FixedPointMathLib.sol';
import {LinkTokenInterface} from '@chainlink/contracts/src/v0.8/interfaces/LinkTokenInterface.sol';
import {BaseTimeWarpable} from '../helpers/BaseTimeWarpable.t.sol';
import {Constants} from '../../Constants.t.sol';
import {CommunityStakingPool} from '../../../src/pools/CommunityStakingPool.sol';
import {CommunityStakingPoolHandler} from './CommunityStakingPoolHandler.t.sol';
import {IBaseInvariantTest} from '../../interfaces/IInvariantTest.t.sol';
import {OperatorStakingPool} from '../../../src/pools/OperatorStakingPool.sol';
import {OperatorStakingPoolHandler} from './OperatorStakingPoolHandler.t.sol';
import {RewardVault} from '../../../src/rewards/RewardVault.sol';

contract RewardVaultHandler is BaseTimeWarpable, Constants {
  using FixedPointMathLib for uint256;

  struct RewardDurationCheckParams {
    uint256 rewardAmount;
    uint256 emissionRate;
    uint256 operatorPoolShare;
    uint256 totalPoolShare;
    uint256 delegationRateDenominator;
    uint256 operatorBaseRewardAmount;
    uint256 communityBaseRewardAmount;
    uint256 operatorDelegatedRewardAmount;
  }

  /// @notice The community staking pool
  CommunityStakingPool internal immutable i_communityStakingPool;
  /// @notice The operator staking pool
  OperatorStakingPool internal immutable i_operatorStakingPool;
  /// @notice The reward vault
  RewardVault internal immutable i_rewardVault;
  /// @notice The LINK token
  LinkTokenInterface internal immutable i_LINK;
  /// @notice The community staking pool handler
  CommunityStakingPoolHandler internal immutable i_communityStakingPoolHandler;
  /// @notice The operator staking pool handler
  OperatorStakingPoolHandler internal immutable i_operatorStakingPoolHandler;

  /// @notice The total reward amount added to the vault
  uint256 internal s_ghost_rewardAddedTotal;
  /// @notice The current staker being used to simulate actions
  address private s_currentStaker;

  constructor(
    CommunityStakingPool communityStakingPool,
    OperatorStakingPool operatorStakingPool,
    RewardVault rewardVault,
    LinkTokenInterface link,
    CommunityStakingPoolHandler communityStakingPoolHandler,
    OperatorStakingPoolHandler operatorStakingPoolHandler,
    IBaseInvariantTest testContract
  ) BaseTimeWarpable(testContract) {
    i_communityStakingPool = communityStakingPool;
    i_operatorStakingPool = operatorStakingPool;
    i_rewardVault = rewardVault;
    i_LINK = link;
    i_communityStakingPoolHandler = communityStakingPoolHandler;
    i_operatorStakingPoolHandler = operatorStakingPoolHandler;
    s_ghost_rewardAddedTotal = REWARD_AMOUNT;
  }

  /// @notice Simulates contract manager adding rewards for all pools
  /// @param rewardAmount The amount of LINK in juels to add to the reward vault
  /// @param emissionRate The aggregate reward rate to use for the reward
  function addRewardToAllPools(
    uint256 rewardAmount,
    uint256 emissionRate
  ) external useRewarder useTimestamps {
    uint256 linkBalance = i_LINK.balanceOf(REWARDER);
    rewardAmount = bound(rewardAmount, 0, linkBalance);
    emissionRate = bound(emissionRate, 1e15, 1e18);

    if (!_validateAddRewardArgs(rewardAmount, emissionRate)) return;
    if (
      !_validateAddRewardArgsAfterSplit({
        rewardAmount: rewardAmount,
        emissionRate: emissionRate,
        splitWithOperatorPool: true
      })
    ) return;

    s_ghost_rewardAddedTotal += rewardAmount;
    i_rewardVault.addReward(address(0), rewardAmount, emissionRate);
  }

  /// @notice Simulates contract manager adding rewards for the community pool
  /// @param rewardAmount The amount of LINK in juels to add to the reward vault
  /// @param emissionRate The aggregate reward rate to use for the reward
  function addRewardToCommunityPool(
    uint256 rewardAmount,
    uint256 emissionRate
  ) external useRewarder useTimestamps {
    uint256 linkBalance = i_LINK.balanceOf(REWARDER);
    rewardAmount = bound(rewardAmount, 0, linkBalance);
    emissionRate = bound(emissionRate, 1e15, 1e18);

    if (!_validateAddRewardArgs(rewardAmount, emissionRate)) return;
    if (
      !_validateAddRewardArgsAfterSplit({
        rewardAmount: rewardAmount,
        emissionRate: emissionRate,
        splitWithOperatorPool: false
      })
    ) return;

    s_ghost_rewardAddedTotal += rewardAmount;
    i_rewardVault.addReward(address(i_communityStakingPool), rewardAmount, emissionRate);
  }

  /// @notice Simulates contract manager adding rewards for the operator pool
  /// @param rewardAmount The amount of LINK in juels to add to the reward vault
  /// @param emissionRate The aggregate reward rate to use for the reward
  function addRewardToOperatorPool(
    uint256 rewardAmount,
    uint256 emissionRate
  ) external useRewarder useTimestamps {
    uint256 linkBalance = i_LINK.balanceOf(REWARDER);
    rewardAmount = bound(rewardAmount, 0, linkBalance);
    emissionRate = bound(emissionRate, 1e15, 1e18);

    if (!_validateAddRewardArgs(rewardAmount, emissionRate)) return;

    s_ghost_rewardAddedTotal += rewardAmount;
    i_rewardVault.addReward(address(i_operatorStakingPool), rewardAmount, emissionRate);
  }

  /// @notice Simulates contract manager setting the delegation rate denominator
  /// @param newDelegationRateDenominator The new delegation rate denominator
  function setDelegationRateDenominator(uint256 newDelegationRateDenominator)
    external
    useOwner
    useTimestamps
  {
    uint256 oldDelegationRateDenominator = i_rewardVault.getDelegationRateDenominator();
    newDelegationRateDenominator = bound(newDelegationRateDenominator, 0, 10000);
    if (newDelegationRateDenominator == oldDelegationRateDenominator) return;
    if (!_validateAddRewardArgs(0, _getTotalEmissionRate())) return;

    i_rewardVault.setDelegationRateDenominator(newDelegationRateDenominator);
  }

  /// @notice Simulates contract manager setting the multiplier duration
  /// @param newMultiplierDuration The new multiplier duration
  function setMultiplierDuration(uint256 newMultiplierDuration) external useOwner useTimestamps {
    newMultiplierDuration = bound(newMultiplierDuration, 30 days, 365 days);
    i_rewardVault.setMultiplierDuration(newMultiplierDuration);
  }

  /// @notice Simulates a staker claiming rewards
  /// @param stakerIdx The index of the staker to use
  /// @param isOperator Whether or not the staker is an operator
  function claimReward(
    uint256 stakerIdx,
    bool isOperator
  ) external useStaker(stakerIdx, isOperator) useTimestamps {
    uint256 reward = i_rewardVault.getReward(s_currentStaker);
    if (reward == 0) return;
    i_rewardVault.claimReward();
  }

  // =========
  // Getters
  // =========

  /// @notice Gets the total unavailable rewards
  /// @return totalUnvestedRewards The total unavailable rewards
  /// @return unvestedOperatorBaseRewards The unavailable operator base rewards
  /// @return unvestedCommunityBaseRewards The unavailable community base rewards
  /// @return unvestedOperatorDelegatedRewards The unavailable operator delegated rewards
  function getTotalUnvestedRewards() public view returns (uint256, uint256, uint256, uint256) {
    RewardVault.RewardBuckets memory buckets = i_rewardVault.getRewardBuckets();
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

  /// @notice Gets the total added rewards
  /// @return The total added rewards
  function getTotalAddedRewards() external view returns (uint256) {
    return s_ghost_rewardAddedTotal;
  }

  /// @notice Gets the total staker rewards
  /// @return totalStakerRewards The total staker rewards
  /// @return totalOperatorStakerRewards The total operator staker rewards
  /// @return totalCommunityStakerRewards The total community staker rewards
  function getTotalStakerRewards() external view returns (uint256, uint256, uint256) {
    uint256 totalStakerRewards;
    uint256 totalOperatorStakerRewards;
    uint256 totalCommunityStakerRewards;
    address[] memory stakers = i_operatorStakingPoolHandler.getStakers();
    for (uint256 i; i < stakers.length; ++i) {
      totalOperatorStakerRewards += i_rewardVault.getReward(stakers[i]);
    }
    stakers = i_communityStakingPoolHandler.getStakers();
    for (uint256 i; i < stakers.length; ++i) {
      totalCommunityStakerRewards += i_rewardVault.getReward(stakers[i]);
    }
    totalStakerRewards = totalOperatorStakerRewards + totalCommunityStakerRewards;
    return (totalStakerRewards, totalOperatorStakerRewards, totalCommunityStakerRewards);
  }

  // =========
  // Helpers
  // =========

  /// @notice Checks if the reward amount and aggregate reward rate inputs are valid
  /// @param rewardAmount The reward amount to check
  /// @param emissionRate The aggregate reward rate to check
  /// @return True if the reward amount and aggregate reward rate are valid, otherwise false
  function _validateAddRewardArgs(
    uint256 rewardAmount,
    uint256 emissionRate
  ) internal view returns (bool) {
    uint256 delegationRateDenominator = i_rewardVault.getDelegationRateDenominator();
    if (rewardAmount > 0 && rewardAmount < delegationRateDenominator) return false;
    if (emissionRate < delegationRateDenominator) return false;

    return true;
  }

  /// @notice Checks if the reward amount and aggregate reward rate inputs are valid after splitting
  /// into
  /// pools
  /// @param rewardAmount The reward amount to check
  /// @param emissionRate The aggregate reward rate to check
  /// @param splitWithOperatorPool Whether or not to split the reward with the operator pool
  /// @return True if the reward amount and aggregate reward rate are valid, otherwise false
  function _validateAddRewardArgsAfterSplit(
    uint256 rewardAmount,
    uint256 emissionRate,
    bool splitWithOperatorPool
  ) internal view returns (bool) {
    uint256 delegationRateDenominator = i_rewardVault.getDelegationRateDenominator();
    uint256 communityPoolShare = i_communityStakingPool.getMaxPoolSize();
    uint256 operatorPoolShare = splitWithOperatorPool ? i_operatorStakingPool.getMaxPoolSize() : 0;
    uint256 totalPoolShare = communityPoolShare + operatorPoolShare;

    if (
      rewardAmount > 0
        && (
          (
            operatorPoolShare > 0
              && rewardAmount.mulWadDown(operatorPoolShare) * FixedPointMathLib.WAD < totalPoolShare
          )
            || (
              communityPoolShare > 0
                && rewardAmount.mulWadDown(communityPoolShare) * FixedPointMathLib.WAD < totalPoolShare
            )
        )
    ) {
      return false;
    }

    uint256 operatorBaseRewardToAdd =
      rewardAmount.mulWadDown(operatorPoolShare).divWadDown(totalPoolShare);
    uint256 communityBaseRewardToAdd = rewardAmount - operatorBaseRewardToAdd;
    if (communityBaseRewardToAdd > 0 && communityBaseRewardToAdd < delegationRateDenominator) {
      return false;
    }
    uint256 operatorDelegatedRewardToAdd =
      delegationRateDenominator > 0 ? communityBaseRewardToAdd / delegationRateDenominator : 0;
    communityBaseRewardToAdd -= operatorDelegatedRewardToAdd;

    if (
      !_checkRewardDurations(
        RewardDurationCheckParams({
          rewardAmount: rewardAmount,
          emissionRate: emissionRate,
          operatorPoolShare: operatorPoolShare,
          totalPoolShare: totalPoolShare,
          delegationRateDenominator: delegationRateDenominator,
          operatorBaseRewardAmount: operatorBaseRewardToAdd,
          communityBaseRewardAmount: communityBaseRewardToAdd,
          operatorDelegatedRewardAmount: operatorDelegatedRewardToAdd
        })
      )
    ) {
      return false;
    }

    return true;
  }

  /// @notice Checks if the add reward args result in valid durations
  /// @param params The add reward params to check the durations for
  /// @return True if the durations are valid, otherwise false
  function _checkRewardDurations(RewardDurationCheckParams memory params)
    internal
    view
    returns (bool)
  {
    (
      uint256 totalUnvestedRewards,
      uint256 unvestedOperatorBaseRewards,
      uint256 unvestedCommunityBaseRewards,
      uint256 unvestedOperatorDelegatedRewards
    ) = getTotalUnvestedRewards();

    uint256 operatorBaseRate =
      params.emissionRate.mulWadDown(params.operatorPoolShare).divWadDown(params.totalPoolShare);
    uint256 communityBaseRate = params.emissionRate - operatorBaseRate;
    uint256 operatorDelegatedRate = params.delegationRateDenominator > 0
      ? communityBaseRate / params.delegationRateDenominator
      : 0;

    // In practice, we'll be adding at least 3 month worth of rewards at a time
    uint256 minEmissionTime = 30 days;
    if (params.rewardAmount + totalUnvestedRewards < params.emissionRate * minEmissionTime) {
      return false;
    }
    if (
      params.operatorBaseRewardAmount + unvestedOperatorBaseRewards
        < operatorBaseRate * minEmissionTime
    ) {
      return false;
    }
    if (
      params.communityBaseRewardAmount + unvestedCommunityBaseRewards
        < communityBaseRate * minEmissionTime
    ) {
      return false;
    }
    if (
      params.operatorDelegatedRewardAmount + unvestedOperatorDelegatedRewards
        < operatorDelegatedRate * minEmissionTime
    ) return false;

    return true;
  }

  /// @notice Gets the total aggregate reward rate
  /// @return The total aggregate reward rate
  function _getTotalEmissionRate() internal view returns (uint256) {
    RewardVault.RewardBuckets memory buckets = i_rewardVault.getRewardBuckets();
    return buckets.operatorBase.emissionRate + buckets.communityBase.emissionRate
      + buckets.operatorDelegated.emissionRate;
  }

  /// @notice Calculates the unavailable rewards in a bucket
  /// @param bucket The bucket to calculate the unavailable rewards for
  /// @return The unavailable rewards in the bucket
  function _calculateUnvestedRewardsInBucket(RewardVault.RewardBucket memory bucket)
    internal
    view
    returns (uint256)
  {
    return bucket.rewardDurationEndsAt <= block.timestamp
      ? 0
      : bucket.emissionRate * (bucket.rewardDurationEndsAt - block.timestamp);
  }

  // =========
  // Modifiers
  // =========

  /// @dev This modifier is used to simulate the rewarder
  modifier useRewarder() {
    vm.startPrank(REWARDER);
    _;
    vm.stopPrank();
  }

  /// @dev This modifier is used to simulate the owner
  modifier useOwner() {
    vm.startPrank(OWNER);
    _;
    vm.stopPrank();
  }

  /// @dev This modifier is used to simulate a staker
  modifier useStaker(uint256 stakerIdx, bool isOperator) {
    address[] memory stakers = isOperator
      ? i_operatorStakingPoolHandler.getStakers()
      : i_communityStakingPoolHandler.getStakers();
    s_currentStaker = stakers[bound(stakerIdx, 0, stakers.length - 1)];
    vm.startPrank(s_currentStaker);
    _;
    vm.stopPrank();
  }

  function test() public override {}
}
