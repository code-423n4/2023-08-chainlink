// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {AggregatorV3Interface} from
  '@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol';

import {IERC165} from '@openzeppelin/contracts/interfaces/IERC165.sol';

import {PriceFeedAlertsController} from '../../../src/alerts/PriceFeedAlertsController.sol';
import {PriceFeedAlertsControllerV2} from '../../../src/tests/PriceFeedAlertsControllerV2.sol';
import {IMigratable} from '../../../src/interfaces/IMigratable.sol';
import {IMigrationDataReceiver} from '../../../src/interfaces/IMigrationDataReceiver.sol';
import {
  PriceFeedAlertsController_WithConfiguredPriceFeedAlertsController,
  PriceFeedAlertsController_WithSlasherRole,
  PriceFeedAlertsController_WhenPoolOpen
} from '../../base-scenarios/PriceFeedAlertsControllerScenarios.t.sol';

contract PriceFeedAlertsController_Migrate_WithoutSlasherRole is
  PriceFeedAlertsController_WhenPoolOpen
{
  function test_RevertWhen_Migrate() public {
    changePrank(OWNER);
    vm.expectRevert(PriceFeedAlertsController.DoesNotHaveSlasherRole.selector);
    s_pfAlertsController.migrate(bytes(''));
  }
}

contract PriceFeedAlertsController_Migrate_WithSlasherRole is
  PriceFeedAlertsController_WithSlasherRole
{
  event AlertRaised(address indexed alerter, uint256 indexed roundId);

  function test_RevertWhen_MigrateCalledByNonOwner() public {
    changePrank(STRANGER);
    vm.expectRevert(
      _getExpectedMissingRoleErrorMessage(STRANGER, s_pfAlertsController.DEFAULT_ADMIN_ROLE())
    );
    s_pfAlertsController.migrate(bytes(''));
  }

  function test_RevertWhen_MigrationTargetNotSet() public {
    changePrank(OWNER);
    vm.expectRevert(IMigratable.InvalidMigrationTarget.selector);
    s_pfAlertsController.migrate(bytes(''));
  }

  function test_MigrateCanBeCalledByOwner() public {
    changePrank(OWNER);
    PriceFeedAlertsControllerV2 pfAlertsControllerV2 = new PriceFeedAlertsControllerV2(
      PriceFeedAlertsControllerV2.ConstructorParams({
        migrationSource: address(s_pfAlertsController)
      })
    );
    s_pfAlertsController.setMigrationTarget(address(pfAlertsControllerV2));

    s_pfAlertsController.migrate(bytes(''));
    assertEq(
      s_operatorStakingPool.hasRole(
        s_operatorStakingPool.SLASHER_ROLE(), address(s_pfAlertsController)
      ),
      false
    );
  }

  function test_CanAlertReturnsFalseIfMigrated() public {
    changePrank(OWNER);
    PriceFeedAlertsControllerV2 pfAlertsControllerV2 = new PriceFeedAlertsControllerV2(
      PriceFeedAlertsControllerV2.ConstructorParams({
        migrationSource: address(s_pfAlertsController)
      })
    );
    s_pfAlertsController.setMigrationTarget(address(pfAlertsControllerV2));
    assertEq(s_pfAlertsController.canAlert(OPERATOR_STAKER_ONE, address(FEED)), true);
    s_pfAlertsController.migrate(bytes(''));
    assertEq(s_pfAlertsController.canAlert(OPERATOR_STAKER_ONE, address(FEED)), false);
  }

  function test_RevertWhen_AlertRaisedOnSameRoundIdOnUpgradedContract() public {
    changePrank(OPERATOR_STAKER_ONE);
    s_pfAlertsController.raiseAlert(address(FEED));

    changePrank(OWNER);
    PriceFeedAlertsControllerV2 pfAlertsControllerV2 = new PriceFeedAlertsControllerV2(
      PriceFeedAlertsControllerV2.ConstructorParams({
        migrationSource: address(s_pfAlertsController)
      })
    );
    s_pfAlertsController.setMigrationTarget(address(pfAlertsControllerV2));
    address[] memory feeds = new address[](1);
    feeds[0] = address(FEED);
    s_pfAlertsController.sendMigrationData(feeds);
    s_pfAlertsController.migrate(bytes(''));

    changePrank(OPERATOR_STAKER_ONE);
    vm.expectRevert(PriceFeedAlertsControllerV2.AlertInvalid.selector);
    pfAlertsControllerV2.raiseAlert(address(FEED));
  }

  function test_CanRaiseAlertForNextRoundIdOnUpgradedContract() public {
    changePrank(OPERATOR_STAKER_ONE);
    s_pfAlertsController.raiseAlert(address(FEED));

    changePrank(OWNER);
    PriceFeedAlertsControllerV2 pfAlertsControllerV2 = new PriceFeedAlertsControllerV2(
      PriceFeedAlertsControllerV2.ConstructorParams({
        migrationSource: address(s_pfAlertsController)
      })
    );
    s_pfAlertsController.setMigrationTarget(address(pfAlertsControllerV2));
    address[] memory feeds = new address[](1);
    feeds[0] = address(FEED);
    s_pfAlertsController.sendMigrationData(feeds);
    s_pfAlertsController.migrate(bytes(''));

    assertEq(pfAlertsControllerV2.getLastAlertedRoundId(address(FEED)), ROUND_ID);

    s_timeFeedGoesDown = block.timestamp + 14 days;
    vm.warp(s_timeFeedGoesDown);
    vm.mockCall(
      address(FEED),
      abi.encodeWithSelector(AggregatorV3Interface.latestRoundData.selector),
      abi.encode(ROUND_ID + 1, int256(0), uint128(0), uint128(s_timeFeedGoesDown), uint80(0))
    );
    vm.warp(s_timeFeedGoesDown + PRIORITY_PERIOD_THRESHOLD_SECONDS + 1);

    changePrank(OPERATOR_STAKER_ONE);
    vm.expectEmit(true, true, true, true, address(pfAlertsControllerV2));
    emit AlertRaised(OPERATOR_STAKER_ONE, ROUND_ID + 1);
    pfAlertsControllerV2.raiseAlert(address(FEED));
    assertEq(pfAlertsControllerV2.getLastAlertedRoundId(address(FEED)), ROUND_ID + 1);
  }
}

