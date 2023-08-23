// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {LinkTokenInterface} from '@chainlink/contracts/src/v0.8/interfaces/LinkTokenInterface.sol';
import {SafeCast} from '@openzeppelin/contracts/utils/math/SafeCast.sol';
import {BaseTest} from './BaseTest.t.sol';
import {CommunityStakingPool} from '../src/pools/CommunityStakingPool.sol';
import {IAccessControlDefaultAdminRulesTest} from
  './interfaces/IAccessControlDefaultAdminRulesTest.t.sol';
import {IPausableTest} from './interfaces/IPausableTest.t.sol';
import {MigrationProxy} from '../src/MigrationProxy.sol';
import {OperatorStakingPool} from '../src/pools/OperatorStakingPool.sol';

abstract contract MigrationProxyTest is BaseTest {
  function setUp() public virtual override {
    BaseTest.setUp();

    changePrank(OWNER);
    s_operatorStakingPool.addOperators(_getDefaultOperators());
    s_operatorStakingPool.open();
    s_communityStakingPool.open();
  }

  // This is needed so that "forge coverage" will ignore this contract
  function test() public virtual override {}
}

contract MigrationProxy_Constructor is MigrationProxyTest {
  function test_RevertWhen_LINKAddressIsZero() public {
    vm.expectRevert(MigrationProxy.InvalidZeroAddress.selector);
    new MigrationProxy(
      MigrationProxy.ConstructorParams({
        LINKAddress: LinkTokenInterface(address(0)),
        v01StakingAddress: MOCK_STAKING_V01,
        operatorStakingPool: s_operatorStakingPool,
        communityStakingPool: s_communityStakingPool,
        adminRoleTransferDelay: ADMIN_ROLE_TRANSFER_DELAY
      })
    );
  }

  function test_RevertWhen_V01StakingAddressIsZero() public {
    vm.expectRevert(MigrationProxy.InvalidZeroAddress.selector);
    new MigrationProxy(
      MigrationProxy.ConstructorParams({
        LINKAddress: s_LINK,
        v01StakingAddress: address(0),
        operatorStakingPool: s_operatorStakingPool,
        communityStakingPool: s_communityStakingPool,
        adminRoleTransferDelay: ADMIN_ROLE_TRANSFER_DELAY
      })
    );
  }

  function test_RevertWhen_OperatorStakingPoolAddressIsZero() public {
    vm.expectRevert(MigrationProxy.InvalidZeroAddress.selector);
    new MigrationProxy(
      MigrationProxy.ConstructorParams({
        LINKAddress: s_LINK,
        v01StakingAddress: MOCK_STAKING_V01,
        operatorStakingPool: OperatorStakingPool(address(0)),
        communityStakingPool: s_communityStakingPool,
        adminRoleTransferDelay: ADMIN_ROLE_TRANSFER_DELAY
      })
    );
  }

  function test_RevertWhen_CommunityStakingPoolAddressIsZero() public {
    vm.expectRevert(MigrationProxy.InvalidZeroAddress.selector);
    new MigrationProxy(
      MigrationProxy.ConstructorParams({
        LINKAddress: s_LINK,
        v01StakingAddress: MOCK_STAKING_V01,
        operatorStakingPool: s_operatorStakingPool,
        communityStakingPool: CommunityStakingPool(address(0)),
        adminRoleTransferDelay: ADMIN_ROLE_TRANSFER_DELAY
      })
    );
  }

  function test_InitializesConfigsAndRoles() public {
    (
      address linkAddress,
      address stakingV01,
      address operatorStakingPool,
      address communityStakingPool
    ) = s_migrationProxy.getConfig();
    assertEq(linkAddress, address(s_LINK));
    assertEq(stakingV01, MOCK_STAKING_V01);
    assertEq(operatorStakingPool, address(s_operatorStakingPool));
    assertEq(communityStakingPool, address(s_communityStakingPool));
    assertEq(s_migrationProxy.hasRole(s_migrationProxy.DEFAULT_ADMIN_ROLE(), OWNER), true);
  }

  function test_TypeAndVersion() public {
    string memory typeAndVersion = s_migrationProxy.typeAndVersion();
    assertEq(typeAndVersion, 'MigrationProxy 1.0.0');
  }
}

