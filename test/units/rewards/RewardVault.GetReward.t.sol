// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {FixedPointMathLib} from '@solmate/utils/FixedPointMathLib.sol';

import {BaseTest} from '../../BaseTest.t.sol';
import {
  RewardVault_WithStakersAndTimeDidNotPass,
  RewardVault_WithStakersAndTimePassed,
  RewardVault_WithUpgradedVaultDeployedAndMigrated,
  RewardVault_WithUpgradedVaultDeployedAndMigratedMultipleTimes
} from '../../base-scenarios/RewardVaultScenarios.t.sol';

contract RewardVault_GetReward is RewardVault_WithStakersAndTimeDidNotPass {
  function test_IfNotStakerReturnZeroReward() public {
    assertEq(s_rewardVault.getReward(STRANGER), 0);
  }

  function test_IfCommunityStakerReturnReward() public {
    uint256 timePassed = 10 days;
    uint256 stakerPrincipal = s_communityStakingPool.getStakerPrincipal(COMMUNITY_STAKER_ONE);
    uint256 totalPrincipal = s_communityStakingPool.getTotalPrincipal();
    uint256 baseEmissionRate = s_rewardVault.getRewardBuckets().communityBase.emissionRate;
    uint256 baseRewardBefore =
      baseEmissionRate * (block.timestamp - s_stakedAtTime) * stakerPrincipal / totalPrincipal;

    skip(timePassed);

    uint256 multiplier = s_rewardVault.getMultiplier(COMMUNITY_STAKER_ONE);
    uint256 earnedBaseReward = stakerPrincipal * baseEmissionRate * timePassed / totalPrincipal;
    uint256 expectedReward =
      (baseRewardBefore + earnedBaseReward) * multiplier / FixedPointMathLib.WAD;

    assertEq(s_rewardVault.getReward(COMMUNITY_STAKER_ONE), expectedReward);
  }

  function test_IfOperatorStakerReturnReward() public {
    uint256 timePassed = 10 days;
    uint256 stakerPrincipal = s_operatorStakingPool.getStakerPrincipal(OPERATOR_STAKER_ONE);
    uint256 totalPrincipal = s_operatorStakingPool.getTotalPrincipal();
    uint256 baseEmissionRate = s_rewardVault.getRewardBuckets().operatorBase.emissionRate;
    uint256 delegatedEmissionRate = s_rewardVault.getRewardBuckets().operatorDelegated.emissionRate;
    uint256 baseRewardBefore =
      baseEmissionRate * (block.timestamp - s_stakedAtTime) * stakerPrincipal / totalPrincipal;
    uint256 operatorDelegatedRewardBefore =
      delegatedEmissionRate * (block.timestamp - s_stakedAtTime) * stakerPrincipal / totalPrincipal;

    skip(timePassed);

    uint256 multiplier = s_rewardVault.getMultiplier(OPERATOR_STAKER_ONE);
    uint256 earnedBaseReward = stakerPrincipal * baseEmissionRate * timePassed / totalPrincipal;
    uint256 earnedDelegatedReward =
      stakerPrincipal * delegatedEmissionRate * timePassed / totalPrincipal;
    uint256 expectedReward =
      (baseRewardBefore + earnedBaseReward) * multiplier / FixedPointMathLib.WAD;
    expectedReward += operatorDelegatedRewardBefore + earnedDelegatedReward;

    assertEq(s_rewardVault.getReward(OPERATOR_STAKER_ONE), expectedReward);
  }

  function test_GetRewardRemainsConstantIfCommunityPoolIsEmpty() public {
    // grow multipliers to max
    skip(INITIAL_MULTIPLIER_DURATION);

    // all stakers leave pool
    changePrank(COMMUNITY_STAKER_ONE);
    s_communityStakingPool.unbond();
    changePrank(COMMUNITY_STAKER_TWO);
    s_communityStakingPool.unbond();

    skip(UNBONDING_PERIOD);
    uint256 rewardBefore = s_rewardVault.getReward(COMMUNITY_STAKER_ONE);

    changePrank(COMMUNITY_STAKER_ONE);
    s_communityStakingPool.unstake(
      s_communityStakingPool.getStakerPrincipal(COMMUNITY_STAKER_ONE), false
    );
    changePrank(COMMUNITY_STAKER_TWO);
    s_communityStakingPool.unstake(
      s_communityStakingPool.getStakerPrincipal(COMMUNITY_STAKER_TWO), false
    );

    // grow multipliers back to max
    skip(INITIAL_MULTIPLIER_DURATION);

    assertEq(s_rewardVault.getReward(COMMUNITY_STAKER_ONE), rewardBefore);
  }

  function test_GetRewardRemainsConstantIfOperatorPoolIsEmpty() public {
    // grow multipliers to max
    skip(INITIAL_MULTIPLIER_DURATION);

    // all stakers leave pool
    changePrank(OPERATOR_STAKER_ONE);
    s_operatorStakingPool.unbond();
    changePrank(OPERATOR_STAKER_TWO);
    s_operatorStakingPool.unbond();

    skip(UNBONDING_PERIOD);
    uint256 rewardBefore = s_rewardVault.getReward(OPERATOR_STAKER_ONE);

    changePrank(OPERATOR_STAKER_ONE);
    s_operatorStakingPool.unstake(
      s_operatorStakingPool.getStakerPrincipal(OPERATOR_STAKER_ONE), false
    );
    changePrank(OPERATOR_STAKER_TWO);
    s_operatorStakingPool.unstake(
      s_operatorStakingPool.getStakerPrincipal(OPERATOR_STAKER_TWO), false
    );

    // grow multipliers back to max
    skip(INITIAL_MULTIPLIER_DURATION);

    assertEq(s_rewardVault.getReward(OPERATOR_STAKER_ONE), rewardBefore);
  }

  function test_StakingAgainDoesNotCauseStakerToLoseRewards() public {
    // Accrue some rewards
    skip(28 days);
    uint256 rewardBeforeStaking = s_rewardVault.getReward(COMMUNITY_STAKER_ONE);
    changePrank(COMMUNITY_STAKER_ONE);
    s_LINK.transferAndCall(
      address(s_communityStakingPool),
      COMMUNITY_MIN_PRINCIPAL,
      abi.encode(s_communityStakerOneProof)
    );
    assertGt(rewardBeforeStaking, 0);
    assertEq(s_rewardVault.getReward(COMMUNITY_STAKER_ONE), rewardBeforeStaking);
  }
}

