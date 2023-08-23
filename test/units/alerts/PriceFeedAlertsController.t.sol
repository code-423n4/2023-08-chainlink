// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {SafeCast} from '@openzeppelin/contracts/utils/math/SafeCast.sol';

import {PriceFeedAlertsController} from '../../../src/alerts/PriceFeedAlertsController.sol';
import {IMigrationDataReceiver} from '../../../src/interfaces/IMigrationDataReceiver.sol';
import {CommunityStakingPool} from '../../../src/pools/CommunityStakingPool.sol';
import {OperatorStakingPool} from '../../../src/pools/OperatorStakingPool.sol';
import {StakingPoolBase} from '../../../src/pools/StakingPoolBase.sol';
import {PriceFeedAlertsControllerV2} from '../../../src/tests/PriceFeedAlertsControllerV2.sol';
import {PriceFeedAlertsController_WithConfiguredPriceFeedAlertsController} from
  '../../base-scenarios/PriceFeedAlertsControllerScenarios.t.sol';
import {IAccessControlDefaultAdminRulesTest} from
  '../../interfaces/IAccessControlDefaultAdminRulesTest.t.sol';
import {IPausableTest} from '../../interfaces/IPausableTest.t.sol';

// =================
// Tests
// =================

contract PriceFeedAlertsController_Constructor is
  PriceFeedAlertsController_WithConfiguredPriceFeedAlertsController
{
  function test_RevertWhen_InvalidCommunityStakingAddress() public {
    vm.expectRevert(PriceFeedAlertsController.InvalidZeroAddress.selector);
    new PriceFeedAlertsController(
      PriceFeedAlertsController.ConstructorParams({
        communityStakingPool: CommunityStakingPool(address(0)),
        operatorStakingPool: s_operatorStakingPool,
        feedConfigs: _getFeedConfigsForConstructor(),
        adminRoleTransferDelay: ADMIN_ROLE_TRANSFER_DELAY
      })
    );
  }

  function test_RevertWhen_InvalidOperatorStakingAddress() public {
    vm.expectRevert(PriceFeedAlertsController.InvalidZeroAddress.selector);
    new PriceFeedAlertsController(
      PriceFeedAlertsController.ConstructorParams({
        communityStakingPool: s_communityStakingPool,
        operatorStakingPool: OperatorStakingPool(address(0)),
        feedConfigs: _getFeedConfigsForConstructor(),
        adminRoleTransferDelay: ADMIN_ROLE_TRANSFER_DELAY
      })
    );
  }

  function test_InitializesVariables() public {
    PriceFeedAlertsController.ConstructorFeedConfigParams[] memory configs =
      _getFeedConfigsForConstructor();
    PriceFeedAlertsController pfAlertsController = new PriceFeedAlertsController(
      PriceFeedAlertsController.ConstructorParams({
        communityStakingPool: s_communityStakingPool,
        operatorStakingPool: s_operatorStakingPool,
        feedConfigs: configs,
        adminRoleTransferDelay: ADMIN_ROLE_TRANSFER_DELAY
      })
    );
    assertEq(pfAlertsController.getStakingPools()[0], address(s_operatorStakingPool));
    assertEq(pfAlertsController.getStakingPools()[1], address(s_communityStakingPool));
    assertEq(
      pfAlertsController.getFeedConfig(address(FEED)).priorityPeriodThreshold,
      configs[0].priorityPeriodThreshold
    );
    assertEq(
      pfAlertsController.getFeedConfig(address(FEED)).regularPeriodThreshold,
      configs[0].regularPeriodThreshold
    );
    assertEq(
      pfAlertsController.getFeedConfig(address(FEED)).slashableAmount, configs[0].slashableAmount
    );
    assertEq(
      pfAlertsController.getFeedConfig(address(FEED)).alerterRewardAmount,
      configs[0].alerterRewardAmount
    );
    assertEq(pfAlertsController.getSlashableOperators(address(FEED)), configs[0].slashableOperators);
  }

  function test_TypeAndVersion() public {
    string memory typeAndVersion = s_pfAlertsController.typeAndVersion();
    assertEq(typeAndVersion, 'PriceFeedAlertsController 1.0.0');
  }
}

