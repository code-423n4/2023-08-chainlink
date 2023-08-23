// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Math} from '@openzeppelin/contracts/utils/math/Math.sol';
import {BaseTest} from '../BaseTest.t.sol';
import {CommunityStakingPool} from '../../src/pools/CommunityStakingPool.sol';
import {ISlashable} from '../../src/interfaces/ISlashable.sol';
import {OperatorStakingPool} from '../../src/pools/OperatorStakingPool.sol';
import {PriceFeedAlertsController} from '../../src/alerts/PriceFeedAlertsController.sol';
import {RewardVault} from '../../src/rewards/RewardVault.sol';
import {StakingPool_StakingLimitsUnset} from './StakingPoolScenarios.t.sol';

abstract contract RewardVault_DelegationDenominatorIsZero is BaseTest {
  function setUp() public virtual override {
    BaseTest.setUp();

    changePrank(OWNER);
    s_rewardVault = new RewardVault(
      RewardVault.ConstructorParams({
        linkToken: s_LINK,
        communityStakingPool: s_communityStakingPool,
        operatorStakingPool: s_operatorStakingPool,
        delegationRateDenominator: 0,
        initialMultiplierDuration: INITIAL_MULTIPLIER_DURATION,
        adminRoleTransferDelay: ADMIN_ROLE_TRANSFER_DELAY
      })
    );
    changePrank(REWARDER);
    s_LINK.approve(address(s_rewardVault), type(uint256).max);

    changePrank(OWNER);
    s_rewardVault.grantRole(s_rewardVault.REWARDER_ROLE(), REWARDER);
    s_communityStakingPool.setRewardVault(s_rewardVault);
    s_operatorStakingPool.setRewardVault(s_rewardVault);
  }

  // This is needed so that "forge coverage" will ignore this contract
  function test() public virtual override {}
}

abstract contract RewardVault_WhenTimeDidNotPass is BaseTest {
  PriceFeedAlertsController internal s_pfAlertsController;
  uint256 rewardAddedAt;

  function setUp() public virtual override {
    BaseTest.setUp();

    // Make sure block.timestamp is not 0
    vm.warp(block.timestamp + 10);

    changePrank(OWNER);
    s_operatorStakingPool.addOperators(_getDefaultOperators());
    s_operatorStakingPool.open();
    s_communityStakingPool.open();
    s_rewardVault.grantRole(s_rewardVault.REWARDER_ROLE(), REWARDER);

    PriceFeedAlertsController.ConstructorFeedConfigParams[] memory configs =
      new PriceFeedAlertsController.ConstructorFeedConfigParams[](1);
    configs[0] = PriceFeedAlertsController.ConstructorFeedConfigParams({
      feed: address(FEED),
      priorityPeriodThreshold: PRIORITY_PERIOD_THRESHOLD_SECONDS,
      regularPeriodThreshold: REGULAR_PERIOD_THRESHOLD_SECONDS,
      slashableAmount: FEED_SLASHABLE_AMOUNT,
      alerterRewardAmount: ALERTER_REWARD_AMOUNT,
      slashableOperators: _getDefaultOperators()
    });
    s_pfAlertsController = new PriceFeedAlertsController(
      PriceFeedAlertsController.ConstructorParams({
        communityStakingPool: s_communityStakingPool,
        operatorStakingPool: s_operatorStakingPool,
        feedConfigs: configs,
        adminRoleTransferDelay: ADMIN_ROLE_TRANSFER_DELAY
      })
    );
    s_operatorStakingPool.addSlasher(
      address(s_pfAlertsController),
      ISlashable.SlasherConfig({refillRate: SLASH_REFILL_RATE, slashCapacity: SLASH_MAX_AMOUNT})
    );

    changePrank(REWARDER);
    s_rewardVault.addReward(address(0), REWARD_AMOUNT, EMISSION_RATE);
    rewardAddedAt = block.timestamp;
  }

  function _getSlashableOperators() internal pure returns (address[] memory) {
    address[] memory slashableOperators = new address[](2);
    slashableOperators[0] = OPERATOR_STAKER_ONE;
    slashableOperators[1] = OPERATOR_STAKER_TWO;
    return slashableOperators;
  }

  // This is needed so that "forge coverage" will ignore this contract
  function test() public virtual override {}
}

abstract contract RewardVault_WithoutStakersAndTimePassed is RewardVault_WhenTimeDidNotPass {
  function setUp() public virtual override {
    RewardVault_WhenTimeDidNotPass.setUp();

    vm.warp(block.timestamp + 14 days);
  }

  // This is needed so that "forge coverage" will ignore this contract
  function test() public virtual override {}
}