contract RewardVault_GetReward_WithStakersAndTimePassed is RewardVault_WithStakersAndTimePassed {
  function test_CommunityStakerHasEarnedCorrectAmountOfRewards() public {
    BaseTest.StakePeriod[] memory stakePeriods = new BaseTest.StakePeriod[](1);
    stakePeriods[0] = BaseTest.StakePeriod({
      time: TIME_AFTER_STAKE + TIME_AFTER_REWARD_UPDATED,
      stakerPrincipal: COMMUNITY_MIN_PRINCIPAL,
      totalPrincipalInPool: 4 * COMMUNITY_MIN_PRINCIPAL,
      rewardEmissionRate: s_rewardVault.getRewardBuckets().communityBase.emissionRate,
      rewardVestingTime: TIME_AFTER_STAKE + TIME_AFTER_REWARD_UPDATED
    });
    uint256 expectedRewards = _calculateExpectedRewardOverMultiplePeriods(
      stakePeriods, INITIAL_MULTIPLIER_DURATION, s_stakedAtTime, s_stakedAtTime
    );
    assertEq(s_rewardVault.getReward(COMMUNITY_STAKER_ONE), expectedRewards);
  }
}

contract RewardVault_GetReward_WithStakersStakingAgain is RewardVault_WithStakersAndTimePassed {
  uint256 private constant TIME_BETWEEN_STAKES = 28 days;

  function setUp() public override {
    RewardVault_WithStakersAndTimePassed.setUp();
    changePrank(COMMUNITY_STAKER_ONE);
    s_LINK.transferAndCall(
      address(s_communityStakingPool),
      COMMUNITY_MIN_PRINCIPAL,
      abi.encode(s_communityStakerOneProof)
    );
  }

  function test_StakerEarnedRewardsDoesNotImmediatelyChange() public {
    BaseTest.StakePeriod[] memory stakePeriods = new BaseTest.StakePeriod[](1);

    // Period after first stake
    stakePeriods[0] = BaseTest.StakePeriod({
      time: TIME_AFTER_STAKE + TIME_AFTER_REWARD_UPDATED,
      stakerPrincipal: COMMUNITY_MIN_PRINCIPAL,
      totalPrincipalInPool: 4 * COMMUNITY_MIN_PRINCIPAL,
      rewardEmissionRate: s_rewardVault.getRewardBuckets().communityBase.emissionRate,
      rewardVestingTime: TIME_AFTER_STAKE + TIME_AFTER_REWARD_UPDATED
    });

    uint256 expectedRewards = _calculateExpectedRewardOverMultiplePeriods(
      stakePeriods, INITIAL_MULTIPLIER_DURATION, s_stakedAtTime, s_stakedAtTime
    );
    assertEq(s_rewardVault.getReward(COMMUNITY_STAKER_ONE), expectedRewards);
  }

  function test_CommunityStakerHasEarnedCorrectAmountOfRewardsAfterSomeTime() public {
    skip(TIME_BETWEEN_STAKES);

    BaseTest.StakePeriod[] memory stakePeriods = new BaseTest.StakePeriod[](2);

    // Period after first stake
    stakePeriods[0] = BaseTest.StakePeriod({
      time: TIME_AFTER_STAKE + TIME_AFTER_REWARD_UPDATED,
      stakerPrincipal: COMMUNITY_MIN_PRINCIPAL,
      totalPrincipalInPool: 4 * COMMUNITY_MIN_PRINCIPAL,
      rewardEmissionRate: s_rewardVault.getRewardBuckets().communityBase.emissionRate,
      rewardVestingTime: TIME_AFTER_STAKE + TIME_AFTER_REWARD_UPDATED
    });

    // Period after second stake
    stakePeriods[1] = BaseTest.StakePeriod({
      time: TIME_BETWEEN_STAKES,
      stakerPrincipal: 2 * COMMUNITY_MIN_PRINCIPAL,
      totalPrincipalInPool: 5 * COMMUNITY_MIN_PRINCIPAL,
      rewardEmissionRate: s_rewardVault.getRewardBuckets().communityBase.emissionRate,
      rewardVestingTime: TIME_BETWEEN_STAKES
    });

    uint256 expectedRewards = _calculateExpectedRewardOverMultiplePeriods(
      stakePeriods, INITIAL_MULTIPLIER_DURATION, s_stakedAtTime, s_stakedAtTime
    );
    assertEq(s_rewardVault.getReward(COMMUNITY_STAKER_ONE), expectedRewards);
  }

  function test_CommunityStakerHasEarnedCorrectAmountOfRewardsAfterSomeTimeAfterStakingThirdTime()
    public
  {
    skip(TIME_BETWEEN_STAKES);
    changePrank(COMMUNITY_STAKER_ONE);
    s_LINK.transferAndCall(
      address(s_communityStakingPool),
      COMMUNITY_MIN_PRINCIPAL,
      abi.encode(s_communityStakerOneProof)
    );
    skip(TIME_BETWEEN_STAKES);

    BaseTest.StakePeriod[] memory stakePeriods = new BaseTest.StakePeriod[](3);

    // Period after first stake
    stakePeriods[0] = BaseTest.StakePeriod({
      time: TIME_AFTER_STAKE + TIME_AFTER_REWARD_UPDATED,
      stakerPrincipal: COMMUNITY_MIN_PRINCIPAL,
      totalPrincipalInPool: 4 * COMMUNITY_MIN_PRINCIPAL,
      rewardEmissionRate: s_rewardVault.getRewardBuckets().communityBase.emissionRate,
      rewardVestingTime: TIME_AFTER_STAKE + TIME_AFTER_REWARD_UPDATED
    });

    // Period after second stake
    stakePeriods[1] = BaseTest.StakePeriod({
      time: TIME_BETWEEN_STAKES,
      stakerPrincipal: 2 * COMMUNITY_MIN_PRINCIPAL,
      totalPrincipalInPool: 5 * COMMUNITY_MIN_PRINCIPAL,
      rewardEmissionRate: s_rewardVault.getRewardBuckets().communityBase.emissionRate,
      rewardVestingTime: TIME_BETWEEN_STAKES
    });

    // Period after third stake
    stakePeriods[2] = BaseTest.StakePeriod({
      time: TIME_BETWEEN_STAKES,
      stakerPrincipal: 3 * COMMUNITY_MIN_PRINCIPAL,
      totalPrincipalInPool: 6 * COMMUNITY_MIN_PRINCIPAL,
      rewardEmissionRate: s_rewardVault.getRewardBuckets().communityBase.emissionRate,
      rewardVestingTime: TIME_BETWEEN_STAKES
    });

    uint256 expectedRewards = _calculateExpectedRewardOverMultiplePeriods(
      stakePeriods, INITIAL_MULTIPLIER_DURATION, s_stakedAtTime, s_stakedAtTime
    );
    assertEq(s_rewardVault.getReward(COMMUNITY_STAKER_ONE), expectedRewards);
  }
}

