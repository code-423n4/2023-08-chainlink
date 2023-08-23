// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {BaseInvariant} from './BaseInvariant.t.sol';
import {RewardVault} from '../../src/rewards/RewardVault.sol';

contract RewardVaultInvariants is BaseInvariant {
  /// @notice This test ensures that the total staker rewards are less than or equal to the vested
  /// rewards
  function invariant_rewardsNeverExceedVestedRewards() public useCurrentTimestamp {
    (uint256 totalStakerRewards,,) = s_rewardVaultHandler.getTotalStakerRewards();
    uint256 totalAddedRewards = s_rewardVaultHandler.getTotalAddedRewards();
    (uint256 totalUnvestedRewards,,,) = s_rewardVaultHandler.getTotalUnvestedRewards();
    assertLe(
      totalStakerRewards,
      totalAddedRewards - totalUnvestedRewards,
      'Invariant violated: sum of added rewards should never exceed available rewards'
    );
  }

  /// @notice This test ensures that the total unavailable rewards are less than or equal to the
  /// LINK token balance of the reward vault
  function invariant_unvestedRewardsNeverExceedLinkBalance() public useCurrentTimestamp {
    (uint256 totalUnvestedRewards,,,) = s_rewardVaultHandler.getTotalUnvestedRewards();
    assertLe(
      totalUnvestedRewards,
      s_LINK.balanceOf(address(s_rewardVault)),
      'Invariant violated: remaining rewards should never exceed LINK balance'
    );
  }

  /// @notice This test ensures that the reward bucket with zero aggregate reward rate has zero
  /// reward
  function invariant_rewardBucketWithZeroEmissionRateHasZeroReward() public useCurrentTimestamp {
    RewardVault.RewardBuckets memory buckets = s_rewardVault.getRewardBuckets();
    if (buckets.operatorBase.emissionRate == 0) {
      assertEq(
        buckets.operatorBase.rewardDurationEndsAt,
        0,
        'Invariant violated: operator base reward bucket with zero aggregate reward rate should have zero reward end time'
      );
    }
    if (buckets.communityBase.emissionRate == 0) {
      assertEq(
        buckets.communityBase.rewardDurationEndsAt,
        0,
        'Invariant violated: community base reward bucket with zero aggregate reward rate should have zero reward end time'
      );
    }
    if (buckets.operatorDelegated.emissionRate == 0) {
      assertEq(
        buckets.operatorDelegated.rewardDurationEndsAt,
        0,
        'Invariant violated: operator delegated reward bucket with zero aggregate reward rate should have zero reward end time'
      );
    }
  }

  /// @notice This test ensures that the multiplier is within the expected range
  function invariant_multiplierShouldBeWithinTheExpectedRange() public useCurrentTimestamp {
    address staker = _getRandomStaker(address(0));
    uint256 multiplier = s_rewardVault.getMultiplier(staker);
    assertGe(multiplier, 0, 'Invariant violated: multiplier should be greater than or equal to 0');
    assertLe(
      multiplier,
      MAX_MULTIPLIER,
      'Invariant violated: multiplier should be less than or equal to the max multiplier'
    );
  }

  /// @notice This test ensures that the getters do not revert
  function invariant_gettersShouldNotRevert() public useCurrentTimestamp {
    address staker = _getRandomStaker(address(0));
    s_rewardVault.getDelegationRateDenominator();
    s_rewardVault.getMigrationSource();
    s_rewardVault.getMigrationTarget();
    s_rewardVault.getMultiplier(staker);
    s_rewardVault.getMultiplierDuration();
    s_rewardVault.getReward(staker);
    s_rewardVault.getRewardBuckets();
    s_rewardVault.getRewardPerTokenUpdatedAt();
    s_rewardVault.getStoredReward(staker);
    s_rewardVault.getVestingCheckpointData();
    s_rewardVault.isOpen();
    s_rewardVault.calculateLatestStakerReward(staker);
    s_rewardVault.isPaused();
    s_rewardVault.typeAndVersion();
  }

  function test() public override {}
}
