// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {BaseTest} from '../BaseTest.t.sol';
import {LinkTokenInterface} from '@chainlink/contracts/src/v0.8/interfaces/LinkTokenInterface.sol';
import {CommunityStakingPool} from '../../src/pools/CommunityStakingPool.sol';
import {MigrationProxy} from '../../src/MigrationProxy.sol';
import {OperatorStakingPool} from '../../src/pools/OperatorStakingPool.sol';
import {StakingPoolBase} from '../../src/pools/StakingPoolBase.sol';

abstract contract StakingPool_Opened is BaseTest {
  function setUp() public virtual override {
    BaseTest.setUp();
    changePrank(OWNER);
    s_operatorStakingPool.addOperators(_getDefaultOperators());
    s_operatorStakingPool.open();
    s_communityStakingPool.open();
    s_rewardVault.grantRole(s_rewardVault.REWARDER_ROLE(), REWARDER);

    changePrank(REWARDER);
    s_rewardVault.addReward(address(0), REWARD_AMOUNT, EMISSION_RATE);
  }

  function test() public virtual override {}
}

abstract contract StakingPool_MigrationsOnly is StakingPool_Opened {
  function setUp() public virtual override {
    StakingPool_Opened.setUp();
    changePrank(OWNER);
    // set the merkle root to merkle tree with only migration proxy address as leaf node
    // this signifies we are in the migrations only phase
    s_communityStakingPool.setMerkleRoot(
      keccak256(abi.encode(keccak256(abi.encode(address(s_migrationProxy)))))
    );
  }

  // This is needed so that "forge coverage" will ignore this contract
  function test() public virtual override {}
}

abstract contract StakingPool_WithStakers is StakingPool_Opened {
  event Unstaked(address indexed staker, uint256 amount, uint256 claimedReward);

  function setUp() public virtual override {
    StakingPool_Opened.setUp();

    changePrank(OPERATOR_STAKER_ONE);
    s_LINK.transferAndCall(address(s_operatorStakingPool), OPERATOR_MIN_PRINCIPAL, '');

    changePrank(OPERATOR_STAKER_TWO);
    s_LINK.transferAndCall(address(s_operatorStakingPool), OPERATOR_MIN_PRINCIPAL * 3, '');

    changePrank(COMMUNITY_STAKER_ONE);
    s_LINK.transferAndCall(
      address(s_communityStakingPool),
      COMMUNITY_MIN_PRINCIPAL,
      abi.encode(s_communityStakerOneProof)
    );

    changePrank(COMMUNITY_STAKER_TWO);
    s_LINK.transferAndCall(
      address(s_communityStakingPool),
      COMMUNITY_MIN_PRINCIPAL * 3,
      abi.encode(s_communityStakerTwoProof)
    );

    s_stakedAtTime = block.timestamp;
  }

  // This is needed so that "forge coverage" will ignore this contract
  function test() public virtual override {}
}

abstract contract StakingPool_WhenPoolsAreClosed is StakingPool_WithStakers {
  // In practice we hopefully will never have to close the staking pool
  uint256 STAKING_PERIOD = 180 days;

  function setUp() public virtual override {
    StakingPool_WithStakers.setUp();

    vm.warp(block.timestamp + STAKING_PERIOD);
    changePrank(OWNER);
    s_operatorStakingPool.close();
    s_communityStakingPool.close();
  }

  // This is needed so that "forge coverage" will ignore this contract
  function test() public virtual override {}
}

abstract contract StakingPool_InUnbondingPeriod is StakingPool_WithStakers {
  function setUp() public virtual override {
    StakingPool_WithStakers.setUp();

    changePrank(OPERATOR_STAKER_ONE);
    s_operatorStakingPool.unbond();

    changePrank(OPERATOR_STAKER_TWO);
    s_operatorStakingPool.unbond();

    changePrank(COMMUNITY_STAKER_ONE);
    s_communityStakingPool.unbond();

    changePrank(COMMUNITY_STAKER_TWO);
    s_communityStakingPool.unbond();
  }

  // This is needed so that "forge coverage" will ignore this contract
  function test() public virtual override {}
}

