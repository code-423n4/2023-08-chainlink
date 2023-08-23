// forge script scripts/DeployMigrationProxy.s.sol:DeployMigrationProxy --broadcast -vvvv --rpc-url
// $RPC_URL
// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import 'forge-std/Script.sol';

import {LinkTokenInterface} from '@chainlink/contracts/src/v0.8/interfaces/LinkTokenInterface.sol';

import {MigrationProxy} from '../src/MigrationProxy.sol';
import {OperatorStakingPool} from '../src/pools/OperatorStakingPool.sol';
import {CommunityStakingPool} from '../src/pools/CommunityStakingPool.sol';
import {RewardVault} from '../src/rewards/RewardVault.sol';
import {StakingV01} from '../src/staking-v0.1/Staking.sol';
import {BaseScenario} from './BaseScenario.s.sol';

contract DeployMigrationProxy is BaseScenario {
  function setUp() public virtual {}

  function run() public virtual {
    uint256 deployerPrivateKey = vm.envUint('PRIVATE_KEY');
    vm.startBroadcast(deployerPrivateKey);
    address deployer = vm.addr(deployerPrivateKey);

    console.log('Deploying MigrationProxy... (deployer: %s)', deployer);

    s_stakingV01 = StakingV01(vm.envAddress('STAKING_V01'));
    s_communityStakingPool = CommunityStakingPool(vm.envAddress('COMMUNITY_STAKING_POOL'));
    s_operatorStakingPool = OperatorStakingPool(vm.envAddress('OPERATOR_STAKING_POOL'));

    s_migrationProxy = new MigrationProxy(
      MigrationProxy.ConstructorParams({
        LINKAddress: LinkTokenInterface(vm.envAddress('LINK_ADDRESS')),
        v01StakingAddress: address(s_stakingV01),
        communityStakingPool: s_communityStakingPool,
        operatorStakingPool: s_operatorStakingPool,
        adminRoleTransferDelay: ADMIN_ROLE_TRANSFER_DELAY
      })
    );

    s_migrationProxy.grantRole(s_migrationProxy.PAUSER_ROLE(), deployer);

    // We need to call acceptMigrationTarget on the staking v0.1 contract after the 7-day timelock
    s_stakingV01.proposeMigrationTarget(address(s_migrationProxy));

    s_operatorStakingPool.setMigrationProxy(address(s_migrationProxy));
    s_communityStakingPool.setMigrationProxy(address(s_migrationProxy));

    address migrationProxy = vm.envOr('MIGRATION_PROXY', address(0));
    if (migrationProxy != address(s_migrationProxy)) {
      vm.writeLine(
        '.env', string.concat('MIGRATION_PROXY=', vm.toString(address(s_migrationProxy)))
      );
    }

    vm.stopBroadcast();
  }
}