contract PriceFeedAlertsController_SetFeedConfig is
  PriceFeedAlertsController_WithConfiguredPriceFeedAlertsController
{
  event FeedConfigSet(
    address indexed feed,
    uint32 priorityPeriodThreshold,
    uint32 regularPeriodThreshold,
    uint96 slashableAmount,
    uint96 alerterRewardAmount
  );

  function test_RevertWhen_SetFeedConfigsByNonOwner() public {
    changePrank(STRANGER);
    vm.expectRevert(
      _getExpectedMissingRoleErrorMessage(STRANGER, s_pfAlertsController.DEFAULT_ADMIN_ROLE())
    );
    s_pfAlertsController.setFeedConfigs(_getFeedConfigs());
  }

  function test_RevertWhen_InvalidFeedAddress() public {
    PriceFeedAlertsController.SetFeedConfigParams[] memory configs = _getFeedConfigs();
    configs[0].feed = address(0);
    vm.expectRevert(PriceFeedAlertsController.InvalidZeroAddress.selector);
    s_pfAlertsController.setFeedConfigs(configs);
  }

  function test_RevertWhen_InvalidPriorityPeriodThreshold() public {
    PriceFeedAlertsController.SetFeedConfigParams[] memory configs = _getFeedConfigs();
    configs[0].priorityPeriodThreshold = 0;
    vm.expectRevert(PriceFeedAlertsController.InvalidPriorityPeriodThreshold.selector);
    s_pfAlertsController.setFeedConfigs(configs);
  }

  function test_RevertWhen_InvalidRegularPeriodThreshold() public {
    PriceFeedAlertsController.SetFeedConfigParams[] memory configs = _getFeedConfigs();
    // regular period should be > priority period
    configs[0].regularPeriodThreshold = PRIORITY_PERIOD_THRESHOLD_SECONDS - 1;
    vm.expectRevert(PriceFeedAlertsController.InvalidRegularPeriodThreshold.selector);
    s_pfAlertsController.setFeedConfigs(configs);
  }

  function test_RevertWhen_SlashableAmountIsZero() public {
    PriceFeedAlertsController.SetFeedConfigParams[] memory configs = _getFeedConfigs();
    configs[0].slashableAmount = 0;
    vm.expectRevert(PriceFeedAlertsController.InvalidSlashableAmount.selector);
    s_pfAlertsController.setFeedConfigs(configs);
  }

  function test_RevertWhen_SlashableAmountIsGreaterThanTheOperatorsMaxPrincipal() public {
    PriceFeedAlertsController.SetFeedConfigParams[] memory configs = _getFeedConfigs();
    configs[0].slashableAmount = uint96(OPERATOR_MAX_PRINCIPAL + 2);
    vm.expectRevert(PriceFeedAlertsController.InvalidSlashableAmount.selector);
    s_pfAlertsController.setFeedConfigs(configs);
  }

  function test_RevertWhen_AlerterRewardAmountIsZero() public {
    PriceFeedAlertsController.SetFeedConfigParams[] memory configs = _getFeedConfigs();
    configs[0].alerterRewardAmount = 0;
    vm.expectRevert(PriceFeedAlertsController.InvalidAlerterRewardAmount.selector);
    s_pfAlertsController.setFeedConfigs(configs);
  }

  function test_SetFeedConfigsSetsFeedConfig() public {
    PriceFeedAlertsController pfAlertsController = new PriceFeedAlertsController(
      PriceFeedAlertsController.ConstructorParams({
        communityStakingPool: s_communityStakingPool,
        operatorStakingPool: s_operatorStakingPool,
        feedConfigs: new PriceFeedAlertsController.ConstructorFeedConfigParams[](0),
        adminRoleTransferDelay: ADMIN_ROLE_TRANSFER_DELAY
      })
    );
    PriceFeedAlertsController.FeedConfig memory configBefore =
      pfAlertsController.getFeedConfig(address(FEED));
    assertEq(configBefore.priorityPeriodThreshold, 0);
    assertEq(configBefore.regularPeriodThreshold, 0);
    assertEq(configBefore.slashableAmount, 0);
    assertEq(configBefore.alerterRewardAmount, 0);

    PriceFeedAlertsController.SetFeedConfigParams[] memory configs = _getFeedConfigs();
    pfAlertsController.setFeedConfigs(configs);
    PriceFeedAlertsController.FeedConfig memory configAfter =
      pfAlertsController.getFeedConfig(address(FEED));
    assertEq(configAfter.priorityPeriodThreshold, PRIORITY_PERIOD_THRESHOLD_SECONDS);
    assertEq(configAfter.regularPeriodThreshold, REGULAR_PERIOD_THRESHOLD_SECONDS);
    assertEq(configAfter.slashableAmount, FEED_SLASHABLE_AMOUNT);
    assertEq(configAfter.alerterRewardAmount, ALERTER_REWARD_AMOUNT);
  }

  function test_SetFeedConfigsUpdatesFeedConfig() public {
    PriceFeedAlertsController.FeedConfig memory configBefore =
      s_pfAlertsController.getFeedConfig(address(FEED));
    assertEq(configBefore.priorityPeriodThreshold, PRIORITY_PERIOD_THRESHOLD_SECONDS);
    assertEq(configBefore.regularPeriodThreshold, REGULAR_PERIOD_THRESHOLD_SECONDS);
    assertEq(configBefore.slashableAmount, FEED_SLASHABLE_AMOUNT);
    assertEq(configBefore.alerterRewardAmount, ALERTER_REWARD_AMOUNT);

    PriceFeedAlertsController.SetFeedConfigParams[] memory configs =
      new PriceFeedAlertsController.SetFeedConfigParams[](1);
    configs[0] = PriceFeedAlertsController.SetFeedConfigParams({
      feed: address(FEED),
      priorityPeriodThreshold: REGULAR_PERIOD_THRESHOLD_SECONDS + 1, // can be the same as regular
        // period
      regularPeriodThreshold: REGULAR_PERIOD_THRESHOLD_SECONDS + 1,
      slashableAmount: FEED_SLASHABLE_AMOUNT + 1,
      alerterRewardAmount: ALERTER_REWARD_AMOUNT + 1
    });
    s_pfAlertsController.setFeedConfigs(configs);
    PriceFeedAlertsController.FeedConfig memory configAfter =
      s_pfAlertsController.getFeedConfig(address(FEED));
    assertEq(configAfter.priorityPeriodThreshold, REGULAR_PERIOD_THRESHOLD_SECONDS + 1);
    assertEq(configAfter.regularPeriodThreshold, REGULAR_PERIOD_THRESHOLD_SECONDS + 1);
    assertEq(configAfter.slashableAmount, FEED_SLASHABLE_AMOUNT + 1);
    assertEq(configAfter.alerterRewardAmount, ALERTER_REWARD_AMOUNT + 1);
  }

  function test_SetFeedConfigsSetsMultipleFeedConfigs() public {
    PriceFeedAlertsController.SetFeedConfigParams[] memory configs =
      new PriceFeedAlertsController.SetFeedConfigParams[](2);
    configs[0] = PriceFeedAlertsController.SetFeedConfigParams({
      feed: address(FEED),
      priorityPeriodThreshold: PRIORITY_PERIOD_THRESHOLD_SECONDS,
      regularPeriodThreshold: REGULAR_PERIOD_THRESHOLD_SECONDS,
      slashableAmount: FEED_SLASHABLE_AMOUNT,
      alerterRewardAmount: ALERTER_REWARD_AMOUNT
    });
    configs[1] = PriceFeedAlertsController.SetFeedConfigParams({
      feed: address(FEED2),
      priorityPeriodThreshold: PRIORITY_PERIOD_THRESHOLD_SECONDS + 1,
      regularPeriodThreshold: REGULAR_PERIOD_THRESHOLD_SECONDS + 1,
      slashableAmount: FEED_SLASHABLE_AMOUNT + 1,
      alerterRewardAmount: ALERTER_REWARD_AMOUNT + 1
    });
    s_pfAlertsController.setFeedConfigs(configs);
    PriceFeedAlertsController.FeedConfig memory feedConfigAfter =
      s_pfAlertsController.getFeedConfig(address(FEED));
    assertEq(feedConfigAfter.priorityPeriodThreshold, PRIORITY_PERIOD_THRESHOLD_SECONDS);
    assertEq(feedConfigAfter.regularPeriodThreshold, REGULAR_PERIOD_THRESHOLD_SECONDS);
    assertEq(feedConfigAfter.slashableAmount, FEED_SLASHABLE_AMOUNT);
    assertEq(feedConfigAfter.alerterRewardAmount, ALERTER_REWARD_AMOUNT);
    PriceFeedAlertsController.FeedConfig memory feed2ConfigAfter =
      s_pfAlertsController.getFeedConfig(address(FEED2));
    assertEq(feed2ConfigAfter.priorityPeriodThreshold, PRIORITY_PERIOD_THRESHOLD_SECONDS + 1);
    assertEq(feed2ConfigAfter.regularPeriodThreshold, REGULAR_PERIOD_THRESHOLD_SECONDS + 1);
    assertEq(feed2ConfigAfter.slashableAmount, FEED_SLASHABLE_AMOUNT + 1);
    assertEq(feed2ConfigAfter.alerterRewardAmount, ALERTER_REWARD_AMOUNT + 1);
  }

  function test_SetFeedConfigsEmitsEvent() public {
    PriceFeedAlertsController.SetFeedConfigParams[] memory configs = _getFeedConfigs();
    vm.expectEmit(true, true, true, true, address(s_pfAlertsController));
    emit FeedConfigSet(
      address(FEED),
      PRIORITY_PERIOD_THRESHOLD_SECONDS,
      REGULAR_PERIOD_THRESHOLD_SECONDS,
      FEED_SLASHABLE_AMOUNT,
      ALERTER_REWARD_AMOUNT
    );
    s_pfAlertsController.setFeedConfigs(configs);
  }
}