abstract contract StakingPool_StakeInUnbondingPeriod is StakingPool_InUnbondingPeriod {
  function setUp() public override {
    // Move one day into unbonding period
    vm.warp(block.timestamp + 1 days);

    StakingPool_InUnbondingPeriod.setUp();

    changePrank(OPERATOR_STAKER_ONE);
    s_LINK.transferAndCall(address(s_operatorStakingPool), OPERATOR_MIN_PRINCIPAL, '');

    changePrank(OPERATOR_STAKER_TWO);
    s_LINK.transferAndCall(address(s_operatorStakingPool), OPERATOR_MIN_PRINCIPAL, '');

    changePrank(COMMUNITY_STAKER_ONE);
    s_LINK.transferAndCall(
      address(s_communityStakingPool),
      COMMUNITY_MIN_PRINCIPAL,
      abi.encode(s_communityStakerOneProof)
    );

    changePrank(COMMUNITY_STAKER_TWO);
    s_LINK.transferAndCall(
      address(s_communityStakingPool),
      COMMUNITY_MIN_PRINCIPAL,
      abi.encode(s_communityStakerTwoProof)
    );
  }

  // This is needed so that "forge coverage" will ignore this contract
  function test() public virtual override {}
}

abstract contract StakingPool_InClaimPeriod is StakingPool_InUnbondingPeriod {
  function setUp() public virtual override {
    StakingPool_InUnbondingPeriod.setUp();

    // Move past unbonding period
    vm.warp(block.timestamp + UNBONDING_PERIOD);
  }

  // This is needed so that "forge coverage" will ignore this contract
  function test() public virtual override {}
}

abstract contract StakingPool_WhenClaimPeriodEndsAt is StakingPool_InUnbondingPeriod {
  function setUp() public virtual override {
    StakingPool_InUnbondingPeriod.setUp();

    // Move time to the claimPeriodEndsAt
    vm.warp(block.timestamp + UNBONDING_PERIOD + CLAIM_PERIOD);
  }

  // This is needed so that "forge coverage" will ignore this contract
  function test() public virtual override {}
}

abstract contract StakingPool_MigrationProxyUnset is BaseTest {
  function setUp() public virtual override {
    // Start at T = 0
    vm.warp(0);
    vm.startPrank(OWNER);

    // Setup LINK token
    s_LINK = LinkTokenInterface(deployCode('LinkToken.sol'));
    s_LINK.transfer(COMMUNITY_STAKER_ONE, 10_000 ether);
    s_LINK.transfer(COMMUNITY_STAKER_TWO, 10_000 ether);
    s_LINK.transfer(OPERATOR_STAKER_ONE, 100_000 ether);
    s_LINK.transfer(OPERATOR_STAKER_TWO, 100_000 ether);

    s_operatorStakingPool = new OperatorStakingPool(
      OperatorStakingPool.ConstructorParams({
        minInitialOperatorCount: MIN_INITIAL_OPERATOR_COUNT,
        baseParams: StakingPoolBase.ConstructorParamsBase({
          LINKAddress: s_LINK,
          initialMaxPoolSize: OPERATOR_MAX_POOL_SIZE,
          initialMaxPrincipalPerStaker: OPERATOR_MAX_PRINCIPAL,
          minPrincipalPerStaker: OPERATOR_MIN_PRINCIPAL,
          initialUnbondingPeriod: INITIAL_UNBONDING_PERIOD,
          maxUnbondingPeriod: MAX_UNBONDING_PERIOD,
          initialClaimPeriod: INITIAL_CLAIM_PERIOD,
          minClaimPeriod: MIN_CLAIM_PERIOD,
          maxClaimPeriod: MAX_CLAIM_PERIOD,
          adminRoleTransferDelay: ADMIN_ROLE_TRANSFER_DELAY
        })
      })
    );
    s_communityStakingPool = new CommunityStakingPool(
      CommunityStakingPool.ConstructorParams({
        operatorStakingPool: s_operatorStakingPool,
        baseParams: StakingPoolBase.ConstructorParamsBase({
          LINKAddress: s_LINK,
          initialMaxPoolSize: COMMUNITY_MAX_POOL_SIZE,
          initialMaxPrincipalPerStaker: COMMUNITY_MAX_PRINCIPAL,
          minPrincipalPerStaker: COMMUNITY_MIN_PRINCIPAL,
          initialUnbondingPeriod: INITIAL_UNBONDING_PERIOD,
          maxUnbondingPeriod: MAX_UNBONDING_PERIOD,
          initialClaimPeriod: INITIAL_CLAIM_PERIOD,
          minClaimPeriod: MIN_CLAIM_PERIOD,
          maxClaimPeriod: MAX_CLAIM_PERIOD,
          adminRoleTransferDelay: ADMIN_ROLE_TRANSFER_DELAY
        })
      })
    );
    s_communityStakingPool.setMerkleRoot(MERKLE_ROOT);

    // Proof generated off chain for keccak256(address(1))
    s_communityStakerOneProof.push(
      0x405787fa12a823e0f2b7631cc41b3ba8828b3321ca811111fa75cd3aa3bb5ace
    );
    // Proof generated off chain for keccak256(address(2))
    s_communityStakerTwoProof.push(
      0xb10e2d527612073b26eecdfd717e6a320cf44b4afac2b0732d9fcbe2b7fa0cf6
    );

    // deploy migration proxy
    s_migrationProxy = new MigrationProxy(
      MigrationProxy.ConstructorParams({
        LINKAddress: s_LINK,
        v01StakingAddress: MOCK_STAKING_V01,
        operatorStakingPool: s_operatorStakingPool,
        communityStakingPool: s_communityStakingPool,
        adminRoleTransferDelay: ADMIN_ROLE_TRANSFER_DELAY
      })
    );
    s_LINK.transfer(MOCK_STAKING_V01, 1_000_000 ether);
  }

  // This is needed so that "forge coverage" will ignore this contract
  function test() public virtual override {}
}

