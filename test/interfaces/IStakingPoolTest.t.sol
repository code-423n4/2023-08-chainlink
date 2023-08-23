// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

interface IStakingPool_Constructor {
  function test_RevertWhen_UnbondingPeriodIsLessThanMinUnbondingPeriod() external;
  function test_RevertWhen_UnbondingPeriodIsGreaterThanMaxUnbondingPeriod() external;
  function test_RevertWhen_ClaimPeriodIsZero() external;
  function test_RevertWhen_MinClaimPeriodIsGreaterThanMaxClaimPeriod() external;
  function test_RevertWhen_MinClaimPeriodIsZero() external;
  function test_RevertWhen_MinAndMaxClaimPeriodAreEqual() external;
  function test_RevertWhen_MaxPoolSizeIsZero() external;
  function test_RevertWhen_MinStakeAmountIsGreaterThanMaxStakeAmount() external;
  function test_RevertWhen_MinStakeAmountIsEqualToMaxStakeAmount() external;
  function test_RevertWhen_MinStakeAmountIsZero() external;
  function test_RevertWhen_MaxStakeAmountIsZero() external;
  function test_RevertWhen_LINKAddressIsZero() external;
  function test_InitializesUnbondingParams() external;
  function test_SetsTheLINKToken() external;
  function test_HasCorrectInitialLimits() external;
  function test_HasCorrectInitialClaimPeriodLimits() external;
  function test_CheckpointIdIsZero() external;
  function test_InitializesRoles() external;
}

interface IStakingPool_GetStaker {
  function test_ReturnsZeroIfStakerHasNotStaked() external;
  function test_ReturnsZeroIfStakerIsInAnotherPool() external;
  function test_ReturnsCorrectStakeAmountIfStakerHasStaked() external;
}

interface IStakingPool_GetClaimPeriodEndsAt {
  function test_ReturnsCorrectClaimPeriodEndsAt() external;
}

interface IStakingPool_SetPoolConfig {
  function test_RevertWhen_ConfigChangedByNonAdmin() external;
  function test_RevertWhen_PoolNotOpen() external;
  function test_RevertWhen_PoolHasBeenClosed() external;
  function test_RevertWhen_TryingToDecreaseMaxPoolSize() external;
  function test_RevertWhen_NewMaxStakerPrincipalLowerThanCurrentMaxPrincipal() external;
  function test_RevertWhen_MaxPoolSizeLowerThanMaxPrincipal() external;
  function test_MaxPoolSizeIncreased() external;
  function test_MaxPrincipalIncreased() external;
  function test_RevertWhen_TryingToStakeLessThanMinPrincipal() external;
  function test_RevertWhen_TryingToStakeMoreThanMaxPrincipal() external;
  function test_RevertWhen_AddingToStakeBringsPrincipalOverMax() external;
}

interface IStakingPool_SetClaimPeriod {
  function test_RevertWhen_CalledByNonAdmin() external;
  function test_RevertWhen_ClaimPeriodIsZero() external;
  function test_RevertWhen_ClaimPeriodIsGreaterThanMax() external;
  function test_RevertWhen_ClaimPeriodIsLessThanMin() external;
  function test_UpdatesClaimPeriod() external;
  function test_EmitsEvent() external;
  function test_DoesNotAffectStakersThatAreUnbonding() external;
}

interface IStakingPool_SetMigrationProxy {
  function test_RevertWhen_NotOwnerSetsMigrationProxy() external;
  function test_RevertWhen_OwnerSetsMigrationProxyToZero() external;
  function test_OwnerCanSetMigrationProxy() external;
  function test_EmitsEventWhenMigrationProxySet() external;
}

interface IStakingPool_OnTokenTransfer {
  function test_RevertWhen_OnTokenTransferNotFromLINK() external;
  function test_RevertWhen_MigrationProxyNotSet() external;
  function test_RevertWhen_OnTokenTransferDataIsEmptyFromMigrationProxy() external;
  function test_RevertWhen_RewardVaultPaused() external;
  function test_RevertWhen_StakerAddressInDataIsZero() external;
  function test_StakingThroughMigrationProxyUpdatesPoolStateTotalPrincipal() external;
  function test_StakingThroughMigrationProxyUpdatesStakerState() external;
  function test_StakingUpdatesPoolStateTotalPrincipal() external;
  function test_StakingUpdatesStakerState() external;
  function test_StakingZeroAmountHasNoStateChanges() external;
  function test_StakingWithNoTimePassedSinceAvgStakingDoesNotUpdateAvgStakingTime() external;
  function test_StakingUpdatesTheCheckpointId() external;
  function test_StakingUpdatesTheStakerTypeInRewardVault() external;
}

interface IStakingPool_OnTokenTransfer_WhenThereOtherStakers {
  function test_StakingMultipleTimesTracksPreviousBalance() external;
  function test_StakingMultipleTimesTracksPreviousAverageStakedAtTime() external;
  function test_StakingUpdatesTheLatestBalance() external;
  function test_StakingDoesNotAffectOtherStakersHistoricalBalance() external;
  function test_StakingDoesNotAffectOtherStakersAverageStakedAtTime() external;
}

interface IStakingPool_OnTokenTransfer_WhenPaused {
  function test_RevertWhen_AttemptingToStakeWhenPaused() external;
  function test_RevertWhen_AttemptingToMigrateWhenPaused() external;
  function test_CanStakeAfterUnpausing() external;
  function test_CanMigrateIntoPoolAfterUnpausing() external;
}

