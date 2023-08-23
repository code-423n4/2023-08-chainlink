// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {AggregatorV3Interface} from
  '@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol';

import {PriceFeedAlertsController} from '../../../src/alerts/PriceFeedAlertsController.sol';
import {IStakingOwner} from '../../../src/interfaces/IStakingOwner.sol';
import {RewardVault} from '../../../src/rewards/RewardVault.sol';
import {StakingPoolBase} from '../../../src/pools/StakingPoolBase.sol';
import {
  PriceFeedAlertsController_WithSlasherRole,
  PriceFeedAlertsController_WithSlasherRoleAndMaxMultipliers,
  PriceFeedAlertsController_WhenPoolOpen
} from '../../base-scenarios/PriceFeedAlertsControllerScenarios.t.sol';

contract PriceFeedAlertsController_RaiseAlert_WithoutSlasherRole is
  PriceFeedAlertsController_WhenPoolOpen
{
  function test_RevertWhen_AlertIsRaised() public {
    vm.expectRevert(PriceFeedAlertsController.AlertInvalid.selector);
    changePrank(OPERATOR_STAKER_ONE);
    s_pfAlertsController.raiseAlert(address(FEED));
  }
}

contract PriceFeedAlertsController_RaiseAlert_WithSlasherRole is
  PriceFeedAlertsController_WithSlasherRole
{
  function test_RevertWhen_FeedNotRegistered() public {
    changePrank(OWNER);
    AggregatorV3Interface randomFeed = AggregatorV3Interface(address(STRANGER));
    vm.mockCall(
      address(randomFeed),
      abi.encodeWithSelector(AggregatorV3Interface.latestRoundData.selector),
      abi.encode(uint80(1), int256(0), uint128(0), uint128(0), uint80(0))
    );
    vm.expectRevert(PriceFeedAlertsController.AlertInvalid.selector);
    changePrank(OPERATOR_STAKER_ONE);
    s_pfAlertsController.raiseAlert(address(randomFeed));
  }

  function test_RevertWhen_CalledByOperatorStakersAndFeedNotStale() public {
    uint256 timeFeedGoesDown = block.timestamp + 14 days;
    skip(14 days);
    vm.mockCall(
      address(FEED),
      abi.encodeWithSelector(AggregatorV3Interface.latestRoundData.selector),
      abi.encode(uint80(1), int256(0), uint128(0), uint128(timeFeedGoesDown), uint80(0))
    );
    skip(PRIORITY_PERIOD_THRESHOLD_SECONDS - 1);
    vm.expectRevert(PriceFeedAlertsController.AlertInvalid.selector);
    changePrank(OPERATOR_STAKER_ONE);
    s_pfAlertsController.raiseAlert(address(FEED));
  }

  function test_RevertWhen_CalledByCommunityStakersAndFeedNotStale() public {
    uint256 timeFeedGoesDown = block.timestamp + 14 days;
    skip(14 days);
    vm.mockCall(
      address(FEED),
      abi.encodeWithSelector(AggregatorV3Interface.latestRoundData.selector),
      abi.encode(uint80(1), int256(0), uint128(0), uint128(timeFeedGoesDown), uint80(0))
    );
    skip(PRIORITY_PERIOD_THRESHOLD_SECONDS - 1);
    vm.expectRevert(PriceFeedAlertsController.AlertInvalid.selector);
    changePrank(COMMUNITY_STAKER_ONE);
    s_pfAlertsController.raiseAlert(address(FEED));
  }
}

contract PriceFeedAlertsController_RaiseAlert_WhenPoolNotOpen is
  PriceFeedAlertsController_WithSlasherRole
{
  function setUp() public override {
    PriceFeedAlertsController_WithSlasherRole.setUp();

    changePrank(OWNER);
    s_operatorStakingPool.close();
  }

  function test_RevertsWhen_OperatorStakingPoolNotActive() public {
    vm.expectRevert(StakingPoolBase.PoolNotActive.selector);
    changePrank(OPERATOR_STAKER_ONE);
    s_pfAlertsController.raiseAlert(address(FEED));
  }
}

