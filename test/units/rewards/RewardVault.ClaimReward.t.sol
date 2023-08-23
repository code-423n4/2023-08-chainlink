// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {FixedPointMathLib} from '@solmate/utils/FixedPointMathLib.sol';

import {BaseTest} from '../../BaseTest.t.sol';
import {
  RewardVault_WhenPaused,
  RewardVault_WhenVaultClosed,
  RewardVault_WithoutStakersAndTimePassed,
  RewardVault_WithStakersAndMultiplierMaxReached,
  RewardVault_WithStakersAndTimePassed,
  RewardVault_AfterUnstake
} from '../../base-scenarios/RewardVaultScenarios.t.sol';
import {
  IRewardVault_ClaimReward_NoAccruedRewards,
  IRewardVault_ClaimReward_WithoutStakers,
  IRewardVault_ClaimReward_WithStakers,
  IRewardVault_ClaimReward_AfterUnstake
} from '../../interfaces/IRewardVaultTest.t.sol';
import {RewardVault} from '../../../src/rewards/RewardVault.sol';

contract RewardVault_ClaimReward_CommunityStakerNotStaked is
  IRewardVault_ClaimReward_WithoutStakers,
  RewardVault_WithoutStakersAndTimePassed
{
  function test_RevertWhen_StakerRewardNotInitialized() public {
    changePrank(COMMUNITY_STAKER_ONE);
    vm.expectRevert(RewardVault.NoRewardToClaim.selector);
    s_rewardVault.claimReward();
  }
}

contract RewardVault_ClaimReward_OperatorNotStaked is
  IRewardVault_ClaimReward_WithoutStakers,
  RewardVault_WithoutStakersAndTimePassed
{
  function test_RevertWhen_StakerRewardNotInitialized() public {
    changePrank(OPERATOR_STAKER_ONE);
    vm.expectRevert(RewardVault.NoRewardToClaim.selector);
    s_rewardVault.claimReward();
  }
}

contract RewardVault_ClaimReward_CommunityStakerAccruedReward is
  IRewardVault_ClaimReward_WithStakers,
  RewardVault_WithStakersAndTimePassed
{
  event RewardClaimed(address indexed staker, uint256 claimedRewards);
  event StakerRewardUpdated(
    address indexed staker,
    uint256 finalizedBaseReward,
    uint256 finalizedDelegatedReward,
    uint256 baseRewardPerToken,
    uint256 operatorDelegatedRewardPerToken,
    uint256 claimedBaseRewardsInPeriod
  );

  function test_TransfersTokensToStaker() public {
    changePrank(COMMUNITY_STAKER_ONE);
    uint256 reward = s_rewardVault.getReward(COMMUNITY_STAKER_ONE);
    uint256 stakerBalanceBefore = s_LINK.balanceOf(COMMUNITY_STAKER_ONE);
    uint256 vaultBalanceBefore = s_LINK.balanceOf(address(s_rewardVault));

    s_rewardVault.claimReward();

    assertEq(s_LINK.balanceOf(COMMUNITY_STAKER_ONE), stakerBalanceBefore + reward);
    assertEq(s_LINK.balanceOf(address(s_rewardVault)), vaultBalanceBefore - reward);
  }

  function test_EmitsEvent() public {
    changePrank(COMMUNITY_STAKER_ONE);
    uint256 fullReward = _calculateStakerExpectedReward(
      COMMUNITY_MIN_PRINCIPAL,
      4 * COMMUNITY_MIN_PRINCIPAL,
      _calculateBucketVestedRewards(
        s_rewardVault.getRewardBuckets().communityBase, s_stakedAtTime, block.timestamp
      )
    );
    uint256 multiplier =
      _calculateStakerMultiplier(s_stakedAtTime, block.timestamp, INITIAL_MULTIPLIER_DURATION);
    uint256 unclaimableReward = fullReward - multiplier * fullReward / FixedPointMathLib.WAD;
    uint256 claimableReward = fullReward - unclaimableReward;
    uint256 rewardPerTokenUpdatedAtBefore = s_rewardVault.getRewardPerTokenUpdatedAt();
    uint256 communityTotalPrincipalBefore = s_communityStakingPool.getTotalPrincipal();
    uint256 expectedCommunityBaseRewardPerToken = _calculateVestedRewardPerToken(
      s_rewardVault.getRewardBuckets().communityBase.vestedRewardPerToken,
      s_rewardVault.getRewardBuckets().communityBase.rewardDurationEndsAt,
      rewardPerTokenUpdatedAtBefore,
      s_rewardVault.getRewardBuckets().communityBase.emissionRate,
      communityTotalPrincipalBefore,
      block.timestamp
    );
    vm.expectEmit(true, true, true, true, address(s_rewardVault));
    emit RewardClaimed(COMMUNITY_STAKER_ONE, claimableReward);
    vm.expectEmit(true, true, true, true, address(s_rewardVault));
    emit StakerRewardUpdated(
      COMMUNITY_STAKER_ONE, 0, 0, expectedCommunityBaseRewardPerToken, 0, claimableReward
    );
    s_rewardVault.claimReward();
  }

  function test_TransfersCorrectAmountIfClaimedPartiallyMultipleTimes() public {
    uint256 stakerLINKBalanceBefore = s_LINK.balanceOf(COMMUNITY_STAKER_ONE);

    changePrank(COMMUNITY_STAKER_ONE);
    s_rewardVault.claimReward();

    assertEq(s_rewardVault.getReward(COMMUNITY_STAKER_ONE), 0);
    skip(3 days);

    s_rewardVault.claimReward();

    BaseTest.StakePeriod[] memory stakePeriods = new BaseTest.StakePeriod[](1);
    stakePeriods[0] = BaseTest.StakePeriod({
      time: block.timestamp - s_stakedAtTime,
      stakerPrincipal: COMMUNITY_MIN_PRINCIPAL,
      totalPrincipalInPool: 4 * COMMUNITY_MIN_PRINCIPAL,
      rewardEmissionRate: s_rewardVault.getRewardBuckets().communityBase.emissionRate,
      rewardVestingTime: block.timestamp - s_stakedAtTime
    });
    uint256 expectedRewards = _calculateExpectedRewardOverMultiplePeriods(
      stakePeriods, INITIAL_MULTIPLIER_DURATION, s_stakedAtTime, s_stakedAtTime
    );

    assertEq(s_LINK.balanceOf(COMMUNITY_STAKER_ONE), stakerLINKBalanceBefore + expectedRewards);
  }
}

