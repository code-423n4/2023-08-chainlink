// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {FixedPointMathLib} from '@solmate/utils/FixedPointMathLib.sol';

import {BaseTest} from '../../BaseTest.t.sol';
import {
  RewardVault_ConfigurablePoolSizes_DelegationDenominatorIsZero,
  RewardVault_ConfigurablePoolSizes_DelegationDenominatorNotZero,
  RewardVault_DelegationDenominatorIsZero,
  RewardVault_WhenPaused,
  RewardVault_WhenVaultClosed,
  RewardVault_WithStakersAndTimePassed
} from '../../base-scenarios/RewardVaultScenarios.t.sol';
import {
  IRewardVault_AddReward_UpdateBucket,
  IRewardVault_UpdateReward_UpdateOnlyPoolsWhenRewardAccrued
} from '../../interfaces/IRewardVaultTest.t.sol';
import {RewardVault} from '../../../src/rewards/RewardVault.sol';

contract RewardVault_AddReward is BaseTest {
  function test_RevertWhen_InvalidPoolAddress() public {
    changePrank(REWARDER);
    vm.expectRevert(abi.encodeWithSelector(RewardVault.InvalidPool.selector));
    s_rewardVault.addReward(STRANGER, REWARD_AMOUNT, EMISSION_RATE);
  }

  function test_RevertWhen_RewardAmountIsLessThanDelegationDenominator() public {
    changePrank(REWARDER);
    vm.expectRevert(abi.encodeWithSelector(RewardVault.InvalidRewardAmount.selector));
    s_rewardVault.addReward(address(0), DELEGATION_RATE_DENOMINATOR - 1, EMISSION_RATE);
  }

  function test_RevertWhen_EmissionRateIsZero() public {
    changePrank(REWARDER);
    vm.expectRevert(abi.encodeWithSelector(RewardVault.InvalidEmissionRate.selector));
    s_rewardVault.addReward(address(0), REWARD_AMOUNT, 0);
  }

  function test_RevertWhen_EmissionRateIsLessThanDelegationDenominator() public {
    changePrank(REWARDER);
    vm.expectRevert(abi.encodeWithSelector(RewardVault.InvalidEmissionRate.selector));
    s_rewardVault.addReward(address(0), REWARD_AMOUNT, DELEGATION_RATE_DENOMINATOR - 1);
  }

  function test_TransfersLinkRewardAmountFromRewarderToRewardVault() public {
    changePrank(REWARDER);
    uint256 rewardVaultBalanceBefore = s_LINK.balanceOf(address(s_rewardVault));
    s_rewardVault.addReward(address(0), REWARD_AMOUNT, EMISSION_RATE);
    uint256 rewardVaultBalanceAfter = s_LINK.balanceOf(address(s_rewardVault));
    assertEq(rewardVaultBalanceAfter - rewardVaultBalanceBefore, REWARD_AMOUNT);
  }

  function test_PoolAddressZeroIsValid() public {
    changePrank(REWARDER);
    s_rewardVault.addReward(address(0), REWARD_AMOUNT, EMISSION_RATE);
  }

  function test_PoolAddresscommunityPoolIsValid() public {
    changePrank(REWARDER);
    s_rewardVault.addReward(address(s_communityStakingPool), REWARD_AMOUNT, EMISSION_RATE);
  }

  function test_PoolAddressOperatorPoolIsValid() public {
    changePrank(REWARDER);
    s_rewardVault.addReward(address(s_operatorStakingPool), REWARD_AMOUNT, EMISSION_RATE);
  }
}

contract RewardVault_AddReward_WhenThereAreStakers is RewardVault_WithStakersAndTimePassed {
  function test_CommunityStakerEarnsCorrectAmountOfRewardsIfEmissionRateChanged() public {
    uint256 expectedRewardBeforeEmissionRateChange = _calculateStakerExpectedReward(
      COMMUNITY_MIN_PRINCIPAL,
      COMMUNITY_MIN_PRINCIPAL * 4,
      _calculateBucketVestedRewards(
        s_rewardVault.getRewardBuckets().communityBase, rewardAddedAt, block.timestamp
      )
    );
    changePrank(REWARDER);
    s_rewardVault.addReward(address(0), 0, EMISSION_RATE / 2);
    uint256 timeEmissionRateChanged = block.timestamp;
    skip(30 days);
    uint256 expectedRewardAfterEmissionRateChange = _calculateStakerExpectedReward(
      COMMUNITY_MIN_PRINCIPAL,
      COMMUNITY_MIN_PRINCIPAL * 4,
      _calculateBucketVestedRewards(
        s_rewardVault.getRewardBuckets().communityBase, timeEmissionRateChanged, block.timestamp
      )
    );
    uint256 multiplier =
      _calculateStakerMultiplier(s_stakedAtTime, block.timestamp, INITIAL_MULTIPLIER_DURATION);
    uint256 expectedReward = multiplier
      * (expectedRewardAfterEmissionRateChange + expectedRewardBeforeEmissionRateChange)
      / FixedPointMathLib.WAD;
    assertEq(s_rewardVault.getReward(COMMUNITY_STAKER_ONE), expectedReward);
  }

  function test_OperatorEarnsCorrectAmountOfRewardsIfEmissionRateChanged() public {
    uint256 expectedBaseRewardBeforeEmissionRateChange = _calculateStakerExpectedReward(
      OPERATOR_MIN_PRINCIPAL,
      OPERATOR_MIN_PRINCIPAL * 4,
      _calculateBucketVestedRewards(
        s_rewardVault.getRewardBuckets().operatorBase, rewardAddedAt, block.timestamp
      )
    );
    uint256 expectedDelegatedRewardBeforeEmissionRateChange = _calculateStakerExpectedReward(
      OPERATOR_MIN_PRINCIPAL,
      OPERATOR_MIN_PRINCIPAL * 4,
      _calculateBucketVestedRewards(
        s_rewardVault.getRewardBuckets().operatorDelegated, rewardAddedAt, block.timestamp
      )
    );
    changePrank(REWARDER);
    s_rewardVault.addReward(address(0), 0, EMISSION_RATE / 2);
    uint256 timeEmissionRateChanged = block.timestamp;
    skip(30 days);
    uint256 expectedBaseRewardAfterEmissionRateChange = _calculateStakerExpectedReward(
      OPERATOR_MIN_PRINCIPAL,
      OPERATOR_MIN_PRINCIPAL * 4,
      _calculateBucketVestedRewards(
        s_rewardVault.getRewardBuckets().operatorBase, timeEmissionRateChanged, block.timestamp
      )
    );
    uint256 expectedDelegatedRewardAfterEmissionRateChange = _calculateStakerExpectedReward(
      OPERATOR_MIN_PRINCIPAL,
      OPERATOR_MIN_PRINCIPAL * 4,
      _calculateBucketVestedRewards(
        s_rewardVault.getRewardBuckets().operatorDelegated, timeEmissionRateChanged, block.timestamp
      )
    );
    uint256 multiplier =
      _calculateStakerMultiplier(s_stakedAtTime, block.timestamp, INITIAL_MULTIPLIER_DURATION);
    uint256 expectedReward = multiplier
      * (expectedBaseRewardAfterEmissionRateChange + expectedBaseRewardBeforeEmissionRateChange)
      / FixedPointMathLib.WAD + expectedDelegatedRewardBeforeEmissionRateChange
      + expectedDelegatedRewardAfterEmissionRateChange;
    assertEq(s_rewardVault.getReward(OPERATOR_STAKER_ONE), expectedReward);
  }
}