contract PriceFeedAlertsController_RaiseAlert_InPriorityPeriod is
  PriceFeedAlertsController_WithSlasherRole
{
  event AlertRaised(address indexed alerter, uint256 indexed roundId, uint96 rewardAmount);

  function test_EmitsEventWhenCalledByOperatorStakers() public {
    vm.expectEmit(true, true, true, true, address(s_pfAlertsController));
    emit AlertRaised(OPERATOR_STAKER_ONE, ROUND_ID, ALERTER_REWARD_AMOUNT);
    changePrank(OPERATOR_STAKER_ONE);
    s_pfAlertsController.raiseAlert(address(FEED));
  }

  function test_SlashesOperatorsAndRewardsAlerter() public {
    address[] memory operators = _getSlashableOperators();
    uint256[] memory rewards = new uint256[](operators.length);
    uint256[] memory delegatedRewards = new uint256[](operators.length);
    for (uint256 i; i < operators.length; ++i) {
      assertLt(s_rewardVault.getMultiplier(operators[i]), MAX_MULTIPLIER);
      rewards[i] = s_rewardVault.getReward(operators[i]);
      (RewardVault.StakerReward memory stakerReward,) =
        s_rewardVault.calculateLatestStakerReward(operators[i]);
      delegatedRewards[i] = stakerReward.finalizedDelegatedReward;
    }

    uint256 alerterLINKBalanceBefore = s_LINK.balanceOf(OPERATOR_STAKER_ONE);
    uint256 operatorStakedAmountBefore =
      s_operatorStakingPool.getStakerPrincipal(OPERATOR_STAKER_ONE);
    uint256 expectedStakedAmountAfter = FEED_SLASHABLE_AMOUNT > operatorStakedAmountBefore
      ? 0
      : operatorStakedAmountBefore - FEED_SLASHABLE_AMOUNT;
    changePrank(OPERATOR_STAKER_ONE);
    s_pfAlertsController.raiseAlert(address(FEED));
    assertEq(
      s_LINK.balanceOf(OPERATOR_STAKER_ONE), alerterLINKBalanceBefore + ALERTER_REWARD_AMOUNT
    );
    assertEq(
      s_operatorStakingPool.getStakerPrincipal(OPERATOR_STAKER_ONE), expectedStakedAmountAfter
    );

    // Make multipliers reach max
    skip(INITIAL_MULTIPLIER_DURATION);
    for (uint256 i; i < operators.length; ++i) {
      // claimable rewards have increased because of the multiplier
      assertGt(s_rewardVault.getReward(operators[i]), rewards[i]);
      // delegated rewards did not change
      (RewardVault.StakerReward memory stakerReward,) =
        s_rewardVault.calculateLatestStakerReward(operators[i]);
      assertEq(stakerReward.finalizedDelegatedReward, delegatedRewards[i]);
    }
  }

  function test_RevertWhen_CalledByCommunityStakers() public {
    vm.expectRevert(PriceFeedAlertsController.AlertInvalid.selector);
    changePrank(COMMUNITY_STAKER_ONE);
    s_pfAlertsController.raiseAlert(address(FEED));
  }

  function test_RevertWhen_CalledByANonStaker() public {
    vm.expectRevert(PriceFeedAlertsController.AlertInvalid.selector);
    changePrank(STRANGER);
    s_pfAlertsController.raiseAlert(address(FEED));
  }
}