contract PriceFeedAlertsController_RemoveFeedConfig is
  PriceFeedAlertsController_WithConfiguredPriceFeedAlertsController
{
  event FeedConfigRemoved(address indexed feed);

  function test_RevertWhen_FeedDoesNotExist() public {
    vm.expectRevert(PriceFeedAlertsController.FeedDoesNotExist.selector);
    s_pfAlertsController.removeFeedConfig(address(FEED2));
  }

  function test_RemoveFeedConfigRemovesFeedConfig() public {
    address[] memory operators = _getDefaultOperators();
    s_pfAlertsController.setSlashableOperators(operators, address(FEED));
    PriceFeedAlertsController.FeedConfig memory configBefore =
      s_pfAlertsController.getFeedConfig(address(FEED));
    assertEq(configBefore.priorityPeriodThreshold, PRIORITY_PERIOD_THRESHOLD_SECONDS);
    assertEq(configBefore.regularPeriodThreshold, REGULAR_PERIOD_THRESHOLD_SECONDS);
    assertEq(s_pfAlertsController.getSlashableOperators(address(FEED)), operators);

    s_pfAlertsController.removeFeedConfig(address(FEED));
    PriceFeedAlertsController.FeedConfig memory configAfter =
      s_pfAlertsController.getFeedConfig(address(FEED));
    assertEq(configAfter.priorityPeriodThreshold, 0);
    assertEq(configAfter.regularPeriodThreshold, 0);
    assertEq(s_pfAlertsController.getSlashableOperators(address(FEED)), new address[](0));
  }

  function test_RemoveFeedConfigEmitsEvent() public {
    vm.expectEmit(false, false, false, true, address(s_pfAlertsController));
    emit FeedConfigRemoved(address(FEED));
    s_pfAlertsController.removeFeedConfig(address(FEED));
  }
}