contract MigrationProxy_GetConfig is MigrationProxyTest {
  function test_GetConfigReturnsCorrectValues() public {
    (address link, address stakingV01, address operatorStakingPool, address communityStakingPool) =
      s_migrationProxy.getConfig();
    assertEq(link, address(s_LINK));
    assertEq(stakingV01, address(MOCK_STAKING_V01));
    assertEq(operatorStakingPool, address(s_operatorStakingPool));
    assertEq(communityStakingPool, address(s_communityStakingPool));
  }
}

contract MigrationProxy_SupportsInterface is MigrationProxyTest {
  function test_SupportsInterfaceReturnsTrueForOnTokenTransfer() public {
    assertEq(s_migrationProxy.supportsInterface(s_migrationProxy.onTokenTransfer.selector), true);
  }

  function test_SupportsInterfaceReturnsFalseForOtherInterfaces() public {
    assertEq(s_migrationProxy.supportsInterface(s_operatorStakingPool.addOperators.selector), false);
  }
}

contract MigrationProxy_OnTokenTransfer is MigrationProxyTest {
  function test_RevertWhen_SenderNotLINKToken() public {
    changePrank(COMMUNITY_STAKER_ONE);
    vm.expectRevert(MigrationProxy.SenderNotLinkToken.selector);
    s_migrationProxy.onTokenTransfer(
      MOCK_STAKING_V01, COMMUNITY_MAX_PRINCIPAL, abi.encode(0, COMMUNITY_MAX_PRINCIPAL)
    );
  }

  function test_RevertWhen_OnTokenTransferCallerIsNotStakingV01() public {
    changePrank(COMMUNITY_STAKER_TWO);

    vm.expectRevert(MigrationProxy.InvalidSourceAddress.selector);
    s_LINK.transferAndCall(
      address(s_migrationProxy),
      COMMUNITY_MAX_PRINCIPAL,
      abi.encode(COMMUNITY_STAKER_TWO, abi.encode(0, COMMUNITY_MAX_PRINCIPAL))
    );
  }

  function test_RevertWhen_PartialMigrationAmountsDoNotAddUp() public {
    changePrank(MOCK_STAKING_V01);

    uint256 principalAndRewards = COMMUNITY_MAX_PRINCIPAL + 100 ether;
    uint256 amountToStake = COMMUNITY_MAX_PRINCIPAL;
    uint256 amountToWithdraw = principalAndRewards - amountToStake + 1;

    vm.expectRevert(
      abi.encodeWithSelector(
        MigrationProxy.InvalidAmounts.selector, amountToStake, amountToWithdraw, principalAndRewards
      )
    );
    s_LINK.transferAndCall(
      address(s_migrationProxy),
      principalAndRewards,
      abi.encode(COMMUNITY_STAKER_ONE, abi.encode(amountToStake, amountToWithdraw))
    );
  }

  function test_CanPartiallyMigrateAsCommunityStaker() public {
    changePrank(MOCK_STAKING_V01);

    uint256 stakerBalanceBefore = s_LINK.balanceOf(COMMUNITY_STAKER_ONE);
    uint256 stakingV01BalanceBefore = s_LINK.balanceOf(MOCK_STAKING_V01);
    uint256 communityStakingPoolBalanceBefore = s_LINK.balanceOf(address(s_communityStakingPool));
    uint256 principalAndRewards = COMMUNITY_MAX_PRINCIPAL + 100 ether;
    uint256 amountToStake = COMMUNITY_MAX_PRINCIPAL;
    uint256 amountToWithdraw = principalAndRewards - amountToStake;

    s_LINK.transferAndCall(
      address(s_migrationProxy),
      principalAndRewards,
      abi.encode(COMMUNITY_STAKER_ONE, abi.encode(amountToStake, amountToWithdraw))
    );

    assertEq(s_LINK.balanceOf(COMMUNITY_STAKER_ONE), stakerBalanceBefore + amountToWithdraw);
    assertEq(s_LINK.balanceOf(MOCK_STAKING_V01), stakingV01BalanceBefore - principalAndRewards);
    assertEq(
      s_LINK.balanceOf(address(s_communityStakingPool)),
      communityStakingPoolBalanceBefore + amountToStake
    );
  }

  function test_CanFullyMigrateAsCommunityStaker() public {
    changePrank(MOCK_STAKING_V01);

    uint256 stakerBalanceBefore = s_LINK.balanceOf(COMMUNITY_STAKER_ONE);
    uint256 stakingV01BalanceBefore = s_LINK.balanceOf(MOCK_STAKING_V01);
    uint256 communityStakingPoolBalanceBefore = s_LINK.balanceOf(address(s_communityStakingPool));
    uint256 principalAndRewards = COMMUNITY_MIN_PRINCIPAL + 100 ether;

    s_LINK.transferAndCall(
      address(s_migrationProxy), principalAndRewards, abi.encode(COMMUNITY_STAKER_ONE, '')
    );

    assertEq(s_LINK.balanceOf(COMMUNITY_STAKER_ONE), stakerBalanceBefore);
    assertEq(s_LINK.balanceOf(MOCK_STAKING_V01), stakingV01BalanceBefore - principalAndRewards);
    assertEq(
      s_LINK.balanceOf(address(s_communityStakingPool)),
      communityStakingPoolBalanceBefore + principalAndRewards
    );
  }

  function test_CanPartiallyMigrateAsOperatorStaker() public {
    changePrank(MOCK_STAKING_V01);

    uint256 stakerBalanceBefore = s_LINK.balanceOf(OPERATOR_STAKER_ONE);
    uint256 stakingV01BalanceBefore = s_LINK.balanceOf(MOCK_STAKING_V01);
    uint256 operatorStakingPoolBalanceBefore = s_LINK.balanceOf(address(s_operatorStakingPool));
    uint256 principalAndRewards = OPERATOR_MAX_PRINCIPAL + 1000 ether;
    uint256 amountToStake = OPERATOR_MAX_PRINCIPAL;
    uint256 amountToWithdraw = principalAndRewards - amountToStake;

    s_LINK.transferAndCall(
      address(s_migrationProxy),
      principalAndRewards,
      abi.encode(OPERATOR_STAKER_ONE, abi.encode(amountToStake, amountToWithdraw))
    );

    assertEq(s_LINK.balanceOf(OPERATOR_STAKER_ONE), stakerBalanceBefore + amountToWithdraw);
    assertEq(s_LINK.balanceOf(MOCK_STAKING_V01), stakingV01BalanceBefore - principalAndRewards);
    assertEq(
      s_LINK.balanceOf(address(s_operatorStakingPool)),
      operatorStakingPoolBalanceBefore + amountToStake
    );
  }

  function test_CanFullyMigrateAsOperatorStaker() public {
    changePrank(MOCK_STAKING_V01);

    uint256 stakerBalanceBefore = s_LINK.balanceOf(OPERATOR_STAKER_ONE);
    uint256 stakingV01BalanceBefore = s_LINK.balanceOf(MOCK_STAKING_V01);
    uint256 operatorStakingPoolBalanceBefore = s_LINK.balanceOf(address(s_operatorStakingPool));
    uint256 principalAndRewards = OPERATOR_MIN_PRINCIPAL + 1000 ether;

    s_LINK.transferAndCall(
      address(s_migrationProxy), principalAndRewards, abi.encode(OPERATOR_STAKER_ONE, '')
    );

    assertEq(s_LINK.balanceOf(OPERATOR_STAKER_ONE), stakerBalanceBefore);
    assertEq(s_LINK.balanceOf(MOCK_STAKING_V01), stakingV01BalanceBefore - principalAndRewards);
    assertEq(
      s_LINK.balanceOf(address(s_operatorStakingPool)),
      operatorStakingPoolBalanceBefore + principalAndRewards
    );
  }
}

