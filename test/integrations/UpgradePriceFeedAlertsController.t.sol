// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {AggregatorV3Interface} from
  '@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol';
import {IAccessControl} from '@openzeppelin/contracts/access/IAccessControl.sol';
import {BaseTestTimelocked} from '../BaseTestTimelocked.t.sol';
import {PriceFeedAlertsController} from '../../src/alerts/PriceFeedAlertsController.sol';
import {PriceFeedAlertsControllerV2} from '../../src/tests/PriceFeedAlertsControllerV2.sol';
import {RewardVault} from '../../src/rewards/RewardVault.sol';
import {StakingPoolBase} from '../../src/pools/StakingPoolBase.sol';
import {Timelock} from '../../src/timelock/Timelock.sol';
import {IMigratable} from '../../src/interfaces/IMigratable.sol';
import {ISlashable} from '../../src/interfaces/ISlashable.sol';

contract UpgradePriceFeedAlertsController is BaseTestTimelocked {
  // PriceFeedAlertsControllerV2 event
  event AlertRaised(address indexed alerter, uint256 indexed roundId);

  PriceFeedAlertsControllerV2 private s_pfAlertsControllerV2;
  Timelock.Call[] private s_timelockUpgradeCalls;
  uint256 private s_lastAlertedRoundId;

  function setUp() public override {
    BaseTestTimelocked.setUp();

    _deployNewPriceFeedAlertsController();
  }

  function test_UpgradePriceFeedAlertsController() public {
    // step 1: schedule upgrade
    _schedulePriceFeedAlertsControllerUpgrade();
    _validateUpgradeIsTimelocked();

    // step 2: wait for timelock to end
    vm.warp(block.timestamp + DELAY_ONE_MONTH);

    // step 3: raise an alert before migrate
    _mockAlertableIncident();
    _raiseAlertBeforeMigrate();

    // step 4: execute upgrade
    _executePriceFeedAlertsControllerUpgrade();
    _validateSlasherRoles();
    _validateRevertOnAlreadyRaisedAlerts();

    // step 5: try raising alert on new incident
    _mockAlertableIncident();
    _validateCanRaiseAlertOnNewIncident();
  }

  function _deployNewPriceFeedAlertsController() private {
    changePrank(OWNER);
    s_pfAlertsControllerV2 = new PriceFeedAlertsControllerV2(
      PriceFeedAlertsControllerV2.ConstructorParams({
        migrationSource: address(s_pfAlertsController)
      })
    );
  }

  function _schedulePriceFeedAlertsControllerUpgrade() private {
    changePrank(PROPOSER_ONE);
    address[] memory feeds = new address[](1);
    feeds[0] = address(FEED);
    s_timelockUpgradeCalls.push(
      _timelockCall(
        address(s_pfAlertsController),
        abi.encodeWithSelector(
          IMigratable.setMigrationTarget.selector, address(s_pfAlertsControllerV2)
        )
      )
    );
    s_timelockUpgradeCalls.push(
      _timelockCall(
        address(s_pfAlertsController),
        abi.encodeWithSelector(PriceFeedAlertsController.sendMigrationData.selector, feeds)
      )
    );
    s_timelockUpgradeCalls.push(
      _timelockCall(
        address(s_pfAlertsController),
        abi.encodeWithSelector(IMigratable.migrate.selector, bytes(''))
      )
    );
    s_timelockUpgradeCalls.push(
      _timelockCall(
        address(s_operatorStakingPool),
        abi.encodeWithSelector(
          ISlashable.addSlasher.selector,
          address(s_pfAlertsControllerV2),
          ISlashable.SlasherConfig({
            refillRate: SLASH_REFILL_RATE,
            slashCapacity: FEED_SLASHABLE_AMOUNT * MIN_INITIAL_OPERATOR_COUNT
          })
        )
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

  function _mockAlertableIncident() private {
    uint256 timeFeedGoesDown = block.timestamp + 14 days;
    vm.warp(timeFeedGoesDown);

    s_lastAlertedRoundId++;
    vm.mockCall(
      address(FEED),
      abi.encodeWithSelector(AggregatorV3Interface.latestRoundData.selector),
      abi.encode(s_lastAlertedRoundId, int256(0), uint128(0), uint128(timeFeedGoesDown), uint80(0))
    );

    vm.warp(timeFeedGoesDown + REGULAR_PERIOD_THRESHOLD_SECONDS + 1);
  }

  function _raiseAlertBeforeMigrate() private {
    changePrank(COMMUNITY_STAKER_ONE);
    uint256 alerterLinkBalance = s_LINK.balanceOf(COMMUNITY_STAKER_ONE);
    uint256 operatorPrincipalBefore = s_operatorStakingPool.getStakerPrincipal(OPERATOR_STAKER_ONE);
    s_pfAlertsController.raiseAlert(address(FEED));
    assertEq(s_LINK.balanceOf(COMMUNITY_STAKER_ONE), alerterLinkBalance + ALERTER_REWARD_AMOUNT);
    uint256 expectedPrincipalAfterSlashing = FEED_SLASHABLE_AMOUNT >= operatorPrincipalBefore
      ? 0
      : operatorPrincipalBefore - FEED_SLASHABLE_AMOUNT;
    assertEq(
      s_operatorStakingPool.getStakerPrincipal(OPERATOR_STAKER_ONE), expectedPrincipalAfterSlashing
    );
  }

  function _executePriceFeedAlertsControllerUpgrade() private {
    changePrank(EXECUTOR_ONE);
    s_stakingTimelock.executeBatch(s_timelockUpgradeCalls, NO_PREDECESSOR, EMPTY_SALT);
  }

  function _validateSlasherRoles() private {
    assertEq(
      s_operatorStakingPool.hasRole(
        s_operatorStakingPool.SLASHER_ROLE(), address(s_pfAlertsControllerV2)
      ),
      true
    );
    assertEq(
      s_operatorStakingPool.hasRole(
        s_operatorStakingPool.SLASHER_ROLE(), address(s_pfAlertsController)
      ),
      false
    );
  }

  function _validateRevertOnAlreadyRaisedAlerts() private {
    changePrank(COMMUNITY_STAKER_ONE);

    // cannot raise alert for already raised incident on new alerts controller
    vm.expectRevert(PriceFeedAlertsController.AlertInvalid.selector);
    s_pfAlertsControllerV2.raiseAlert(address(FEED));

    // cannot raise alert for migrated feed on old alerts controller
    vm.expectRevert(PriceFeedAlertsController.AlertInvalid.selector);
    s_pfAlertsController.raiseAlert(address(FEED));
  }

  function _validateCanRaiseAlertOnNewIncident() private {
    changePrank(COMMUNITY_STAKER_ONE);

    // can raise alert for new incident on new alerts controller
    vm.expectEmit(true, true, true, true, address(s_pfAlertsControllerV2));
    emit AlertRaised(COMMUNITY_STAKER_ONE, s_lastAlertedRoundId);
    s_pfAlertsControllerV2.raiseAlert(address(FEED));

    // cannot raise alert for new incident on old alerts controller
    vm.expectRevert(PriceFeedAlertsController.AlertInvalid.selector);
    s_pfAlertsController.raiseAlert(address(FEED));
  }
}