contract RewardVault_AddReward_OperatorRewardBucket is
  IRewardVault_AddReward_UpdateBucket,
  BaseTest
{
  function test_InitializeRewardDuration() public {
    uint256 duration = REWARD_AMOUNT / EMISSION_RATE;

    changePrank(REWARDER);

    RewardVault.RewardBuckets memory rewardBuckets = s_rewardVault.getRewardBuckets();

    assertEq(rewardBuckets.operatorBase.rewardDurationEndsAt, 0);
    assertEq(rewardBuckets.communityBase.rewardDurationEndsAt, 0);
    assertEq(rewardBuckets.operatorDelegated.rewardDurationEndsAt, 0);

    s_rewardVault.addReward(address(s_operatorStakingPool), REWARD_AMOUNT, EMISSION_RATE);
    rewardBuckets = s_rewardVault.getRewardBuckets();

    assertEq(rewardBuckets.operatorBase.rewardDurationEndsAt, duration + TEST_START_TIME);
    assertEq(rewardBuckets.communityBase.rewardDurationEndsAt, 0);
    assertEq(rewardBuckets.operatorDelegated.rewardDurationEndsAt, 0);
  }

  function test_InitializeEmissionRate() public {
    changePrank(REWARDER);

    RewardVault.RewardBuckets memory rewardBuckets = s_rewardVault.getRewardBuckets();

    assertEq(rewardBuckets.operatorBase.emissionRate, 0);
    assertEq(rewardBuckets.communityBase.emissionRate, 0);
    assertEq(rewardBuckets.operatorDelegated.emissionRate, 0);

    s_rewardVault.addReward(address(s_operatorStakingPool), REWARD_AMOUNT, EMISSION_RATE);
    rewardBuckets = s_rewardVault.getRewardBuckets();

    assertEq(rewardBuckets.operatorBase.emissionRate, EMISSION_RATE);
    assertEq(rewardBuckets.communityBase.emissionRate, 0);
    assertEq(rewardBuckets.operatorDelegated.emissionRate, 0);
  }

  function test_UpdateEmissionRate() public {
    uint256 newEmissionRate = EMISSION_RATE * 2;

    changePrank(REWARDER);
    s_rewardVault.addReward(address(s_operatorStakingPool), REWARD_AMOUNT, EMISSION_RATE);
    RewardVault.RewardBuckets memory rewardBuckets = s_rewardVault.getRewardBuckets();

    assertEq(rewardBuckets.operatorBase.emissionRate, EMISSION_RATE);
    assertEq(rewardBuckets.communityBase.emissionRate, 0);
    assertEq(rewardBuckets.operatorDelegated.emissionRate, 0);

    s_rewardVault.addReward(address(s_operatorStakingPool), REWARD_AMOUNT, newEmissionRate);
    rewardBuckets = s_rewardVault.getRewardBuckets();

    assertEq(rewardBuckets.operatorBase.emissionRate, newEmissionRate);
    assertEq(rewardBuckets.communityBase.emissionRate, 0);
    assertEq(rewardBuckets.operatorDelegated.emissionRate, 0);
  }

  function test_IncreaseRewardDurationWithMoreRewardsSameRate() public {
    uint256 duration = REWARD_AMOUNT / EMISSION_RATE;

    changePrank(REWARDER);
    s_rewardVault.addReward(address(s_operatorStakingPool), REWARD_AMOUNT, EMISSION_RATE);
    RewardVault.RewardBuckets memory rewardBuckets = s_rewardVault.getRewardBuckets();

    assertEq(rewardBuckets.operatorBase.rewardDurationEndsAt, duration + TEST_START_TIME);
    assertEq(rewardBuckets.communityBase.rewardDurationEndsAt, 0);
    assertEq(rewardBuckets.operatorDelegated.rewardDurationEndsAt, 0);

    assertEq(rewardBuckets.operatorBase.emissionRate, EMISSION_RATE);
    assertEq(rewardBuckets.communityBase.emissionRate, 0);
    assertEq(rewardBuckets.operatorDelegated.emissionRate, 0);

    s_rewardVault.addReward(address(s_operatorStakingPool), REWARD_AMOUNT, EMISSION_RATE);
    rewardBuckets = s_rewardVault.getRewardBuckets();

    assertEq(rewardBuckets.operatorBase.rewardDurationEndsAt, duration * 2 + TEST_START_TIME);
    assertEq(rewardBuckets.communityBase.rewardDurationEndsAt, 0);
    assertEq(rewardBuckets.operatorDelegated.rewardDurationEndsAt, 0);

    assertEq(rewardBuckets.operatorBase.emissionRate, EMISSION_RATE);
    assertEq(rewardBuckets.communityBase.emissionRate, 0);
    assertEq(rewardBuckets.operatorDelegated.emissionRate, 0);

    (
      uint256 unvestedCommunityBaseRewards,
      uint256 unvestedOperatorBaseRewards,
      uint256 unvestedOperatorDelegatedRewards
    ) = s_rewardVault.getUnvestedRewards();

    assertEq(unvestedCommunityBaseRewards, 0);
    assertEq(unvestedOperatorBaseRewards, REWARD_AMOUNT * 2);
    assertEq(unvestedOperatorDelegatedRewards, 0);
  }

  function test_IncreaseRewardDurationWithZeroRewardAmountAndSlowerRate() public {
    uint256 duration = REWARD_AMOUNT / EMISSION_RATE;

    changePrank(REWARDER);
    s_rewardVault.addReward(address(s_operatorStakingPool), REWARD_AMOUNT, EMISSION_RATE);
    RewardVault.RewardBuckets memory rewardBuckets = s_rewardVault.getRewardBuckets();

    assertEq(rewardBuckets.operatorBase.rewardDurationEndsAt, duration + TEST_START_TIME);
    assertEq(rewardBuckets.communityBase.rewardDurationEndsAt, 0);
    assertEq(rewardBuckets.operatorDelegated.rewardDurationEndsAt, 0);

    assertEq(rewardBuckets.operatorBase.emissionRate, EMISSION_RATE);
    assertEq(rewardBuckets.communityBase.emissionRate, 0);
    assertEq(rewardBuckets.operatorDelegated.emissionRate, 0);

    s_rewardVault.addReward(address(s_operatorStakingPool), 0, EMISSION_RATE / 2);
    rewardBuckets = s_rewardVault.getRewardBuckets();

    assertEq(rewardBuckets.operatorBase.rewardDurationEndsAt, duration * 2 + TEST_START_TIME);
    assertEq(rewardBuckets.communityBase.rewardDurationEndsAt, 0);
    assertEq(rewardBuckets.operatorDelegated.rewardDurationEndsAt, 0);

    assertEq(rewardBuckets.operatorBase.emissionRate, EMISSION_RATE / 2);
    assertEq(rewardBuckets.communityBase.emissionRate, 0);
    assertEq(rewardBuckets.operatorDelegated.emissionRate, 0);
  }

  function test_DecreaseRewardDurationWithZeroRewardAmountAndFasterRate() public {
    uint256 duration = REWARD_AMOUNT / EMISSION_RATE;

    changePrank(REWARDER);
    s_rewardVault.addReward(address(s_operatorStakingPool), REWARD_AMOUNT, EMISSION_RATE);
    RewardVault.RewardBuckets memory rewardBuckets = s_rewardVault.getRewardBuckets();

    assertEq(rewardBuckets.operatorBase.rewardDurationEndsAt, duration + TEST_START_TIME);
    assertEq(rewardBuckets.communityBase.rewardDurationEndsAt, 0);
    assertEq(rewardBuckets.operatorDelegated.rewardDurationEndsAt, 0);

    assertEq(rewardBuckets.operatorBase.emissionRate, EMISSION_RATE);
    assertEq(rewardBuckets.communityBase.emissionRate, 0);
    assertEq(rewardBuckets.operatorDelegated.emissionRate, 0);

    s_rewardVault.addReward(address(s_operatorStakingPool), 0, EMISSION_RATE * 2);
    rewardBuckets = s_rewardVault.getRewardBuckets();

    assertEq(rewardBuckets.operatorBase.rewardDurationEndsAt, duration / 2 + TEST_START_TIME);
    assertEq(rewardBuckets.communityBase.rewardDurationEndsAt, 0);
    assertEq(rewardBuckets.operatorDelegated.rewardDurationEndsAt, 0);

    assertEq(rewardBuckets.operatorBase.emissionRate, EMISSION_RATE * 2);
    assertEq(rewardBuckets.communityBase.emissionRate, 0);
    assertEq(rewardBuckets.operatorDelegated.emissionRate, 0);
  }

  function test_TopUpRewardsAtConclusionOfOldRewards() public {
    uint256 duration = REWARD_AMOUNT / EMISSION_RATE;
    uint256 firstEnding = duration + TEST_START_TIME;
    uint256 secondEnding = duration * 2 + TEST_START_TIME;

    changePrank(REWARDER);
    s_rewardVault.addReward(address(s_operatorStakingPool), REWARD_AMOUNT, EMISSION_RATE);
    RewardVault.RewardBuckets memory rewardBuckets = s_rewardVault.getRewardBuckets();

    assertEq(rewardBuckets.operatorBase.rewardDurationEndsAt, firstEnding);
    assertEq(rewardBuckets.communityBase.rewardDurationEndsAt, 0);
    assertEq(rewardBuckets.operatorDelegated.rewardDurationEndsAt, 0);

    skip(duration);
    s_rewardVault.addReward(address(s_operatorStakingPool), REWARD_AMOUNT, EMISSION_RATE);
    rewardBuckets = s_rewardVault.getRewardBuckets();

    assertEq(rewardBuckets.operatorBase.rewardDurationEndsAt, secondEnding);
    assertEq(rewardBuckets.communityBase.rewardDurationEndsAt, 0);
    assertEq(rewardBuckets.operatorDelegated.rewardDurationEndsAt, 0);
  }

  function test_TopUpRewardsAfterConclusionOfOldRewards() public {
    uint256 duration = REWARD_AMOUNT / EMISSION_RATE;
    uint256 delay = 100;
    uint256 firstEnding = duration + TEST_START_TIME;
    uint256 secondEnding = duration * 2 + TEST_START_TIME;
    uint256 secondEndingWithDelay = secondEnding + delay;

    changePrank(REWARDER);
    s_rewardVault.addReward(address(s_operatorStakingPool), REWARD_AMOUNT, EMISSION_RATE);
    RewardVault.RewardBuckets memory rewardBuckets = s_rewardVault.getRewardBuckets();

    assertEq(rewardBuckets.operatorBase.rewardDurationEndsAt, firstEnding);
    assertEq(rewardBuckets.communityBase.rewardDurationEndsAt, 0);
    assertEq(rewardBuckets.operatorDelegated.rewardDurationEndsAt, 0);

    skip(duration + delay);
    s_rewardVault.addReward(address(s_operatorStakingPool), REWARD_AMOUNT, EMISSION_RATE);
    rewardBuckets = s_rewardVault.getRewardBuckets();

    assertEq(rewardBuckets.operatorBase.rewardDurationEndsAt, secondEndingWithDelay);
    assertEq(rewardBuckets.communityBase.rewardDurationEndsAt, 0);
    assertEq(rewardBuckets.operatorDelegated.rewardDurationEndsAt, 0);
  }

  function test_RevertWhen_AddRewardAmountLessThanEmissionRate() public {
    uint256 rewardAmount = 5 ether; // 5 link
    uint256 emissionRate = 10 ether; // 10 link per sec

    changePrank(REWARDER);
    vm.expectRevert(RewardVault.RewardDurationTooShort.selector);
    s_rewardVault.addReward(address(s_operatorStakingPool), rewardAmount, emissionRate);
  }
}

