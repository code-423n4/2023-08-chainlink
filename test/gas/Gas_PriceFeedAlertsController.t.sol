// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {PriceFeedAlertsController_WithAllOperatorsAsSlashable} from
  '../base-scenarios/PriceFeedAlertsControllerScenarios.t.sol';

contract Gas_PriceFeedAlertsController_InRegularPeriod is
  PriceFeedAlertsController_WithAllOperatorsAsSlashable
{
  function setUp() public override {
    PriceFeedAlertsController_WithAllOperatorsAsSlashable.setUp();
    changePrank(OPERATOR_STAKER_ONE);
  }

  function test_Gas_RaiseAlertInRegularPeriod() public {
    s_pfAlertsController.raiseAlert(address(FEED));
  }
}

contract Gas_PriceFeedAlertsController_InPriorityPeriod is
  PriceFeedAlertsController_WithAllOperatorsAsSlashable
{
  function setUp() public override {
    PriceFeedAlertsController_WithAllOperatorsAsSlashable.setUp();
    skip(REGULAR_PERIOD_THRESHOLD_SECONDS + 1);
    changePrank(COMMUNITY_STAKER_ONE);
  }

  function test_Gas_RaiseAlertInPriorityPeriod() public {
    s_pfAlertsController.raiseAlert(address(FEED));
  }
}
