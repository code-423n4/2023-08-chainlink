// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {ERC677ReceiverInterface} from
  '@chainlink/contracts/src/v0.8/interfaces/ERC677ReceiverInterface.sol';
import {LinkTokenInterface} from '@chainlink/contracts/src/v0.8/interfaces/LinkTokenInterface.sol';
import {IERC165} from '@openzeppelin/contracts/interfaces/IERC165.sol';
import {BaseTest} from '../../BaseTest.t.sol';
import {IMigratable} from '../../../src/interfaces/IMigratable.sol';
import {IStakingOwner} from '../../../src/interfaces/IStakingOwner.sol';
import {IStakingPool} from '../../../src/interfaces/IStakingPool.sol';
import {RewardVault} from '../../../src/rewards/RewardVault.sol';
import {StakingPoolBase} from '../../../src/pools/StakingPoolBase.sol';
import {StakingPool_WithStakers} from '../../base-scenarios/StakingPoolScenarios.t.sol';
import {StakingPoolBaseHarness} from '../../../src/tests/StakingPoolBaseHarness.sol';
import {StakingPoolBaseV2} from '../../../src/tests/StakingPoolBaseV2.sol';

contract StakingPoolBase_NotImplemented is BaseTest {
  StakingPoolBaseHarness internal s_stakingPoolBaseHarness;

  function setUp() public override {
    BaseTest.setUp();

    s_stakingPoolBaseHarness = new StakingPoolBaseHarness(
      StakingPoolBase.ConstructorParamsBase({
        LINKAddress: s_LINK,
        initialMaxPoolSize: 31_500_000 ether,
        initialMaxPrincipalPerStaker: 1000 ether,
        minPrincipalPerStaker: 1 ether,
        initialUnbondingPeriod: INITIAL_UNBONDING_PERIOD,
        maxUnbondingPeriod: MAX_UNBONDING_PERIOD,
        initialClaimPeriod: INITIAL_CLAIM_PERIOD,
        minClaimPeriod: MIN_CLAIM_PERIOD,
        maxClaimPeriod: MAX_CLAIM_PERIOD,
        adminRoleTransferDelay: ADMIN_ROLE_TRANSFER_DELAY
      })
    );

    s_stakingPoolBaseHarness.setMigrationProxy(address(s_migrationProxy));
    s_stakingPoolBaseHarness.setRewardVault(s_rewardVault);
  }

  function test_onTokenTransfer() public {
    changePrank(OWNER);
    s_stakingPoolBaseHarness.setIsOpen(true);

    changePrank(OPERATOR_STAKER_ONE);
    vm.expectRevert('Not implemented');
    s_LINK.transferAndCall(address(s_stakingPoolBaseHarness), OPERATOR_MIN_PRINCIPAL, '');
  }

  function test_open() public {
    changePrank(OWNER);
    vm.expectRevert('Not implemented');
    s_stakingPoolBaseHarness.open();
  }
}

