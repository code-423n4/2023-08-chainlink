// forge script scripts/scenarios/Scenario_DeployContracts.s.sol:Scenario_DeployContracts
// --broadcast -vvvv --rpc-url $RPC_URL
// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import 'forge-std/Script.sol';
import {Strings} from '@openzeppelin/contracts/utils/Strings.sol';
import {OperatorStakingPool} from '../../src/pools/OperatorStakingPool.sol';
import {CommunityStakingPool} from '../../src/pools/CommunityStakingPool.sol';
import {MigrationProxy} from '../../src/MigrationProxy.sol';
import {StakingPoolBase} from '../../src/pools/StakingPoolBase.sol';
import {RewardVault} from '../../src/rewards/RewardVault.sol';
import {Constants} from '../../test/Constants.t.sol';
import {LinkTokenInterface} from '@chainlink/contracts/src/v0.8/interfaces/LinkTokenInterface.sol';
import {DeployCommunityStakingPool} from '../DeployCommunityStakingPool.s.sol';
import {DeployOperatorStakingPool} from '../DeployOperatorStakingPool.s.sol';
import {DeployLINK} from '../DeployLINK.s.sol';
import {DeployMigrationProxy} from '../DeployMigrationProxy.s.sol';
import {DeployRewardVault} from '../DeployRewardVault.s.sol';
import {DeployStakingV01} from '../DeployStakingV01.s.sol';

import 'forge-std/console.sol';

contract Scenario_DeployContracts is
  DeployCommunityStakingPool,
  DeployOperatorStakingPool,
  DeployMigrationProxy,
  DeployLINK,
  DeployRewardVault,
  DeployStakingV01
{
  using Strings for address;

  bytes32[] internal s_communityStakerOneProof;
  bytes32[] internal s_communityStakerTwoProof;

  address internal s_actor;
  uint256 internal s_deployerPrivateKey;

  function setUp()
    public
    virtual
    override(
      DeployCommunityStakingPool,
      DeployLINK,
      DeployOperatorStakingPool,
      DeployMigrationProxy,
      DeployRewardVault,
      DeployStakingV01
    )
  {}

  function run()
    public
    virtual
    override(
      DeployCommunityStakingPool,
      DeployLINK,
      DeployOperatorStakingPool,
      DeployMigrationProxy,
      DeployRewardVault,
      DeployStakingV01
    )
  {
    // Start at T = 0
    vm.warp(TEST_START_TIME);

    s_deployerPrivateKey = vm.envUint('PRIVATE_KEY');

    s_actor = vm.addr(s_deployerPrivateKey);

    DeployLINK.run();
    vm.setEnv('LINK_ADDRESS', address(s_LINK).toHexString());
    _distributeLINKTokens();

    DeployOperatorStakingPool.run();
    vm.setEnv('OPERATOR_STAKING_POOL', address(s_operatorStakingPool).toHexString());
    DeployCommunityStakingPool.run();
    vm.setEnv('COMMUNITY_STAKING_POOL', address(s_communityStakingPool).toHexString());

    DeployStakingV01.run();
    vm.setEnv('STAKING_V01', address(s_stakingV01).toHexString());
    DeployMigrationProxy.run();
    DeployRewardVault.run();
  }

  function _distributeLINKTokens() internal usingBroadcast(s_deployerPrivateKey) {
    console.log('Distributing LINK');
    s_LINK.transfer(COMMUNITY_STAKER_ONE, 2 * COMMUNITY_MAX_PRINCIPAL);
    s_LINK.transfer(COMMUNITY_STAKER_TWO, 2 * COMMUNITY_MAX_PRINCIPAL);
    s_LINK.transfer(PUBLIC_COMMUNITY_STAKER, 2 * COMMUNITY_MAX_PRINCIPAL);
    s_LINK.transfer(OPERATOR_STAKER_ONE, 2 * OPERATOR_MAX_PRINCIPAL);
    s_LINK.transfer(OPERATOR_STAKER_TWO, 2 * OPERATOR_MAX_PRINCIPAL);
    s_LINK.transfer(OPERATOR_STAKER_THREE, 2 * OPERATOR_MAX_PRINCIPAL);
  }
}