contract RewardVault_AddReward_CommunityRewardBucket_DelegationDenominatorIsZero is
  RewardVault_DelegationDenominatorIsZero,
  IRewardVault_AddReward_UpdateBucket
{
  function test_InitializeRewardDuration() public {
    uint256 duration = REWARD_AMOUNT / EMISSION_RATE;

    changePrank(REWARDER);

    RewardVault.RewardBuckets memory rewardBuckets = s_rewardVault.getRewardBuckets();

    assertEq(rewardBuckets.operatorBase.rewardDurationEndsAt, 0);
    assertEq(rewardBuckets.communityBase.rewardDurationEndsAt, 0);
    assertEq(rewardBuckets.operatorDelegated.rewardDurationEndsAt, 0);

    s_rewardVault.addReward(address(s_communityStakingPool), REWARD_AMOUNT, EMISSION_RATE);
    rewardBuckets = s_rewardVault.getRewardBuckets();

    assertEq(rewardBuckets.operatorBase.rewardDurationEndsAt, 0);
    assertEq(rewardBuckets.communityBase.rewardDurationEndsAt, duration + TEST_START_TIME);
    assertEq(rewardBuckets.operatorDelegated.rewardDurationEndsAt, 0);
  }

  function test_InitializeEmissionRate() public {
    changePrank(REWARDER);

    RewardVault.RewardBuckets memory rewardBuckets = s_rewardVault.getRewardBuckets();

    assertEq(rewardBuckets.operatorBase.emissionRate, 0);
    assertEq(rewardBuckets.communityBase.emissionRate, 0);
    assertEq(rewardBuckets.operatorDelegated.emissionRate, 0);

    s_rewardVault.addReward(address(s_communityStakingPool), REWARD_AMOUNT, EMISSION_RATE);
    rewardBuckets = s_rewardVault.getRewardBuckets();

    assertEq(rewardBuckets.operatorBase.emissionRate, 0);
    assertEq(rewardBuckets.communityBase.emissionRate, EMISSION_RATE);
    assertEq(rewardBuckets.operatorDelegated.emissionRate, 0);
  }

  function test_UpdateEmissionRate() public {
    uint256 newEmissionRate = EMISSION_RATE * 2;

    changePrank(REWARDER);
    s_rewardVault.addReward(address(s_communityStakingPool), REWARD_AMOUNT, EMISSION_RATE);
    RewardVault.RewardBuckets memory rewardBuckets = s_rewardVault.getRewardBuckets();

    assertEq(rewardBuckets.operatorBase.emissionRate, 0);
    assertEq(rewardBuckets.communityBase.emissionRate, EMISSION_RATE);
    assertEq(rewardBuckets.operatorDelegated.emissionRate, 0);

    s_rewardVault.addReward(address(s_communityStakingPool), REWARD_AMOUNT, newEmissionRate);
    rewardBuckets = s_rewardVault.getRewardBuckets();

    assertEq(rewardBuckets.operatorBase.emissionRate, 0);
    assertEq(rewardBuckets.communityBase.emissionRate, newEmissionRate);
    assertEq(rewardBuckets.operatorDelegated.emissionRate, 0);
  }

  function test_IncreaseRewardDurationWithMoreRewardsSameRate() public {
    uint256 duration = REWARD_AMOUNT / EMISSION_RATE;

    changePrank(REWARDER);
    s_rewardVault.addReward(address(s_communityStakingPool), REWARD_AMOUNT, EMISSION_RATE);
    RewardVault.RewardBuckets memory rewardBuckets = s_rewardVault.getRewardBuckets();

    assertEq(rewardBuckets.operatorBase.rewardDurationEndsAt, 0);
    assertEq(rewardBuckets.communityBase.rewardDurationEndsAt, duration + TEST_START_TIME);
    assertEq(rewardBuckets.operatorDelegated.rewardDurationEndsAt, 0);

    assertEq(rewardBuckets.operatorBase.emissionRate, 0);
    assertEq(rewardBuckets.communityBase.emissionRate, EMISSION_RATE);
    assertEq(rewardBuckets.operatorDelegated.emissionRate, 0);

    s_rewardVault.addReward(address(s_communityStakingPool), REWARD_AMOUNT, EMISSION_RATE);
    rewardBuckets = s_rewardVault.getRewardBuckets();

    assertEq(rewardBuckets.operatorBase.rewardDurationEndsAt, 0);
    assertEq(rewardBuckets.communityBase.rewardDurationEndsAt, duration * 2 + TEST_START_TIME);
    assertEq(rewardBuckets.operatorDelegated.rewardDurationEndsAt, 0);

    assertEq(rewardBuckets.operatorBase.emissionRate, 0);
    assertEq(rewardBuckets.communityBase.emissionRate, EMISSION_RATE);
    assertEq(rewardBuckets.operatorDelegated.emissionRate, 0);
  }

  function test_IncreaseRewardDurationWithZeroRewardAmountAndSlowerRate() public {
    uint256 duration = REWARD_AMOUNT / EMISSION_RATE;

    changePrank(REWARDER);
    s_rewardVault.addReward(address(s_communityStakingPool), REWARD_AMOUNT, EMISSION_RATE);
    RewardVault.RewardBuckets memory rewardBuckets = s_rewardVault.getRewardBuckets();

    assertEq(rewardBuckets.operatorBase.rewardDurationEndsAt, 0);
    assertEq(rewardBuckets.communityBase.rewardDurationEndsAt, duration + TEST_START_TIME);
    assertEq(rewardBuckets.operatorDelegated.rewardDurationEndsAt, 0);

    assertEq(rewardBuckets.operatorBase.emissionRate, 0);
    assertEq(rewardBuckets.communityBase.emissionRate, EMISSION_RATE);
    assertEq(rewardBuckets.operatorDelegated.emissionRate, 0);

    s_rewardVault.addReward(address(s_communityStakingPool), 0, EMISSION_RATE / 2);
    rewardBuckets = s_rewardVault.getRewardBuckets();

    assertEq(rewardBuckets.operatorBase.rewardDurationEndsAt, 0);
    assertEq(rewardBuckets.communityBase.rewardDurationEndsAt, duration * 2 + TEST_START_TIME);
    assertEq(rewardBuckets.operatorDelegated.rewardDurationEndsAt, 0);

    assertEq(rewardBuckets.operatorBase.emissionRate, 0);
    assertEq(rewardBuckets.communityBase.emissionRate, EMISSION_RATE / 2);
    assertEq(rewardBuckets.operatorDelegated.emissionRate, 0);
  }

  function test_DecreaseRewardDurationWithZeroRewardAmountAndFasterRate() public {
    uint256 duration = REWARD_AMOUNT / EMISSION_RATE;

    changePrank(REWARDER);
    s_rewardVault.addReward(address(s_communityStakingPool), REWARD_AMOUNT, EMISSION_RATE);
    RewardVault.RewardBuckets memory rewardBuckets = s_rewardVault.getRewardBuckets();

    assertEq(rewardBuckets.operatorBase.rewardDurationEndsAt, 0);
    assertEq(rewardBuckets.communityBase.rewardDurationEndsAt, duration + TEST_START_TIME);
    assertEq(rewardBuckets.operatorDelegated.rewardDurationEndsAt, 0);

    assertEq(rewardBuckets.operatorBase.emissionRate, 0);
    assertEq(rewardBuckets.communityBase.emissionRate, EMISSION_RATE);
    assertEq(rewardBuckets.operatorDelegated.emissionRate, 0);

    s_rewardVault.addReward(address(s_communityStakingPool), 0, EMISSION_RATE * 2);
    rewardBuckets = s_rewardVault.getRewardBuckets();

    assertEq(rewardBuckets.operatorBase.rewardDurationEndsAt, 0);
    assertEq(rewardBuckets.communityBase.rewardDurationEndsAt, duration / 2 + TEST_START_TIME);
    assertEq(rewardBuckets.operatorDelegated.rewardDurationEndsAt, 0);

    assertEq(rewardBuckets.operatorBase.emissionRate, 0);
    assertEq(rewardBuckets.communityBase.emissionRate, EMISSION_RATE * 2);
    assertEq(rewardBuckets.operatorDelegated.emissionRate, 0);
  }

  function test_TopUpRewardsAtConclusionOfOldRewards() public {
    uint256 duration = REWARD_AMOUNT / EMISSION_RATE;
    uint256 firstEnding = duration + TEST_START_TIME;
    uint256 secondEnding = duration * 2 + TEST_START_TIME;

    changePrank(REWARDER);
    s_rewardVault.addReward(address(s_communityStakingPool), REWARD_AMOUNT, EMISSION_RATE);
    RewardVault.RewardBuckets memory rewardBuckets = s_rewardVault.getRewardBuckets();

    assertEq(rewardBuckets.operatorBase.rewardDurationEndsAt, 0);
    assertEq(rewardBuckets.communityBase.rewardDurationEndsAt, firstEnding);
    assertEq(rewardBuckets.operatorDelegated.rewardDurationEndsAt, 0);

    skip(duration);
    s_rewardVault.addReward(address(s_communityStakingPool), REWARD_AMOUNT, EMISSION_RATE);
    rewardBuckets = s_rewardVault.getRewardBuckets();

    assertEq(rewardBuckets.operatorBase.rewardDurationEndsAt, 0);
    assertEq(rewardBuckets.communityBase.rewardDurationEndsAt, secondEnding);
    assertEq(rewardBuckets.operatorDelegated.rewardDurationEndsAt, 0);
  }

  function test_TopUpRewardsAfterConclusionOfOldRewards() public {
    uint256 duration = REWARD_AMOUNT / EMISSION_RATE;
    uint256 delay = 100;
    uint256 firstEnding = duration + TEST_START_TIME;
    uint256 secondEnding = duration * 2 + TEST_START_TIME;
    uint256 secondEndingWithDelay = secondEnding + delay;

    changePrank(REWARDER);
    s_rewardVault.addReward(address(s_communityStakingPool), REWARD_AMOUNT, EMISSION_RATE);
    RewardVault.RewardBuckets memory rewardBuckets = s_rewardVault.getRewardBuckets();

    assertEq(rewardBuckets.operatorBase.rewardDurationEndsAt, 0);
    assertEq(rewardBuckets.communityBase.rewardDurationEndsAt, firstEnding);
    assertEq(rewardBuckets.operatorDelegated.rewardDurationEndsAt, 0);

    skip(duration + delay);
    s_rewardVault.addReward(address(s_communityStakingPool), REWARD_AMOUNT, EMISSION_RATE);
    rewardBuckets = s_rewardVault.getRewardBuckets();

    assertEq(rewardBuckets.operatorBase.rewardDurationEndsAt, 0);
    assertEq(rewardBuckets.communityBase.rewardDurationEndsAt, secondEndingWithDelay);
    assertEq(rewardBuckets.operatorDelegated.rewardDurationEndsAt, 0);
  }

  function test_RevertWhen_AddRewardAmountLessThanEmissionRate() public {
    uint256 rewardAmount = 5 ether; // 5 link
    uint256 emissionRate = 10 ether; // 10 link per sec

    changePrank(REWARDER);
    vm.expectRevert(RewardVault.RewardDurationTooShort.selector);
    s_rewardVault.addReward(address(s_communityStakingPool), rewardAmount, emissionRate);
  }
}

