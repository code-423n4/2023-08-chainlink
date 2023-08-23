// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {IAccessControlDefaultAdminRules} from
  '@openzeppelin/contracts/access/IAccessControlDefaultAdminRules.sol';
import {FixedPointMathLib} from '@solmate/utils/FixedPointMathLib.sol';
import {RewardVault_WithStakersAndTimePassed} from '../base-scenarios/RewardVaultScenarios.t.sol';
import {BaseTestTimelocked} from '../BaseTestTimelocked.t.sol';
import {CommunityStakingPool} from '../../src/pools/CommunityStakingPool.sol';
import {OperatorStakingPool} from '../../src/pools/OperatorStakingPool.sol';
import {RewardVault} from '../../src/rewards/RewardVault.sol';
import {StakingPoolBase} from '../../src/pools/StakingPoolBase.sol';
import {Timelock} from '../../src/timelock/Timelock.sol';
import {IMigratable} from '../../src/interfaces/IMigratable.sol';
import {ISlashable} from '../../src/interfaces/ISlashable.sol';
import {IStakingOwner} from '../../src/interfaces/IStakingOwner.sol';
import {AggregatorV3Interface} from
  '@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol';

contract StakingPoolUpgradeOneStakerTest is BaseTestTimelocked {
  uint256 private constant INTEGRATION_TEST_START_TIME = TEST_START_TIME + 10;
  uint256 private constant TIME_AFTER_MIGRATION = 10 days;
  uint256 private s_migratedAtTime;

  address internal constant NEW_STAKER = address(8888);
  RewardVault internal s_rewardVaultVersion2;
  uint256 private s_operatorOneStakerRewardsAtMigrateTime;

  // Let's assume that this staking pool is for a new staker type
  OperatorStakingPool internal s_newStakerTypePool;

  RewardVault.RewardBuckets private s_rewardBucketsBeforeMigration;
  Timelock.Call[] private s_timelockUpgradeCalls;

  function setUp() public override {
    BaseTestTimelocked.setUp();

    s_operatorOneStakerRewardsAtMigrateTime = s_rewardVault.getReward(OPERATOR_STAKER_ONE);

    changePrank(OWNER);

    s_LINK.transfer(NEW_STAKER, 10_000 ether);

    // Configure new pool
    s_newStakerTypePool = new OperatorStakingPool(
      OperatorStakingPool.ConstructorParams({
        minInitialOperatorCount: MIN_INITIAL_OPERATOR_COUNT,
        baseParams: StakingPoolBase.ConstructorParamsBase({
          LINKAddress: s_LINK,
          initialMaxPoolSize: INITIAL_MAX_OPERATOR_POOL_SIZE,
          initialMaxPrincipalPerStaker: INITIAL_MAX_OPERATOR_STAKE,
          minPrincipalPerStaker: INITIAL_MIN_OPERATOR_STAKE,
          initialUnbondingPeriod: INITIAL_UNBONDING_PERIOD,
          maxUnbondingPeriod: MAX_UNBONDING_PERIOD,
          initialClaimPeriod: INITIAL_CLAIM_PERIOD,
          minClaimPeriod: MIN_CLAIM_PERIOD,
          maxClaimPeriod: MAX_CLAIM_PERIOD,
          adminRoleTransferDelay: ADMIN_ROLE_TRANSFER_DELAY
        })
      })
    );
    s_newStakerTypePool.setRewardVault(s_rewardVault);
    address[] memory operators = _getDefaultOperators();

    // Make one of the operators a new staker
    operators[operators.length - 1] = NEW_STAKER;
    s_newStakerTypePool.addOperators(operators);

    // Configure new reward vault
    s_rewardVaultVersion2 = new RewardVault(
        RewardVault.ConstructorParams({
        linkToken: s_LINK,
        communityStakingPool: s_communityStakingPool,
        operatorStakingPool: s_newStakerTypePool, // Let's assume the new staker type pool replaces the operator staking pool
        delegationRateDenominator: DELEGATION_RATE_DENOMINATOR,
        initialMultiplierDuration: INITIAL_MULTIPLIER_DURATION,
        adminRoleTransferDelay: ADMIN_ROLE_TRANSFER_DELAY
      })
    );
    s_rewardVaultVersion2.grantRole(
      s_rewardVaultVersion2.REWARDER_ROLE(), address(s_newStakerTypePool)
    );
    s_rewardVaultVersion2.grantRole(
      s_rewardVaultVersion2.REWARDER_ROLE(), address(s_communityStakingPool)
    );

    s_rewardVaultVersion2.setMigrationSource(address(s_rewardVault));

    // In practice the addresses that the contracts point to will be updated
    // at the same time in a batched transaction.
    s_newStakerTypePool.setRewardVault(s_rewardVaultVersion2);
    s_rewardVaultVersion2.beginDefaultAdminTransfer(address(s_stakingTimelock));

    changePrank(PROPOSER_ONE);
    Timelock.Call[] memory calls = _singletonCalls(
      _timelockCall(
        address(s_rewardVaultVersion2),
        abi.encodeWithSelector(IAccessControlDefaultAdminRules.acceptDefaultAdminTransfer.selector)
      )
    );
    s_stakingTimelock.scheduleBatch(calls, NO_PREDECESSOR, EMPTY_SALT, MIN_DELAY);
    vm.warp(block.timestamp + MIN_DELAY);

    changePrank(EXECUTOR_ONE);
    s_stakingTimelock.executeBatch(calls, NO_PREDECESSOR, EMPTY_SALT);
    _saveRewardBuckets();

    // step 1: schedule upgrades
    changePrank(PROPOSER_ONE);

    s_timelockUpgradeCalls.push(
      _timelockCall(
        address(s_communityStakingPool),
        abi.encodeWithSelector(CommunityStakingPool.setMerkleRoot.selector, bytes32(''))
      )
    );
    // schedule reward vault upgrade on all staking pools
    s_timelockUpgradeCalls.push(
      _timelockCall(
        address(s_communityStakingPool),
        abi.encodeWithSelector(
          StakingPoolBase.setRewardVault.selector, address(s_rewardVaultVersion2)
        )
      )
    );

    // propose migration of reward vault
    s_timelockUpgradeCalls.push(
      _timelockCall(
        address(s_rewardVault),
        abi.encodeWithSelector(
          IMigratable.setMigrationTarget.selector, address(s_rewardVaultVersion2)
        )
      )
    );
    s_timelockUpgradeCalls.push(
      _timelockCall(
        address(s_rewardVault), abi.encodeWithSelector(RewardVault.migrate.selector, bytes(''))
      )
    );

    s_timelockUpgradeCalls.push(
      _timelockCall(
        address(s_operatorStakingPool),
        abi.encodeWithSelector(
          StakingPoolBase.setMigrationProxy.selector, address(s_newStakerTypePool)
        )
      )
    );

    s_stakingTimelock.scheduleBatch(
      s_timelockUpgradeCalls, NO_PREDECESSOR, EMPTY_SALT, DELAY_ONE_MONTH
    );

    // step 2: wait for time lock to end
    vm.warp(block.timestamp + DELAY_ONE_MONTH);
    _validateRewardBucketsBeforeMigrate();
    _validateIsOpenBeforeMigrate();

    // step 3: execute the upgrades
    changePrank(EXECUTOR_ONE);
    s_stakingTimelock.executeBatch(s_timelockUpgradeCalls, NO_PREDECESSOR, EMPTY_SALT);
    s_migratedAtTime = block.timestamp;
    changePrank(OWNER);
    s_newStakerTypePool.open();

    delete s_timelockUpgradeCalls;

    _validateRewardBucketsAfterMigrate();
    _validateIsOpenAfterMigrate();
  }

  // Test that staker can't stake in old staking pool.
  function test_RevertStakerCannotContinueStakingInTheirPool() public {
    changePrank(OPERATOR_STAKER_ONE);
    vm.expectRevert(StakingPoolBase.RewardVaultNotActive.selector);
    s_LINK.transferAndCall(address(s_operatorStakingPool), OPERATOR_MIN_PRINCIPAL, abi.encode(''));
  }

  function test_StakerCanMigrate() private {
    s_timelockUpgradeCalls.push(
      _timelockCall(
        address(s_operatorStakingPool),
        abi.encodeWithSelector(
          IMigratable.setMigrationTarget.selector, address(s_newStakerTypePool)
        )
      )
    );

    s_timelockUpgradeCalls.push(
      _timelockCall(
        address(s_operatorStakingPool), abi.encodeWithSelector(StakingPoolBase.close.selector)
      )
    );

    changePrank(PROPOSER_ONE);
    s_stakingTimelock.scheduleBatch(
      s_timelockUpgradeCalls, NO_PREDECESSOR, EMPTY_SALT, DELAY_ONE_MONTH
    );

    // step 2: wait for time lock to end
    vm.warp(block.timestamp + DELAY_ONE_MONTH);
    changePrank(EXECUTOR_ONE);
    s_stakingTimelock.executeBatch(s_timelockUpgradeCalls, NO_PREDECESSOR, EMPTY_SALT);
    delete s_timelockUpgradeCalls;

    changePrank(OWNER);
    uint256 stakerPrincipalOldPool = s_operatorStakingPool.getStakerPrincipal(OPERATOR_STAKER_ONE);
    s_newStakerTypePool.setMigrationProxy(address(s_operatorStakingPool));

    changePrank(OPERATOR_STAKER_ONE);
    bytes memory data;
    s_operatorStakingPool.migrate(data);
    uint256 stakerPrincipalNewPool = s_newStakerTypePool.getStakerPrincipal(OPERATOR_STAKER_ONE);
    assertEq(stakerPrincipalNewPool, stakerPrincipalOldPool, 'staker principal');
    assertEq(
      s_operatorStakingPool.getStakerPrincipal(OPERATOR_STAKER_ONE), 0, 'staker principal pool 1'
    );
  }

  function _saveRewardBuckets() private {
    s_rewardBucketsBeforeMigration = s_rewardVault.getRewardBuckets();
  }

  function _validateRewardBucketsBeforeMigrate() private {
    // validate the aggregate reward rates and reward durations are greater than zero in the old
    // vault
    // before migrating

    // calculate pool reward amount
    uint256 communityCommunityMaxSize = s_communityStakingPool.getMaxPoolSize();
    uint256 operatorPoolMaxSize = s_operatorStakingPool.getMaxPoolSize();
    uint256 totalPoolMaxSize = communityCommunityMaxSize + operatorPoolMaxSize;
    uint256 communityCommunityReward = REWARD_AMOUNT * communityCommunityMaxSize / totalPoolMaxSize;
    uint256 operatorPoolReward = REWARD_AMOUNT * operatorPoolMaxSize / totalPoolMaxSize;

    // calculate the expected pool rates
    uint256 expectedOperatorRate = EMISSION_RATE * operatorPoolReward / REWARD_AMOUNT;
    uint256 expectedCommunityRate = EMISSION_RATE * communityCommunityReward / REWARD_AMOUNT;
    uint256 expectedDelegationRate = expectedCommunityRate / DELEGATION_RATE_DENOMINATOR;
    expectedCommunityRate -= expectedDelegationRate;

    // start time is TEST_START_TIME + 10 due to the scenario setup
    uint256 duration = REWARD_AMOUNT / EMISSION_RATE;

    // validate the aggregate reward rates and reward durations before migrating
    assertEq(
      s_rewardBucketsBeforeMigration.operatorBase.emissionRate,
      expectedOperatorRate,
      's_rewardBucketsBeforeMigration.operatorBase.emissionRate'
    );
    assertEq(
      s_rewardBucketsBeforeMigration.operatorBase.rewardDurationEndsAt,
      INTEGRATION_TEST_START_TIME + duration,
      's_rewardBucketsBeforeMigration.operatorBase.rewardDurationEndsAt'
    );

    assertEq(
      s_rewardBucketsBeforeMigration.communityBase.emissionRate,
      expectedCommunityRate,
      's_rewardBucketsBeforeMigration.communityBase.emissionRate'
    );
    assertEq(
      s_rewardBucketsBeforeMigration.communityBase.rewardDurationEndsAt,
      INTEGRATION_TEST_START_TIME + duration,
      's_rewardBucketsBeforeMigration.communityBase.rewardDurationEndsAt'
    );

    assertEq(
      s_rewardBucketsBeforeMigration.operatorDelegated.emissionRate,
      expectedDelegationRate,
      's_rewardBucketsBeforeMigration.operatorDelegated.emissionRate'
    );
    assertEq(
      s_rewardBucketsBeforeMigration.operatorDelegated.rewardDurationEndsAt,
      INTEGRATION_TEST_START_TIME + duration,
      's_rewardBucketsBeforeMigration.operatorDelegated.rewardDurationEndsAt'
    );

    // validate the aggregate reward rates and reward durations are zero in the new vault before
    // migrating
    RewardVault.RewardBuckets memory newVaultBuckets = s_rewardVaultVersion2.getRewardBuckets();
    assertEq(newVaultBuckets.operatorBase.emissionRate, 0, 'operatorBase.emissionRate');
    assertEq(
      newVaultBuckets.operatorBase.rewardDurationEndsAt, 0, 'operatorBase.rewardDurationEndsAt'
    );

    assertEq(newVaultBuckets.communityBase.emissionRate, 0, 'communityBase.emissionRate');
    assertEq(
      newVaultBuckets.communityBase.rewardDurationEndsAt, 0, 'communityBase.rewardDurationEndsAt'
    );

    assertEq(newVaultBuckets.operatorDelegated.emissionRate, 0, 'operatorDelegated.emissionRate');
    assertEq(
      newVaultBuckets.operatorDelegated.rewardDurationEndsAt,
      0,
      'operatorDelegated.rewardDurationEndsAt'
    );
  }

  function _validateRewardBucketsAfterMigrate() private {
    RewardVault.RewardBuckets memory newVaultBuckets = s_rewardVaultVersion2.getRewardBuckets();

    // validate the aggregate reward rates and reward durations are the same in both vaults after
    // migrating
    assertEq(
      s_rewardBucketsBeforeMigration.operatorBase.emissionRate,
      newVaultBuckets.operatorBase.emissionRate,
      's_rewardBucketsBeforeMigration.operatorBase.emissionRate'
    );
    assertEq(
      s_rewardBucketsBeforeMigration.operatorBase.rewardDurationEndsAt,
      newVaultBuckets.operatorBase.rewardDurationEndsAt,
      's_rewardBucketsBeforeMigration.operatorBase.rewardDurationEndsAt'
    );

    assertEq(
      s_rewardBucketsBeforeMigration.communityBase.emissionRate,
      newVaultBuckets.communityBase.emissionRate,
      's_rewardBucketsBeforeMigration.communityBase.emissionRate'
    );
    assertEq(
      s_rewardBucketsBeforeMigration.communityBase.rewardDurationEndsAt,
      newVaultBuckets.communityBase.rewardDurationEndsAt,
      's_rewardBucketsBeforeMigration.communityBase.rewardDurationEndsAt'
    );

    assertEq(
      s_rewardBucketsBeforeMigration.operatorDelegated.emissionRate,
      newVaultBuckets.operatorDelegated.emissionRate,
      's_rewardBucketsBeforeMigration.operatorDelegated.emissionRate'
    );
    assertEq(
      s_rewardBucketsBeforeMigration.operatorDelegated.rewardDurationEndsAt,
      newVaultBuckets.operatorDelegated.rewardDurationEndsAt,
      's_rewardBucketsBeforeMigration.operatorDelegated.rewardDurationEndsAt'
    );

    // validate old vaults have ended their reward durations
    RewardVault.RewardBuckets memory oldVaultBuckets = s_rewardVault.getRewardBuckets();
    assertEq(
      oldVaultBuckets.operatorBase.rewardDurationEndsAt,
      s_migratedAtTime,
      'oldVaultBuckets.operatorBase.rewardDurationEndsAt'
    );
    assertEq(
      oldVaultBuckets.communityBase.rewardDurationEndsAt,
      s_migratedAtTime,
      'oldVaultBuckets.communityBase.rewardDurationEndsAt'
    );
    assertEq(
      oldVaultBuckets.operatorDelegated.rewardDurationEndsAt,
      s_migratedAtTime,
      'oldVaultBuckets.operatorDelegated.rewardDurationEndsAt'
    );
  }

  function _validateIsOpenBeforeMigrate() private {
    assertEq(s_rewardVault.isOpen(), true);
    assertEq(s_rewardVaultVersion2.isOpen(), true);
  }

  function _validateIsOpenAfterMigrate() private {
    assertEq(s_rewardVault.isOpen(), false);
    assertEq(s_rewardVaultVersion2.isOpen(), true);
  }
}