contract PriceFeedAlertsController_RaiseAlert_InRegularPeriod is
  PriceFeedAlertsController_WithSlasherRole
{
  event AlertRaised(address indexed alerter, uint256 indexed roundId, uint96 rewardAmount);

  function setUp() public override {
    PriceFeedAlertsController_WithSlasherRole.setUp();

    vm.warp(s_timeFeedGoesDown + REGULAR_PERIOD_THRESHOLD_SECONDS + 1);
  }

  function test_EmitsEventWhenCalledByOperatorStakers() public {
    vm.expectEmit(true, true, true, true, address(s_pfAlertsController));
    emit AlertRaised(OPERATOR_STAKER_ONE, ROUND_ID, ALERTER_REWARD_AMOUNT);
    changePrank(OPERATOR_STAKER_ONE);
    s_pfAlertsController.raiseAlert(address(FEED));
  }

  function test_EmitsEventWhenCalledByCommunityStakers() public {
    vm.expectEmit(true, true, true, true, address(s_pfAlertsController));
    emit AlertRaised(COMMUNITY_STAKER_ONE, ROUND_ID, ALERTER_REWARD_AMOUNT);
    changePrank(COMMUNITY_STAKER_ONE);
    s_pfAlertsController.raiseAlert(address(FEED));
  }

  function test_SlashesOperatorsAndRewardsAlerterWhenCalledByOperatorStakers() public {
    uint256 alerterLINKBalanceBefore = s_LINK.balanceOf(OPERATOR_STAKER_ONE);
    uint256 operatorStakedAmountBefore =
      s_operatorStakingPool.getStakerPrincipal(OPERATOR_STAKER_ONE);
    uint256 expectedStakedAmountAfter = FEED_SLASHABLE_AMOUNT > operatorStakedAmountBefore
      ? 0
      : operatorStakedAmountBefore - FEED_SLASHABLE_AMOUNT;
    changePrank(OPERATOR_STAKER_ONE);
    s_pfAlertsController.raiseAlert(address(FEED));
    assertEq(
      s_LINK.balanceOf(OPERATOR_STAKER_ONE), alerterLINKBalanceBefore + ALERTER_REWARD_AMOUNT
    );
    assertEq(
      s_operatorStakingPool.getStakerPrincipal(OPERATOR_STAKER_ONE), expectedStakedAmountAfter
    );
  }

  function test_SlashesOperatorsAndRewardsAlerterWhenCalledByCommunityStakers() public {
    uint256 alerterLINKBalanceBefore = s_LINK.balanceOf(COMMUNITY_STAKER_ONE);
    uint256 operatorStakedAmountBefore =
      s_operatorStakingPool.getStakerPrincipal(OPERATOR_STAKER_ONE);
    uint256 expectedStakedAmountAfter = FEED_SLASHABLE_AMOUNT > operatorStakedAmountBefore
      ? 0
      : operatorStakedAmountBefore - FEED_SLASHABLE_AMOUNT;
    changePrank(COMMUNITY_STAKER_ONE);
    s_pfAlertsController.raiseAlert(address(FEED));
    assertEq(
      s_LINK.balanceOf(COMMUNITY_STAKER_ONE), alerterLINKBalanceBefore + ALERTER_REWARD_AMOUNT
    );
    assertEq(
      s_operatorStakingPool.getStakerPrincipal(OPERATOR_STAKER_ONE), expectedStakedAmountAfter
    );
  }

  function test_RevertWhen_CalledByANonStaker() public {
    vm.expectRevert(PriceFeedAlertsController.AlertInvalid.selector);
    changePrank(STRANGER);
    s_pfAlertsController.raiseAlert(address(FEED));
  }
}

contract PriceFeedAlertsController_RaiseAlert_AfterMultiplierReachesMax is
  PriceFeedAlertsController_WithSlasherRoleAndMaxMultipliers
{
  function test_RewardDoesNotGrowAfterSlashedAndMultipleirReachesMax() public {
    address[] memory operators = _getSlashableOperators();
    uint256[] memory rewards = new uint256[](operators.length);

    for (uint256 i; i < operators.length; ++i) {
      assertEq(s_rewardVault.getMultiplier(operators[i]), MAX_MULTIPLIER);
      rewards[i] = s_rewardVault.getReward(operators[i]);
    }

    changePrank(OPERATOR_STAKER_ONE);
    s_pfAlertsController.raiseAlert(address(FEED));

    for (uint256 i; i < operators.length; ++i) {
      assertEq(s_rewardVault.getReward(operators[i]), rewards[i]);
    }

    skip(10 days);

    for (uint256 i; i < operators.length; ++i) {
      assertEq(s_rewardVault.getReward(operators[i]), rewards[i]);
    }
  }
}