contract RewardVault_ClaimReward_OperatorStakerAccruedReward is
  IRewardVault_ClaimReward_WithStakers,
  RewardVault_WithStakersAndTimePassed
{
  event RewardClaimed(address indexed staker, uint256 claimedRewards);
  event StakerRewardUpdated(
    address indexed staker,
    uint256 finalizedBaseReward,
    uint256 finalizedDelegatedReward,
    uint256 baseRewardPerToken,
    uint256 operatorDelegatedRewardPerToken,
    uint256 claimedBaseRewardsInPeriod
  );
  event ForfeitedRewardDistributed(
    uint256 vestedReward,
    uint256 vestedRewardPerToken,
    uint256 reclaimedReward,
    bool isOperatorReward
  );

  function test_TransfersTokensToStaker() public {
    changePrank(OPERATOR_STAKER_ONE);

    uint256 reward = s_rewardVault.getReward(OPERATOR_STAKER_ONE);
    uint256 stakerBalanceBefore = s_LINK.balanceOf(OPERATOR_STAKER_ONE);
    uint256 vaultBalanceBefore = s_LINK.balanceOf(address(s_rewardVault));

    s_rewardVault.claimReward();

    assertEq(s_LINK.balanceOf(OPERATOR_STAKER_ONE), stakerBalanceBefore + reward);
    assertEq(s_LINK.balanceOf(address(s_rewardVault)), vaultBalanceBefore - reward);
  }

  function test_DoesNotForfeitReward() public {
    uint256 rewardPerTokenUpdatedAtBefore = s_rewardVault.getRewardPerTokenUpdatedAt();
    uint256 communityTotalPrincipalBefore = s_communityStakingPool.getTotalPrincipal();
    uint256 operatorTotalPrincipalBefore = s_operatorStakingPool.getTotalPrincipal();
    changePrank(OPERATOR_STAKER_ONE);
    RewardVault.RewardBuckets memory bucketsBefore = s_rewardVault.getRewardBuckets();
    s_rewardVault.claimReward();

    // no vestedRewardPerToken changes
    RewardVault.RewardBuckets memory bucketsAfter = s_rewardVault.getRewardBuckets();
    assertEq(
      bucketsAfter.communityBase.vestedRewardPerToken,
      _calculateVestedRewardPerToken(
        bucketsBefore.communityBase.vestedRewardPerToken,
        bucketsBefore.communityBase.rewardDurationEndsAt,
        rewardPerTokenUpdatedAtBefore,
        bucketsBefore.communityBase.emissionRate,
        communityTotalPrincipalBefore,
        block.timestamp
      )
    );
    assertEq(
      bucketsAfter.operatorBase.vestedRewardPerToken,
      _calculateVestedRewardPerToken(
        bucketsBefore.operatorBase.vestedRewardPerToken,
        bucketsBefore.operatorBase.rewardDurationEndsAt,
        rewardPerTokenUpdatedAtBefore,
        bucketsBefore.operatorBase.emissionRate,
        operatorTotalPrincipalBefore,
        block.timestamp
      )
    );
    assertEq(
      bucketsAfter.operatorDelegated.vestedRewardPerToken,
      _calculateVestedRewardPerToken(
        bucketsBefore.operatorDelegated.vestedRewardPerToken,
        bucketsBefore.operatorDelegated.rewardDurationEndsAt,
        rewardPerTokenUpdatedAtBefore,
        bucketsBefore.operatorDelegated.emissionRate,
        operatorTotalPrincipalBefore,
        block.timestamp
      )
    );
  }

  function test_EmitsEvent() public {
    changePrank(OPERATOR_STAKER_ONE);
    uint256 fullBaseReward = _calculateStakerExpectedReward(
      OPERATOR_MIN_PRINCIPAL,
      4 * OPERATOR_MIN_PRINCIPAL,
      _calculateBucketVestedRewards(
        s_rewardVault.getRewardBuckets().operatorBase, s_stakedAtTime, block.timestamp
      )
    );
    uint256 multiplier =
      _calculateStakerMultiplier(s_stakedAtTime, block.timestamp, INITIAL_MULTIPLIER_DURATION);
    uint256 unclaimableReward = fullBaseReward - multiplier * fullBaseReward / FixedPointMathLib.WAD;
    uint256 claimableReward = s_rewardVault.getReward(OPERATOR_STAKER_ONE);
    uint256 rewardPerTokenUpdatedAtBefore = s_rewardVault.getRewardPerTokenUpdatedAt();
    uint256 operatorTotalPrincipalBefore = s_operatorStakingPool.getTotalPrincipal();
    uint256 expectedOperatorBaseRewardPerToken = _calculateVestedRewardPerToken(
      s_rewardVault.getRewardBuckets().operatorBase.vestedRewardPerToken,
      s_rewardVault.getRewardBuckets().operatorBase.rewardDurationEndsAt,
      rewardPerTokenUpdatedAtBefore,
      s_rewardVault.getRewardBuckets().operatorBase.emissionRate,
      operatorTotalPrincipalBefore,
      block.timestamp
    );
    uint256 expectedOperatorDelegatedRewardPerToken = _calculateVestedRewardPerToken(
      s_rewardVault.getRewardBuckets().operatorDelegated.vestedRewardPerToken,
      s_rewardVault.getRewardBuckets().operatorDelegated.rewardDurationEndsAt,
      rewardPerTokenUpdatedAtBefore,
      s_rewardVault.getRewardBuckets().operatorDelegated.emissionRate,
      operatorTotalPrincipalBefore,
      block.timestamp
    );

    vm.expectEmit(true, true, true, true, address(s_rewardVault));
    emit RewardClaimed(OPERATOR_STAKER_ONE, claimableReward);
    vm.expectEmit(true, true, true, true, address(s_rewardVault));
    emit StakerRewardUpdated(
      OPERATOR_STAKER_ONE,
      0,
      0,
      expectedOperatorBaseRewardPerToken,
      expectedOperatorDelegatedRewardPerToken,
      fullBaseReward - unclaimableReward
    );

    s_rewardVault.claimReward();
  }

  function test_TransfersCorrectAmountIfClaimedPartiallyMultipleTimes() public {
    uint256 stakerLINKBalanceBefore = s_LINK.balanceOf(OPERATOR_STAKER_ONE);

    changePrank(OPERATOR_STAKER_ONE);
    s_rewardVault.claimReward();

    assertEq(s_rewardVault.getReward(OPERATOR_STAKER_ONE), 0);
    skip(3 days);

    s_rewardVault.claimReward();

    BaseTest.StakePeriod[] memory stakePeriods = new BaseTest.StakePeriod[](1);
    stakePeriods[0] = BaseTest.StakePeriod({
      time: block.timestamp - s_stakedAtTime,
      stakerPrincipal: OPERATOR_MIN_PRINCIPAL,
      totalPrincipalInPool: 4 * OPERATOR_MIN_PRINCIPAL,
      rewardEmissionRate: s_rewardVault.getRewardBuckets().operatorBase.emissionRate,
      rewardVestingTime: block.timestamp - s_stakedAtTime
    });
    uint256 expectedBaseRewards = _calculateExpectedRewardOverMultiplePeriods(
      stakePeriods, INITIAL_MULTIPLIER_DURATION, s_stakedAtTime, s_stakedAtTime
    );
    uint256 expectedDelegatedRewards = _calculateStakerExpectedReward(
      OPERATOR_MIN_PRINCIPAL,
      4 * OPERATOR_MIN_PRINCIPAL,
      _calculateBucketVestedRewards(
        s_rewardVault.getRewardBuckets().operatorDelegated, s_stakedAtTime, block.timestamp
      )
    );

    assertEq(
      s_LINK.balanceOf(OPERATOR_STAKER_ONE),
      stakerLINKBalanceBefore + expectedBaseRewards + expectedDelegatedRewards
    );
  }
}