contract RewardVault_GetReward_WhenAVaultHasBeenUpgradedAndAnOperatorIsRemoved is
  RewardVault_WithUpgradedVaultDeployedAndMigrated
{
  uint256 private constant TIME_AFTER_REMOVAL = 30 days;
  uint256 private s_operatorRemovedAtTime;
  uint256 private s_timeStakeAsCommunityStaker;

  function setUp() public override {
    RewardVault_WithUpgradedVaultDeployedAndMigrated.setUp();

    changePrank(OWNER);
    address[] memory removedOperators = new address[](1);
    removedOperators[0] = OPERATOR_STAKER_ONE;
    s_operatorStakingPool.removeOperators(removedOperators);
    s_operatorRemovedAtTime = block.timestamp;

    // Open community staking pool
    changePrank(OWNER);
    s_communityStakingPool.setMerkleRoot(bytes32(''));
    skip(TIME_AFTER_REMOVAL);
  }

  function test_ReturnsTheCorrectAmountOfEarnedRewardsInOldVault() public {
    uint256 vestedOperatorBaseRewards = _calculateBucketVestedRewards(
      s_rewardVault.getRewardBuckets().operatorBase, s_stakedAtTime, s_migratedAtTime
    );
    uint256 vestedOperatorDelegatedRewards = _calculateBucketVestedRewards(
      s_rewardVault.getRewardBuckets().operatorDelegated, s_stakedAtTime, s_migratedAtTime
    );
    uint256 multiplier =
      _calculateStakerMultiplier(s_stakedAtTime, block.timestamp, INITIAL_MULTIPLIER_DURATION);
    uint256 expectedBaseRewards = _calculateStakerExpectedReward(
      OPERATOR_MIN_PRINCIPAL, OPERATOR_MIN_PRINCIPAL * 4, vestedOperatorBaseRewards
    ) * multiplier / FixedPointMathLib.WAD;
    uint256 expectedDelegatedRewards = _calculateStakerExpectedReward(
      OPERATOR_MIN_PRINCIPAL, OPERATOR_MIN_PRINCIPAL * 4, vestedOperatorDelegatedRewards
    );
    assertEq(
      s_rewardVault.getReward(OPERATOR_STAKER_ONE), expectedBaseRewards + expectedDelegatedRewards
    );
  }

  function test_ReturnsTheCorrectAmountOfEarnedRewardsInNewVault() public {
    // Calculate rewards as operator
    uint256 expectedBaseRewardsBeforeMultiplier = _calculateStakerExpectedReward(
      OPERATOR_MIN_PRINCIPAL,
      OPERATOR_MIN_PRINCIPAL * 4,
      _calculateBucketVestedRewards(
        s_rewardVaultVersion2.getRewardBuckets().operatorBase,
        s_migratedAtTime,
        s_operatorRemovedAtTime
      )
    );
    uint256 multiplier = _calculateStakerMultiplier(
      s_stakedAtTime, s_operatorRemovedAtTime, INITIAL_MULTIPLIER_DURATION
    );
    uint256 expectedBaseRewards =
      multiplier * expectedBaseRewardsBeforeMultiplier / FixedPointMathLib.WAD;

    uint256 expectedDelegatedRewards = _calculateStakerExpectedReward(
      OPERATOR_MIN_PRINCIPAL,
      OPERATOR_MIN_PRINCIPAL * 4,
      _calculateBucketVestedRewards(
        s_rewardVaultVersion2.getRewardBuckets().operatorDelegated,
        s_migratedAtTime,
        s_operatorRemovedAtTime
      )
    );

    assertEq(
      s_rewardVaultVersion2.getReward(OPERATOR_STAKER_ONE),
      expectedBaseRewards + expectedDelegatedRewards
    );
  }
}