contract RewardVault_AddReward_CommunityAndDelegatedRewardBucket is
  IRewardVault_AddReward_UpdateBucket,
  BaseTest
{
  function test_InitializeRewardDuration() public {
    uint256 duration = REWARD_AMOUNT / EMISSION_RATE;

    changePrank(REWARDER);
    s_rewardVault.addReward(address(s_communityStakingPool), REWARD_AMOUNT, EMISSION_RATE);
    RewardVault.RewardBuckets memory rewardBuckets = s_rewardVault.getRewardBuckets();

    assertEq(rewardBuckets.operatorBase.rewardDurationEndsAt, 0);
    assertEq(rewardBuckets.communityBase.rewardDurationEndsAt, duration + TEST_START_TIME);
    assertEq(rewardBuckets.operatorDelegated.rewardDurationEndsAt, duration + TEST_START_TIME);
  }

  function test_InitializeEmissionRate() public {
    uint256 expectedDelegationRate = EMISSION_RATE / DELEGATION_RATE_DENOMINATOR;
    uint256 expectedCommunityRate = EMISSION_RATE - expectedDelegationRate;
    RewardVault.RewardBuckets memory rewardBuckets = s_rewardVault.getRewardBuckets();

    assertEq(rewardBuckets.operatorBase.emissionRate, 0);
    assertEq(rewardBuckets.communityBase.emissionRate, 0);
    assertEq(rewardBuckets.operatorDelegated.emissionRate, 0);

    changePrank(REWARDER);
    s_rewardVault.addReward(address(s_communityStakingPool), REWARD_AMOUNT, EMISSION_RATE);
    rewardBuckets = s_rewardVault.getRewardBuckets();

    assertEq(rewardBuckets.operatorBase.emissionRate, 0);
    assertEq(rewardBuckets.communityBase.emissionRate, expectedCommunityRate);
    assertEq(rewardBuckets.operatorDelegated.emissionRate, expectedDelegationRate);
  }

  function test_UpdateEmissionRate() public {
    uint256 expectedDelegationRate = EMISSION_RATE / DELEGATION_RATE_DENOMINATOR;
    uint256 expectedCommunityRate = EMISSION_RATE - expectedDelegationRate;
    RewardVault.RewardBuckets memory rewardBuckets = s_rewardVault.getRewardBuckets();

    changePrank(REWARDER);
    s_rewardVault.addReward(address(s_communityStakingPool), REWARD_AMOUNT, EMISSION_RATE);
    rewardBuckets = s_rewardVault.getRewardBuckets();

    assertEq(rewardBuckets.operatorBase.emissionRate, 0);
    assertEq(rewardBuckets.communityBase.emissionRate, expectedCommunityRate);
    assertEq(rewardBuckets.operatorDelegated.emissionRate, expectedDelegationRate);

    uint256 newEmisisonRate = EMISSION_RATE * 2;
    expectedDelegationRate = newEmisisonRate / DELEGATION_RATE_DENOMINATOR;
    expectedCommunityRate = newEmisisonRate - expectedDelegationRate;

    s_rewardVault.addReward(address(s_communityStakingPool), REWARD_AMOUNT, newEmisisonRate);
    rewardBuckets = s_rewardVault.getRewardBuckets();

    assertEq(rewardBuckets.operatorBase.emissionRate, 0);
    assertEq(rewardBuckets.communityBase.emissionRate, expectedCommunityRate);
    assertEq(rewardBuckets.operatorDelegated.emissionRate, expectedDelegationRate);
  }

  function test_IncreaseRewardDurationWithMoreRewardsSameRate() public {
    uint256 duration = REWARD_AMOUNT / EMISSION_RATE;
    uint256 firstEnding = duration + TEST_START_TIME;
    uint256 secondEnding = duration * 2 + TEST_START_TIME;
    uint256 delegatedRate = EMISSION_RATE / DELEGATION_RATE_DENOMINATOR;
    uint256 communityRate = EMISSION_RATE - delegatedRate;

    changePrank(REWARDER);
    s_rewardVault.addReward(address(s_communityStakingPool), REWARD_AMOUNT, EMISSION_RATE);
    RewardVault.RewardBuckets memory rewardBuckets = s_rewardVault.getRewardBuckets();

    assertEq(rewardBuckets.operatorBase.rewardDurationEndsAt, 0);
    assertEq(rewardBuckets.communityBase.rewardDurationEndsAt, firstEnding);
    assertEq(rewardBuckets.operatorDelegated.rewardDurationEndsAt, firstEnding);

    assertEq(rewardBuckets.operatorBase.emissionRate, 0);
    assertEq(rewardBuckets.communityBase.emissionRate, communityRate);
    assertEq(rewardBuckets.operatorDelegated.emissionRate, delegatedRate);

    s_rewardVault.addReward(address(s_communityStakingPool), REWARD_AMOUNT, EMISSION_RATE);
    rewardBuckets = s_rewardVault.getRewardBuckets();

    assertEq(rewardBuckets.operatorBase.rewardDurationEndsAt, 0);
    assertEq(rewardBuckets.communityBase.rewardDurationEndsAt, secondEnding);
    assertEq(rewardBuckets.operatorDelegated.rewardDurationEndsAt, secondEnding);

    assertEq(rewardBuckets.operatorBase.emissionRate, 0);
    assertEq(rewardBuckets.communityBase.emissionRate, communityRate);
    assertEq(rewardBuckets.operatorDelegated.emissionRate, delegatedRate);
  }

  function test_IncreaseRewardDurationWithZeroRewardAmountAndSlowerRate() public {
    uint256 duration = REWARD_AMOUNT / EMISSION_RATE;
    uint256 firstEnding = duration + TEST_START_TIME;
    uint256 secondEnding = duration * 2 + TEST_START_TIME;
    uint256 delegatedRate = EMISSION_RATE / DELEGATION_RATE_DENOMINATOR;
    uint256 communityRate = EMISSION_RATE - delegatedRate;

    changePrank(REWARDER);
    s_rewardVault.addReward(address(s_communityStakingPool), REWARD_AMOUNT, EMISSION_RATE);
    RewardVault.RewardBuckets memory rewardBuckets = s_rewardVault.getRewardBuckets();

    assertEq(rewardBuckets.operatorBase.rewardDurationEndsAt, 0);
    assertEq(rewardBuckets.communityBase.rewardDurationEndsAt, firstEnding);
    assertEq(rewardBuckets.operatorDelegated.rewardDurationEndsAt, firstEnding);

    assertEq(rewardBuckets.operatorBase.emissionRate, 0);
    assertEq(rewardBuckets.communityBase.emissionRate, communityRate);
    assertEq(rewardBuckets.operatorDelegated.emissionRate, delegatedRate);

    s_rewardVault.addReward(address(s_communityStakingPool), 0, EMISSION_RATE / 2);
    rewardBuckets = s_rewardVault.getRewardBuckets();

    assertEq(rewardBuckets.operatorBase.rewardDurationEndsAt, 0);
    assertEq(rewardBuckets.communityBase.rewardDurationEndsAt, secondEnding);
    assertEq(rewardBuckets.operatorDelegated.rewardDurationEndsAt, secondEnding);

    assertEq(rewardBuckets.operatorBase.rewardDurationEndsAt, 0);
    assertEq(rewardBuckets.communityBase.emissionRate, communityRate / 2);
    assertEq(rewardBuckets.operatorDelegated.emissionRate, delegatedRate / 2);
  }

  function test_DecreaseRewardDurationWithZeroRewardAmountAndFasterRate() public {
    uint256 duration = REWARD_AMOUNT / EMISSION_RATE;
    uint256 firstEnding = duration + TEST_START_TIME;
    uint256 secondEnding = duration / 2 + TEST_START_TIME;
    uint256 delegatedRate = EMISSION_RATE / DELEGATION_RATE_DENOMINATOR;
    uint256 communityRate = EMISSION_RATE - delegatedRate;

    changePrank(REWARDER);
    s_rewardVault.addReward(address(s_communityStakingPool), REWARD_AMOUNT, EMISSION_RATE);
    RewardVault.RewardBuckets memory rewardBuckets = s_rewardVault.getRewardBuckets();

    assertEq(rewardBuckets.operatorBase.rewardDurationEndsAt, 0);
    assertEq(rewardBuckets.communityBase.rewardDurationEndsAt, firstEnding);
    assertEq(rewardBuckets.operatorDelegated.rewardDurationEndsAt, firstEnding);

    assertEq(rewardBuckets.operatorBase.emissionRate, 0);
    assertEq(rewardBuckets.communityBase.emissionRate, communityRate);
    assertEq(rewardBuckets.operatorDelegated.emissionRate, delegatedRate);

    s_rewardVault.addReward(address(s_communityStakingPool), 0, EMISSION_RATE * 2);
    rewardBuckets = s_rewardVault.getRewardBuckets();

    assertEq(rewardBuckets.operatorBase.rewardDurationEndsAt, 0);
    assertEq(rewardBuckets.communityBase.rewardDurationEndsAt, secondEnding);
    assertEq(rewardBuckets.operatorDelegated.rewardDurationEndsAt, secondEnding);

    assertEq(rewardBuckets.operatorBase.emissionRate, 0);
    assertEq(rewardBuckets.communityBase.emissionRate, communityRate * 2);
    assertEq(rewardBuckets.operatorDelegated.emissionRate, delegatedRate * 2);
  }

  function test_TopUpRewardsAtConclusionOfOldRewards() public {
    uint256 duration = REWARD_AMOUNT / EMISSION_RATE;
    uint256 firstEnding = duration + TEST_START_TIME;
    uint256 secondEnding = duration * 2 + TEST_START_TIME;

    changePrank(REWARDER);
    s_rewardVault.addReward(address(s_communityStakingPool), REWARD_AMOUNT, EMISSION_RATE);
    RewardVault.RewardBuckets memory rewardBuckets = s_rewardVault.getRewardBuckets();

    assertEq(rewardBuckets.operatorBase.rewardDurationEndsAt, 0);
    assertEq(rewardBuckets.communityBase.rewardDurationEndsAt, firstEnding);
    assertEq(rewardBuckets.operatorDelegated.rewardDurationEndsAt, firstEnding);

    skip(duration);
    s_rewardVault.addReward(address(s_communityStakingPool), REWARD_AMOUNT, EMISSION_RATE);
    rewardBuckets = s_rewardVault.getRewardBuckets();

    assertEq(rewardBuckets.operatorBase.rewardDurationEndsAt, 0);
    assertEq(rewardBuckets.communityBase.rewardDurationEndsAt, secondEnding);
    assertEq(rewardBuckets.operatorDelegated.rewardDurationEndsAt, secondEnding);
  }

  function test_TopUpRewardsAfterConclusionOfOldRewards() public {
    uint256 duration = REWARD_AMOUNT / EMISSION_RATE;
    uint256 delay = 100;
    uint256 firstEnding = duration + TEST_START_TIME;
    uint256 secondEnding = duration * 2 + TEST_START_TIME;
    uint256 secondEndingWithDelay = secondEnding + delay;

    changePrank(REWARDER);
    s_rewardVault.addReward(address(s_communityStakingPool), REWARD_AMOUNT, EMISSION_RATE);
    RewardVault.RewardBuckets memory rewardBuckets = s_rewardVault.getRewardBuckets();

    assertEq(rewardBuckets.operatorBase.rewardDurationEndsAt, 0);
    assertEq(rewardBuckets.communityBase.rewardDurationEndsAt, firstEnding);
    assertEq(rewardBuckets.operatorDelegated.rewardDurationEndsAt, firstEnding);

    skip(duration + delay);
    s_rewardVault.addReward(address(s_communityStakingPool), REWARD_AMOUNT, EMISSION_RATE);
    rewardBuckets = s_rewardVault.getRewardBuckets();

    assertEq(rewardBuckets.operatorBase.rewardDurationEndsAt, 0);
    assertEq(rewardBuckets.communityBase.rewardDurationEndsAt, secondEndingWithDelay);
    assertEq(rewardBuckets.operatorDelegated.rewardDurationEndsAt, secondEndingWithDelay);
  }

  function test_RevertWhen_AddRewardAmountLessThanEmissionRate() public {
    uint256 rewardAmount = 5 ether; // 5 link
    uint256 emissionRate = 10 ether; // 10 link per sec

    changePrank(REWARDER);
    vm.expectRevert(RewardVault.RewardDurationTooShort.selector);
    s_rewardVault.addReward(address(s_communityStakingPool), rewardAmount, emissionRate);
  }
}