abstract contract RewardVault_WithStakersAndTimeDidNotPass is RewardVault_WhenTimeDidNotPass {
  uint256 internal constant TIME_AFTER_STAKE = 14 days;

  function setUp() public virtual override {
    RewardVault_WhenTimeDidNotPass.setUp();

    s_stakedAtTime = block.timestamp;
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

    // accrue rewards
    skip(TIME_AFTER_STAKE);

    // subsequent calls will be called with no time passed after this
    changePrank(address(s_communityStakingPool));
    s_rewardVault.updateReward(address(0), 0);
  }

  // This is needed so that "forge coverage" will ignore this contract
  function test() public virtual override {}
}

abstract contract RewardVault_WithStakersAndTimePassed is RewardVault_WithStakersAndTimeDidNotPass {
  uint256 internal constant TIME_AFTER_REWARD_UPDATED = 14 days;

  function setUp() public virtual override {
    RewardVault_WithStakersAndTimeDidNotPass.setUp();
    skip(TIME_AFTER_REWARD_UPDATED);
  }

  // This is needed so that "forge coverage" will ignore this contract
  function test() public virtual override {}
}

abstract contract RewardVault_WithStakersAndMultiplierMaxReached is
  RewardVault_WithStakersAndTimeDidNotPass
{
  function setUp() public virtual override {
    RewardVault_WithStakersAndTimeDidNotPass.setUp();

    vm.warp(block.timestamp + INITIAL_MULTIPLIER_DURATION);
  }

  // This is needed so that "forge coverage" will ignore this contract
  function test() public virtual override {}
}

abstract contract RewardVault_WithStakersAndTimePassedAndPoolsUpdated is
  RewardVault_WithStakersAndTimePassed
{
  function setUp() public virtual override {
    RewardVault_WithStakersAndTimePassed.setUp();

    s_rewardVault.updateReward(address(0), 0);
  }

  // This is needed so that "forge coverage" will ignore this contract
  function test() public virtual override {}
}

abstract contract RewardVault_InClaimPeriod is RewardVault_WithStakersAndTimePassed {
  function setUp() public virtual override {
    RewardVault_WithStakersAndTimePassed.setUp();

    changePrank(OPERATOR_STAKER_ONE);
    s_operatorStakingPool.unbond();

    changePrank(OPERATOR_STAKER_TWO);
    s_operatorStakingPool.unbond();

    changePrank(COMMUNITY_STAKER_ONE);
    s_communityStakingPool.unbond();

    changePrank(COMMUNITY_STAKER_TWO);
    s_communityStakingPool.unbond();

    vm.warp(block.timestamp + UNBONDING_PERIOD);
  }

  // This is needed so that "forge coverage" will ignore this contract
  function test() public virtual override {}
}

abstract contract RewardVault_AfterUnstake is RewardVault_InClaimPeriod {
  function setUp() public virtual override {
    RewardVault_InClaimPeriod.setUp();

    changePrank(OPERATOR_STAKER_ONE);
    s_operatorStakingPool.unstake(OPERATOR_MIN_PRINCIPAL, false);

    changePrank(OPERATOR_STAKER_TWO);
    s_operatorStakingPool.unstake(3 * OPERATOR_MIN_PRINCIPAL, false);

    changePrank(COMMUNITY_STAKER_ONE);
    s_communityStakingPool.unstake(COMMUNITY_MIN_PRINCIPAL, false);

    changePrank(COMMUNITY_STAKER_TWO);
    s_communityStakingPool.unstake(3 * COMMUNITY_MIN_PRINCIPAL, false);
  }

  function test() public virtual override {}
}

abstract contract RewardVault_ConfigurablePoolSizes_DelegationDenominatorNotZero is
  StakingPool_StakingLimitsUnset
{
  function setUp() public virtual override {
    StakingPool_StakingLimitsUnset.setUp();

    s_rewardVault = new RewardVault(
      RewardVault.ConstructorParams({
        linkToken: s_LINK,
        communityStakingPool: s_communityStakingPool,
        operatorStakingPool: s_operatorStakingPool,
        delegationRateDenominator: DELEGATION_RATE_DENOMINATOR,
        initialMultiplierDuration: INITIAL_MULTIPLIER_DURATION,
        adminRoleTransferDelay: ADMIN_ROLE_TRANSFER_DELAY
      })
    );
    changePrank(REWARDER);
    s_LINK.approve(address(s_rewardVault), type(uint256).max);

    changePrank(OWNER);
    s_rewardVault.grantRole(s_rewardVault.REWARDER_ROLE(), REWARDER);

    s_communityStakingPool.setRewardVault(s_rewardVault);
    s_operatorStakingPool.setRewardVault(s_rewardVault);

    s_operatorStakingPool.open();
    s_communityStakingPool.open();
  }

  // This is needed so that "forge coverage" will ignore this contract
  function test() public virtual override {}
}

