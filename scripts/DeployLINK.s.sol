// forge script scripts/DeployLINK.s.sol:DeployLINK --broadcast -vvvv --rpc-url $RPC_URL
// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import 'forge-std/Script.sol';
import {OperatorStakingPool} from '../src/pools/OperatorStakingPool.sol';
import {StakingPoolBase} from '../src/pools/StakingPoolBase.sol';
import {Constants} from '../test/Constants.t.sol';
import {LinkTokenInterface} from '@chainlink/contracts/src/v0.8/interfaces/LinkTokenInterface.sol';
import {BaseScenario} from './BaseScenario.s.sol';

contract DeployLINK is BaseScenario {
  function setUp() public virtual {}

  function run() public virtual {
    uint256 deployerPrivateKey = vm.envUint('PRIVATE_KEY');
    vm.startBroadcast(deployerPrivateKey);

    console.log('Deploying LINK... (deployer: %s)', vm.addr(deployerPrivateKey));

    // Deploy LINK
    s_LINK = LinkTokenInterface(deployCode('LinkToken.sol'));

    address linkAddr = vm.envOr('LINK_ADDRESS', address(0));
    if (linkAddr != address(s_LINK)) {
      vm.writeLine('.env', string.concat('LINK_ADDRESS=', vm.toString(address(s_LINK))));
    }

    vm.stopBroadcast();
  }
}
