// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {AggregatorV3Interface} from
  '@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol';

import {
  PriceFeedAlertsController_WithSlasherRole,
  PriceFeedAlertsController_WhenPoolOpen,
  PriceFeedAlertsController_WhenPoolNotOpen,
  PriceFeedAlertsController_WhenAlertHasBeenRaisedInRegularRound,
  PriceFeedAlertsController_WhenAlertHasBeenRaisedInPriorityRound
} from '../../base-scenarios/PriceFeedAlertsControllerScenarios.t.sol';
import {RewardVault} from '../../../src/rewards/RewardVault.sol';

contract PriceFeedAlertsController_CanAlert_WithoutSlasherRole is
  PriceFeedAlertsController_WhenPoolOpen
{
  function test_CanAlertReturnsFalse() public {
    assertEq(s_pfAlertsController.canAlert(OPERATOR_STAKER_ONE, address(FEED)), false);
  }
}

contract PriceFeedAlertsController_CanAlert_WithSlasherRole is
  PriceFeedAlertsController_WithSlasherRole
{
  function test_CanAlertReturnsFalseIfFeedNotRegistered() public {
    changePrank(OWNER);
    AggregatorV3Interface randomFeed = AggregatorV3Interface(address(STRANGER));
    vm.mockCall(
      address(randomFeed),
      abi.encodeWithSelector(AggregatorV3Interface.latestRoundData.selector),
      abi.encode(uint80(1), int256(0), uint128(0), uint128(0), uint80(0))
    );
    assertEq(s_pfAlertsController.canAlert(OPERATOR_STAKER_ONE, address(randomFeed)), false);
  }

  function test_CanAlertReturnsFalseForOperatorStakersIfFeedNotStale() public {
    uint256 timeFeedGoesDown = block.timestamp + 14 days;
    vm.warp(timeFeedGoesDown);
    vm.mockCall(
      address(FEED),
      abi.encodeWithSelector(AggregatorV3Interface.latestRoundData.selector),
      abi.encode(uint80(1), int256(0), uint128(0), uint128(timeFeedGoesDown), uint80(0))
    );
    vm.warp(timeFeedGoesDown + PRIORITY_PERIOD_THRESHOLD_SECONDS - 1);
    assertEq(s_pfAlertsController.canAlert(OPERATOR_STAKER_ONE, address(FEED)), false);
  }

  function test_CanAlertReturnsFalseForCommunityStakersIfFeedNotStale() public {
    uint256 timeFeedGoesDown = block.timestamp + 14 days;
    vm.warp(timeFeedGoesDown);
    vm.mockCall(
      address(FEED),
      abi.encodeWithSelector(AggregatorV3Interface.latestRoundData.selector),
      abi.encode(uint80(1), int256(0), uint128(0), uint128(timeFeedGoesDown), uint80(0))
    );
    vm.warp(timeFeedGoesDown + PRIORITY_PERIOD_THRESHOLD_SECONDS - 1);
    assertEq(s_pfAlertsController.canAlert(COMMUNITY_STAKER_ONE, address(FEED)), false);
  }
}

contract PriceFeedAlertsController_CanAlert_WhenPoolNotOpen is
  PriceFeedAlertsController_WhenPoolNotOpen
{
  function test_canAlertReturnsFalseIfStakingPoolNotOpen() public {
    vm.mockCall(
      address(FEED),
      abi.encodeWithSelector(AggregatorV3Interface.latestRoundData.selector),
      abi.encode(uint80(1), int256(0), uint128(0), uint128(0), uint80(0))
    );
    assertEq(s_pfAlertsController.canAlert(OPERATOR_STAKER_ONE, address(FEED)), false);
  }
}