contract StakingPoolUpgradeTwoStakerAndAlertsTest is RewardVault_WithStakersAndTimePassed {
  uint256 private constant INTEGRATION_TEST_START_TIME = TEST_START_TIME + 10;

  address internal constant MIGRATED_OPERATOR = OPERATOR_STAKER_ONE;
  address internal constant DOUBLE_STAKER = OPERATOR_STAKER_TWO;

  uint256 internal constant TIME_AFTER_MIGRATION = 28 days;

  RewardVault internal s_rewardVaultVersion2;
  uint256 private s_operatorOneStakerRewardsAtMigrateTime;
  uint256 private s_operatorTwoStakerRewardsAtMigrateTime;

  uint256 internal s_unvestedCommunityBaseRewardsFromVaultOne;
  uint256 internal s_unvestedOperatorBaseRewardsFromVaultOne;
  uint256 internal s_unvestedOperatorDelegatedRewardsFromVaultOne;

  uint256 internal s_migratedAtTime;

  // Let's assume that this staking pool is for a new staker type
  OperatorStakingPool internal s_newOperatorPool;

  uint256 internal s_timeFeedGoesDown;
  RewardVault.RewardBuckets private s_rewardBucketsBeforeMigration;

  function setUp() public override {
    RewardVault_WithStakersAndTimePassed.setUp();

    changePrank(OWNER);

    s_communityStakingPool.setMerkleRoot(bytes32(''));

    // Configure new pool
    s_newOperatorPool = new OperatorStakingPool(
      OperatorStakingPool.ConstructorParams({
        minInitialOperatorCount: MIN_INITIAL_OPERATOR_COUNT,
        baseParams: StakingPoolBase.ConstructorParamsBase({
          LINKAddress: s_LINK,
          initialMaxPoolSize: INITIAL_MAX_OPERATOR_POOL_SIZE,
          initialMaxPrincipalPerStaker: INITIAL_MAX_OPERATOR_STAKE,
          minPrincipalPerStaker: INITIAL_MIN_OPERATOR_STAKE,
          initialUnbondingPeriod: INITIAL_UNBONDING_PERIOD,
          maxUnbondingPeriod: MAX_UNBONDING_PERIOD,
          initialClaimPeriod: INITIAL_CLAIM_PERIOD,
          minClaimPeriod: MIN_CLAIM_PERIOD,
          maxClaimPeriod: MAX_CLAIM_PERIOD,
          adminRoleTransferDelay: ADMIN_ROLE_TRANSFER_DELAY
        })
      })
    );

    // Configure new reward vault
    s_rewardVaultVersion2 = new RewardVault(
        RewardVault.ConstructorParams({
        linkToken: s_LINK,
        communityStakingPool: s_communityStakingPool,
        operatorStakingPool: s_newOperatorPool, // Let's assume the new staker type pool replaces the operator staking pool
        delegationRateDenominator: DELEGATION_RATE_DENOMINATOR,
        initialMultiplierDuration: INITIAL_MULTIPLIER_DURATION,
        adminRoleTransferDelay: ADMIN_ROLE_TRANSFER_DELAY
      })
    );
    s_rewardVaultVersion2.grantRole(
      s_rewardVaultVersion2.REWARDER_ROLE(), address(s_newOperatorPool)
    );
    s_rewardVaultVersion2.grantRole(
      s_rewardVaultVersion2.REWARDER_ROLE(), address(s_communityStakingPool)
    );

    // Set migration target
    s_rewardVault.setMigrationTarget(address(s_rewardVaultVersion2));
    s_rewardVaultVersion2.setMigrationSource(address(s_rewardVault));

    changePrank(OWNER);

    // Allow stakers in new operator pool to raise alert
    s_pfAlertsController.setOperatorStakingPool(s_newOperatorPool);
    s_newOperatorPool.addSlasher(
      address(s_pfAlertsController),
      ISlashable.SlasherConfig({refillRate: SLASH_REFILL_RATE, slashCapacity: SLASH_MAX_AMOUNT})
    );

    (
      s_unvestedCommunityBaseRewardsFromVaultOne,
      s_unvestedOperatorBaseRewardsFromVaultOne,
      s_unvestedOperatorDelegatedRewardsFromVaultOne
    ) = s_rewardVault.getUnvestedRewards();

    s_operatorOneStakerRewardsAtMigrateTime = s_rewardVault.getReward(OPERATOR_STAKER_ONE);
    s_operatorTwoStakerRewardsAtMigrateTime = s_rewardVault.getReward(DOUBLE_STAKER);

    // In practice the addresses that the contracts point to will be updated
    // at the same time in a batched transaction.
    s_communityStakingPool.setRewardVault(s_rewardVaultVersion2);
    s_newOperatorPool.setRewardVault(s_rewardVaultVersion2);
    s_operatorStakingPool.setMigrationTarget(address(s_newOperatorPool));

    address[] memory operators = _getDefaultOperators();
    s_newOperatorPool.addOperators(operators);

    _saveRewardBuckets();
    _validateRewardBucketsBeforeMigrate();
    _validateIsOpenBeforeMigrate();

    bytes memory data;
    s_rewardVault.migrate(data);
    s_migratedAtTime = block.timestamp;

    // Open new pool
    s_newOperatorPool.setMigrationProxy(address(s_operatorStakingPool));
    s_newOperatorPool.open();

    // Close old pool
    s_operatorStakingPool.close();

    changePrank(MIGRATED_OPERATOR);
    s_operatorStakingPool.migrate(data);

    changePrank(DOUBLE_STAKER);
    s_LINK.transferAndCall(address(s_newOperatorPool), OPERATOR_MIN_PRINCIPAL, abi.encode(''));
    skip(TIME_AFTER_MIGRATION);
    _validateIsOpenAfterMigrate();
  }

  function test_OperatorsWhoHaveNotMigratedCanAlert() public {
    // Make feed go down
    s_timeFeedGoesDown = block.timestamp + 14 days;
    vm.warp(s_timeFeedGoesDown);
    vm.mockCall(
      address(FEED),
      abi.encodeWithSelector(AggregatorV3Interface.latestRoundData.selector),
      abi.encode(ROUND_ID, int256(0), uint128(0), uint128(s_timeFeedGoesDown), uint80(0))
    );
    vm.warp(s_timeFeedGoesDown + PRIORITY_PERIOD_THRESHOLD_SECONDS + 1);
    assertEq(s_pfAlertsController.canAlert(DOUBLE_STAKER, address(FEED)), true);
  }

  function test_OperatorsWhoHaveMigratedCanAlert() public {
    // Make feed go down
    s_timeFeedGoesDown = block.timestamp + 14 days;
    vm.warp(s_timeFeedGoesDown);
    vm.mockCall(
      address(FEED),
      abi.encodeWithSelector(AggregatorV3Interface.latestRoundData.selector),
      abi.encode(ROUND_ID, int256(0), uint128(0), uint128(s_timeFeedGoesDown), uint80(0))
    );
    vm.warp(s_timeFeedGoesDown + PRIORITY_PERIOD_THRESHOLD_SECONDS + 1);
    assertEq(s_pfAlertsController.canAlert(MIGRATED_OPERATOR, address(FEED)), true);
  }

  // A staker who has migrated will not be able to stake in the old pool
  // as we close it as part of the upgrade sequence
  function test_OperatorWhoHasMigratedCannotStakeInOldPool() public {
    changePrank(MIGRATED_OPERATOR);
    vm.expectRevert(IStakingOwner.PoolNotOpen.selector);
    s_LINK.transferAndCall(address(s_operatorStakingPool), OPERATOR_MIN_PRINCIPAL, abi.encode(''));
  }

  function test_OperatorWhoStakesInBothPoolsEarnsCorrectRewardsFromOldVault() public {
    skip(28 days); // Let time go on
    RewardVault.RewardBuckets memory rewardBuckets = s_rewardVault.getRewardBuckets();

    uint256 vestedOperatorBaseRewards =
      _calculateBucketVestedRewards(rewardBuckets.operatorBase, s_stakedAtTime, block.timestamp);
    uint256 vestedOperatorDelegatedRewards = _calculateBucketVestedRewards(
      rewardBuckets.operatorDelegated, s_stakedAtTime, block.timestamp
    );
    uint256 multiplier =
      _calculateStakerMultiplier(s_stakedAtTime, block.timestamp, INITIAL_MULTIPLIER_DURATION);
    uint256 expectedBaseRewards = _calculateStakerExpectedReward(
      OPERATOR_MIN_PRINCIPAL, OPERATOR_MIN_PRINCIPAL * 4, vestedOperatorBaseRewards
    ) * multiplier / FixedPointMathLib.WAD;
    uint256 expectedDelegatedRewards = _calculateStakerExpectedReward(
      OPERATOR_MIN_PRINCIPAL, OPERATOR_MIN_PRINCIPAL * 4, vestedOperatorDelegatedRewards
    );
    assertEq(s_rewardVault.getReward(DOUBLE_STAKER), expectedBaseRewards + expectedDelegatedRewards);
  }

  function test_OperatorWhoStakesInBothPoolsEarnsCorrectRewardsFromNewVault() public {
    skip(28 days); // Let time go on
    RewardVault.RewardBuckets memory rewardBuckets = s_rewardVaultVersion2.getRewardBuckets();

    // OperatorStakerOne migrated OPERATOR_MIN_PRINCIPAL to the pool
    // OperatorStakerTwo migrated OPERATOR_MIN_PRINCIPAL to the pool
    // This means that the total staked LINK amount in the pool is 2 * OPERATOR_MIN_PRINCIPAL
    uint256 totalPoolPrincipal = OPERATOR_MIN_PRINCIPAL * 2;
    uint256 stakerPrincipal = OPERATOR_MIN_PRINCIPAL;
    uint256 vestedOperatorBaseRewards =
      _calculateBucketVestedRewards(rewardBuckets.operatorBase, s_migratedAtTime, block.timestamp);
    uint256 vestedOperatorDelegatedRewards = _calculateBucketVestedRewards(
      rewardBuckets.operatorDelegated, s_migratedAtTime, block.timestamp
    );
    uint256 multiplier =
      _calculateStakerMultiplier(s_migratedAtTime, block.timestamp, INITIAL_MULTIPLIER_DURATION);
    uint256 expectedBaseRewards = _calculateStakerExpectedReward(
      stakerPrincipal, totalPoolPrincipal, vestedOperatorBaseRewards
    ) * multiplier / FixedPointMathLib.WAD;
    uint256 expectedDelegatedRewards = _calculateStakerExpectedReward(
      stakerPrincipal, totalPoolPrincipal, vestedOperatorDelegatedRewards
    );
    assertEq(
      s_rewardVaultVersion2.getReward(DOUBLE_STAKER), expectedBaseRewards + expectedDelegatedRewards
    );
  }

  function _validateRewardBucketsBeforeMigrate() private {
    // validate the aggregate reward rates and reward durations are greater than zero in the old
    // vault
    // before migrating

    // calculate pool reward amount
    uint256 communityCommunityMaxSize = s_communityStakingPool.getMaxPoolSize();
    uint256 operatorPoolMaxSize = s_operatorStakingPool.getMaxPoolSize();
    uint256 totalPoolMaxSize = communityCommunityMaxSize + operatorPoolMaxSize;
    uint256 communityCommunityReward = REWARD_AMOUNT * communityCommunityMaxSize / totalPoolMaxSize;
    uint256 operatorPoolReward = REWARD_AMOUNT * operatorPoolMaxSize / totalPoolMaxSize;

    // calculate the expected pool rates
    uint256 expectedOperatorRate = EMISSION_RATE * operatorPoolReward / REWARD_AMOUNT;
    uint256 expectedCommunityRate = EMISSION_RATE * communityCommunityReward / REWARD_AMOUNT;
    uint256 expectedDelegationRate = expectedCommunityRate / DELEGATION_RATE_DENOMINATOR;
    expectedCommunityRate -= expectedDelegationRate;

    // start time is TEST_START_TIME + 10 due to the scenario setup
    uint256 duration = REWARD_AMOUNT / EMISSION_RATE;

    // validate the aggregate reward rates and reward durations before migrating
    assertEq(
      s_rewardBucketsBeforeMigration.operatorBase.emissionRate,
      expectedOperatorRate,
      's_rewardBucketsBeforeMigration.operatorBase.emissionRate'
    );
    assertEq(
      s_rewardBucketsBeforeMigration.operatorBase.rewardDurationEndsAt,
      INTEGRATION_TEST_START_TIME + duration,
      's_rewardBucketsBeforeMigration.operatorBase.rewardDurationEndsAt'
    );

    assertEq(
      s_rewardBucketsBeforeMigration.communityBase.emissionRate,
      expectedCommunityRate,
      's_rewardBucketsBeforeMigration.communityBase.emissionRate'
    );
    assertEq(
      s_rewardBucketsBeforeMigration.communityBase.rewardDurationEndsAt,
      INTEGRATION_TEST_START_TIME + duration,
      's_rewardBucketsBeforeMigration.communityBase.rewardDurationEndsAt'
    );

    assertEq(
      s_rewardBucketsBeforeMigration.operatorDelegated.emissionRate,
      expectedDelegationRate,
      's_rewardBucketsBeforeMigration.operatorDelegated.emissionRate'
    );
    assertEq(
      s_rewardBucketsBeforeMigration.operatorDelegated.rewardDurationEndsAt,
      INTEGRATION_TEST_START_TIME + duration,
      's_rewardBucketsBeforeMigration.operatorDelegated.rewardDurationEndsAt'
    );

    // validate the aggregate reward rates and reward durations are zero in the new vault before
    // migrating
    RewardVault.RewardBuckets memory newVaultBuckets = s_rewardVaultVersion2.getRewardBuckets();
    assertEq(newVaultBuckets.operatorBase.emissionRate, 0, 'operatorBase.emissionRate');
    assertEq(
      newVaultBuckets.operatorBase.rewardDurationEndsAt, 0, 'operatorBase.rewardDurationEndsAt'
    );

    assertEq(newVaultBuckets.communityBase.emissionRate, 0, 'communityBase.emissionRate');
    assertEq(
      newVaultBuckets.communityBase.rewardDurationEndsAt, 0, 'communityBase.rewardDurationEndsAt'
    );

    assertEq(newVaultBuckets.operatorDelegated.emissionRate, 0, 'operatorDelegated.emissionRate');
    assertEq(
      newVaultBuckets.operatorDelegated.rewardDurationEndsAt,
      0,
      'operatorDelegated.rewardDurationEndsAt'
    );
  }

  function _validateRewardBucketsAfterMigrate() private {
    RewardVault.RewardBuckets memory newVaultBuckets = s_rewardVaultVersion2.getRewardBuckets();

    // validate the aggregate reward rates and reward durations are the same in both vaults after
    // migrating
    assertEq(
      s_rewardBucketsBeforeMigration.operatorBase.emissionRate,
      newVaultBuckets.operatorBase.emissionRate
    );
    assertEq(
      s_rewardBucketsBeforeMigration.operatorBase.rewardDurationEndsAt,
      newVaultBuckets.operatorBase.rewardDurationEndsAt
    );

    assertEq(
      s_rewardBucketsBeforeMigration.communityBase.emissionRate,
      newVaultBuckets.communityBase.emissionRate
    );
    assertEq(
      s_rewardBucketsBeforeMigration.communityBase.rewardDurationEndsAt,
      newVaultBuckets.communityBase.rewardDurationEndsAt
    );

    assertEq(
      s_rewardBucketsBeforeMigration.operatorDelegated.emissionRate,
      newVaultBuckets.operatorDelegated.emissionRate
    );
    assertEq(
      s_rewardBucketsBeforeMigration.operatorDelegated.rewardDurationEndsAt,
      newVaultBuckets.operatorDelegated.rewardDurationEndsAt
    );

    // validate old vaults have ended their reward durations
    RewardVault.RewardBuckets memory oldVaultBuckets = s_rewardVault.getRewardBuckets();
    assertEq(oldVaultBuckets.operatorBase.rewardDurationEndsAt, s_migratedAtTime);
    assertEq(oldVaultBuckets.communityBase.rewardDurationEndsAt, s_migratedAtTime);
    assertEq(oldVaultBuckets.operatorDelegated.rewardDurationEndsAt, s_migratedAtTime);
  }

  function _saveRewardBuckets() private {
    s_rewardBucketsBeforeMigration = s_rewardVault.getRewardBuckets();
  }

  function _validateIsOpenBeforeMigrate() private {
    assertEq(s_rewardVault.isOpen(), true);
    assertEq(s_rewardVaultVersion2.isOpen(), true);
  }

  function _validateIsOpenAfterMigrate() private {
    assertEq(s_rewardVault.isOpen(), false);
    assertEq(s_rewardVaultVersion2.isOpen(), true);
  }
}