contract RewardVault_GetReward_WhenAVaultHasBeenUpgradedOnceAndAStakerStakes is
  RewardVault_WithUpgradedVaultDeployedAndMigrated
{
  uint256 private constant TIME_AFTER_STAKING = 30 days;
  uint256 private s_secondStakedAtTime;

  function setUp() public override {
    RewardVault_WithUpgradedVaultDeployedAndMigrated.setUp();
    changePrank(COMMUNITY_STAKER_ONE);
    s_LINK.transferAndCall(
      address(s_communityStakingPool),
      COMMUNITY_MIN_PRINCIPAL,
      abi.encode(s_communityStakerOneProof)
    );
    changePrank(OPERATOR_STAKER_ONE);
    s_LINK.transferAndCall(address(s_operatorStakingPool), OPERATOR_MIN_PRINCIPAL, abi.encode(''));
    s_secondStakedAtTime = block.timestamp;
    skip(TIME_AFTER_STAKING);
  }

  function test_StakingDoesNotAffectCommunityStakerEarnedRewardsInOldVault() external {
    uint256 vestedCommunityBaseRewards = _calculateBucketVestedRewards(
      s_rewardVault.getRewardBuckets().communityBase, s_stakedAtTime, s_migratedAtTime
    );
    uint256 multiplier =
      _calculateStakerMultiplier(s_stakedAtTime, block.timestamp, INITIAL_MULTIPLIER_DURATION);
    uint256 expectedRewards = _calculateStakerExpectedReward(
      COMMUNITY_MIN_PRINCIPAL, COMMUNITY_MIN_PRINCIPAL * 4, vestedCommunityBaseRewards
    ) * multiplier / FixedPointMathLib.WAD;
    assertEq(s_rewardVault.getReward(COMMUNITY_STAKER_ONE), expectedRewards);
  }

  function test_StakingAgainCorrectlyCalculatesCommunityStakerRewardsInNewVault() external {
    BaseTest.StakePeriod[] memory stakePeriods = new BaseTest.StakePeriod[](2);

    // Period after first stake
    stakePeriods[0] = BaseTest.StakePeriod({
      time: TIME_AFTER_MIGRATION,
      stakerPrincipal: COMMUNITY_MIN_PRINCIPAL,
      totalPrincipalInPool: 4 * COMMUNITY_MIN_PRINCIPAL,
      rewardEmissionRate: s_rewardVault.getRewardBuckets().communityBase.emissionRate,
      rewardVestingTime: TIME_AFTER_MIGRATION
    });

    // Period after second stake
    stakePeriods[1] = BaseTest.StakePeriod({
      time: TIME_AFTER_STAKING,
      stakerPrincipal: 2 * COMMUNITY_MIN_PRINCIPAL,
      totalPrincipalInPool: 5 * COMMUNITY_MIN_PRINCIPAL,
      rewardEmissionRate: s_rewardVault.getRewardBuckets().communityBase.emissionRate,
      rewardVestingTime: TIME_AFTER_STAKING
    });

    uint256 expectedRewards = _calculateExpectedRewardOverMultiplePeriods(
      stakePeriods, INITIAL_MULTIPLIER_DURATION, s_stakedAtTime, s_migratedAtTime
    );

    assertEq(s_rewardVaultVersion2.getReward(COMMUNITY_STAKER_ONE), expectedRewards);
  }

  function test_StakingDoesNotAffectOperatorStakerEarnedRewardsInOldVault() external {
    uint256 vestedOperatorBaseRewards = _calculateBucketVestedRewards(
      s_rewardVault.getRewardBuckets().operatorBase, s_stakedAtTime, s_migratedAtTime
    );
    uint256 vestedOperatorDelegatedRewards = _calculateBucketVestedRewards(
      s_rewardVault.getRewardBuckets().operatorDelegated, s_stakedAtTime, s_migratedAtTime
    );
    uint256 multiplier =
      _calculateStakerMultiplier(s_stakedAtTime, block.timestamp, INITIAL_MULTIPLIER_DURATION);
    uint256 expectedBaseRewards = _calculateStakerExpectedReward(
      OPERATOR_MIN_PRINCIPAL, OPERATOR_MIN_PRINCIPAL * 4, vestedOperatorBaseRewards
    ) * multiplier / FixedPointMathLib.WAD;
    uint256 expectedDelegatedRewards = _calculateStakerExpectedReward(
      OPERATOR_MIN_PRINCIPAL, OPERATOR_MIN_PRINCIPAL * 4, vestedOperatorDelegatedRewards
    );
    assertEq(
      s_rewardVault.getReward(OPERATOR_STAKER_ONE), expectedBaseRewards + expectedDelegatedRewards
    );
  }

  function test_StakingAgainCorrectlyCalculatesOperatorsStakerRewardsInNewVault() external {
    BaseTest.StakePeriod[] memory stakePeriods = new BaseTest.StakePeriod[](2);

    // Period after first stake
    stakePeriods[0] = BaseTest.StakePeriod({
      time: TIME_AFTER_MIGRATION,
      stakerPrincipal: OPERATOR_MIN_PRINCIPAL,
      totalPrincipalInPool: 4 * OPERATOR_MIN_PRINCIPAL,
      rewardEmissionRate: s_rewardVault.getRewardBuckets().operatorBase.emissionRate,
      rewardVestingTime: TIME_AFTER_MIGRATION
    });

    // Period after second stake
    stakePeriods[1] = BaseTest.StakePeriod({
      time: TIME_AFTER_STAKING,
      stakerPrincipal: 2 * OPERATOR_MIN_PRINCIPAL,
      totalPrincipalInPool: 5 * OPERATOR_MIN_PRINCIPAL,
      rewardEmissionRate: s_rewardVault.getRewardBuckets().operatorBase.emissionRate,
      rewardVestingTime: TIME_AFTER_STAKING
    });

    uint256 expectedBaseRewards = _calculateExpectedRewardOverMultiplePeriods(
      stakePeriods, INITIAL_MULTIPLIER_DURATION, s_stakedAtTime, s_migratedAtTime
    );

    uint256 expectedDelegatedRewardsFirstStake = _calculateStakerExpectedReward(
      OPERATOR_MIN_PRINCIPAL,
      OPERATOR_MIN_PRINCIPAL * 4,
      _calculateBucketVestedRewards(
        s_rewardVaultVersion2.getRewardBuckets().operatorDelegated,
        s_migratedAtTime,
        s_secondStakedAtTime
      )
    );
    uint256 expectedDelegatedRewardsSecondStake = _calculateStakerExpectedReward(
      OPERATOR_MIN_PRINCIPAL * 2,
      OPERATOR_MIN_PRINCIPAL * 5,
      _calculateBucketVestedRewards(
        s_rewardVaultVersion2.getRewardBuckets().operatorDelegated,
        s_secondStakedAtTime,
        block.timestamp
      )
    );
    uint256 expectedDelegatedRewards =
      expectedDelegatedRewardsFirstStake + expectedDelegatedRewardsSecondStake;
    assertEq(
      s_rewardVaultVersion2.getReward(OPERATOR_STAKER_ONE),
      expectedBaseRewards + expectedDelegatedRewards
    );
  }
}