interface IStakingPool_OnTokenTransfer_WhenStakeIsUnbonding {
  function test_ResetsUnbondingPeriod() external;
  function test_EmitsCorrectEvent() external;
}

interface IStakingPool_Unbond_WhenStakeIsNotUnbonding {
  function test_RevertWhen_StakerHasNotStaked() external;
  function test_CorrectlySetsTheStakersUnbondingPeriod() external;
  function test_CorrectlySetsTheStakersClaimPeriod() external;
  function test_EmitsEvent() external;
}

interface IStakingPool_Unbond_WhenStakeIsUnbonding {
  function test_RevertWhen_StakerIsAlreadyInUnbondingPeriod() external;
  function test_RevertWhen_StakerIsInClaimPeriod() external;
  function test_CorrectlySetsTheStakersUnbondingPeriodWhenOutsideClaimPeriod() external;
}

interface IStakingPool_Unbond_WhenStakerStakesAgainDuringUnbondingPeriod {
  function test_CorrectlyStartsTheUnbondingPeriod() external;
}

interface IStakingPool_Unstake {
  function test_RevertWhen_UnstakeAmountIsZero() external;
  function test_RevertWhen_UnstakeAmountIsGreaterThanPrincipal() external;
  function test_RevertWhen_UnstakeAmountLeavesStakerWithLessThanMinPrincipal() external;
  function test_CorrectlyUpdatesPoolStateTotalPrincipal() external;
  function test_CorrectlyUpdatesStakerStatePrincipal() external;
  function test_CorrectlyTransferTokensToStaker() external;
  function test_AllowsMultipleUnstakesInClaimPeriod() external;
  function test_ClaimsRewardsIfShouldClaimRewardSetToTrue() external;
  function test_DoesNotClaimRewardIfShouldClaimRewardSetToTrueButNoRewardAccrued() external;
  function test_EmitsEvent() external;
  function test_CorrectlyIncrementsTheCheckpointId() external;
}

interface IStakingPool_Unstake_WhenMoreThanTwoStakers {
  function test_DistributesCorrectAmountToFirstStakerIfFullyUnstaking() external;
  function test_DistributesCorrectAmountToSecondStakerIfFullyUnstaking() external;
  function test_DistributesCorrectAmountToFirstStakerIfPartiallyUnstaking() external;
  function test_DistributesCorrectAmountToSecondStakerIfPartiallyUnstaking() external;
}

interface IStakingPool_Unstake_WhenPoolIsFull {
  function test_DistributesFullForfeitedRewardsIfStakerUnstakesASmallAmountAfterEarningASmallAmountOfRewards(
  ) external;
}

interface IStakingPool_Unstake_WhenStakerReachesMaxRampUpPeriod {
  function test_StakerClaimsFullRewards() external;
  function test_StakerRewardsNotForfeited() external;
}

interface IStakingPool_Unstake_WhenThereAreOtherStakers {
  function test_CorrectlyTracksHistoricalBalance() external;
  function test_DoesNotAffectOtherStakerBalances() external;
  function test_CorrectlyTracksHistoricalAverageStakedAtTime() external;
  function test_DoesNotAffectOtherStakerAverageStakedAtTime() external;
}

interface IStakingPool_Unstake_WhenUnbondingNotStarted {
  function test_RevertWhen_StakerTriesToUnstake() external;
}

interface IStakingPool_Unstake_WhileUnbonding {
  function test_RevertWhen_StakerTriesToUnstake() external;
}

interface IStakingPool_Unstake_WhenClaimPeriodFinished {
  function test_RevertWhen_StakerTriesToUnstake() external;
}

interface IStakingPool_Unstake_WhenPoolClosed {
  function test_CanUnstakeIfPoolClosed() external;
}

interface IStakingPool_Unstake_WhenPaused {
  function test_CanUnstakeWithoutInitiatingUnbondingPeriod() external;
  function test_CanUnstakeAfterInitiatingUnbondingPeriodWithoutWaiting() external;
  function test_CanUnstakeAfterUnbondingPeriod() external;
  function test_RevertWhen_UnstakeAfterUnpausingAndBeforeUnbonding() external;
  function test_RevertWhen_UnstakeWithShouldClaimRewardsTrue() external;
}

interface IStakingPool_Unstake_WhenLastStakerUnstakesAndClaims {
  function test_DoesNotForfeitRewards() external;
}

interface IStakingPool_SetUnbondingPeriod_WhenPoolOpenedAndStakersAreUnbonding {
  function test_RevertWhen_CalledByNonAdmin() external;
  function test_RevertWhen_UnbondingPeriodIsZero() external;
  function test_RevertWhen_UnbondingPeriodIsGreaterThanMax() external;
  function test_UpdatesUnbondingPeriod() external;
  function test_DoesNotAffectStakersThatAreUnbonding() external;
  function test_EmitsEvent() external;
}

// Gas measurements

interface IStakingPool_Gas_OpenAndNoStakers {
  function test_Gas_StakingAsFirstStaker() external;
}

interface IStakingPool_Gas_OpenWithStakers_AsASubsequentStakerAndWithTimePassed {
  function test_Gas_StakingAsSubsequentStaker() external;
}

interface IStakingPool_Gas_OpenWithStakers_AndWithTimePassed {
  function test_Gas_StakingASecondTime() external;

  function test_Gas_Unbonding() external;
}

interface IStakingPool_Gas_OpenWithStakersInUnbondingPeriod {
  function test_Gas_Unstake() external;
}

interface IStakingPool_Gas_OpenWithStakersClaimReward {
  function test_Gas_ClaimReward() external;
}
