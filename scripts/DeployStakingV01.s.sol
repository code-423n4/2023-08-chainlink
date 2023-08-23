// forge script scripts/DeployStakingV01.s.sol:DeployStakingV01 --broadcast -vvvv --rpc-url
// $RPC_URL
// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import 'forge-std/Script.sol';

import {AggregatorV3Interface} from
  '@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol';
import {LinkTokenInterface} from '@chainlink/contracts/src/v0.8/interfaces/LinkTokenInterface.sol';

import {BaseScenario} from './BaseScenario.s.sol';
import {StakingV01} from '../src/staking-v0.1/Staking.sol';
import {Constants} from '../test/Constants.t.sol';

contract DeployStakingV01 is BaseScenario {
  function setUp() public virtual {}

  uint256 internal constant INITIAL_MAX_POOL_SIZE = 25_000_000 * 1e18;
  uint256 internal constant MAX_ALERTING_REWARD_AMOUNT = INITIAL_MAX_COMMUNITY_STAKE / 2;
  uint256 internal constant MIN_REWARD_DURATION = 30 days;
  uint256 internal constant SLASHABLE_DURATION = 90 days;
  uint256 internal constant REWARD_RATE = 317;
  uint256 internal constant ONE_MONTH = 30 * 24 * 60 * 60;

  function run() public virtual {
    uint256 deployerPrivateKey = vm.envUint('PRIVATE_KEY');
    vm.startBroadcast(deployerPrivateKey);

    console.log('Deploying StakingV01... (deployer: %s)', vm.addr(deployerPrivateKey));

    string memory key = 'OPERATORS';
    string memory delimiter = ',';
    address[] memory OPERATORS = vm.envAddress(key, delimiter);

    s_LINK = LinkTokenInterface(vm.envAddress('LINK_ADDRESS'));

    // Deploy LINK
    s_stakingV01 = new StakingV01(
      StakingV01.PoolConstructorParams({
        LINKAddress: s_LINK,
        monitoredFeed: AggregatorV3Interface(vm.envAddress('ETH_USD_FEED')),
        initialMaxPoolSize: INITIAL_MAX_POOL_SIZE,
        initialMaxCommunityStakeAmount: INITIAL_MAX_COMMUNITY_STAKE,
        initialMaxOperatorStakeAmount: INITIAL_MAX_OPERATOR_STAKE,
        minCommunityStakeAmount: INITIAL_MIN_COMMUNITY_STAKE,
        minOperatorStakeAmount: INITIAL_MIN_OPERATOR_STAKE,
        priorityPeriodThreshold: PRIORITY_PERIOD_THRESHOLD_SECONDS,
        regularPeriodThreshold: REGULAR_PERIOD_THRESHOLD_SECONDS,
        maxAlertingRewardAmount: MAX_ALERTING_REWARD_AMOUNT,
        minInitialOperatorCount: 2,
        minRewardDuration: MIN_REWARD_DURATION,
        slashableDuration: SLASHABLE_DURATION,
        delegationRateDenominator: DELEGATION_RATE_DENOMINATOR
      })
    );

    s_stakingV01.addOperators(OPERATORS);
    s_stakingV01.setFeedOperators(OPERATORS);
    s_LINK.approve(address(s_stakingV01), REWARD_AMOUNT);
    s_stakingV01.setMerkleRoot(MERKLE_ROOT);
    s_stakingV01.start(REWARD_AMOUNT, REWARD_RATE);
    s_stakingV01.setMerkleRoot(bytes32(''));

    address stakingV01 = vm.envOr('STAKING_V01', address(0));
    if (stakingV01 != address(s_stakingV01)) {
      vm.writeLine('.env', string.concat('STAKING_V01=', vm.toString(address(s_stakingV01))));
    }

    vm.stopBroadcast();
  }
}
