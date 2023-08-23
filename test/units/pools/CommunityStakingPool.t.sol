// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {LinkTokenInterface} from '@chainlink/contracts/src/v0.8/interfaces/LinkTokenInterface.sol';
import {SafeCast} from '@openzeppelin/contracts/utils/math/SafeCast.sol';
import {FixedPointMathLib} from '@solmate/utils/FixedPointMathLib.sol';
import {BaseTest} from '../../BaseTest.t.sol';
import {
  StakingPool_MigrationsOnly,
  StakingPool_WithStakers,
  StakingPool_InUnbondingPeriod,
  StakingPool_StakeInUnbondingPeriod,
  StakingPool_MigrationProxyUnset,
  StakingPool_InClaimPeriod,
  StakingPool_WhenPaused,
  StakingPool_WhenClaimPeriodEndsAt
} from '../../base-scenarios/StakingPoolScenarios.t.sol';
import {IAccessControlDefaultAdminRulesTest} from
  '../../interfaces/IAccessControlDefaultAdminRulesTest.t.sol';
import {IOpenableTest} from '../../interfaces/IOpenableTest.t.sol';
import {IPausableTest} from '../../interfaces/IPausableTest.t.sol';
import {
  IStakingPool_Constructor,
  IStakingPool_GetClaimPeriodEndsAt,
  IStakingPool_GetStaker,
  IStakingPool_Unbond_WhenStakeIsNotUnbonding,
  IStakingPool_Unbond_WhenStakeIsUnbonding,
  IStakingPool_OnTokenTransfer,
  IStakingPool_OnTokenTransfer_WhenPaused,
  IStakingPool_OnTokenTransfer_WhenThereOtherStakers,
  IStakingPool_OnTokenTransfer_WhenStakeIsUnbonding,
  IStakingPool_Unbond_WhenStakeIsUnbonding,
  IStakingPool_Unbond_WhenStakerStakesAgainDuringUnbondingPeriod,
  IStakingPool_SetPoolConfig,
  IStakingPool_SetMigrationProxy,
  IStakingPool_Unbond_WhenStakeIsUnbonding,
  IStakingPool_Unstake,
  IStakingPool_Unstake_WhenUnbondingNotStarted,
  IStakingPool_Unstake_WhileUnbonding,
  IStakingPool_Unstake_WhenClaimPeriodFinished,
  IStakingPool_Unstake_WhenPaused,
  IStakingPool_Unstake_WhenPoolClosed,
  IStakingPool_Unstake_WhenMoreThanTwoStakers,
  IStakingPool_SetUnbondingPeriod_WhenPoolOpenedAndStakersAreUnbonding,
  IStakingPool_Unstake_WhenPoolIsFull,
  IStakingPool_Unstake_WhenThereAreOtherStakers,
  IStakingPool_SetClaimPeriod,
  IStakingPool_Unstake_WhenLastStakerUnstakesAndClaims
} from '../../interfaces/IStakingPoolTest.t.sol';
import {CommunityStakingPool} from '../../../src/pools/CommunityStakingPool.sol';
import {IMerkleAccessController} from '../../../src/interfaces/IMerkleAccessController.sol';
import {IRewardVault} from '../../../src/interfaces/IRewardVault.sol';
import {IStakingOwner} from '../../../src/interfaces/IStakingOwner.sol';
import {IStakingPool} from '../../../src/interfaces/IStakingPool.sol';
import {OperatorStakingPool} from '../../../src/pools/OperatorStakingPool.sol';
import {RewardVault} from '../../../src/rewards/RewardVault.sol';
import {StakingPoolBase} from '../../../src/pools/StakingPoolBase.sol';