contract PriceFeedAlertsController_SendMigrationData is
  PriceFeedAlertsController_WithConfiguredPriceFeedAlertsController
{
  event MigrationDataSent(address indexed migrationTarget, address[] feeds, bytes migrationData);
  event FeedConfigRemoved(address indexed feed);

  PriceFeedAlertsControllerV2 private s_pfAlertsControllerV2;
  address[] private s_feeds;

  function setUp() public override {
    PriceFeedAlertsController_WithConfiguredPriceFeedAlertsController.setUp();

    s_pfAlertsControllerV2 = new PriceFeedAlertsControllerV2(
      PriceFeedAlertsControllerV2.ConstructorParams({
        migrationSource: address(s_pfAlertsController)
      })
    );
    s_feeds = new address[](1);
    s_feeds[0] = address(FEED);
  }

  function test_RevertWhen_CalledByNonOwner() public {
    changePrank(STRANGER);
    vm.expectRevert(
      _getExpectedMissingRoleErrorMessage(STRANGER, s_pfAlertsController.DEFAULT_ADMIN_ROLE())
    );
    s_pfAlertsController.sendMigrationData(s_feeds);
  }

  function test_RevertWhen_MigrationTargetNotSet() public {
    changePrank(OWNER);
    vm.expectRevert(IMigratable.InvalidMigrationTarget.selector);
    s_pfAlertsController.sendMigrationData(s_feeds);
  }

  function test_RevertWhen_FeedDoesNotExist() public {
    changePrank(OWNER);
    s_pfAlertsController.setMigrationTarget(address(s_pfAlertsControllerV2));
    s_feeds[0] = address(FEED2);
    vm.expectRevert(PriceFeedAlertsController.FeedDoesNotExist.selector);
    s_pfAlertsController.sendMigrationData(s_feeds);
  }

  function test_CorrectlyMigrates() public {
    changePrank(OWNER);
    s_pfAlertsController.setMigrationTarget(address(s_pfAlertsControllerV2));
    PriceFeedAlertsController.LastAlertedRoundId[] memory lastAlertedRoundIds =
      new PriceFeedAlertsController.LastAlertedRoundId[](1);
    lastAlertedRoundIds[0] =
      PriceFeedAlertsController.LastAlertedRoundId({feed: address(FEED), roundId: 0});
    bytes memory migrationData = abi.encode(lastAlertedRoundIds);
    vm.expectEmit(true, true, true, true, address(s_pfAlertsController));
    emit FeedConfigRemoved(address(FEED));
    vm.expectEmit(true, true, true, true, address(s_pfAlertsController));
    emit MigrationDataSent(address(s_pfAlertsControllerV2), s_feeds, migrationData);
    s_pfAlertsController.sendMigrationData(s_feeds);
    assertEq(s_pfAlertsController.getFeedConfig(address(FEED)).priorityPeriodThreshold, 0);
  }

  function test_RevertWhen_RaisingAlertForMigratedFeed() public {
    changePrank(OWNER);
    s_pfAlertsController.setMigrationTarget(address(s_pfAlertsControllerV2));
    s_pfAlertsController.sendMigrationData(s_feeds);

    changePrank(OPERATOR_STAKER_ONE);
    vm.mockCall(
      address(FEED),
      abi.encodeWithSelector(AggregatorV3Interface.latestRoundData.selector),
      abi.encode(uint80(1), int256(0), uint128(0), uint128(0), uint80(0))
    );
    vm.expectRevert(PriceFeedAlertsController.AlertInvalid.selector);
    s_pfAlertsController.raiseAlert(address(FEED));
  }
}