contract PriceFeedAlertsController_SlashableOperators is
  PriceFeedAlertsController_WithConfiguredPriceFeedAlertsController
{
  event SlashableOperatorsSet(address indexed feed, address[] operators);

  function setUp() public virtual override {
    PriceFeedAlertsController_WithConfiguredPriceFeedAlertsController.setUp();

    changePrank(OWNER);
    PriceFeedAlertsController.SetFeedConfigParams[] memory configs =
      new PriceFeedAlertsController.SetFeedConfigParams[](1);
    configs[0] = PriceFeedAlertsController.SetFeedConfigParams({
      feed: address(FEED),
      priorityPeriodThreshold: PRIORITY_PERIOD_THRESHOLD_SECONDS,
      regularPeriodThreshold: REGULAR_PERIOD_THRESHOLD_SECONDS,
      slashableAmount: FEED_SLASHABLE_AMOUNT,
      alerterRewardAmount: ALERTER_REWARD_AMOUNT
    });
    s_pfAlertsController.setFeedConfigs(configs);
  }

  function test_RevertWhen_SetFeedConfigsCalledByNonOwner() public {
    changePrank(STRANGER);
    vm.expectRevert(
      _getExpectedMissingRoleErrorMessage(STRANGER, s_pfAlertsController.DEFAULT_ADMIN_ROLE())
    );
    address[] memory operators = _getDefaultOperators();
    s_pfAlertsController.setSlashableOperators(operators, address(FEED));
  }

  function test_RevertWhen_SetFeedConfigsWithInvalidFeed() public {
    vm.expectRevert(PriceFeedAlertsController.InvalidZeroAddress.selector);
    address[] memory operators = _getDefaultOperators();
    s_pfAlertsController.setSlashableOperators(operators, address(0));
  }

  function test_RevertWhen_SetFeedConfigsWithUnregisteredFeed() public {
    vm.expectRevert(PriceFeedAlertsController.FeedDoesNotExist.selector);
    address[] memory operators = _getDefaultOperators();
    s_pfAlertsController.setSlashableOperators(operators, address(STRANGER));
  }

  function test_RevertWhen_SetFeedConfigsWithInvalidOperator() public {
    vm.expectRevert(PriceFeedAlertsController.InvalidZeroAddress.selector);
    address[] memory operators = new address[](1);
    operators[0] = address(0);
    s_pfAlertsController.setSlashableOperators(operators, address(FEED));
  }

  function test_RevertWhen_SetFeedConfigsWithUnsortedOperatorList() public {
    vm.expectRevert(PriceFeedAlertsController.InvalidOperatorList.selector);
    address[] memory operators = new address[](2);
    operators[0] = OPERATOR_STAKER_TWO;
    operators[1] = OPERATOR_STAKER_ONE;
    s_pfAlertsController.setSlashableOperators(operators, address(FEED));
  }

  function test_RevertWhen_SetFeedConfigsWithOperatorListWithDuplicates() public {
    vm.expectRevert(PriceFeedAlertsController.InvalidOperatorList.selector);
    address[] memory operators = new address[](2);
    operators[0] = OPERATOR_STAKER_ONE;
    operators[1] = OPERATOR_STAKER_ONE;
    s_pfAlertsController.setSlashableOperators(operators, address(FEED));
  }

  function test_SetSlashableOperators() public {
    address[] memory operators = _getDefaultOperators();
    s_pfAlertsController.setSlashableOperators(operators, address(FEED));
    address[] memory setOperators = s_pfAlertsController.getSlashableOperators(address(FEED));
    assertEq(setOperators.length, operators.length);
    for (uint256 i; i < operators.length; ++i) {
      assertEq(setOperators[i], operators[i]);
    }
  }

  function test_SetSlashableOperatorsOverwritesExistingOperators() public {
    address[] memory operators = _getDefaultOperators();
    s_pfAlertsController.setSlashableOperators(operators, address(FEED));
    assertEq(s_pfAlertsController.getSlashableOperators(address(FEED)), operators);

    operators = new address[](1);
    operators[0] = STRANGER;
    s_pfAlertsController.setSlashableOperators(operators, address(FEED));
    assertEq(s_pfAlertsController.getSlashableOperators(address(FEED)), operators);
  }

  function test_SetSlashableOperatorsEmitsEvent() public {
    address[] memory operators = _getDefaultOperators();
    vm.expectEmit(false, false, false, true, address(s_pfAlertsController));
    emit SlashableOperatorsSet(address(FEED), operators);
    s_pfAlertsController.setSlashableOperators(operators, address(FEED));
  }

  function test_GetSlashableOperators() public {
    address[] memory operators = _getDefaultOperators();
    s_pfAlertsController.setSlashableOperators(operators, address(FEED));
    assertEq(s_pfAlertsController.getSlashableOperators(address(FEED)), operators);
  }
}

