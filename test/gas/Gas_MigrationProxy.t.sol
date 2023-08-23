// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {StakingPoolV01} from '../base-scenarios/StakingV01Scenarios.t.sol';

contract Gas_StakingV01_Migrate_AsOperator is StakingPoolV01 {
  uint256 s_amountToStake;
  uint256 s_amountToWithdraw;

  function setUp() public override {
    StakingPoolV01.setUp();

    changePrank(OPERATOR_STAKER_ONE);
    uint256 migratableAmount = s_stakingV01.getStake(OPERATOR_STAKER_ONE)
      + s_stakingV01.getBaseReward(OPERATOR_STAKER_ONE)
      + s_stakingV01.getDelegationReward(OPERATOR_STAKER_ONE);
    s_amountToStake = OPERATOR_MIN_PRINCIPAL;
    s_amountToWithdraw = migratableAmount - s_amountToStake;
  }

  function test_Gas_MigrateFullAmount() public {
    bytes memory empty;
    s_stakingV01.migrate(empty);
  }

  function test_Gas_MigratePartialAmount() public {
    s_stakingV01.migrate(abi.encode(s_amountToStake, s_amountToWithdraw));
  }
}

contract Gas_StakingV01_Migrate_AsCommunityStaker is StakingPoolV01 {
  uint256 s_amountToStake;
  uint256 s_amountToWithdraw;

  function setUp() public override {
    StakingPoolV01.setUp();

    changePrank(COMMUNITY_STAKER_ONE);
    uint256 migratableAmount = s_stakingV01.getStake(COMMUNITY_STAKER_ONE)
      + s_stakingV01.getBaseReward(COMMUNITY_STAKER_ONE)
      + s_stakingV01.getDelegationReward(COMMUNITY_STAKER_ONE);
    s_amountToStake = COMMUNITY_MIN_PRINCIPAL;
    s_amountToWithdraw = migratableAmount - s_amountToStake;
  }

  function test_Gas_MigrateFullAmount() public {
    bytes memory empty;
    s_stakingV01.migrate(empty);
  }

  function test_Gas_MigratePartialAmount() public {
    s_stakingV01.migrate(abi.encode(s_amountToStake, s_amountToWithdraw));
  }
}