contract StakingPoolBase_SetRewardVault is BaseTest {
  event RewardVaultSet(address indexed oldRewardVault, address indexed newRewardVault);

  StakingPoolBaseHarness internal s_stakingPoolBaseHarness;

  function setUp() public override {
    BaseTest.setUp();

    s_stakingPoolBaseHarness = new StakingPoolBaseHarness(
      StakingPoolBase.ConstructorParamsBase({
        LINKAddress: s_LINK,
        initialMaxPoolSize: 31_500_000 ether,
        initialMaxPrincipalPerStaker: 1000 ether,
        minPrincipalPerStaker: 1 ether,
        initialUnbondingPeriod: INITIAL_UNBONDING_PERIOD,
        maxUnbondingPeriod: MAX_UNBONDING_PERIOD,
        initialClaimPeriod: INITIAL_CLAIM_PERIOD,
        minClaimPeriod: MIN_CLAIM_PERIOD,
        maxClaimPeriod: MAX_CLAIM_PERIOD,
        adminRoleTransferDelay: ADMIN_ROLE_TRANSFER_DELAY
      })
    );

    s_stakingPoolBaseHarness.setMigrationProxy(address(s_migrationProxy));
    s_stakingPoolBaseHarness.setRewardVault(s_rewardVault);
  }

  function test_setRewardVault_RevertWhen_CalledByNonOwner() public {
    changePrank(STRANGER);
    vm.expectRevert(
      _getExpectedMissingRoleErrorMessage(STRANGER, s_stakingPoolBaseHarness.DEFAULT_ADMIN_ROLE())
    );
    s_stakingPoolBaseHarness.setRewardVault(s_rewardVault);
  }

  function test_setRewardVault_RevertWhen_CalledWithZeroAddress() public {
    changePrank(OWNER);
    vm.expectRevert(IStakingPool.InvalidZeroAddress.selector);
    s_stakingPoolBaseHarness.setRewardVault(RewardVault(address(0)));
  }

  function test_setRewardVault_UpdatesRewardVault() public {
    changePrank(OWNER);
    address mockRewardVault = address(2000);
    RewardVault newRewardVault = RewardVault(mockRewardVault);
    vm.expectEmit(true, true, true, true, address(s_stakingPoolBaseHarness));
    emit RewardVaultSet(address(s_rewardVault), address(newRewardVault));
    s_stakingPoolBaseHarness.setRewardVault(newRewardVault);
    assertEq(address(s_stakingPoolBaseHarness.getRewardVault()), address(newRewardVault));
  }
}

contract StakingPoolBase_SetMigrationTarget is StakingPool_WithStakers {
  event MigrationTargetSet(address indexed oldMigrationTarget, address indexed newMigrationTarget);

  StakingPoolBaseV2 private s_stakingPoolBaseV2;

  function setUp() public override {
    StakingPool_WithStakers.setUp();

    s_stakingPoolBaseV2 = new StakingPoolBaseV2(
      StakingPoolBaseV2.ConstructorParams({
        LINKAddress: s_LINK,
        migrationSource: address(s_communityStakingPool)
      })
    );
  }

  function test_RevertWhen_CalledByNonOwner() public {
    changePrank(STRANGER);
    vm.expectRevert(
      _getExpectedMissingRoleErrorMessage(STRANGER, s_communityStakingPool.DEFAULT_ADMIN_ROLE())
    );
    s_communityStakingPool.setMigrationTarget(address(s_stakingPoolBaseV2));
  }

  function test_RevertWhen_PassedInZeroAddress() public {
    changePrank(OWNER);
    vm.expectRevert(IMigratable.InvalidMigrationTarget.selector);
    s_communityStakingPool.setMigrationTarget(address(0));
  }

  function test_RevertWhen_PassedInOwnAddress() public {
    changePrank(OWNER);
    vm.expectRevert(IMigratable.InvalidMigrationTarget.selector);
    s_communityStakingPool.setMigrationTarget(address(s_communityStakingPool));
  }

  function test_RevertWhen_PassedInTheSameMigrationTarget() public {
    changePrank(OWNER);
    s_communityStakingPool.setMigrationTarget(address(s_stakingPoolBaseV2));
    vm.expectRevert(IMigratable.InvalidMigrationTarget.selector);
    s_communityStakingPool.setMigrationTarget(address(s_stakingPoolBaseV2));
  }

  function test_RevertWhen_PassedInAnAddressThatIsNotERC677Compatible() public {
    changePrank(OWNER);
    vm.mockCall(
      address(s_stakingPoolBaseV2),
      abi.encodeWithSelector(
        IERC165.supportsInterface.selector, ERC677ReceiverInterface.onTokenTransfer.selector
      ),
      abi.encode(false)
    );
    vm.expectRevert(IMigratable.InvalidMigrationTarget.selector);
    s_communityStakingPool.setMigrationTarget(address(s_stakingPoolBaseV2));
  }

  function test_RevertWhen_PassedInANonContractAddress() public {
    changePrank(OWNER);
    vm.expectRevert(IMigratable.InvalidMigrationTarget.selector);
    s_communityStakingPool.setMigrationTarget(STRANGER);
  }

  function test_CorrectlySetsMigrationTarget() public {
    changePrank(OWNER);
    vm.expectEmit(true, true, true, true, address(s_communityStakingPool));
    emit MigrationTargetSet(address(0), address(s_stakingPoolBaseV2));
    s_communityStakingPool.setMigrationTarget(address(s_stakingPoolBaseV2));
    assertEq(s_communityStakingPool.getMigrationTarget(), address(s_stakingPoolBaseV2));
  }
}