contract PriceFeedAlertsController_Pausable is
  PriceFeedAlertsController_WithConfiguredPriceFeedAlertsController,
  IPausableTest
{
  function test_RevertWhen_NotPauserEmergencyPause() public {
    changePrank(STRANGER);
    vm.expectRevert(
      _getExpectedMissingRoleErrorMessage(STRANGER, s_pfAlertsController.PAUSER_ROLE())
    );

    s_pfAlertsController.emergencyPause();
    assertEq(s_pfAlertsController.paused(), false);
  }

  function test_PauserCanEmergencyPause() public {
    changePrank(PAUSER);

    s_pfAlertsController.emergencyPause();
    assertEq(s_pfAlertsController.paused(), true);
  }

  function test_RevertWhen_PausingWhenAlreadyPaused() public {
    changePrank(PAUSER);
    s_pfAlertsController.emergencyPause();

    vm.expectRevert('Pausable: paused');
    s_pfAlertsController.emergencyPause();
  }

  function test_RevertWhen_NotPauserEmergencyUnpause() public {
    changePrank(PAUSER);
    s_pfAlertsController.emergencyPause();

    changePrank(STRANGER);
    vm.expectRevert(
      _getExpectedMissingRoleErrorMessage(STRANGER, s_pfAlertsController.PAUSER_ROLE())
    );
    s_pfAlertsController.emergencyUnpause();

    assertEq(s_pfAlertsController.paused(), true);
  }

  function test_PauserCanEmergencyUnpause() public {
    changePrank(PAUSER);
    s_pfAlertsController.emergencyPause();
    s_pfAlertsController.emergencyUnpause();
    assertEq(s_pfAlertsController.paused(), false);
  }

  function test_RevertWhen_UnpausingWhenAlreadyUnpaused() public {
    changePrank(PAUSER);

    vm.expectRevert('Pausable: not paused');
    s_pfAlertsController.emergencyUnpause();
  }
}

contract PriceFeedAlertsController_SupportsInterface is
  PriceFeedAlertsController_WithConfiguredPriceFeedAlertsController
{
  function test_IsIMigrationDataReceiverCompatible() public {
    PriceFeedAlertsControllerV2 pfAlertsControllerV2 = new PriceFeedAlertsControllerV2(
      PriceFeedAlertsControllerV2.ConstructorParams({
        migrationSource: address(s_pfAlertsController)
      })
    );
    assertEq(
      pfAlertsControllerV2.supportsInterface(IMigrationDataReceiver.receiveMigrationData.selector),
      true
    );
  }
}