abstract contract StakingPool_StakingLimitsUnset is BaseTest {
  uint96 constant INITIAL_MAX_POOL_SIZE = 10;
  uint96 constant INITIAL_MAX_PRINCIPAL_PER_STAKER = 5;
  uint96 constant MIN_PRINCIPAL_PER_STAKER = 1;

  function setUp() public virtual override {
    BaseTest.setUp();

    changePrank(OWNER);

    s_operatorStakingPool = new OperatorStakingPool(
      OperatorStakingPool.ConstructorParams({
        minInitialOperatorCount: 0,
        baseParams: StakingPoolBase.ConstructorParamsBase({
          LINKAddress: s_LINK,
          initialMaxPoolSize: INITIAL_MAX_POOL_SIZE,
          initialMaxPrincipalPerStaker: INITIAL_MAX_PRINCIPAL_PER_STAKER,
          minPrincipalPerStaker: MIN_PRINCIPAL_PER_STAKER,
          initialUnbondingPeriod: INITIAL_UNBONDING_PERIOD,
          maxUnbondingPeriod: MAX_UNBONDING_PERIOD,
          initialClaimPeriod: INITIAL_CLAIM_PERIOD,
          minClaimPeriod: MIN_CLAIM_PERIOD,
          maxClaimPeriod: MAX_CLAIM_PERIOD,
          adminRoleTransferDelay: ADMIN_ROLE_TRANSFER_DELAY
        })
      })
    );

    s_communityStakingPool = new CommunityStakingPool(
      CommunityStakingPool.ConstructorParams({
        operatorStakingPool: s_operatorStakingPool,
        baseParams: StakingPoolBase.ConstructorParamsBase({
          LINKAddress: s_LINK,
          initialMaxPoolSize: INITIAL_MAX_POOL_SIZE,
          initialMaxPrincipalPerStaker: INITIAL_MAX_PRINCIPAL_PER_STAKER,
          minPrincipalPerStaker: MIN_PRINCIPAL_PER_STAKER,
          initialUnbondingPeriod: INITIAL_UNBONDING_PERIOD,
          maxUnbondingPeriod: MAX_UNBONDING_PERIOD,
          initialClaimPeriod: INITIAL_CLAIM_PERIOD,
          minClaimPeriod: MIN_CLAIM_PERIOD,
          maxClaimPeriod: MAX_CLAIM_PERIOD,
          adminRoleTransferDelay: ADMIN_ROLE_TRANSFER_DELAY
        })
      })
    );
    s_communityStakingPool.setMerkleRoot(MERKLE_ROOT);
  }

  // This is needed so that "forge coverage" will ignore this contract
  function test() public virtual override {}
}

abstract contract StakingPool_WhenPaused is StakingPool_WithStakers {
  function setUp() public virtual override {
    StakingPool_WithStakers.setUp();

    changePrank(PAUSER);

    s_communityStakingPool.emergencyPause();
    s_operatorStakingPool.emergencyPause();
  }

  // This is needed so that "forge coverage" will ignore this contract
  function test() public virtual override {}
}
