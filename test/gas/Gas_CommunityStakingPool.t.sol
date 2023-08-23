// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {StakingPool_Opened} from '../base-scenarios/StakingPoolScenarios.t.sol';
import {RewardVault_WithStakersAndTimePassed} from '../base-scenarios/RewardVaultScenarios.t.sol';
import {
  IStakingPool_Gas_OpenAndNoStakers,
  IStakingPool_Gas_OpenWithStakers_AndWithTimePassed,
  IStakingPool_Gas_OpenWithStakersInUnbondingPeriod,
  IStakingPool_Gas_OpenWithStakers_AsASubsequentStakerAndWithTimePassed,
  IStakingPool_Gas_OpenWithStakersClaimReward
} from '../interfaces/IStakingPoolTest.t.sol';

contract Gas_CommunityStakingPool_OpenAndNoStakersAndPrivate is
  IStakingPool_Gas_OpenAndNoStakers,
  StakingPool_Opened
{
  function setUp() public override {
    StakingPool_Opened.setUp();
    changePrank(COMMUNITY_STAKER_ONE);
  }

  function test_Gas_StakingAsFirstStaker() public override {
    s_LINK.transferAndCall(
      address(s_communityStakingPool),
      COMMUNITY_MIN_PRINCIPAL,
      abi.encode(s_communityStakerOneProof, '')
    );
  }
}

contract Gas_CommunityStakingPool_OpenAndNoStakersAndPublic is
  IStakingPool_Gas_OpenAndNoStakers,
  StakingPool_Opened
{
  function setUp() public override {
    StakingPool_Opened.setUp();

    changePrank(OWNER);
    s_communityStakingPool.setMerkleRoot(bytes32(''));

    changePrank(COMMUNITY_STAKER_ONE);
  }

  function test_Gas_StakingAsFirstStaker() public override {
    s_LINK.transferAndCall(
      address(s_communityStakingPool),
      COMMUNITY_MIN_PRINCIPAL,
      abi.encode(s_communityStakerOneProof, '')
    );
  }
}

contract Gas_CommunityStakingPool__OpenWithStakersAndPrivate_AndWithTimePassed is
  IStakingPool_Gas_OpenWithStakers_AndWithTimePassed,
  RewardVault_WithStakersAndTimePassed
{
  function setUp() public override {
    RewardVault_WithStakersAndTimePassed.setUp();

    changePrank(COMMUNITY_STAKER_ONE);
    s_LINK.transferAndCall(
      address(s_communityStakingPool),
      COMMUNITY_MIN_PRINCIPAL,
      abi.encode(s_communityStakerOneProof, '')
    );
  }

  function test_Gas_StakingASecondTime() public override {
    s_LINK.transferAndCall(
      address(s_communityStakingPool),
      COMMUNITY_MIN_PRINCIPAL,
      abi.encode(s_communityStakerOneProof, '')
    );
  }

  function test_Gas_Unbonding() public override {
    s_communityStakingPool.unbond();
  }
}

contract Gas_CommunityStakingPool__OpenWithStakersAndPublic_AndWithTimePassed is
  IStakingPool_Gas_OpenWithStakers_AndWithTimePassed,
  RewardVault_WithStakersAndTimePassed
{
  function setUp() public override {
    RewardVault_WithStakersAndTimePassed.setUp();

    changePrank(OWNER);
    s_communityStakingPool.setMerkleRoot(bytes32(''));

    changePrank(COMMUNITY_STAKER_ONE);
    s_LINK.transferAndCall(
      address(s_communityStakingPool),
      COMMUNITY_MIN_PRINCIPAL,
      abi.encode(s_communityStakerOneProof, '')
    );
  }

  function test_Gas_StakingASecondTime() public override {
    s_LINK.transferAndCall(address(s_communityStakingPool), COMMUNITY_MIN_PRINCIPAL, abi.encode(''));
  }

  function test_Gas_Unbonding() public override {
    s_communityStakingPool.unbond();
  }
}

contract Gas_CommunityStakingPool_OpenWithStakersAndPrivate_AsASubsequentStakerAndWithTimePassed is
  RewardVault_WithStakersAndTimePassed,
  IStakingPool_Gas_OpenWithStakers_AsASubsequentStakerAndWithTimePassed
{
  function setUp() public override {
    RewardVault_WithStakersAndTimePassed.setUp();

    changePrank(COMMUNITY_STAKER_ONE);
    s_LINK.transferAndCall(
      address(s_communityStakingPool),
      COMMUNITY_MIN_PRINCIPAL,
      abi.encode(s_communityStakerOneProof, '')
    );

    changePrank(COMMUNITY_STAKER_TWO);
  }

  function test_Gas_StakingAsSubsequentStaker() public override {
    s_LINK.transferAndCall(
      address(s_communityStakingPool),
      COMMUNITY_MIN_PRINCIPAL,
      abi.encode(s_communityStakerTwoProof, '')
    );
  }
}

contract Gas_CommunityStakingPool_OpenWithStakersAndPublic_AsASubsequentStakerAndWithTimePassed is
  RewardVault_WithStakersAndTimePassed,
  IStakingPool_Gas_OpenWithStakers_AsASubsequentStakerAndWithTimePassed
{
  function setUp() public override {
    RewardVault_WithStakersAndTimePassed.setUp();

    changePrank(OWNER);
    s_communityStakingPool.setMerkleRoot(bytes32(''));

    changePrank(COMMUNITY_STAKER_ONE);
    s_LINK.transferAndCall(
      address(s_communityStakingPool),
      COMMUNITY_MIN_PRINCIPAL,
      abi.encode(s_communityStakerOneProof, '')
    );

    changePrank(COMMUNITY_STAKER_TWO);
  }

  function test_Gas_StakingAsSubsequentStaker() public override {
    s_LINK.transferAndCall(address(s_communityStakingPool), COMMUNITY_MIN_PRINCIPAL, abi.encode(''));
  }
}

contract Gas_CommunityStakingPool_OpenWithStakersInUnbondingPeriod is
  RewardVault_WithStakersAndTimePassed,
  IStakingPool_Gas_OpenWithStakersInUnbondingPeriod
{
  function setUp() public override {
    RewardVault_WithStakersAndTimePassed.setUp();

    changePrank(COMMUNITY_STAKER_ONE);
    s_communityStakingPool.unbond();
    skip(UNBONDING_PERIOD);
  }

  function test_Gas_Unstake() public override {
    changePrank(COMMUNITY_STAKER_ONE);
    s_communityStakingPool.unstake(COMMUNITY_MIN_PRINCIPAL, false);
  }
}

contract Gas_CommunityStakingPool_OpenWithStakersClaimReward is
  RewardVault_WithStakersAndTimePassed,
  IStakingPool_Gas_OpenWithStakersClaimReward
{
  function setUp() public override {
    RewardVault_WithStakersAndTimePassed.setUp();

    changePrank(COMMUNITY_STAKER_ONE);
  }

  function test_Gas_ClaimReward() public override {
    s_rewardVault.claimReward();
  }
}