contract RewardVault_AddReward_AllRewardBuckets_WithDelegation is
  IRewardVault_AddReward_UpdateBucket,
  BaseTest
{
  function test_InitializeRewardDuration() public {
    uint256 duration = REWARD_AMOUNT / EMISSION_RATE;
    RewardVault.RewardBuckets memory rewardBuckets = s_rewardVault.getRewardBuckets();

    assertEq(rewardBuckets.operatorBase.rewardDurationEndsAt, 0);
    assertEq(rewardBuckets.communityBase.rewardDurationEndsAt, 0);
    assertEq(rewardBuckets.operatorDelegated.rewardDurationEndsAt, 0);

    changePrank(REWARDER);
    s_rewardVault.addReward(address(0), REWARD_AMOUNT, EMISSION_RATE);
    rewardBuckets = s_rewardVault.getRewardBuckets();

    assertEq(rewardBuckets.operatorBase.rewardDurationEndsAt, duration + TEST_START_TIME);
    assertEq(rewardBuckets.communityBase.rewardDurationEndsAt, duration + TEST_START_TIME);
    assertEq(rewardBuckets.operatorDelegated.rewardDurationEndsAt, duration + TEST_START_TIME);
  }

  function test_InitializeEmissionRate() public {
    // calculate pool reward amount
    uint256 communityCommunityMaxSize = s_communityStakingPool.getMaxPoolSize();
    uint256 operatorPoolMaxSize = s_operatorStakingPool.getMaxPoolSize();
    uint256 totalPoolMaxSize = communityCommunityMaxSize + operatorPoolMaxSize;
    uint256 communityCommunityReward = REWARD_AMOUNT * communityCommunityMaxSize / totalPoolMaxSize;
    uint256 operatorPoolReward = REWARD_AMOUNT * operatorPoolMaxSize / totalPoolMaxSize;

    // calculate the expected pool rates
    uint256 expectedOperatorRate = EMISSION_RATE * operatorPoolReward / REWARD_AMOUNT;
    uint256 expectedCommunityRate = EMISSION_RATE * communityCommunityReward / REWARD_AMOUNT;
    uint256 expectedDelegationRate = expectedCommunityRate / DELEGATION_RATE_DENOMINATOR;
    expectedCommunityRate -= expectedDelegationRate;

    assertEq(expectedOperatorRate + expectedCommunityRate + expectedDelegationRate, EMISSION_RATE);

    RewardVault.RewardBuckets memory rewardBuckets = s_rewardVault.getRewardBuckets();

    assertEq(rewardBuckets.operatorBase.emissionRate, 0);
    assertEq(rewardBuckets.communityBase.emissionRate, 0);
    assertEq(rewardBuckets.operatorDelegated.emissionRate, 0);

    changePrank(REWARDER);
    s_rewardVault.addReward(address(0), REWARD_AMOUNT, EMISSION_RATE);
    rewardBuckets = s_rewardVault.getRewardBuckets();

    assertEq(rewardBuckets.operatorBase.emissionRate, expectedOperatorRate);
    assertEq(rewardBuckets.communityBase.emissionRate, expectedCommunityRate);
    assertEq(rewardBuckets.operatorDelegated.emissionRate, expectedDelegationRate);
  }

  function test_UpdateEmissionRate() public {
    // calculate pool reward amount
    uint256 communityCommunityMaxSize = s_communityStakingPool.getMaxPoolSize();
    uint256 operatorPoolMaxSize = s_operatorStakingPool.getMaxPoolSize();
    uint256 totalPoolMaxSize = communityCommunityMaxSize + operatorPoolMaxSize;
    uint256 communityCommunityReward = REWARD_AMOUNT * communityCommunityMaxSize / totalPoolMaxSize;
    uint256 operatorPoolReward = REWARD_AMOUNT * operatorPoolMaxSize / totalPoolMaxSize;

    // calculate the expected pool rates
    uint256 expectedOperatorRate = EMISSION_RATE * operatorPoolReward / REWARD_AMOUNT;
    uint256 expectedCommunityRate = EMISSION_RATE * communityCommunityReward / REWARD_AMOUNT;
    uint256 expectedDelegationRate = expectedCommunityRate / DELEGATION_RATE_DENOMINATOR;
    expectedCommunityRate -= expectedDelegationRate;

    assertEq(expectedOperatorRate + expectedCommunityRate + expectedDelegationRate, EMISSION_RATE);

    changePrank(REWARDER);
    s_rewardVault.addReward(address(0), REWARD_AMOUNT, EMISSION_RATE);
    RewardVault.RewardBuckets memory rewardBuckets = s_rewardVault.getRewardBuckets();

    assertEq(rewardBuckets.operatorBase.emissionRate, expectedOperatorRate);
    assertEq(rewardBuckets.communityBase.emissionRate, expectedCommunityRate);
    assertEq(rewardBuckets.operatorDelegated.emissionRate, expectedDelegationRate);

    s_rewardVault.addReward(address(0), REWARD_AMOUNT, EMISSION_RATE * 2);
    rewardBuckets = s_rewardVault.getRewardBuckets();

    assertEq(rewardBuckets.operatorBase.emissionRate, expectedOperatorRate * 2);
    assertEq(rewardBuckets.communityBase.emissionRate, expectedCommunityRate * 2);
    assertEq(rewardBuckets.operatorDelegated.emissionRate, expectedDelegationRate * 2);
  }

  function test_IncreaseRewardDurationWithMoreRewardsSameRate() public {
    // calculate pool reward amount
    uint256 communityCommunityMaxSize = s_communityStakingPool.getMaxPoolSize();
    uint256 operatorPoolMaxSize = s_operatorStakingPool.getMaxPoolSize();
    uint256 totalPoolMaxSize = communityCommunityMaxSize + operatorPoolMaxSize;
    uint256 communityCommunityReward = REWARD_AMOUNT * communityCommunityMaxSize / totalPoolMaxSize;
    uint256 operatorPoolReward = REWARD_AMOUNT * operatorPoolMaxSize / totalPoolMaxSize;

    // calculate the expected pool rates
    uint256 expectedOperatorRate = EMISSION_RATE * operatorPoolReward / REWARD_AMOUNT;
    uint256 expectedCommunityRate = EMISSION_RATE * communityCommunityReward / REWARD_AMOUNT;
    uint256 expectedDelegationRate = expectedCommunityRate / DELEGATION_RATE_DENOMINATOR;
    expectedCommunityRate -= expectedDelegationRate;

    // calculate the duration
    uint256 duration = REWARD_AMOUNT / EMISSION_RATE;
    uint256 firstEnding = duration + TEST_START_TIME;
    uint256 secondEnding = duration * 2 + TEST_START_TIME;

    changePrank(REWARDER);
    s_rewardVault.addReward(address(0), REWARD_AMOUNT, EMISSION_RATE);
    RewardVault.RewardBuckets memory rewardBuckets = s_rewardVault.getRewardBuckets();

    assertEq(rewardBuckets.operatorBase.rewardDurationEndsAt, firstEnding);
    assertEq(rewardBuckets.communityBase.rewardDurationEndsAt, firstEnding);
    assertEq(rewardBuckets.operatorDelegated.rewardDurationEndsAt, firstEnding);

    assertEq(rewardBuckets.operatorBase.emissionRate, expectedOperatorRate);
    assertEq(rewardBuckets.communityBase.emissionRate, expectedCommunityRate);
    assertEq(rewardBuckets.operatorDelegated.emissionRate, expectedDelegationRate);

    s_rewardVault.addReward(address(0), REWARD_AMOUNT, EMISSION_RATE);
    rewardBuckets = s_rewardVault.getRewardBuckets();

    assertEq(rewardBuckets.operatorBase.rewardDurationEndsAt, secondEnding);
    assertEq(rewardBuckets.communityBase.rewardDurationEndsAt, secondEnding);
    assertEq(rewardBuckets.operatorDelegated.rewardDurationEndsAt, secondEnding);

    assertEq(rewardBuckets.operatorBase.emissionRate, expectedOperatorRate);
    assertEq(rewardBuckets.communityBase.emissionRate, expectedCommunityRate);
    assertEq(rewardBuckets.operatorDelegated.emissionRate, expectedDelegationRate);
  }

  function test_IncreaseRewardDurationWithZeroRewardAmountAndSlowerRate() public {
    // calculate pool reward amount
    uint256 communityCommunityMaxSize = s_communityStakingPool.getMaxPoolSize();
    uint256 operatorPoolMaxSize = s_operatorStakingPool.getMaxPoolSize();
    uint256 totalPoolMaxSize = communityCommunityMaxSize + operatorPoolMaxSize;
    uint256 communityCommunityReward = REWARD_AMOUNT * communityCommunityMaxSize / totalPoolMaxSize;
    uint256 operatorPoolReward = REWARD_AMOUNT * operatorPoolMaxSize / totalPoolMaxSize;

    // calculate the expected pool rates
    uint256 expectedOperatorRate = EMISSION_RATE * operatorPoolReward / REWARD_AMOUNT;
    uint256 expectedCommunityRate = EMISSION_RATE * communityCommunityReward / REWARD_AMOUNT;
    uint256 expectedDelegationRate = expectedCommunityRate / DELEGATION_RATE_DENOMINATOR;
    expectedCommunityRate -= expectedDelegationRate;

    // calculate the duration
    uint256 duration = REWARD_AMOUNT / EMISSION_RATE;
    uint256 firstEnding = duration + TEST_START_TIME;
    uint256 secondEnding = duration * 2 + TEST_START_TIME;

    changePrank(REWARDER);
    s_rewardVault.addReward(address(0), REWARD_AMOUNT, EMISSION_RATE);
    RewardVault.RewardBuckets memory rewardBuckets = s_rewardVault.getRewardBuckets();

    assertEq(rewardBuckets.operatorBase.rewardDurationEndsAt, firstEnding);
    assertEq(rewardBuckets.communityBase.rewardDurationEndsAt, firstEnding);
    assertEq(rewardBuckets.operatorDelegated.rewardDurationEndsAt, firstEnding);

    assertEq(rewardBuckets.operatorBase.emissionRate, expectedOperatorRate);
    assertEq(rewardBuckets.communityBase.emissionRate, expectedCommunityRate);
    assertEq(rewardBuckets.operatorDelegated.emissionRate, expectedDelegationRate);

    s_rewardVault.addReward(address(0), 0, EMISSION_RATE / 2);
    rewardBuckets = s_rewardVault.getRewardBuckets();

    assertEq(rewardBuckets.operatorBase.rewardDurationEndsAt, secondEnding);
    assertEq(rewardBuckets.communityBase.rewardDurationEndsAt, secondEnding);
    assertEq(rewardBuckets.operatorDelegated.rewardDurationEndsAt, secondEnding);

    assertEq(rewardBuckets.operatorBase.emissionRate, expectedOperatorRate / 2);
    assertEq(rewardBuckets.communityBase.emissionRate, expectedCommunityRate / 2);
    assertEq(rewardBuckets.operatorDelegated.emissionRate, expectedDelegationRate / 2);
  }

  function test_DecreaseRewardDurationWithZeroRewardAmountAndFasterRate() public {
    // calculate pool reward amount
    uint256 communityCommunityMaxSize = s_communityStakingPool.getMaxPoolSize();
    uint256 operatorPoolMaxSize = s_operatorStakingPool.getMaxPoolSize();
    uint256 totalPoolMaxSize = communityCommunityMaxSize + operatorPoolMaxSize;
    uint256 communityCommunityReward = REWARD_AMOUNT * communityCommunityMaxSize / totalPoolMaxSize;
    uint256 operatorPoolReward = REWARD_AMOUNT * operatorPoolMaxSize / totalPoolMaxSize;

    // calculate the expected pool rates
    uint256 expectedOperatorRate = EMISSION_RATE * operatorPoolReward / REWARD_AMOUNT;
    uint256 expectedCommunityRate = EMISSION_RATE * communityCommunityReward / REWARD_AMOUNT;
    uint256 expectedDelegationRate = expectedCommunityRate / DELEGATION_RATE_DENOMINATOR;
    expectedCommunityRate -= expectedDelegationRate;

    // calculate the duration
    uint256 duration = REWARD_AMOUNT / EMISSION_RATE;
    uint256 firstEnding = duration + TEST_START_TIME;
    uint256 secondEnding = duration / 2 + TEST_START_TIME;

    changePrank(REWARDER);
    s_rewardVault.addReward(address(0), REWARD_AMOUNT, EMISSION_RATE);
    RewardVault.RewardBuckets memory rewardBuckets = s_rewardVault.getRewardBuckets();

    assertEq(rewardBuckets.operatorBase.rewardDurationEndsAt, firstEnding);
    assertEq(rewardBuckets.communityBase.rewardDurationEndsAt, firstEnding);
    assertEq(rewardBuckets.operatorDelegated.rewardDurationEndsAt, firstEnding);

    assertEq(rewardBuckets.operatorBase.emissionRate, expectedOperatorRate);
    assertEq(rewardBuckets.communityBase.emissionRate, expectedCommunityRate);
    assertEq(rewardBuckets.operatorDelegated.emissionRate, expectedDelegationRate);

    s_rewardVault.addReward(address(0), 0, EMISSION_RATE * 2);
    rewardBuckets = s_rewardVault.getRewardBuckets();

    assertEq(rewardBuckets.operatorBase.rewardDurationEndsAt, secondEnding);
    assertEq(rewardBuckets.communityBase.rewardDurationEndsAt, secondEnding);
    assertEq(rewardBuckets.operatorDelegated.rewardDurationEndsAt, secondEnding);

    assertEq(rewardBuckets.operatorBase.emissionRate, expectedOperatorRate * 2);
    assertEq(rewardBuckets.communityBase.emissionRate, expectedCommunityRate * 2);
    assertEq(rewardBuckets.operatorDelegated.emissionRate, expectedDelegationRate * 2);
  }

  function test_TopUpRewardsAtConclusionOfOldRewards() public {
    uint256 duration = REWARD_AMOUNT / EMISSION_RATE;
    uint256 firstEnding = duration + TEST_START_TIME;
    uint256 secondEnding = duration * 2 + TEST_START_TIME;

    changePrank(REWARDER);
    s_rewardVault.addReward(address(0), REWARD_AMOUNT, EMISSION_RATE);
    RewardVault.RewardBuckets memory rewardBuckets = s_rewardVault.getRewardBuckets();

    assertEq(rewardBuckets.operatorBase.rewardDurationEndsAt, firstEnding);
    assertEq(rewardBuckets.communityBase.rewardDurationEndsAt, firstEnding);
    assertEq(rewardBuckets.operatorDelegated.rewardDurationEndsAt, firstEnding);

    skip(duration);
    s_rewardVault.addReward(address(0), REWARD_AMOUNT, EMISSION_RATE);
    rewardBuckets = s_rewardVault.getRewardBuckets();

    assertEq(rewardBuckets.operatorBase.rewardDurationEndsAt, secondEnding);
    assertEq(rewardBuckets.communityBase.rewardDurationEndsAt, secondEnding);
    assertEq(rewardBuckets.operatorDelegated.rewardDurationEndsAt, secondEnding);
  }

  function test_TopUpRewardsAfterConclusionOfOldRewards() public {
    uint256 duration = REWARD_AMOUNT / EMISSION_RATE;
    uint256 delay = 100;
    uint256 firstEnding = duration + TEST_START_TIME;
    uint256 secondEnding = duration * 2 + TEST_START_TIME;
    uint256 secondEndingWithDelay = secondEnding + delay;

    changePrank(REWARDER);
    s_rewardVault.addReward(address(0), REWARD_AMOUNT, EMISSION_RATE);
    RewardVault.RewardBuckets memory rewardBuckets = s_rewardVault.getRewardBuckets();

    assertEq(rewardBuckets.operatorBase.rewardDurationEndsAt, firstEnding);
    assertEq(rewardBuckets.communityBase.rewardDurationEndsAt, firstEnding);
    assertEq(rewardBuckets.operatorDelegated.rewardDurationEndsAt, firstEnding);

    skip(duration + delay);
    s_rewardVault.addReward(address(0), REWARD_AMOUNT, EMISSION_RATE);
    rewardBuckets = s_rewardVault.getRewardBuckets();

    assertEq(rewardBuckets.operatorBase.rewardDurationEndsAt, secondEndingWithDelay);
    assertEq(rewardBuckets.communityBase.rewardDurationEndsAt, secondEndingWithDelay);
    assertEq(rewardBuckets.operatorDelegated.rewardDurationEndsAt, secondEndingWithDelay);
  }

  function test_RevertWhen_AddRewardAmountLessThanEmissionRate() public {
    uint256 rewardAmount = 5 ether; // 5 link
    uint256 emissionRate = 10 ether; // 10 link per sec

    changePrank(REWARDER);
    vm.expectRevert(RewardVault.RewardDurationTooShort.selector);
    s_rewardVault.addReward(address(0), rewardAmount, emissionRate);
  }
}

