// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import 'forge-std/Script.sol';
import {LinkTokenInterface} from '@chainlink/contracts/src/v0.8/interfaces/LinkTokenInterface.sol';
import {MigrationProxy} from '../src/MigrationProxy.sol';
import {CommunityStakingPool} from '../src/pools/CommunityStakingPool.sol';
import {OperatorStakingPool} from '../src/pools/OperatorStakingPool.sol';
import {PriceFeedAlertsController} from '../src/alerts/PriceFeedAlertsController.sol';
import {RewardVault} from '../src/rewards/RewardVault.sol';
import {StakingV01} from '../src/staking-v0.1/Staking.sol';
import {Constants} from '../test/Constants.t.sol';

abstract contract BaseScenario is Script, Constants {
  CommunityStakingPool internal s_communityStakingPool;
  LinkTokenInterface internal s_LINK;
  MigrationProxy internal s_migrationProxy;
  StakingV01 internal s_stakingV01;
  OperatorStakingPool internal s_operatorStakingPool;
  PriceFeedAlertsController internal s_alertsController;
  RewardVault internal s_rewardVault;

  modifier usingBroadcast(uint256 privateKey) {
    vm.startBroadcast(privateKey);
    _;
    vm.stopBroadcast();
  }
}
