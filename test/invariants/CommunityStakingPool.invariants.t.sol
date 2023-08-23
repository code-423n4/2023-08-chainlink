// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {BaseInvariant} from './BaseInvariant.t.sol';

contract CommunityStakingPoolInvariants is BaseInvariant {
  /// @notice This test ensures that the total staked LINK amount is equal to the sum of the staker
  /// staked LINK amounts
  function invariant_stakerPrincipalsEqualTotalPrincipal() public useCurrentTimestamp {
    assertEq(
      s_communityStakingPoolHandler.getTotalStaked(),
      s_communityStakingPool.getTotalPrincipal(),
      'Invariant violated: the sum of staker principals must always equal the total principal'
    );
  }

  /// @notice This test ensures that operator is not staking in community pool
  function invariant_operatorShouldNotBeStakingInCommunityPool() public useCurrentTimestamp {
    address[] memory operators = s_operatorStakingPoolHandler.getStakers();
    for (uint256 i; i < operators.length; ++i) {
      assertEq(
        s_communityStakingPool.getStakerPrincipal(operators[i]),
        0,
        'Invariant violated: operator should not be staking community pool'
      );
    }
  }

  /// @notice This test ensures that the total staked amount never exceeds the max pool size
  function invariant_stakingAmountNeverExceedsMaxPoolSize() public useCurrentTimestamp {
    assertLe(
      s_communityStakingPoolHandler.getTotalStaked(),
      s_communityStakingPool.getMaxPoolSize(),
      'Invariant violated: staking amount should never exceed max pool size'
    );
  }

  /// @notice This test ensures that the getters do not revert
  function invariant_gettersShouldNotRevert() public useCurrentTimestamp {
    address staker = _getRandomStaker(address(s_communityStakingPool));
    s_communityStakingPool.getChainlinkToken();
    s_communityStakingPool.getClaimPeriodEndsAt(staker);
    uint256 currentCheckpointId = s_communityStakingPool.getCurrentCheckpointId();
    s_communityStakingPool.getMaxPoolSize();
    s_communityStakingPool.getMerkleRoot();
    s_communityStakingPool.getMigrationProxy();
    s_communityStakingPool.getMigrationTarget();
    s_communityStakingPool.getRewardVault();
    s_communityStakingPool.getStakerStakedAtTime(staker);
    s_communityStakingPool.getStakerStakedAtTimeAt(staker, _getRandomNumber(0, currentCheckpointId));
    s_communityStakingPool.getStakerLimits();
    s_communityStakingPool.getStakerPrincipal(staker);
    s_communityStakingPool.getStakerPrincipalAt(staker, _getRandomNumber(0, currentCheckpointId));
    s_communityStakingPool.getTotalPrincipal();
    s_communityStakingPool.getUnbondingEndsAt(staker);
    s_communityStakingPool.getUnbondingParams();
    s_communityStakingPool.paused();
    s_communityStakingPool.typeAndVersion();
  }

  function test() public override {}
}
