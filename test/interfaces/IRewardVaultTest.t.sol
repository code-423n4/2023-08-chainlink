// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

interface IRewardVault_AddReward_UpdateBucket {
  function test_InitializeRewardDuration() external;
  function test_InitializeEmissionRate() external;
  function test_UpdateEmissionRate() external;
  function test_IncreaseRewardDurationWithMoreRewardsSameRate() external;
  function test_IncreaseRewardDurationWithZeroRewardAmountAndSlowerRate() external;
  function test_DecreaseRewardDurationWithZeroRewardAmountAndFasterRate() external;
  function test_TopUpRewardsAtConclusionOfOldRewards() external;
  function test_TopUpRewardsAfterConclusionOfOldRewards() external;
  function test_RevertWhen_AddRewardAmountLessThanEmissionRate() external;
}

interface IRewardVault_SetDelegationRateDenominator {
  function test_OwnerCanIncreaseDelegationRateDenominator() external;
}

interface IRewardVault_UpdateReward_UpdateOnlyPoolsWhenTimeDidNotPass {
  function test_DoesNotUpdateVestedRewardPerTokens() external;
  function test_DoesNotUpdateRewardPerTokenUpdatedAt() external;
}

interface IRewardVault_UpdateReward_UpdateOnlyPoolsOnlyUpdatesUpdatedAt {
  function test_DoesNotUpdateVestedRewardPerTokens() external;
  function test_UpdatesRewardPerTokenUpdatedAt() external;
}

interface IRewardVault_UpdateReward_UpdateOnlyPoolsWhenRewardAccrued {
  function test_UpdatesVestedRewardPerTokens() external;
  function test_UpdatesRewardPerTokenUpdatedAt() external;
}

interface IRewardVault_UpdateReward_UpdateOnlyStakerWhenTimeDidNotPass {
  function test_DoesNotUpdateStakerStoredReward() external;
  function test_DoesNotUpdateStakerFinalizedReward() external;
  function test_DoesNotUpdateStakerBaseRewardPerToken() external;
  function test_DoesNotUpdateStakerDelegatedRewardPerToken() external;
}

interface IRewardVault_UpdateReward_UpdateOnlyCommunityStakerWhenRewardAccrued {
  function test_UpdatesStakerStoredReward() external;
  function test_UpdatesStakerBaseRewardPerToken() external;
}

interface IRewardVault_UpdateReward_UpdateOnlyOperatorWhenRewardAccrued {
  function test_UpdatesStakerStoredReward() external;
  function test_UpdatesStakerFinalizedReward() external;
  function test_UpdatesStakerBaseRewardPerToken() external;
  function test_UpdatesStakerDelegatedRewardPerToken() external;
}

interface IRewardVault_UpdateReward_UpdatePoolsAndStakerWhenTimeDidNotPass is
  IRewardVault_UpdateReward_UpdateOnlyPoolsWhenTimeDidNotPass,
  IRewardVault_UpdateReward_UpdateOnlyStakerWhenTimeDidNotPass
{}

interface IRewardVault_UpdateReward_UpdatePoolsAndCommunityStakerWhenRewardAccrued is
  IRewardVault_UpdateReward_UpdateOnlyPoolsWhenRewardAccrued,
  IRewardVault_UpdateReward_UpdateOnlyCommunityStakerWhenRewardAccrued
{}

interface IRewardVault_UpdateReward_UpdatePoolsAndOperatorWhenRewardAccrued is
  IRewardVault_UpdateReward_UpdateOnlyPoolsWhenRewardAccrued,
  IRewardVault_UpdateReward_UpdateOnlyOperatorWhenRewardAccrued
{}

interface IRewardVault_UpdateReward_Initialize {
  function test_InitializesStakerRewardStakingPool() external;
}

interface IRewardVault_ClaimReward_WithoutStakers {
  function test_RevertWhen_StakerRewardNotInitialized() external;
}

interface IRewardVault_ClaimReward_WithStakers {
  function test_TransfersTokensToStaker() external;
  function test_EmitsEvent() external;
  function test_TransfersCorrectAmountIfClaimedPartiallyMultipleTimes() external;
}

interface IRewardVault_ClaimReward_AfterUnstake {
  function test_TransfersCorrectTokenAmountToCommunityStakerThatHasFullyUnstaked() external;

  function test_TransfersCorrectTokenAmountToOperatorThatHasFullyUnstaked() external;

  function test_TransfersCorrectTokenAmountToCommunityStakerThatHasPartiallyUnstaked() external;

  function test_TransfersCorrectTokenAmountToOperatorThatHasPartiallyUnstaked() external;
}

interface IRewardVault_ClaimReward_NoAccruedRewards {
  function test_RevertWhen_StakerHasNoReward() external;
}

interface
  IRewardVault_ClaimReward_AfterUnstakeAndNotClaimingRewardAndBeforeReachingTheMaxRampUpPeriod {
  function test_ClaimsCorrectAmountOfRewards() external;
  function test_RevertWhen_ClaimingRightAfterClaiming() external;
}

interface IRewardVault_SetMultiplierDuration {
  function test_RevertWhen_CalledByNonAdmin() external;
  function test_UpdatesMultiplierDuration() external;
  function test_DoesNotAffectFinalizedRewards() external;
  function test_EmitsEvent() external;
  function test_CanSetMultiplierDurationToZero() external;
}

interface IRewardVault_GetMultiplier {
  function test_ReturnsZeroWhenStakerNotStaked() external;
  function test_ReturnsZeroWhenStakerStakedAndNoTimePassed() external;
  function test_ReturnsCorrectValueWhenStakerStakedAndTimePassed() external;
  function test_ReducesMultiplierWhenStakerStakedAgain() external;
  function test_ReturnsMaxValueWhenStakerStakedForFullMultiplierDuration() external;
  function test_DoesNotChangeWhenStakerClaimsReward() external;
  function test_ReturnsZeroWhenStakerFullyUnstaked() external;
  function test_DoesNotGrowAfterStakerFullyUnstaked() external;
  function test_ReturnsZeroWhenStakerStakedAgainAfterFullyUnstaked() external;
  function test_ReturnsCorrectValueWhenStakerStakedAgainAfterFullyUnstakedAndTimePassed() external;
  function test_ReturnsZeroWhenStakerPartiallyUnstaked() external;
  function test_DoesGrowAfterStakerPartiallyUnstaked() external;
  function test_ReturnsCorrectValueWhenStakerStakedAgainAfterPartiallyUnstaked() external;
  function test_ReturnsCorrectValueWhenStakerStakedAgainAfterPartiallyUnstakedAndTimePassed()
    external;
  function test_ReturnsMaxValueWhenMultiplierDurationIsChangedToZero() external;
  function test_ReturnsCorrectValueWhenMultiplierDurationIsIncreased() external;
  function test_ReturnsCorrectValueWhenMultiplierDurationIsDecreased() external;
}
