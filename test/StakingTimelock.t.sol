// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {IAccessControl} from '@openzeppelin/contracts/access/IAccessControl.sol';
import {BaseTestTimelocked} from './BaseTestTimelocked.t.sol';
import {IMigratable} from '../src/interfaces/IMigratable.sol';
import {ISlashable} from '../src/interfaces/ISlashable.sol';
import {OperatorStakingPool} from '../src/pools/OperatorStakingPool.sol';
import {PriceFeedAlertsController} from '../src/alerts/PriceFeedAlertsController.sol';
import {RewardVault} from '../src/rewards/RewardVault.sol';
import {StakingPoolBase} from '../src/pools/StakingPoolBase.sol';
import {Timelock} from '../src/timelock/Timelock.sol';

contract StakingTimelock_Constructor is BaseTestTimelocked {
  function test_InitializesMinDelays() public {
    // Changing timelock delay
    assertEq(
      s_stakingTimelock.getMinDelay(
        address(s_stakingTimelock), bytes4(keccak256('updateDelay(uint256)'))
      ),
      DELAY_ONE_MONTH
    );
    assertEq(
      s_stakingTimelock.getMinDelay(
        address(s_stakingTimelock), bytes4(keccak256('updateDelay((address,bytes4,uint256)[])'))
      ),
      DELAY_ONE_MONTH
    );

    // Migrating staking pools to a new reward vault
    assertEq(
      s_stakingTimelock.getMinDelay(
        address(s_communityStakingPool), StakingPoolBase.setRewardVault.selector
      ),
      DELAY_ONE_MONTH
    );
    assertEq(
      s_stakingTimelock.getMinDelay(
        address(s_operatorStakingPool), StakingPoolBase.setRewardVault.selector
      ),
      DELAY_ONE_MONTH
    );

    // Migrating the staking pools to the upgraded pools
    assertEq(
      s_stakingTimelock.getMinDelay(
        address(s_communityStakingPool), IMigratable.setMigrationTarget.selector
      ),
      DELAY_ONE_MONTH
    );
    assertEq(
      s_stakingTimelock.getMinDelay(
        address(s_operatorStakingPool), IMigratable.setMigrationTarget.selector
      ),
      DELAY_ONE_MONTH
    );

    // Migrating the reward vault to the upgraded reward vault
    assertEq(
      s_stakingTimelock.getMinDelay(address(s_rewardVault), IMigratable.setMigrationTarget.selector),
      DELAY_ONE_MONTH
    );

    // Migrating the alerts controller to the upgraded alerts controller
    assertEq(
      s_stakingTimelock.getMinDelay(
        address(s_pfAlertsController), IMigratable.setMigrationTarget.selector
      ),
      DELAY_ONE_MONTH
    );

    // Granting a new slasher role / adding a new slashing condition
    assertEq(
      s_stakingTimelock.getMinDelay(address(s_operatorStakingPool), ISlashable.addSlasher.selector),
      DELAY_ONE_MONTH
    );

    // Updating unbonding periods in the staking pools
    assertEq(
      s_stakingTimelock.getMinDelay(
        address(s_communityStakingPool), StakingPoolBase.setUnbondingPeriod.selector
      ),
      DELAY_ONE_MONTH
    );
    assertEq(
      s_stakingTimelock.getMinDelay(
        address(s_operatorStakingPool), StakingPoolBase.setUnbondingPeriod.selector
      ),
      DELAY_ONE_MONTH
    );
  }
}

contract StakingTimelock_UpdateDelay is BaseTestTimelocked {
  // Test that if updateDelay is scheduled, the min delay is greater than MIN_DELAY
  function test_UpdateDelay_RevertsWhen_DelayTooLow() public {
    changePrank(PROPOSER_ONE);
    Timelock.Call[] memory calls = _singletonCalls(
      _timelockCall(
        address(s_stakingTimelock),
        abi.encodeWithSelector(bytes4(keccak256('updateDelay(uint256)')), 123)
      )
    );

    // DELAY_ONE_MONTH - 1 is insufficient delay for updateDelay
    vm.expectRevert('Timelock: insufficient delay');
    s_stakingTimelock.scheduleBatch(calls, NO_PREDECESSOR, EMPTY_SALT, DELAY_ONE_MONTH - 1);
  }

  function test_UpdateDelay_SufficientDelay() public {
    changePrank(PROPOSER_ONE);
    Timelock.Call[] memory calls = _singletonCalls(
      _timelockCall(
        address(s_stakingTimelock),
        abi.encodeWithSelector(bytes4(keccak256('updateDelay(uint256)')), 123)
      )
    );

    // DELAY_ONE_MONTH is sufficient delay for updateDelay
    s_stakingTimelock.scheduleBatch(calls, NO_PREDECESSOR, EMPTY_SALT, DELAY_ONE_MONTH);
    bytes32 batchedOperationID =
      s_stakingTimelock.hashOperationBatch(calls, NO_PREDECESSOR, EMPTY_SALT);
    assertEq(s_stakingTimelock.isOperation(batchedOperationID), true);
  }

  function test_UpdateSelectorDelay_RevertsWhen_DelayTooLow() public {
    changePrank(PROPOSER_ONE);
    Timelock.UpdateDelayParams[] memory params = new Timelock.UpdateDelayParams[](1);
    params[0] = Timelock.UpdateDelayParams({
      target: address(s_stakingTimelock),
      selector: bytes4(keccak256('updateDelay((address,bytes4,uint256)[])')),
      newDelay: 123
    });
    Timelock.Call[] memory calls = _singletonCalls(
      _timelockCall(
        address(s_stakingTimelock),
        abi.encodeWithSelector(bytes4(keccak256('updateDelay((address,bytes4,uint256)[])')), params)
      )
    );

    // DELAY_ONE_MONTH - 1 is insufficient delay for updateDelay
    vm.expectRevert('Timelock: insufficient delay');
    s_stakingTimelock.scheduleBatch(calls, NO_PREDECESSOR, EMPTY_SALT, DELAY_ONE_MONTH - 1);
  }

  function test_UpdateSelectorDelay_SufficientDelay() public {
    changePrank(PROPOSER_ONE);
    Timelock.UpdateDelayParams[] memory params = new Timelock.UpdateDelayParams[](1);
    params[0] = Timelock.UpdateDelayParams({
      target: address(s_stakingTimelock),
      selector: bytes4(keccak256('updateDelay((address,bytes4,uint256)[])')),
      newDelay: 123
    });
    Timelock.Call[] memory calls = _singletonCalls(
      _timelockCall(
        address(s_stakingTimelock),
        abi.encodeWithSelector(bytes4(keccak256('updateDelay((address,bytes4,uint256)[])')), params)
      )
    );

    // DELAY_ONE_MONTH is sufficient delay for updateDelay
    s_stakingTimelock.scheduleBatch(calls, NO_PREDECESSOR, EMPTY_SALT, DELAY_ONE_MONTH);
    bytes32 batchedOperationID =
      s_stakingTimelock.hashOperationBatch(calls, NO_PREDECESSOR, EMPTY_SALT);
    assertEq(s_stakingTimelock.isOperation(batchedOperationID), true);
  }
}