contract MigrationProxy_OnTokenTransfer_Pausable is MigrationProxyTest {
  function setUp() public override {
    MigrationProxyTest.setUp();

    changePrank(PAUSER);
    s_migrationProxy.emergencyPause();
  }

  function test_RevertWhen_AttemptingToFullyMigrateCommunityStakerWhenPaused() public {
    changePrank(MOCK_STAKING_V01);

    uint256 principalAndRewards = COMMUNITY_MAX_PRINCIPAL + 100 ether;

    vm.expectRevert('Pausable: paused');
    s_LINK.transferAndCall(
      address(s_migrationProxy), principalAndRewards, abi.encode(COMMUNITY_STAKER_ONE, '')
    );
  }

  function test_RevertWhen_AttemptingToPartiallyMigrateCommunityStakerWhenPaused() public {
    changePrank(MOCK_STAKING_V01);

    uint256 principalAndRewards = COMMUNITY_MAX_PRINCIPAL + 100 ether;
    uint256 amountToStake = COMMUNITY_MAX_PRINCIPAL;
    uint256 amountToWithdraw = principalAndRewards - amountToStake;

    vm.expectRevert('Pausable: paused');
    s_LINK.transferAndCall(
      address(s_migrationProxy),
      principalAndRewards,
      abi.encode(COMMUNITY_STAKER_ONE, abi.encode(amountToStake, amountToWithdraw))
    );
  }

  function test_ResumePartiallyMigrateCommunityStakerWhenUnpaused() public {
    changePrank(PAUSER);
    s_migrationProxy.emergencyUnpause();

    uint256 principalAndRewards = COMMUNITY_MAX_PRINCIPAL + 100 ether;
    uint256 amountToStake = COMMUNITY_MAX_PRINCIPAL;
    uint256 amountToWithdraw = principalAndRewards - amountToStake;

    changePrank(MOCK_STAKING_V01);
    s_LINK.transferAndCall(
      address(s_migrationProxy),
      principalAndRewards,
      abi.encode(COMMUNITY_STAKER_ONE, abi.encode(amountToStake, amountToWithdraw))
    );
  }

  function test_ResumeFullyMigrateCommunityStakerWhenUnpaused() public {
    changePrank(PAUSER);
    s_migrationProxy.emergencyUnpause();

    uint256 principalAndRewards = COMMUNITY_MIN_PRINCIPAL + 100 ether;

    changePrank(MOCK_STAKING_V01);
    s_LINK.transferAndCall(
      address(s_migrationProxy), principalAndRewards, abi.encode(COMMUNITY_STAKER_ONE, '')
    );
  }

  function test_RevertWhen_AttemptingToFullyMigrateOperatorWhenPaused() public {
    changePrank(MOCK_STAKING_V01);

    uint256 principalAndRewards = OPERATOR_MAX_PRINCIPAL + 1000 ether;

    vm.expectRevert('Pausable: paused');
    s_LINK.transferAndCall(
      address(s_migrationProxy), principalAndRewards, abi.encode(OPERATOR_STAKER_ONE, '')
    );
  }

  function test_RevertWhen_AttemptingToPartiallyMigrateOperatorWhenPaused() public {
    changePrank(MOCK_STAKING_V01);

    uint256 principalAndRewards = OPERATOR_MAX_PRINCIPAL + 1000 ether;
    uint256 amountToStake = OPERATOR_MAX_PRINCIPAL;
    uint256 amountToWithdraw = principalAndRewards - amountToStake;

    vm.expectRevert('Pausable: paused');
    s_LINK.transferAndCall(
      address(s_migrationProxy),
      principalAndRewards,
      abi.encode(OPERATOR_STAKER_ONE, abi.encode(amountToStake, amountToWithdraw))
    );
  }

  function test_ResumePartiallyMigrateOperatorWhenUnpaused() public {
    changePrank(PAUSER);
    s_migrationProxy.emergencyUnpause();

    changePrank(MOCK_STAKING_V01);

    uint256 principalAndRewards = OPERATOR_MAX_PRINCIPAL + 1000 ether;
    uint256 amountToStake = OPERATOR_MAX_PRINCIPAL;
    uint256 amountToWithdraw = principalAndRewards - amountToStake;

    s_LINK.transferAndCall(
      address(s_migrationProxy),
      principalAndRewards,
      abi.encode(OPERATOR_STAKER_ONE, abi.encode(amountToStake, amountToWithdraw))
    );
  }

  function test_ResumeFullyMigrateOperatorWhenUnpaused() public {
    changePrank(PAUSER);
    s_migrationProxy.emergencyUnpause();

    uint256 principalAndRewards = OPERATOR_MIN_PRINCIPAL + 1000 ether;

    changePrank(MOCK_STAKING_V01);

    s_LINK.transferAndCall(
      address(s_migrationProxy), principalAndRewards, abi.encode(OPERATOR_STAKER_ONE, '')
    );
  }
}

