// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {BaseInvariant} from './BaseInvariant.t.sol';

contract OperatorStakingPoolInvariants is BaseInvariant {
  /// @notice This test ensures that the total staked LINK amount is equal to the sum of the staker
  /// staked LINK amounts
  function invariant_stakerPrincipalsEqualTotalPrincipal() public useCurrentTimestamp {
    assertEq(
      s_operatorStakingPoolHandler.getTotalStaked(),
      s_operatorStakingPool.getTotalPrincipal(),
      'Invariant violated: the sum of staker principals must always equal the total principal'
    );
  }

  /// @notice This test ensures that community staker is not staking in operator pool
  function invariant_communityStakerShouldNotBeStakingInOperatorPool() public useCurrentTimestamp {
    address[] memory stakers = s_communityStakingPoolHandler.getStakers();
    for (uint256 i; i < stakers.length; ++i) {
      assertEq(
        s_operatorStakingPool.getStakerPrincipal(stakers[i]),
        0,
        'Invariant violated: community staker should not be staking in operator pool'
      );
    }
  }

  /// @notice This test ensures that the total staked amount never exceeds the max pool size
  function invariant_stakingAmountNeverExceedsMaxPoolSize() public useCurrentTimestamp {
    assertLe(
      s_operatorStakingPoolHandler.getTotalStaked(),
      s_operatorStakingPool.getMaxPoolSize(),
      'Invariant violated: staking amount should never exceed max pool size'
    );
  }

  /// @notice This test ensures that the getters do not revert
  function invariant_gettersShouldNotRevert() public useCurrentTimestamp {
    address staker = _getRandomStaker(address(s_operatorStakingPool));
    s_operatorStakingPool.getAlerterRewardFunds();
    s_operatorStakingPool.getChainlinkToken();
    s_operatorStakingPool.getClaimPeriodEndsAt(staker);
    uint256 currentCheckpointId = s_operatorStakingPool.getCurrentCheckpointId();
    s_operatorStakingPool.getMaxPoolSize();
    s_operatorStakingPool.getMigrationProxy();
    s_operatorStakingPool.getMigrationTarget();
    s_operatorStakingPool.getNumOperators();
    s_operatorStakingPool.getRemovedPrincipal(staker);
    s_operatorStakingPool.getSlashCapacity(address(0));
    s_operatorStakingPool.getSlasherConfig(address(0));
    s_operatorStakingPool.getRewardVault();
    s_operatorStakingPool.getStakerStakedAtTime(staker);
    s_operatorStakingPool.getStakerStakedAtTimeAt(staker, _getRandomNumber(0, currentCheckpointId));
    s_operatorStakingPool.getStakerLimits();
    s_operatorStakingPool.getStakerPrincipal(staker);
    s_operatorStakingPool.getStakerPrincipalAt(staker, _getRandomNumber(0, currentCheckpointId));
    s_operatorStakingPool.getTotalPrincipal();
    s_operatorStakingPool.getUnbondingEndsAt(staker);
    s_operatorStakingPool.getUnbondingParams();
    s_operatorStakingPool.paused();
    s_operatorStakingPool.typeAndVersion();
  }

  function test() public override {}
}
