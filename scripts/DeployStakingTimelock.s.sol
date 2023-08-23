// forge script scripts/DeployStakingTimelock.s.sol:Run --broadcast -vvvv --rpc-url $RPC_URL
// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import 'forge-std/Script.sol';

import {LinkTokenInterface} from '@chainlink/contracts/src/v0.8/interfaces/LinkTokenInterface.sol';

import {StakingTimelock} from '../src/timelock/StakingTimelock.sol';
import {ConstantsTimelocked} from '../test/ConstantsTimelocked.t.sol';

contract Run is Script, ConstantsTimelocked {
  StakingTimelock internal s_stakingTimelock;
  address[] internal PROPOSERS = new address[](1);
  address[] internal EXECUTORS = new address[](1);
  address[] internal CANCELLERS = new address[](1);

  function setUp() public {}

  function run() public {
    uint256 deployerPrivateKey = vm.envUint('PRIVATE_KEY');
    vm.startBroadcast(deployerPrivateKey);
    address deployer = vm.addr(deployerPrivateKey);

    console.log('Deploying StakingTimelock... (deployer: %s)', deployer);

    address deployerAddr = vm.addr(deployerPrivateKey);
    PROPOSERS[0] = deployerAddr;
    EXECUTORS[0] = deployerAddr;
    CANCELLERS[0] = deployerAddr;

    s_stakingTimelock = new StakingTimelock(
      StakingTimelock.ConstructorParams({
        rewardVault: vm.envAddress('REWARD_VAULT'),
        communityStakingPool: vm.envAddress('COMMUNITY_STAKING_POOL'),
        operatorStakingPool: vm.envAddress('OPERATOR_STAKING_POOL'),
        alertsController: vm.envAddress('PF_ALERTS_CONTROLLER'),
        minDelay: MIN_DELAY,
        admin: deployerAddr,
        proposers: PROPOSERS,
        executors: EXECUTORS,
        cancellers: CANCELLERS
      })
    );

    vm.stopBroadcast();
  }
}