contract PriceFeedAlertsController_SetCommunityStakingPool is
  PriceFeedAlertsController_WithConfiguredPriceFeedAlertsController
{
  CommunityStakingPool s_communityStakingPoolNew;

  function setUp() public override {
    PriceFeedAlertsController_WithConfiguredPriceFeedAlertsController.setUp();

    s_communityStakingPoolNew = new CommunityStakingPool(
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
  }

  event CommunityStakingPoolSet(
    address indexed oldCommunityStakingPool, address indexed newCommunityStakingPool
  );

  function test_RevertWhen_CalledByNonOwner() public {
    changePrank(STRANGER);
    vm.expectRevert(
      _getExpectedMissingRoleErrorMessage(STRANGER, s_pfAlertsController.DEFAULT_ADMIN_ROLE())
    );
    s_pfAlertsController.setCommunityStakingPool(s_communityStakingPoolNew);
  }

  function test_RevertWhen_CalledWithZeroAddress() public {
    changePrank(OWNER);
    vm.expectRevert(PriceFeedAlertsController.InvalidZeroAddress.selector);
    s_pfAlertsController.setCommunityStakingPool(CommunityStakingPool(address(0)));
  }

  function test_CorrectlySetsCommunityPool() public {
    changePrank(OWNER);
    vm.expectEmit(true, true, true, true, address(s_pfAlertsController));
    emit CommunityStakingPoolSet(
      address(s_communityStakingPool), address(s_communityStakingPoolNew)
    );
    s_pfAlertsController.setCommunityStakingPool(s_communityStakingPoolNew);
    assertEq(s_pfAlertsController.getStakingPools()[1], address(s_communityStakingPoolNew));
  }
}

contract PriceFeedAlertsController_SetOperatorStakingPool is
  PriceFeedAlertsController_WithConfiguredPriceFeedAlertsController
{
  OperatorStakingPool s_operatorStakingPoolNew;

  function setUp() public override {
    PriceFeedAlertsController_WithConfiguredPriceFeedAlertsController.setUp();

    s_operatorStakingPoolNew = new OperatorStakingPool(
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
  }

  event OperatorStakingPoolSet(
    address indexed oldOperatorStakingPool, address indexed newOperatorStakingPool
  );

  function test_RevertWhen_CalledByNonOwner() public {
    changePrank(STRANGER);
    vm.expectRevert(
      _getExpectedMissingRoleErrorMessage(STRANGER, s_pfAlertsController.DEFAULT_ADMIN_ROLE())
    );
    s_pfAlertsController.setOperatorStakingPool(s_operatorStakingPoolNew);
  }

  function test_RevertWhen_CalledWithZeroAddress() public {
    changePrank(OWNER);
    vm.expectRevert(PriceFeedAlertsController.InvalidZeroAddress.selector);
    s_pfAlertsController.setOperatorStakingPool(OperatorStakingPool(address(0)));
  }

  function test_CorrectlySetsOperatorPool() public {
    changePrank(OWNER);
    vm.expectEmit(true, true, true, true, address(s_pfAlertsController));
    emit OperatorStakingPoolSet(address(s_operatorStakingPool), address(s_operatorStakingPoolNew));
    s_pfAlertsController.setOperatorStakingPool(s_operatorStakingPoolNew);
    assertEq(s_pfAlertsController.getStakingPools()[0], address(s_operatorStakingPoolNew));
  }
}

contract PriceFeedAlertsController_AccessControlDefaultAdminRules is
  IAccessControlDefaultAdminRulesTest,
  PriceFeedAlertsController_WithConfiguredPriceFeedAlertsController
{
  using SafeCast for uint256;

  event DefaultAdminTransferScheduled(address indexed newAdmin, uint48 acceptSchedule);
  event DefaultAdminTransferCanceled();
  event DefaultAdminDelayChangeScheduled(uint48 newDelay, uint48 effectSchedule);
  event DefaultAdminDelayChangeCanceled();

  function test_DefaultValuesAreInitialized() public {
    assertEq(s_pfAlertsController.hasRole(s_pfAlertsController.DEFAULT_ADMIN_ROLE(), OWNER), true);
    assertEq(s_pfAlertsController.defaultAdmin(), OWNER);
    (address pendingDefaultAdmin, uint48 adminSchedule) = s_pfAlertsController.pendingDefaultAdmin();
    assertEq(pendingDefaultAdmin, address(0));
    assertEq(adminSchedule, 0);
    assertEq(s_pfAlertsController.defaultAdminDelay(), 0);
    (uint48 pendingDelay, uint48 delaySchedule) = s_pfAlertsController.pendingDefaultAdminDelay();
    assertEq(pendingDelay, 0);
    assertEq(delaySchedule, 0);
    assertEq(s_pfAlertsController.defaultAdminDelayIncreaseWait(), 5 days);
  }

  function test_RevertWhen_DirectlyGrantDefaultAdminRole() public {
    changePrank(OWNER);
    bytes32 defaultAdminRole = s_pfAlertsController.DEFAULT_ADMIN_ROLE();
    vm.expectRevert("AccessControl: can't directly grant default admin role");
    s_pfAlertsController.grantRole(defaultAdminRole, NEW_OWNER);
  }

  function test_RevertWhen_DirectlyRevokeDefaultAdminRole() public {
    changePrank(OWNER);
    bytes32 defaultAdminRole = s_pfAlertsController.DEFAULT_ADMIN_ROLE();
    vm.expectRevert("AccessControl: can't directly revoke default admin role");
    s_pfAlertsController.revokeRole(defaultAdminRole, NEW_OWNER);
  }

  function test_RevertWhen_NonAdminBeginsDefaultAdminTransfer() public {
    changePrank(NEW_OWNER);
    vm.expectRevert(
      _getExpectedMissingRoleErrorMessage(NEW_OWNER, s_pfAlertsController.DEFAULT_ADMIN_ROLE())
    );
    s_pfAlertsController.beginDefaultAdminTransfer(NEW_OWNER);
  }

  function test_CurrentAdminCanBeginDefaultAdminTransfer() public {
    changePrank(OWNER);
    address newAdmin = NEW_OWNER;
    uint48 newSchedule = SafeCast.toUint48(block.timestamp);
    vm.expectEmit(true, true, true, true, address(s_pfAlertsController));
    emit DefaultAdminTransferScheduled(newAdmin, newSchedule);

    s_pfAlertsController.beginDefaultAdminTransfer(newAdmin);

    assertEq(s_pfAlertsController.hasRole(s_pfAlertsController.DEFAULT_ADMIN_ROLE(), OWNER), true);
    assertEq(s_pfAlertsController.defaultAdmin(), OWNER);
    (address pendingDefaultAdmin, uint48 schedule) = s_pfAlertsController.pendingDefaultAdmin();
    assertEq(pendingDefaultAdmin, newAdmin);
    assertEq(schedule, newSchedule);
  }

  function test_CurrentAdminCanOverwritePendingDefaultAdminTransfer() public {
    changePrank(OWNER);
    s_pfAlertsController.beginDefaultAdminTransfer(NEW_OWNER);

    address newAdmin = PAUSER;
    uint48 newSchedule = SafeCast.toUint48(block.timestamp);
    vm.expectEmit(true, true, true, true, address(s_pfAlertsController));
    emit DefaultAdminTransferCanceled();
    vm.expectEmit(true, true, true, true, address(s_pfAlertsController));
    emit DefaultAdminTransferScheduled(newAdmin, newSchedule);

    s_pfAlertsController.beginDefaultAdminTransfer(newAdmin);

    assertEq(s_pfAlertsController.hasRole(s_pfAlertsController.DEFAULT_ADMIN_ROLE(), OWNER), true);
    assertEq(s_pfAlertsController.defaultAdmin(), OWNER);
    (address pendingDefaultAdmin, uint48 schedule) = s_pfAlertsController.pendingDefaultAdmin();
    assertEq(pendingDefaultAdmin, newAdmin);
    assertEq(schedule, newSchedule);
  }

  function test_CurrentAdminCanOverwriteDefaultAdminTransferAfterDelayPassedAndIfNotAccepted()
    public
  {
    changePrank(OWNER);
    s_pfAlertsController.beginDefaultAdminTransfer(NEW_OWNER);
    (, uint48 scheduleBefore) = s_pfAlertsController.pendingDefaultAdmin();

    // After the delay is over
    skip(2);

    address newAdmin = PAUSER;
    uint48 newSchedule = scheduleBefore + 2;
    vm.expectEmit(true, true, true, true, address(s_pfAlertsController));
    emit DefaultAdminTransferCanceled();
    vm.expectEmit(true, true, true, true, address(s_pfAlertsController));
    emit DefaultAdminTransferScheduled(newAdmin, newSchedule);

    s_pfAlertsController.beginDefaultAdminTransfer(PAUSER);

    assertEq(s_pfAlertsController.hasRole(s_pfAlertsController.DEFAULT_ADMIN_ROLE(), OWNER), true);
    assertEq(s_pfAlertsController.defaultAdmin(), OWNER);
    (address pendingDefaultAdmin, uint48 schedule) = s_pfAlertsController.pendingDefaultAdmin();
    assertEq(pendingDefaultAdmin, newAdmin);
    assertEq(schedule, newSchedule);
  }

  function test_RevertWhen_NonAdminCancelPendingDefaultAdminTransfer() public {
    changePrank(OWNER);
    s_pfAlertsController.beginDefaultAdminTransfer(NEW_OWNER);

    changePrank(NEW_OWNER);
    vm.expectRevert(
      _getExpectedMissingRoleErrorMessage(NEW_OWNER, s_pfAlertsController.DEFAULT_ADMIN_ROLE())
    );
    s_pfAlertsController.cancelDefaultAdminTransfer();
  }

  function test_CurrentAdminCanCancelPendingDefaultAdminTransfer() public {
    changePrank(OWNER);
    s_pfAlertsController.beginDefaultAdminTransfer(NEW_OWNER);

    vm.expectEmit(true, true, true, true, address(s_pfAlertsController));
    emit DefaultAdminTransferCanceled();
    s_pfAlertsController.cancelDefaultAdminTransfer();

    (address pendingDefaultAdmin, uint48 schedule) = s_pfAlertsController.pendingDefaultAdmin();
    assertEq(pendingDefaultAdmin, address(0));
    assertEq(schedule, 0);
  }

  function test_RevertWhen_NonPendingDefaultAdminAcceptsTransfer() public {
    changePrank(OWNER);
    s_pfAlertsController.beginDefaultAdminTransfer(NEW_OWNER);

    changePrank(STRANGER);
    vm.expectRevert('AccessControl: pending admin must accept');
    s_pfAlertsController.acceptDefaultAdminTransfer();
  }

  function test_RevertWhen_PendingDefaultAdminAcceptsTransferBeforeDelayPassed() public {
    changePrank(OWNER);
    s_pfAlertsController.changeDefaultAdminDelay(1 days);
    s_pfAlertsController.beginDefaultAdminTransfer(NEW_OWNER);

    changePrank(NEW_OWNER);
    vm.expectRevert('AccessControl: transfer delay not passed');
    s_pfAlertsController.acceptDefaultAdminTransfer();
  }

  function test_PendingDefaultAdminCanAcceptTransferImmediatelyIfDelayIsZero() public {
    changePrank(OWNER);
    s_pfAlertsController.beginDefaultAdminTransfer(NEW_OWNER);

    skip(1); // needs to satisfy: schedule < block.timestamp

    changePrank(NEW_OWNER);
    s_pfAlertsController.acceptDefaultAdminTransfer();

    assertEq(s_pfAlertsController.hasRole(s_pfAlertsController.DEFAULT_ADMIN_ROLE(), OWNER), false);
    assertEq(
      s_pfAlertsController.hasRole(s_pfAlertsController.DEFAULT_ADMIN_ROLE(), NEW_OWNER), true
    );
    assertEq(s_pfAlertsController.defaultAdmin(), NEW_OWNER);
    (address pendingDefaultAdmin, uint48 schedule) = s_pfAlertsController.pendingDefaultAdmin();
    assertEq(pendingDefaultAdmin, address(0));
    assertEq(schedule, 0);
  }

  function test_PendingDefaultAdminCanAcceptTransferAfterDelayPassed() public {
    changePrank(OWNER);
    s_pfAlertsController.changeDefaultAdminDelay(30 days);
    s_pfAlertsController.beginDefaultAdminTransfer(NEW_OWNER);

    skip(30 days);

    changePrank(NEW_OWNER);
    s_pfAlertsController.acceptDefaultAdminTransfer();

    assertEq(s_pfAlertsController.hasRole(s_pfAlertsController.DEFAULT_ADMIN_ROLE(), OWNER), false);
    assertEq(
      s_pfAlertsController.hasRole(s_pfAlertsController.DEFAULT_ADMIN_ROLE(), NEW_OWNER), true
    );
    assertEq(s_pfAlertsController.defaultAdmin(), NEW_OWNER);
    (address pendingDefaultAdmin, uint48 schedule) = s_pfAlertsController.pendingDefaultAdmin();
    assertEq(pendingDefaultAdmin, address(0));
    assertEq(schedule, 0);
  }

  function test_RevertWhen_NonAdminChangesDelay() public {
    changePrank(NEW_OWNER);
    vm.expectRevert(
      _getExpectedMissingRoleErrorMessage(NEW_OWNER, s_pfAlertsController.DEFAULT_ADMIN_ROLE())
    );
    s_pfAlertsController.changeDefaultAdminDelay(30 days);
  }

  function test_CurrentAdminCanChangeDelay() public {
    changePrank(OWNER);
    uint48 newDelay = 30 days;
    uint48 newSchedule = SafeCast.toUint48(block.timestamp + 5 days);
    vm.expectEmit(true, true, true, true, address(s_pfAlertsController));
    emit DefaultAdminDelayChangeScheduled(newDelay, newSchedule);
    s_pfAlertsController.changeDefaultAdminDelay(newDelay);

    assertEq(s_pfAlertsController.defaultAdminDelay(), 0);
    (uint48 pendingDelay, uint48 schedule) = s_pfAlertsController.pendingDefaultAdminDelay();
    assertEq(pendingDelay, newDelay);
    assertEq(schedule, newSchedule);
  }

  function test_RevertWhen_NonAdminRollbackDelayChange() public {
    changePrank(OWNER);
    s_pfAlertsController.changeDefaultAdminDelay(30 days);

    changePrank(NEW_OWNER);
    vm.expectRevert(
      _getExpectedMissingRoleErrorMessage(NEW_OWNER, s_pfAlertsController.DEFAULT_ADMIN_ROLE())
    );
    s_pfAlertsController.rollbackDefaultAdminDelay();
  }

  function test_CurrentAdminCanRollbackDelayChange() public {
    changePrank(OWNER);
    s_pfAlertsController.changeDefaultAdminDelay(30 days);

    vm.expectEmit(true, true, true, true, address(s_pfAlertsController));
    emit DefaultAdminDelayChangeCanceled();
    s_pfAlertsController.rollbackDefaultAdminDelay();

    assertEq(s_pfAlertsController.defaultAdminDelay(), 0);
    (uint48 pendingDelay, uint48 schedule) = s_pfAlertsController.pendingDefaultAdminDelay();
    assertEq(pendingDelay, 0);
    assertEq(schedule, 0);
  }
}
