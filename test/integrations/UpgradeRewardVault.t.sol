// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {IAccessControlDefaultAdminRules} from
  '@openzeppelin/contracts/access/IAccessControlDefaultAdminRules.sol';
import {FixedPointMathLib} from '@solmate/utils/FixedPointMathLib.sol';
import {BaseTestTimelocked} from '../BaseTestTimelocked.t.sol';
import {RewardVault} from '../../src/rewards/RewardVault.sol';
import {StakingPoolBase} from '../../src/pools/StakingPoolBase.sol';
import {Timelock} from '../../src/timelock/Timelock.sol';
import {IMigratable} from '../../src/interfaces/IMigratable.sol';

contract UpgradeRewardVault is BaseTestTimelocked {
  uint256 private constant INTEGRATION_TEST_START_TIME = TEST_START_TIME + 10;
  uint256 private constant TIME_AFTER_MIGRATION = 10 days;
  uint256 private s_migratedAtTime;
  uint256 private s_multiplierCommunityStakerOne;
  uint256 private s_multiplierCommunityStakerTwo;
  uint256 private s_multiplierOperatorStakerOne;
  uint256 private s_multiplierOperatorStakerTwo;
  RewardVault.RewardBuckets private s_rewardBucketsBeforeMigration;
  RewardVault private s_rewardVaultVersion2;
  Timelock.Call[] private s_timelockUpgradeCalls;

  function setUp() public override {
    BaseTestTimelocked.setUp();

    _deployNewRewardVault();

    // save a copy of reward bucket values before migration
    _saveRewardBuckets();
  }

  function test_UpgradeRewardVault() public {
    // step 1: schedule upgrade
    _scheduleRewardVaultUpgrade();
    _validateUpgradeIsTimelocked();

    // step 2: wait for time lock to end
    vm.warp(block.timestamp + DELAY_ONE_MONTH);
    // ensure some stakers have full multiplier, some have no multiplier, and some have partial
    _setUpStakerMultipliers();
    _validateRewardBucketsBeforeMigrate();
    _validateIsOpenBeforeMigrate();

    // step 3: execute the upgrade
    _executeRewardVaultUpgrade();

    _validateRewardBucketsAfterMigrate();
    _validateMultipliersAfterMigrate();
    _validateRewardsEarnedInOldAndNewVaults();
    _validateIsOpenAfterMigrate();
  }

  function _deployNewRewardVault() private {
    changePrank(OWNER);
    s_rewardVaultVersion2 = new RewardVault(
      RewardVault.ConstructorParams({
        linkToken: s_LINK,
        communityStakingPool: s_communityStakingPool,
        operatorStakingPool: s_operatorStakingPool,
        delegationRateDenominator: DELEGATION_RATE_DENOMINATOR,
        initialMultiplierDuration: INITIAL_MULTIPLIER_DURATION,
        adminRoleTransferDelay: ADMIN_ROLE_TRANSFER_DELAY
      })
    );
    s_rewardVaultVersion2.setMigrationSource(address(s_rewardVault));
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
  }

  function _saveRewardBuckets() private {
    s_rewardBucketsBeforeMigration = s_rewardVault.getRewardBuckets();
  }

  function _scheduleRewardVaultUpgrade() private {
    changePrank(PROPOSER_ONE);
    // schedule reward vault upgrade on all staking pools
    s_timelockUpgradeCalls.push(
      _timelockCall(
        address(s_communityStakingPool),
        abi.encodeWithSelector(
          StakingPoolBase.setRewardVault.selector, address(s_rewardVaultVersion2)
        )
      )
    );
    s_timelockUpgradeCalls.push(
      _timelockCall(
        address(s_operatorStakingPool),
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

    s_stakingTimelock.scheduleBatch(
      s_timelockUpgradeCalls, NO_PREDECESSOR, EMPTY_SALT, DELAY_ONE_MONTH
    );
  }

  function _validateUpgradeIsTimelocked() private {
    changePrank(EXECUTOR_ONE);
    vm.expectRevert('Timelock: operation is not ready');
    s_stakingTimelock.executeBatch(s_timelockUpgradeCalls, NO_PREDECESSOR, EMPTY_SALT);
  }

  function _executeRewardVaultUpgrade() private {
    changePrank(EXECUTOR_ONE);
    s_stakingTimelock.executeBatch(s_timelockUpgradeCalls, NO_PREDECESSOR, EMPTY_SALT);
    s_migratedAtTime = block.timestamp;
  }

  function _setUpStakerMultipliers() private {
    // ensure some stakers have full multiplier, some have no multiplier, and some have partial

    // operator staker one will unbond, unstake, and stake again with time passing to get a partial
    // multiplier
    changePrank(OPERATOR_STAKER_ONE);
    s_operatorStakingPool.unbond();

    skip(UNBONDING_PERIOD);

    changePrank(OPERATOR_STAKER_ONE);
    s_operatorStakingPool.unstake(
      s_operatorStakingPool.getStakerPrincipal(OPERATOR_STAKER_ONE), true
    );

    skip(INITIAL_MULTIPLIER_DURATION);

    changePrank(OPERATOR_STAKER_ONE);
    s_LINK.transferAndCall(address(s_operatorStakingPool), OPERATOR_MIN_PRINCIPAL, '');

    // community staker one will unbond, unstake, and stake again without time passing to reset
    // multiplier to zero
    changePrank(COMMUNITY_STAKER_ONE);
    s_communityStakingPool.unbond();

    // unbonding period is shorter than multiplier duration which will cause a partial multiplier
    skip(UNBONDING_PERIOD);

    changePrank(COMMUNITY_STAKER_ONE);
    s_communityStakingPool.unstake(
      s_communityStakingPool.getStakerPrincipal(COMMUNITY_STAKER_ONE), true
    );
    s_LINK.transferAndCall(
      address(s_communityStakingPool),
      COMMUNITY_MIN_PRINCIPAL,
      abi.encode(s_communityStakerOneProof)
    );

    s_multiplierCommunityStakerOne = s_rewardVault.getMultiplier(COMMUNITY_STAKER_ONE);
    s_multiplierCommunityStakerTwo = s_rewardVault.getMultiplier(COMMUNITY_STAKER_TWO);
    s_multiplierOperatorStakerOne = s_rewardVault.getMultiplier(OPERATOR_STAKER_ONE);
    s_multiplierOperatorStakerTwo = s_rewardVault.getMultiplier(OPERATOR_STAKER_TWO);

    assertEq(s_multiplierCommunityStakerOne, 0); // no multiplier
    assertEq(s_multiplierCommunityStakerTwo, MAX_MULTIPLIER); // full multiplier
    assertEq(
      s_multiplierOperatorStakerOne,
      _calculateStakerMultiplier(
        block.timestamp - UNBONDING_PERIOD, block.timestamp, INITIAL_MULTIPLIER_DURATION
      )
    );
    assertLt(s_multiplierOperatorStakerOne, MAX_MULTIPLIER); // partial multiplier
    assertEq(s_multiplierOperatorStakerTwo, MAX_MULTIPLIER); // full multiplier
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
    assertEq(s_rewardBucketsBeforeMigration.operatorBase.emissionRate, expectedOperatorRate);
    assertEq(
      s_rewardBucketsBeforeMigration.operatorBase.rewardDurationEndsAt,
      INTEGRATION_TEST_START_TIME + duration
    );

    assertEq(s_rewardBucketsBeforeMigration.communityBase.emissionRate, expectedCommunityRate);
    assertEq(
      s_rewardBucketsBeforeMigration.communityBase.rewardDurationEndsAt,
      INTEGRATION_TEST_START_TIME + duration
    );

    assertEq(s_rewardBucketsBeforeMigration.operatorDelegated.emissionRate, expectedDelegationRate);
    assertEq(
      s_rewardBucketsBeforeMigration.operatorDelegated.rewardDurationEndsAt,
      INTEGRATION_TEST_START_TIME + duration
    );

    // validate the aggregate reward rates and reward durations are zero in the new vault before
    // migrating
    RewardVault.RewardBuckets memory newVaultBuckets = s_rewardVaultVersion2.getRewardBuckets();
    assertEq(newVaultBuckets.operatorBase.emissionRate, 0);
    assertEq(newVaultBuckets.operatorBase.rewardDurationEndsAt, 0);

    assertEq(newVaultBuckets.communityBase.emissionRate, 0);
    assertEq(newVaultBuckets.communityBase.rewardDurationEndsAt, 0);

    assertEq(newVaultBuckets.operatorDelegated.emissionRate, 0);
    assertEq(newVaultBuckets.operatorDelegated.rewardDurationEndsAt, 0);
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

  function _validateMultipliersAfterMigrate() private {
    // validate multipliers are the same
    assertEq(
      s_rewardVaultVersion2.getMultiplier(COMMUNITY_STAKER_ONE), s_multiplierCommunityStakerOne
    );
    assertEq(
      s_rewardVaultVersion2.getMultiplier(COMMUNITY_STAKER_TWO), s_multiplierCommunityStakerTwo
    );
    assertEq(
      s_rewardVaultVersion2.getMultiplier(OPERATOR_STAKER_ONE), s_multiplierOperatorStakerOne
    );
    assertEq(
      s_rewardVaultVersion2.getMultiplier(OPERATOR_STAKER_TWO), s_multiplierOperatorStakerTwo
    );
  }

  function _validateRewardsEarnedInOldAndNewVaults() private {
    uint256 rewardVault1CommunityStakerOneBefore = s_rewardVault.getReward(COMMUNITY_STAKER_ONE);
    uint256 rewardVault1CommunityStakerTwoBefore = s_rewardVault.getReward(COMMUNITY_STAKER_TWO);
    uint256 rewardVault1OperatorStakerOneBefore = s_rewardVault.getReward(OPERATOR_STAKER_ONE);
    uint256 rewardVault1OperatorStakerTwoBefore = s_rewardVault.getReward(OPERATOR_STAKER_TWO);

    uint256 rewardVault2CommunityStakerOneBefore =
      s_rewardVaultVersion2.getReward(COMMUNITY_STAKER_ONE);
    uint256 rewardVault2CommunityStakerTwoBefore =
      s_rewardVaultVersion2.getReward(COMMUNITY_STAKER_TWO);
    uint256 rewardVault2OperatorStakerOneBefore =
      s_rewardVaultVersion2.getReward(OPERATOR_STAKER_ONE);
    uint256 rewardVault2OperatorStakerTwoBefore =
      s_rewardVaultVersion2.getReward(OPERATOR_STAKER_TWO);

    skip(TIME_AFTER_MIGRATION);

    // validate the rewards are no longer being earned in the old vault
    assertEq(s_rewardVault.getReward(COMMUNITY_STAKER_ONE), rewardVault1CommunityStakerOneBefore);
    assertEq(s_rewardVault.getReward(COMMUNITY_STAKER_TWO), rewardVault1CommunityStakerTwoBefore);
    // multiplier still growing therefore rewards will be greater
    assertGt(s_rewardVault.getReward(OPERATOR_STAKER_ONE), rewardVault1OperatorStakerOneBefore);
    assertEq(
      s_rewardVault.getReward(OPERATOR_STAKER_ONE),
      _calculateStakerExpectedReward(
        s_operatorStakingPool.getStakerPrincipal(OPERATOR_STAKER_ONE),
        s_operatorStakingPool.getTotalPrincipal(),
        _calculateBucketVestedRewards(
          s_rewardVault.getRewardBuckets().operatorBase,
          block.timestamp - UNBONDING_PERIOD - TIME_AFTER_MIGRATION,
          s_migratedAtTime
        )
      )
        * _calculateStakerMultiplier(
          block.timestamp - UNBONDING_PERIOD - TIME_AFTER_MIGRATION,
          block.timestamp,
          INITIAL_MULTIPLIER_DURATION
        ) / FixedPointMathLib.WAD
        + _calculateStakerExpectedReward(
          s_operatorStakingPool.getStakerPrincipal(OPERATOR_STAKER_ONE),
          s_operatorStakingPool.getTotalPrincipal(),
          _calculateBucketVestedRewards(
            s_rewardVault.getRewardBuckets().operatorDelegated,
            block.timestamp - UNBONDING_PERIOD - TIME_AFTER_MIGRATION,
            s_migratedAtTime
          )
        )
    );
    assertEq(s_rewardVault.getReward(OPERATOR_STAKER_TWO), rewardVault1OperatorStakerTwoBefore);

    // validate the rewards are being earned in the new vault
    assertGt(
      s_rewardVaultVersion2.getReward(COMMUNITY_STAKER_ONE), rewardVault2CommunityStakerOneBefore
    );
    assertEq(
      s_rewardVaultVersion2.getReward(COMMUNITY_STAKER_ONE),
      _calculateStakerExpectedReward(
        s_communityStakingPool.getStakerPrincipal(COMMUNITY_STAKER_ONE),
        s_communityStakingPool.getTotalPrincipal(),
        _calculateBucketVestedRewards(
          s_rewardVaultVersion2.getRewardBuckets().communityBase,
          s_migratedAtTime,
          s_migratedAtTime + TIME_AFTER_MIGRATION
        )
      ) * s_rewardVaultVersion2.getMultiplier(COMMUNITY_STAKER_ONE) / FixedPointMathLib.WAD
    );
    assertGt(
      s_rewardVaultVersion2.getReward(COMMUNITY_STAKER_TWO), rewardVault2CommunityStakerTwoBefore
    );
    assertEq(
      s_rewardVaultVersion2.getReward(COMMUNITY_STAKER_TWO),
      _calculateStakerExpectedReward(
        s_communityStakingPool.getStakerPrincipal(COMMUNITY_STAKER_TWO),
        s_communityStakingPool.getTotalPrincipal(),
        _calculateBucketVestedRewards(
          s_rewardVaultVersion2.getRewardBuckets().communityBase,
          s_migratedAtTime,
          s_migratedAtTime + TIME_AFTER_MIGRATION
        )
      ) * s_rewardVaultVersion2.getMultiplier(COMMUNITY_STAKER_TWO) / FixedPointMathLib.WAD
    );
    assertGt(
      s_rewardVaultVersion2.getReward(OPERATOR_STAKER_ONE), rewardVault2OperatorStakerOneBefore
    );
    assertEq(
      s_rewardVaultVersion2.getReward(OPERATOR_STAKER_ONE),
      _calculateStakerExpectedReward(
        s_operatorStakingPool.getStakerPrincipal(OPERATOR_STAKER_ONE),
        s_operatorStakingPool.getTotalPrincipal(),
        _calculateBucketVestedRewards(
          s_rewardVaultVersion2.getRewardBuckets().operatorBase,
          s_migratedAtTime,
          s_migratedAtTime + TIME_AFTER_MIGRATION
        )
      ) * s_rewardVaultVersion2.getMultiplier(OPERATOR_STAKER_ONE) / FixedPointMathLib.WAD
        + _calculateStakerExpectedReward(
          s_operatorStakingPool.getStakerPrincipal(OPERATOR_STAKER_ONE),
          s_operatorStakingPool.getTotalPrincipal(),
          _calculateBucketVestedRewards(
            s_rewardVaultVersion2.getRewardBuckets().operatorDelegated,
            s_migratedAtTime,
            s_migratedAtTime + TIME_AFTER_MIGRATION
          )
        )
    );
    assertGt(
      s_rewardVaultVersion2.getReward(OPERATOR_STAKER_TWO), rewardVault2OperatorStakerTwoBefore
    );
    assertEq(
      s_rewardVaultVersion2.getReward(OPERATOR_STAKER_TWO),
      _calculateStakerExpectedReward(
        s_operatorStakingPool.getStakerPrincipal(OPERATOR_STAKER_TWO),
        s_operatorStakingPool.getTotalPrincipal(),
        _calculateBucketVestedRewards(
          s_rewardVaultVersion2.getRewardBuckets().operatorBase,
          s_migratedAtTime,
          s_migratedAtTime + TIME_AFTER_MIGRATION
        )
      ) * s_rewardVaultVersion2.getMultiplier(OPERATOR_STAKER_TWO) / FixedPointMathLib.WAD
        + _calculateStakerExpectedReward(
          s_operatorStakingPool.getStakerPrincipal(OPERATOR_STAKER_TWO),
          s_operatorStakingPool.getTotalPrincipal(),
          _calculateBucketVestedRewards(
            s_rewardVaultVersion2.getRewardBuckets().operatorDelegated,
            s_migratedAtTime,
            s_migratedAtTime + TIME_AFTER_MIGRATION
          )
        )
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