contract StakingPoolBase_SupportsInterface is StakingPool_WithStakers {
  function test_IsStakingPoolBaseOnTokenTransferCompatible() public {
    StakingPoolBaseV2 stakingPoolBaseV2 = new StakingPoolBaseV2(
      StakingPoolBaseV2.ConstructorParams({
        LINKAddress: s_LINK,
        migrationSource: address(s_communityStakingPool)
      })
    );
    assertEq(
      stakingPoolBaseV2.supportsInterface(ERC677ReceiverInterface.onTokenTransfer.selector), true
    );
  }
}

contract StakingPoolBase_Migrate is StakingPool_WithStakers {
  StakingPoolBaseV2 private s_stakingPoolBaseV2;

  event MigrationTargetSet(address indexed oldMigrationTarget, address indexed newMigrationTarget);
  event StakerMigrated(address indexed migrationTarget, uint256 amount, bytes migrationData);

  function setUp() public override {
    StakingPool_WithStakers.setUp();

    s_stakingPoolBaseV2 = new StakingPoolBaseV2(
      StakingPoolBaseV2.ConstructorParams({
        LINKAddress: s_LINK,
        migrationSource: address(s_communityStakingPool)
      })
    );
  }

  function test_RevertWhen_CalledByNonStaker() public {
    changePrank(OWNER);
    s_communityStakingPool.setMigrationTarget(address(s_stakingPoolBaseV2));
    s_communityStakingPool.close();
    changePrank(STRANGER);
    vm.expectRevert(abi.encodeWithSelector(IStakingPool.StakeNotFound.selector, STRANGER));
    s_communityStakingPool.migrate('');
  }

  function test_RevertWhen_MigrationTargetNotSet() public {
    changePrank(OWNER);
    s_communityStakingPool.close();

    changePrank(COMMUNITY_STAKER_ONE);
    vm.expectRevert(IMigratable.InvalidMigrationTarget.selector);
    s_communityStakingPool.migrate('');
  }

  function test_RevertWhen_RewardVaultNotSet() public {
    changePrank(OWNER);
    // deploy a new CommunityStakingPool
    StakingPoolBaseHarness stakingPoolBaseHarness = new StakingPoolBaseHarness(
      StakingPoolBase.ConstructorParamsBase({
        LINKAddress: s_LINK,
        initialMaxPoolSize: 31_500_000 ether,
        initialMaxPrincipalPerStaker: 1000 ether,
        minPrincipalPerStaker: 1 ether,
        initialUnbondingPeriod: INITIAL_UNBONDING_PERIOD,
        maxUnbondingPeriod: MAX_UNBONDING_PERIOD,
        initialClaimPeriod: INITIAL_CLAIM_PERIOD,
        minClaimPeriod: MIN_CLAIM_PERIOD,
          maxClaimPeriod: MAX_CLAIM_PERIOD,
        adminRoleTransferDelay: ADMIN_ROLE_TRANSFER_DELAY
      })
    );

    stakingPoolBaseHarness.setIsOpen(true);
    stakingPoolBaseHarness.setMigrationTarget(address(s_stakingPoolBaseV2));
    stakingPoolBaseHarness.setMigrationProxy(address(s_migrationProxy));
    stakingPoolBaseHarness.close();

    changePrank(COMMUNITY_STAKER_ONE);

    vm.expectRevert(abi.encodeWithSelector(IStakingPool.RewardVaultNotSet.selector));
    stakingPoolBaseHarness.migrate('');
  }

  function test_RevertWhen_PoolNotClosed() public {
    changePrank(COMMUNITY_STAKER_ONE);
    vm.expectRevert(IStakingOwner.PoolNotClosed.selector);
    s_communityStakingPool.migrate('');
  }

  function test_CorrectlyMigrates() public {
    changePrank(OWNER);
    s_communityStakingPool.setMigrationTarget(address(s_stakingPoolBaseV2));
    s_communityStakingPool.close();
    changePrank(address(COMMUNITY_STAKER_ONE));
    vm.expectEmit(true, true, true, true, address(s_communityStakingPool));
    bytes memory data = '0x0000';
    uint256 amount = 1000000000000000000;
    uint256 stakerStakedAtTime = 1;
    bytes memory migrationData = abi.encode(address(COMMUNITY_STAKER_ONE), stakerStakedAtTime, data);
    emit StakerMigrated(address(s_stakingPoolBaseV2), amount, migrationData);
    s_communityStakingPool.migrate(data);
    assertEq(
      s_communityStakingPool.getStakerPrincipal(COMMUNITY_STAKER_ONE), 0, 'staker principal pool 1'
    );
  }
}