contract RewardVault_AddReward_AllRewardBuckets_WithoutDelegation is
  RewardVault_DelegationDenominatorIsZero,
  IRewardVault_AddReward_UpdateBucket
{
  function test_InitializeRewardDuration() public {
    uint256 duration = REWARD_AMOUNT / EMISSION_RATE;

    changePrank(REWARDER);

    RewardVault.RewardBuckets memory rewardBuckets = s_rewardVault.getRewardBuckets();

    assertEq(rewardBuckets.operatorBase.rewardDurationEndsAt, 0);
    assertEq(rewardBuckets.communityBase.rewardDurationEndsAt, 0);
    assertEq(rewardBuckets.operatorDelegated.rewardDurationEndsAt, 0);

    s_rewardVault.addReward(address(0), REWARD_AMOUNT, EMISSION_RATE);
    rewardBuckets = s_rewardVault.getRewardBuckets();

    assertEq(rewardBuckets.operatorBase.rewardDurationEndsAt, duration + TEST_START_TIME);
    assertEq(rewardBuckets.communityBase.rewardDurationEndsAt, duration + TEST_START_TIME);
    assertEq(rewardBuckets.operatorDelegated.rewardDurationEndsAt, 0);
  }

  function test_InitializeEmissionRate() public {
    // calculate pool reward amount
    uint256 communityCommunityMaxSize = s_communityStakingPool.getMaxPoolSize();
    uint256 operatorPoolMaxSize = s_operatorStakingPool.getMaxPoolSize();
    uint256 totalPoolMaxSize = communityCommunityMaxSize + operatorPoolMaxSize;
    uint256 communityCommunityReward = REWARD_AMOUNT * communityCommunityMaxSize / totalPoolMaxSize;
    uint256 operatorPoolReward = REWARD_AMOUNT * operatorPoolMaxSize / totalPoolMaxSize;

    // calculate the expected pool rates
    uint256 expectedOperatorRate = EMISSION_RATE * operatorPoolReward / REWARD_AMOUNT;
    uint256 expectedCommunityRate = EMISSION_RATE * communityCommunityReward / REWARD_AMOUNT;

    changePrank(REWARDER);

    RewardVault.RewardBuckets memory rewardBuckets = s_rewardVault.getRewardBuckets();

    assertEq(rewardBuckets.operatorBase.emissionRate, 0);
    assertEq(rewardBuckets.communityBase.emissionRate, 0);
    assertEq(rewardBuckets.operatorDelegated.emissionRate, 0);

    s_rewardVault.addReward(address(0), REWARD_AMOUNT, EMISSION_RATE);
    rewardBuckets = s_rewardVault.getRewardBuckets();

    assertEq(rewardBuckets.operatorBase.emissionRate, expectedOperatorRate);
    assertEq(rewardBuckets.communityBase.emissionRate, expectedCommunityRate);
    assertEq(rewardBuckets.operatorDelegated.emissionRate, 0);
  }

  function test_UpdateEmissionRate() public {
    // calculate pool reward amount
    uint256 communityCommunityMaxSize = s_communityStakingPool.getMaxPoolSize();
    uint256 operatorPoolMaxSize = s_operatorStakingPool.getMaxPoolSize();
    uint256 totalPoolMaxSize = communityCommunityMaxSize + operatorPoolMaxSize;
    uint256 communityCommunityReward = REWARD_AMOUNT * communityCommunityMaxSize / totalPoolMaxSize;
    uint256 operatorPoolReward = REWARD_AMOUNT * operatorPoolMaxSize / totalPoolMaxSize;

    // calculate the expected pool rates
    uint256 expectedOperatorRate = EMISSION_RATE * operatorPoolReward / REWARD_AMOUNT;
    uint256 expectedCommunityRate = EMISSION_RATE * communityCommunityReward / REWARD_AMOUNT;

    assertEq(expectedOperatorRate + expectedCommunityRate, EMISSION_RATE);

    changePrank(REWARDER);
    s_rewardVault.addReward(address(0), REWARD_AMOUNT, EMISSION_RATE);
    RewardVault.RewardBuckets memory rewardBuckets = s_rewardVault.getRewardBuckets();

    assertEq(rewardBuckets.operatorBase.emissionRate, expectedOperatorRate);
    assertEq(rewardBuckets.communityBase.emissionRate, expectedCommunityRate);
    assertEq(rewardBuckets.operatorDelegated.emissionRate, 0);

    s_rewardVault.addReward(address(0), REWARD_AMOUNT, EMISSION_RATE * 2);
    rewardBuckets = s_rewardVault.getRewardBuckets();

    assertEq(rewardBuckets.operatorBase.emissionRate, expectedOperatorRate * 2);
    assertEq(rewardBuckets.communityBase.emissionRate, expectedCommunityRate * 2);
    assertEq(rewardBuckets.operatorDelegated.emissionRate, 0);
  }

  function test_IncreaseRewardDurationWithMoreRewardsSameRate() public {
    // calculate pool reward amount
    uint256 communityCommunityMaxSize = s_communityStakingPool.getMaxPoolSize();
    uint256 operatorPoolMaxSize = s_operatorStakingPool.getMaxPoolSize();
    uint256 totalPoolMaxSize = communityCommunityMaxSize + operatorPoolMaxSize;
    uint256 communityCommunityReward = REWARD_AMOUNT * communityCommunityMaxSize / totalPoolMaxSize;
    uint256 operatorPoolReward = REWARD_AMOUNT * operatorPoolMaxSize / totalPoolMaxSize;

    // calculate the expected pool rates
    uint256 expectedOperatorRate = EMISSION_RATE * operatorPoolReward / REWARD_AMOUNT;
    uint256 expectedCommunityRate = EMISSION_RATE * communityCommunityReward / REWARD_AMOUNT;

    // calculate the duration
    uint256 duration = REWARD_AMOUNT / EMISSION_RATE;
    uint256 firstEnding = duration + TEST_START_TIME;
    uint256 secondEnding = duration * 2 + TEST_START_TIME;

    changePrank(REWARDER);
    s_rewardVault.addReward(address(0), REWARD_AMOUNT, EMISSION_RATE);
    RewardVault.RewardBuckets memory rewardBuckets = s_rewardVault.getRewardBuckets();

    assertEq(rewardBuckets.operatorBase.rewardDurationEndsAt, firstEnding);
    assertEq(rewardBuckets.communityBase.rewardDurationEndsAt, firstEnding);
    assertEq(rewardBuckets.operatorDelegated.rewardDurationEndsAt, 0);

    assertEq(rewardBuckets.operatorBase.emissionRate, expectedOperatorRate);
    assertEq(rewardBuckets.communityBase.emissionRate, expectedCommunityRate);
    assertEq(rewardBuckets.operatorDelegated.emissionRate, 0);

    s_rewardVault.addReward(address(0), REWARD_AMOUNT, EMISSION_RATE);
    rewardBuckets = s_rewardVault.getRewardBuckets();

    assertEq(rewardBuckets.operatorBase.rewardDurationEndsAt, secondEnding);
    assertEq(rewardBuckets.communityBase.rewardDurationEndsAt, secondEnding);
    assertEq(rewardBuckets.operatorDelegated.rewardDurationEndsAt, 0);

    assertEq(rewardBuckets.operatorBase.emissionRate, expectedOperatorRate);
    assertEq(rewardBuckets.communityBase.emissionRate, expectedCommunityRate);
    assertEq(rewardBuckets.operatorDelegated.emissionRate, 0);
  }

  function test_IncreaseRewardDurationWithZeroRewardAmountAndSlowerRate() public {
    // calculate pool reward amount
    uint256 communityCommunityMaxSize = s_communityStakingPool.getMaxPoolSize();
    uint256 operatorPoolMaxSize = s_operatorStakingPool.getMaxPoolSize();
    uint256 totalPoolMaxSize = communityCommunityMaxSize + operatorPoolMaxSize;
    uint256 communityCommunityReward = REWARD_AMOUNT * communityCommunityMaxSize / totalPoolMaxSize;
    uint256 operatorPoolReward = REWARD_AMOUNT * operatorPoolMaxSize / totalPoolMaxSize;

    // calculate the expected pool rates
    uint256 expectedOperatorRate = EMISSION_RATE * operatorPoolReward / REWARD_AMOUNT;
    uint256 expectedCommunityRate = EMISSION_RATE * communityCommunityReward / REWARD_AMOUNT;

    // calculate the duration
    uint256 duration = REWARD_AMOUNT / EMISSION_RATE;
    uint256 firstEnding = duration + TEST_START_TIME;
    uint256 secondEnding = duration * 2 + TEST_START_TIME;

    changePrank(REWARDER);
    s_rewardVault.addReward(address(0), REWARD_AMOUNT, EMISSION_RATE);
    RewardVault.RewardBuckets memory rewardBuckets = s_rewardVault.getRewardBuckets();

    assertEq(rewardBuckets.operatorBase.rewardDurationEndsAt, firstEnding);
    assertEq(rewardBuckets.communityBase.rewardDurationEndsAt, firstEnding);
    assertEq(rewardBuckets.operatorDelegated.rewardDurationEndsAt, 0);

    assertEq(rewardBuckets.operatorBase.emissionRate, expectedOperatorRate);
    assertEq(rewardBuckets.communityBase.emissionRate, expectedCommunityRate);
    assertEq(rewardBuckets.operatorDelegated.emissionRate, 0);

    s_rewardVault.addReward(address(0), 0, EMISSION_RATE / 2);
    rewardBuckets = s_rewardVault.getRewardBuckets();

    assertEq(rewardBuckets.operatorBase.rewardDurationEndsAt, secondEnding);
    assertEq(rewardBuckets.communityBase.rewardDurationEndsAt, secondEnding);
    assertEq(rewardBuckets.operatorDelegated.rewardDurationEndsAt, 0);

    assertEq(rewardBuckets.operatorBase.emissionRate, expectedOperatorRate / 2);
    assertEq(rewardBuckets.communityBase.emissionRate, expectedCommunityRate / 2);
    assertEq(rewardBuckets.operatorDelegated.emissionRate, 0);
  }

  function test_DecreaseRewardDurationWithZeroRewardAmountAndFasterRate() public {
    // calculate pool reward amount
    uint256 communityCommunityMaxSize = s_communityStakingPool.getMaxPoolSize();
    uint256 operatorPoolMaxSize = s_operatorStakingPool.getMaxPoolSize();
    uint256 totalPoolMaxSize = communityCommunityMaxSize + operatorPoolMaxSize;
    uint256 communityCommunityReward = REWARD_AMOUNT * communityCommunityMaxSize / totalPoolMaxSize;
    uint256 operatorPoolReward = REWARD_AMOUNT * operatorPoolMaxSize / totalPoolMaxSize;

    // calculate the expected pool rates
    uint256 expectedOperatorRate = EMISSION_RATE * operatorPoolReward / REWARD_AMOUNT;
    uint256 expectedCommunityRate = EMISSION_RATE * communityCommunityReward / REWARD_AMOUNT;

    // calculate the duration
    uint256 duration = REWARD_AMOUNT / EMISSION_RATE;
    uint256 firstEnding = duration + TEST_START_TIME;
    uint256 secondEnding = duration / 2 + TEST_START_TIME;

    changePrank(REWARDER);
    s_rewardVault.addReward(address(0), REWARD_AMOUNT, EMISSION_RATE);
    RewardVault.RewardBuckets memory rewardBuckets = s_rewardVault.getRewardBuckets();

    assertEq(rewardBuckets.operatorBase.rewardDurationEndsAt, firstEnding);
    assertEq(rewardBuckets.communityBase.rewardDurationEndsAt, firstEnding);
    assertEq(rewardBuckets.operatorDelegated.rewardDurationEndsAt, 0);

    assertEq(rewardBuckets.operatorBase.emissionRate, expectedOperatorRate);
    assertEq(rewardBuckets.communityBase.emissionRate, expectedCommunityRate);
    assertEq(rewardBuckets.operatorDelegated.emissionRate, 0);

    s_rewardVault.addReward(address(0), 0, EMISSION_RATE * 2);
    rewardBuckets = s_rewardVault.getRewardBuckets();

    assertEq(rewardBuckets.operatorBase.rewardDurationEndsAt, secondEnding);
    assertEq(rewardBuckets.communityBase.rewardDurationEndsAt, secondEnding);
    assertEq(rewardBuckets.operatorDelegated.rewardDurationEndsAt, 0);

    assertEq(rewardBuckets.operatorBase.emissionRate, expectedOperatorRate * 2);
    assertEq(rewardBuckets.communityBase.emissionRate, expectedCommunityRate * 2);
    assertEq(rewardBuckets.operatorDelegated.emissionRate, 0);
  }

  function test_TopUpRewardsAtConclusionOfOldRewards() public {
    uint256 duration = REWARD_AMOUNT / EMISSION_RATE;
    uint256 firstEnding = duration + TEST_START_TIME;
    uint256 secondEnding = duration * 2 + TEST_START_TIME;

    changePrank(REWARDER);
    s_rewardVault.addReward(address(0), REWARD_AMOUNT, EMISSION_RATE);
    RewardVault.RewardBuckets memory rewardBuckets = s_rewardVault.getRewardBuckets();

    assertEq(rewardBuckets.operatorBase.rewardDurationEndsAt, firstEnding);
    assertEq(rewardBuckets.communityBase.rewardDurationEndsAt, firstEnding);
    assertEq(rewardBuckets.operatorDelegated.rewardDurationEndsAt, 0);

    skip(duration);
    s_rewardVault.addReward(address(0), REWARD_AMOUNT, EMISSION_RATE);
    rewardBuckets = s_rewardVault.getRewardBuckets();

    assertEq(rewardBuckets.operatorBase.rewardDurationEndsAt, secondEnding);
    assertEq(rewardBuckets.communityBase.rewardDurationEndsAt, secondEnding);
    assertEq(rewardBuckets.operatorDelegated.rewardDurationEndsAt, 0);
  }

  function test_TopUpRewardsAfterConclusionOfOldRewards() public {
    uint256 duration = REWARD_AMOUNT / EMISSION_RATE;
    uint256 delay = 100;
    uint256 firstEnding = duration + TEST_START_TIME;
    uint256 secondEnding = duration * 2 + TEST_START_TIME;
    uint256 secondEndingWithDelay = secondEnding + delay;

    changePrank(REWARDER);
    s_rewardVault.addReward(address(0), REWARD_AMOUNT, EMISSION_RATE);
    RewardVault.RewardBuckets memory rewardBuckets = s_rewardVault.getRewardBuckets();

    assertEq(rewardBuckets.operatorBase.rewardDurationEndsAt, firstEnding);
    assertEq(rewardBuckets.communityBase.rewardDurationEndsAt, firstEnding);
    assertEq(rewardBuckets.operatorDelegated.rewardDurationEndsAt, 0);

    skip(duration + delay);
    s_rewardVault.addReward(address(0), REWARD_AMOUNT, EMISSION_RATE);
    rewardBuckets = s_rewardVault.getRewardBuckets();

    assertEq(rewardBuckets.operatorBase.rewardDurationEndsAt, secondEndingWithDelay);
    assertEq(rewardBuckets.communityBase.rewardDurationEndsAt, secondEndingWithDelay);
    assertEq(rewardBuckets.operatorDelegated.rewardDurationEndsAt, 0);
  }

  function test_RevertWhen_AddRewardAmountLessThanEmissionRate() public {
    uint256 rewardAmount = 5 ether; // 5 link
    uint256 emissionRate = 10 ether; // 10 link per sec

    changePrank(REWARDER);
    vm.expectRevert(RewardVault.RewardDurationTooShort.selector);
    s_rewardVault.addReward(address(0), rewardAmount, emissionRate);
  }
}