contract PriceFeedAlertsController_ReceiveMigrationData is
  PriceFeedAlertsController_WithConfiguredPriceFeedAlertsController
{
  event MigrationDataReceived(PriceFeedAlertsController.LastAlertedRoundId[] lastAlertedRoundIds);

  PriceFeedAlertsControllerV2 private s_pfAlertsControllerV2;

  function test_RevertWhen_MigrationSourceNotSet() public {
    changePrank(OWNER);
    s_pfAlertsControllerV2 = new PriceFeedAlertsControllerV2(
      PriceFeedAlertsControllerV2.ConstructorParams({
        migrationSource: address(0)
      })
    );
    changePrank(address(s_pfAlertsController));
    vm.expectRevert(PriceFeedAlertsControllerV2.InvalidMigrationSource.selector);
    s_pfAlertsControllerV2.receiveMigrationData(bytes(''));
  }

  function test_RevertWhen_SenderNotMigrationSource() public {
    changePrank(OWNER);
    s_pfAlertsControllerV2 = new PriceFeedAlertsControllerV2(
      PriceFeedAlertsControllerV2.ConstructorParams({
        migrationSource: address(s_pfAlertsController)
      })
    );
    vm.expectRevert(PriceFeedAlertsControllerV2.SenderNotMigrationSource.selector);
    s_pfAlertsControllerV2.receiveMigrationData(bytes(''));
  }

  function test_CorrectlyReceivesData() public {
    changePrank(OWNER);
    s_pfAlertsControllerV2 = new PriceFeedAlertsControllerV2(
      PriceFeedAlertsControllerV2.ConstructorParams({
        migrationSource: address(s_pfAlertsController)
      })
    );

    changePrank(address(s_pfAlertsController));
    address[] memory feeds = new address[](1);
    feeds[0] = address(FEED);
    PriceFeedAlertsController.LastAlertedRoundId[] memory lastAlertedRoundIds =
      new PriceFeedAlertsController.LastAlertedRoundId[](1);
    lastAlertedRoundIds[0] =
      PriceFeedAlertsController.LastAlertedRoundId({feed: address(FEED), roundId: 0});
    bytes memory migrationData = abi.encode(lastAlertedRoundIds);
    vm.expectEmit(true, true, true, true, address(s_pfAlertsControllerV2));
    emit MigrationDataReceived(lastAlertedRoundIds);
    s_pfAlertsControllerV2.receiveMigrationData(migrationData);
  }
}