contract PriceFeedAlertsController_CanAlert_WhenPoolNotEmittingRewards is
  PriceFeedAlertsController_WithSlasherRole
{
  function test_canAlertReturnsFalseIfStakingPoolNotEmittingRewards() public {
    RewardVault.RewardBuckets memory buckets = s_rewardVault.getRewardBuckets();
    vm.warp(buckets.operatorBase.rewardDurationEndsAt - 1);
    assertEq(s_pfAlertsController.canAlert(OPERATOR_STAKER_ONE, address(FEED)), true);
    skip(1);
    assertEq(s_pfAlertsController.canAlert(OPERATOR_STAKER_ONE, address(FEED)), false);
  }
}

contract PriceFeedAlertsController_CanAlert_InPriorityPeriod is
  PriceFeedAlertsController_WithSlasherRole
{
  function test_CanAlertReturnsTrueForOperatorStakers() public {
    assertEq(s_pfAlertsController.canAlert(OPERATOR_STAKER_ONE, address(FEED)), true);
  }

  function test_CanAlertReturnsFalseForCommunityStakers() public {
    assertEq(s_pfAlertsController.canAlert(COMMUNITY_STAKER_ONE, address(FEED)), false);
  }

  function test_CanAlertReturnsFalseIfPaused() public {
    assertEq(s_pfAlertsController.canAlert(OPERATOR_STAKER_ONE, address(FEED)), true);
    changePrank(PAUSER);
    s_pfAlertsController.emergencyPause();
    assertEq(s_pfAlertsController.canAlert(OPERATOR_STAKER_ONE, address(FEED)), false);
  }
}

contract PriceFeedAlertsController_CanAlert_InRegularPeriod is
  PriceFeedAlertsController_WithSlasherRole
{
  function setUp() public override {
    PriceFeedAlertsController_WithSlasherRole.setUp();

    vm.warp(s_timeFeedGoesDown + REGULAR_PERIOD_THRESHOLD_SECONDS + 1);
  }

  function test_CanAlertReturnsTrueForOperatorStakers() public {
    assertEq(s_pfAlertsController.canAlert(OPERATOR_STAKER_ONE, address(FEED)), true);
  }

  function test_CanAlertReturnsTrueForCommunityStakers() public {
    assertEq(s_pfAlertsController.canAlert(COMMUNITY_STAKER_ONE, address(FEED)), true);
  }

  function test_CanAlertReturnsFalseIfNotStaker() public {
    changePrank(STRANGER);
    assertEq(s_pfAlertsController.canAlert(STRANGER, address(FEED)), false);
  }

  function test_CanAlertReturnsFalseIfPaused() public {
    assertEq(s_pfAlertsController.canAlert(COMMUNITY_STAKER_ONE, address(FEED)), true);
    changePrank(PAUSER);
    s_pfAlertsController.emergencyPause();
    assertEq(s_pfAlertsController.canAlert(COMMUNITY_STAKER_ONE, address(FEED)), false);
  }
}

