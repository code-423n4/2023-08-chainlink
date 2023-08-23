// forge script scripts/DeployPriceFeedAlertsController.s.sol:Run --broadcast -vvvv --rpc-url
// $RPC_URL
// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import 'forge-std/Script.sol';

import {LinkTokenInterface} from '@chainlink/contracts/src/v0.8/interfaces/LinkTokenInterface.sol';

import {PriceFeedAlertsController} from '../src/alerts/PriceFeedAlertsController.sol';
import {ISlashable} from '../src/interfaces/ISlashable.sol';
import {OperatorStakingPool} from '../src/pools/OperatorStakingPool.sol';
import {CommunityStakingPool} from '../src/pools/CommunityStakingPool.sol';
import {StakingPoolBase} from '../src/pools/StakingPoolBase.sol';
import {BaseScenario} from './BaseScenario.s.sol';

contract Run is BaseScenario {
  function setUp() public {}

  function run() public {
    uint256 deployerPrivateKey = vm.envUint('PRIVATE_KEY');
    vm.startBroadcast(deployerPrivateKey);
    address deployer = vm.addr(deployerPrivateKey);

    console.log('Deploying PriceFeedAlertsController... (deployer: %s)', deployer);

    // Load config
    string memory key = 'OPERATORS';
    string memory delimiter = ',';
    address[] memory OPERATORS = vm.envAddress(key, delimiter);

    address ethUsdFeed = vm.envAddress('ETH_USD_FEED');
    s_operatorStakingPool = OperatorStakingPool(vm.envAddress('OPERATOR_STAKING_POOL'));

    // Deploy PFAC
    PriceFeedAlertsController.ConstructorFeedConfigParams[] memory configs =
      new PriceFeedAlertsController.ConstructorFeedConfigParams[](1);
    configs[0] = PriceFeedAlertsController.ConstructorFeedConfigParams({
      feed: ethUsdFeed,
      priorityPeriodThreshold: PRIORITY_PERIOD_THRESHOLD_SECONDS,
      regularPeriodThreshold: REGULAR_PERIOD_THRESHOLD_SECONDS,
      slashableAmount: FEED_SLASHABLE_AMOUNT,
      alerterRewardAmount: ALERTER_REWARD_AMOUNT,
      slashableOperators: OPERATORS
    });
    s_alertsController = new PriceFeedAlertsController(
      PriceFeedAlertsController.ConstructorParams({
        communityStakingPool: CommunityStakingPool(vm.envAddress('COMMUNITY_STAKING_POOL')),
        operatorStakingPool: s_operatorStakingPool,
        feedConfigs: configs,
        adminRoleTransferDelay: ADMIN_ROLE_TRANSFER_DELAY
      })
    );

    s_alertsController.grantRole(s_alertsController.PAUSER_ROLE(), deployer);

    s_operatorStakingPool.addSlasher(
      address(s_alertsController),
      ISlashable.SlasherConfig({refillRate: SLASH_REFILL_RATE, slashCapacity: SLASH_MAX_AMOUNT})
    );
    s_alertsController.setSlashableOperators(OPERATORS, ethUsdFeed);

    address alertsController = vm.envOr('PF_ALERTS_CONTROLLER', address(0));
    if (alertsController != address(s_alertsController)) {
      vm.writeLine(
        '.env', string.concat('PF_ALERTS_CONTROLLER=', vm.toString(address(s_alertsController)))
      );
    }

    vm.stopBroadcast();
  }
}