contract MigrationProxy_Pausable is MigrationProxyTest, IPausableTest {
  function test_RevertWhen_NotPauserEmergencyPause() public {
    changePrank(STRANGER);
    vm.expectRevert(_getExpectedMissingRoleErrorMessage(STRANGER, s_migrationProxy.PAUSER_ROLE()));

    s_migrationProxy.emergencyPause();
    assertEq(s_migrationProxy.paused(), false);
  }

  function test_PauserCanEmergencyPause() public {
    changePrank(PAUSER);

    s_migrationProxy.emergencyPause();
    assertEq(s_migrationProxy.paused(), true);
  }

  function test_RevertWhen_PausingWhenAlreadyPaused() public {
    changePrank(PAUSER);
    s_migrationProxy.emergencyPause();

    vm.expectRevert('Pausable: paused');
    s_migrationProxy.emergencyPause();
  }

  function test_RevertWhen_NotPauserEmergencyUnpause() public {
    changePrank(PAUSER);
    s_migrationProxy.emergencyPause();

    changePrank(STRANGER);
    vm.expectRevert(_getExpectedMissingRoleErrorMessage(STRANGER, s_migrationProxy.PAUSER_ROLE()));
    s_migrationProxy.emergencyUnpause();

    assertEq(s_migrationProxy.paused(), true);
  }

  function test_PauserCanEmergencyUnpause() public {
    changePrank(PAUSER);
    s_migrationProxy.emergencyPause();
    s_migrationProxy.emergencyUnpause();
    assertEq(s_migrationProxy.paused(), false);
  }

  function test_RevertWhen_UnpausingWhenAlreadyUnpaused() public {
    changePrank(PAUSER);

    vm.expectRevert('Pausable: not paused');
    s_migrationProxy.emergencyUnpause();
  }
}