contract RewardVault_AddReward_AllRewardBuckets_RoundingTowardsZero_WithDelegation is
  RewardVault_ConfigurablePoolSizes_DelegationDenominatorNotZero
{
  function test_RevertWhen_CommunityRewardIsLessThanDelegationDenominator() public {
    uint256 rewardAmount = 30;
    uint256 emissionRate = 20;
    uint256 maxCommunityPoolSize = 100 * DECIMALS;
    uint256 maxOperatorPoolSize = 100 * DECIMALS;

    // Refer to RewardVault:_checkForRoundingToZeroRewardAmountSplit
    // Ensures trigger for revert is not caused by reward amount split
    assert(
      rewardAmount * maxCommunityPoolSize / DECIMALS * DECIMALS
        >= maxCommunityPoolSize + maxOperatorPoolSize
    );
    assert(
      rewardAmount * maxOperatorPoolSize / DECIMALS * DECIMALS
        >= maxCommunityPoolSize + maxOperatorPoolSize
    );

    changePrank(OWNER);
    s_communityStakingPool.setPoolConfig(maxCommunityPoolSize, INITIAL_MAX_PRINCIPAL_PER_STAKER);
    s_operatorStakingPool.setPoolConfig(maxOperatorPoolSize, INITIAL_MAX_PRINCIPAL_PER_STAKER);

    changePrank(REWARDER);
    vm.expectRevert(RewardVault.InvalidRewardAmount.selector);
    s_rewardVault.addReward(address(0), rewardAmount, emissionRate);
  }

  function test_RevertWhen_CommunityEmissionRateIsLessThanDelegationDenominator() public {
    uint256 rewardAmount = 400;
    uint256 emissionRate = 20;
    uint256 maxCommunityPoolSize = 100 * DECIMALS;
    uint256 maxOperatorPoolSize = 100 * DECIMALS;

    // Refer to RewardVault:_checkForRoundingToZeroEmissionRateSplit
    // Ensures trigger for revert is not caused by emission split
    assert(
      emissionRate * maxCommunityPoolSize / DECIMALS * DECIMALS
        >= maxCommunityPoolSize + maxOperatorPoolSize
    );
    assert(
      emissionRate * maxOperatorPoolSize / DECIMALS * DECIMALS
        >= maxCommunityPoolSize + maxOperatorPoolSize
    );

    changePrank(OWNER);
    s_communityStakingPool.setPoolConfig(maxCommunityPoolSize, INITIAL_MAX_PRINCIPAL_PER_STAKER);
    s_operatorStakingPool.setPoolConfig(maxOperatorPoolSize, INITIAL_MAX_PRINCIPAL_PER_STAKER);

    changePrank(REWARDER);
    vm.expectRevert(RewardVault.InvalidEmissionRate.selector);
    s_rewardVault.addReward(address(0), rewardAmount, emissionRate);
  }
}