contract StakingPoolBase_OnTokenTransfer is StakingPool_WithStakers {
  StakingPoolBaseV2 private s_stakingPoolBaseV2;

  event StakerMigrated(
    address sender, uint256 amount, uint256 stakerStakedAtTime, bytes data, address previousPool
  );

  function setUp() public override {
    StakingPool_WithStakers.setUp();
  }

  function test_RevertWhen_MigrationSourceNotSet() public {
    changePrank(OWNER);
    s_stakingPoolBaseV2 = new StakingPoolBaseV2(
      StakingPoolBaseV2.ConstructorParams({
        LINKAddress: s_LINK,
        migrationSource: address(0)
      })
    );
    changePrank(address(s_stakingPoolBaseV2));
    vm.expectRevert(StakingPoolBaseV2.InvalidMigrationSource.selector);
    s_stakingPoolBaseV2.onTokenTransfer(address(0), 0, bytes(''));
  }

  function test_RevertWhen_SenderNotLinkToken() public {
    changePrank(OWNER);
    s_stakingPoolBaseV2 = new StakingPoolBaseV2(
      StakingPoolBaseV2.ConstructorParams({
        LINKAddress: s_LINK,
        migrationSource: address(s_communityStakingPool)
      })
    );
    changePrank(address(s_stakingPoolBaseV2));
    vm.expectRevert(StakingPoolBaseV2.SenderNotLinkToken.selector);
    s_stakingPoolBaseV2.onTokenTransfer(address(0), 0, bytes(''));
  }

  function test_CorrectlyOnTokenTransfer() public {
    changePrank(OWNER);
    s_stakingPoolBaseV2 = new StakingPoolBaseV2(
      StakingPoolBaseV2.ConstructorParams({
        LINKAddress: s_LINK,
        migrationSource: address(s_communityStakingPool)
      })
    );

    changePrank(address(s_LINK));
    uint256 amount = 1000000000000000000;
    uint256 stakerStakedAtTime = 1;
    bytes memory data = '0xffff';

    bytes memory migrationData = abi.encode(address(COMMUNITY_STAKER_ONE), stakerStakedAtTime, data);

    vm.expectEmit(true, true, true, true, address(s_stakingPoolBaseV2));
    emit StakerMigrated(
      address(COMMUNITY_STAKER_ONE),
      amount,
      stakerStakedAtTime,
      data,
      address(s_communityStakingPool)
    );
    s_stakingPoolBaseV2.onTokenTransfer(address(s_communityStakingPool), amount, migrationData);
  }
}
