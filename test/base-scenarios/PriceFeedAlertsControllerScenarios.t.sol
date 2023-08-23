// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {BaseTest} from '../BaseTest.t.sol';
import {AggregatorV3Interface} from
  '@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol';
import {ISlashable} from '../../src/interfaces/ISlashable.sol';
import {OperatorStakingPool} from '../../src/pools/OperatorStakingPool.sol';
import {PriceFeedAlertsController} from '../../src/alerts/PriceFeedAlertsController.sol';

abstract contract PriceFeedAlertsController_WithConfiguredPriceFeedAlertsController is BaseTest {
  PriceFeedAlertsController internal s_pfAlertsController;

  uint256 internal s_timeFeedGoesDown;

  function setUp() public virtual override {
    BaseTest.setUp();

    changePrank(OWNER);
    s_pfAlertsController = new PriceFeedAlertsController(
      PriceFeedAlertsController.ConstructorParams({
        communityStakingPool: s_communityStakingPool,
        operatorStakingPool: s_operatorStakingPool,
        feedConfigs: _getFeedConfigsForConstructor(),
        adminRoleTransferDelay: ADMIN_ROLE_TRANSFER_DELAY
      })
    );

    s_pfAlertsController.grantRole(s_pfAlertsController.PAUSER_ROLE(), PAUSER);
  }

  function _getFeedConfigs()
    internal
    pure
    returns (PriceFeedAlertsController.SetFeedConfigParams[] memory)
  {
    PriceFeedAlertsController.SetFeedConfigParams[] memory configs =
      new PriceFeedAlertsController.SetFeedConfigParams[](1);
    configs[0] = PriceFeedAlertsController.SetFeedConfigParams({
      feed: address(FEED),
      priorityPeriodThreshold: PRIORITY_PERIOD_THRESHOLD_SECONDS,
      regularPeriodThreshold: REGULAR_PERIOD_THRESHOLD_SECONDS,
      slashableAmount: FEED_SLASHABLE_AMOUNT,
      alerterRewardAmount: ALERTER_REWARD_AMOUNT
    });
    return configs;
  }

  function _getFeedConfigsForConstructor()
    internal
    pure
    returns (PriceFeedAlertsController.ConstructorFeedConfigParams[] memory)
  {
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
    return configs;
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

abstract contract PriceFeedAlertsController_WithStakers is
  PriceFeedAlertsController_WithConfiguredPriceFeedAlertsController
{
  function setUp() public virtual override {
    PriceFeedAlertsController_WithConfiguredPriceFeedAlertsController.setUp();

    changePrank(OWNER);
    s_rewardVault.grantRole(s_rewardVault.REWARDER_ROLE(), REWARDER);

    // Have all 31 OPERATORs stake
    address[] memory operators = _getDefaultOperators();
    s_operatorStakingPool.addOperators(operators);
    s_operatorStakingPool.open();
    s_communityStakingPool.open();

    changePrank(REWARDER);
    s_rewardVault.addReward(address(0), REWARD_AMOUNT, EMISSION_RATE);

    // stake as users
    s_stakedAtTime = block.timestamp;
    changePrank(COMMUNITY_STAKER_ONE);
    s_LINK.transferAndCall(
      address(s_communityStakingPool),
      COMMUNITY_MIN_PRINCIPAL,
      abi.encode(s_communityStakerOneProof)
    );
    changePrank(COMMUNITY_STAKER_TWO);
    s_LINK.transferAndCall(
      address(s_communityStakingPool),
      COMMUNITY_MIN_PRINCIPAL,
      abi.encode(s_communityStakerTwoProof)
    );
    changePrank(OPERATOR_STAKER_ONE);
    s_LINK.transferAndCall(address(s_operatorStakingPool), OPERATOR_MIN_PRINCIPAL, '');
    changePrank(OPERATOR_STAKER_TWO);
    s_LINK.transferAndCall(address(s_operatorStakingPool), OPERATOR_MIN_PRINCIPAL, '');
  }

  // This is needed so that "forge coverage" will ignore this contract
  function test() public virtual override {}
}

abstract contract PriceFeedAlertsController_WhenPoolOpen is PriceFeedAlertsController_WithStakers {
  function setUp() public virtual override {
    PriceFeedAlertsController_WithStakers.setUp();
    // Make feed go down 2 weeks after all the operators have staked
    // so that operators have some rewards slashed.
    s_timeFeedGoesDown = block.timestamp + 14 days;
    skip(14 days);
    vm.mockCall(
      address(FEED),
      abi.encodeWithSelector(AggregatorV3Interface.latestRoundData.selector),
      abi.encode(ROUND_ID, int256(0), uint128(0), uint128(s_timeFeedGoesDown), uint80(0))
    );
    skip(PRIORITY_PERIOD_THRESHOLD_SECONDS + 1);

    changePrank(OWNER);
  }

  // This is needed so that "forge coverage" will ignore this contract
  function test() public virtual override {}
}

abstract contract PriceFeedAlertsController_WithSlasherRole is
  PriceFeedAlertsController_WhenPoolOpen
{
  function setUp() public virtual override {
    PriceFeedAlertsController_WhenPoolOpen.setUp();

    changePrank(OWNER);
    s_operatorStakingPool.addSlasher(
      address(s_pfAlertsController),
      ISlashable.SlasherConfig({refillRate: SLASH_REFILL_RATE, slashCapacity: SLASH_MAX_AMOUNT})
    );

    s_pfAlertsController.setSlashableOperators(_getSlashableOperators(), address(FEED));
  }

  // This is needed so that "forge coverage" will ignore this contract
  function test() public virtual override {}
}

abstract contract PriceFeedAlertsController_WithAllOperatorsAsSlashable is
  PriceFeedAlertsController_WithSlasherRole
{
  function setUp() public virtual override {
    PriceFeedAlertsController_WithSlasherRole.setUp();

    changePrank(OWNER);
    s_pfAlertsController.setSlashableOperators(_getDefaultOperators(), address(FEED));
  }

  // This is needed so that "forge coverage" will ignore this contract
  function test() public virtual override {}
}

abstract contract PriceFeedAlertsController_WithSlasherRoleAndMaxStakedAmount is
  PriceFeedAlertsController_WithSlasherRole
{
  function setUp() public virtual override {
    PriceFeedAlertsController_WithSlasherRole.setUp();

    // top up operators stake to max
    changePrank(OPERATOR_STAKER_ONE);
    s_LINK.transferAndCall(
      address(s_operatorStakingPool),
      OPERATOR_MAX_PRINCIPAL - s_operatorStakingPool.getStakerPrincipal(OPERATOR_STAKER_ONE),
      ''
    );
    changePrank(OPERATOR_STAKER_TWO);
    s_LINK.transferAndCall(
      address(s_operatorStakingPool),
      OPERATOR_MAX_PRINCIPAL - s_operatorStakingPool.getStakerPrincipal(OPERATOR_STAKER_TWO),
      ''
    );
  }

  // This is needed so that "forge coverage" will ignore this contract
  function test() public virtual override {}
}

abstract contract PriceFeedAlertsController_WithSlasherRoleAndMaxMultipliers is
  PriceFeedAlertsController_WithStakers
{
  function setUp() public virtual override {
    PriceFeedAlertsController_WithStakers.setUp();

    changePrank(OWNER);
    s_operatorStakingPool.addSlasher(
      address(s_pfAlertsController),
      ISlashable.SlasherConfig({refillRate: SLASH_REFILL_RATE, slashCapacity: SLASH_MAX_AMOUNT})
    );
    s_pfAlertsController.setSlashableOperators(_getSlashableOperators(), address(FEED));

    // Make the multipliers grow to max
    skip(INITIAL_MULTIPLIER_DURATION);

    // Make feed go down 2 weeks after all the operators have staked
    // so that operators have some rewards slashed.
    s_timeFeedGoesDown = block.timestamp + 14 days;
    skip(14 days);
    vm.mockCall(
      address(FEED),
      abi.encodeWithSelector(AggregatorV3Interface.latestRoundData.selector),
      abi.encode(ROUND_ID, int256(0), uint128(0), uint128(s_timeFeedGoesDown), uint80(0))
    );
    skip(PRIORITY_PERIOD_THRESHOLD_SECONDS + 1);

    changePrank(OWNER);
  }

  // This is needed so that "forge coverage" will ignore this contract
  function test() public virtual override {}
}

abstract contract PriceFeedAlertsController_WhenPoolNotOpen is
  PriceFeedAlertsController_WithConfiguredPriceFeedAlertsController
{
  function setUp() public virtual override {
    PriceFeedAlertsController_WithConfiguredPriceFeedAlertsController.setUp();

    changePrank(OWNER);
    s_operatorStakingPool.addSlasher(
      address(s_pfAlertsController),
      ISlashable.SlasherConfig({refillRate: SLASH_REFILL_RATE, slashCapacity: SLASH_MAX_AMOUNT})
    );
  }

  // This is needed so that "forge coverage" will ignore this contract
  function test() public virtual override {}
}

abstract contract PriceFeedAlertsController_WhenAlertHasBeenRaisedInPriorityRound is
  PriceFeedAlertsController_WithSlasherRole
{
  function setUp() public virtual override {
    PriceFeedAlertsController_WithSlasherRole.setUp();
    vm.warp(s_timeFeedGoesDown + REGULAR_PERIOD_THRESHOLD_SECONDS + 1);
    changePrank(OPERATOR_STAKER_ONE);
    // to prevent a complete slash
    s_LINK.transferAndCall(address(s_operatorStakingPool), FEED_SLASHABLE_AMOUNT, '');
    s_pfAlertsController.raiseAlert(address(FEED));
  }

  // This is needed so that "forge coverage" will ignore this contract
  function test() public virtual override {}
}

abstract contract PriceFeedAlertsController_WhenAlertHasBeenRaisedInRegularRound is
  PriceFeedAlertsController_WithSlasherRole
{
  function setUp() public virtual override {
    PriceFeedAlertsController_WithSlasherRole.setUp();
    vm.warp(s_timeFeedGoesDown + REGULAR_PERIOD_THRESHOLD_SECONDS + 1);
    changePrank(OPERATOR_STAKER_ONE);
    // to prevent a complete slash
    s_LINK.transferAndCall(address(s_operatorStakingPool), FEED_SLASHABLE_AMOUNT, '');
    changePrank(COMMUNITY_STAKER_ONE);
    s_pfAlertsController.raiseAlert(address(FEED));
  }

  // This is needed so that "forge coverage" will ignore this contract
  function test() public virtual override {}
}
