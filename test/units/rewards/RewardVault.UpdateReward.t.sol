// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Math} from '@openzeppelin/contracts/utils/math/Math.sol';

import {FixedPointMathLib} from '@solmate/utils/FixedPointMathLib.sol';

import {
  RewardVault_InClaimPeriod,
  RewardVault_WhenTimeDidNotPass,
  RewardVault_WithoutStakersAndTimePassed,
  RewardVault_WithStakersAndTimePassedAndPoolsUpdated,
  RewardVault_WithStakersAndTimeDidNotPass,
  RewardVault_WithStakersAndTimePassed
} from '../../base-scenarios/RewardVaultScenarios.t.sol';
import {
  IRewardVault_UpdateReward_UpdateOnlyCommunityStakerWhenRewardAccrued,
  IRewardVault_UpdateReward_UpdateOnlyOperatorWhenRewardAccrued,
  IRewardVault_UpdateReward_UpdateOnlyPoolsOnlyUpdatesUpdatedAt,
  IRewardVault_UpdateReward_UpdateOnlyPoolsWhenRewardAccrued,
  IRewardVault_UpdateReward_UpdateOnlyPoolsWhenTimeDidNotPass,
  IRewardVault_UpdateReward_UpdateOnlyStakerWhenTimeDidNotPass,
  IRewardVault_UpdateReward_UpdatePoolsAndCommunityStakerWhenRewardAccrued,
  IRewardVault_UpdateReward_UpdatePoolsAndOperatorWhenRewardAccrued,
  IRewardVault_UpdateReward_UpdatePoolsAndStakerWhenTimeDidNotPass
} from '../../interfaces/IRewardVaultTest.t.sol';
import {RewardVault} from '../../../src/rewards/RewardVault.sol';

