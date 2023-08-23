// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {LinkTokenInterface} from '@chainlink/contracts/src/v0.8/interfaces/LinkTokenInterface.sol';
import {BaseTimeWarpable} from '../helpers/BaseTimeWarpable.t.sol';
import {Constants} from '../../Constants.t.sol';
import {IBaseInvariantTest} from '../../interfaces/IInvariantTest.t.sol';
import {OperatorStakingPool} from '../../../src/pools/OperatorStakingPool.sol';
import {RewardVault} from '../../../src/rewards/RewardVault.sol';

/// @title This contract is used to test the invariants of the OperatorStakingPool
/// Functions exposed to the fuzzer:
///   - onTokenTransfer
///   - unstake
contract OperatorStakingPoolHandler is BaseTimeWarpable, Constants {
  /// @notice The operator staking pool
  OperatorStakingPool internal immutable i_operatorStakingPool;
  /// @notice The reward vault
  RewardVault internal immutable i_rewardVault;
  /// @notice The LINK token
  LinkTokenInterface internal immutable i_LINK;
  /// @notice The list of operators
  address[] internal s_operators;
  /// @notice The total amount staked in the operator staking pool during
  /// the invariant testing run
  uint256 private s_ghost_totalStaked;
  /// @notice The current staker being used to simulate actions
  address private s_currentStaker;

  constructor(
    OperatorStakingPool operatorStakingPool,
    RewardVault rewardVault,
    LinkTokenInterface link,
    address[] memory operators,
    IBaseInvariantTest testContract
  ) BaseTimeWarpable(testContract) {
    i_operatorStakingPool = operatorStakingPool;
    i_rewardVault = rewardVault;
    i_LINK = link;
    s_operators = operators;
  }

  /// @notice Simulates a single staker staking into the community staking pool
  /// if the staker can still stake into the pool.
  /// @param stakerIdx The index of the staker to use
  /// @param stakeAmount The amount the staker will stake into the pool.
  /// @dev This handler function performs several checks and modifies the stakeAmount
  /// to prevent stakers from staking an invalid amount.  These include:
  ///
  ///  - Ensuring that the staker's staked LINK amount is still less than the pool's
  ///  maximum staker staked LINK amount.
  ///  - Bounding the stakeAmount to be within the pool's minimum and maximum
  /// stake amounts.
  /// - Ensuring that staking the stakeAmount does not increase the staker's
  /// staked LINK amount to more than the maximum staked LINK amount and does not increase the
  /// pool's total staked LINK amount to be more than the pool's maximum size.
  /// - Prevent staking 0 LINK.
  function stake(
    uint256 stakerIdx,
    uint256 stakeAmount
  ) external useStaker(stakerIdx) useTimestamps {
    uint256 stakerPrincipalInPool = i_operatorStakingPool.getStakerPrincipal(s_currentStaker);
    (uint256 minPrincipal, uint256 maxPrincipal) = i_operatorStakingPool.getStakerLimits();
    if (stakerPrincipalInPool == maxPrincipal) return;

    stakeAmount = bound(stakeAmount, minPrincipal, maxPrincipal);

    // Prevent staking more than the max
    if (stakerPrincipalInPool + stakeAmount > maxPrincipal) {
      stakeAmount = maxPrincipal - stakerPrincipalInPool;
    }

    // Prevent staking more than the maximum pool size
    uint256 poolTotalPrincipal = i_operatorStakingPool.getTotalPrincipal();
    if (poolTotalPrincipal + stakeAmount > i_operatorStakingPool.getMaxPoolSize()) {
      stakeAmount = i_operatorStakingPool.getMaxPoolSize() - poolTotalPrincipal;
    }

    // Prevent staking 0 LINK
    if (stakeAmount == 0) return;

    i_LINK.transferAndCall(address(i_operatorStakingPool), stakeAmount, abi.encode(''));
    s_ghost_totalStaked += stakeAmount;
  }

  /// @notice Simulates a staker unbonding and then unstaking from the community
  /// staking pool.
  /// @param stakerIdx The index of the community staker to use
  /// @param unstakeAmount The amount to unstake
  /// @dev This handler functions performs several checks and modifies the
  /// unstakeAmount to prevent stakers from unstaking an invalid amount.  These
  /// include:
  ///
  /// - Unstaking a 0 amount
  /// - Calling the unbond function is the staker has not yet unbonded
  /// - Ensuring that unstaking the unstakeAmount does not reduce the staker's
  /// staked LINK amount to be below the minimum staked LINK amount IF the staker is not unstaking
  /// their full staked LINK amount.
  function unstake(
    uint256 stakerIdx,
    uint256 unstakeAmount
  ) external useStaker(stakerIdx) useTimestamps {
    uint256 stakerPrincipal = i_operatorStakingPool.getStakerPrincipal(s_currentStaker);
    if (stakerPrincipal == 0) return;
    uint256 stakerUnbondingEndsAt = i_operatorStakingPool.getUnbondingEndsAt(s_currentStaker);
    uint256 stakerClaimPeriodEndsAt = i_operatorStakingPool.getClaimPeriodEndsAt(s_currentStaker);
    bool hasNotStartedUnbondingPeriod =
      stakerUnbondingEndsAt == 0 || stakerClaimPeriodEndsAt <= block.timestamp;
    bool isInUnbondingPeriod = stakerUnbondingEndsAt > 0 && block.timestamp < stakerUnbondingEndsAt;
    if (hasNotStartedUnbondingPeriod) {
      i_operatorStakingPool.unbond();
      vm.warp(i_operatorStakingPool.getUnbondingEndsAt(s_currentStaker));
    } else if (isInUnbondingPeriod) {
      vm.warp(i_operatorStakingPool.getUnbondingEndsAt(s_currentStaker));
    }

    unstakeAmount = bound(unstakeAmount, 0, stakerPrincipal);

    // Prevent unstaking 0
    if (unstakeAmount == 0) return;

    // Prevent unstaking to below the minimum
    (uint256 minPrincipal,) = i_operatorStakingPool.getStakerLimits();
    if (stakerPrincipal - unstakeAmount < minPrincipal) return;

    i_operatorStakingPool.unstake(unstakeAmount, false);
    s_ghost_totalStaked -= unstakeAmount;
  }

  /// @notice Returns the total amount staked in the operator staking pool
  /// throughout the invariant test run
  /// @return uint256 The total amount staked in the operator staking pool in juels
  function getTotalStaked() external view returns (uint256) {
    return s_ghost_totalStaked;
  }

  /// @notice Returns the list of operators
  /// @return address[] The list of operators
  function getStakers() external view returns (address[] memory) {
    return s_operators;
  }

  /// @notice Selects a staker from the list of community staker
  /// @param operatorIdx The index of the operator to use
  modifier useStaker(uint256 operatorIdx) {
    s_currentStaker = s_operators[bound(operatorIdx, 0, s_operators.length - 1)];
    if (i_LINK.balanceOf(s_currentStaker) == 0) {
      (, uint256 maxPrincipal) = i_operatorStakingPool.getStakerLimits();
      vm.startPrank(OWNER);
      i_LINK.transfer(s_currentStaker, maxPrincipal);
      vm.stopPrank();
    }
    vm.startPrank(s_currentStaker);
    _;
    vm.stopPrank();
  }

  function test() public override {}
}