contract RewardVault_ClaimReward_AfterStakersUnstake is
  IRewardVault_ClaimReward_AfterUnstake,
  RewardVault_AfterUnstake
{
  function test_TransfersCorrectTokenAmountToCommunityStakerThatHasFullyUnstaked() public override {
    uint256 stakerLINKBalanceBefore = s_LINK.balanceOf(COMMUNITY_STAKER_ONE);
    changePrank(COMMUNITY_STAKER_ONE);
    uint256 rewardAmount = s_rewardVault.getReward(COMMUNITY_STAKER_ONE);
    s_rewardVault.claimReward();
    assertEq(s_LINK.balanceOf(COMMUNITY_STAKER_ONE), stakerLINKBalanceBefore + rewardAmount);
  }

  function test_TransfersCorrectTokenAmountToOperatorThatHasFullyUnstaked() public override {
    uint256 stakerLINKBalanceBefore = s_LINK.balanceOf(OPERATOR_STAKER_ONE);
    changePrank(OPERATOR_STAKER_ONE);
    uint256 rewardAmount = s_rewardVault.getReward(OPERATOR_STAKER_ONE);
    s_rewardVault.claimReward();
    assertEq(s_LINK.balanceOf(OPERATOR_STAKER_ONE), stakerLINKBalanceBefore + rewardAmount);
  }

  function test_TransfersCorrectTokenAmountToCommunityStakerThatHasPartiallyUnstaked()
    public
    override
  {
    uint256 stakerLINKBalanceBefore = s_LINK.balanceOf(COMMUNITY_STAKER_TWO);
    changePrank(COMMUNITY_STAKER_TWO);
    uint256 rewardAmount = s_rewardVault.getReward(COMMUNITY_STAKER_TWO);
    s_rewardVault.claimReward();
    assertEq(s_LINK.balanceOf(COMMUNITY_STAKER_TWO), stakerLINKBalanceBefore + rewardAmount);
  }

  function test_TransfersCorrectTokenAmountToOperatorThatHasPartiallyUnstaked() public override {
    uint256 stakerLINKBalanceBefore = s_LINK.balanceOf(OPERATOR_STAKER_TWO);
    changePrank(OPERATOR_STAKER_TWO);
    uint256 rewardAmount = s_rewardVault.getReward(OPERATOR_STAKER_TWO);
    s_rewardVault.claimReward();
    assertEq(s_LINK.balanceOf(OPERATOR_STAKER_TWO), stakerLINKBalanceBefore + rewardAmount);
  }
}