contract RewardVault_AddReward_AllRewardBuckets_RoundingTowardsZero_WithoutDelegation is
  RewardVault_ConfigurablePoolSizes_DelegationDenominatorIsZero
{
  function test_RevertWhen_CommunityRewardIsRoundedTowardsZero() public {
    uint256 rewardAmount = 2;
    uint256 emissionRate = 5;
    uint256 maxCommunityPoolSize = 10 * DECIMALS;
    uint256 maxOperatorPoolSize = 60 * DECIMALS;

    // Refer to RewardVault:_checkForRoundingToZeroRewardAmountSplit
    // Ensures trigger for revert is not caused by operator reward
    assert(
      rewardAmount * maxOperatorPoolSize / DECIMALS * DECIMALS
        >= maxCommunityPoolSize + maxOperatorPoolSize
    );

    changePrank(OWNER);
    s_communityStakingPool.setPoolConfig(maxCommunityPoolSize, INITIAL_MAX_PRINCIPAL_PER_STAKER);
    s_operatorStakingPool.setPoolConfig(maxOperatorPoolSize, INITIAL_MAX_PRINCIPAL_PER_STAKER);

    changePrank(REWARDER);
    vm.expectRevert(RewardVault.InvalidRewardAmount.selector);
    s_rewardVault.addReward(address(0), rewardAmount, emissionRate);
  }

  function test_RevertWhen_OperatorRewardIsRoundedTowardsZero() public {
    uint256 rewardAmount = 2;
    uint256 emissionRate = 5;
    uint256 maxCommunityPoolSize = 60 * DECIMALS;
    uint256 maxOperatorPoolSize = 10 * DECIMALS;

    // Refer to RewardVault:_checkForRoundingToZeroRewardAmountSplit
    // Ensures trigger for revert is not caused by community reward
    assert(
      rewardAmount * maxCommunityPoolSize / DECIMALS * DECIMALS
        >= maxCommunityPoolSize + maxOperatorPoolSize
    );

    changePrank(OWNER);
    s_communityStakingPool.setPoolConfig(maxCommunityPoolSize, INITIAL_MAX_PRINCIPAL_PER_STAKER);
    s_operatorStakingPool.setPoolConfig(maxOperatorPoolSize, INITIAL_MAX_PRINCIPAL_PER_STAKER);

    changePrank(REWARDER);
    vm.expectRevert(RewardVault.InvalidRewardAmount.selector);
    s_rewardVault.addReward(address(0), rewardAmount, emissionRate);
  }

  function test_RevertWhen_CommunityEmissionRateIsRoundedTowardsZero() public {
    uint256 rewardAmount = 5;
    uint256 emissionRate = 2;
    uint256 maxCommunityPoolSize = 30 * DECIMALS;
    uint256 maxOperatorPoolSize = 70 * DECIMALS;

    // Refer to RewardVault:_checkForRoundingToZeroEmissionRateSplit
    // Ensures trigger for revert is not caused by operator aggregate reward rate
    assert(
      emissionRate * maxOperatorPoolSize / DECIMALS * DECIMALS
        >= maxCommunityPoolSize + maxOperatorPoolSize
    );

    changePrank(OWNER);
    s_communityStakingPool.setPoolConfig(maxCommunityPoolSize, INITIAL_MAX_PRINCIPAL_PER_STAKER);
    s_operatorStakingPool.setPoolConfig(maxOperatorPoolSize, INITIAL_MAX_PRINCIPAL_PER_STAKER);

    changePrank(REWARDER);
    vm.expectRevert(RewardVault.InvalidEmissionRate.selector);
    s_rewardVault.addReward(address(0), rewardAmount, emissionRate);
  }

  function test_RevertWhen_OperatorEmissionRateIsRoundedTowardsZero() public {
    uint256 rewardAmount = 5;
    uint256 emissionRate = 2;
    uint256 maxCommunityPoolSize = 70 * DECIMALS;
    uint256 maxOperatorPoolSize = 30 * DECIMALS;

    // Refer to RewardVault:_checkForRoundingToZeroEmissionRateSplit
    // Ensures trigger for revert is not caused by community aggregate reward rate
    assert(
      emissionRate * maxCommunityPoolSize / DECIMALS * DECIMALS
        >= maxCommunityPoolSize + maxOperatorPoolSize
    );

    changePrank(OWNER);
    s_communityStakingPool.setPoolConfig(maxCommunityPoolSize, INITIAL_MAX_PRINCIPAL_PER_STAKER);
    s_operatorStakingPool.setPoolConfig(maxOperatorPoolSize, INITIAL_MAX_PRINCIPAL_PER_STAKER);

    changePrank(REWARDER);
    vm.expectRevert(RewardVault.InvalidEmissionRate.selector);
    s_rewardVault.addReward(address(0), rewardAmount, emissionRate);
  }
}

contract RewardVault_AddReward_UpdatesRewardPerToken is
  IRewardVault_UpdateReward_UpdateOnlyPoolsWhenRewardAccrued,
  RewardVault_WithStakersAndTimePassed
{
  function test_UpdatesVestedRewardPerTokens() public {
    uint256 rewardPerTokenUpdatedAtBefore = s_rewardVault.getRewardPerTokenUpdatedAt();
    uint256 communityTotalPrincipalBefore = s_communityStakingPool.getTotalPrincipal();
    uint256 operatorTotalPrincipalBefore = s_operatorStakingPool.getTotalPrincipal();
    RewardVault.RewardBuckets memory bucketsBefore = s_rewardVault.getRewardBuckets();

    changePrank(REWARDER);
    s_rewardVault.addReward(address(0), REWARD_AMOUNT, EMISSION_RATE);

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

  function test_UpdatesRewardPerTokenUpdatedAt() public {
    changePrank(REWARDER);
    uint256 rewardPerTokenUpdatedAtBefore = s_rewardVault.getRewardPerTokenUpdatedAt();
    s_rewardVault.addReward(address(0), REWARD_AMOUNT, EMISSION_RATE);
    assertEq(s_rewardVault.getRewardPerTokenUpdatedAt(), block.timestamp);
    assertGt(s_rewardVault.getRewardPerTokenUpdatedAt(), rewardPerTokenUpdatedAtBefore);
  }
}

contract RewardVault_AddReward_WhenPaused is RewardVault_WhenPaused {
  using FixedPointMathLib for uint256;

  function test_RevertWhen_Paused() public {
    changePrank(REWARDER);
    vm.expectRevert('Pausable: paused');
    s_rewardVault.addReward(address(0), REWARD_AMOUNT, EMISSION_RATE);
  }

  function test_CanAddRewardAfterUnpausing() public {
    uint256 operatorMaxPoolSize = s_operatorStakingPool.getMaxPoolSize();
    uint256 communityMaxPoolSize = s_communityStakingPool.getMaxPoolSize();
    uint256 totalMaxPoolSize = operatorMaxPoolSize + communityMaxPoolSize;
    uint256 delegationRateDenominator = s_rewardVault.getDelegationRateDenominator();
    RewardVault.RewardBuckets memory bucketsBefore = s_rewardVault.getRewardBuckets();

    changePrank(PAUSER);
    s_rewardVault.emergencyUnpause();

    changePrank(REWARDER);
    s_rewardVault.addReward(address(0), REWARD_AMOUNT, EMISSION_RATE);
    RewardVault.RewardBuckets memory bucketsAfter = s_rewardVault.getRewardBuckets();
    uint256 operatorBaseRewardAmount =
      REWARD_AMOUNT.mulWadDown(operatorMaxPoolSize).divWadDown(totalMaxPoolSize);
    uint256 communityBaseRewardAmount = REWARD_AMOUNT - operatorBaseRewardAmount;
    uint256 operatorDelegatedRewardAmount = communityBaseRewardAmount / delegationRateDenominator;
    communityBaseRewardAmount -= operatorDelegatedRewardAmount;
    uint256 operatorBaseEmissionRate =
      EMISSION_RATE.mulWadDown(operatorMaxPoolSize).divWadDown(totalMaxPoolSize);
    uint256 communityBaseEmissionRate = EMISSION_RATE - operatorBaseEmissionRate;
    uint256 operatorDelegatedEmissionRate = communityBaseEmissionRate / delegationRateDenominator;
    communityBaseEmissionRate -= operatorDelegatedEmissionRate;
    assertEq(
      bucketsAfter.operatorBase.rewardDurationEndsAt,
      bucketsBefore.operatorBase.rewardDurationEndsAt
        + (operatorBaseRewardAmount / operatorBaseEmissionRate)
    );
    assertEq(
      bucketsAfter.communityBase.rewardDurationEndsAt,
      bucketsBefore.communityBase.rewardDurationEndsAt
        + (communityBaseRewardAmount / communityBaseEmissionRate)
    );
    assertEq(
      bucketsAfter.operatorDelegated.rewardDurationEndsAt,
      bucketsBefore.operatorDelegated.rewardDurationEndsAt
        + (operatorDelegatedRewardAmount / operatorDelegatedEmissionRate)
    );
    assertEq(bucketsAfter.operatorBase.emissionRate, operatorBaseEmissionRate);
    assertEq(bucketsAfter.communityBase.emissionRate, communityBaseEmissionRate);
    assertEq(bucketsAfter.operatorDelegated.emissionRate, operatorDelegatedEmissionRate);
  }
}

contract RewardVault_AddReward_WhenVaultClosed is RewardVault_WhenVaultClosed {
  function test_RevertWhen_VaultClosed() public {
    changePrank(REWARDER);
    vm.expectRevert(abi.encodeWithSelector(RewardVault.VaultAlreadyClosed.selector));
    s_rewardVault.addReward(STRANGER, REWARD_AMOUNT, EMISSION_RATE);
  }
}
