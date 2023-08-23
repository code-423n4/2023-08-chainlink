// forge script scripts/scenarios/Scenario_WithAddedRewards.s.sol:Scenario_WithAddedRewards
// --broadcast -vvvv --rpc-url $RPC_URL
// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Scenario_DeployContracts} from './Scenario_DeployContracts.s.sol';

import 'forge-std/console.sol';

contract Scenario_WithAddedRewards is Scenario_DeployContracts {
  function setUp() public override(Scenario_DeployContracts) {}

  function run() public virtual override(Scenario_DeployContracts) {
    Scenario_DeployContracts.run();
    _fundRewardVault();
  }

  function _fundRewardVault() internal usingBroadcast(s_deployerPrivateKey) {
    address deployer = vm.addr(s_deployerPrivateKey);
    console.log(
      'Funding Reward Vault at address %s... (rewarder: %s)', address(s_rewardVault), deployer
    );
    s_rewardVault.addReward(address(0), REWARD_AMOUNT, EMISSION_RATE);
  }
}