contract RewardVault_ClaimReward_CommunityStakerNoReward is
  IRewardVault_ClaimReward_NoAccruedRewards,
  RewardVault_WithStakersAndTimePassed
{
  function setUp() public override {
    RewardVault_WithStakersAndTimePassed.setUp();

    changePrank(COMMUNITY_STAKER_ONE);

    s_rewardVault.claimReward();
    assertEq(s_rewardVault.getReward(COMMUNITY_STAKER_ONE), 0);
  }

  function test_RevertWhen_StakerHasNoReward() public {
    uint256 stakerBalanceBefore = s_LINK.balanceOf(COMMUNITY_STAKER_ONE);
    uint256 vaultBalanceBefore = s_LINK.balanceOf(address(s_rewardVault));

    // did not accrue more rewards since last claimReward
    vm.expectRevert(RewardVault.NoRewardToClaim.selector);
    s_rewardVault.claimReward();

    assertEq(s_LINK.balanceOf(COMMUNITY_STAKER_ONE), stakerBalanceBefore);
    assertEq(s_LINK.balanceOf(address(s_rewardVault)), vaultBalanceBefore);
  }

  function test_DoesNotForfeitReward() public {
    RewardVault.RewardBuckets memory bucketsBefore = s_rewardVault.getRewardBuckets();

    // did not accrue more rewards since last claimReward
    vm.expectRevert(RewardVault.NoRewardToClaim.selector);
    s_rewardVault.claimReward();

    // no vestedRewardPerToken changes
    RewardVault.RewardBuckets memory bucketsAfter = s_rewardVault.getRewardBuckets();
    assertEq(
      bucketsAfter.communityBase.vestedRewardPerToken,
      bucketsBefore.communityBase.vestedRewardPerToken
    );
    assertEq(
      bucketsAfter.operatorBase.vestedRewardPerToken,
      bucketsBefore.operatorBase.vestedRewardPerToken
    );
    assertEq(
      bucketsAfter.operatorDelegated.vestedRewardPerToken,
      bucketsBefore.operatorDelegated.vestedRewardPerToken
    );
  }
}

contract RewardVault_ClaimReward_OperatorStakerNoReward is
  IRewardVault_ClaimReward_NoAccruedRewards,
  RewardVault_WithStakersAndTimePassed
{
  function setUp() public override {
    super.setUp();

    changePrank(OPERATOR_STAKER_ONE);

    s_rewardVault.claimReward();
    assertEq(s_rewardVault.getReward(OPERATOR_STAKER_ONE), 0);
  }

  function test_RevertWhen_StakerHasNoReward() public {
    uint256 stakerBalanceBefore = s_LINK.balanceOf(OPERATOR_STAKER_ONE);
    uint256 vaultBalanceBefore = s_LINK.balanceOf(address(s_rewardVault));

    // did not accrue more rewards since last claimReward
    vm.expectRevert(RewardVault.NoRewardToClaim.selector);
    s_rewardVault.claimReward();

    assertEq(s_LINK.balanceOf(OPERATOR_STAKER_ONE), stakerBalanceBefore);
    assertEq(s_LINK.balanceOf(address(s_rewardVault)), vaultBalanceBefore);
  }

  function test_DoesNotForfeitReward() public {
    RewardVault.RewardBuckets memory bucketsBefore = s_rewardVault.getRewardBuckets();

    // did not accrue more rewards since last claimReward
    vm.expectRevert(RewardVault.NoRewardToClaim.selector);
    s_rewardVault.claimReward();

    // no vestedRewardPerToken changes
    RewardVault.RewardBuckets memory bucketsAfter = s_rewardVault.getRewardBuckets();
    assertEq(
      bucketsAfter.communityBase.vestedRewardPerToken,
      bucketsBefore.communityBase.vestedRewardPerToken
    );
    assertEq(
      bucketsAfter.operatorBase.vestedRewardPerToken,
      bucketsBefore.operatorBase.vestedRewardPerToken
    );
    assertEq(
      bucketsAfter.operatorDelegated.vestedRewardPerToken,
      bucketsBefore.operatorDelegated.vestedRewardPerToken
    );
  }
}