contract RewardVault_GetReward_WhenAVaultHasBeenUpgradedOnceAndAStakerUnstakes is
  RewardVault_WithUpgradedVaultDeployedAndMigrated
{
  uint256 private constant TIME_AFTER_UNSTAKING = 30 days;
  uint256 private s_unstakedAtTime;

  function setUp() public override {
    RewardVault_WithUpgradedVaultDeployedAndMigrated.setUp();
    changePrank(COMMUNITY_STAKER_ONE);
    s_communityStakingPool.unbond();
    changePrank(OPERATOR_STAKER_ONE);
    s_operatorStakingPool.unbond();
    skip(UNBONDING_PERIOD);
    changePrank(COMMUNITY_STAKER_ONE);
    s_communityStakingPool.unstake(COMMUNITY_MIN_PRINCIPAL, false);
    changePrank(OPERATOR_STAKER_ONE);
    s_operatorStakingPool.unstake(OPERATOR_MIN_PRINCIPAL, false);
    s_unstakedAtTime = block.timestamp;
    skip(TIME_AFTER_UNSTAKING);
  }

  function test_UnstakingDoesNotAffectCommunityStakerEarnedRewardsInOldVault() external {
    uint256 vestedCommunityBaseRewards = _calculateBucketVestedRewards(
      s_rewardVault.getRewardBuckets().communityBase, s_stakedAtTime, s_migratedAtTime
    );
    uint256 multiplier =
      _calculateStakerMultiplier(s_stakedAtTime, block.timestamp, INITIAL_MULTIPLIER_DURATION);
    uint256 expectedRewards = _calculateStakerExpectedReward(
      COMMUNITY_MIN_PRINCIPAL, COMMUNITY_MIN_PRINCIPAL * 4, vestedCommunityBaseRewards
    ) * multiplier / FixedPointMathLib.WAD;
    assertEq(s_rewardVault.getReward(COMMUNITY_STAKER_ONE), expectedRewards);
  }

  function test_UnstakingAgainCorrectlyCalculatesCommunityStakerRewardsInNewVault() external {
    uint256 expectedRewards = _calculateStakerExpectedReward(
      COMMUNITY_MIN_PRINCIPAL,
      COMMUNITY_MIN_PRINCIPAL * 4,
      _calculateBucketVestedRewards(
        s_rewardVaultVersion2.getRewardBuckets().communityBase, s_migratedAtTime, s_unstakedAtTime
      )
    );
    uint256 multiplier =
      _calculateStakerMultiplier(s_stakedAtTime, s_unstakedAtTime, INITIAL_MULTIPLIER_DURATION);
    expectedRewards = multiplier * expectedRewards / FixedPointMathLib.WAD;
    assertEq(s_rewardVaultVersion2.getReward(COMMUNITY_STAKER_ONE), expectedRewards);
  }

  function test_UnstakingDoesNotAffectOperatorStakerEarnedRewardsInOldVault() external {
    uint256 vestedOperatorBaseRewards = _calculateBucketVestedRewards(
      s_rewardVault.getRewardBuckets().operatorBase, s_stakedAtTime, s_migratedAtTime
    );
    uint256 vestedOperatorDelegatedRewards = _calculateBucketVestedRewards(
      s_rewardVault.getRewardBuckets().operatorDelegated, s_stakedAtTime, s_migratedAtTime
    );
    uint256 multiplier =
      _calculateStakerMultiplier(s_stakedAtTime, block.timestamp, INITIAL_MULTIPLIER_DURATION);
    uint256 expectedBaseRewards = _calculateStakerExpectedReward(
      OPERATOR_MIN_PRINCIPAL, OPERATOR_MIN_PRINCIPAL * 4, vestedOperatorBaseRewards
    ) * multiplier / FixedPointMathLib.WAD;
    uint256 expectedDelegatedRewards = _calculateStakerExpectedReward(
      OPERATOR_MIN_PRINCIPAL, OPERATOR_MIN_PRINCIPAL * 4, vestedOperatorDelegatedRewards
    );
    assertEq(
      s_rewardVault.getReward(OPERATOR_STAKER_ONE), expectedBaseRewards + expectedDelegatedRewards
    );
  }

  function test_UnstakingCorrectlyCalculatesOperatorsStakerRewardsInNewVault() external {
    uint256 expectedBaseRewards = _calculateStakerExpectedReward(
      OPERATOR_MIN_PRINCIPAL,
      OPERATOR_MIN_PRINCIPAL * 4,
      _calculateBucketVestedRewards(
        s_rewardVaultVersion2.getRewardBuckets().operatorBase, s_migratedAtTime, s_unstakedAtTime
      )
    );
    uint256 expectedDelegatedRewards = _calculateStakerExpectedReward(
      OPERATOR_MIN_PRINCIPAL,
      OPERATOR_MIN_PRINCIPAL * 4,
      _calculateBucketVestedRewards(
        s_rewardVaultVersion2.getRewardBuckets().operatorDelegated,
        s_migratedAtTime,
        s_unstakedAtTime
      )
    );
    uint256 multiplier =
      _calculateStakerMultiplier(s_stakedAtTime, s_unstakedAtTime, INITIAL_MULTIPLIER_DURATION);
    expectedBaseRewards = multiplier * expectedBaseRewards / FixedPointMathLib.WAD;
    assertEq(
      s_rewardVaultVersion2.getReward(OPERATOR_STAKER_ONE),
      expectedBaseRewards + expectedDelegatedRewards
    );
  }
}

