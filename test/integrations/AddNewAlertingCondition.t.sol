// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {PriceFeedAlertsController_WithSlasherRole} from
  '../base-scenarios/PriceFeedAlertsControllerScenarios.t.sol';
import {ISlashable} from '../../src/interfaces/ISlashable.sol';
import {AlertsController} from '../../src/tests/AlertsController.sol';

contract AddNewAlertingCondition is PriceFeedAlertsController_WithSlasherRole {
  uint256 private constant ALERT_SLASHABLE_AMOUNT = OPERATOR_MIN_PRINCIPAL;
  uint256 private constant ALERT_REWARD_AMOUNT = ALERT_SLASHABLE_AMOUNT;

  AlertsController private s_alertsController;
  uint256 private s_alerterBalance;
  mapping(address => uint256) s_slashableOperatorsBalances;

  function setUp() public override {
    PriceFeedAlertsController_WithSlasherRole.setUp();
  }

  function test_AddNewAlertingCondition() public {
    // step 1: deploy new alerts controller
    _deployNewAlertsController();

    // step 2: configure slashable operators
    _configureSlashableOperators();

    // step 3: grant slasher role to new alerts controller
    _addSlasher();

    // step 4: set up alert condition and raise alert
    _validateAlertConditionCannotBeRaised();
    _setupAlertCondition();
    _validateAlertConditionCanBeRaised();
    _raiseAlertCondition();
    _validateAfterAlertConditionIsRaised();
  }

  function _deployNewAlertsController() private {
    s_alertsController = new AlertsController(AlertsController.ConstructorParams({
      alerterRewardAmount: ALERT_REWARD_AMOUNT,
      slashableAmount: ALERT_SLASHABLE_AMOUNT,
      communityStakingPool: s_communityStakingPool,
      operatorStakingPool: s_operatorStakingPool,
      slashableOperators: _getSlashableOperators()
    }));

    address[] memory stakingPools = s_alertsController.getStakingPools();
    // should only return 2 pools (operator and community)
    assertEq(stakingPools.length, 2);
    assertTrue(stakingPools[0] != stakingPools[1]);
    assertTrue(
      stakingPools[0] == address(s_operatorStakingPool)
        || stakingPools[1] == address(s_operatorStakingPool)
    );
    assertTrue(
      stakingPools[0] == address(s_communityStakingPool)
        || stakingPools[1] == address(s_communityStakingPool)
    );
  }

  function _configureSlashableOperators() private {
    changePrank(OWNER);
    s_alertsController.setSlashableOperators(_getSlashableOperators(), address(FEED));
    assertEq(s_alertsController.getSlashableOperators(address(FEED)), _getSlashableOperators());
  }

  function _addSlasher() private {
    changePrank(OWNER);
    s_operatorStakingPool.addSlasher(
      address(s_alertsController),
      ISlashable.SlasherConfig({refillRate: SLASH_REFILL_RATE, slashCapacity: SLASH_MAX_AMOUNT})
    );
  }

  function _setupAlertCondition() private {
    changePrank(OWNER);
    s_alertsController.toggleRaisable();
  }

  function _raiseAlertCondition() private {
    // store balances before slashing
    s_alerterBalance = s_LINK.balanceOf(COMMUNITY_STAKER_ONE);
    address[] memory slashableOperators = _getSlashableOperators();
    for (uint256 i; i < slashableOperators.length; ++i) {
      s_slashableOperatorsBalances[slashableOperators[i]] =
        s_operatorStakingPool.getStakerPrincipal(slashableOperators[i]);
    }

    changePrank(COMMUNITY_STAKER_ONE);
    s_alertsController.raiseAlert(address(FEED));
    changePrank(OWNER);
    s_alertsController.toggleRaisable();
  }

  function _validateAlertConditionCannotBeRaised() private {
    assertFalse(s_alertsController.canAlert(COMMUNITY_STAKER_ONE, address(FEED)));
    assertFalse(s_alertsController.canAlert(OPERATOR_STAKER_ONE, address(FEED)));

    changePrank(COMMUNITY_STAKER_ONE);
    vm.expectRevert(AlertsController.AlertInvalid.selector);
    s_alertsController.raiseAlert(address(FEED));
  }

  function _validateAlertConditionCanBeRaised() private {
    assertTrue(s_alertsController.canAlert(COMMUNITY_STAKER_ONE, address(FEED)));
    assertTrue(s_alertsController.canAlert(OPERATOR_STAKER_ONE, address(FEED)));
  }

  function _validateAfterAlertConditionIsRaised() private {
    // validate balances after slashing
    assertEq(s_LINK.balanceOf(COMMUNITY_STAKER_ONE), s_alerterBalance + ALERT_REWARD_AMOUNT);
    address[] memory slashableOperators = _getSlashableOperators();
    for (uint256 i; i < slashableOperators.length; ++i) {
      assertEq(
        s_operatorStakingPool.getStakerPrincipal(slashableOperators[i]),
        s_slashableOperatorsBalances[slashableOperators[i]] - ALERT_SLASHABLE_AMOUNT
      );
    }

    assertFalse(s_alertsController.canAlert(COMMUNITY_STAKER_ONE, address(FEED)));
    assertFalse(s_alertsController.canAlert(OPERATOR_STAKER_ONE, address(FEED)));
  }
}