contract RewardVault_ClaimReward_CommunityStakerReachedMaxMultiplier is
  RewardVault_WithStakersAndMultiplierMaxReached
{
  function test_DoesNotForfeitReward() public {
    // ensure no change in disitributedRewardPerToken due to time passed
    s_rewardVault.updateReward(address(0), 0);
    RewardVault.RewardBuckets memory bucketsBefore = s_rewardVault.getRewardBuckets();

    changePrank(COMMUNITY_STAKER_ONE);
    s_rewardVault.claimReward();

    // no vestedRewardPerToken changes
    RewardVault.RewardBuckets memory bucketsAfter = s_rewardVault.getRewardBuckets();
    assertEq(
      bucketsAfter.communityBase.vestedRewardPerToken,
      bucketsBefore.communityBase.vestedRewardPerToken
    );
    assertEq(
      bucketsAfter.operatorBase.vestedRewardPerToken,
      bucketsBefore.operatorBase.vestedRewardPerToken
    );
    assertEq(
      bucketsAfter.operatorDelegated.vestedRewardPerToken,
      bucketsBefore.operatorDelegated.vestedRewardPerToken
    );
  }
}

contract RewardVault_ClaimReward_OperatorStakerReachedMaxMultiplier is
  RewardVault_WithStakersAndMultiplierMaxReached
{
  function test_DoesNotForfeitReward() public {
    // ensure no change in disitributedRewardPerToken due to time passed
    s_rewardVault.updateReward(address(0), 0);
    RewardVault.RewardBuckets memory bucketsBefore = s_rewardVault.getRewardBuckets();

    changePrank(OPERATOR_STAKER_ONE);
    s_rewardVault.claimReward();

    // no vestedRewardPerToken changes
    RewardVault.RewardBuckets memory bucketsAfter = s_rewardVault.getRewardBuckets();
    assertEq(
      bucketsAfter.communityBase.vestedRewardPerToken,
      bucketsBefore.communityBase.vestedRewardPerToken
    );
    assertEq(
      bucketsAfter.operatorBase.vestedRewardPerToken,
      bucketsBefore.operatorBase.vestedRewardPerToken
    );
    assertEq(
      bucketsAfter.operatorDelegated.vestedRewardPerToken,
      bucketsBefore.operatorDelegated.vestedRewardPerToken
    );
  }
}

contract RewardVault_ClaimReward_CommunityPoolIsEmpty is RewardVault_WithStakersAndTimePassed {
  function test_OnlyRevestForfeitedRewardToOperatorBaseAndDelegatedRewardBuckets() public {
    // all community stakers leave pool
    changePrank(COMMUNITY_STAKER_ONE);
    s_communityStakingPool.unbond();
    changePrank(COMMUNITY_STAKER_TWO);
    s_communityStakingPool.unbond();

    skip(UNBONDING_PERIOD);

    changePrank(COMMUNITY_STAKER_ONE);
    s_communityStakingPool.unstake(
      s_communityStakingPool.getStakerPrincipal(COMMUNITY_STAKER_ONE), false
    );
    changePrank(COMMUNITY_STAKER_TWO);
    uint256 rewardBefore = s_rewardVault.getReward(COMMUNITY_STAKER_TWO);
    ForfeitedRewardDistribution memory distribution = _calculateForfeitedRewardDistribution({
      staker: COMMUNITY_STAKER_TWO,
      isOperator: false,
      isPrincipalDecreased: true
    });
    RewardVault.RewardBuckets memory bucketsBefore = s_rewardVault.getRewardBuckets();
    s_communityStakingPool.unstake(
      s_communityStakingPool.getStakerPrincipal(COMMUNITY_STAKER_TWO), false
    );
    assertEq(
      s_rewardVault.getReward(COMMUNITY_STAKER_TWO), rewardBefore + distribution.reclaimableReward
    );

    s_rewardVault.claimReward();

    RewardVault.RewardBuckets memory bucketsAfter = s_rewardVault.getRewardBuckets();
    assertEq(
      bucketsAfter.communityBase.vestedRewardPerToken,
      bucketsBefore.communityBase.vestedRewardPerToken
    );
    assertEq(
      bucketsAfter.operatorBase.vestedRewardPerToken,
      bucketsBefore.operatorBase.vestedRewardPerToken
    );
    assertEq(
      bucketsAfter.operatorDelegated.vestedRewardPerToken,
      bucketsBefore.operatorDelegated.vestedRewardPerToken
    );
  }
}