contract RewardVault_GetReward_WhenAVaultHasBeenUpgradedMultipleTimesAndAStakerStakes is
  RewardVault_WithUpgradedVaultDeployedAndMigratedMultipleTimes
{
  uint256 private constant TIME_AFTER_STAKING = 30 days;
  uint256 private s_secondStakedAtTime;

  function setUp() public override {
    RewardVault_WithUpgradedVaultDeployedAndMigratedMultipleTimes.setUp();
    changePrank(COMMUNITY_STAKER_ONE);
    s_LINK.transferAndCall(
      address(s_communityStakingPool),
      COMMUNITY_MIN_PRINCIPAL,
      abi.encode(s_communityStakerOneProof)
    );
    changePrank(OPERATOR_STAKER_ONE);
    s_LINK.transferAndCall(address(s_operatorStakingPool), OPERATOR_MIN_PRINCIPAL, abi.encode(''));
    s_secondStakedAtTime = block.timestamp;
    skip(TIME_AFTER_STAKING);
  }

  function test_DoesNotAffectEarnedCommunityStakerRewardsInFirstVault() public {
    uint256 vestedCommunityBaseRewards = _calculateBucketVestedRewards(
      s_rewardVault.getRewardBuckets().communityBase, s_stakedAtTime, s_migratedAtTime
    );
    uint256 multiplier =
      _calculateStakerMultiplier(s_stakedAtTime, block.timestamp, INITIAL_MULTIPLIER_DURATION);
    uint256 expectedRewards = _calculateStakerExpectedReward(
      COMMUNITY_MIN_PRINCIPAL, COMMUNITY_MIN_PRINCIPAL * 4, vestedCommunityBaseRewards
    ) * multiplier / FixedPointMathLib.WAD;
    assertEq(s_rewardVault.getReward(COMMUNITY_STAKER_ONE), expectedRewards);
  }

  function test_DoesNotAffectEarnedCommunityStakerRewardsInSecondVault() public {
    uint256 vestedCommunityBaseRewards = _calculateBucketVestedRewards(
      s_rewardVaultVersion2.getRewardBuckets().communityBase,
      s_migratedAtTime,
      s_secondMigratedAtTime
    );
    uint256 multiplier =
      _calculateStakerMultiplier(s_migratedAtTime, block.timestamp, INITIAL_MULTIPLIER_DURATION);
    uint256 expectedRewards = _calculateStakerExpectedReward(
      COMMUNITY_MIN_PRINCIPAL, COMMUNITY_MIN_PRINCIPAL * 4, vestedCommunityBaseRewards
    ) * multiplier / FixedPointMathLib.WAD;
    assertEq(s_rewardVaultVersion2.getReward(COMMUNITY_STAKER_ONE), expectedRewards);
  }

  function test_StakingAgainCorrectlyCalculatesCommunityStakerRewardsInNewVault() public {
    BaseTest.StakePeriod[] memory stakePeriods = new BaseTest.StakePeriod[](2);

    // Period after first stake
    stakePeriods[0] = BaseTest.StakePeriod({
      time: TIME_AFTER_MIGRATION,
      stakerPrincipal: COMMUNITY_MIN_PRINCIPAL,
      totalPrincipalInPool: 4 * COMMUNITY_MIN_PRINCIPAL,
      rewardEmissionRate: s_rewardVaultVersion3.getRewardBuckets().communityBase.emissionRate,
      rewardVestingTime: TIME_AFTER_MIGRATION
    });

    // Period after second stake
    stakePeriods[1] = BaseTest.StakePeriod({
      time: TIME_AFTER_STAKING,
      stakerPrincipal: 2 * COMMUNITY_MIN_PRINCIPAL,
      totalPrincipalInPool: 5 * COMMUNITY_MIN_PRINCIPAL,
      rewardEmissionRate: s_rewardVaultVersion3.getRewardBuckets().communityBase.emissionRate,
      rewardVestingTime: TIME_AFTER_STAKING
    });

    uint256 expectedRewards = _calculateExpectedRewardOverMultiplePeriods(
      stakePeriods, INITIAL_MULTIPLIER_DURATION, s_stakedAtTime, s_secondMigratedAtTime
    );

    assertEq(s_rewardVaultVersion3.getReward(COMMUNITY_STAKER_ONE), expectedRewards);
  }

  function test_DoesNotAffectEarnedOperatorStakerRewardsInFirstVault() public {
    uint256 vestedOperatorBaseRewards = _calculateBucketVestedRewards(
      s_rewardVault.getRewardBuckets().operatorBase, s_stakedAtTime, s_migratedAtTime
    );
    uint256 vestedOperatorDelegatedRewards = _calculateBucketVestedRewards(
      s_rewardVault.getRewardBuckets().operatorDelegated, s_stakedAtTime, s_migratedAtTime
    );
    uint256 multiplier =
      _calculateStakerMultiplier(s_stakedAtTime, block.timestamp, INITIAL_MULTIPLIER_DURATION);
    uint256 expectedBaseRewards = _calculateStakerExpectedReward(
      OPERATOR_MIN_PRINCIPAL, OPERATOR_MIN_PRINCIPAL * 4, vestedOperatorBaseRewards
    ) * multiplier / FixedPointMathLib.WAD;
    uint256 expectedDelegatedRewards = _calculateStakerExpectedReward(
      OPERATOR_MIN_PRINCIPAL, OPERATOR_MIN_PRINCIPAL * 4, vestedOperatorDelegatedRewards
    );
    assertEq(
      s_rewardVault.getReward(OPERATOR_STAKER_ONE), expectedBaseRewards + expectedDelegatedRewards
    );
  }

  function test_DoesNotAffectEarnedOperatorStakerRewardsInSecondVault() public {
    uint256 vestedOperatorBaseRewards = _calculateBucketVestedRewards(
      s_rewardVaultVersion2.getRewardBuckets().operatorBase,
      s_migratedAtTime,
      s_secondMigratedAtTime
    );
    uint256 vestedOperatorDelegatedRewards = _calculateBucketVestedRewards(
      s_rewardVaultVersion2.getRewardBuckets().operatorDelegated,
      s_migratedAtTime,
      s_secondMigratedAtTime
    );
    uint256 multiplier =
      _calculateStakerMultiplier(s_migratedAtTime, block.timestamp, INITIAL_MULTIPLIER_DURATION);
    uint256 expectedBaseRewards = _calculateStakerExpectedReward(
      OPERATOR_MIN_PRINCIPAL, OPERATOR_MIN_PRINCIPAL * 4, vestedOperatorBaseRewards
    ) * multiplier / FixedPointMathLib.WAD;
    uint256 expectedDelegatedRewards = _calculateStakerExpectedReward(
      OPERATOR_MIN_PRINCIPAL, OPERATOR_MIN_PRINCIPAL * 4, vestedOperatorDelegatedRewards
    );
    assertEq(
      s_rewardVaultVersion2.getReward(OPERATOR_STAKER_ONE),
      expectedBaseRewards + expectedDelegatedRewards
    );
  }

  function test_StakingAgainCorrectlyCalculatesOperatorStakerRewardsInNewVault() public {
    BaseTest.StakePeriod[] memory stakePeriods = new BaseTest.StakePeriod[](2);

    // Period after first stake
    stakePeriods[0] = BaseTest.StakePeriod({
      time: TIME_AFTER_MIGRATION,
      stakerPrincipal: OPERATOR_MIN_PRINCIPAL,
      totalPrincipalInPool: 4 * OPERATOR_MIN_PRINCIPAL,
      rewardEmissionRate: s_rewardVaultVersion3.getRewardBuckets().operatorBase.emissionRate,
      rewardVestingTime: TIME_AFTER_MIGRATION
    });

    // Period after second stake
    stakePeriods[1] = BaseTest.StakePeriod({
      time: TIME_AFTER_STAKING,
      stakerPrincipal: 2 * OPERATOR_MIN_PRINCIPAL,
      totalPrincipalInPool: 5 * OPERATOR_MIN_PRINCIPAL,
      rewardEmissionRate: s_rewardVaultVersion3.getRewardBuckets().operatorBase.emissionRate,
      rewardVestingTime: TIME_AFTER_STAKING
    });

    uint256 expectedBaseRewards = _calculateExpectedRewardOverMultiplePeriods(
      stakePeriods, INITIAL_MULTIPLIER_DURATION, s_stakedAtTime, s_secondMigratedAtTime
    );

    uint256 expectedDelegatedRewardsFirstStake = _calculateStakerExpectedReward(
      OPERATOR_MIN_PRINCIPAL,
      OPERATOR_MIN_PRINCIPAL * 4,
      _calculateBucketVestedRewards(
        s_rewardVaultVersion3.getRewardBuckets().operatorDelegated,
        s_secondMigratedAtTime,
        s_secondStakedAtTime
      )
    );

    uint256 expectedDelegatedRewardsSecondStake = _calculateStakerExpectedReward(
      OPERATOR_MIN_PRINCIPAL * 2,
      OPERATOR_MIN_PRINCIPAL * 5,
      _calculateBucketVestedRewards(
        s_rewardVaultVersion3.getRewardBuckets().operatorDelegated,
        s_secondStakedAtTime,
        block.timestamp
      )
    );

    uint256 expectedDelegatedRewards =
      expectedDelegatedRewardsFirstStake + expectedDelegatedRewardsSecondStake;
    assertEq(
      s_rewardVaultVersion3.getReward(OPERATOR_STAKER_ONE),
      expectedBaseRewards + expectedDelegatedRewards
    );
  }
}