contract CommunityStakingPool_Constructor is IStakingPool_Constructor, BaseTest {
  function test_RevertWhen_UnbondingPeriodIsLessThanMinUnbondingPeriod() external override {
    vm.expectRevert(StakingPoolBase.InvalidUnbondingPeriod.selector);
    s_communityStakingPool = new CommunityStakingPool(
      CommunityStakingPool.ConstructorParams({
        baseParams: StakingPoolBase.ConstructorParamsBase({
          LINKAddress: s_LINK,
          initialMaxPoolSize: COMMUNITY_MAX_POOL_SIZE,
          initialMaxPrincipalPerStaker: COMMUNITY_MAX_PRINCIPAL,
          minPrincipalPerStaker: COMMUNITY_MIN_PRINCIPAL,
          initialUnbondingPeriod: MIN_UNBONDING_PERIOD - 1,
          maxUnbondingPeriod: MAX_UNBONDING_PERIOD,
          initialClaimPeriod: INITIAL_CLAIM_PERIOD,
          minClaimPeriod: MIN_CLAIM_PERIOD,
          maxClaimPeriod: MAX_CLAIM_PERIOD,
          adminRoleTransferDelay: ADMIN_ROLE_TRANSFER_DELAY
        }),
        operatorStakingPool: s_operatorStakingPool
      })
    );
  }

  function test_RevertWhen_UnbondingPeriodIsGreaterThanMaxUnbondingPeriod() external override {
    vm.expectRevert(StakingPoolBase.InvalidUnbondingPeriod.selector);
    s_communityStakingPool = new CommunityStakingPool(
      CommunityStakingPool.ConstructorParams({
        baseParams: StakingPoolBase.ConstructorParamsBase({
          LINKAddress: s_LINK,
          initialMaxPoolSize: COMMUNITY_MAX_POOL_SIZE,
          initialMaxPrincipalPerStaker: COMMUNITY_MAX_PRINCIPAL,
          minPrincipalPerStaker: COMMUNITY_MIN_PRINCIPAL,
          initialUnbondingPeriod: MAX_UNBONDING_PERIOD + 1,
          maxUnbondingPeriod: MAX_UNBONDING_PERIOD,
          initialClaimPeriod: INITIAL_CLAIM_PERIOD,
          minClaimPeriod: MIN_CLAIM_PERIOD,
          maxClaimPeriod: MAX_CLAIM_PERIOD,
          adminRoleTransferDelay: ADMIN_ROLE_TRANSFER_DELAY
        }),
        operatorStakingPool: s_operatorStakingPool
      })
    );
  }

  function test_RevertWhen_MinUnbondingPeriodIsGreaterThanMaxUnbondingPeriod() public {
    vm.expectRevert(
      abi.encodeWithSelector(
        StakingPoolBase.InvalidUnbondingPeriodRange.selector,
        MIN_UNBONDING_PERIOD,
        MIN_UNBONDING_PERIOD - 1
      )
    );
    s_communityStakingPool = new CommunityStakingPool(
      CommunityStakingPool.ConstructorParams({
        baseParams: StakingPoolBase.ConstructorParamsBase({
          LINKAddress: s_LINK,
          initialMaxPoolSize: COMMUNITY_MAX_POOL_SIZE,
          initialMaxPrincipalPerStaker: COMMUNITY_MAX_PRINCIPAL,
          minPrincipalPerStaker: COMMUNITY_MIN_PRINCIPAL,
          initialUnbondingPeriod: INITIAL_UNBONDING_PERIOD,
          maxUnbondingPeriod: MIN_UNBONDING_PERIOD - 1,
          initialClaimPeriod: INITIAL_CLAIM_PERIOD,
          minClaimPeriod: MIN_CLAIM_PERIOD,
          maxClaimPeriod: MAX_CLAIM_PERIOD,
          adminRoleTransferDelay: ADMIN_ROLE_TRANSFER_DELAY
        }),
        operatorStakingPool: s_operatorStakingPool
      })
    );
  }

  function test_RevertWhen_ClaimPeriodIsZero() external override {
    vm.expectRevert(StakingPoolBase.InvalidClaimPeriod.selector);
    s_communityStakingPool = new CommunityStakingPool(
      CommunityStakingPool.ConstructorParams({
        baseParams: StakingPoolBase.ConstructorParamsBase({
          LINKAddress: s_LINK,
          initialMaxPoolSize: COMMUNITY_MAX_POOL_SIZE,
          initialMaxPrincipalPerStaker: COMMUNITY_MAX_PRINCIPAL,
          minPrincipalPerStaker: COMMUNITY_MIN_PRINCIPAL,
          initialUnbondingPeriod: INITIAL_UNBONDING_PERIOD,
          maxUnbondingPeriod: MAX_UNBONDING_PERIOD,
          initialClaimPeriod: 0,
          minClaimPeriod: MIN_CLAIM_PERIOD,
          maxClaimPeriod: MAX_CLAIM_PERIOD,
          adminRoleTransferDelay: ADMIN_ROLE_TRANSFER_DELAY
        }),
        operatorStakingPool: s_operatorStakingPool
      })
    );
  }

  function test_RevertWhen_MinClaimPeriodIsGreaterThanMaxClaimPeriod() public {
    vm.expectRevert(
      abi.encodeWithSelector(
        StakingPoolBase.InvalidClaimPeriodRange.selector, MAX_CLAIM_PERIOD, MIN_CLAIM_PERIOD
      )
    );
    new CommunityStakingPool(
      CommunityStakingPool.ConstructorParams({
        operatorStakingPool: s_operatorStakingPool,
        baseParams: StakingPoolBase.ConstructorParamsBase({
          LINKAddress: s_LINK,
          initialMaxPoolSize: OPERATOR_MAX_POOL_SIZE,
          initialMaxPrincipalPerStaker: OPERATOR_MAX_PRINCIPAL,
          minPrincipalPerStaker: OPERATOR_MIN_PRINCIPAL,
          initialUnbondingPeriod: INITIAL_UNBONDING_PERIOD,
          maxUnbondingPeriod: MAX_UNBONDING_PERIOD,
          initialClaimPeriod: INITIAL_CLAIM_PERIOD,
          minClaimPeriod: MAX_CLAIM_PERIOD,
          maxClaimPeriod: MIN_CLAIM_PERIOD,
          adminRoleTransferDelay: ADMIN_ROLE_TRANSFER_DELAY
        })
      })
    );
  }

  function test_RevertWhen_MinClaimPeriodIsZero() public {
    vm.expectRevert(
      abi.encodeWithSelector(StakingPoolBase.InvalidClaimPeriodRange.selector, 0, MAX_CLAIM_PERIOD)
    );
    new CommunityStakingPool(
      CommunityStakingPool.ConstructorParams({
        operatorStakingPool: s_operatorStakingPool,
        baseParams: StakingPoolBase.ConstructorParamsBase({
          LINKAddress: s_LINK,
          initialMaxPoolSize: OPERATOR_MAX_POOL_SIZE,
          initialMaxPrincipalPerStaker: OPERATOR_MAX_PRINCIPAL,
          minPrincipalPerStaker: OPERATOR_MIN_PRINCIPAL,
          initialUnbondingPeriod: INITIAL_UNBONDING_PERIOD,
          maxUnbondingPeriod: MAX_UNBONDING_PERIOD,
          initialClaimPeriod: INITIAL_CLAIM_PERIOD,
          minClaimPeriod: 0,
          maxClaimPeriod: MAX_CLAIM_PERIOD,
          adminRoleTransferDelay: ADMIN_ROLE_TRANSFER_DELAY
        })
      })
    );
  }

  function test_RevertWhen_MinAndMaxClaimPeriodAreEqual() public {
    vm.expectRevert(
      abi.encodeWithSelector(
        StakingPoolBase.InvalidClaimPeriodRange.selector, MAX_CLAIM_PERIOD, MAX_CLAIM_PERIOD
      )
    );
    new CommunityStakingPool(
      CommunityStakingPool.ConstructorParams({
        operatorStakingPool: s_operatorStakingPool,
        baseParams: StakingPoolBase.ConstructorParamsBase({
          LINKAddress: s_LINK,
          initialMaxPoolSize: OPERATOR_MAX_POOL_SIZE,
          initialMaxPrincipalPerStaker: OPERATOR_MAX_PRINCIPAL,
          minPrincipalPerStaker: OPERATOR_MIN_PRINCIPAL,
          initialUnbondingPeriod: INITIAL_UNBONDING_PERIOD,
          maxUnbondingPeriod: MAX_UNBONDING_PERIOD,
          initialClaimPeriod: INITIAL_CLAIM_PERIOD,
          minClaimPeriod: MAX_CLAIM_PERIOD,
          maxClaimPeriod: MAX_CLAIM_PERIOD,
          adminRoleTransferDelay: ADMIN_ROLE_TRANSFER_DELAY
        })
      })
    );
  }

  function test_RevertWhen_MaxPoolSizeIsZero() public {
    vm.expectRevert(abi.encodeWithSelector(IStakingOwner.InvalidPoolSize.selector, 0));
    new CommunityStakingPool(
      CommunityStakingPool.ConstructorParams({
        operatorStakingPool: s_operatorStakingPool,
        baseParams: StakingPoolBase.ConstructorParamsBase({
          LINKAddress: s_LINK,
          initialMaxPoolSize: 0,
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
  }

  function test_RevertWhen_MinStakeAmountIsGreaterThanMaxStakeAmount() public {
    vm.expectRevert(IStakingOwner.InvalidMinStakeAmount.selector);
    new CommunityStakingPool(
      CommunityStakingPool.ConstructorParams({
        operatorStakingPool: s_operatorStakingPool,
        baseParams: StakingPoolBase.ConstructorParamsBase({
          LINKAddress: s_LINK,
          initialMaxPoolSize: COMMUNITY_MAX_POOL_SIZE,
          initialMaxPrincipalPerStaker: COMMUNITY_MAX_PRINCIPAL,
          minPrincipalPerStaker: COMMUNITY_MAX_PRINCIPAL + 1000,
          initialUnbondingPeriod: INITIAL_UNBONDING_PERIOD,
          maxUnbondingPeriod: MAX_UNBONDING_PERIOD,
          initialClaimPeriod: INITIAL_CLAIM_PERIOD,
          minClaimPeriod: MIN_CLAIM_PERIOD,
          maxClaimPeriod: MAX_CLAIM_PERIOD,
          adminRoleTransferDelay: ADMIN_ROLE_TRANSFER_DELAY
        })
      })
    );
  }

  function test_RevertWhen_MinStakeAmountIsEqualToMaxStakeAmount() public {
    vm.expectRevert(IStakingOwner.InvalidMinStakeAmount.selector);
    new CommunityStakingPool(
      CommunityStakingPool.ConstructorParams({
        operatorStakingPool: s_operatorStakingPool,
        baseParams: StakingPoolBase.ConstructorParamsBase({
          LINKAddress: s_LINK,
          initialMaxPoolSize: COMMUNITY_MAX_POOL_SIZE,
          initialMaxPrincipalPerStaker: COMMUNITY_MAX_PRINCIPAL,
          minPrincipalPerStaker: COMMUNITY_MAX_PRINCIPAL,
          initialUnbondingPeriod: INITIAL_UNBONDING_PERIOD,
          maxUnbondingPeriod: MAX_UNBONDING_PERIOD,
          initialClaimPeriod: INITIAL_CLAIM_PERIOD,
          minClaimPeriod: MIN_CLAIM_PERIOD,
          maxClaimPeriod: MAX_CLAIM_PERIOD,
          adminRoleTransferDelay: ADMIN_ROLE_TRANSFER_DELAY
        })
      })
    );
  }

  function test_RevertWhen_MinStakeAmountIsZero() public {
    vm.expectRevert(IStakingOwner.InvalidMinStakeAmount.selector);
    new CommunityStakingPool(
      CommunityStakingPool.ConstructorParams({
        operatorStakingPool: s_operatorStakingPool,
        baseParams: StakingPoolBase.ConstructorParamsBase({
          LINKAddress: s_LINK,
          initialMaxPoolSize: COMMUNITY_MAX_POOL_SIZE,
          initialMaxPrincipalPerStaker: COMMUNITY_MAX_PRINCIPAL,
          minPrincipalPerStaker: 0,
          initialUnbondingPeriod: INITIAL_UNBONDING_PERIOD,
          maxUnbondingPeriod: MAX_UNBONDING_PERIOD,
          initialClaimPeriod: INITIAL_CLAIM_PERIOD,
          minClaimPeriod: MIN_CLAIM_PERIOD,
          maxClaimPeriod: MAX_CLAIM_PERIOD,
          adminRoleTransferDelay: ADMIN_ROLE_TRANSFER_DELAY
        })
      })
    );
  }

  function test_RevertWhen_MaxStakeAmountIsZero() public {
    // This should revert with InvalidMinStakeAmount as minPrincipalPerStaker
    // must be greater than initialMaxPrincipalPerStaker
    vm.expectRevert(IStakingOwner.InvalidMinStakeAmount.selector);
    new CommunityStakingPool(
      CommunityStakingPool.ConstructorParams({
        operatorStakingPool: s_operatorStakingPool,
        baseParams: StakingPoolBase.ConstructorParamsBase({
          LINKAddress: s_LINK,
          initialMaxPoolSize: COMMUNITY_MAX_POOL_SIZE,
          initialMaxPrincipalPerStaker: 0,
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
  }

  function test_RevertWhen_ProvidedOperatorStakingPoolAddressIsZero() public {
    vm.expectRevert(IStakingPool.InvalidZeroAddress.selector);
    new CommunityStakingPool(
      CommunityStakingPool.ConstructorParams({
        operatorStakingPool: OperatorStakingPool(address(0)),
        baseParams: StakingPoolBase.ConstructorParamsBase({
          LINKAddress: s_LINK,
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
  }

  function test_RevertWhen_LINKAddressIsZero() public {
    vm.expectRevert(IStakingPool.InvalidZeroAddress.selector);
    new CommunityStakingPool(
      CommunityStakingPool.ConstructorParams({
        operatorStakingPool: s_operatorStakingPool,
        baseParams: StakingPoolBase.ConstructorParamsBase({
          LINKAddress: LinkTokenInterface(address(0)),
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
  }

  function test_InitializesUnbondingParams() external override {
    (uint256 unbondingPeriod, uint256 claimPeriod) = s_communityStakingPool.getUnbondingParams();
    assertEq(unbondingPeriod, UNBONDING_PERIOD);
    assertEq(claimPeriod, CLAIM_PERIOD);
  }

  function test_InitializesUnbondingPeriodLimits() public {
    (uint256 minUnbondingPeriod, uint256 maxUnbondingPeriod) =
      s_communityStakingPool.getUnbondingPeriodLimits();
    assertEq(minUnbondingPeriod, MIN_UNBONDING_PERIOD);
    assertEq(maxUnbondingPeriod, MAX_UNBONDING_PERIOD);
  }

  function test_SetsTheLINKToken() public {
    assertEq(s_communityStakingPool.getChainlinkToken(), address(s_LINK));
  }

  function test_HasCorrectInitialLimits() public {
    uint256 communityMaxPoolSize = s_communityStakingPool.getMaxPoolSize();
    (uint256 communityMinPrincipal, uint256 communityMaxPrincipal) =
      s_communityStakingPool.getStakerLimits();
    assertEq(communityMaxPoolSize, COMMUNITY_MAX_POOL_SIZE);
    assertEq(communityMinPrincipal, COMMUNITY_MIN_PRINCIPAL);
    assertEq(communityMaxPrincipal, COMMUNITY_MAX_PRINCIPAL);
  }

  function test_HasCorrectInitialClaimPeriodLimits() public {
    (uint256 minClaimPeriod, uint256 maxClaimPeriod) = s_communityStakingPool.getClaimPeriodLimits();
    assertEq(minClaimPeriod, MIN_CLAIM_PERIOD);
    assertEq(maxClaimPeriod, MAX_CLAIM_PERIOD);
  }

  function test_CheckpointIdIsZero() public {
    assertEq(s_communityStakingPool.getCurrentCheckpointId(), 0);
  }

  function test_InitializesRoles() public {
    assertEq(
      s_communityStakingPool.hasRole(s_communityStakingPool.DEFAULT_ADMIN_ROLE(), OWNER), true
    );
  }
}

contract CommunityStakingPool_GetStaker is IStakingPool_GetStaker, StakingPool_WithStakers {
  function test_ReturnsZeroIfStakerHasNotStaked() public override {
    assertEq(s_communityStakingPool.getStakerPrincipal(STRANGER), 0);
    assertEq(s_communityStakingPool.getStakerStakedAtTime(STRANGER), 0);
  }

  function test_ReturnsZeroIfStakerIsInAnotherPool() public override {
    assertEq(s_communityStakingPool.getStakerPrincipal(STRANGER), 0);
    assertEq(s_communityStakingPool.getStakerStakedAtTime(OPERATOR_STAKER_ONE), 0);
  }

  function test_ReturnsCorrectStakeAmountIfStakerHasStaked() public override {
    assertEq(
      s_communityStakingPool.getStakerPrincipal(COMMUNITY_STAKER_ONE), COMMUNITY_MIN_PRINCIPAL
    );
    assertEq(s_communityStakingPool.getStakerStakedAtTime(COMMUNITY_STAKER_ONE), block.timestamp);
  }
}

contract CommunityStakingPool_GetClaimPeriodEndsAtDuringClaimPeriod is
  IStakingPool_GetClaimPeriodEndsAt,
  StakingPool_InUnbondingPeriod
{
  event UnbondingPeriodStarted(address indexed staker);

  function test_ReturnsCorrectClaimPeriodEndsAt() public override {
    changePrank(COMMUNITY_STAKER_ONE);
    uint256 claimPeriodEndsAt = s_communityStakingPool.getClaimPeriodEndsAt(COMMUNITY_STAKER_ONE);

    assertEq(claimPeriodEndsAt, block.timestamp + CLAIM_PERIOD + UNBONDING_PERIOD);
  }
}

contract CommunityStakingPool_GetClaimPeriodEndsAtBeforeUnbondingPeriod is
  IStakingPool_GetClaimPeriodEndsAt,
  StakingPool_WithStakers
{
  function test_ReturnsCorrectClaimPeriodEndsAt() public override {
    changePrank(COMMUNITY_STAKER_ONE);
    uint256 claimPeriodEndsAt = s_communityStakingPool.getClaimPeriodEndsAt(COMMUNITY_STAKER_ONE);

    assertEq(claimPeriodEndsAt, 0);
  }
}

contract CommunityStakingPool_SetPoolConfig is IStakingPool_SetPoolConfig, StakingPool_WithStakers {
  uint256 internal constant NEW_MAX_POOL_SIZE = 40_000_000 ether;
  uint256 internal constant NEW_MAX_PRINCIPAL = 80_000 ether;

  function setUp() public override {
    StakingPool_WithStakers.setUp();

    changePrank(OWNER);
  }

  function test_RevertWhen_ConfigChangedByNonAdmin() public {
    vm.expectRevert(
      _getExpectedMissingRoleErrorMessage(STRANGER, s_communityStakingPool.DEFAULT_ADMIN_ROLE())
    );
    changePrank(STRANGER);
    s_communityStakingPool.setPoolConfig(COMMUNITY_MAX_POOL_SIZE, COMMUNITY_MAX_PRINCIPAL);
  }

  function test_RevertWhen_PoolNotOpen() public {
    CommunityStakingPool notOpenedCommunityStakingPool = new CommunityStakingPool(
      CommunityStakingPool.ConstructorParams({
        baseParams: StakingPoolBase.ConstructorParamsBase({
          LINKAddress: s_LINK,
          initialMaxPoolSize: COMMUNITY_MAX_POOL_SIZE,
          initialMaxPrincipalPerStaker: COMMUNITY_MAX_PRINCIPAL,
          minPrincipalPerStaker: COMMUNITY_MIN_PRINCIPAL,
          initialUnbondingPeriod: INITIAL_UNBONDING_PERIOD,
          maxUnbondingPeriod: MAX_UNBONDING_PERIOD,
          initialClaimPeriod: INITIAL_CLAIM_PERIOD,
          minClaimPeriod: MIN_CLAIM_PERIOD,
          maxClaimPeriod: MAX_CLAIM_PERIOD,
          adminRoleTransferDelay: ADMIN_ROLE_TRANSFER_DELAY
        }),
        operatorStakingPool: s_operatorStakingPool
      })
    );
    vm.expectRevert(IStakingOwner.PoolNotOpen.selector);
    notOpenedCommunityStakingPool.setPoolConfig(COMMUNITY_MAX_POOL_SIZE, COMMUNITY_MAX_PRINCIPAL);
  }

  function test_RevertWhen_PoolHasBeenClosed() public {
    changePrank(OWNER);
    s_communityStakingPool.close();
    vm.expectRevert(IStakingOwner.PoolNotOpen.selector);
    s_communityStakingPool.setPoolConfig(COMMUNITY_MAX_POOL_SIZE, COMMUNITY_MAX_PRINCIPAL);
  }

  function test_RevertWhen_TryingToDecreaseMaxPoolSize() public {
    uint256 newMaxPoolSize = COMMUNITY_MAX_POOL_SIZE / 2;
    vm.expectRevert(abi.encodeWithSelector(IStakingOwner.InvalidPoolSize.selector, newMaxPoolSize));
    s_communityStakingPool.setPoolConfig(newMaxPoolSize, COMMUNITY_MAX_PRINCIPAL / 2);
  }

  function test_RevertWhen_NewMaxStakerPrincipalLowerThanCurrentMaxPrincipal() public {
    uint256 newPrincipal = COMMUNITY_MAX_PRINCIPAL / 2;
    vm.expectRevert(
      abi.encodeWithSelector(IStakingOwner.InvalidMaxStakeAmount.selector, newPrincipal)
    );
    s_communityStakingPool.setPoolConfig(COMMUNITY_MAX_POOL_SIZE, newPrincipal);
  }

  function test_RevertWhen_MaxPoolSizeLowerThanMaxPrincipal() public {
    uint256 newPrincipal = COMMUNITY_MAX_POOL_SIZE * 2;
    vm.expectRevert(
      abi.encodeWithSelector(IStakingOwner.InvalidMaxStakeAmount.selector, newPrincipal)
    );
    s_communityStakingPool.setPoolConfig(COMMUNITY_MAX_POOL_SIZE, newPrincipal);
  }

  function test_MaxPoolSizeIncreased() public {
    uint256 newMaxPoolSize = COMMUNITY_MAX_POOL_SIZE * 2;
    s_communityStakingPool.setPoolConfig(newMaxPoolSize, COMMUNITY_MAX_PRINCIPAL);
    assertEq(s_communityStakingPool.getMaxPoolSize(), newMaxPoolSize);
  }

  function test_MaxPrincipalIncreased() public {
    uint256 newMaxPrincipal = COMMUNITY_MAX_PRINCIPAL * 2;
    s_communityStakingPool.setPoolConfig(COMMUNITY_MAX_POOL_SIZE, newMaxPrincipal);
    (, uint256 communityMaxPrincipal) = s_communityStakingPool.getStakerLimits();
    assertEq(communityMaxPrincipal, newMaxPrincipal);
  }

  function test_RevertWhen_TryingToStakeLessThanMinPrincipal() public {
    uint256 stakeAmount = COMMUNITY_MIN_PRINCIPAL - 1;

    changePrank(OWNER);
    s_communityStakingPool.setMerkleRoot(bytes32(''));
    s_LINK.transfer(STRANGER, stakeAmount);

    changePrank(STRANGER);
    vm.expectRevert(IStakingPool.InsufficientStakeAmount.selector);
    s_LINK.transferAndCall(address(s_communityStakingPool), stakeAmount, abi.encode(bytes32('')));
  }

  function test_RevertWhen_TryingToStakeMoreThanMaxPrincipal() public {
    uint256 stakeAmount = COMMUNITY_MAX_PRINCIPAL + 1;

    changePrank(COMMUNITY_STAKER_ONE);

    vm.expectRevert(IStakingPool.ExceedsMaxStakeAmount.selector);
    s_LINK.transferAndCall(
      address(s_communityStakingPool), stakeAmount, abi.encode(s_communityStakerOneProof)
    );
  }

  function test_RevertWhen_TryingToStakeMoreThanMaxPoolSize() public {
    // change max stake size
    uint256 totalPrincipalBefore = s_communityStakingPool.getTotalPrincipal();
    uint256 stakerPrincipalBefore = s_communityStakingPool.getStakerPrincipal(COMMUNITY_STAKER_TWO);
    s_communityStakingPool.setPoolConfig(
      NEW_MAX_POOL_SIZE + totalPrincipalBefore, NEW_MAX_POOL_SIZE + stakerPrincipalBefore
    );
    s_LINK.transfer(COMMUNITY_STAKER_TWO, NEW_MAX_POOL_SIZE);
    s_LINK.transfer(STRANGER, COMMUNITY_MIN_PRINCIPAL);
    s_communityStakingPool.setMerkleRoot(bytes32(''));

    changePrank(COMMUNITY_STAKER_TWO);
    s_LINK.transferAndCall(
      address(s_communityStakingPool), NEW_MAX_POOL_SIZE, abi.encode(bytes32(''))
    );

    changePrank(STRANGER);
    vm.expectRevert(IStakingPool.ExceedsMaxPoolSize.selector);
    s_LINK.transferAndCall(
      address(s_communityStakingPool), COMMUNITY_MIN_PRINCIPAL, abi.encode(bytes32(''))
    );
  }

  function test_RevertWhen_AddingToStakeBringsPrincipalOverMax() public {
    changePrank(COMMUNITY_STAKER_ONE);

    uint256 stakeAmount = COMMUNITY_MAX_PRINCIPAL;
    vm.expectRevert(IStakingPool.ExceedsMaxStakeAmount.selector);
    s_LINK.transferAndCall(
      address(s_communityStakingPool), stakeAmount, abi.encode(s_communityStakerOneProof)
    );
  }
}

contract CommunityStakingPool_SetMigrationProxy is
  IStakingPool_SetMigrationProxy,
  StakingPool_MigrationProxyUnset
{
  event MigrationProxySet(address indexed migrationProxy);

  function test_RevertWhen_NotOwnerSetsMigrationProxy() public {
    changePrank(STRANGER);

    vm.expectRevert(
      _getExpectedMissingRoleErrorMessage(STRANGER, s_communityStakingPool.DEFAULT_ADMIN_ROLE())
    );
    s_communityStakingPool.setMigrationProxy(address(s_migrationProxy));
  }

  function test_RevertWhen_OwnerSetsMigrationProxyToZero() public {
    changePrank(OWNER);

    vm.expectRevert(IStakingPool.InvalidZeroAddress.selector);
    s_communityStakingPool.setMigrationProxy(address(0));
  }

  function test_OwnerCanSetMigrationProxy() public {
    changePrank(OWNER);

    assertEq(s_communityStakingPool.getMigrationProxy(), address(0));
    s_communityStakingPool.setMigrationProxy(address(s_migrationProxy));
    assertEq(s_communityStakingPool.getMigrationProxy(), address(s_migrationProxy));
  }

  function test_EmitsEventWhenMigrationProxySet() public {
    changePrank(OWNER);
    vm.expectEmit(true, true, true, true, address(s_communityStakingPool));
    emit MigrationProxySet(address(s_migrationProxy));
    s_communityStakingPool.setMigrationProxy(address(s_migrationProxy));
  }
}

contract CommunityStakingPool_Openable is IOpenableTest, BaseTest {
  event PoolOpened();
  event PoolClosed();

  function test_RevertWhen_NotOwnerOpens() public {
    changePrank(STRANGER);

    vm.expectRevert(
      _getExpectedMissingRoleErrorMessage(STRANGER, s_communityStakingPool.DEFAULT_ADMIN_ROLE())
    );
    s_communityStakingPool.open();
  }

  function test_OwnerCanOpen() public {
    changePrank(OWNER);

    vm.expectEmit(true, true, true, true, address(s_communityStakingPool));
    emit PoolOpened();
    s_communityStakingPool.open();

    assertEq(s_communityStakingPool.isOpen(), true);
  }

  function test_RevertWhen_AlreadyOpened() public {
    changePrank(OWNER);

    s_communityStakingPool.open();
    vm.expectRevert(IStakingOwner.PoolHasBeenOpened.selector);
    s_communityStakingPool.open();
  }

  function test_RevertWhen_MerkleRootNotSet() public {
    changePrank(OWNER);

    CommunityStakingPool communityStakingPool = new CommunityStakingPool(
      CommunityStakingPool.ConstructorParams({
        operatorStakingPool: s_operatorStakingPool,
        baseParams: StakingPoolBase.ConstructorParamsBase({
          LINKAddress: s_LINK,
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
    communityStakingPool.setRewardVault(s_rewardVault);
    vm.expectRevert(CommunityStakingPool.MerkleRootNotSet.selector);
    communityStakingPool.open();
  }

  function test_RevertWhen_MerkleRootReset() public {
    changePrank(OWNER);

    s_communityStakingPool.setMerkleRoot(bytes32(''));

    vm.expectRevert(CommunityStakingPool.MerkleRootNotSet.selector);
    s_communityStakingPool.open();
  }

  function test_RevertWhen_NotOwnerCloses() public {
    changePrank(OWNER);

    s_communityStakingPool.open();

    changePrank(STRANGER);

    vm.expectRevert(
      _getExpectedMissingRoleErrorMessage(STRANGER, s_communityStakingPool.DEFAULT_ADMIN_ROLE())
    );
    s_communityStakingPool.close();
  }

  function test_OwnerCanClose() public {
    changePrank(OWNER);

    s_communityStakingPool.open();
    assertEq(s_communityStakingPool.isOpen(), true);
    vm.expectEmit(true, true, true, true, address(s_communityStakingPool));
    emit PoolClosed();
    s_communityStakingPool.close();
    assertEq(s_communityStakingPool.isOpen(), false);
  }

  function test_RevertWhen_NotYetOpened() public {
    changePrank(OWNER);

    vm.expectRevert(IStakingOwner.PoolNotOpen.selector);
    s_communityStakingPool.close();
  }

  function test_RevertWhen_AlreadyClosed() public {
    changePrank(OWNER);

    s_communityStakingPool.open();
    s_communityStakingPool.close();
    vm.expectRevert(IStakingOwner.PoolNotOpen.selector);
    s_communityStakingPool.close();
  }

  function test_RevertWhen_TryingToOpenAgain() public {
    changePrank(OWNER);

    // Make sure block.timestamp is not 0
    vm.warp(block.timestamp + 10);

    s_communityStakingPool.open();
    s_communityStakingPool.close();
    vm.expectRevert(IStakingOwner.PoolHasBeenClosed.selector);
    s_communityStakingPool.open();
  }

  function test_RevertWhen_RewardVaultNotOpen() public {
    vm.mockCall(
      address(s_rewardVault),
      0,
      abi.encodeWithSelector(RewardVault.isOpen.selector),
      abi.encode(false)
    );
    changePrank(OWNER);
    vm.expectRevert(StakingPoolBase.RewardVaultNotActive.selector);
    s_communityStakingPool.open();
  }

  function test_RevertWhen_RewardVaultPaused() public {
    vm.mockCall(
      address(s_rewardVault),
      0,
      abi.encodeWithSelector(RewardVault.isOpen.selector),
      abi.encode(true)
    );
    vm.mockCall(
      address(s_rewardVault),
      0,
      abi.encodeWithSelector(RewardVault.isPaused.selector),
      abi.encode(true)
    );
    changePrank(OWNER);
    vm.expectRevert(StakingPoolBase.RewardVaultNotActive.selector);
    s_communityStakingPool.open();
  }
}

contract CommunityStakingPool_Pausable is IPausableTest, BaseTest {
  function test_RevertWhen_NotPauserEmergencyPause() public {
    changePrank(STRANGER);
    vm.expectRevert(
      _getExpectedMissingRoleErrorMessage(STRANGER, s_communityStakingPool.PAUSER_ROLE())
    );

    s_communityStakingPool.emergencyPause();
    assertEq(s_communityStakingPool.paused(), false);
  }

  function test_PauserCanEmergencyPause() public {
    changePrank(PAUSER);

    s_communityStakingPool.emergencyPause();
    assertEq(s_communityStakingPool.paused(), true);
  }

  function test_RevertWhen_PausingWhenAlreadyPaused() public {
    changePrank(PAUSER);
    s_communityStakingPool.emergencyPause();

    vm.expectRevert('Pausable: paused');
    s_communityStakingPool.emergencyPause();
  }

  function test_RevertWhen_NotPauserEmergencyUnpause() public {
    changePrank(PAUSER);
    s_communityStakingPool.emergencyPause();

    changePrank(STRANGER);
    vm.expectRevert(
      _getExpectedMissingRoleErrorMessage(STRANGER, s_communityStakingPool.PAUSER_ROLE())
    );
    s_communityStakingPool.emergencyUnpause();

    assertEq(s_communityStakingPool.paused(), true);
  }

  function test_PauserCanEmergencyUnpause() public {
    changePrank(PAUSER);
    s_communityStakingPool.emergencyPause();
    s_communityStakingPool.emergencyUnpause();
    assertEq(s_communityStakingPool.paused(), false);
  }

  function test_RevertWhen_UnpausingWhenAlreadyUnpaused() public {
    changePrank(PAUSER);

    vm.expectRevert('Pausable: not paused');
    s_communityStakingPool.emergencyUnpause();
  }
}

contract CommunityStakingPool_Unbond_WhenStakeIsNotUnbonding is
  IStakingPool_Unbond_WhenStakeIsNotUnbonding,
  StakingPool_WithStakers
{
  event UnbondingPeriodStarted(address indexed staker);

  function test_RevertWhen_StakerHasNotStaked() external override {
    changePrank(STRANGER);
    vm.expectRevert(abi.encodeWithSelector(IStakingPool.StakeNotFound.selector, STRANGER));
    s_communityStakingPool.unbond();
  }

  function test_CorrectlySetsTheStakersUnbondingPeriod() external override {
    changePrank(COMMUNITY_STAKER_ONE);
    (uint256 unbondingPeriod,) = s_communityStakingPool.getUnbondingParams();
    s_communityStakingPool.unbond();

    assertEq(
      s_communityStakingPool.getUnbondingEndsAt(COMMUNITY_STAKER_ONE),
      block.timestamp + unbondingPeriod
    );
  }

  function test_EmitsEvent() external override {
    vm.expectEmit(true, true, true, true, address(s_communityStakingPool));
    changePrank(COMMUNITY_STAKER_ONE);
    emit UnbondingPeriodStarted(COMMUNITY_STAKER_ONE);
    s_communityStakingPool.unbond();
  }

  function test_CorrectlySetsTheStakersClaimPeriod() external override {
    changePrank(COMMUNITY_STAKER_ONE);
    (uint256 unbondingPeriod, uint256 claimPeriod) = s_communityStakingPool.getUnbondingParams();
    s_communityStakingPool.unbond();

    assertEq(
      s_communityStakingPool.getClaimPeriodEndsAt(COMMUNITY_STAKER_ONE),
      block.timestamp + unbondingPeriod + claimPeriod
    );
  }
}

contract CommunityStakingPool_Unbond_WhenStakeIsUnbonding is
  IStakingPool_Unbond_WhenStakeIsUnbonding,
  StakingPool_InUnbondingPeriod
{
  function test_RevertWhen_StakerIsAlreadyInUnbondingPeriod() external override {
    changePrank(COMMUNITY_STAKER_ONE);
    vm.expectRevert(
      abi.encodeWithSelector(
        StakingPoolBase.UnbondingPeriodActive.selector,
        s_communityStakingPool.getUnbondingEndsAt(COMMUNITY_STAKER_ONE)
      )
    );
    s_communityStakingPool.unbond();
  }

  function test_RevertWhen_StakerIsInClaimPeriod() external override {
    uint256 stakerUnbondingEndsAt = s_communityStakingPool.getUnbondingEndsAt(COMMUNITY_STAKER_ONE);
    vm.warp(stakerUnbondingEndsAt + 1);
    changePrank(COMMUNITY_STAKER_ONE);
    vm.expectRevert(
      abi.encodeWithSelector(
        StakingPoolBase.UnbondingPeriodActive.selector,
        s_communityStakingPool.getUnbondingEndsAt(COMMUNITY_STAKER_ONE)
      )
    );
    s_communityStakingPool.unbond();
  }

  function test_CorrectlySetsTheStakersUnbondingPeriodWhenOutsideClaimPeriod() external override {
    uint256 stakerUnbondingEndsAt = s_communityStakingPool.getUnbondingEndsAt(COMMUNITY_STAKER_ONE);
    (uint256 unbondingPeriod, uint256 claimPeriod) = s_communityStakingPool.getUnbondingParams();
    uint256 unbondedAt = stakerUnbondingEndsAt + claimPeriod + 1;
    vm.warp(unbondedAt);
    changePrank(COMMUNITY_STAKER_ONE);
    s_communityStakingPool.unbond();
    assertEq(
      s_communityStakingPool.getUnbondingEndsAt(COMMUNITY_STAKER_ONE), unbondedAt + unbondingPeriod
    );
  }
}

contract CommunityStakingPool_Unbond_WhenClaimPeriodEndsAt is StakingPool_WhenClaimPeriodEndsAt {
  function test_RevertWhen_StakerIsAtClaimPeriodEndsAt() public {
    changePrank(COMMUNITY_STAKER_ONE);
    vm.expectRevert(
      abi.encodeWithSelector(
        StakingPoolBase.UnbondingPeriodActive.selector,
        s_communityStakingPool.getUnbondingEndsAt(COMMUNITY_STAKER_ONE)
      )
    );
    s_communityStakingPool.unbond();
  }
}

contract CommunityStakingPool_Unbond_WhenStakerStakesAgainDuringUnbondingPeriod is
  IStakingPool_Unbond_WhenStakerStakesAgainDuringUnbondingPeriod,
  StakingPool_StakeInUnbondingPeriod
{
  function test_CorrectlyStartsTheUnbondingPeriod() external {
    changePrank(COMMUNITY_STAKER_ONE);
    s_communityStakingPool.unbond();
    assertEq(
      s_communityStakingPool.getUnbondingEndsAt(COMMUNITY_STAKER_ONE),
      block.timestamp + UNBONDING_PERIOD
    );
  }
}

contract CommunityStakingPool_OnTokenTransfer_WhenMigrationsOnly is StakingPool_MigrationsOnly {
  function test_RevertWhen_StakingWhenOnAllowlistDuringMigrationsOnly() public {
    changePrank(COMMUNITY_STAKER_ONE);
    vm.expectRevert(IStakingPool.AccessForbidden.selector);
    s_LINK.transferAndCall(
      address(s_communityStakingPool),
      COMMUNITY_MIN_PRINCIPAL,
      abi.encode(s_communityStakerOneProof)
    );
  }

  function test_MigrationsOnlyAllowsForStakingThroughMigrationProxy() public {
    changePrank(MOCK_STAKING_V01);
    s_LINK.transferAndCall(
      address(s_migrationProxy), COMMUNITY_MIN_PRINCIPAL, abi.encode(COMMUNITY_STAKER_ONE, '')
    );
  }

  function test_DisablingMigrationsOnlyAllowsForAllowlistStaking() public {
    changePrank(COMMUNITY_STAKER_ONE);
    vm.expectRevert(IStakingPool.AccessForbidden.selector);
    s_LINK.transferAndCall(
      address(s_communityStakingPool),
      COMMUNITY_MIN_PRINCIPAL,
      abi.encode(s_communityStakerOneProof)
    );

    changePrank(OWNER);
    // this step is how we transition from migrations only to access limited phase (set the merkle
    // root to
    // the allowlist)
    s_communityStakingPool.setMerkleRoot(MERKLE_ROOT);

    changePrank(COMMUNITY_STAKER_ONE);
    s_LINK.transferAndCall(
      address(s_communityStakingPool),
      COMMUNITY_MIN_PRINCIPAL,
      abi.encode(s_communityStakerOneProof)
    );
  }

  function test_DisablingMigrationsProxyStillAllowsForStakingThroughMigrationProxy() public {
    changePrank(OWNER);
    // this step is how we transition from migrations only to access limited phase (set the merkle
    // root to
    // the allowlist)
    s_communityStakingPool.setMerkleRoot(MERKLE_ROOT);

    changePrank(MOCK_STAKING_V01);
    s_LINK.transferAndCall(
      address(s_migrationProxy), COMMUNITY_MIN_PRINCIPAL, abi.encode(COMMUNITY_STAKER_ONE, '')
    );
  }
}

contract CommunityStakingPool_OnTokenTransfer_WhenPaused is
  IStakingPool_OnTokenTransfer_WhenPaused,
  StakingPool_WhenPaused
{
  function test_RevertWhen_AttemptingToStakeWhenPaused() public {
    changePrank(COMMUNITY_STAKER_ONE);

    vm.expectRevert('Pausable: paused');
    s_LINK.transferAndCall(
      address(s_communityStakingPool),
      COMMUNITY_MIN_PRINCIPAL,
      abi.encode(s_communityStakerOneProof)
    );
  }

  function test_RevertWhen_AttemptingToMigrateWhenPaused() public {
    changePrank(MOCK_STAKING_V01);

    vm.expectRevert('Pausable: paused');
    s_LINK.transferAndCall(
      address(s_migrationProxy),
      COMMUNITY_MIN_PRINCIPAL + 100 ether,
      abi.encode(COMMUNITY_STAKER_ONE, '')
    );
  }

  function test_CanStakeAfterUnpausing() public {
    changePrank(PAUSER);
    s_communityStakingPool.emergencyUnpause();

    changePrank(COMMUNITY_STAKER_ONE);
    s_LINK.transferAndCall(
      address(s_communityStakingPool),
      COMMUNITY_MIN_PRINCIPAL,
      abi.encode(s_communityStakerOneProof)
    );
  }

  function test_CanMigrateIntoPoolAfterUnpausing() public {
    changePrank(PAUSER);
    s_communityStakingPool.emergencyUnpause();

    changePrank(MOCK_STAKING_V01);
    s_LINK.transferAndCall(
      address(s_migrationProxy),
      COMMUNITY_MIN_PRINCIPAL + 100 ether,
      abi.encode(COMMUNITY_STAKER_ONE, '')
    );
  }
}

contract CommunityStakingPool_OnTokenTransfer_WhenPoolNotOpen is BaseTest {
  function setUp() public override {
    BaseTest.setUp();

    changePrank(OWNER);

    // fund the migration proxy with LINK
    s_LINK.transfer(address(s_migrationProxy), COMMUNITY_MIN_PRINCIPAL);
  }

  function test_RevertWhen_PoolNotOpen() public {
    changePrank(COMMUNITY_STAKER_ONE);

    vm.expectRevert(IStakingOwner.PoolNotOpen.selector);
    s_LINK.transferAndCall(
      address(s_communityStakingPool),
      COMMUNITY_MIN_PRINCIPAL,
      abi.encode(s_communityStakerOneProof)
    );
  }

  function test_RevertWhen_PoolHasBeenClosed() public {
    changePrank(OWNER);
    s_communityStakingPool.open();
    s_communityStakingPool.close();

    changePrank(COMMUNITY_STAKER_ONE);

    vm.expectRevert(IStakingOwner.PoolNotOpen.selector);
    s_LINK.transferAndCall(
      address(s_communityStakingPool),
      COMMUNITY_MIN_PRINCIPAL,
      abi.encode(s_communityStakerOneProof)
    );
  }
}

contract CommunityStakingPool_OnTokenTransfer_WhenPoolOpen is
  IStakingPool_OnTokenTransfer,
  StakingPool_WithStakers
{
  function setUp() public override {
    StakingPool_WithStakers.setUp();

    changePrank(OWNER);

    // fund the migration proxy with LINK
    s_LINK.transfer(address(s_migrationProxy), COMMUNITY_MIN_PRINCIPAL);
  }

  function test_RevertWhen_OnTokenTransferNotFromLINK() public {
    vm.expectRevert(IStakingPool.SenderNotLinkToken.selector);
    s_communityStakingPool.onTokenTransfer(address(0), 0, new bytes(0));
  }

  function test_RevertWhen_RewardVaultPaused() public {
    changePrank(PAUSER);
    s_rewardVault.emergencyPause();
    changePrank(address(s_LINK));
    vm.expectRevert(StakingPoolBase.RewardVaultNotActive.selector);
    s_communityStakingPool.onTokenTransfer(address(0), 0, new bytes(0));
  }

  function test_RevertWhen_StakerAddressInDataIsZero() public {
    changePrank(address(s_migrationProxy));
    vm.expectRevert(IStakingPool.InvalidZeroAddress.selector);
    s_LINK.transferAndCall(
      address(s_communityStakingPool), COMMUNITY_MIN_PRINCIPAL, abi.encode(address(0), '')
    );
  }

  function test_StakingUpdatesPoolStateTotalPrincipal() public {
    changePrank(COMMUNITY_STAKER_ONE);

    uint256 totalPrincipalBefore = s_communityStakingPool.getTotalPrincipal();

    s_LINK.transferAndCall(
      address(s_communityStakingPool),
      COMMUNITY_MIN_PRINCIPAL,
      abi.encode(s_communityStakerOneProof)
    );
    assertEq(
      s_communityStakingPool.getTotalPrincipal(), totalPrincipalBefore + COMMUNITY_MIN_PRINCIPAL
    );
  }

  function test_StakingUpdatesStakerState() public {
    changePrank(COMMUNITY_STAKER_ONE);

    uint256 stakerPrincipalBefore = s_communityStakingPool.getStakerPrincipal(COMMUNITY_STAKER_ONE);

    s_LINK.transferAndCall(
      address(s_communityStakingPool),
      COMMUNITY_MIN_PRINCIPAL,
      abi.encode(s_communityStakerOneProof)
    );
    assertEq(
      s_communityStakingPool.getStakerPrincipal(COMMUNITY_STAKER_ONE),
      stakerPrincipalBefore + COMMUNITY_MIN_PRINCIPAL
    );

    // stake more
    vm.warp(block.timestamp + 10);
    stakerPrincipalBefore = s_communityStakingPool.getStakerPrincipal(COMMUNITY_STAKER_ONE);
    s_LINK.transferAndCall(
      address(s_communityStakingPool),
      COMMUNITY_MIN_PRINCIPAL,
      abi.encode(s_communityStakerOneProof)
    );

    assertEq(
      s_communityStakingPool.getStakerPrincipal(COMMUNITY_STAKER_ONE),
      stakerPrincipalBefore + COMMUNITY_MIN_PRINCIPAL
    );
    assertEq(s_communityStakingPool.getStakerStakedAtTime(COMMUNITY_STAKER_ONE), block.timestamp);
  }

  function test_StakingZeroAmountHasNoStateChanges() public {
    changePrank(COMMUNITY_STAKER_ONE);

    uint256 stakerPrincipalBefore = s_communityStakingPool.getStakerPrincipal(COMMUNITY_STAKER_ONE);

    s_LINK.transferAndCall(
      address(s_communityStakingPool),
      COMMUNITY_MIN_PRINCIPAL,
      abi.encode(s_communityStakerOneProof)
    );
    assertEq(
      s_communityStakingPool.getStakerPrincipal(COMMUNITY_STAKER_ONE),
      stakerPrincipalBefore + COMMUNITY_MIN_PRINCIPAL
    );

    // stake 0
    vm.warp(block.timestamp + 10);
    stakerPrincipalBefore = s_communityStakingPool.getStakerPrincipal(COMMUNITY_STAKER_ONE);
    uint256 stakedAtTimeBefore = s_communityStakingPool.getStakerStakedAtTime(COMMUNITY_STAKER_ONE);
    s_LINK.transferAndCall(
      address(s_communityStakingPool), 0, abi.encode(s_communityStakerOneProof)
    );

    assertEq(s_communityStakingPool.getStakerPrincipal(COMMUNITY_STAKER_ONE), stakerPrincipalBefore);
    assertEq(s_communityStakingPool.getStakerStakedAtTime(COMMUNITY_STAKER_ONE), stakedAtTimeBefore);
  }

  function test_StakingWithNoTimePassedSinceAvgStakingDoesNotUpdateAvgStakingTime() public {
    changePrank(COMMUNITY_STAKER_ONE);

    uint256 stakedAtTimeBefore = s_communityStakingPool.getStakerStakedAtTime(COMMUNITY_STAKER_ONE);
    assertEq(s_communityStakingPool.getStakerStakedAtTime(COMMUNITY_STAKER_ONE), block.timestamp);

    s_LINK.transferAndCall(
      address(s_communityStakingPool),
      COMMUNITY_MIN_PRINCIPAL,
      abi.encode(s_communityStakerOneProof)
    );

    assertEq(s_communityStakingPool.getStakerStakedAtTime(COMMUNITY_STAKER_ONE), stakedAtTimeBefore);
  }

  function test_StakingUpdatesTheCheckpointId() public {
    uint256 prevCheckpointId = s_communityStakingPool.getCurrentCheckpointId();
    changePrank(COMMUNITY_STAKER_ONE);
    s_LINK.transferAndCall(
      address(s_communityStakingPool),
      COMMUNITY_MIN_PRINCIPAL,
      abi.encode(s_communityStakerOneProof)
    );
    assertEq(s_communityStakingPool.getCurrentCheckpointId(), prevCheckpointId + 1);
  }

  function test_RevertWhen_MigrationProxyNotSet() public {
    // deploy a new CommunityStakingPool
    CommunityStakingPool communityStakingPool = new CommunityStakingPool(
      CommunityStakingPool.ConstructorParams({
        operatorStakingPool: s_operatorStakingPool,
        baseParams: StakingPoolBase.ConstructorParamsBase({
          LINKAddress: s_LINK,
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

    changePrank(COMMUNITY_STAKER_ONE);

    vm.expectRevert(abi.encodeWithSelector(IStakingPool.MigrationProxyNotSet.selector));
    s_LINK.transferAndCall(address(communityStakingPool), COMMUNITY_MIN_PRINCIPAL, '');
  }

  function test_RevertWhen_OnTokenTransferDataIsEmptyFromMigrationProxy() public {
    changePrank(address(s_migrationProxy));

    vm.expectRevert(IStakingPool.InvalidData.selector);
    s_LINK.transferAndCall(address(s_communityStakingPool), COMMUNITY_MIN_PRINCIPAL, '');
  }

  function test_StakingThroughMigrationProxyUpdatesPoolStateTotalPrincipal() public {
    // define staker data
    bytes memory stakerData = abi.encode(COMMUNITY_MIN_PRINCIPAL, 0);
    // define migration proxy data
    bytes memory migrationProxyData = abi.encode(COMMUNITY_STAKER_ONE, stakerData);

    changePrank(address(s_migrationProxy));

    uint256 totalPrincipalBefore = s_communityStakingPool.getTotalPrincipal();

    s_LINK.transferAndCall(
      address(s_communityStakingPool), COMMUNITY_MIN_PRINCIPAL, migrationProxyData
    );
    assertEq(
      s_communityStakingPool.getTotalPrincipal(), totalPrincipalBefore + COMMUNITY_MIN_PRINCIPAL
    );
  }

  function test_StakingThroughMigrationProxyUpdatesStakerState() public {
    // define staker data
    bytes memory stakerData = abi.encode(COMMUNITY_MIN_PRINCIPAL, COMMUNITY_MIN_PRINCIPAL);
    // define migration proxy data
    bytes memory migrationProxyData = abi.encode(COMMUNITY_STAKER_ONE, stakerData);

    changePrank(address(s_migrationProxy));

    uint256 stakerPrincipalBefore = s_communityStakingPool.getStakerPrincipal(COMMUNITY_STAKER_ONE);

    s_LINK.transferAndCall(
      address(s_communityStakingPool), COMMUNITY_MIN_PRINCIPAL, migrationProxyData
    );
    assertEq(
      s_communityStakingPool.getStakerPrincipal(COMMUNITY_STAKER_ONE),
      stakerPrincipalBefore + COMMUNITY_MIN_PRINCIPAL
    );

    assertEq(s_communityStakingPool.getStakerStakedAtTime(COMMUNITY_STAKER_ONE), block.timestamp);
  }

  function test_RevertWhen_StakingWithoutAccess() public {
    // fund stranger address
    changePrank(OWNER);
    s_LINK.transfer(STRANGER, COMMUNITY_MIN_PRINCIPAL);

    changePrank(STRANGER);

    vm.expectRevert(IStakingPool.AccessForbidden.selector);
    s_LINK.transferAndCall(
      address(s_communityStakingPool),
      COMMUNITY_MIN_PRINCIPAL,
      abi.encode(s_communityStakerOneProof)
    );
  }

  function test_RevertWhen_StakingAsNodeOperator() public {
    // add community staker one as node operator
    changePrank(OWNER);
    address[] memory operators = new address[](1);
    operators[0] = PUBLIC_COMMUNITY_STAKER;
    s_operatorStakingPool.addOperators(operators);

    changePrank(PUBLIC_COMMUNITY_STAKER);

    vm.expectRevert(IStakingPool.AccessForbidden.selector);
    s_LINK.transferAndCall(
      address(s_communityStakingPool),
      COMMUNITY_MIN_PRINCIPAL,
      abi.encode(s_communityStakerOneProof)
    );
  }

  function test_StakingUpdatesTheStakerTypeInRewardVault() public {
    // make general access
    changePrank(OWNER);
    s_communityStakingPool.setMerkleRoot(bytes32(''));
    IRewardVault.StakerReward memory stakerReward =
      s_rewardVault.getStoredReward(PUBLIC_COMMUNITY_STAKER);
    assertEq(uint256(stakerReward.stakerType), uint256(IRewardVault.StakerType.NOT_STAKED));
    changePrank(PUBLIC_COMMUNITY_STAKER);
    s_LINK.transferAndCall(address(s_communityStakingPool), COMMUNITY_MIN_PRINCIPAL, '');
    stakerReward = s_rewardVault.getStoredReward(PUBLIC_COMMUNITY_STAKER);
    assertEq(uint256(stakerReward.stakerType), uint256(IRewardVault.StakerType.COMMUNITY));
  }

  function test_RestakingDoesNotUpdateTheStakerTypeInRewardVault() public {
    // make general access
    changePrank(OWNER);
    s_communityStakingPool.setMerkleRoot(bytes32(''));
    changePrank(PUBLIC_COMMUNITY_STAKER);
    s_LINK.transferAndCall(address(s_communityStakingPool), COMMUNITY_MIN_PRINCIPAL, '');
    IRewardVault.StakerReward memory stakerReward =
      s_rewardVault.getStoredReward(PUBLIC_COMMUNITY_STAKER);
    assertEq(uint256(stakerReward.stakerType), uint256(IRewardVault.StakerType.COMMUNITY));
    s_LINK.transferAndCall(address(s_communityStakingPool), COMMUNITY_MIN_PRINCIPAL, '');
    stakerReward = s_rewardVault.getStoredReward(PUBLIC_COMMUNITY_STAKER);
    assertEq(uint256(stakerReward.stakerType), uint256(IRewardVault.StakerType.COMMUNITY));
  }
}

contract CommunityStakingPool_OnTokenTransfer_WhenOperatorIsRemoved is StakingPool_WithStakers {
  function setUp() public override {
    StakingPool_WithStakers.setUp();
    changePrank(OWNER);
    s_communityStakingPool.setMerkleRoot(bytes32(''));
    address[] memory operators = new address[](1);
    operators[0] = OPERATOR_STAKER_ONE;
    s_operatorStakingPool.removeOperators(operators);
  }

  function test_RevertWhen_RemovedOperatorTriesToStake() public {
    vm.expectRevert(IStakingPool.AccessForbidden.selector);
    changePrank(OPERATOR_STAKER_ONE);
    s_LINK.transferAndCall(address(s_communityStakingPool), COMMUNITY_MIN_PRINCIPAL, abi.encode(''));
  }
}

contract CommunityStakingPool_OnTokenTransfer_WhenThereAreOtherStakers is
  IStakingPool_OnTokenTransfer_WhenThereOtherStakers,
  StakingPool_WithStakers
{
  uint256 private s_currentCheckpointId;

  function setUp() public override {
    StakingPool_WithStakers.setUp();
    s_currentCheckpointId = s_communityStakingPool.getCurrentCheckpointId();
  }

  function test_StakingMultipleTimesTracksPreviousBalance() public {
    changePrank(COMMUNITY_STAKER_ONE);
    s_LINK.transferAndCall(
      address(s_communityStakingPool),
      COMMUNITY_MIN_PRINCIPAL,
      abi.encode(s_communityStakerOneProof)
    );

    assertEq(
      s_communityStakingPool.getStakerPrincipalAt(COMMUNITY_STAKER_ONE, s_currentCheckpointId - 1),
      COMMUNITY_MIN_PRINCIPAL
    );
  }

  function test_StakingMultipleTimesTracksPreviousAverageStakedAtTime() public {
    uint256 stakedAtTimeBefore = s_communityStakingPool.getStakerStakedAtTime(COMMUNITY_STAKER_ONE);
    changePrank(COMMUNITY_STAKER_ONE);
    s_LINK.transferAndCall(
      address(s_communityStakingPool),
      COMMUNITY_MIN_PRINCIPAL,
      abi.encode(s_communityStakerOneProof)
    );

    assertEq(
      s_communityStakingPool.getStakerStakedAtTimeAt(
        COMMUNITY_STAKER_ONE, s_currentCheckpointId - 1
      ),
      stakedAtTimeBefore
    );
  }

  function test_StakingUpdatesTheLatestBalance() public {
    changePrank(COMMUNITY_STAKER_ONE);
    s_LINK.transferAndCall(
      address(s_communityStakingPool),
      COMMUNITY_MIN_PRINCIPAL,
      abi.encode(s_communityStakerOneProof)
    );

    assertEq(
      s_communityStakingPool.getStakerPrincipal(COMMUNITY_STAKER_ONE), 2 * COMMUNITY_MIN_PRINCIPAL
    );
  }

  function test_StakingDoesNotAffectOtherStakersHistoricalBalance() public {
    changePrank(COMMUNITY_STAKER_TWO);
    s_LINK.transferAndCall(
      address(s_communityStakingPool),
      COMMUNITY_MIN_PRINCIPAL,
      abi.encode(s_communityStakerTwoProof)
    );

    assertEq(
      s_communityStakingPool.getStakerPrincipalAt(COMMUNITY_STAKER_ONE, s_currentCheckpointId - 1),
      COMMUNITY_MIN_PRINCIPAL
    );
  }

  function test_StakingDoesNotAffectOtherStakersAverageStakedAtTime() public {
    uint256 stakedAtTimeBefore = s_communityStakingPool.getStakerStakedAtTime(COMMUNITY_STAKER_ONE);
    changePrank(COMMUNITY_STAKER_TWO);
    s_LINK.transferAndCall(
      address(s_communityStakingPool),
      COMMUNITY_MIN_PRINCIPAL,
      abi.encode(s_communityStakerTwoProof)
    );

    assertEq(
      s_communityStakingPool.getStakerStakedAtTimeAt(
        COMMUNITY_STAKER_ONE, s_currentCheckpointId - 1
      ),
      stakedAtTimeBefore
    );
  }
}

contract CommunityStakingPool_OnTokenTransfer_WhenRewardVaultNotActive is StakingPool_WithStakers {
  function test_RevertWhen_RewardVaultHasBeenClosed() public {
    changePrank(OWNER);
    s_rewardVault.close();

    changePrank(COMMUNITY_STAKER_ONE);
    vm.expectRevert(StakingPoolBase.RewardVaultNotActive.selector);
    s_LINK.transferAndCall(
      address(s_communityStakingPool),
      COMMUNITY_MIN_PRINCIPAL,
      abi.encode(s_communityStakerOneProof)
    );
  }
}

contract CommunityStakingPool_OnTokenTransfer_WhenStakeIsUnbonding is
  IStakingPool_OnTokenTransfer_WhenStakeIsUnbonding,
  StakingPool_InUnbondingPeriod
{
  event UnbondingPeriodReset(address indexed staker);

  function test_ResetsUnbondingPeriod() external {
    assertGt(s_communityStakingPool.getUnbondingEndsAt(COMMUNITY_STAKER_ONE), 0);
    changePrank(COMMUNITY_STAKER_ONE);
    s_LINK.transferAndCall(
      address(s_communityStakingPool),
      COMMUNITY_MIN_PRINCIPAL,
      abi.encode(s_communityStakerOneProof)
    );
    assertEq(s_communityStakingPool.getUnbondingEndsAt(COMMUNITY_STAKER_ONE), 0);
  }

  function test_CorrectlyStartsTheUnbondingPeriod() external {
    changePrank(COMMUNITY_STAKER_ONE);
    s_LINK.transferAndCall(
      address(s_communityStakingPool),
      COMMUNITY_MIN_PRINCIPAL,
      abi.encode(s_communityStakerOneProof)
    );
    changePrank(COMMUNITY_STAKER_ONE);
    s_communityStakingPool.unbond();
    assertEq(
      s_communityStakingPool.getUnbondingEndsAt(COMMUNITY_STAKER_ONE),
      block.timestamp + UNBONDING_PERIOD
    );
  }

  function test_EmitsCorrectEvent() external {
    vm.expectEmit(true, true, true, true, address(s_communityStakingPool));
    emit UnbondingPeriodReset(COMMUNITY_STAKER_ONE);
    changePrank(COMMUNITY_STAKER_ONE);
    s_LINK.transferAndCall(
      address(s_communityStakingPool),
      COMMUNITY_MIN_PRINCIPAL,
      abi.encode(s_communityStakerOneProof)
    );
  }
}

contract CommunityStakingPool_HasAccess_WhenPoolIsPrivate is BaseTest {
  function test_EarlyAccessCommunityStakersHasAccess() public {
    assertEq(
      s_communityStakingPool.hasAccess(COMMUNITY_STAKER_ONE, s_communityStakerOneProof), true
    );
    assertEq(
      s_communityStakingPool.hasAccess(COMMUNITY_STAKER_TWO, s_communityStakerTwoProof), true
    );
  }

  function test_NonEarlyAccessCommunityStakerHasNoAccess() public {
    bytes32[] memory proof;
    assertEq(s_communityStakingPool.hasAccess(address(1000), proof), false);
  }

  function test_CanMakePoolPublic() public {
    s_communityStakingPool.setMerkleRoot(bytes32(''));
    bytes32[] memory proof = new bytes32[](0);
    assertEq(s_communityStakingPool.hasAccess(PUBLIC_COMMUNITY_STAKER, proof), true);
  }
}

contract CommunityStakingPool_HasAccess_WhenPoolIsPublic is BaseTest {
  function setUp() public override {
    BaseTest.setUp();
    s_communityStakingPool.setMerkleRoot(bytes32(''));
  }

  function test_NonEarlyAccessCommunityStakerHasAccess() public {
    bytes32[] memory proof = new bytes32[](0);
    assertEq(s_communityStakingPool.hasAccess(PUBLIC_COMMUNITY_STAKER, proof), true);
  }
}

contract CommunityStakingPool_SetMerkleRoot is BaseTest {
  event MerkleRootChanged(bytes32 newMerkleRoot);

  function test_RevertWhen_CalledByNonAdminAddress() public {
    changePrank(STRANGER);
    vm.expectRevert(
      _getExpectedMissingRoleErrorMessage(STRANGER, s_communityStakingPool.DEFAULT_ADMIN_ROLE())
    );
    s_communityStakingPool.setMerkleRoot(bytes32('foo'));
  }

  function test_UpdatesTheMerkleRoot() public {
    bytes32 merkleRoot = bytes32('foo');
    s_communityStakingPool.setMerkleRoot(merkleRoot);
    assertEq(s_communityStakingPool.getMerkleRoot(), merkleRoot);
  }

  function test_EmitsEvent() public {
    bytes32 newMerkleRoot = bytes32('foo');
    vm.expectEmit(false, false, false, true, address(s_communityStakingPool));
    emit MerkleRootChanged(newMerkleRoot);
    s_communityStakingPool.setMerkleRoot(newMerkleRoot);
  }
}

contract CommunityStakingPool_SetOperatorStakingPool is BaseTest {
  event OperatorStakingPoolChanged(
    address indexed oldOperatorStakingPool, address indexed newOperatorStakingPool
  );

  OperatorStakingPool private s_operatorStakingPoolV2;

  function setUp() public override {
    BaseTest.setUp();
    s_operatorStakingPoolV2 = new OperatorStakingPool(
      OperatorStakingPool.ConstructorParams({
        minInitialOperatorCount: MIN_INITIAL_OPERATOR_COUNT,
        baseParams: StakingPoolBase.ConstructorParamsBase({
          LINKAddress: s_LINK,
          initialMaxPoolSize: OPERATOR_MAX_POOL_SIZE,
          initialMaxPrincipalPerStaker: OPERATOR_MAX_PRINCIPAL,
          minPrincipalPerStaker: OPERATOR_MIN_PRINCIPAL,
          initialUnbondingPeriod: INITIAL_UNBONDING_PERIOD,
          maxUnbondingPeriod: MAX_UNBONDING_PERIOD,
          initialClaimPeriod: INITIAL_CLAIM_PERIOD,
          minClaimPeriod: MIN_CLAIM_PERIOD,
          maxClaimPeriod: MAX_CLAIM_PERIOD,
          adminRoleTransferDelay: ADMIN_ROLE_TRANSFER_DELAY
        })
      })
    );
  }

  function test_RevertWhen_CalledByNonAdmin() public {
    changePrank(STRANGER);
    vm.expectRevert(
      _getExpectedMissingRoleErrorMessage(STRANGER, s_communityStakingPool.DEFAULT_ADMIN_ROLE())
    );
    s_communityStakingPool.setOperatorStakingPool(s_operatorStakingPoolV2);
  }

  function test_RevertWhen_ProvidedOperatorStakingPoolAddressIsZero() public {
    changePrank(OWNER);
    vm.expectRevert(IStakingPool.InvalidZeroAddress.selector);
    s_communityStakingPool.setOperatorStakingPool(OperatorStakingPool(address(0)));
  }

  function test_SetsOperatorStakingPool() public {
    changePrank(OWNER);
    vm.expectEmit(true, true, true, true, address(s_communityStakingPool));
    emit OperatorStakingPoolChanged(
      address(s_operatorStakingPool), address(s_operatorStakingPoolV2)
    );
    s_communityStakingPool.setOperatorStakingPool(s_operatorStakingPoolV2);
  }
}

contract CommunityStakingPool_Unstake is
  IStakingPool_Unstake,
  IStakingPool_Unstake_WhenPoolClosed,
  StakingPool_InClaimPeriod
{
  event RewardClaimed(address indexed staker, uint256 claimedRewards);

  function test_RevertWhen_UnstakeAmountIsZero() public {
    changePrank(COMMUNITY_STAKER_ONE);
    vm.expectRevert(IStakingPool.UnstakeZeroAmount.selector);
    s_communityStakingPool.unstake(0, false);
  }

  function test_RevertWhen_UnstakeAmountIsGreaterThanPrincipal() public {
    uint256 unstakeAmount = s_communityStakingPool.getStakerPrincipal(COMMUNITY_STAKER_ONE) + 1;
    changePrank(COMMUNITY_STAKER_ONE);
    vm.expectRevert(IStakingPool.UnstakeExceedsPrincipal.selector);
    s_communityStakingPool.unstake(unstakeAmount, false);
  }

  function test_RevertWhen_UnstakeAmountLeavesStakerWithLessThanMinPrincipal() public {
    uint256 unstakeAmount =
      s_communityStakingPool.getStakerPrincipal(COMMUNITY_STAKER_TWO) - COMMUNITY_MIN_PRINCIPAL + 1;
    changePrank(COMMUNITY_STAKER_TWO);
    vm.expectRevert(IStakingPool.UnstakePrincipalBelowMinAmount.selector);
    s_communityStakingPool.unstake(unstakeAmount, false);
  }

  function test_CorrectlyUpdatesPoolStateTotalPrincipal() public {
    uint256 initialPrincipal = s_communityStakingPool.getTotalPrincipal();
    changePrank(COMMUNITY_STAKER_ONE);
    s_communityStakingPool.unstake(COMMUNITY_MIN_PRINCIPAL, false);
    assertEq(s_communityStakingPool.getTotalPrincipal(), initialPrincipal - COMMUNITY_MIN_PRINCIPAL);
  }

  function test_CorrectlyUpdatesStakerStatePrincipal() public {
    uint256 initialPrincipal = s_communityStakingPool.getStakerPrincipal(COMMUNITY_STAKER_ONE);
    changePrank(COMMUNITY_STAKER_ONE);
    s_communityStakingPool.unstake(COMMUNITY_MIN_PRINCIPAL, false);
    assertEq(
      s_communityStakingPool.getStakerPrincipal(COMMUNITY_STAKER_ONE),
      initialPrincipal - COMMUNITY_MIN_PRINCIPAL
    );
  }

  function test_CorrectlyTransferTokensToStaker() public {
    uint256 initialBalance = s_LINK.balanceOf(COMMUNITY_STAKER_ONE);
    changePrank(COMMUNITY_STAKER_ONE);
    s_communityStakingPool.unstake(COMMUNITY_MIN_PRINCIPAL, false);
    assertEq(s_LINK.balanceOf(COMMUNITY_STAKER_ONE), initialBalance + COMMUNITY_MIN_PRINCIPAL);
  }

  function test_EmitsEvent() public {
    changePrank(COMMUNITY_STAKER_ONE);
    vm.expectEmit(true, true, true, true, address(s_communityStakingPool));
    emit Unstaked(COMMUNITY_STAKER_ONE, COMMUNITY_MIN_PRINCIPAL, 0);
    s_communityStakingPool.unstake(COMMUNITY_MIN_PRINCIPAL, false);
  }

  function test_AllowsMultipleUnstakesInClaimPeriod() public {
    uint256 initialPrincipal = s_communityStakingPool.getStakerPrincipal(COMMUNITY_STAKER_TWO);
    changePrank(COMMUNITY_STAKER_TWO);
    s_communityStakingPool.unstake(COMMUNITY_MIN_PRINCIPAL, false);
    s_communityStakingPool.unstake(COMMUNITY_MIN_PRINCIPAL, false);
    assertEq(
      s_communityStakingPool.getStakerPrincipal(COMMUNITY_STAKER_ONE),
      initialPrincipal - COMMUNITY_MIN_PRINCIPAL * 2
    );
  }

  function test_ClaimsRewardsIfShouldClaimRewardSetToTrue() public {
    uint256 initialBalance = s_LINK.balanceOf(COMMUNITY_STAKER_ONE);
    uint256 reward = s_rewardVault.getReward(COMMUNITY_STAKER_ONE);

    changePrank(COMMUNITY_STAKER_ONE);

    vm.expectEmit(true, true, true, true, address(s_rewardVault));
    emit RewardClaimed(COMMUNITY_STAKER_ONE, reward);

    s_communityStakingPool.unstake(COMMUNITY_MIN_PRINCIPAL, true);
    assertEq(
      s_LINK.balanceOf(COMMUNITY_STAKER_ONE), initialBalance + COMMUNITY_MIN_PRINCIPAL + reward
    );
    assertEq(s_rewardVault.getStoredReward(COMMUNITY_STAKER_ONE).storedBaseReward, 0);
  }

  function test_DoesNotClaimRewardIfShouldClaimRewardSetToTrueButNoRewardAccrued() public {
    changePrank(COMMUNITY_STAKER_TWO);

    uint256 principal = s_communityStakingPool.getStakerPrincipal(COMMUNITY_STAKER_TWO);
    (uint256 minPrincipal,) = s_communityStakingPool.getStakerLimits();
    s_communityStakingPool.unstake(principal - minPrincipal, true);

    assertEq(s_rewardVault.getReward(COMMUNITY_STAKER_TWO), 0);

    vm.expectRevert(RewardVault.NoRewardToClaim.selector);
    s_communityStakingPool.unstake(minPrincipal, true);
  }

  function test_CanUnstakeIfPoolClosed() public {
    changePrank(OWNER);

    s_communityStakingPool.close();

    changePrank(COMMUNITY_STAKER_ONE);

    vm.expectEmit(true, true, true, true, address(s_communityStakingPool));
    emit Unstaked(COMMUNITY_STAKER_ONE, COMMUNITY_MIN_PRINCIPAL, 0);
    s_communityStakingPool.unstake(COMMUNITY_MIN_PRINCIPAL, false);
  }

  function test_CorrectlyIncrementsTheCheckpointId() public {
    uint256 prevCheckpointId = s_communityStakingPool.getCurrentCheckpointId();
    changePrank(COMMUNITY_STAKER_ONE);
    s_communityStakingPool.unstake(COMMUNITY_MIN_PRINCIPAL, false);
    assertEq(s_communityStakingPool.getCurrentCheckpointId(), prevCheckpointId + 1);
  }
}

contract CommunityStakingPool_Unstake_WhenThereAreMoreThanTwoStakers is
  StakingPool_InClaimPeriod,
  IStakingPool_Unstake_WhenMoreThanTwoStakers
{
  uint256 private constant TIME_AFTER_THIRD_STAKER_STAKES = 5 days;
  uint256 private s_timeThirdStakerStakes;

  function setUp() public override {
    StakingPool_InClaimPeriod.setUp();

    changePrank(OWNER);
    s_communityStakingPool.setMerkleRoot(bytes32(''));
    s_communityStakingPool.setPoolConfig(COMMUNITY_MAX_POOL_SIZE, COMMUNITY_MAX_PRINCIPAL);

    changePrank(PUBLIC_COMMUNITY_STAKER);
    s_LINK.transferAndCall(
      address(s_communityStakingPool), COMMUNITY_MIN_PRINCIPAL * 2, abi.encode('')
    );
    s_timeThirdStakerStakes = block.timestamp;
    skip(TIME_AFTER_THIRD_STAKER_STAKES);
  }

  function test_DistributesCorrectAmountToFirstStakerIfFullyUnstaking() public {
    changePrank(COMMUNITY_STAKER_TWO);
    s_communityStakingPool.unstake(COMMUNITY_MIN_PRINCIPAL * 3, false);

    uint256 multiplier =
      _calculateStakerMultiplier(s_stakedAtTime, block.timestamp, INITIAL_MULTIPLIER_DURATION);

    // Calculate amount of forfeited rewards
    uint256 unstakingStakerFullRewards = _calculateStakerExpectedReward(
      3 * COMMUNITY_MIN_PRINCIPAL,
      4 * COMMUNITY_MIN_PRINCIPAL,
      _calculateBucketVestedRewards(
        s_rewardVault.getRewardBuckets().communityBase, s_stakedAtTime, s_timeThirdStakerStakes
      )
    )
      + _calculateStakerExpectedReward(
        3 * COMMUNITY_MIN_PRINCIPAL,
        6 * COMMUNITY_MIN_PRINCIPAL,
        _calculateBucketVestedRewards(
          s_rewardVault.getRewardBuckets().communityBase, s_timeThirdStakerStakes, block.timestamp
        )
      );
    uint256 forfeitedRewards =
      unstakingStakerFullRewards - multiplier * unstakingStakerFullRewards / FixedPointMathLib.WAD;
    uint256 remainingStakerPrincipal = COMMUNITY_MIN_PRINCIPAL;
    uint256 totalRemainingPrincipal = COMMUNITY_MIN_PRINCIPAL * 3;
    uint256 forfeitedRewardsPerToken =
      FixedPointMathLib.divWadDown(forfeitedRewards, totalRemainingPrincipal);

    uint256 rewardsForfeitedToRemainingStaker =
      FixedPointMathLib.mulWadDown(forfeitedRewardsPerToken, remainingStakerPrincipal);

    uint256 remainingStakerBaseRewards = _calculateStakerExpectedReward(
      COMMUNITY_MIN_PRINCIPAL,
      4 * COMMUNITY_MIN_PRINCIPAL,
      _calculateBucketVestedRewards(
        s_rewardVault.getRewardBuckets().communityBase, s_stakedAtTime, s_timeThirdStakerStakes
      )
    )
      + _calculateStakerExpectedReward(
        COMMUNITY_MIN_PRINCIPAL,
        6 * COMMUNITY_MIN_PRINCIPAL,
        _calculateBucketVestedRewards(
          s_rewardVault.getRewardBuckets().communityBase, s_timeThirdStakerStakes, block.timestamp
        )
      );

    assertEq(
      s_rewardVault.getReward(COMMUNITY_STAKER_ONE),
      (remainingStakerBaseRewards + rewardsForfeitedToRemainingStaker) * multiplier
        / FixedPointMathLib.WAD
    );
  }

  function test_DistributesCorrectAmountToSecondStakerIfFullyUnstaking() public {
    changePrank(COMMUNITY_STAKER_TWO);
    s_communityStakingPool.unstake(COMMUNITY_MIN_PRINCIPAL * 3, false);

    uint256 multiplier =
      _calculateStakerMultiplier(s_stakedAtTime, block.timestamp, INITIAL_MULTIPLIER_DURATION);

    // Calculate amount of forfeited rewards
    uint256 unstakingStakerFullReward = _calculateStakerExpectedReward(
      3 * COMMUNITY_MIN_PRINCIPAL,
      4 * COMMUNITY_MIN_PRINCIPAL,
      _calculateBucketVestedRewards(
        s_rewardVault.getRewardBuckets().communityBase, s_stakedAtTime, s_timeThirdStakerStakes
      )
    )
      + _calculateStakerExpectedReward(
        3 * COMMUNITY_MIN_PRINCIPAL,
        6 * COMMUNITY_MIN_PRINCIPAL,
        _calculateBucketVestedRewards(
          s_rewardVault.getRewardBuckets().communityBase, s_timeThirdStakerStakes, block.timestamp
        )
      );
    uint256 forfeitedRewards =
      unstakingStakerFullReward - multiplier * unstakingStakerFullReward / FixedPointMathLib.WAD;
    uint256 remainingStakerPrincipal = 2 * COMMUNITY_MIN_PRINCIPAL;
    uint256 totalRemainingPrincipal = 3 * COMMUNITY_MIN_PRINCIPAL;
    uint256 forfeitedRewardsPerToken =
      FixedPointMathLib.divWadDown(forfeitedRewards, totalRemainingPrincipal);

    uint256 rewardsForfeitedToRemainingStaker =
      FixedPointMathLib.mulWadDown(forfeitedRewardsPerToken, remainingStakerPrincipal);

    uint256 remainingStakerMultiplier = _calculateStakerMultiplier(
      s_timeThirdStakerStakes, block.timestamp, INITIAL_MULTIPLIER_DURATION
    );

    uint256 remainingStakerRewards = _calculateStakerExpectedReward(
      2 * COMMUNITY_MIN_PRINCIPAL,
      6 * COMMUNITY_MIN_PRINCIPAL,
      _calculateBucketVestedRewards(
        s_rewardVault.getRewardBuckets().communityBase, s_timeThirdStakerStakes, block.timestamp
      )
    );
    assertEq(
      s_rewardVault.getReward(PUBLIC_COMMUNITY_STAKER),
      (remainingStakerRewards + rewardsForfeitedToRemainingStaker) * remainingStakerMultiplier
        / FixedPointMathLib.WAD
    );
  }

  function test_DistributesCorrectAmountToFirstStakerIfPartiallyUnstaking() public {
    changePrank(COMMUNITY_STAKER_TWO);
    uint256 stakerPrincipalBefore = 3 * COMMUNITY_MIN_PRINCIPAL;
    uint256 unstakeAmount = COMMUNITY_MIN_PRINCIPAL / 2;
    s_communityStakingPool.unstake(unstakeAmount, false);

    uint256 multiplier =
      _calculateStakerMultiplier(s_stakedAtTime, block.timestamp, INITIAL_MULTIPLIER_DURATION);

    // Calculate amount of forfeited rewards
    uint256 unstakingStakerFullRewards = _calculateStakerExpectedReward(
      3 * COMMUNITY_MIN_PRINCIPAL,
      4 * COMMUNITY_MIN_PRINCIPAL,
      _calculateBucketVestedRewards(
        s_rewardVault.getRewardBuckets().communityBase, s_stakedAtTime, s_timeThirdStakerStakes
      )
    )
      + _calculateStakerExpectedReward(
        3 * COMMUNITY_MIN_PRINCIPAL,
        6 * COMMUNITY_MIN_PRINCIPAL,
        _calculateBucketVestedRewards(
          s_rewardVault.getRewardBuckets().communityBase, s_timeThirdStakerStakes, block.timestamp
        )
      );

    uint256 unclaimableAmount =
      unstakingStakerFullRewards - multiplier * unstakingStakerFullRewards / FixedPointMathLib.WAD;
    uint256 forfeitedRewardAmount = unclaimableAmount * unstakeAmount / stakerPrincipalBefore;

    uint256 remainingStakerPrincipal = COMMUNITY_MIN_PRINCIPAL;

    // Total remaining staked LINK amount from the remaining 2 stakers plus
    // the remainder of the unstaking staker's staked LINK amount
    uint256 totalPrincipal = 3 * COMMUNITY_MIN_PRINCIPAL;
    uint256 forfeitedRewardsPerToken =
      FixedPointMathLib.divWadDown(forfeitedRewardAmount, totalPrincipal);

    uint256 rewardsForfeitedToRemainingStaker =
      FixedPointMathLib.mulWadDown(forfeitedRewardsPerToken, remainingStakerPrincipal);

    uint256 remainingStakerBaseRewards = _calculateStakerExpectedReward(
      COMMUNITY_MIN_PRINCIPAL,
      4 * COMMUNITY_MIN_PRINCIPAL,
      _calculateBucketVestedRewards(
        s_rewardVault.getRewardBuckets().communityBase, s_stakedAtTime, s_timeThirdStakerStakes
      )
    )
      + _calculateStakerExpectedReward(
        COMMUNITY_MIN_PRINCIPAL,
        6 * COMMUNITY_MIN_PRINCIPAL,
        _calculateBucketVestedRewards(
          s_rewardVault.getRewardBuckets().communityBase, s_timeThirdStakerStakes, block.timestamp
        )
      );

    assertEq(
      s_rewardVault.getReward(COMMUNITY_STAKER_ONE),
      (remainingStakerBaseRewards + rewardsForfeitedToRemainingStaker) * multiplier
        / FixedPointMathLib.WAD
    );
  }

  function test_DistributesCorrectAmountToSecondStakerIfPartiallyUnstaking() public {
    changePrank(COMMUNITY_STAKER_TWO);
    uint256 stakerPrincipalBefore = 3 * COMMUNITY_MIN_PRINCIPAL;
    uint256 unstakeAmount = COMMUNITY_MIN_PRINCIPAL / 2;
    s_communityStakingPool.unstake(unstakeAmount, false);

    uint256 multiplier =
      _calculateStakerMultiplier(s_stakedAtTime, block.timestamp, INITIAL_MULTIPLIER_DURATION);

    // Calculate amount of forfeited rewards
    uint256 stakerFullRewards = _calculateStakerExpectedReward(
      3 * COMMUNITY_MIN_PRINCIPAL,
      4 * COMMUNITY_MIN_PRINCIPAL,
      _calculateBucketVestedRewards(
        s_rewardVault.getRewardBuckets().communityBase, s_stakedAtTime, s_timeThirdStakerStakes
      )
    )
      + _calculateStakerExpectedReward(
        3 * COMMUNITY_MIN_PRINCIPAL,
        6 * COMMUNITY_MIN_PRINCIPAL,
        _calculateBucketVestedRewards(
          s_rewardVault.getRewardBuckets().communityBase, s_timeThirdStakerStakes, block.timestamp
        )
      );

    uint256 unclaimableAmount =
      stakerFullRewards - multiplier * stakerFullRewards / FixedPointMathLib.WAD;
    uint256 forfeitedRewardAmount = unclaimableAmount * unstakeAmount / stakerPrincipalBefore;

    uint256 remainingStakerPrincipal = 2 * COMMUNITY_MIN_PRINCIPAL;

    // Total remaining staked LINK amount from the remaining 2 stakers plus
    // the remainder of the unstaking staker's principal
    uint256 totalPrincipal = 3 * COMMUNITY_MIN_PRINCIPAL;
    uint256 forfeitedRewardsPerToken =
      FixedPointMathLib.divWadDown(forfeitedRewardAmount, totalPrincipal);

    uint256 rewardsForfeitedToRemainingStaker =
      FixedPointMathLib.mulWadDown(forfeitedRewardsPerToken, remainingStakerPrincipal);

    uint256 remainingStakerBaseRewards = _calculateStakerExpectedReward(
      2 * COMMUNITY_MIN_PRINCIPAL,
      6 * COMMUNITY_MIN_PRINCIPAL,
      _calculateBucketVestedRewards(
        s_rewardVault.getRewardBuckets().communityBase, s_timeThirdStakerStakes, block.timestamp
      )
    );

    uint256 remainingStakerMultiplier = _calculateStakerMultiplier(
      s_timeThirdStakerStakes, block.timestamp, INITIAL_MULTIPLIER_DURATION
    );

    assertEq(
      s_rewardVault.getReward(PUBLIC_COMMUNITY_STAKER),
      (remainingStakerBaseRewards + rewardsForfeitedToRemainingStaker) * remainingStakerMultiplier
        / FixedPointMathLib.WAD
    );
  }
}

contract CommunityStakingPool_Unstake_WhenPoolIsFull is
  IStakingPool_Unstake_WhenPoolIsFull,
  StakingPool_InClaimPeriod
{
  uint256 private constant PUBLIC_COMMUNITY_STAKER_STAKE_AMOUNT = 2 * COMMUNITY_MIN_PRINCIPAL;

  uint256 private s_timeThirdStakerStakes;
  address private LARGE_COMMUNITY_STAKER = address(12345);

  function setUp() public override {
    StakingPool_InClaimPeriod.setUp();

    changePrank(OWNER);
    s_LINK.transfer(LARGE_COMMUNITY_STAKER, COMMUNITY_MAX_POOL_SIZE);
    s_communityStakingPool.setMerkleRoot(bytes32(''));
    s_communityStakingPool.setPoolConfig(COMMUNITY_MAX_POOL_SIZE, COMMUNITY_MAX_POOL_SIZE);

    // Stake to fill up pool
    changePrank(LARGE_COMMUNITY_STAKER);
    uint256 stakeAmount = COMMUNITY_MAX_POOL_SIZE - s_communityStakingPool.getTotalPrincipal()
      - PUBLIC_COMMUNITY_STAKER_STAKE_AMOUNT;
    s_LINK.transferAndCall(address(s_communityStakingPool), stakeAmount, abi.encode(''));

    changePrank(PUBLIC_COMMUNITY_STAKER);
    s_LINK.transferAndCall(
      address(s_communityStakingPool), PUBLIC_COMMUNITY_STAKER_STAKE_AMOUNT, abi.encode('')
    );
    s_timeThirdStakerStakes = block.timestamp;

    s_communityStakingPool.unbond();
    skip(UNBONDING_PERIOD);
  }

  function test_DistributesFullForfeitedRewardsIfStakerUnstakesASmallAmountAfterEarningASmallAmountOfRewards(
  ) public {
    changePrank(PUBLIC_COMMUNITY_STAKER);
    s_communityStakingPool.unstake(1, false);

    uint256 unstakingStakerMultiplier = _calculateStakerMultiplier(
      s_timeThirdStakerStakes, block.timestamp, INITIAL_MULTIPLIER_DURATION
    );

    // Calculate amount of forfeited rewards
    uint256 unstakingStakerFullRewards = _calculateStakerExpectedReward(
      PUBLIC_COMMUNITY_STAKER_STAKE_AMOUNT,
      COMMUNITY_MAX_POOL_SIZE,
      _calculateBucketVestedRewards(
        s_rewardVault.getRewardBuckets().communityBase, s_timeThirdStakerStakes, block.timestamp
      )
    );
    uint256 forfeitedRewards = unstakingStakerFullRewards
      - unstakingStakerMultiplier * unstakingStakerFullRewards / FixedPointMathLib.WAD;
    uint256 remainingStakerPrincipal = COMMUNITY_MIN_PRINCIPAL;
    uint256 totalRemainingPrincipal = COMMUNITY_MAX_POOL_SIZE - PUBLIC_COMMUNITY_STAKER_STAKE_AMOUNT;
    uint256 forfeitedRewardsPerToken =
      FixedPointMathLib.divWadDown(forfeitedRewards, totalRemainingPrincipal);

    uint256 rewardsForfeitedToRemainingStaker =
      FixedPointMathLib.mulWadDown(forfeitedRewardsPerToken, remainingStakerPrincipal);

    uint256 remainingStakerBaseRewards = _calculateStakerExpectedReward(
      COMMUNITY_MIN_PRINCIPAL,
      4 * COMMUNITY_MIN_PRINCIPAL,
      _calculateBucketVestedRewards(
        s_rewardVault.getRewardBuckets().communityBase, s_stakedAtTime, s_timeThirdStakerStakes
      )
    )
      + _calculateStakerExpectedReward(
        COMMUNITY_MIN_PRINCIPAL,
        COMMUNITY_MAX_POOL_SIZE,
        _calculateBucketVestedRewards(
          s_rewardVault.getRewardBuckets().communityBase, s_timeThirdStakerStakes, block.timestamp
        )
      );

    uint256 multiplier =
      _calculateStakerMultiplier(s_stakedAtTime, block.timestamp, INITIAL_MULTIPLIER_DURATION);

    assertEq(
      s_rewardVault.getReward(COMMUNITY_STAKER_ONE),
      (remainingStakerBaseRewards + rewardsForfeitedToRemainingStaker) * multiplier
        / FixedPointMathLib.WAD
    );
  }
}

contract CommunityStakingPool_Unstake_WhenUnbondingNotStarted is
  IStakingPool_Unstake_WhenUnbondingNotStarted,
  IStakingPool_Unstake_WhenPoolClosed,
  StakingPool_WithStakers
{
  function test_RevertWhen_StakerTriesToUnstake() external override {
    vm.expectRevert(
      abi.encodeWithSelector(StakingPoolBase.StakerNotInClaimPeriod.selector, COMMUNITY_STAKER_ONE)
    );
    changePrank(COMMUNITY_STAKER_ONE);
    s_communityStakingPool.unstake(COMMUNITY_MIN_PRINCIPAL, true);
  }

  function test_CanUnstakeIfPoolClosed() public {
    changePrank(OWNER);

    s_communityStakingPool.close();

    changePrank(COMMUNITY_STAKER_ONE);

    vm.expectEmit(true, true, true, true, address(s_communityStakingPool));
    emit Unstaked(COMMUNITY_STAKER_ONE, COMMUNITY_MIN_PRINCIPAL, 0);
    s_communityStakingPool.unstake(COMMUNITY_MIN_PRINCIPAL, false);
  }
}

contract CommunityStakingStakingPool_Unstake_WhileUnbonding is
  IStakingPool_Unstake_WhileUnbonding,
  IStakingPool_Unstake_WhenPoolClosed,
  StakingPool_InUnbondingPeriod
{
  function test_RevertWhen_StakerTriesToUnstake() external {
    vm.expectRevert(
      abi.encodeWithSelector(StakingPoolBase.StakerNotInClaimPeriod.selector, COMMUNITY_STAKER_ONE)
    );
    changePrank(COMMUNITY_STAKER_ONE);
    s_communityStakingPool.unstake(COMMUNITY_MIN_PRINCIPAL, true);
  }

  function test_CanUnstakeIfPoolClosed() public {
    changePrank(OWNER);

    s_communityStakingPool.close();

    changePrank(COMMUNITY_STAKER_ONE);

    vm.expectEmit(true, true, true, true, address(s_communityStakingPool));
    emit Unstaked(COMMUNITY_STAKER_ONE, COMMUNITY_MIN_PRINCIPAL, 0);
    s_communityStakingPool.unstake(COMMUNITY_MIN_PRINCIPAL, false);
  }
}

contract CommunityStakingPool_Unstake_WhenClaimPeriodEndsAt is StakingPool_WhenClaimPeriodEndsAt {
  function test_CanUnstakeAtClaimPeriodEndsAt() public {
    changePrank(COMMUNITY_STAKER_ONE);
    vm.expectEmit(true, true, true, true, address(s_communityStakingPool));
    emit Unstaked(COMMUNITY_STAKER_ONE, COMMUNITY_MIN_PRINCIPAL, 0);
    s_communityStakingPool.unstake(COMMUNITY_MIN_PRINCIPAL, false);
  }
}

contract CommunityStakingPool_Unstake_WhenClaimPeriodFinished is
  IStakingPool_Unstake_WhenClaimPeriodFinished,
  IStakingPool_Unstake_WhenPoolClosed,
  StakingPool_InUnbondingPeriod
{
  function setUp() public override {
    StakingPool_InUnbondingPeriod.setUp();
    uint256 stakerUnbondingEndsAt = s_communityStakingPool.getUnbondingEndsAt(COMMUNITY_STAKER_ONE);
    (, uint256 claimPeriod) = s_communityStakingPool.getUnbondingParams();
    // Move one day past the claim period
    vm.warp(stakerUnbondingEndsAt + claimPeriod + 1);
  }

  function test_RevertWhen_StakerTriesToUnstake() external {
    vm.expectRevert(
      abi.encodeWithSelector(StakingPoolBase.StakerNotInClaimPeriod.selector, COMMUNITY_STAKER_ONE)
    );
    changePrank(COMMUNITY_STAKER_ONE);
    s_communityStakingPool.unstake(COMMUNITY_MIN_PRINCIPAL, true);
  }

  function test_CanUnstakeIfPoolClosed() public {
    changePrank(OWNER);

    s_communityStakingPool.close();

    changePrank(COMMUNITY_STAKER_ONE);

    uint256 reward = s_rewardVault.getReward(COMMUNITY_STAKER_ONE);
    vm.expectEmit(true, true, true, true, address(s_communityStakingPool));
    emit Unstaked(COMMUNITY_STAKER_ONE, COMMUNITY_MIN_PRINCIPAL, reward);
    s_communityStakingPool.unstake(COMMUNITY_MIN_PRINCIPAL, true);
  }
}

contract CommunityStakingPool_Unstake_WhenLastStakerUnstakesAndClaims is
  IStakingPool_Unstake_WhenLastStakerUnstakesAndClaims,
  StakingPool_InClaimPeriod
{
  function setUp() public override {
    StakingPool_InClaimPeriod.setUp();

    changePrank(COMMUNITY_STAKER_ONE);
    s_communityStakingPool.unstake(COMMUNITY_MIN_PRINCIPAL, false);
  }

  function test_DoesNotForfeitRewards() external {
    uint256 communityStakerTwoPrincipal = COMMUNITY_MIN_PRINCIPAL * 3;
    uint256 communityStakerTwoLINKBalanceBefore = s_LINK.balanceOf(COMMUNITY_STAKER_TWO);
    uint256 multiplier =
      _calculateStakerMultiplier(s_stakedAtTime, block.timestamp, INITIAL_MULTIPLIER_DURATION);

    uint256 communityStakerOneFullRewards = _calculateStakerExpectedReward(
      COMMUNITY_MIN_PRINCIPAL,
      4 * COMMUNITY_MIN_PRINCIPAL,
      _calculateBucketVestedRewards(
        s_rewardVault.getRewardBuckets().communityBase, s_stakedAtTime, block.timestamp
      )
    );

    uint256 stakerOneForfeitedRewards = communityStakerOneFullRewards
      - multiplier * communityStakerOneFullRewards / FixedPointMathLib.WAD;

    uint256 stakerOneForfeitedRewardsPerToken =
      FixedPointMathLib.divWadDown(stakerOneForfeitedRewards, communityStakerTwoPrincipal);

    // Calculate amount of forfeited rewards
    uint256 communityStakerTwoBaseRewards = _calculateStakerExpectedReward(
      3 * COMMUNITY_MIN_PRINCIPAL,
      4 * COMMUNITY_MIN_PRINCIPAL,
      _calculateBucketVestedRewards(
        s_rewardVault.getRewardBuckets().communityBase, s_stakedAtTime, block.timestamp
      )
    );

    uint256 expectedReward = FixedPointMathLib.mulWadDown(
      stakerOneForfeitedRewardsPerToken, communityStakerTwoPrincipal
    ) + communityStakerTwoBaseRewards;

    changePrank(COMMUNITY_STAKER_TWO);
    s_communityStakingPool.unstake(communityStakerTwoPrincipal, true);

    assertEq(
      s_LINK.balanceOf(COMMUNITY_STAKER_TWO),
      communityStakerTwoLINKBalanceBefore + expectedReward + communityStakerTwoPrincipal
    );
  }
}

contract CommunityStakingPool_Unstake_WhenPaused is
  IStakingPool_Unstake_WhenPaused,
  StakingPool_WhenPaused
{
  function test_CanUnstakeWithoutInitiatingUnbondingPeriod() public {
    changePrank(COMMUNITY_STAKER_ONE);
    s_communityStakingPool.unstake(
      s_communityStakingPool.getStakerPrincipal(COMMUNITY_STAKER_ONE), false
    );
  }

  function test_CanUnstakeAfterInitiatingUnbondingPeriodWithoutWaiting() public {
    changePrank(COMMUNITY_STAKER_ONE);
    s_communityStakingPool.unbond();
    s_communityStakingPool.unstake(
      s_communityStakingPool.getStakerPrincipal(COMMUNITY_STAKER_ONE), false
    );
  }

  function test_CanUnstakeAfterUnbondingPeriod() public {
    changePrank(COMMUNITY_STAKER_ONE);
    s_communityStakingPool.unbond();

    skip(UNBONDING_PERIOD);

    s_communityStakingPool.unstake(
      s_communityStakingPool.getStakerPrincipal(COMMUNITY_STAKER_ONE), false
    );
  }

  function test_RevertWhen_UnstakeAfterUnpausingAndBeforeUnbonding() public {
    changePrank(PAUSER);
    s_communityStakingPool.emergencyUnpause();

    changePrank(COMMUNITY_STAKER_ONE);
    uint256 principal = s_communityStakingPool.getStakerPrincipal(COMMUNITY_STAKER_ONE);
    vm.expectRevert(
      abi.encodeWithSelector(StakingPoolBase.StakerNotInClaimPeriod.selector, COMMUNITY_STAKER_ONE)
    );
    s_communityStakingPool.unstake(principal, false);
  }

  function test_RevertWhen_UnstakeWithShouldClaimRewardsTrue() public {
    changePrank(COMMUNITY_STAKER_ONE);
    uint256 unstakeAmount = s_communityStakingPool.getStakerPrincipal(COMMUNITY_STAKER_ONE);
    vm.expectRevert(StakingPoolBase.CannotClaimRewardWhenPaused.selector);
    s_communityStakingPool.unstake(unstakeAmount, true);
  }
}

contract CommunityStakingPool_Unstake_WhenThereAreOtherStakers is
  IStakingPool_Unstake_WhenThereAreOtherStakers,
  StakingPool_InClaimPeriod
{
  uint256 private s_currentCheckpointId;

  function setUp() public override {
    StakingPool_InClaimPeriod.setUp();
    s_currentCheckpointId = s_communityStakingPool.getCurrentCheckpointId();
  }

  function test_CorrectlyTracksHistoricalBalance() external {
    changePrank(COMMUNITY_STAKER_ONE);
    s_communityStakingPool.unstake(COMMUNITY_MIN_PRINCIPAL, true);
    assertEq(
      s_communityStakingPool.getStakerPrincipalAt(COMMUNITY_STAKER_ONE, s_currentCheckpointId - 1),
      COMMUNITY_MIN_PRINCIPAL
    );
  }

  function test_DoesNotAffectOtherStakerBalances() external {
    changePrank(COMMUNITY_STAKER_TWO);
    s_communityStakingPool.unstake(COMMUNITY_MIN_PRINCIPAL, true);
    assertEq(
      s_communityStakingPool.getStakerPrincipal(COMMUNITY_STAKER_ONE), COMMUNITY_MIN_PRINCIPAL
    );
  }

  function test_CorrectlyTracksHistoricalAverageStakedAtTime() public {
    uint256 stakedAtTimeBefore = s_communityStakingPool.getStakerStakedAtTime(COMMUNITY_STAKER_ONE);
    changePrank(COMMUNITY_STAKER_ONE);
    s_communityStakingPool.unstake(COMMUNITY_MIN_PRINCIPAL, true);
    assertEq(
      s_communityStakingPool.getStakerStakedAtTimeAt(
        COMMUNITY_STAKER_ONE, s_currentCheckpointId - 1
      ),
      stakedAtTimeBefore
    );
  }

  function test_DoesNotAffectOtherStakerAverageStakedAtTime() public {
    uint256 stakedAtTimeBefore = s_communityStakingPool.getStakerStakedAtTime(COMMUNITY_STAKER_ONE);
    changePrank(COMMUNITY_STAKER_TWO);
    s_communityStakingPool.unstake(COMMUNITY_MIN_PRINCIPAL, true);
    assertEq(
      s_communityStakingPool.getStakerStakedAtTimeAt(
        COMMUNITY_STAKER_ONE, s_currentCheckpointId - 1
      ),
      stakedAtTimeBefore
    );
  }
}

contract CommunityStakingPool_SetUnbondingPeriod_WhenPoolOpenedAndStakersAreUnbonding is
  IStakingPool_SetUnbondingPeriod_WhenPoolOpenedAndStakersAreUnbonding,
  StakingPool_InUnbondingPeriod
{
  event UnbondingPeriodSet(uint256 oldUnbondingPeriod, uint256 newUnbondingPeriod);

  function test_RevertWhen_CalledByNonAdmin() external {
    vm.expectRevert(
      _getExpectedMissingRoleErrorMessage(STRANGER, s_communityStakingPool.DEFAULT_ADMIN_ROLE())
    );
    changePrank(STRANGER);
    s_communityStakingPool.setUnbondingPeriod(MAX_UNBONDING_PERIOD);
  }

  function test_RevertWhen_UnbondingPeriodIsZero() external {
    vm.expectRevert(StakingPoolBase.InvalidUnbondingPeriod.selector);
    changePrank(OWNER);
    s_communityStakingPool.setUnbondingPeriod(0);
  }

  function test_RevertWhen_UnbondingPeriodIsGreaterThanMax() external {
    vm.expectRevert(StakingPoolBase.InvalidUnbondingPeriod.selector);
    changePrank(OWNER);
    s_communityStakingPool.setUnbondingPeriod(MAX_UNBONDING_PERIOD + 1);
  }

  function test_UpdatesUnbondingPeriod() external {
    uint256 newUnbondingPeriod = MAX_UNBONDING_PERIOD;
    changePrank(OWNER);
    s_communityStakingPool.setUnbondingPeriod(newUnbondingPeriod);
    (uint256 unbondingPeriod,) = s_communityStakingPool.getUnbondingParams();
    assertEq(unbondingPeriod, newUnbondingPeriod);
  }

  function test_DoesNotAffectStakersThatAreUnbonding() external {
    uint256 newUnbondingPeriod = MAX_UNBONDING_PERIOD;
    uint256 unbondingEndsAt = s_communityStakingPool.getUnbondingEndsAt(COMMUNITY_STAKER_ONE);
    changePrank(OWNER);
    s_communityStakingPool.setUnbondingPeriod(newUnbondingPeriod);
    assertEq(s_communityStakingPool.getUnbondingEndsAt(COMMUNITY_STAKER_ONE), unbondingEndsAt);
  }

  function test_EmitsEvent() external {
    uint256 newUnbondingPeriod = MAX_UNBONDING_PERIOD;
    (uint256 oldUnbondingPeriod,) = s_communityStakingPool.getUnbondingParams();
    vm.expectEmit(true, true, true, true, address(s_communityStakingPool));
    emit UnbondingPeriodSet(oldUnbondingPeriod, newUnbondingPeriod);
    changePrank(OWNER);
    s_communityStakingPool.setUnbondingPeriod(newUnbondingPeriod);
  }

  function test_TypeAndVersion() public {
    string memory typeAndVersion = s_communityStakingPool.typeAndVersion();
    assertEq(typeAndVersion, 'CommunityStakingPool 1.0.0');
  }
}

contract CommunityStakingPool_AccessControlDefaultAdminRules is
  IAccessControlDefaultAdminRulesTest,
  BaseTest
{
  using SafeCast for uint256;

  event DefaultAdminTransferScheduled(address indexed newAdmin, uint48 acceptSchedule);
  event DefaultAdminTransferCanceled();
  event DefaultAdminDelayChangeScheduled(uint48 newDelay, uint48 effectSchedule);
  event DefaultAdminDelayChangeCanceled();

  function test_DefaultValuesAreInitialized() public {
    assertEq(
      s_communityStakingPool.hasRole(s_communityStakingPool.DEFAULT_ADMIN_ROLE(), OWNER), true
    );
    assertEq(s_communityStakingPool.defaultAdmin(), OWNER);
    (address pendingDefaultAdmin, uint48 adminSchedule) =
      s_communityStakingPool.pendingDefaultAdmin();
    assertEq(pendingDefaultAdmin, address(0));
    assertEq(adminSchedule, 0);
    assertEq(s_communityStakingPool.defaultAdminDelay(), 0);
    (uint48 pendingDelay, uint48 delaySchedule) = s_communityStakingPool.pendingDefaultAdminDelay();
    assertEq(pendingDelay, 0);
    assertEq(delaySchedule, 0);
    assertEq(s_communityStakingPool.defaultAdminDelayIncreaseWait(), 5 days);
  }

  function test_RevertWhen_DirectlyGrantDefaultAdminRole() public {
    changePrank(OWNER);
    bytes32 defaultAdminRole = s_communityStakingPool.DEFAULT_ADMIN_ROLE();
    vm.expectRevert("AccessControl: can't directly grant default admin role");
    s_communityStakingPool.grantRole(defaultAdminRole, NEW_OWNER);
  }

  function test_RevertWhen_DirectlyRevokeDefaultAdminRole() public {
    changePrank(OWNER);
    bytes32 defaultAdminRole = s_communityStakingPool.DEFAULT_ADMIN_ROLE();
    vm.expectRevert("AccessControl: can't directly revoke default admin role");
    s_communityStakingPool.revokeRole(defaultAdminRole, NEW_OWNER);
  }

  function test_RevertWhen_NonAdminBeginsDefaultAdminTransfer() public {
    changePrank(NEW_OWNER);
    vm.expectRevert(
      _getExpectedMissingRoleErrorMessage(NEW_OWNER, s_communityStakingPool.DEFAULT_ADMIN_ROLE())
    );
    s_communityStakingPool.beginDefaultAdminTransfer(NEW_OWNER);
  }

  function test_CurrentAdminCanBeginDefaultAdminTransfer() public {
    changePrank(OWNER);
    address newAdmin = NEW_OWNER;
    uint48 newSchedule = SafeCast.toUint48(block.timestamp);
    vm.expectEmit(true, true, true, true, address(s_communityStakingPool));
    emit DefaultAdminTransferScheduled(newAdmin, newSchedule);

    s_communityStakingPool.beginDefaultAdminTransfer(newAdmin);

    assertEq(
      s_communityStakingPool.hasRole(s_communityStakingPool.DEFAULT_ADMIN_ROLE(), OWNER), true
    );
    assertEq(s_communityStakingPool.defaultAdmin(), OWNER);
    (address pendingDefaultAdmin, uint48 schedule) = s_communityStakingPool.pendingDefaultAdmin();
    assertEq(pendingDefaultAdmin, newAdmin);
    assertEq(schedule, newSchedule);
  }

  function test_CurrentAdminCanOverwritePendingDefaultAdminTransfer() public {
    changePrank(OWNER);
    s_communityStakingPool.beginDefaultAdminTransfer(NEW_OWNER);

    address newAdmin = PAUSER;
    uint48 newSchedule = SafeCast.toUint48(block.timestamp);
    vm.expectEmit(true, true, true, true, address(s_communityStakingPool));
    emit DefaultAdminTransferCanceled();
    vm.expectEmit(true, true, true, true, address(s_communityStakingPool));
    emit DefaultAdminTransferScheduled(newAdmin, newSchedule);

    s_communityStakingPool.beginDefaultAdminTransfer(newAdmin);

    assertEq(
      s_communityStakingPool.hasRole(s_communityStakingPool.DEFAULT_ADMIN_ROLE(), OWNER), true
    );
    assertEq(s_communityStakingPool.defaultAdmin(), OWNER);
    (address pendingDefaultAdmin, uint48 schedule) = s_communityStakingPool.pendingDefaultAdmin();
    assertEq(pendingDefaultAdmin, newAdmin);
    assertEq(schedule, newSchedule);
  }

  function test_CurrentAdminCanOverwriteDefaultAdminTransferAfterDelayPassedAndIfNotAccepted()
    public
  {
    changePrank(OWNER);
    s_communityStakingPool.beginDefaultAdminTransfer(NEW_OWNER);
    (, uint48 scheduleBefore) = s_communityStakingPool.pendingDefaultAdmin();

    // After the delay is over
    skip(2);

    address newAdmin = PAUSER;
    uint48 newSchedule = scheduleBefore + 2;
    vm.expectEmit(true, true, true, true, address(s_communityStakingPool));
    emit DefaultAdminTransferCanceled();
    vm.expectEmit(true, true, true, true, address(s_communityStakingPool));
    emit DefaultAdminTransferScheduled(newAdmin, newSchedule);

    s_communityStakingPool.beginDefaultAdminTransfer(PAUSER);

    assertEq(
      s_communityStakingPool.hasRole(s_communityStakingPool.DEFAULT_ADMIN_ROLE(), OWNER), true
    );
    assertEq(s_communityStakingPool.defaultAdmin(), OWNER);
    (address pendingDefaultAdmin, uint48 schedule) = s_communityStakingPool.pendingDefaultAdmin();
    assertEq(pendingDefaultAdmin, newAdmin);
    assertEq(schedule, newSchedule);
  }

  function test_RevertWhen_NonAdminCancelPendingDefaultAdminTransfer() public {
    changePrank(OWNER);
    s_communityStakingPool.beginDefaultAdminTransfer(NEW_OWNER);

    changePrank(NEW_OWNER);
    vm.expectRevert(
      _getExpectedMissingRoleErrorMessage(NEW_OWNER, s_communityStakingPool.DEFAULT_ADMIN_ROLE())
    );
    s_communityStakingPool.cancelDefaultAdminTransfer();
  }

  function test_CurrentAdminCanCancelPendingDefaultAdminTransfer() public {
    changePrank(OWNER);
    s_communityStakingPool.beginDefaultAdminTransfer(NEW_OWNER);

    vm.expectEmit(true, true, true, true, address(s_communityStakingPool));
    emit DefaultAdminTransferCanceled();
    s_communityStakingPool.cancelDefaultAdminTransfer();

    (address pendingDefaultAdmin, uint48 schedule) = s_communityStakingPool.pendingDefaultAdmin();
    assertEq(pendingDefaultAdmin, address(0));
    assertEq(schedule, 0);
  }

  function test_RevertWhen_NonPendingDefaultAdminAcceptsTransfer() public {
    changePrank(OWNER);
    s_communityStakingPool.beginDefaultAdminTransfer(NEW_OWNER);

    changePrank(STRANGER);
    vm.expectRevert('AccessControl: pending admin must accept');
    s_communityStakingPool.acceptDefaultAdminTransfer();
  }

  function test_RevertWhen_PendingDefaultAdminAcceptsTransferBeforeDelayPassed() public {
    changePrank(OWNER);
    s_communityStakingPool.changeDefaultAdminDelay(1 days);
    s_communityStakingPool.beginDefaultAdminTransfer(NEW_OWNER);

    changePrank(NEW_OWNER);
    vm.expectRevert('AccessControl: transfer delay not passed');
    s_communityStakingPool.acceptDefaultAdminTransfer();
  }

  function test_PendingDefaultAdminCanAcceptTransferImmediatelyIfDelayIsZero() public {
    changePrank(OWNER);
    s_communityStakingPool.beginDefaultAdminTransfer(NEW_OWNER);

    skip(1); // needs to satisfy: schedule < block.timestamp

    changePrank(NEW_OWNER);
    s_communityStakingPool.acceptDefaultAdminTransfer();

    assertEq(
      s_communityStakingPool.hasRole(s_communityStakingPool.DEFAULT_ADMIN_ROLE(), OWNER), false
    );
    assertEq(
      s_communityStakingPool.hasRole(s_communityStakingPool.DEFAULT_ADMIN_ROLE(), NEW_OWNER), true
    );
    assertEq(s_communityStakingPool.defaultAdmin(), NEW_OWNER);
    (address pendingDefaultAdmin, uint48 schedule) = s_communityStakingPool.pendingDefaultAdmin();
    assertEq(pendingDefaultAdmin, address(0));
    assertEq(schedule, 0);
  }

  function test_PendingDefaultAdminCanAcceptTransferAfterDelayPassed() public {
    changePrank(OWNER);
    s_communityStakingPool.changeDefaultAdminDelay(30 days);
    s_communityStakingPool.beginDefaultAdminTransfer(NEW_OWNER);

    skip(30 days);

    changePrank(NEW_OWNER);
    s_communityStakingPool.acceptDefaultAdminTransfer();

    assertEq(
      s_communityStakingPool.hasRole(s_communityStakingPool.DEFAULT_ADMIN_ROLE(), OWNER), false
    );
    assertEq(
      s_communityStakingPool.hasRole(s_communityStakingPool.DEFAULT_ADMIN_ROLE(), NEW_OWNER), true
    );
    assertEq(s_communityStakingPool.defaultAdmin(), NEW_OWNER);
    (address pendingDefaultAdmin, uint48 schedule) = s_communityStakingPool.pendingDefaultAdmin();
    assertEq(pendingDefaultAdmin, address(0));
    assertEq(schedule, 0);
  }

  function test_RevertWhen_NonAdminChangesDelay() public {
    changePrank(NEW_OWNER);
    vm.expectRevert(
      _getExpectedMissingRoleErrorMessage(NEW_OWNER, s_communityStakingPool.DEFAULT_ADMIN_ROLE())
    );
    s_communityStakingPool.changeDefaultAdminDelay(30 days);
  }

  function test_CurrentAdminCanChangeDelay() public {
    changePrank(OWNER);
    uint48 newDelay = 30 days;
    uint48 newSchedule = SafeCast.toUint48(block.timestamp + 5 days);
    vm.expectEmit(true, true, true, true, address(s_communityStakingPool));
    emit DefaultAdminDelayChangeScheduled(newDelay, newSchedule);
    s_communityStakingPool.changeDefaultAdminDelay(newDelay);

    assertEq(s_communityStakingPool.defaultAdminDelay(), 0);
    (uint48 pendingDelay, uint48 schedule) = s_communityStakingPool.pendingDefaultAdminDelay();
    assertEq(pendingDelay, newDelay);
    assertEq(schedule, newSchedule);
  }

  function test_RevertWhen_NonAdminRollbackDelayChange() public {
    changePrank(OWNER);
    s_communityStakingPool.changeDefaultAdminDelay(30 days);

    changePrank(NEW_OWNER);
    vm.expectRevert(
      _getExpectedMissingRoleErrorMessage(NEW_OWNER, s_communityStakingPool.DEFAULT_ADMIN_ROLE())
    );
    s_communityStakingPool.rollbackDefaultAdminDelay();
  }

  function test_CurrentAdminCanRollbackDelayChange() public {
    changePrank(OWNER);
    s_communityStakingPool.changeDefaultAdminDelay(30 days);

    vm.expectEmit(true, true, true, true, address(s_communityStakingPool));
    emit DefaultAdminDelayChangeCanceled();
    s_communityStakingPool.rollbackDefaultAdminDelay();

    assertEq(s_communityStakingPool.defaultAdminDelay(), 0);
    (uint48 pendingDelay, uint48 schedule) = s_communityStakingPool.pendingDefaultAdminDelay();
    assertEq(pendingDelay, 0);
    assertEq(schedule, 0);
  }
}

contract CommunityStakingPool_SetClaimPeriod is
  IStakingPool_SetClaimPeriod,
  StakingPool_WithStakers
{
  event ClaimPeriodSet(uint256 oldClaimPeriod, uint256 claimPeriod);

  function test_RevertWhen_CalledByNonAdmin() public {
    changePrank(STRANGER);
    vm.expectRevert(
      _getExpectedMissingRoleErrorMessage(STRANGER, s_communityStakingPool.DEFAULT_ADMIN_ROLE())
    );
    s_communityStakingPool.setClaimPeriod(1 days);
  }

  function test_RevertWhen_ClaimPeriodIsZero() public {
    changePrank(OWNER);
    vm.expectRevert(StakingPoolBase.InvalidClaimPeriod.selector);
    s_communityStakingPool.setClaimPeriod(0);
  }

  function test_RevertWhen_ClaimPeriodIsGreaterThanMax() public {
    changePrank(OWNER);
    vm.expectRevert(StakingPoolBase.InvalidClaimPeriod.selector);
    s_communityStakingPool.setClaimPeriod(MAX_CLAIM_PERIOD + 1);
  }

  function test_RevertWhen_ClaimPeriodIsLessThanMin() public {
    changePrank(OWNER);
    vm.expectRevert(StakingPoolBase.InvalidClaimPeriod.selector);
    s_communityStakingPool.setClaimPeriod(MIN_CLAIM_PERIOD - 1);
  }

  function test_UpdatesClaimPeriod() public {
    changePrank(OWNER);
    uint256 newClaimPeriod = MIN_CLAIM_PERIOD + 2 days;
    s_communityStakingPool.setClaimPeriod(newClaimPeriod);
    (, uint256 claimPeriod) = s_communityStakingPool.getUnbondingParams();
    assertEq(claimPeriod, newClaimPeriod);
  }

  function test_EmitsEvent() public {
    changePrank(OWNER);
    uint256 newClaimPeriod = MIN_CLAIM_PERIOD + 2 days;
    vm.expectEmit(true, true, true, true, address(s_communityStakingPool));
    emit ClaimPeriodSet(CLAIM_PERIOD, newClaimPeriod);
    s_communityStakingPool.setClaimPeriod(newClaimPeriod);
  }

  function test_DoesNotAffectStakersThatAreUnbonding() public {
    changePrank(COMMUNITY_STAKER_ONE);
    s_communityStakingPool.unbond();
    uint256 claimPeriodEndsAt = block.timestamp + UNBONDING_PERIOD + CLAIM_PERIOD;
    assertEq(s_communityStakingPool.getClaimPeriodEndsAt(COMMUNITY_STAKER_ONE), claimPeriodEndsAt);
    changePrank(OWNER);
    uint256 newClaimPeriod = MIN_CLAIM_PERIOD;
    assertTrue(newClaimPeriod != CLAIM_PERIOD);
    s_communityStakingPool.setClaimPeriod(newClaimPeriod);
    assertEq(s_communityStakingPool.getClaimPeriodEndsAt(COMMUNITY_STAKER_ONE), claimPeriodEndsAt);
  }
}

contract CommunityStakingPool_isActive is StakingPool_WithStakers {
  function test_IsActiveWhenPoolIsOpenAndEmittingRewards() public {
    assertEq(s_communityStakingPool.isOpen(), true);
    assertEq(s_communityStakingPool.isActive(), true);
  }

  function test_IsNotActiveWhenPoolIsClosedAndEmittingRewards() public {
    changePrank(OWNER);
    s_communityStakingPool.close();
    assertEq(s_communityStakingPool.isActive(), false);
  }

  function test_IsNotActiveWhenPoolIsOpenAndStoppedEmittingRewards() public {
    RewardVault.RewardBuckets memory buckets = s_rewardVault.getRewardBuckets();
    uint256 rewardDurationEndsAt = buckets.communityBase.rewardDurationEndsAt;
    vm.warp(rewardDurationEndsAt + 1);
    assertEq(s_communityStakingPool.isOpen(), true);
    assertEq(s_communityStakingPool.isActive(), false);
  }

  function test_IsNotActiveWhenPoolIsClosedAndStoppedEmittingRewards() public {
    changePrank(OWNER);
    RewardVault.RewardBuckets memory buckets = s_rewardVault.getRewardBuckets();
    uint256 rewardDurationEndsAt = buckets.communityBase.rewardDurationEndsAt;
    vm.warp(rewardDurationEndsAt + 1);
    s_communityStakingPool.close();
    assertEq(s_communityStakingPool.isActive(), false);
  }
}
