// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {BaseTestTimelocked} from '../BaseTestTimelocked.t.sol';
import {MigrationProxy} from '../../src/MigrationProxy.sol';
import {StakingPoolBase} from '../../src/pools/StakingPoolBase.sol';
import {Timelock} from '../../src/timelock/Timelock.sol';

contract ReplaceMigrationProxy is BaseTestTimelocked {
  MigrationProxy private s_newMigrationProxy;
  Timelock.Call[] private s_timelockUpgradeCalls;

  function setUp() public override {
    BaseTestTimelocked.setUp();
  }

  function test_ReplaceMigrationProxy() public {
    // step 1: pause migration proxy
    _pauseCurrentMigrationProxy();
    _validateMigrationProxyPaused();

    // step 2: deploy new migration proxy
    _deployNewMigrationProxy();
    _validateDeployedMigrationProxy();

    // step 3: timelock propose to replace migration proxy
    _scheduleMigrationProxyUpgrade();
    _validateNewMigrationProxyTimelock();

    // step 4: wait for timelock to end
    skip(
      s_stakingTimelock.getMinDelay(
        address(s_communityStakingPool), StakingPoolBase.setMigrationProxy.selector
      )
    );

    // step 6: time lock execute to replace migration proxy
    _executeMigrationProxyUpgrade();
    _validateNewMigrationProxyMigrations();
    _attemptAndFailMigrationsThroughOldProxy();
  }

  function _pauseCurrentMigrationProxy() private {
    changePrank(PAUSER);
    s_migrationProxy.emergencyPause();
  }

  function _deployNewMigrationProxy() private {
    changePrank(OWNER);
    s_newMigrationProxy = new MigrationProxy(
      MigrationProxy.ConstructorParams({
        LINKAddress: s_LINK,
        v01StakingAddress: MOCK_STAKING_V01,
        operatorStakingPool: s_operatorStakingPool,
        communityStakingPool: s_communityStakingPool,
        adminRoleTransferDelay: ADMIN_ROLE_TRANSFER_DELAY
      })
    );
  }

  function _scheduleMigrationProxyUpgrade() private {
    changePrank(PROPOSER_ONE);
    // schedule reward vault upgrade on all staking pools
    s_timelockUpgradeCalls.push(
      _timelockCall(
        address(s_communityStakingPool),
        abi.encodeWithSelector(
          StakingPoolBase.setMigrationProxy.selector, address(s_newMigrationProxy)
        )
      )
    );
    s_timelockUpgradeCalls.push(
      _timelockCall(
        address(s_operatorStakingPool),
        abi.encodeWithSelector(
          StakingPoolBase.setMigrationProxy.selector, address(s_newMigrationProxy)
        )
      )
    );
    s_stakingTimelock.scheduleBatch(
      s_timelockUpgradeCalls,
      NO_PREDECESSOR,
      EMPTY_SALT,
      s_stakingTimelock.getMinDelay(
        address(s_communityStakingPool), StakingPoolBase.setMigrationProxy.selector
      )
    );
  }

  function _executeMigrationProxyUpgrade() private {
    changePrank(EXECUTOR_ONE);
    s_stakingTimelock.executeBatch(s_timelockUpgradeCalls, NO_PREDECESSOR, EMPTY_SALT);
  }

  function _validateNewMigrationProxyTimelock() private {
    assertGt(
      s_stakingTimelock.getMinDelay(
        address(s_communityStakingPool), StakingPoolBase.setMigrationProxy.selector
      ),
      0
    );
    assertGt(
      s_stakingTimelock.getMinDelay(
        address(s_operatorStakingPool), StakingPoolBase.setMigrationProxy.selector
      ),
      0
    );
    assertEq(
      s_stakingTimelock.getMinDelay(
        address(s_communityStakingPool), StakingPoolBase.setMigrationProxy.selector
      ),
      s_stakingTimelock.getMinDelay(
        address(s_operatorStakingPool), StakingPoolBase.setMigrationProxy.selector
      )
    );
    changePrank(EXECUTOR_ONE);
    vm.expectRevert('Timelock: operation is not ready');
    s_stakingTimelock.executeBatch(s_timelockUpgradeCalls, NO_PREDECESSOR, EMPTY_SALT);
  }

  function _validateMigrationProxyPaused() private {
    _attemptAndFailMigrationsThroughOldProxy();
  }

  function _validateDeployedMigrationProxy() private {
    (
      address linkToken,
      address v01StakingAddress,
      address operatorStakingPool,
      address communityStakingPool
    ) = s_newMigrationProxy.getConfig();

    assertEq(linkToken, address(s_LINK));
    assertEq(v01StakingAddress, MOCK_STAKING_V01);
    assertEq(operatorStakingPool, address(s_operatorStakingPool));
    assertEq(communityStakingPool, address(s_communityStakingPool));
  }

  function _validateNewMigrationProxyMigrations() private {
    uint256 principalAndRewards = COMMUNITY_MIN_PRINCIPAL + 100 ether;
    uint256 amountToStake = COMMUNITY_MIN_PRINCIPAL;
    uint256 amountToWithdraw = principalAndRewards - amountToStake;

    changePrank(MOCK_STAKING_V01);
    uint256 stakerInitialBalance = s_communityStakingPool.getStakerPrincipal(COMMUNITY_STAKER_ONE);
    s_LINK.transferAndCall(
      address(s_newMigrationProxy), principalAndRewards, abi.encode(COMMUNITY_STAKER_ONE, '')
    );
    assertEq(
      s_communityStakingPool.getStakerPrincipal(COMMUNITY_STAKER_ONE),
      stakerInitialBalance + principalAndRewards
    );
    stakerInitialBalance = s_communityStakingPool.getStakerPrincipal(COMMUNITY_STAKER_TWO);
    s_LINK.transferAndCall(
      address(s_newMigrationProxy),
      principalAndRewards,
      abi.encode(COMMUNITY_STAKER_TWO, abi.encode(amountToStake, amountToWithdraw))
    );
    assertEq(
      s_communityStakingPool.getStakerPrincipal(COMMUNITY_STAKER_TWO),
      stakerInitialBalance + amountToStake
    );

    principalAndRewards = OPERATOR_MIN_PRINCIPAL + 100 ether;
    amountToStake = OPERATOR_MIN_PRINCIPAL;
    amountToWithdraw = principalAndRewards - amountToStake;

    stakerInitialBalance = s_operatorStakingPool.getStakerPrincipal(OPERATOR_STAKER_ONE);
    s_LINK.transferAndCall(
      address(s_newMigrationProxy), principalAndRewards, abi.encode(OPERATOR_STAKER_ONE, '')
    );
    assertEq(
      s_operatorStakingPool.getStakerPrincipal(OPERATOR_STAKER_ONE),
      stakerInitialBalance + principalAndRewards
    );
    stakerInitialBalance = s_operatorStakingPool.getStakerPrincipal(OPERATOR_STAKER_TWO);
    s_LINK.transferAndCall(
      address(s_newMigrationProxy),
      principalAndRewards,
      abi.encode(OPERATOR_STAKER_TWO, abi.encode(amountToStake, amountToWithdraw))
    );
    assertEq(
      s_operatorStakingPool.getStakerPrincipal(OPERATOR_STAKER_TWO),
      stakerInitialBalance + amountToStake
    );
  }

  function _attemptAndFailMigrationsThroughOldProxy() private {
    uint256 principalAndRewards = COMMUNITY_MIN_PRINCIPAL + 100 ether;
    uint256 amountToStake = COMMUNITY_MIN_PRINCIPAL;
    uint256 amountToWithdraw = principalAndRewards - amountToStake;

    // old migration proxy should not allow for new migrations
    changePrank(MOCK_STAKING_V01);
    vm.expectRevert('Pausable: paused');
    s_LINK.transferAndCall(
      address(s_migrationProxy), principalAndRewards, abi.encode(COMMUNITY_STAKER_ONE, '')
    );
    vm.expectRevert('Pausable: paused');
    s_LINK.transferAndCall(
      address(s_migrationProxy),
      principalAndRewards,
      abi.encode(COMMUNITY_STAKER_ONE, abi.encode(amountToStake, amountToWithdraw))
    );

    principalAndRewards = OPERATOR_MIN_PRINCIPAL + 100 ether;
    amountToStake = OPERATOR_MIN_PRINCIPAL;
    amountToWithdraw = principalAndRewards - amountToStake;

    vm.expectRevert('Pausable: paused');
    s_LINK.transferAndCall(
      address(s_migrationProxy), principalAndRewards, abi.encode(OPERATOR_STAKER_ONE, '')
    );
    vm.expectRevert('Pausable: paused');
    s_LINK.transferAndCall(
      address(s_migrationProxy),
      principalAndRewards,
      abi.encode(OPERATOR_STAKER_ONE, abi.encode(amountToStake, amountToWithdraw))
    );
  }
}