contract RewardVault_ClaimReward_OperatorPoolIsEmpty is RewardVault_WithStakersAndTimePassed {
  function test_OnlyRevestForfeitedRewardToCommunityBaseRewardBuckets() public {
    // all operator stakers leave pool
    changePrank(OPERATOR_STAKER_ONE);
    s_operatorStakingPool.unbond();
    changePrank(OPERATOR_STAKER_TWO);
    s_operatorStakingPool.unbond();

    skip(UNBONDING_PERIOD);

    changePrank(OPERATOR_STAKER_ONE);
    s_operatorStakingPool.unstake(
      s_operatorStakingPool.getStakerPrincipal(OPERATOR_STAKER_ONE), false
    );
    changePrank(OPERATOR_STAKER_TWO);
    uint256 rewardBefore = s_rewardVault.getReward(OPERATOR_STAKER_TWO);
    ForfeitedRewardDistribution memory distribution = _calculateForfeitedRewardDistribution({
      staker: OPERATOR_STAKER_TWO,
      isOperator: true,
      isPrincipalDecreased: true
    });
    RewardVault.RewardBuckets memory bucketsBefore = s_rewardVault.getRewardBuckets();
    s_operatorStakingPool.unstake(
      s_operatorStakingPool.getStakerPrincipal(OPERATOR_STAKER_TWO), false
    );
    assertEq(
      s_rewardVault.getReward(OPERATOR_STAKER_TWO), rewardBefore + distribution.reclaimableReward
    );

    s_rewardVault.claimReward();

    RewardVault.RewardBuckets memory bucketsAfter = s_rewardVault.getRewardBuckets();
    assertEq(
      bucketsAfter.communityBase.vestedRewardPerToken,
      bucketsBefore.communityBase.vestedRewardPerToken
    );
    assertEq(
      bucketsAfter.operatorBase.vestedRewardPerToken,
      bucketsBefore.operatorBase.vestedRewardPerToken
    );
    assertEq(
      bucketsAfter.operatorDelegated.vestedRewardPerToken,
      bucketsBefore.operatorDelegated.vestedRewardPerToken
    );
  }

  function test_CommunityStakerClaimsCorrectRewardAmountAfterMultipleClaims() public {
    uint256 stakerLINKBalanceBefore = s_LINK.balanceOf(COMMUNITY_STAKER_ONE);

    changePrank(COMMUNITY_STAKER_ONE);
    s_rewardVault.claimReward();

    assertEq(s_rewardVault.getReward(COMMUNITY_STAKER_ONE), 0);
    skip(3 days);

    s_rewardVault.claimReward();

    BaseTest.StakePeriod[] memory stakePeriods = new BaseTest.StakePeriod[](1);
    stakePeriods[0] = BaseTest.StakePeriod({
      time: block.timestamp - s_stakedAtTime,
      stakerPrincipal: COMMUNITY_MIN_PRINCIPAL,
      totalPrincipalInPool: 4 * COMMUNITY_MIN_PRINCIPAL,
      rewardEmissionRate: s_rewardVault.getRewardBuckets().communityBase.emissionRate,
      rewardVestingTime: block.timestamp - s_stakedAtTime
    });
    uint256 expectedRewards = _calculateExpectedRewardOverMultiplePeriods(
      stakePeriods, INITIAL_MULTIPLIER_DURATION, s_stakedAtTime, s_stakedAtTime
    );

    assertEq(s_LINK.balanceOf(COMMUNITY_STAKER_ONE), stakerLINKBalanceBefore + expectedRewards);
  }

  function test_OperatorStakerClaimsCorrectRewardAmountAfterMultipleClaims() public {
    uint256 stakerLINKBalanceBefore = s_LINK.balanceOf(OPERATOR_STAKER_ONE);

    changePrank(OPERATOR_STAKER_ONE);
    s_rewardVault.claimReward();

    assertEq(s_rewardVault.getReward(OPERATOR_STAKER_ONE), 0);
    skip(3 days);

    s_rewardVault.claimReward();

    BaseTest.StakePeriod[] memory stakePeriods = new BaseTest.StakePeriod[](1);
    stakePeriods[0] = BaseTest.StakePeriod({
      time: block.timestamp - s_stakedAtTime,
      stakerPrincipal: OPERATOR_MIN_PRINCIPAL,
      totalPrincipalInPool: 4 * OPERATOR_MIN_PRINCIPAL,
      rewardEmissionRate: s_rewardVault.getRewardBuckets().operatorBase.emissionRate,
      rewardVestingTime: block.timestamp - s_stakedAtTime
    });
    uint256 expectedBaseRewards = _calculateExpectedRewardOverMultiplePeriods(
      stakePeriods, INITIAL_MULTIPLIER_DURATION, s_stakedAtTime, s_stakedAtTime
    );
    uint256 expectedDelegatedRewards = _calculateStakerExpectedReward(
      OPERATOR_MIN_PRINCIPAL,
      4 * OPERATOR_MIN_PRINCIPAL,
      _calculateBucketVestedRewards(
        s_rewardVault.getRewardBuckets().operatorDelegated, s_stakedAtTime, block.timestamp
      )
    );

    assertEq(
      s_LINK.balanceOf(OPERATOR_STAKER_ONE),
      stakerLINKBalanceBefore + expectedBaseRewards + expectedDelegatedRewards
    );
  }
}

