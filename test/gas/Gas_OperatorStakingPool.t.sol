// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {BaseTest} from '../BaseTest.t.sol';
import {StakingPool_Opened} from '../base-scenarios/StakingPoolScenarios.t.sol';
import {RewardVault_WithStakersAndTimePassed} from '../base-scenarios/RewardVaultScenarios.t.sol';
import {
  IStakingPool_Gas_OpenAndNoStakers,
  IStakingPool_Gas_OpenWithStakers_AndWithTimePassed,
  IStakingPool_Gas_OpenWithStakersInUnbondingPeriod,
  IStakingPool_Gas_OpenWithStakers_AsASubsequentStakerAndWithTimePassed,
  IStakingPool_Gas_OpenWithStakersClaimReward
} from '../interfaces/IStakingPoolTest.t.sol';

contract Gas_OperatorStakingPool_OpenAndNoStakers is
  IStakingPool_Gas_OpenAndNoStakers,
  StakingPool_Opened
{
  function setUp() public override {
    StakingPool_Opened.setUp();
    changePrank(OPERATOR_STAKER_ONE);
  }

  function test_Gas_StakingAsFirstStaker() public override {
    s_LINK.transferAndCall(
      address(s_operatorStakingPool), OPERATOR_MIN_PRINCIPAL, abi.encode(OPERATOR_STAKER_ONE, '')
    );
  }
}

contract Gas_OperatorStakingPool_OpenWithStakers_AsASubsequentStakerAndWithTimePassed is
  IStakingPool_Gas_OpenWithStakers_AsASubsequentStakerAndWithTimePassed,
  RewardVault_WithStakersAndTimePassed
{
  function setUp() public override {
    RewardVault_WithStakersAndTimePassed.setUp();
    changePrank(OPERATOR_STAKER_TWO);
  }

  function test_Gas_StakingAsSubsequentStaker() public override {
    s_LINK.transferAndCall(
      address(s_operatorStakingPool), OPERATOR_MIN_PRINCIPAL, abi.encode(OPERATOR_STAKER_ONE, '')
    );
  }
}

contract Gas_OperatorStakingPool__OpenWithStakers_AndWithTimePassed is
  IStakingPool_Gas_OpenWithStakers_AndWithTimePassed,
  RewardVault_WithStakersAndTimePassed
{
  function setUp() public override {
    RewardVault_WithStakersAndTimePassed.setUp();

    changePrank(OPERATOR_STAKER_ONE);
    s_LINK.transferAndCall(
      address(s_operatorStakingPool), OPERATOR_MIN_PRINCIPAL, abi.encode(OPERATOR_STAKER_ONE, '')
    );
  }

  function test_Gas_StakingASecondTime() public override {
    s_LINK.transferAndCall(
      address(s_operatorStakingPool), OPERATOR_MIN_PRINCIPAL, abi.encode(OPERATOR_STAKER_ONE, '')
    );
  }

  function test_Gas_Unbonding() public override {
    s_operatorStakingPool.unbond();
  }
}

contract Gas_OperatorStakingPool_OpenWithStakersInUnbondingPeriod is
  RewardVault_WithStakersAndTimePassed,
  IStakingPool_Gas_OpenWithStakersInUnbondingPeriod
{
  function setUp() public override {
    RewardVault_WithStakersAndTimePassed.setUp();

    changePrank(OPERATOR_STAKER_ONE);
    s_operatorStakingPool.unbond();
    skip(UNBONDING_PERIOD);
  }

  function test_Gas_Unstake() public override {
    s_operatorStakingPool.unstake(OPERATOR_MIN_PRINCIPAL, false);
  }
}

contract Gas_OperatorStakingPool_OpenWithStakersClaimReward is
  RewardVault_WithStakersAndTimePassed,
  IStakingPool_Gas_OpenWithStakersClaimReward
{
  function setUp() public override {
    RewardVault_WithStakersAndTimePassed.setUp();

    changePrank(OPERATOR_STAKER_ONE);
  }

  function test_Gas_ClaimReward() public override {
    s_rewardVault.claimReward();
  }
}

contract Gas_OperatorStakingPool_AddOperators is BaseTest {
  function setUp() public override {
    BaseTest.setUp();
    changePrank(OWNER);
  }

  function test_Gas_AddOperators() public {
    s_operatorStakingPool.addOperators(_getDefaultOperators());
  }
}

contract Gas_OperatorStakingPool_RemoveOperators is BaseTest {
  function setUp() public override {
    BaseTest.setUp();
    changePrank(OWNER);
    s_operatorStakingPool.addOperators(_getDefaultOperators());
    s_operatorStakingPool.open();
  }

  function test_Gas_RemoveOperators() public {
    s_operatorStakingPool.removeOperators(_getDefaultOperators());
  }
}