contract RewardVault_UpdateReward_UpdateOnlyPoolsWhenTimeDidNotPass is
  IRewardVault_UpdateReward_UpdateOnlyPoolsWhenTimeDidNotPass,
  RewardVault_WhenTimeDidNotPass
{
  function test_RevertWhen_CalledByNonValidPool() public {
    changePrank(STRANGER);
    vm.expectRevert(RewardVault.AccessForbidden.selector);
    s_rewardVault.updateReward(address(0), 0);
  }

  function test_DoesNotUpdateVestedRewardPerTokens() public {
    changePrank(address(s_communityStakingPool));
    RewardVault.RewardBuckets memory bucketsBefore = s_rewardVault.getRewardBuckets();

    s_rewardVault.updateReward(address(0), 0);

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

  function test_DoesNotUpdateRewardPerTokenUpdatedAt() public {
    changePrank(address(s_communityStakingPool));
    uint256 rewardPerTokenUpdatedAtBefore = s_rewardVault.getRewardPerTokenUpdatedAt();
    // time didn't pass since the last `updateReward` call
    s_rewardVault.updateReward(address(0), 0);
    assertEq(s_rewardVault.getRewardPerTokenUpdatedAt(), block.timestamp);
    assertEq(s_rewardVault.getRewardPerTokenUpdatedAt(), rewardPerTokenUpdatedAtBefore);
  }
}

contract RewardVault_UpdateReward_UpdateOnlyPoolsWhenTotalPrincipalIsZero is
  IRewardVault_UpdateReward_UpdateOnlyPoolsOnlyUpdatesUpdatedAt,
  RewardVault_WithoutStakersAndTimePassed
{
  function test_DoesNotUpdateVestedRewardPerTokens() public {
    RewardVault.RewardBuckets memory bucketsBefore = s_rewardVault.getRewardBuckets();

    changePrank(address(s_communityStakingPool));
    s_rewardVault.updateReward(address(0), 0);

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

  function test_UpdatesRewardPerTokenUpdatedAt() public {
    changePrank(address(s_communityStakingPool));
    assertLt(s_rewardVault.getRewardPerTokenUpdatedAt(), block.timestamp);
    s_rewardVault.updateReward(address(0), 0);
    assertEq(s_rewardVault.getRewardPerTokenUpdatedAt(), block.timestamp);
  }
}

contract RewardVault_UpdateReward_UpdateOnlyPoolsWhenTimePassed is
  IRewardVault_UpdateReward_UpdateOnlyPoolsWhenRewardAccrued,
  RewardVault_WithStakersAndTimePassed
{
  event PoolRewardUpdated(
    uint256 communityBaseRewardPerToken,
    uint256 operatorBaseRewardPerToken,
    uint256 operatorDelegatedRewardPerToken
  );

  function test_UpdatesVestedRewardPerTokens() public {
    uint256 rewardPerTokenUpdatedAtBefore = s_rewardVault.getRewardPerTokenUpdatedAt();
    uint256 communityTotalPrincipalBefore = s_communityStakingPool.getTotalPrincipal();
    uint256 operatorTotalPrincipalBefore = s_operatorStakingPool.getTotalPrincipal();

    uint256 expectedCommunityBaseRewardPerToken = _calculateVestedRewardPerToken(
      s_rewardVault.getRewardBuckets().communityBase.vestedRewardPerToken,
      s_rewardVault.getRewardBuckets().communityBase.rewardDurationEndsAt,
      rewardPerTokenUpdatedAtBefore,
      s_rewardVault.getRewardBuckets().communityBase.emissionRate,
      communityTotalPrincipalBefore,
      block.timestamp
    );
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

    changePrank(address(s_communityStakingPool));
    vm.expectEmit(true, true, true, true, address(s_rewardVault));
    emit PoolRewardUpdated(
      expectedCommunityBaseRewardPerToken,
      expectedOperatorBaseRewardPerToken,
      expectedOperatorDelegatedRewardPerToken
    );
    s_rewardVault.updateReward(address(0), 0);

    RewardVault.RewardBuckets memory bucketsAfter = s_rewardVault.getRewardBuckets();

    assertEq(bucketsAfter.communityBase.vestedRewardPerToken, expectedCommunityBaseRewardPerToken);
    assertEq(bucketsAfter.operatorBase.vestedRewardPerToken, expectedOperatorBaseRewardPerToken);
    assertEq(
      bucketsAfter.operatorDelegated.vestedRewardPerToken, expectedOperatorDelegatedRewardPerToken
    );
  }

  function test_UpdatesRewardPerTokenUpdatedAt() public {
    changePrank(address(s_communityStakingPool));
    uint256 rewardPerTokenUpdatedAtBefore = s_rewardVault.getRewardPerTokenUpdatedAt();
    s_rewardVault.updateReward(address(0), 0);
    assertEq(s_rewardVault.getRewardPerTokenUpdatedAt(), block.timestamp);
    assertGt(s_rewardVault.getRewardPerTokenUpdatedAt(), rewardPerTokenUpdatedAtBefore);
  }
}

contract RewardVault_UpdateReward_UpdateOnlyStakerWhenTimeDidNotPass is
  IRewardVault_UpdateReward_UpdateOnlyPoolsWhenTimeDidNotPass,
  IRewardVault_UpdateReward_UpdateOnlyStakerWhenTimeDidNotPass,
  RewardVault_WithStakersAndTimeDidNotPass
{
  function test_DoesNotUpdateVestedRewardPerTokens() public {
    changePrank(address(s_communityStakingPool));
    RewardVault.RewardBuckets memory bucketsBefore = s_rewardVault.getRewardBuckets();

    // time didn't pass since the last `updateReward` call
    s_rewardVault.updateReward(COMMUNITY_STAKER_ONE, COMMUNITY_MIN_PRINCIPAL);

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

  function test_DoesNotUpdateRewardPerTokenUpdatedAt() public {
    changePrank(address(s_communityStakingPool));
    s_rewardVault.updateReward(COMMUNITY_STAKER_ONE, COMMUNITY_MIN_PRINCIPAL);
    uint256 rewardPerTokenUpdatedAtBefore = s_rewardVault.getRewardPerTokenUpdatedAt();
    // time didn't pass since the last `updateReward` call
    s_rewardVault.updateReward(COMMUNITY_STAKER_ONE, COMMUNITY_MIN_PRINCIPAL);
    assertEq(s_rewardVault.getRewardPerTokenUpdatedAt(), block.timestamp);
    assertEq(s_rewardVault.getRewardPerTokenUpdatedAt(), rewardPerTokenUpdatedAtBefore);
  }

  function test_DoesNotUpdateStakerStoredReward() public {
    changePrank(address(s_communityStakingPool));
    s_rewardVault.updateReward(COMMUNITY_STAKER_ONE, COMMUNITY_MIN_PRINCIPAL);

    RewardVault.StakerReward memory stakerRewardBefore =
      s_rewardVault.getStoredReward(COMMUNITY_STAKER_ONE);

    // time didn't pass since the last `updateReward` call
    s_rewardVault.updateReward(COMMUNITY_STAKER_ONE, COMMUNITY_MIN_PRINCIPAL);

    RewardVault.StakerReward memory stakerRewardAfter =
      s_rewardVault.getStoredReward(COMMUNITY_STAKER_ONE);

    assertEq(stakerRewardAfter.storedBaseReward, stakerRewardBefore.storedBaseReward);
  }

  function test_DoesNotUpdateStakerFinalizedReward() public {
    changePrank(address(s_communityStakingPool));
    s_rewardVault.updateReward(COMMUNITY_STAKER_ONE, COMMUNITY_MIN_PRINCIPAL);

    RewardVault.StakerReward memory stakerRewardBefore =
      s_rewardVault.getStoredReward(COMMUNITY_STAKER_ONE);
    assertEq(stakerRewardBefore.finalizedDelegatedReward, 0);

    // time didn't pass since the last `updateReward` call
    s_rewardVault.updateReward(COMMUNITY_STAKER_ONE, COMMUNITY_MIN_PRINCIPAL);

    RewardVault.StakerReward memory stakerRewardAfter =
      s_rewardVault.getStoredReward(COMMUNITY_STAKER_ONE);

    assertEq(stakerRewardAfter.finalizedBaseReward, stakerRewardBefore.finalizedBaseReward);
    assertEq(
      stakerRewardAfter.finalizedDelegatedReward, stakerRewardBefore.finalizedDelegatedReward
    );
  }

  function test_DoesNotUpdateStakerBaseRewardPerToken() public {
    changePrank(address(s_communityStakingPool));
    s_rewardVault.updateReward(COMMUNITY_STAKER_ONE, COMMUNITY_MIN_PRINCIPAL);

    RewardVault.StakerReward memory stakerRewardBefore =
      s_rewardVault.getStoredReward(COMMUNITY_STAKER_ONE);

    // time didn't pass since the last `updateReward` call
    s_rewardVault.updateReward(COMMUNITY_STAKER_ONE, COMMUNITY_MIN_PRINCIPAL);

    RewardVault.StakerReward memory stakerRewardAfter =
      s_rewardVault.getStoredReward(COMMUNITY_STAKER_ONE);

    assertEq(stakerRewardAfter.baseRewardPerToken, stakerRewardBefore.baseRewardPerToken);
  }

  function test_DoesNotUpdateStakerDelegatedRewardPerToken() public {
    changePrank(address(s_communityStakingPool));
    s_rewardVault.updateReward(COMMUNITY_STAKER_ONE, COMMUNITY_MIN_PRINCIPAL);

    RewardVault.StakerReward memory stakerRewardBefore =
      s_rewardVault.getStoredReward(COMMUNITY_STAKER_ONE);

    // time didn't pass since the last `updateReward` call
    s_rewardVault.updateReward(COMMUNITY_STAKER_ONE, COMMUNITY_MIN_PRINCIPAL);

    RewardVault.StakerReward memory stakerRewardAfter =
      s_rewardVault.getStoredReward(COMMUNITY_STAKER_ONE);

    assertEq(
      stakerRewardAfter.operatorDelegatedRewardPerToken,
      stakerRewardBefore.operatorDelegatedRewardPerToken
    );
  }
}

contract RewardVault_UpdateReward_WhenCommunityBaseRewardDurationEnded_FirstCallAfterEnd is
  IRewardVault_UpdateReward_UpdateOnlyPoolsWhenRewardAccrued,
  RewardVault_WithStakersAndTimePassed
{
  function setUp() public override {
    RewardVault_WithStakersAndTimePassed.setUp();

    vm.warp(s_rewardVault.getRewardBuckets().communityBase.rewardDurationEndsAt + 1);
  }

  function test_UpdatesVestedRewardPerTokens() public {
    uint256 rewardPerTokenUpdatedAtBefore = s_rewardVault.getRewardPerTokenUpdatedAt();
    uint256 communityTotalPrincipalBefore = s_communityStakingPool.getTotalPrincipal();
    uint256 operatorTotalPrincipalBefore = s_operatorStakingPool.getTotalPrincipal();
    RewardVault.RewardBuckets memory bucketsBefore = s_rewardVault.getRewardBuckets();

    changePrank(address(s_communityStakingPool));
    s_rewardVault.updateReward(address(0), 0);

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

    // total available reward amount until the end of reward duration
    assertEq(
      bucketsAfter.communityBase.vestedRewardPerToken * communityTotalPrincipalBefore,
      bucketsAfter.communityBase.emissionRate
        * (
          Math.min(block.timestamp, bucketsBefore.communityBase.rewardDurationEndsAt) - rewardAddedAt
        ) * DECIMALS
    );
    assertEq(
      bucketsAfter.operatorBase.vestedRewardPerToken * operatorTotalPrincipalBefore,
      bucketsAfter.operatorBase.emissionRate
        * (Math.min(block.timestamp, bucketsBefore.operatorBase.rewardDurationEndsAt) - rewardAddedAt)
        * DECIMALS
    );
    assertEq(
      bucketsAfter.operatorDelegated.vestedRewardPerToken * operatorTotalPrincipalBefore,
      bucketsAfter.operatorDelegated.emissionRate
        * (
          Math.min(block.timestamp, bucketsBefore.operatorDelegated.rewardDurationEndsAt)
            - rewardAddedAt
        ) * DECIMALS
    );
  }

  function test_UpdatesRewardPerTokenUpdatedAt() public {
    changePrank(address(s_communityStakingPool));
    uint256 rewardPerTokenUpdatedAtBefore = s_rewardVault.getRewardPerTokenUpdatedAt();
    s_rewardVault.updateReward(address(0), 0);
    assertEq(s_rewardVault.getRewardPerTokenUpdatedAt(), block.timestamp);
    assertGt(s_rewardVault.getRewardPerTokenUpdatedAt(), rewardPerTokenUpdatedAtBefore);
  }
}

contract RewardVault_UpdateReward_WhenOperatorBaseRewardDurationEnded_FirstCallAfterEnd is
  IRewardVault_UpdateReward_UpdateOnlyPoolsWhenRewardAccrued,
  RewardVault_WithStakersAndTimePassed
{
  function setUp() public override {
    RewardVault_WithStakersAndTimePassed.setUp();

    vm.warp(s_rewardVault.getRewardBuckets().operatorBase.rewardDurationEndsAt + 1);
  }

  function test_UpdatesVestedRewardPerTokens() public {
    uint256 rewardPerTokenUpdatedAtBefore = s_rewardVault.getRewardPerTokenUpdatedAt();
    uint256 communityTotalPrincipalBefore = s_communityStakingPool.getTotalPrincipal();
    uint256 operatorTotalPrincipalBefore = s_operatorStakingPool.getTotalPrincipal();
    RewardVault.RewardBuckets memory bucketsBefore = s_rewardVault.getRewardBuckets();

    changePrank(address(s_communityStakingPool));
    s_rewardVault.updateReward(address(0), 0);

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

    // total available reward amount until the end of reward duration
    assertEq(
      bucketsAfter.communityBase.vestedRewardPerToken * communityTotalPrincipalBefore,
      bucketsAfter.communityBase.emissionRate
        * (
          Math.min(block.timestamp, bucketsBefore.communityBase.rewardDurationEndsAt) - rewardAddedAt
        ) * DECIMALS
    );
    assertEq(
      bucketsAfter.operatorBase.vestedRewardPerToken * operatorTotalPrincipalBefore,
      bucketsAfter.operatorBase.emissionRate
        * (Math.min(block.timestamp, bucketsBefore.operatorBase.rewardDurationEndsAt) - rewardAddedAt)
        * DECIMALS
    );
    assertEq(
      bucketsAfter.operatorDelegated.vestedRewardPerToken * operatorTotalPrincipalBefore,
      bucketsAfter.operatorDelegated.emissionRate
        * (
          Math.min(block.timestamp, bucketsBefore.operatorDelegated.rewardDurationEndsAt)
            - rewardAddedAt
        ) * DECIMALS
    );
  }

  function test_UpdatesRewardPerTokenUpdatedAt() public {
    changePrank(address(s_communityStakingPool));
    uint256 rewardPerTokenUpdatedAtBefore = s_rewardVault.getRewardPerTokenUpdatedAt();
    s_rewardVault.updateReward(address(0), 0);
    assertEq(s_rewardVault.getRewardPerTokenUpdatedAt(), block.timestamp);
    assertGt(s_rewardVault.getRewardPerTokenUpdatedAt(), rewardPerTokenUpdatedAtBefore);
  }
}

contract RewardVault_UpdateReward_WhenOperatorDelegatedRewardDurationEnded_FirstCallAfterEnd is
  IRewardVault_UpdateReward_UpdateOnlyPoolsWhenRewardAccrued,
  RewardVault_WithStakersAndTimePassed
{
  function setUp() public override {
    RewardVault_WithStakersAndTimePassed.setUp();

    vm.warp(s_rewardVault.getRewardBuckets().operatorDelegated.rewardDurationEndsAt + 1);
  }

  function test_UpdatesVestedRewardPerTokens() public {
    uint256 rewardPerTokenUpdatedAtBefore = s_rewardVault.getRewardPerTokenUpdatedAt();
    uint256 communityTotalPrincipalBefore = s_communityStakingPool.getTotalPrincipal();
    uint256 operatorTotalPrincipalBefore = s_operatorStakingPool.getTotalPrincipal();
    RewardVault.RewardBuckets memory bucketsBefore = s_rewardVault.getRewardBuckets();

    changePrank(address(s_communityStakingPool));
    s_rewardVault.updateReward(address(0), 0);

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

    // total available reward amount until the end of reward duration
    assertEq(
      bucketsAfter.communityBase.vestedRewardPerToken * communityTotalPrincipalBefore,
      bucketsAfter.communityBase.emissionRate
        * (
          Math.min(block.timestamp, bucketsBefore.communityBase.rewardDurationEndsAt) - rewardAddedAt
        ) * DECIMALS
    );
    assertEq(
      bucketsAfter.operatorBase.vestedRewardPerToken * operatorTotalPrincipalBefore,
      bucketsAfter.operatorBase.emissionRate
        * (Math.min(block.timestamp, bucketsBefore.operatorBase.rewardDurationEndsAt) - rewardAddedAt)
        * DECIMALS
    );
    assertEq(
      bucketsAfter.operatorDelegated.vestedRewardPerToken * operatorTotalPrincipalBefore,
      bucketsAfter.operatorDelegated.emissionRate
        * (
          Math.min(block.timestamp, bucketsBefore.operatorDelegated.rewardDurationEndsAt)
            - rewardAddedAt
        ) * DECIMALS
    );
  }

  function test_UpdatesRewardPerTokenUpdatedAt() public {
    changePrank(address(s_communityStakingPool));
    uint256 rewardPerTokenUpdatedAtBefore = s_rewardVault.getRewardPerTokenUpdatedAt();
    s_rewardVault.updateReward(address(0), 0);
    assertEq(s_rewardVault.getRewardPerTokenUpdatedAt(), block.timestamp);
    assertGt(s_rewardVault.getRewardPerTokenUpdatedAt(), rewardPerTokenUpdatedAtBefore);
  }
}

contract RewardVault_UpdateReward_WhenCommunityBaseRewardDurationEnded_NotFirstCallAfterEnd is
  IRewardVault_UpdateReward_UpdateOnlyPoolsOnlyUpdatesUpdatedAt,
  RewardVault_WithStakersAndTimePassed
{
  function setUp() public override {
    RewardVault_WithStakersAndTimePassed.setUp();

    vm.warp(s_rewardVault.getRewardBuckets().communityBase.rewardDurationEndsAt + 1);

    changePrank(address(s_communityStakingPool));
    s_rewardVault.updateReward(address(0), 0);

    vm.warp(block.timestamp + 10);
  }

  function test_DoesNotUpdateVestedRewardPerTokens() public {
    changePrank(address(s_communityStakingPool));

    RewardVault.RewardBuckets memory bucketsBefore = s_rewardVault.getRewardBuckets();

    s_rewardVault.updateReward(address(0), 0);

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

  function test_UpdatesRewardPerTokenUpdatedAt() public {
    changePrank(address(s_communityStakingPool));
    uint256 rewardPerTokenUpdatedAtBefore = s_rewardVault.getRewardPerTokenUpdatedAt();
    s_rewardVault.updateReward(address(0), 0);
    assertEq(s_rewardVault.getRewardPerTokenUpdatedAt(), block.timestamp);
    assertGt(s_rewardVault.getRewardPerTokenUpdatedAt(), rewardPerTokenUpdatedAtBefore);
  }
}

contract RewardVault_UpdateReward_WhenOperatorBaseRewardDurationEnded_NotFirstCallAfterEnd is
  IRewardVault_UpdateReward_UpdateOnlyPoolsOnlyUpdatesUpdatedAt,
  RewardVault_WithStakersAndTimePassed
{
  function setUp() public override {
    RewardVault_WithStakersAndTimePassed.setUp();

    vm.warp(s_rewardVault.getRewardBuckets().operatorBase.rewardDurationEndsAt + 1);

    changePrank(address(s_communityStakingPool));
    s_rewardVault.updateReward(address(0), 0);

    vm.warp(block.timestamp + 10);
  }

  function test_DoesNotUpdateVestedRewardPerTokens() public {
    changePrank(address(s_communityStakingPool));

    RewardVault.RewardBuckets memory bucketsBefore = s_rewardVault.getRewardBuckets();

    s_rewardVault.updateReward(address(0), 0);

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

  function test_UpdatesRewardPerTokenUpdatedAt() public {
    changePrank(address(s_communityStakingPool));
    uint256 rewardPerTokenUpdatedAtBefore = s_rewardVault.getRewardPerTokenUpdatedAt();
    s_rewardVault.updateReward(address(0), 0);
    assertEq(s_rewardVault.getRewardPerTokenUpdatedAt(), block.timestamp);
    assertGt(s_rewardVault.getRewardPerTokenUpdatedAt(), rewardPerTokenUpdatedAtBefore);
  }
}

contract RewardVault_UpdateReward_WhenOperatorDelegatedRewardDurationEnded_NotFirstCallAfterEnd is
  IRewardVault_UpdateReward_UpdateOnlyPoolsOnlyUpdatesUpdatedAt,
  RewardVault_WithStakersAndTimePassed
{
  function setUp() public override {
    RewardVault_WithStakersAndTimePassed.setUp();

    vm.warp(s_rewardVault.getRewardBuckets().operatorDelegated.rewardDurationEndsAt + 1);

    changePrank(address(s_communityStakingPool));
    s_rewardVault.updateReward(address(0), 0);

    vm.warp(block.timestamp + 10);
  }

  function test_DoesNotUpdateVestedRewardPerTokens() public {
    changePrank(address(s_communityStakingPool));

    RewardVault.RewardBuckets memory bucketsBefore = s_rewardVault.getRewardBuckets();

    s_rewardVault.updateReward(address(0), 0);

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

  function test_UpdatesRewardPerTokenUpdatedAt() public {
    changePrank(address(s_communityStakingPool));
    uint256 rewardPerTokenUpdatedAtBefore = s_rewardVault.getRewardPerTokenUpdatedAt();
    s_rewardVault.updateReward(address(0), 0);
    assertEq(s_rewardVault.getRewardPerTokenUpdatedAt(), block.timestamp);
    assertGt(s_rewardVault.getRewardPerTokenUpdatedAt(), rewardPerTokenUpdatedAtBefore);
  }
}

contract RewardVault_UpdateReward_UpdateOnlyStakerWhenCalledForCommunityStaker is
  IRewardVault_UpdateReward_UpdateOnlyPoolsWhenTimeDidNotPass,
  IRewardVault_UpdateReward_UpdateOnlyCommunityStakerWhenRewardAccrued,
  RewardVault_WithStakersAndTimePassedAndPoolsUpdated
{
  event StakerRewardUpdated(
    address indexed staker,
    uint256 finalizedBaseReward,
    uint256 finalizedDelegatedReward,
    uint256 baseRewardPerToken,
    uint256 operatorDelegatedRewardPerToken,
    uint256 claimedBaseRewardsInPeriod
  );

  function test_DoesNotUpdateVestedRewardPerTokens() public {
    changePrank(address(s_communityStakingPool));
    RewardVault.RewardBuckets memory bucketsBefore = s_rewardVault.getRewardBuckets();

    s_rewardVault.updateReward(COMMUNITY_STAKER_ONE, COMMUNITY_MIN_PRINCIPAL);

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

  function test_DoesNotUpdateRewardPerTokenUpdatedAt() public {
    changePrank(address(s_communityStakingPool));
    uint256 rewardPerTokenUpdatedAtBefore = s_rewardVault.getRewardPerTokenUpdatedAt();
    s_rewardVault.updateReward(COMMUNITY_STAKER_ONE, COMMUNITY_MIN_PRINCIPAL);
    assertEq(s_rewardVault.getRewardPerTokenUpdatedAt(), rewardPerTokenUpdatedAtBefore);
  }

  function test_UpdatesStakerStoredReward() public {
    changePrank(address(s_communityStakingPool));

    uint256 stakerPrincipal = s_communityStakingPool.getStakerPrincipal(COMMUNITY_STAKER_ONE);
    RewardVault.StakerReward memory stakerRewardBefore =
      s_rewardVault.getStoredReward(COMMUNITY_STAKER_ONE);

    uint256 expectedStoredReward = _calculateAccruedReward(
      stakerPrincipal,
      stakerRewardBefore.baseRewardPerToken,
      s_rewardVault.getRewardBuckets().communityBase.vestedRewardPerToken
    );

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
    emit StakerRewardUpdated(COMMUNITY_STAKER_ONE, 0, 0, expectedCommunityBaseRewardPerToken, 0, 0);
    s_rewardVault.updateReward(COMMUNITY_STAKER_ONE, COMMUNITY_MIN_PRINCIPAL);

    RewardVault.StakerReward memory stakerRewardAfter =
      s_rewardVault.getStoredReward(COMMUNITY_STAKER_ONE);

    assertEq(stakerRewardAfter.storedBaseReward, expectedStoredReward);
  }

  function test_DoesNotUpdateStakerFinalizedReward() public {
    changePrank(address(s_communityStakingPool));

    RewardVault.StakerReward memory stakerRewardBefore =
      s_rewardVault.getStoredReward(COMMUNITY_STAKER_ONE);
    assertEq(stakerRewardBefore.finalizedDelegatedReward, 0);

    s_rewardVault.updateReward(COMMUNITY_STAKER_ONE, COMMUNITY_MIN_PRINCIPAL);

    RewardVault.StakerReward memory stakerRewardAfter =
      s_rewardVault.getStoredReward(COMMUNITY_STAKER_ONE);

    assertEq(stakerRewardAfter.finalizedBaseReward, stakerRewardBefore.finalizedBaseReward);
    assertEq(
      stakerRewardAfter.finalizedDelegatedReward, stakerRewardBefore.finalizedDelegatedReward
    );
  }

  function test_UpdatesStakerBaseRewardPerToken() public {
    changePrank(address(s_communityStakingPool));

    s_rewardVault.updateReward(COMMUNITY_STAKER_ONE, COMMUNITY_MIN_PRINCIPAL);

    RewardVault.RewardBuckets memory bucketsAfter = s_rewardVault.getRewardBuckets();
    RewardVault.StakerReward memory stakerRewardAfter =
      s_rewardVault.getStoredReward(COMMUNITY_STAKER_ONE);

    assertEq(stakerRewardAfter.baseRewardPerToken, bucketsAfter.communityBase.vestedRewardPerToken);
  }

  function test_DoesNotUpdateStakerDelegatedRewardPerToken() public {
    changePrank(address(s_communityStakingPool));

    RewardVault.StakerReward memory stakerRewardBefore =
      s_rewardVault.getStoredReward(COMMUNITY_STAKER_ONE);

    s_rewardVault.updateReward(COMMUNITY_STAKER_ONE, COMMUNITY_MIN_PRINCIPAL);

    RewardVault.StakerReward memory stakerRewardAfter =
      s_rewardVault.getStoredReward(COMMUNITY_STAKER_ONE);

    assertEq(
      stakerRewardAfter.operatorDelegatedRewardPerToken,
      stakerRewardBefore.operatorDelegatedRewardPerToken
    );
  }
}

contract RewardVault_UpdateReward_UpdateOnlyStakerWhenCalledForOperator is
  IRewardVault_UpdateReward_UpdateOnlyPoolsWhenTimeDidNotPass,
  IRewardVault_UpdateReward_UpdateOnlyOperatorWhenRewardAccrued,
  RewardVault_WithStakersAndTimePassedAndPoolsUpdated
{
  event StakerRewardUpdated(
    address indexed staker,
    uint256 finalizedBaseReward,
    uint256 finalizedDelegatedReward,
    uint256 baseRewardPerToken,
    uint256 operatorDelegatedRewardPerToken,
    uint256 claimedBaseRewardsInPeriod
  );

  function test_DoesNotUpdateVestedRewardPerTokens() public {
    changePrank(address(s_operatorStakingPool));

    RewardVault.RewardBuckets memory bucketsBefore = s_rewardVault.getRewardBuckets();

    s_rewardVault.updateReward(OPERATOR_STAKER_ONE, OPERATOR_MIN_PRINCIPAL);

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

  function test_DoesNotUpdateRewardPerTokenUpdatedAt() public {
    changePrank(address(s_operatorStakingPool));
    uint256 rewardPerTokenUpdatedAtBefore = s_rewardVault.getRewardPerTokenUpdatedAt();
    s_rewardVault.updateReward(OPERATOR_STAKER_ONE, OPERATOR_MIN_PRINCIPAL);
    assertEq(s_rewardVault.getRewardPerTokenUpdatedAt(), rewardPerTokenUpdatedAtBefore);
  }

  function test_UpdatesStakerStoredReward() public {
    changePrank(address(s_operatorStakingPool));

    uint256 stakerPrincipal = s_operatorStakingPool.getStakerPrincipal(OPERATOR_STAKER_ONE);
    RewardVault.StakerReward memory stakerRewardBefore =
      s_rewardVault.getStoredReward(OPERATOR_STAKER_ONE);
    uint256 expectedFinalizedDelegatedReward = _calculateAccruedReward(
      stakerPrincipal,
      stakerRewardBefore.operatorDelegatedRewardPerToken,
      s_rewardVault.getRewardBuckets().operatorDelegated.vestedRewardPerToken
    );

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
    emit StakerRewardUpdated(
      OPERATOR_STAKER_ONE,
      0,
      expectedFinalizedDelegatedReward,
      expectedOperatorBaseRewardPerToken,
      expectedOperatorDelegatedRewardPerToken,
      0
    );
    s_rewardVault.updateReward(OPERATOR_STAKER_ONE, OPERATOR_MIN_PRINCIPAL);

    RewardVault.RewardBuckets memory bucketsAfter = s_rewardVault.getRewardBuckets();
    RewardVault.StakerReward memory stakerRewardAfter =
      s_rewardVault.getStoredReward(OPERATOR_STAKER_ONE);

    assertEq(
      stakerRewardAfter.storedBaseReward,
      stakerRewardBefore.storedBaseReward
        + _calculateAccruedReward(
          stakerPrincipal,
          stakerRewardBefore.baseRewardPerToken,
          bucketsAfter.operatorBase.vestedRewardPerToken
        )
    );
  }

  function test_UpdatesStakerFinalizedReward() public {
    changePrank(address(s_operatorStakingPool));

    uint256 stakerPrincipal = s_operatorStakingPool.getStakerPrincipal(OPERATOR_STAKER_ONE);
    RewardVault.StakerReward memory stakerRewardBefore =
      s_rewardVault.getStoredReward(OPERATOR_STAKER_ONE);

    s_rewardVault.updateReward(OPERATOR_STAKER_ONE, OPERATOR_MIN_PRINCIPAL);

    RewardVault.RewardBuckets memory bucketsAfter = s_rewardVault.getRewardBuckets();
    RewardVault.StakerReward memory stakerRewardAfter =
      s_rewardVault.getStoredReward(OPERATOR_STAKER_ONE);

    // base rewards are not yet finalized
    assertEq(stakerRewardAfter.finalizedBaseReward, 0);
    assertEq(
      stakerRewardAfter.finalizedDelegatedReward,
      stakerRewardBefore.finalizedDelegatedReward
        + _calculateAccruedReward(
          stakerPrincipal,
          stakerRewardBefore.operatorDelegatedRewardPerToken,
          bucketsAfter.operatorDelegated.vestedRewardPerToken
        )
    );
  }

  function test_UpdatesStakerBaseRewardPerToken() public {
    changePrank(address(s_operatorStakingPool));

    s_rewardVault.updateReward(OPERATOR_STAKER_ONE, OPERATOR_MIN_PRINCIPAL);

    RewardVault.RewardBuckets memory bucketsAfter = s_rewardVault.getRewardBuckets();
    RewardVault.StakerReward memory stakerRewardAfter =
      s_rewardVault.getStoredReward(OPERATOR_STAKER_ONE);

    assertEq(stakerRewardAfter.baseRewardPerToken, bucketsAfter.operatorBase.vestedRewardPerToken);
  }

  function test_UpdatesStakerDelegatedRewardPerToken() public {
    changePrank(address(s_operatorStakingPool));

    s_rewardVault.updateReward(OPERATOR_STAKER_ONE, OPERATOR_MIN_PRINCIPAL);

    RewardVault.RewardBuckets memory bucketsAfter = s_rewardVault.getRewardBuckets();
    RewardVault.StakerReward memory stakerRewardAfter =
      s_rewardVault.getStoredReward(OPERATOR_STAKER_ONE);

    assertEq(
      stakerRewardAfter.operatorDelegatedRewardPerToken,
      bucketsAfter.operatorDelegated.vestedRewardPerToken
    );
  }
}

contract RewardVault_UpdateReward_UpdatePoolsAndStakerWhenCalledForCommunityStaker is
  IRewardVault_UpdateReward_UpdatePoolsAndCommunityStakerWhenRewardAccrued,
  RewardVault_WithStakersAndTimePassed
{
  function test_UpdatesVestedRewardPerTokens() public {
    changePrank(address(s_communityStakingPool));
    uint256 rewardPerTokenUpdatedAtBefore = s_rewardVault.getRewardPerTokenUpdatedAt();
    uint256 communityTotalPrincipalBefore = s_communityStakingPool.getTotalPrincipal();
    uint256 operatorTotalPrincipalBefore = s_operatorStakingPool.getTotalPrincipal();
    RewardVault.RewardBuckets memory bucketsBefore = s_rewardVault.getRewardBuckets();

    s_rewardVault.updateReward(COMMUNITY_STAKER_ONE, COMMUNITY_MIN_PRINCIPAL);

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

    // total available reward amount until now
    assertEq(
      bucketsAfter.communityBase.vestedRewardPerToken * communityTotalPrincipalBefore,
      bucketsAfter.communityBase.emissionRate * (block.timestamp - rewardAddedAt) * DECIMALS
    );
    assertEq(
      bucketsAfter.operatorBase.vestedRewardPerToken * operatorTotalPrincipalBefore,
      bucketsAfter.operatorBase.emissionRate * (block.timestamp - rewardAddedAt) * DECIMALS
    );
    assertEq(
      bucketsAfter.operatorDelegated.vestedRewardPerToken * operatorTotalPrincipalBefore,
      bucketsAfter.operatorDelegated.emissionRate * (block.timestamp - rewardAddedAt) * DECIMALS
    );
  }

  function test_UpdatesRewardPerTokenUpdatedAt() public {
    changePrank(address(s_communityStakingPool));
    uint256 rewardPerTokenUpdatedAtBefore = s_rewardVault.getRewardPerTokenUpdatedAt();
    s_rewardVault.updateReward(COMMUNITY_STAKER_ONE, COMMUNITY_MIN_PRINCIPAL);
    assertEq(s_rewardVault.getRewardPerTokenUpdatedAt(), block.timestamp);
    assertGt(s_rewardVault.getRewardPerTokenUpdatedAt(), rewardPerTokenUpdatedAtBefore);
  }

  function test_UpdatesStakerStoredReward() public {
    changePrank(address(s_communityStakingPool));

    uint256 stakerPrincipal = s_communityStakingPool.getStakerPrincipal(COMMUNITY_STAKER_ONE);
    RewardVault.StakerReward memory stakerRewardBefore =
      s_rewardVault.getStoredReward(COMMUNITY_STAKER_ONE);

    s_rewardVault.updateReward(COMMUNITY_STAKER_ONE, COMMUNITY_MIN_PRINCIPAL);

    RewardVault.RewardBuckets memory bucketsAfter = s_rewardVault.getRewardBuckets();
    RewardVault.StakerReward memory stakerRewardAfter =
      s_rewardVault.getStoredReward(COMMUNITY_STAKER_ONE);

    assertEq(
      stakerRewardAfter.storedBaseReward,
      stakerRewardBefore.storedBaseReward
        + _calculateAccruedReward(
          stakerPrincipal,
          stakerRewardBefore.baseRewardPerToken,
          bucketsAfter.communityBase.vestedRewardPerToken
        )
    );
  }

  function test_DoesNotUpdateStakerFinalizedReward() public {
    changePrank(address(s_communityStakingPool));

    RewardVault.StakerReward memory stakerRewardBefore =
      s_rewardVault.getStoredReward(COMMUNITY_STAKER_ONE);
    assertEq(stakerRewardBefore.finalizedDelegatedReward, 0);

    s_rewardVault.updateReward(COMMUNITY_STAKER_ONE, COMMUNITY_MIN_PRINCIPAL);

    RewardVault.StakerReward memory stakerRewardAfter =
      s_rewardVault.getStoredReward(COMMUNITY_STAKER_ONE);

    assertEq(stakerRewardAfter.finalizedBaseReward, stakerRewardBefore.finalizedBaseReward);
    assertEq(
      stakerRewardAfter.finalizedDelegatedReward, stakerRewardBefore.finalizedDelegatedReward
    );
  }

  function test_UpdatesStakerBaseRewardPerToken() public {
    changePrank(address(s_communityStakingPool));

    s_rewardVault.updateReward(COMMUNITY_STAKER_ONE, COMMUNITY_MIN_PRINCIPAL);

    RewardVault.RewardBuckets memory bucketsAfter = s_rewardVault.getRewardBuckets();
    RewardVault.StakerReward memory stakerRewardAfter =
      s_rewardVault.getStoredReward(COMMUNITY_STAKER_ONE);

    assertEq(stakerRewardAfter.baseRewardPerToken, bucketsAfter.communityBase.vestedRewardPerToken);
  }

  function test_DoesNotUpdateStakerDelegatedRewardPerToken() public {
    changePrank(address(s_communityStakingPool));

    RewardVault.StakerReward memory stakerRewardBefore =
      s_rewardVault.getStoredReward(COMMUNITY_STAKER_ONE);

    s_rewardVault.updateReward(COMMUNITY_STAKER_ONE, COMMUNITY_MIN_PRINCIPAL);

    RewardVault.StakerReward memory stakerRewardAfter =
      s_rewardVault.getStoredReward(COMMUNITY_STAKER_ONE);

    assertEq(
      stakerRewardAfter.operatorDelegatedRewardPerToken,
      stakerRewardBefore.operatorDelegatedRewardPerToken
    );
  }
}

contract RewardVault_UpdateReward_UpdatePoolsAndStakerWhenCalledForOperator is
  IRewardVault_UpdateReward_UpdatePoolsAndOperatorWhenRewardAccrued,
  RewardVault_WithStakersAndTimePassed
{
  function test_UpdatesVestedRewardPerTokens() public {
    changePrank(address(s_operatorStakingPool));
    uint256 rewardPerTokenUpdatedAtBefore = s_rewardVault.getRewardPerTokenUpdatedAt();
    uint256 communityTotalPrincipalBefore = s_communityStakingPool.getTotalPrincipal();
    uint256 operatorTotalPrincipalBefore = s_operatorStakingPool.getTotalPrincipal();
    RewardVault.RewardBuckets memory bucketsBefore = s_rewardVault.getRewardBuckets();

    s_rewardVault.updateReward(OPERATOR_STAKER_ONE, OPERATOR_MIN_PRINCIPAL);

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

    // total available reward amount until now
    assertEq(
      bucketsAfter.communityBase.vestedRewardPerToken * communityTotalPrincipalBefore,
      bucketsAfter.communityBase.emissionRate * (block.timestamp - rewardAddedAt) * DECIMALS
    );
    assertEq(
      bucketsAfter.operatorBase.vestedRewardPerToken * operatorTotalPrincipalBefore,
      bucketsAfter.operatorBase.emissionRate * (block.timestamp - rewardAddedAt) * DECIMALS
    );
    assertEq(
      bucketsAfter.operatorDelegated.vestedRewardPerToken * operatorTotalPrincipalBefore,
      bucketsAfter.operatorDelegated.emissionRate * (block.timestamp - rewardAddedAt) * DECIMALS
    );
  }

  function test_UpdatesRewardPerTokenUpdatedAt() public {
    changePrank(address(s_operatorStakingPool));
    uint256 rewardPerTokenUpdatedAtBefore = s_rewardVault.getRewardPerTokenUpdatedAt();
    s_rewardVault.updateReward(OPERATOR_STAKER_ONE, OPERATOR_MIN_PRINCIPAL);
    assertEq(s_rewardVault.getRewardPerTokenUpdatedAt(), block.timestamp);
    assertGt(s_rewardVault.getRewardPerTokenUpdatedAt(), rewardPerTokenUpdatedAtBefore);
  }

  function test_UpdatesStakerStoredReward() public {
    changePrank(address(s_operatorStakingPool));

    uint256 stakerPrincipal = s_operatorStakingPool.getStakerPrincipal(OPERATOR_STAKER_ONE);
    RewardVault.StakerReward memory stakerRewardBefore =
      s_rewardVault.getStoredReward(OPERATOR_STAKER_ONE);

    s_rewardVault.updateReward(OPERATOR_STAKER_ONE, OPERATOR_MIN_PRINCIPAL);

    RewardVault.RewardBuckets memory bucketsAfter = s_rewardVault.getRewardBuckets();
    RewardVault.StakerReward memory stakerRewardAfter =
      s_rewardVault.getStoredReward(OPERATOR_STAKER_ONE);

    assertEq(
      stakerRewardAfter.storedBaseReward,
      stakerRewardBefore.storedBaseReward
        + _calculateAccruedReward(
          stakerPrincipal,
          stakerRewardBefore.baseRewardPerToken,
          bucketsAfter.operatorBase.vestedRewardPerToken
        )
    );
  }

  function test_UpdatesStakerFinalizedReward() public {
    changePrank(address(s_operatorStakingPool));

    uint256 stakerPrincipal = s_operatorStakingPool.getStakerPrincipal(OPERATOR_STAKER_ONE);
    RewardVault.StakerReward memory stakerRewardBefore =
      s_rewardVault.getStoredReward(OPERATOR_STAKER_ONE);

    s_rewardVault.updateReward(OPERATOR_STAKER_ONE, OPERATOR_MIN_PRINCIPAL);

    RewardVault.RewardBuckets memory bucketsAfter = s_rewardVault.getRewardBuckets();
    RewardVault.StakerReward memory stakerRewardAfter =
      s_rewardVault.getStoredReward(OPERATOR_STAKER_ONE);

    // base rewards are not yet finalized
    assertEq(stakerRewardAfter.finalizedBaseReward, 0);
    assertEq(
      stakerRewardAfter.finalizedDelegatedReward,
      stakerRewardBefore.finalizedDelegatedReward
        + _calculateAccruedReward(
          stakerPrincipal,
          stakerRewardBefore.operatorDelegatedRewardPerToken,
          bucketsAfter.operatorDelegated.vestedRewardPerToken
        )
    );
  }

  function test_UpdatesStakerBaseRewardPerToken() public {
    changePrank(address(s_operatorStakingPool));

    s_rewardVault.updateReward(OPERATOR_STAKER_ONE, OPERATOR_MIN_PRINCIPAL);

    RewardVault.RewardBuckets memory bucketsAfter = s_rewardVault.getRewardBuckets();
    RewardVault.StakerReward memory stakerRewardAfter =
      s_rewardVault.getStoredReward(OPERATOR_STAKER_ONE);

    assertEq(stakerRewardAfter.baseRewardPerToken, bucketsAfter.operatorBase.vestedRewardPerToken);
  }

  function test_UpdatesStakerDelegatedRewardPerToken() public {
    changePrank(address(s_operatorStakingPool));

    s_rewardVault.updateReward(OPERATOR_STAKER_ONE, OPERATOR_MIN_PRINCIPAL);

    RewardVault.RewardBuckets memory bucketsAfter = s_rewardVault.getRewardBuckets();
    RewardVault.StakerReward memory stakerRewardAfter =
      s_rewardVault.getStoredReward(OPERATOR_STAKER_ONE);

    assertEq(
      stakerRewardAfter.operatorDelegatedRewardPerToken,
      bucketsAfter.operatorDelegated.vestedRewardPerToken
    );
  }
}

contract RewardVault_UpdateReward_UpdatePoolsAndStakerWhenCommunityStakerClaimsReward is
  IRewardVault_UpdateReward_UpdatePoolsAndCommunityStakerWhenRewardAccrued,
  RewardVault_WithStakersAndTimePassed
{
  function test_UpdatesVestedRewardPerTokens() public {
    uint256 rewardPerTokenUpdatedAtBefore = s_rewardVault.getRewardPerTokenUpdatedAt();
    uint256 communityTotalPrincipalBefore = s_communityStakingPool.getTotalPrincipal();
    uint256 operatorTotalPrincipalBefore = s_operatorStakingPool.getTotalPrincipal();
    RewardVault.RewardBuckets memory bucketsBefore = s_rewardVault.getRewardBuckets();
    changePrank(COMMUNITY_STAKER_ONE);
    s_rewardVault.claimReward();

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

    // total available reward amount until now
    assertEq(
      bucketsAfter.communityBase.vestedRewardPerToken * communityTotalPrincipalBefore / DECIMALS,
      bucketsAfter.communityBase.emissionRate * (block.timestamp - rewardAddedAt)
    );
    assertEq(
      bucketsAfter.operatorBase.vestedRewardPerToken * operatorTotalPrincipalBefore / DECIMALS,
      bucketsAfter.operatorBase.emissionRate * (block.timestamp - rewardAddedAt)
    );
    assertEq(
      bucketsAfter.operatorDelegated.vestedRewardPerToken * operatorTotalPrincipalBefore / DECIMALS,
      bucketsAfter.operatorDelegated.emissionRate * (block.timestamp - rewardAddedAt)
    );
  }

  function test_UpdatesRewardPerTokenUpdatedAt() public {
    changePrank(COMMUNITY_STAKER_ONE);
    assertLt(s_rewardVault.getRewardPerTokenUpdatedAt(), block.timestamp);
    s_rewardVault.claimReward();
    assertEq(s_rewardVault.getRewardPerTokenUpdatedAt(), block.timestamp);
  }

  function test_ResetsClaimReward() public {
    changePrank(COMMUNITY_STAKER_ONE);
    s_rewardVault.claimReward();
    assertEq(s_rewardVault.getReward(COMMUNITY_STAKER_ONE), 0);
  }

  function test_UpdatesStakerStoredReward() public {
    changePrank(COMMUNITY_STAKER_ONE);

    s_rewardVault.claimReward();

    RewardVault.StakerReward memory stakerRewardAfter =
      s_rewardVault.getStoredReward(COMMUNITY_STAKER_ONE);

    uint256 fullReward = _calculateStakerExpectedReward(
      COMMUNITY_MIN_PRINCIPAL,
      4 * COMMUNITY_MIN_PRINCIPAL,
      _calculateBucketVestedRewards(
        s_rewardVault.getRewardBuckets().communityBase, s_stakedAtTime, block.timestamp
      )
    );
    uint256 multiplier =
      _calculateStakerMultiplier(s_stakedAtTime, block.timestamp, INITIAL_MULTIPLIER_DURATION);

    uint256 unclaimableRewards = fullReward - multiplier * fullReward / FixedPointMathLib.WAD;

    assertEq(stakerRewardAfter.storedBaseReward, unclaimableRewards);
  }

  function test_UpdatesStakerFinalizedReward() public {
    changePrank(COMMUNITY_STAKER_ONE);

    s_rewardVault.claimReward();

    RewardVault.StakerReward memory stakerRewardAfter =
      s_rewardVault.getStoredReward(COMMUNITY_STAKER_ONE);

    assertEq(stakerRewardAfter.finalizedBaseReward, 0);
    assertEq(stakerRewardAfter.finalizedDelegatedReward, 0);
  }

  function test_UpdatesStakerBaseRewardPerToken() public {
    changePrank(COMMUNITY_STAKER_ONE);

    s_rewardVault.claimReward();

    RewardVault.RewardBuckets memory bucketsAfter = s_rewardVault.getRewardBuckets();
    RewardVault.StakerReward memory stakerRewardAfter =
      s_rewardVault.getStoredReward(COMMUNITY_STAKER_ONE);

    assertEq(stakerRewardAfter.baseRewardPerToken, bucketsAfter.communityBase.vestedRewardPerToken);
  }
}

contract RewardVault_UpdateReward_UpdatePoolsAndStakerWhenOperatorClaimsReward is
  IRewardVault_UpdateReward_UpdatePoolsAndOperatorWhenRewardAccrued,
  RewardVault_WithStakersAndTimePassed
{
  function test_UpdatesVestedRewardPerTokens() public {
    uint256 rewardPerTokenUpdatedAtBefore = s_rewardVault.getRewardPerTokenUpdatedAt();
    uint256 communityTotalPrincipalBefore = s_communityStakingPool.getTotalPrincipal();
    uint256 operatorTotalPrincipalBefore = s_operatorStakingPool.getTotalPrincipal();
    RewardVault.RewardBuckets memory bucketsBefore = s_rewardVault.getRewardBuckets();

    changePrank(OPERATOR_STAKER_ONE);
    s_rewardVault.claimReward();

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

    // total available reward amount until now
    assertEq(
      bucketsAfter.communityBase.vestedRewardPerToken * communityTotalPrincipalBefore / DECIMALS,
      bucketsAfter.communityBase.emissionRate * (block.timestamp - rewardAddedAt)
    );
    assertEq(
      (bucketsAfter.operatorBase.vestedRewardPerToken * operatorTotalPrincipalBefore / DECIMALS),
      bucketsAfter.operatorBase.emissionRate * (block.timestamp - rewardAddedAt)
    );
    assertEq(
      bucketsAfter.operatorDelegated.vestedRewardPerToken * operatorTotalPrincipalBefore / DECIMALS,
      bucketsAfter.operatorDelegated.emissionRate * (block.timestamp - rewardAddedAt)
    );
  }

  function test_UpdatesRewardPerTokenUpdatedAt() public {
    changePrank(OPERATOR_STAKER_ONE);
    assertLt(s_rewardVault.getRewardPerTokenUpdatedAt(), block.timestamp);
    s_rewardVault.claimReward();
    assertEq(s_rewardVault.getRewardPerTokenUpdatedAt(), block.timestamp);
  }

  function test_UpdatesStakerStoredReward() public {
    changePrank(OPERATOR_STAKER_ONE);

    s_rewardVault.claimReward();

    RewardVault.StakerReward memory stakerRewardAfter =
      s_rewardVault.getStoredReward(OPERATOR_STAKER_ONE);

    uint256 fullReward = _calculateStakerExpectedReward(
      OPERATOR_MIN_PRINCIPAL,
      4 * OPERATOR_MIN_PRINCIPAL,
      _calculateBucketVestedRewards(
        s_rewardVault.getRewardBuckets().operatorBase, s_stakedAtTime, block.timestamp
      )
    );
    uint256 multiplier =
      _calculateStakerMultiplier(s_stakedAtTime, block.timestamp, INITIAL_MULTIPLIER_DURATION);

    uint256 unclaimableRewards = fullReward - multiplier * fullReward / FixedPointMathLib.WAD;

    assertEq(stakerRewardAfter.storedBaseReward, unclaimableRewards);
  }

  function test_UpdatesStakerFinalizedReward() public {
    changePrank(OPERATOR_STAKER_ONE);

    s_rewardVault.claimReward();

    RewardVault.StakerReward memory stakerRewardAfter =
      s_rewardVault.getStoredReward(OPERATOR_STAKER_ONE);

    assertEq(stakerRewardAfter.finalizedBaseReward, 0);
    assertEq(stakerRewardAfter.finalizedDelegatedReward, 0);
  }

  function test_UpdatesStakerBaseRewardPerToken() public {
    changePrank(OPERATOR_STAKER_ONE);

    s_rewardVault.claimReward();

    RewardVault.RewardBuckets memory bucketsAfter = s_rewardVault.getRewardBuckets();
    RewardVault.StakerReward memory stakerRewardAfter =
      s_rewardVault.getStoredReward(OPERATOR_STAKER_ONE);

    assertEq(stakerRewardAfter.baseRewardPerToken, bucketsAfter.operatorBase.vestedRewardPerToken);
  }

  function test_UpdatesStakerDelegatedRewardPerToken() public {
    changePrank(OPERATOR_STAKER_ONE);

    s_rewardVault.claimReward();

    RewardVault.RewardBuckets memory bucketsAfter = s_rewardVault.getRewardBuckets();
    RewardVault.StakerReward memory stakerRewardAfter =
      s_rewardVault.getStoredReward(OPERATOR_STAKER_ONE);

    assertEq(
      stakerRewardAfter.operatorDelegatedRewardPerToken,
      bucketsAfter.operatorDelegated.vestedRewardPerToken
    );
  }
}

contract RewardVault_UpdateReward_UpdatePoolsAndStakerWhenCSPoolTotalPrincipalIncreases is
  IRewardVault_UpdateReward_UpdatePoolsAndCommunityStakerWhenRewardAccrued,
  RewardVault_WithStakersAndTimePassed
{
  function test_UpdatesVestedRewardPerTokens() public {
    uint256 rewardPerTokenUpdatedAtBefore = s_rewardVault.getRewardPerTokenUpdatedAt();
    uint256 communityTotalPrincipalBefore = s_communityStakingPool.getTotalPrincipal();
    uint256 operatorTotalPrincipalBefore = s_operatorStakingPool.getTotalPrincipal();
    RewardVault.RewardBuckets memory bucketsBefore = s_rewardVault.getRewardBuckets();

    changePrank(COMMUNITY_STAKER_ONE);
    s_LINK.transferAndCall(
      address(s_communityStakingPool),
      COMMUNITY_MIN_PRINCIPAL,
      abi.encode(s_communityStakerOneProof)
    );

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

    // total available reward amount until now
    assertEq(
      bucketsAfter.communityBase.vestedRewardPerToken * communityTotalPrincipalBefore,
      bucketsAfter.communityBase.emissionRate * (block.timestamp - rewardAddedAt) * DECIMALS
    );
    assertEq(
      bucketsAfter.operatorBase.vestedRewardPerToken * operatorTotalPrincipalBefore,
      bucketsAfter.operatorBase.emissionRate * (block.timestamp - rewardAddedAt) * DECIMALS
    );
    assertEq(
      bucketsAfter.operatorDelegated.vestedRewardPerToken * operatorTotalPrincipalBefore,
      bucketsAfter.operatorDelegated.emissionRate * (block.timestamp - rewardAddedAt) * DECIMALS
    );
  }

  function test_UpdatesRewardPerTokenUpdatedAt() public {
    changePrank(COMMUNITY_STAKER_ONE);
    assertLt(s_rewardVault.getRewardPerTokenUpdatedAt(), block.timestamp);
    s_LINK.transferAndCall(
      address(s_communityStakingPool),
      COMMUNITY_MIN_PRINCIPAL,
      abi.encode(s_communityStakerOneProof)
    );
    assertEq(s_rewardVault.getRewardPerTokenUpdatedAt(), block.timestamp);
  }

  function test_UpdatesStakerStoredReward() public {
    changePrank(COMMUNITY_STAKER_ONE);

    s_LINK.transferAndCall(
      address(s_communityStakingPool),
      COMMUNITY_MIN_PRINCIPAL,
      abi.encode(s_communityStakerOneProof)
    );
    RewardVault.StakerReward memory stakerRewardAfter =
      s_rewardVault.getStoredReward(COMMUNITY_STAKER_ONE);

    uint256 fullReward = _calculateStakerExpectedReward(
      COMMUNITY_MIN_PRINCIPAL,
      4 * COMMUNITY_MIN_PRINCIPAL,
      _calculateBucketVestedRewards(
        s_rewardVault.getRewardBuckets().communityBase, s_stakedAtTime, block.timestamp
      )
    );
    uint256 multiplier =
      _calculateStakerMultiplier(s_stakedAtTime, block.timestamp, INITIAL_MULTIPLIER_DURATION);

    uint256 unclaimableRewards = fullReward - multiplier * fullReward / FixedPointMathLib.WAD;

    assertEq(stakerRewardAfter.storedBaseReward, unclaimableRewards);
  }

  function test_UpdatesStakerBaseRewardPerToken() public {
    changePrank(COMMUNITY_STAKER_ONE);

    s_LINK.transferAndCall(
      address(s_communityStakingPool),
      COMMUNITY_MIN_PRINCIPAL,
      abi.encode(s_communityStakerOneProof)
    );

    RewardVault.RewardBuckets memory bucketsAfter = s_rewardVault.getRewardBuckets();
    RewardVault.StakerReward memory stakerRewardAfter =
      s_rewardVault.getStoredReward(COMMUNITY_STAKER_ONE);

    assertEq(stakerRewardAfter.baseRewardPerToken, bucketsAfter.communityBase.vestedRewardPerToken);
  }
}

contract RewardVault_UpdateReward_UpdatePoolsAndStakerWhenOperatorPoolTotalPrincipalIncreases is
  IRewardVault_UpdateReward_UpdatePoolsAndOperatorWhenRewardAccrued,
  RewardVault_WithStakersAndTimePassed
{
  function test_UpdatesVestedRewardPerTokens() public {
    uint256 rewardPerTokenUpdatedAtBefore = s_rewardVault.getRewardPerTokenUpdatedAt();
    uint256 communityTotalPrincipalBefore = s_communityStakingPool.getTotalPrincipal();
    uint256 operatorTotalPrincipalBefore = s_operatorStakingPool.getTotalPrincipal();
    RewardVault.RewardBuckets memory bucketsBefore = s_rewardVault.getRewardBuckets();

    changePrank(OPERATOR_STAKER_ONE);
    s_LINK.transferAndCall(
      address(s_operatorStakingPool), OPERATOR_MIN_PRINCIPAL, abi.encode(OPERATOR_STAKER_ONE, '')
    );

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

    // total available reward amount until now
    assertEq(
      bucketsAfter.communityBase.vestedRewardPerToken * communityTotalPrincipalBefore,
      bucketsAfter.communityBase.emissionRate * (block.timestamp - rewardAddedAt) * DECIMALS
    );
    assertEq(
      bucketsAfter.operatorBase.vestedRewardPerToken * operatorTotalPrincipalBefore,
      bucketsAfter.operatorBase.emissionRate * (block.timestamp - rewardAddedAt) * DECIMALS
    );
    assertEq(
      bucketsAfter.operatorDelegated.vestedRewardPerToken * operatorTotalPrincipalBefore,
      bucketsAfter.operatorDelegated.emissionRate * (block.timestamp - rewardAddedAt) * DECIMALS
    );
  }

  function test_UpdatesRewardPerTokenUpdatedAt() public {
    changePrank(OPERATOR_STAKER_ONE);
    assertLt(s_rewardVault.getRewardPerTokenUpdatedAt(), block.timestamp);
    s_LINK.transferAndCall(
      address(s_operatorStakingPool), OPERATOR_MIN_PRINCIPAL, abi.encode(OPERATOR_STAKER_ONE, '')
    );
    assertEq(s_rewardVault.getRewardPerTokenUpdatedAt(), block.timestamp);
  }

  function test_UpdatesStakerStoredReward() public {
    changePrank(OPERATOR_STAKER_ONE);

    s_LINK.transferAndCall(
      address(s_operatorStakingPool), OPERATOR_MIN_PRINCIPAL, abi.encode(OPERATOR_STAKER_ONE, '')
    );

    RewardVault.StakerReward memory stakerRewardAfter =
      s_rewardVault.getStoredReward(OPERATOR_STAKER_ONE);

    uint256 fullReward = _calculateStakerExpectedReward(
      OPERATOR_MIN_PRINCIPAL,
      4 * OPERATOR_MIN_PRINCIPAL,
      _calculateBucketVestedRewards(
        s_rewardVault.getRewardBuckets().operatorBase, s_stakedAtTime, block.timestamp
      )
    );
    uint256 multiplier =
      _calculateStakerMultiplier(s_stakedAtTime, block.timestamp, INITIAL_MULTIPLIER_DURATION);

    uint256 unclaimableRewards = fullReward - multiplier * fullReward / FixedPointMathLib.WAD;

    assertEq(stakerRewardAfter.storedBaseReward, unclaimableRewards);
  }

  function test_UpdatesStakerFinalizedReward() public {
    changePrank(OPERATOR_STAKER_ONE);

    uint256 stakerPrincipal = s_operatorStakingPool.getStakerPrincipal(OPERATOR_STAKER_ONE);
    RewardVault.StakerReward memory stakerRewardBefore =
      s_rewardVault.getStoredReward(OPERATOR_STAKER_ONE);

    uint256 stakerMultiplier = s_rewardVault.getMultiplier(OPERATOR_STAKER_ONE);

    s_LINK.transferAndCall(
      address(s_operatorStakingPool), OPERATOR_MIN_PRINCIPAL, abi.encode(OPERATOR_STAKER_ONE, '')
    );

    RewardVault.RewardBuckets memory bucketsAfter = s_rewardVault.getRewardBuckets();
    RewardVault.StakerReward memory stakerRewardAfter =
      s_rewardVault.getStoredReward(OPERATOR_STAKER_ONE);

    assertEq(
      stakerRewardAfter.finalizedBaseReward,
      stakerRewardBefore.finalizedBaseReward
        + _calculateAccruedReward(
          stakerPrincipal,
          stakerRewardBefore.baseRewardPerToken,
          bucketsAfter.operatorBase.vestedRewardPerToken
        ) * stakerMultiplier / FixedPointMathLib.WAD
    );
    assertEq(
      stakerRewardAfter.finalizedDelegatedReward,
      stakerRewardBefore.finalizedDelegatedReward
        + _calculateAccruedReward(
          stakerPrincipal,
          stakerRewardBefore.operatorDelegatedRewardPerToken,
          bucketsAfter.operatorDelegated.vestedRewardPerToken
        )
    );
  }

  function test_UpdatesStakerBaseRewardPerToken() public {
    changePrank(OPERATOR_STAKER_ONE);

    s_LINK.transferAndCall(
      address(s_operatorStakingPool), OPERATOR_MIN_PRINCIPAL, abi.encode(OPERATOR_STAKER_ONE, '')
    );

    RewardVault.RewardBuckets memory bucketsAfter = s_rewardVault.getRewardBuckets();
    RewardVault.StakerReward memory stakerRewardAfter =
      s_rewardVault.getStoredReward(OPERATOR_STAKER_ONE);

    assertEq(stakerRewardAfter.baseRewardPerToken, bucketsAfter.operatorBase.vestedRewardPerToken);
  }

  function test_UpdatesStakerDelegatedRewardPerToken() public {
    changePrank(OPERATOR_STAKER_ONE);

    s_LINK.transferAndCall(
      address(s_operatorStakingPool), OPERATOR_MIN_PRINCIPAL, abi.encode(OPERATOR_STAKER_ONE, '')
    );

    RewardVault.RewardBuckets memory bucketsAfter = s_rewardVault.getRewardBuckets();
    RewardVault.StakerReward memory stakerRewardAfter =
      s_rewardVault.getStoredReward(OPERATOR_STAKER_ONE);

    assertEq(
      stakerRewardAfter.operatorDelegatedRewardPerToken,
      bucketsAfter.operatorDelegated.vestedRewardPerToken
    );
  }
}

contract RewardVault_UpdateReward_UpdatePoolsAndStakerWhenCSPoolTotalPrincipalDecreases is
  IRewardVault_UpdateReward_UpdatePoolsAndCommunityStakerWhenRewardAccrued,
  RewardVault_InClaimPeriod
{
  function test_UpdatesVestedRewardPerTokens() public {
    uint256 rewardPerTokenUpdatedAtBefore = s_rewardVault.getRewardPerTokenUpdatedAt();
    uint256 communityTotalPrincipalBefore = s_communityStakingPool.getTotalPrincipal();
    uint256 operatorTotalPrincipalBefore = s_operatorStakingPool.getTotalPrincipal();
    RewardVault.RewardBuckets memory bucketsBefore = s_rewardVault.getRewardBuckets();
    ForfeitedRewardDistribution memory distribution = _calculateForfeitedRewardDistribution({
      staker: COMMUNITY_STAKER_ONE,
      isOperator: false,
      isPrincipalDecreased: true
    });
    changePrank(COMMUNITY_STAKER_ONE);
    s_communityStakingPool.unstake(COMMUNITY_MIN_PRINCIPAL, false);

    RewardVault.RewardBuckets memory bucketsAfter = s_rewardVault.getRewardBuckets();

    uint256 communityBaseRewardPerTokenBefore = _calculateVestedRewardPerToken(
      bucketsBefore.communityBase.vestedRewardPerToken,
      bucketsBefore.communityBase.rewardDurationEndsAt,
      rewardPerTokenUpdatedAtBefore,
      bucketsBefore.communityBase.emissionRate,
      communityTotalPrincipalBefore,
      block.timestamp
    );
    uint256 communityTotalPrincipalAfter = s_communityStakingPool.getTotalPrincipal();
    assertEq(
      bucketsAfter.communityBase.vestedRewardPerToken,
      communityBaseRewardPerTokenBefore + distribution.vestedRewardPerToken
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

    // total available reward amount until now
    assertEq(
      (
        (
          communityBaseRewardPerTokenBefore * communityTotalPrincipalBefore
            + (bucketsAfter.communityBase.vestedRewardPerToken - communityBaseRewardPerTokenBefore)
              * communityTotalPrincipalAfter
        ) / DECIMALS
      ),
      bucketsAfter.communityBase.emissionRate * (block.timestamp - rewardAddedAt)
        + (distribution.vestedRewardPerToken * communityTotalPrincipalAfter / DECIMALS)
    );
    assertEq(
      bucketsAfter.operatorBase.vestedRewardPerToken * operatorTotalPrincipalBefore / DECIMALS,
      bucketsAfter.operatorBase.emissionRate * (block.timestamp - rewardAddedAt)
    );
    assertEq(
      bucketsAfter.operatorDelegated.vestedRewardPerToken * operatorTotalPrincipalBefore / DECIMALS,
      bucketsAfter.operatorDelegated.emissionRate * (block.timestamp - rewardAddedAt)
    );
  }

  function test_UpdatesRewardPerTokenUpdatedAt() public {
    changePrank(COMMUNITY_STAKER_ONE);
    assertLt(s_rewardVault.getRewardPerTokenUpdatedAt(), block.timestamp);
    s_communityStakingPool.unstake(COMMUNITY_MIN_PRINCIPAL, false);
    assertEq(s_rewardVault.getRewardPerTokenUpdatedAt(), block.timestamp);
  }

  function test_UpdatesStakerStoredReward() public {
    changePrank(address(s_communityStakingPool));
    s_rewardVault.updateReward(COMMUNITY_STAKER_ONE, COMMUNITY_MIN_PRINCIPAL);

    changePrank(COMMUNITY_STAKER_ONE);

    RewardVault.StakerReward memory stakerRewardBefore =
      s_rewardVault.getStoredReward(COMMUNITY_STAKER_ONE);
    assertGt(stakerRewardBefore.storedBaseReward, 0);

    s_communityStakingPool.unstake(COMMUNITY_MIN_PRINCIPAL, false);

    RewardVault.StakerReward memory stakerRewardAfter =
      s_rewardVault.getStoredReward(COMMUNITY_STAKER_ONE);

    assertEq(stakerRewardAfter.storedBaseReward, 0);
  }

  function test_UpdatesStakerFinalizedReward() public {
    changePrank(COMMUNITY_STAKER_ONE);

    uint256 stakerPrincipal = s_communityStakingPool.getStakerPrincipal(COMMUNITY_STAKER_ONE);
    uint256 multiplier = s_rewardVault.getMultiplier(COMMUNITY_STAKER_ONE);
    RewardVault.StakerReward memory stakerRewardBefore =
      s_rewardVault.getStoredReward(COMMUNITY_STAKER_ONE);
    uint256 vestedRewardPerToken = _calculateVestedRewardPerToken(
      s_rewardVault.getRewardBuckets().communityBase.vestedRewardPerToken,
      s_rewardVault.getRewardBuckets().communityBase.rewardDurationEndsAt,
      s_rewardVault.getRewardPerTokenUpdatedAt(),
      s_rewardVault.getRewardBuckets().communityBase.emissionRate,
      s_communityStakingPool.getTotalPrincipal(),
      block.timestamp
    );
    uint256 accruedReward = _calculateAccruedReward(
      stakerPrincipal, stakerRewardBefore.baseRewardPerToken, vestedRewardPerToken
    );

    s_communityStakingPool.unstake(COMMUNITY_MIN_PRINCIPAL, false);
    RewardVault.StakerReward memory stakerRewardAfter =
      s_rewardVault.getStoredReward(COMMUNITY_STAKER_ONE);

    assertEq(
      stakerRewardAfter.finalizedBaseReward,
      (stakerRewardBefore.storedBaseReward + accruedReward) * multiplier / DECIMALS
    );
    assertEq(
      stakerRewardAfter.finalizedDelegatedReward, stakerRewardBefore.finalizedDelegatedReward
    );
  }

  function test_UpdatesStakerBaseRewardPerToken() public {
    changePrank(COMMUNITY_STAKER_ONE);

    s_communityStakingPool.unstake(COMMUNITY_MIN_PRINCIPAL, false);

    RewardVault.RewardBuckets memory bucketsAfter = s_rewardVault.getRewardBuckets();
    RewardVault.StakerReward memory stakerRewardAfter =
      s_rewardVault.getStoredReward(COMMUNITY_STAKER_ONE);

    assertEq(stakerRewardAfter.baseRewardPerToken, bucketsAfter.communityBase.vestedRewardPerToken);
  }
}

contract RewardVault_UpdateReward_UpdatePoolsAndStakerWhenOperatorPoolTotalPrincipalDecreases is
  IRewardVault_UpdateReward_UpdatePoolsAndOperatorWhenRewardAccrued,
  RewardVault_InClaimPeriod
{
  function test_UpdatesVestedRewardPerTokens() public {
    uint256 rewardPerTokenUpdatedAtBefore = s_rewardVault.getRewardPerTokenUpdatedAt();
    uint256 communityTotalPrincipalBefore = s_communityStakingPool.getTotalPrincipal();
    uint256 operatorTotalPrincipalBefore = s_operatorStakingPool.getTotalPrincipal();
    RewardVault.RewardBuckets memory bucketsBefore = s_rewardVault.getRewardBuckets();
    ForfeitedRewardDistribution memory distribution = _calculateForfeitedRewardDistribution({
      staker: OPERATOR_STAKER_ONE,
      isOperator: true,
      isPrincipalDecreased: true
    });
    changePrank(OPERATOR_STAKER_ONE);
    s_operatorStakingPool.unstake(OPERATOR_MIN_PRINCIPAL, false);

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
    uint256 operatorBaseRewardPerTokenBefore = _calculateVestedRewardPerToken(
      bucketsBefore.operatorBase.vestedRewardPerToken,
      bucketsBefore.operatorBase.rewardDurationEndsAt,
      rewardPerTokenUpdatedAtBefore,
      bucketsBefore.operatorBase.emissionRate,
      operatorTotalPrincipalBefore,
      block.timestamp
    );
    uint256 operatorTotalPrincipalAfter = s_operatorStakingPool.getTotalPrincipal();
    assertEq(
      bucketsAfter.operatorBase.vestedRewardPerToken,
      operatorBaseRewardPerTokenBefore + distribution.vestedRewardPerToken
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
    // total available reward amount until now
    assertEq(
      bucketsAfter.communityBase.vestedRewardPerToken * communityTotalPrincipalBefore / DECIMALS,
      bucketsAfter.communityBase.emissionRate * (block.timestamp - rewardAddedAt)
    );
    assertEq(
      (
        (
          operatorBaseRewardPerTokenBefore * operatorTotalPrincipalBefore
            + (bucketsAfter.operatorBase.vestedRewardPerToken - operatorBaseRewardPerTokenBefore)
              * operatorTotalPrincipalAfter
        ) / DECIMALS
      ),
      bucketsAfter.operatorBase.emissionRate * (block.timestamp - rewardAddedAt)
        + (distribution.vestedRewardPerToken * operatorTotalPrincipalAfter / DECIMALS)
    );
    assertEq(
      bucketsAfter.operatorDelegated.vestedRewardPerToken * operatorTotalPrincipalBefore / DECIMALS,
      bucketsAfter.operatorDelegated.emissionRate * (block.timestamp - rewardAddedAt)
    );
  }

  function test_UpdatesRewardPerTokenUpdatedAt() public {
    changePrank(OPERATOR_STAKER_ONE);
    assertLt(s_rewardVault.getRewardPerTokenUpdatedAt(), block.timestamp);
    s_operatorStakingPool.unstake(OPERATOR_MIN_PRINCIPAL, false);
    assertEq(s_rewardVault.getRewardPerTokenUpdatedAt(), block.timestamp);
  }

  function test_UpdatesStakerStoredReward() public {
    changePrank(address(s_operatorStakingPool));
    s_rewardVault.updateReward(OPERATOR_STAKER_ONE, OPERATOR_MIN_PRINCIPAL);

    changePrank(OPERATOR_STAKER_ONE);

    RewardVault.StakerReward memory stakerRewardBefore =
      s_rewardVault.getStoredReward(OPERATOR_STAKER_ONE);
    assertGt(stakerRewardBefore.storedBaseReward, 0);

    s_operatorStakingPool.unstake(OPERATOR_MIN_PRINCIPAL, false);

    RewardVault.StakerReward memory stakerRewardAfter =
      s_rewardVault.getStoredReward(OPERATOR_STAKER_ONE);
    assertEq(stakerRewardAfter.storedBaseReward, 0);
  }

  function test_UpdatesStakerFinalizedReward() public {
    changePrank(OPERATOR_STAKER_ONE);

    uint256 stakerPrincipal = s_operatorStakingPool.getStakerPrincipal(OPERATOR_STAKER_ONE);
    uint256 multiplier = s_rewardVault.getMultiplier(OPERATOR_STAKER_ONE);
    RewardVault.StakerReward memory stakerRewardBefore =
      s_rewardVault.getStoredReward(OPERATOR_STAKER_ONE);
    uint256 vestedBaseRewardPerToken = _calculateVestedRewardPerToken(
      s_rewardVault.getRewardBuckets().operatorBase.vestedRewardPerToken,
      s_rewardVault.getRewardBuckets().operatorBase.rewardDurationEndsAt,
      s_rewardVault.getRewardPerTokenUpdatedAt(),
      s_rewardVault.getRewardBuckets().operatorBase.emissionRate,
      s_operatorStakingPool.getTotalPrincipal(),
      block.timestamp
    );
    uint256 vestedDelegatedRewardPerToken = _calculateVestedRewardPerToken(
      s_rewardVault.getRewardBuckets().operatorDelegated.vestedRewardPerToken,
      s_rewardVault.getRewardBuckets().operatorDelegated.rewardDurationEndsAt,
      s_rewardVault.getRewardPerTokenUpdatedAt(),
      s_rewardVault.getRewardBuckets().operatorDelegated.emissionRate,
      s_operatorStakingPool.getTotalPrincipal(),
      block.timestamp
    );
    uint256 accruedBaseReward = _calculateAccruedReward(
      stakerPrincipal, stakerRewardBefore.baseRewardPerToken, vestedBaseRewardPerToken
    );
    uint256 accruedDelegatedReward = _calculateAccruedReward(
      stakerPrincipal,
      stakerRewardBefore.operatorDelegatedRewardPerToken,
      vestedDelegatedRewardPerToken
    );
    s_operatorStakingPool.unstake(OPERATOR_MIN_PRINCIPAL, false);

    RewardVault.StakerReward memory stakerRewardAfter =
      s_rewardVault.getStoredReward(OPERATOR_STAKER_ONE);

    assertEq(
      stakerRewardAfter.finalizedBaseReward,
      (stakerRewardBefore.storedBaseReward + accruedBaseReward) * multiplier / DECIMALS
    );
    assertEq(stakerRewardAfter.finalizedDelegatedReward, accruedDelegatedReward);
  }

  function test_UpdatesStakerBaseRewardPerToken() public {
    changePrank(OPERATOR_STAKER_ONE);

    s_operatorStakingPool.unstake(OPERATOR_MIN_PRINCIPAL, false);

    RewardVault.RewardBuckets memory bucketsAfter = s_rewardVault.getRewardBuckets();
    RewardVault.StakerReward memory stakerRewardAfter =
      s_rewardVault.getStoredReward(OPERATOR_STAKER_ONE);

    assertEq(stakerRewardAfter.baseRewardPerToken, bucketsAfter.operatorBase.vestedRewardPerToken);
  }

  function test_UpdatesStakerDelegatedRewardPerToken() public {
    changePrank(OPERATOR_STAKER_ONE);

    s_operatorStakingPool.unstake(OPERATOR_MIN_PRINCIPAL, false);

    RewardVault.RewardBuckets memory bucketsAfter = s_rewardVault.getRewardBuckets();
    RewardVault.StakerReward memory stakerRewardAfter =
      s_rewardVault.getStoredReward(OPERATOR_STAKER_ONE);

    assertEq(
      stakerRewardAfter.operatorDelegatedRewardPerToken,
      bucketsAfter.operatorDelegated.vestedRewardPerToken
    );
  }
}

contract RewardVault_UpdateReward_UpdatePoolsAndStakerWhenTimeDidNotPass is
  IRewardVault_UpdateReward_UpdatePoolsAndStakerWhenTimeDidNotPass,
  RewardVault_WithStakersAndTimeDidNotPass
{
  function test_DoesNotUpdateVestedRewardPerTokens() public {
    changePrank(address(s_communityStakingPool));
    RewardVault.RewardBuckets memory bucketsBefore = s_rewardVault.getRewardBuckets();

    // time didn't pass since the last `updateReward` call
    s_rewardVault.updateReward(COMMUNITY_STAKER_ONE, COMMUNITY_MIN_PRINCIPAL);

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

  function test_DoesNotUpdateRewardPerTokenUpdatedAt() public {
    changePrank(address(s_communityStakingPool));
    s_rewardVault.updateReward(COMMUNITY_STAKER_ONE, COMMUNITY_MIN_PRINCIPAL);
    uint256 rewardPerTokenUpdatedAtBefore = s_rewardVault.getRewardPerTokenUpdatedAt();
    // time didn't pass since the last `updateReward` call
    s_rewardVault.updateReward(COMMUNITY_STAKER_ONE, COMMUNITY_MIN_PRINCIPAL);
    assertEq(s_rewardVault.getRewardPerTokenUpdatedAt(), block.timestamp);
    assertEq(s_rewardVault.getRewardPerTokenUpdatedAt(), rewardPerTokenUpdatedAtBefore);
  }

  function test_DoesNotUpdateStakerStoredReward() public {
    changePrank(address(s_communityStakingPool));
    s_rewardVault.updateReward(COMMUNITY_STAKER_ONE, COMMUNITY_MIN_PRINCIPAL);

    RewardVault.StakerReward memory stakerRewardBefore =
      s_rewardVault.getStoredReward(COMMUNITY_STAKER_ONE);

    // time didn't pass since the last `updateReward` call
    s_rewardVault.updateReward(COMMUNITY_STAKER_ONE, COMMUNITY_MIN_PRINCIPAL);

    RewardVault.StakerReward memory stakerRewardAfter =
      s_rewardVault.getStoredReward(COMMUNITY_STAKER_ONE);

    assertEq(stakerRewardAfter.storedBaseReward, stakerRewardBefore.storedBaseReward);
  }

  function test_DoesNotUpdateStakerFinalizedReward() public {
    changePrank(address(s_communityStakingPool));
    s_rewardVault.updateReward(COMMUNITY_STAKER_ONE, COMMUNITY_MIN_PRINCIPAL);

    RewardVault.StakerReward memory stakerRewardBefore =
      s_rewardVault.getStoredReward(COMMUNITY_STAKER_ONE);

    // time didn't pass since the last `updateReward` call
    s_rewardVault.updateReward(COMMUNITY_STAKER_ONE, COMMUNITY_MIN_PRINCIPAL);

    RewardVault.StakerReward memory stakerRewardAfter =
      s_rewardVault.getStoredReward(COMMUNITY_STAKER_ONE);

    assertEq(stakerRewardAfter.finalizedBaseReward, stakerRewardBefore.finalizedBaseReward);
    assertEq(
      stakerRewardAfter.finalizedDelegatedReward, stakerRewardBefore.finalizedDelegatedReward
    );
  }

  function test_DoesNotUpdateStakerBaseRewardPerToken() public {
    changePrank(address(s_communityStakingPool));
    s_rewardVault.updateReward(COMMUNITY_STAKER_ONE, COMMUNITY_MIN_PRINCIPAL);

    RewardVault.StakerReward memory stakerRewardBefore =
      s_rewardVault.getStoredReward(COMMUNITY_STAKER_ONE);

    // time didn't pass since the last `updateReward` call
    s_rewardVault.updateReward(COMMUNITY_STAKER_ONE, COMMUNITY_MIN_PRINCIPAL);

    RewardVault.StakerReward memory stakerRewardAfter =
      s_rewardVault.getStoredReward(COMMUNITY_STAKER_ONE);

    assertEq(stakerRewardAfter.baseRewardPerToken, stakerRewardBefore.baseRewardPerToken);
  }

  function test_DoesNotUpdateStakerDelegatedRewardPerToken() public {
    changePrank(address(s_communityStakingPool));
    s_rewardVault.updateReward(COMMUNITY_STAKER_ONE, COMMUNITY_MIN_PRINCIPAL);

    RewardVault.StakerReward memory stakerRewardBefore =
      s_rewardVault.getStoredReward(COMMUNITY_STAKER_ONE);

    // time didn't pass since the last `updateReward` call
    s_rewardVault.updateReward(COMMUNITY_STAKER_ONE, COMMUNITY_MIN_PRINCIPAL);

    RewardVault.StakerReward memory stakerRewardAfter =
      s_rewardVault.getStoredReward(COMMUNITY_STAKER_ONE);

    assertEq(
      stakerRewardAfter.operatorDelegatedRewardPerToken,
      stakerRewardBefore.operatorDelegatedRewardPerToken
    );
  }
}

contract RewardVault_UpdateReward_UpdatePoolsAndStakerWhenOperatorsSlashed is
  IRewardVault_UpdateReward_UpdatePoolsAndOperatorWhenRewardAccrued,
  RewardVault_WithStakersAndTimePassed
{
  function test_UpdatesVestedRewardPerTokens() public {
    uint256 rewardPerTokenUpdatedAtBefore = s_rewardVault.getRewardPerTokenUpdatedAt();
    uint256 communityTotalPrincipalBefore = s_communityStakingPool.getTotalPrincipal();
    uint256 operatorTotalPrincipalBefore = s_operatorStakingPool.getTotalPrincipal();
    RewardVault.RewardBuckets memory bucketsBefore = s_rewardVault.getRewardBuckets();

    changePrank(address(s_pfAlertsController));
    s_operatorStakingPool.slashAndReward(
      _getSlashableOperators(), COMMUNITY_STAKER_ONE, FEED_SLASHABLE_AMOUNT, ALERTER_REWARD_AMOUNT
    );

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

    // total available reward amount until now
    assertEq(
      bucketsAfter.communityBase.vestedRewardPerToken * communityTotalPrincipalBefore,
      bucketsAfter.communityBase.emissionRate * (block.timestamp - rewardAddedAt) * DECIMALS
    );
    assertEq(
      bucketsAfter.operatorBase.vestedRewardPerToken * operatorTotalPrincipalBefore,
      bucketsAfter.operatorBase.emissionRate * (block.timestamp - rewardAddedAt) * DECIMALS
    );
    assertEq(
      bucketsAfter.operatorDelegated.vestedRewardPerToken * operatorTotalPrincipalBefore,
      bucketsAfter.operatorDelegated.emissionRate * (block.timestamp - rewardAddedAt) * DECIMALS
    );
  }

  function test_UpdatesRewardPerTokenUpdatedAt() public {
    changePrank(address(s_pfAlertsController));

    assertLt(s_rewardVault.getRewardPerTokenUpdatedAt(), block.timestamp);

    s_operatorStakingPool.slashAndReward(
      _getSlashableOperators(), COMMUNITY_STAKER_ONE, FEED_SLASHABLE_AMOUNT, ALERTER_REWARD_AMOUNT
    );

    assertEq(s_rewardVault.getRewardPerTokenUpdatedAt(), block.timestamp);
  }

  function test_UpdatesStakerStoredReward() public {
    changePrank(address(s_pfAlertsController));

    address[] memory slashableOperators = _getSlashableOperators();
    uint256[] memory principals = new uint256[](slashableOperators.length);
    RewardVault.StakerReward[] memory stakerRewardsBefore =
      new RewardVault.StakerReward[](slashableOperators.length);
    for (uint256 i; i < slashableOperators.length; ++i) {
      address operator = slashableOperators[i];
      principals[i] = s_operatorStakingPool.getStakerPrincipal(operator);
      stakerRewardsBefore[i] = s_rewardVault.getStoredReward(operator);
    }

    s_operatorStakingPool.slashAndReward(
      slashableOperators, COMMUNITY_STAKER_ONE, FEED_SLASHABLE_AMOUNT, ALERTER_REWARD_AMOUNT
    );

    RewardVault.RewardBuckets memory bucketsAfter = s_rewardVault.getRewardBuckets();
    for (uint256 i; i < slashableOperators.length; ++i) {
      address operator = slashableOperators[i];
      RewardVault.StakerReward memory stakerRewardAfter = s_rewardVault.getStoredReward(operator);

      assertEq(
        stakerRewardAfter.storedBaseReward,
        stakerRewardsBefore[i].storedBaseReward
          + _calculateAccruedReward(
            principals[i],
            stakerRewardsBefore[i].baseRewardPerToken,
            bucketsAfter.operatorBase.vestedRewardPerToken
          )
      );
    }
  }

  function test_UpdatesStakerFinalizedReward() public {
    changePrank(address(s_pfAlertsController));

    address[] memory slashableOperators = _getSlashableOperators();
    uint256[] memory principals = new uint256[](slashableOperators.length);
    RewardVault.StakerReward[] memory stakerRewardsBefore =
      new RewardVault.StakerReward[](slashableOperators.length);
    for (uint256 i; i < slashableOperators.length; ++i) {
      address operator = slashableOperators[i];
      principals[i] = s_operatorStakingPool.getStakerPrincipal(operator);
      stakerRewardsBefore[i] = s_rewardVault.getStoredReward(operator);
    }

    s_operatorStakingPool.slashAndReward(
      slashableOperators, COMMUNITY_STAKER_ONE, FEED_SLASHABLE_AMOUNT, ALERTER_REWARD_AMOUNT
    );

    RewardVault.RewardBuckets memory bucketsAfter = s_rewardVault.getRewardBuckets();
    for (uint256 i; i < slashableOperators.length; ++i) {
      address operator = slashableOperators[i];
      RewardVault.StakerReward memory stakerRewardAfter = s_rewardVault.getStoredReward(operator);

      assertEq(
        stakerRewardAfter.finalizedBaseReward + stakerRewardAfter.finalizedDelegatedReward,
        stakerRewardsBefore[i].finalizedBaseReward + stakerRewardsBefore[i].finalizedDelegatedReward
          + _calculateAccruedReward(
            principals[i],
            stakerRewardsBefore[i].operatorDelegatedRewardPerToken,
            bucketsAfter.operatorDelegated.vestedRewardPerToken
          )
      );
    }
  }

  function test_UpdatesStakerBaseRewardPerToken() public {
    changePrank(address(s_pfAlertsController));

    address[] memory slashableOperators = _getSlashableOperators();

    s_operatorStakingPool.slashAndReward(
      slashableOperators, COMMUNITY_STAKER_ONE, FEED_SLASHABLE_AMOUNT, ALERTER_REWARD_AMOUNT
    );

    RewardVault.RewardBuckets memory bucketsAfter = s_rewardVault.getRewardBuckets();
    for (uint256 i; i < slashableOperators.length; ++i) {
      address operator = slashableOperators[i];
      RewardVault.StakerReward memory stakerRewardAfter = s_rewardVault.getStoredReward(operator);

      assertEq(stakerRewardAfter.baseRewardPerToken, bucketsAfter.operatorBase.vestedRewardPerToken);
    }
  }

  function test_UpdatesStakerDelegatedRewardPerToken() public {
    changePrank(address(s_pfAlertsController));

    address[] memory slashableOperators = _getSlashableOperators();

    s_operatorStakingPool.slashAndReward(
      slashableOperators, COMMUNITY_STAKER_ONE, FEED_SLASHABLE_AMOUNT, ALERTER_REWARD_AMOUNT
    );

    RewardVault.RewardBuckets memory bucketsAfter = s_rewardVault.getRewardBuckets();
    for (uint256 i; i < slashableOperators.length; ++i) {
      address operator = slashableOperators[i];
      RewardVault.StakerReward memory stakerRewardAfter = s_rewardVault.getStoredReward(operator);

      assertEq(
        stakerRewardAfter.operatorDelegatedRewardPerToken,
        bucketsAfter.operatorDelegated.vestedRewardPerToken
      );
    }
  }
}