contract PriceFeedAlertsController_CanAlert_WhenAlertHasBeenRaisedHasBeenRaisedInPriorityRound is
  PriceFeedAlertsController_WhenAlertHasBeenRaisedInPriorityRound
{
  function test_CanAlertReturnsFalseForOperatorStakers() public {
    assertEq(s_pfAlertsController.canAlert(OPERATOR_STAKER_ONE, address(FEED)), false);
  }

  function test_CanAlertReturnsFalseForCommunityStakers() public {
    assertEq(s_pfAlertsController.canAlert(COMMUNITY_STAKER_ONE, address(FEED)), false);
  }

  function test_CanAlertReturnsFalseForOperatorStakersWhenFeedRoundIDDecreases() public {
    vm.mockCall(
      address(FEED),
      abi.encodeWithSelector(AggregatorV3Interface.latestRoundData.selector),
      abi.encode(ROUND_ID - 1, int256(0), uint128(0), uint128(s_timeFeedGoesDown), uint80(0))
    );
    assertEq(s_pfAlertsController.canAlert(OPERATOR_STAKER_ONE, address(FEED)), false);
  }

  function test_CanAlertReturnsFalseForCommunityStakersWhenFeedRoundIDDecreases() public {
    vm.mockCall(
      address(FEED),
      abi.encodeWithSelector(AggregatorV3Interface.latestRoundData.selector),
      abi.encode(ROUND_ID - 1, int256(0), uint128(0), uint128(s_timeFeedGoesDown), uint80(0))
    );
    assertEq(s_pfAlertsController.canAlert(COMMUNITY_STAKER_ONE, address(FEED)), false);
  }

  function test_CanAlertReturnsTrueForOperatorStakersWhenFeedRoundIDIncreases() public {
    vm.mockCall(
      address(FEED),
      abi.encodeWithSelector(AggregatorV3Interface.latestRoundData.selector),
      abi.encode(ROUND_ID + 1, int256(0), uint128(0), uint128(s_timeFeedGoesDown), uint80(0))
    );
    assertEq(s_pfAlertsController.canAlert(OPERATOR_STAKER_ONE, address(FEED)), true);
  }

  function test_CanAlertReturnsTrueForCommunityStakersWhenFeedRoundIDIncreases() public {
    vm.mockCall(
      address(FEED),
      abi.encodeWithSelector(AggregatorV3Interface.latestRoundData.selector),
      abi.encode(ROUND_ID + 1, int256(0), uint128(0), uint128(s_timeFeedGoesDown), uint80(0))
    );
    assertEq(s_pfAlertsController.canAlert(COMMUNITY_STAKER_ONE, address(FEED)), true);
  }
}

contract PriceFeedAlertsController_CanAlert_WhenAlertHasBeenRaisedInRegularRound is
  PriceFeedAlertsController_WhenAlertHasBeenRaisedInRegularRound
{
  function test_CanAlertReturnsFalseForOperatorStakers() public {
    assertEq(s_pfAlertsController.canAlert(OPERATOR_STAKER_ONE, address(FEED)), false);
  }

  function test_CanAlertReturnsFalseForCommunityStakers() public {
    assertEq(s_pfAlertsController.canAlert(COMMUNITY_STAKER_ONE, address(FEED)), false);
  }

  function test_CanAlertReturnsFalseForOperatorStakersWhenFeedRoundIDDecreases() public {
    vm.mockCall(
      address(FEED),
      abi.encodeWithSelector(AggregatorV3Interface.latestRoundData.selector),
      abi.encode(ROUND_ID - 1, int256(0), uint128(0), uint128(s_timeFeedGoesDown), uint80(0))
    );
    assertEq(s_pfAlertsController.canAlert(OPERATOR_STAKER_ONE, address(FEED)), false);
  }

  function test_CanAlertReturnsFalseForCommunityStakersWhenFeedRoundIDDecreases() public {
    vm.mockCall(
      address(FEED),
      abi.encodeWithSelector(AggregatorV3Interface.latestRoundData.selector),
      abi.encode(ROUND_ID - 1, int256(0), uint128(0), uint128(s_timeFeedGoesDown), uint80(0))
    );
    assertEq(s_pfAlertsController.canAlert(COMMUNITY_STAKER_ONE, address(FEED)), false);
  }

  function test_CanAlertReturnsTrueForOperatorStakersWhenFeedRoundIDIncreases() public {
    vm.mockCall(
      address(FEED),
      abi.encodeWithSelector(AggregatorV3Interface.latestRoundData.selector),
      abi.encode(ROUND_ID + 1, int256(0), uint128(0), uint128(s_timeFeedGoesDown), uint80(0))
    );
    assertEq(s_pfAlertsController.canAlert(OPERATOR_STAKER_ONE, address(FEED)), true);
  }

  function test_CanAlertReturnsTrueForCommunityStakersWhenFeedRoundIDIncreases() public {
    vm.mockCall(
      address(FEED),
      abi.encodeWithSelector(AggregatorV3Interface.latestRoundData.selector),
      abi.encode(ROUND_ID + 1, int256(0), uint128(0), uint128(s_timeFeedGoesDown), uint80(0))
    );
    assertEq(s_pfAlertsController.canAlert(COMMUNITY_STAKER_ONE, address(FEED)), true);
  }
}