abstract contract RewardVault_ConfigurablePoolSizes_DelegationDenominatorIsZero is
  StakingPool_StakingLimitsUnset
{
  function setUp() public virtual override {
    StakingPool_StakingLimitsUnset.setUp();

    s_rewardVault = new RewardVault(
      RewardVault.ConstructorParams({
        linkToken: s_LINK,
        communityStakingPool: s_communityStakingPool,
        operatorStakingPool: s_operatorStakingPool,
        delegationRateDenominator: 0,
        initialMultiplierDuration: INITIAL_MULTIPLIER_DURATION,
        adminRoleTransferDelay: ADMIN_ROLE_TRANSFER_DELAY
      })
    );
    changePrank(REWARDER);
    s_LINK.approve(address(s_rewardVault), type(uint256).max);

    changePrank(OWNER);
    s_rewardVault.grantRole(s_rewardVault.REWARDER_ROLE(), REWARDER);

    s_communityStakingPool.setRewardVault(s_rewardVault);
    s_operatorStakingPool.setRewardVault(s_rewardVault);

    s_operatorStakingPool.open();
    s_communityStakingPool.open();
  }
  // This is needed so that "forge coverage" will ignore this contract

  function test() public virtual override {}
}

abstract contract RewardVault_WhenVaultClosed is RewardVault_WithStakersAndTimePassed {
  function setUp() public override {
    RewardVault_WithStakersAndTimePassed.setUp();

    changePrank(OWNER);
    s_rewardVault.close();
  }

  // This is needed so that "forge coverage" will ignore this contract
  function test() public virtual override {}
}

abstract contract RewardVault_WithUpgradedVaultDeployedButNotMigrated is
  RewardVault_WithStakersAndTimePassed
{
  RewardVault internal s_rewardVaultVersion2;

  function setUp() public virtual override {
    RewardVault_WithStakersAndTimePassed.setUp();
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
  }

  function test() public virtual override {}
}

abstract contract RewardVault_WithUpgradedVaultDeployedAndMigrated is
  RewardVault_WithUpgradedVaultDeployedButNotMigrated
{
  uint256 internal constant TIME_AFTER_MIGRATION = 30 days;
  uint256 internal s_migratedAtTime;
  uint256 internal s_unvestedCommunityBaseRewards;

  function setUp() public virtual override {
    RewardVault_WithUpgradedVaultDeployedButNotMigrated.setUp();

    changePrank(OWNER);
    s_rewardVault.setMigrationTarget(address(s_rewardVaultVersion2));

    s_rewardVault.migrate(bytes(''));
    s_communityStakingPool.setRewardVault(s_rewardVaultVersion2);
    s_operatorStakingPool.setRewardVault(s_rewardVaultVersion2);
    s_migratedAtTime = block.timestamp;

    skip(TIME_AFTER_MIGRATION);
  }

  function test() public virtual override {}
}

abstract contract RewardVault_WithUpgradedVaultDeployedAndMigratedMultipleTimes is
  RewardVault_WithUpgradedVaultDeployedAndMigrated
{
  RewardVault internal s_rewardVaultVersion3;
  uint256 internal s_secondMigratedAtTime;

  function setUp() public virtual override {
    RewardVault_WithUpgradedVaultDeployedAndMigrated.setUp();

    s_rewardVaultVersion3 = new RewardVault(
      RewardVault.ConstructorParams({
        linkToken: s_LINK,
        communityStakingPool: s_communityStakingPool,
        operatorStakingPool: s_operatorStakingPool,
        delegationRateDenominator: DELEGATION_RATE_DENOMINATOR,
        initialMultiplierDuration: INITIAL_MULTIPLIER_DURATION,
        adminRoleTransferDelay: ADMIN_ROLE_TRANSFER_DELAY
      })
    );
    s_rewardVaultVersion3.setMigrationSource(address(s_rewardVaultVersion2));
    s_rewardVaultVersion2.setMigrationTarget(address(s_rewardVaultVersion3));

    s_rewardVaultVersion2.migrate(bytes(''));
    s_communityStakingPool.setRewardVault(s_rewardVaultVersion3);
    s_operatorStakingPool.setRewardVault(s_rewardVaultVersion3);
    s_secondMigratedAtTime = block.timestamp;

    skip(TIME_AFTER_MIGRATION);
  }

  function test() public override {}
}

abstract contract RewardVault_WhenPaused is RewardVault_WithStakersAndTimePassed {
  function setUp() public override {
    RewardVault_WithStakersAndTimePassed.setUp();

    changePrank(PAUSER);
    s_rewardVault.emergencyPause();
  }

  // This is needed so that "forge coverage" will ignore this contract
  function test() public virtual override {}
}
