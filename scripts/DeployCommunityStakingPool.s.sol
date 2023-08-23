// forge script scripts/DeployCommunityStakingPool.s.sol:DeployCommunityStakingPool --broadcast
// -vvvv --rpc-url $RPC_URL
// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import 'forge-std/Script.sol';
import {OperatorStakingPool} from '../src/pools/OperatorStakingPool.sol';
import {CommunityStakingPool} from '../src/pools/CommunityStakingPool.sol';
import {StakingPoolBase} from '../src/pools/StakingPoolBase.sol';
import {Constants} from '../test/Constants.t.sol';
import {LinkTokenInterface} from '@chainlink/contracts/src/v0.8/interfaces/LinkTokenInterface.sol';
import {BaseScenario} from './BaseScenario.s.sol';

contract DeployCommunityStakingPool is BaseScenario {
  function setUp() public virtual {}

  function run() public virtual {
    uint256 deployerPrivateKey = vm.envUint('PRIVATE_KEY');
    vm.startBroadcast(deployerPrivateKey);
    address deployer = vm.addr(deployerPrivateKey);

    console.log('Deploying CommunityStakingPool... (deployer: %s)', deployer);

    // Deploy Community staking pool
    s_communityStakingPool = new CommunityStakingPool(
      CommunityStakingPool.ConstructorParams({
        operatorStakingPool: OperatorStakingPool(vm.envAddress('OPERATOR_STAKING_POOL')),
        baseParams: StakingPoolBase.ConstructorParamsBase({
          LINKAddress: LinkTokenInterface(vm.envAddress('LINK_ADDRESS')),
          initialMaxPoolSize: COMMUNITY_MAX_POOL_SIZE,
          initialMaxPrincipalPerStaker: COMMUNITY_MAX_PRINCIPAL,
          minPrincipalPerStaker: COMMUNITY_MIN_PRINCIPAL,
          initialUnbondingPeriod: INITIAL_UNBONDING_PERIOD,
          maxUnbondingPeriod: MAX_UNBONDING_PERIOD,
          initialClaimPeriod: INITIAL_CLAIM_PERIOD,
          minClaimPeriod: MIN_CLAIM_PERIOD,
          maxClaimPeriod: MAX_CLAIM_PERIOD,
          adminRoleTransferDelay: ADMIN_ROLE_TRANSFER_DELAY
        })
      })
    );
    s_communityStakingPool.setMerkleRoot(vm.envOr('MERKLE_ROOT', bytes32(MERKLE_ROOT)));
    s_communityStakingPool.grantRole(s_communityStakingPool.PAUSER_ROLE(), deployer);

    address communityStakingPool = vm.envOr('COMMUNITY_STAKING_POOL', address(0));
    if (communityStakingPool != address(s_communityStakingPool)) {
      vm.writeLine(
        '.env',
        string.concat('COMMUNITY_STAKING_POOL=', vm.toString(address(s_communityStakingPool)))
      );
    }

    vm.stopBroadcast();
  }
}