contract RewardVault_ClaimReward_StakerAccruedRewardAmountTooSmall is
  RewardVault_WithoutStakersAndTimePassed
{
  function setUp() public override {
    RewardVault_WithoutStakersAndTimePassed.setUp();
    changePrank(OWNER);
    s_communityStakingPool.setMerkleRoot(bytes32(''));
    s_communityStakingPool.setPoolConfig(COMMUNITY_MAX_POOL_SIZE * 3, COMMUNITY_MAX_PRINCIPAL * 3);

    uint256 maxPoolSize = 5 * COMMUNITY_MAX_POOL_SIZE;
    uint256 maxPrincipal = 5 * COMMUNITY_MAX_PRINCIPAL;
    uint256 numStakers = maxPoolSize / maxPrincipal - 1; // Leave some room in the pool
    s_communityStakingPool.setPoolConfig(maxPoolSize, maxPrincipal);

    for (uint256 i; i < numStakers; ++i) {
      address staker = address(uint160(10000 + i));
      changePrank(OWNER);
      s_LINK.transfer(staker, maxPrincipal);

      changePrank(staker);
      s_LINK.transferAndCall(address(s_communityStakingPool), maxPrincipal, abi.encode(bytes32('')));
    }
  }

  function test_DoesNotUpdateRewardBucketIfRewardPerTokenRoundsToZero() public {
    s_stakedAtTime = block.timestamp;
    changePrank(COMMUNITY_STAKER_ONE);
    s_LINK.transferAndCall(
      address(s_communityStakingPool),
      COMMUNITY_MIN_PRINCIPAL,
      abi.encode(s_communityStakerOneProof)
    );

    // accrue very small amount
    skip(1);
    changePrank(address(s_communityStakingPool));
    s_rewardVault.updateReward(address(0), 0);

    ForfeitedRewardDistribution memory distribution = _calculateForfeitedRewardDistribution({
      staker: COMMUNITY_STAKER_ONE,
      isOperator: false,
      isPrincipalDecreased: false
    });
    assertGt(distribution.vestedReward, 0);
    assertEq(distribution.vestedRewardPerToken, 0);
    assertEq(distribution.reclaimableReward, 0);

    RewardVault.RewardBuckets memory bucketsBefore = s_rewardVault.getRewardBuckets();

    changePrank(COMMUNITY_STAKER_ONE);
    s_rewardVault.claimReward();

    RewardVault.RewardBuckets memory bucketsAfter = s_rewardVault.getRewardBuckets();
    assertEq(
      bucketsAfter.communityBase.vestedRewardPerToken,
      bucketsBefore.communityBase.vestedRewardPerToken
    );
    assertEq(
      bucketsAfter.operatorBase.vestedRewardPerToken,
      bucketsBefore.operatorBase.vestedRewardPerToken
    );
    assertEq(
      bucketsAfter.operatorDelegated.vestedRewardPerToken,
      bucketsBefore.operatorDelegated.vestedRewardPerToken
    );
  }
}

contract RewardVault_ClaimReward_MultiplierAlmostReachedMax is
  RewardVault_WithoutStakersAndTimePassed
{
  function setUp() public override {
    RewardVault_WithoutStakersAndTimePassed.setUp();
    changePrank(OWNER);
    s_communityStakingPool.setMerkleRoot(bytes32(''));

    uint256 maxPoolSize = 5 * COMMUNITY_MAX_POOL_SIZE;
    uint256 maxPrincipal = 5 * COMMUNITY_MAX_PRINCIPAL;
    uint256 numStakers = maxPoolSize / maxPrincipal - 1; // Leave some room in the pool
    s_communityStakingPool.setPoolConfig(maxPoolSize, maxPrincipal);

    for (uint256 i; i < numStakers; ++i) {
      address staker = address(uint160(10000 + i));
      changePrank(OWNER);
      s_LINK.transfer(staker, maxPrincipal);

      changePrank(staker);
      s_LINK.transferAndCall(address(s_communityStakingPool), maxPrincipal, abi.encode(bytes32('')));
    }
  }

  function test_DoesNotRevestIfForfeitedRewardPerTokenRoundsToZero() public {
    s_stakedAtTime = block.timestamp;
    changePrank(COMMUNITY_STAKER_ONE);
    s_LINK.transferAndCall(
      address(s_communityStakingPool),
      COMMUNITY_MIN_PRINCIPAL,
      abi.encode(s_communityStakerOneProof)
    );

    // grow multiplier to almost max
    skip(INITIAL_MULTIPLIER_DURATION - 1);
    changePrank(address(s_communityStakingPool));
    s_rewardVault.updateReward(address(0), 0);

    ForfeitedRewardDistribution memory distribution = _calculateForfeitedRewardDistribution({
      staker: COMMUNITY_STAKER_ONE,
      isOperator: false,
      isPrincipalDecreased: false
    });
    assertGt(distribution.vestedReward, 0);
    assertEq(distribution.vestedRewardPerToken, 0);
    assertEq(distribution.reclaimableReward, 0);

    RewardVault.RewardBuckets memory bucketsBefore = s_rewardVault.getRewardBuckets();

    changePrank(COMMUNITY_STAKER_ONE);
    s_rewardVault.claimReward();

    RewardVault.RewardBuckets memory bucketsAfter = s_rewardVault.getRewardBuckets();
    assertEq(
      bucketsAfter.communityBase.vestedRewardPerToken,
      bucketsBefore.communityBase.vestedRewardPerToken
    );
    assertEq(
      bucketsAfter.operatorBase.vestedRewardPerToken,
      bucketsBefore.operatorBase.vestedRewardPerToken
    );
    assertEq(
      bucketsAfter.operatorDelegated.vestedRewardPerToken,
      bucketsBefore.operatorDelegated.vestedRewardPerToken
    );
  }
}