contract PriceFeedAlertsController_SetMigrationTarget is
  PriceFeedAlertsController_WithConfiguredPriceFeedAlertsController
{
  event MigrationTargetSet(address indexed oldMigrationTarget, address indexed newMigrationTarget);

  PriceFeedAlertsControllerV2 private s_pfAlertsControllerV2;

  function setUp() public override {
    PriceFeedAlertsController_WithConfiguredPriceFeedAlertsController.setUp();

    s_pfAlertsControllerV2 = new PriceFeedAlertsControllerV2(
      PriceFeedAlertsControllerV2.ConstructorParams({
        migrationSource: address(s_pfAlertsController)
      })
    );
  }

  function test_RevertWhen_CalledByNonOwner() public {
    changePrank(STRANGER);
    vm.expectRevert(
      _getExpectedMissingRoleErrorMessage(STRANGER, s_pfAlertsController.DEFAULT_ADMIN_ROLE())
    );
    s_pfAlertsController.setMigrationTarget(address(s_pfAlertsControllerV2));
  }

  function test_RevertWhen_PassedInZeroAddress() public {
    changePrank(OWNER);
    vm.expectRevert(IMigratable.InvalidMigrationTarget.selector);
    s_pfAlertsController.setMigrationTarget(address(0));
  }

  function test_RevertWhen_PassedInOwnAddress() public {
    changePrank(OWNER);
    vm.expectRevert(IMigratable.InvalidMigrationTarget.selector);
    s_pfAlertsController.setMigrationTarget(address(s_pfAlertsController));
  }

  function test_RevertWhen_PassedInTheSameMigrationTarget() public {
    changePrank(OWNER);
    s_pfAlertsController.setMigrationTarget(address(s_pfAlertsControllerV2));
    vm.expectRevert(IMigratable.InvalidMigrationTarget.selector);
    s_pfAlertsController.setMigrationTarget(address(s_pfAlertsControllerV2));
  }

  function test_RevertWhen_PassedInAnAddressThatIsNotIMigrationDataReceiverCompatible() public {
    changePrank(OWNER);
    vm.mockCall(
      address(s_pfAlertsControllerV2),
      abi.encodeWithSelector(
        IERC165.supportsInterface.selector, IMigrationDataReceiver.receiveMigrationData.selector
      ),
      abi.encode(false)
    );
    vm.expectRevert(IMigratable.InvalidMigrationTarget.selector);
    s_pfAlertsController.setMigrationTarget(address(s_pfAlertsControllerV2));
  }

  function test_RevertWhen_PassedInANonContractAddress() public {
    changePrank(OWNER);
    vm.expectRevert(IMigratable.InvalidMigrationTarget.selector);
    s_pfAlertsController.setMigrationTarget(STRANGER);
  }

  function test_CorrectlySetsMigrationTarget() public {
    changePrank(OWNER);
    vm.expectEmit(true, true, true, true, address(s_pfAlertsController));
    emit MigrationTargetSet(address(0), address(s_pfAlertsControllerV2));
    s_pfAlertsController.setMigrationTarget(address(s_pfAlertsControllerV2));
    assertEq(s_pfAlertsController.getMigrationTarget(), address(s_pfAlertsControllerV2));
  }
}