contract MigrationProxy_AccessControlDefaultAdminRules is
  IAccessControlDefaultAdminRulesTest,
  BaseTest
{
  using SafeCast for uint256;

  event DefaultAdminTransferScheduled(address indexed newAdmin, uint48 acceptSchedule);
  event DefaultAdminTransferCanceled();
  event DefaultAdminDelayChangeScheduled(uint48 newDelay, uint48 effectSchedule);
  event DefaultAdminDelayChangeCanceled();

  function test_DefaultValuesAreInitialized() public {
    assertEq(s_migrationProxy.hasRole(s_migrationProxy.DEFAULT_ADMIN_ROLE(), OWNER), true);
    assertEq(s_migrationProxy.defaultAdmin(), OWNER);
    (address pendingDefaultAdmin, uint48 adminSchedule) = s_migrationProxy.pendingDefaultAdmin();
    assertEq(pendingDefaultAdmin, address(0));
    assertEq(adminSchedule, 0);
    assertEq(s_migrationProxy.defaultAdminDelay(), 0);
    (uint48 pendingDelay, uint48 delaySchedule) = s_migrationProxy.pendingDefaultAdminDelay();
    assertEq(pendingDelay, 0);
    assertEq(delaySchedule, 0);
    assertEq(s_migrationProxy.defaultAdminDelayIncreaseWait(), 5 days);
  }

  function test_RevertWhen_DirectlyGrantDefaultAdminRole() public {
    changePrank(OWNER);
    bytes32 defaultAdminRole = s_migrationProxy.DEFAULT_ADMIN_ROLE();
    vm.expectRevert("AccessControl: can't directly grant default admin role");
    s_migrationProxy.grantRole(defaultAdminRole, NEW_OWNER);
  }

  function test_RevertWhen_DirectlyRevokeDefaultAdminRole() public {
    changePrank(OWNER);
    bytes32 defaultAdminRole = s_migrationProxy.DEFAULT_ADMIN_ROLE();
    vm.expectRevert("AccessControl: can't directly revoke default admin role");
    s_migrationProxy.revokeRole(defaultAdminRole, NEW_OWNER);
  }

  function test_RevertWhen_NonAdminBeginsDefaultAdminTransfer() public {
    changePrank(NEW_OWNER);
    vm.expectRevert(
      _getExpectedMissingRoleErrorMessage(NEW_OWNER, s_migrationProxy.DEFAULT_ADMIN_ROLE())
    );
    s_migrationProxy.beginDefaultAdminTransfer(NEW_OWNER);
  }

  function test_CurrentAdminCanBeginDefaultAdminTransfer() public {
    changePrank(OWNER);
    address newAdmin = NEW_OWNER;
    uint48 newSchedule = SafeCast.toUint48(block.timestamp);
    vm.expectEmit(true, true, true, true, address(s_migrationProxy));
    emit DefaultAdminTransferScheduled(newAdmin, newSchedule);

    s_migrationProxy.beginDefaultAdminTransfer(newAdmin);

    assertEq(s_migrationProxy.hasRole(s_migrationProxy.DEFAULT_ADMIN_ROLE(), OWNER), true);
    assertEq(s_migrationProxy.defaultAdmin(), OWNER);
    (address pendingDefaultAdmin, uint48 schedule) = s_migrationProxy.pendingDefaultAdmin();
    assertEq(pendingDefaultAdmin, newAdmin);
    assertEq(schedule, newSchedule);
  }

  function test_CurrentAdminCanOverwritePendingDefaultAdminTransfer() public {
    changePrank(OWNER);
    s_migrationProxy.beginDefaultAdminTransfer(NEW_OWNER);

    address newAdmin = PAUSER;
    uint48 newSchedule = SafeCast.toUint48(block.timestamp);
    vm.expectEmit(true, true, true, true, address(s_migrationProxy));
    emit DefaultAdminTransferCanceled();
    vm.expectEmit(true, true, true, true, address(s_migrationProxy));
    emit DefaultAdminTransferScheduled(newAdmin, newSchedule);

    s_migrationProxy.beginDefaultAdminTransfer(newAdmin);

    assertEq(s_migrationProxy.hasRole(s_migrationProxy.DEFAULT_ADMIN_ROLE(), OWNER), true);
    assertEq(s_migrationProxy.defaultAdmin(), OWNER);
    (address pendingDefaultAdmin, uint48 schedule) = s_migrationProxy.pendingDefaultAdmin();
    assertEq(pendingDefaultAdmin, newAdmin);
    assertEq(schedule, newSchedule);
  }

  function test_CurrentAdminCanOverwriteDefaultAdminTransferAfterDelayPassedAndIfNotAccepted()
    public
  {
    changePrank(OWNER);
    s_migrationProxy.beginDefaultAdminTransfer(NEW_OWNER);
    (, uint48 scheduleBefore) = s_migrationProxy.pendingDefaultAdmin();

    // After the delay is over
    skip(2);

    address newAdmin = PAUSER;
    uint48 newSchedule = scheduleBefore + 2;
    vm.expectEmit(true, true, true, true, address(s_migrationProxy));
    emit DefaultAdminTransferCanceled();
    vm.expectEmit(true, true, true, true, address(s_migrationProxy));
    emit DefaultAdminTransferScheduled(newAdmin, newSchedule);

    s_migrationProxy.beginDefaultAdminTransfer(PAUSER);

    assertEq(s_migrationProxy.hasRole(s_migrationProxy.DEFAULT_ADMIN_ROLE(), OWNER), true);
    assertEq(s_migrationProxy.defaultAdmin(), OWNER);
    (address pendingDefaultAdmin, uint48 schedule) = s_migrationProxy.pendingDefaultAdmin();
    assertEq(pendingDefaultAdmin, newAdmin);
    assertEq(schedule, newSchedule);
  }

  function test_RevertWhen_NonAdminCancelPendingDefaultAdminTransfer() public {
    changePrank(OWNER);
    s_migrationProxy.beginDefaultAdminTransfer(NEW_OWNER);

    changePrank(NEW_OWNER);
    vm.expectRevert(
      _getExpectedMissingRoleErrorMessage(NEW_OWNER, s_migrationProxy.DEFAULT_ADMIN_ROLE())
    );
    s_migrationProxy.cancelDefaultAdminTransfer();
  }

  function test_CurrentAdminCanCancelPendingDefaultAdminTransfer() public {
    changePrank(OWNER);
    s_migrationProxy.beginDefaultAdminTransfer(NEW_OWNER);

    vm.expectEmit(true, true, true, true, address(s_migrationProxy));
    emit DefaultAdminTransferCanceled();
    s_migrationProxy.cancelDefaultAdminTransfer();

    (address pendingDefaultAdmin, uint48 schedule) = s_migrationProxy.pendingDefaultAdmin();
    assertEq(pendingDefaultAdmin, address(0));
    assertEq(schedule, 0);
  }

  function test_RevertWhen_NonPendingDefaultAdminAcceptsTransfer() public {
    changePrank(OWNER);
    s_migrationProxy.beginDefaultAdminTransfer(NEW_OWNER);

    changePrank(STRANGER);
    vm.expectRevert('AccessControl: pending admin must accept');
    s_migrationProxy.acceptDefaultAdminTransfer();
  }

  function test_RevertWhen_PendingDefaultAdminAcceptsTransferBeforeDelayPassed() public {
    changePrank(OWNER);
    s_migrationProxy.changeDefaultAdminDelay(1 days);
    s_migrationProxy.beginDefaultAdminTransfer(NEW_OWNER);

    changePrank(NEW_OWNER);
    vm.expectRevert('AccessControl: transfer delay not passed');
    s_migrationProxy.acceptDefaultAdminTransfer();
  }

  function test_PendingDefaultAdminCanAcceptTransferImmediatelyIfDelayIsZero() public {
    changePrank(OWNER);
    s_migrationProxy.beginDefaultAdminTransfer(NEW_OWNER);

    skip(1); // needs to satisfy: schedule < block.timestamp

    changePrank(NEW_OWNER);
    s_migrationProxy.acceptDefaultAdminTransfer();

    assertEq(s_migrationProxy.hasRole(s_migrationProxy.DEFAULT_ADMIN_ROLE(), OWNER), false);
    assertEq(s_migrationProxy.hasRole(s_migrationProxy.DEFAULT_ADMIN_ROLE(), NEW_OWNER), true);
    assertEq(s_migrationProxy.defaultAdmin(), NEW_OWNER);
    (address pendingDefaultAdmin, uint48 schedule) = s_migrationProxy.pendingDefaultAdmin();
    assertEq(pendingDefaultAdmin, address(0));
    assertEq(schedule, 0);
  }

  function test_PendingDefaultAdminCanAcceptTransferAfterDelayPassed() public {
    changePrank(OWNER);
    s_migrationProxy.changeDefaultAdminDelay(30 days);
    s_migrationProxy.beginDefaultAdminTransfer(NEW_OWNER);

    skip(30 days);

    changePrank(NEW_OWNER);
    s_migrationProxy.acceptDefaultAdminTransfer();

    assertEq(s_migrationProxy.hasRole(s_migrationProxy.DEFAULT_ADMIN_ROLE(), OWNER), false);
    assertEq(s_migrationProxy.hasRole(s_migrationProxy.DEFAULT_ADMIN_ROLE(), NEW_OWNER), true);
    assertEq(s_migrationProxy.defaultAdmin(), NEW_OWNER);
    (address pendingDefaultAdmin, uint48 schedule) = s_migrationProxy.pendingDefaultAdmin();
    assertEq(pendingDefaultAdmin, address(0));
    assertEq(schedule, 0);
  }

  function test_RevertWhen_NonAdminChangesDelay() public {
    changePrank(NEW_OWNER);
    vm.expectRevert(
      _getExpectedMissingRoleErrorMessage(NEW_OWNER, s_migrationProxy.DEFAULT_ADMIN_ROLE())
    );
    s_migrationProxy.changeDefaultAdminDelay(30 days);
  }

  function test_CurrentAdminCanChangeDelay() public {
    changePrank(OWNER);
    uint48 newDelay = 30 days;
    uint48 newSchedule = SafeCast.toUint48(block.timestamp + 5 days);
    vm.expectEmit(true, true, true, true, address(s_migrationProxy));
    emit DefaultAdminDelayChangeScheduled(newDelay, newSchedule);
    s_migrationProxy.changeDefaultAdminDelay(newDelay);

    assertEq(s_migrationProxy.defaultAdminDelay(), 0);
    (uint48 pendingDelay, uint48 schedule) = s_migrationProxy.pendingDefaultAdminDelay();
    assertEq(pendingDelay, newDelay);
    assertEq(schedule, newSchedule);
  }

  function test_RevertWhen_NonAdminRollbackDelayChange() public {
    changePrank(OWNER);
    s_migrationProxy.changeDefaultAdminDelay(30 days);

    changePrank(NEW_OWNER);
    vm.expectRevert(
      _getExpectedMissingRoleErrorMessage(NEW_OWNER, s_migrationProxy.DEFAULT_ADMIN_ROLE())
    );
    s_migrationProxy.rollbackDefaultAdminDelay();
  }

  function test_CurrentAdminCanRollbackDelayChange() public {
    changePrank(OWNER);
    s_migrationProxy.changeDefaultAdminDelay(30 days);

    vm.expectEmit(true, true, true, true, address(s_migrationProxy));
    emit DefaultAdminDelayChangeCanceled();
    s_migrationProxy.rollbackDefaultAdminDelay();

    assertEq(s_migrationProxy.defaultAdminDelay(), 0);
    (uint48 pendingDelay, uint48 schedule) = s_migrationProxy.pendingDefaultAdminDelay();
    assertEq(pendingDelay, 0);
    assertEq(schedule, 0);
  }
}