contract RewardVault_ClaimReward_WhenPaused is RewardVault_WhenPaused {
  function test_RevertWhen_Paused() public {
    changePrank(COMMUNITY_STAKER_ONE);
    vm.expectRevert('Pausable: paused');
    s_rewardVault.claimReward();
  }

  function test_CanClaimRewardAfterUnpausing() public {
    uint256 reward = s_rewardVault.getReward(COMMUNITY_STAKER_ONE);
    assertGt(reward, 0);

    changePrank(PAUSER);
    s_rewardVault.emergencyUnpause();

    changePrank(COMMUNITY_STAKER_ONE);
    assertEq(s_rewardVault.getReward(COMMUNITY_STAKER_ONE), reward);
    s_rewardVault.claimReward();
    assertEq(s_rewardVault.getReward(COMMUNITY_STAKER_ONE), 0);
  }
}

contract RewardVault_ClaimReward_WhenVaultClosed is RewardVault_WhenVaultClosed {
  function test_CommunityStakerCanClaimReward() public {
    changePrank(COMMUNITY_STAKER_ONE);
    uint256 reward = s_rewardVault.getReward(COMMUNITY_STAKER_ONE);
    uint256 stakerBalanceBefore = s_LINK.balanceOf(COMMUNITY_STAKER_ONE);
    uint256 vaultBalanceBefore = s_LINK.balanceOf(address(s_rewardVault));

    s_rewardVault.claimReward();

    assertEq(s_LINK.balanceOf(COMMUNITY_STAKER_ONE), stakerBalanceBefore + reward);
    assertEq(s_LINK.balanceOf(address(s_rewardVault)), vaultBalanceBefore - reward);
  }

  function test_OperatorStakerCanClaimReward() public {
    changePrank(OPERATOR_STAKER_ONE);
    uint256 reward = s_rewardVault.getReward(OPERATOR_STAKER_ONE);
    uint256 stakerBalanceBefore = s_LINK.balanceOf(OPERATOR_STAKER_ONE);
    uint256 vaultBalanceBefore = s_LINK.balanceOf(address(s_rewardVault));

    s_rewardVault.claimReward();

    assertEq(s_LINK.balanceOf(OPERATOR_STAKER_ONE), stakerBalanceBefore + reward);
    assertEq(s_LINK.balanceOf(address(s_rewardVault)), vaultBalanceBefore - reward);
  }

  function test_CommunityStakerForfeitedRewardIsNotVested() public {
    changePrank(COMMUNITY_STAKER_ONE);
    RewardVault.RewardBuckets memory bucketsBefore = s_rewardVault.getRewardBuckets();

    s_rewardVault.claimReward();

    RewardVault.RewardBuckets memory bucketsAfter = s_rewardVault.getRewardBuckets();
    assertEq(
      bucketsAfter.communityBase.vestedRewardPerToken,
      bucketsBefore.communityBase.vestedRewardPerToken
    );
    assertEq(
      bucketsAfter.operatorBase.vestedRewardPerToken,
      bucketsBefore.operatorBase.vestedRewardPerToken
    );
    assertEq(
      bucketsAfter.operatorDelegated.vestedRewardPerToken,
      bucketsBefore.operatorDelegated.vestedRewardPerToken
    );
  }

  function test_OperatorStakerForfeitedRewardIsNotVested() public {
    changePrank(OPERATOR_STAKER_ONE);
    RewardVault.RewardBuckets memory bucketsBefore = s_rewardVault.getRewardBuckets();

    s_rewardVault.claimReward();

    RewardVault.RewardBuckets memory bucketsAfter = s_rewardVault.getRewardBuckets();
    assertEq(
      bucketsAfter.communityBase.vestedRewardPerToken,
      bucketsBefore.communityBase.vestedRewardPerToken
    );
    assertEq(
      bucketsAfter.operatorBase.vestedRewardPerToken,
      bucketsBefore.operatorBase.vestedRewardPerToken
    );
    assertEq(
      bucketsAfter.operatorDelegated.vestedRewardPerToken,
      bucketsBefore.operatorDelegated.vestedRewardPerToken
    );
  }
}
