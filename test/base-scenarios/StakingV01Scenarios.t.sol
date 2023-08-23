// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {BaseTest} from '../BaseTest.t.sol';
import {MigrationProxy} from '../../src/MigrationProxy.sol';
import {StakingV01} from '../../src/staking-v0.1/Staking.sol';

abstract contract StakingPoolV01 is BaseTest {
  StakingV01 s_stakingV01;
  uint256 internal constant INITIAL_MAX_POOL_SIZE = 25_000_000 * 1e18;
  uint256 internal constant MAX_ALERTING_REWARD_AMOUNT = INITIAL_MAX_COMMUNITY_STAKE / 2;
  uint256 internal constant MIN_REWARD_DURATION = 30 days;
  uint256 internal constant SLASHABLE_DURATION = 90 days;
  uint256 internal constant REWARD_RATE = 317;
  uint256 internal constant ONE_MONTH = 30 * 24 * 60 * 60;

  function setUp() public virtual override {
    BaseTest.setUp();

    changePrank(OWNER);
    s_operatorStakingPool.addOperators(_getDefaultOperators());
    s_operatorStakingPool.open();
    s_communityStakingPool.open();
    s_rewardVault.grantRole(s_rewardVault.REWARDER_ROLE(), REWARDER);
    // set the merkle root to merkle tree with only migration proxy address as leaf node
    // this signifies we are in the migrations only phase
    s_communityStakingPool.setMerkleRoot(
      keccak256(abi.encode(keccak256(abi.encode(address(s_migrationProxy)))))
    );

    // deploy and configure the staking v0.1 contract
    s_stakingV01 = new StakingV01(
      StakingV01.PoolConstructorParams({
        LINKAddress: s_LINK,
        monitoredFeed: FEED,
        initialMaxPoolSize: INITIAL_MAX_POOL_SIZE,
        initialMaxCommunityStakeAmount: INITIAL_MAX_COMMUNITY_STAKE,
        initialMaxOperatorStakeAmount: INITIAL_MAX_OPERATOR_STAKE,
        minCommunityStakeAmount: INITIAL_MIN_COMMUNITY_STAKE,
        minOperatorStakeAmount: INITIAL_MIN_OPERATOR_STAKE,
        priorityPeriodThreshold: PRIORITY_PERIOD_THRESHOLD_SECONDS,
        regularPeriodThreshold: REGULAR_PERIOD_THRESHOLD_SECONDS,
        maxAlertingRewardAmount: MAX_ALERTING_REWARD_AMOUNT,
        minInitialOperatorCount: MIN_INITIAL_OPERATOR_COUNT,
        minRewardDuration: MIN_REWARD_DURATION,
        slashableDuration: SLASHABLE_DURATION,
        delegationRateDenominator: DELEGATION_RATE_DENOMINATOR
      })
    );
    address[] memory operators = _getDefaultOperators();
    s_stakingV01.addOperators(operators);
    s_stakingV01.setFeedOperators(operators);
    s_LINK.approve(address(s_stakingV01), REWARD_AMOUNT);
    s_stakingV01.setMerkleRoot(MERKLE_ROOT);
    s_stakingV01.start(REWARD_AMOUNT, REWARD_RATE);
    s_stakingV01.setMerkleRoot(bytes32(''));

    changePrank(COMMUNITY_STAKER_ONE);
    bytes32[] memory proof;
    s_LINK.transferAndCall(address(s_stakingV01), COMMUNITY_MIN_PRINCIPAL, abi.encode(proof));

    changePrank(OPERATOR_STAKER_ONE);
    bytes memory empty;
    s_LINK.transferAndCall(address(s_stakingV01), OPERATOR_MIN_PRINCIPAL, empty);

    changePrank(OWNER);
    vm.warp(block.timestamp + ONE_MONTH + 1);
    s_stakingV01.conclude();

    s_migrationProxy = new MigrationProxy(
      MigrationProxy.ConstructorParams({
        LINKAddress: s_LINK,
        v01StakingAddress: address(s_stakingV01),
        operatorStakingPool: s_operatorStakingPool,
        communityStakingPool: s_communityStakingPool,
        adminRoleTransferDelay: ADMIN_ROLE_TRANSFER_DELAY
      })
    );
    s_LINK.transfer(address(s_stakingV01), 1_000_000 ether);

    s_stakingV01.proposeMigrationTarget(address(s_migrationProxy));
    vm.warp(block.timestamp + 7 days);
    s_stakingV01.acceptMigrationTarget();

    // set migration proxy on both staking pools
    s_operatorStakingPool.setMigrationProxy(address(s_migrationProxy));
    s_communityStakingPool.setMigrationProxy(address(s_migrationProxy));

    changePrank(REWARDER);
    s_rewardVault.addReward(address(0), REWARD_AMOUNT, EMISSION_RATE);
  }

  function test() public virtual override {}
}
