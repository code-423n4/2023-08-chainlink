// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {ERC677ReceiverInterface} from
  '@chainlink/contracts/src/v0.8/interfaces/ERC677ReceiverInterface.sol';
import {LinkTokenInterface} from '@chainlink/contracts/src/v0.8/interfaces/LinkTokenInterface.sol';
import {Math} from '@openzeppelin/contracts/utils/math/Math.sol';
import {SafeCast} from '@openzeppelin/contracts/utils/math/SafeCast.sol';
import {FixedPointMathLib} from '@solmate/utils/FixedPointMathLib.sol';
import {BaseTest} from '../../BaseTest.t.sol';
import {
  PriceFeedAlertsController_WhenPoolOpen,
  PriceFeedAlertsController_WithSlasherRole,
  PriceFeedAlertsController_WithSlasherRoleAndMaxStakedAmount
} from '../../base-scenarios/PriceFeedAlertsControllerScenarios.t.sol';
import {
  StakingPool_WithStakers,
  StakingPool_InUnbondingPeriod,
  StakingPool_StakeInUnbondingPeriod,
  StakingPool_MigrationProxyUnset,
  StakingPool_InClaimPeriod,
  StakingPool_WhenPoolsAreClosed,
  StakingPool_WhenPaused,
  StakingPool_Opened,
  StakingPool_WhenClaimPeriodEndsAt
} from '../../base-scenarios/StakingPoolScenarios.t.sol';
import {IAccessControlDefaultAdminRulesTest} from
  '../../interfaces/IAccessControlDefaultAdminRulesTest.t.sol';
import {IOpenableTest} from '../../interfaces/IOpenableTest.t.sol';
import {IPausableTest} from '../../interfaces/IPausableTest.t.sol';
import {
  IStakingPool_GetClaimPeriodEndsAt,
  IStakingPool_GetStaker,
  IStakingPool_Constructor,
  IStakingPool_Unbond_WhenStakerStakesAgainDuringUnbondingPeriod,
  IStakingPool_Unbond_WhenStakeIsNotUnbonding,
  IStakingPool_Unbond_WhenStakeIsUnbonding,
  IStakingPool_OnTokenTransfer,
  IStakingPool_OnTokenTransfer_WhenPaused,
  IStakingPool_OnTokenTransfer_WhenStakeIsUnbonding,
  IStakingPool_OnTokenTransfer_WhenThereOtherStakers,
  IStakingPool_Unbond_WhenStakeIsUnbonding,
  IStakingPool_SetPoolConfig,
  IStakingPool_SetMigrationProxy,
  IStakingPool_Unbond_WhenStakeIsUnbonding,
  IStakingPool_Unstake,
  IStakingPool_Unstake_WhenUnbondingNotStarted,
  IStakingPool_Unstake_WhileUnbonding,
  IStakingPool_Unstake_WhenClaimPeriodFinished,
  IStakingPool_Unstake_WhenPaused,
  IStakingPool_Unstake_WhenThereAreOtherStakers,
  IStakingPool_Unstake_WhenPoolClosed,
  IStakingPool_SetClaimPeriod,
  IStakingPool_Unstake_WhenMoreThanTwoStakers,
  IStakingPool_Unstake_WhenLastStakerUnstakesAndClaims,
  IStakingPool_SetUnbondingPeriod_WhenPoolOpenedAndStakersAreUnbonding
} from '../../interfaces/IStakingPoolTest.t.sol';
import {ISlashable} from '../../../src/interfaces/ISlashable.sol';
import {IRewardVault} from '../../../src/interfaces/IRewardVault.sol';
import {IStakingOwner} from '../../../src/interfaces/IStakingOwner.sol';
import {IStakingPool} from '../../../src/interfaces/IStakingPool.sol';
import {OperatorStakingPool} from '../../../src/pools/OperatorStakingPool.sol';
import {RewardVault} from '../../../src/rewards/RewardVault.sol';
import {StakingPoolBase} from '../../../src/pools/StakingPoolBase.sol';

contract OperatorStakingPoolTest_SupportsInterface is BaseTest {
  function test_IsERC677Compatible() public {
    assertEq(
      s_operatorStakingPool.supportsInterface(ERC677ReceiverInterface.onTokenTransfer.selector),
      true
    );
  }
}

contract OperatorStakingPoolTest is BaseTest {
  event OperatorRemoved(address indexed operator, uint256 principal);

  /// @notice Test that verifies a non-owner address cannot add operators
  function test_RevertWhen_NotOwnerAddOperators() public {
    changePrank(STRANGER);
    vm.expectRevert(
      _getExpectedMissingRoleErrorMessage(STRANGER, s_operatorStakingPool.DEFAULT_ADMIN_ROLE())
    );

    address[] memory operators = _getDefaultOperators();
    s_operatorStakingPool.addOperators(operators);
  }

  /// @notice Test that verifies the owner cannot add operators with an unsorted list
  function test_RevertWhen_OperatorsInputListNotSorted() public {
    changePrank(OWNER);
    vm.expectRevert(OperatorStakingPool.InvalidOperatorList.selector);

    address[] memory operators = new address[](2);
    operators[0] = OPERATOR_STAKER_TWO;
    operators[1] = OPERATOR_STAKER_ONE;

    s_operatorStakingPool.addOperators(operators);
  }

  /// @notice Test that verifies the owner cannot add operators with a list that contains duplicates
  function test_RevertWhen_OperatorsInputListNotUnique() public {
    changePrank(OWNER);
    vm.expectRevert(OperatorStakingPool.InvalidOperatorList.selector);

    address[] memory operators = new address[](2);
    operators[0] = OPERATOR_STAKER_ONE;
    operators[1] = OPERATOR_STAKER_ONE;

    s_operatorStakingPool.addOperators(operators);
  }

  function test_RevertWhen_NotEnoughSpaceForOperators() public {
    changePrank(OWNER);
    s_operatorStakingPool.addOperators(_getDefaultOperators());
    s_operatorStakingPool.open();
    s_operatorStakingPool.setPoolConfig(
      OPERATOR_MAX_POOL_SIZE, OPERATOR_MAX_POOL_SIZE / MIN_INITIAL_OPERATOR_COUNT
    );

    address[] memory operators = new address[](2);
    operators[0] = address(99);
    operators[1] = address(999);

    vm.expectRevert(
      abi.encodeWithSelector(
        OperatorStakingPool.InsufficientPoolSpace.selector,
        OPERATOR_MAX_POOL_SIZE,
        OPERATOR_MAX_POOL_SIZE / MIN_INITIAL_OPERATOR_COUNT,
        MIN_INITIAL_OPERATOR_COUNT + operators.length
      )
    );
    s_operatorStakingPool.addOperators(operators);
  }

  /// @notice Test that verifier that duplicate operators cannot be added to
  /// the pool
  function test_RevertWhen_DuplicateOperatorIsAdded() public {
    changePrank(OWNER);

    address[] memory operators = new address[](2);
    operators[0] = OPERATOR_STAKER_ONE;
    operators[1] = OPERATOR_STAKER_TWO;
    s_operatorStakingPool.addOperators(operators);

    vm.expectRevert(
      abi.encodeWithSelector(
        OperatorStakingPool.OperatorAlreadyExists.selector, OPERATOR_STAKER_ONE
      )
    );
    s_operatorStakingPool.addOperators(operators);
  }

  function test_RevertWhen_RewardVaultNotSet() public {
    changePrank(OWNER);

    s_operatorStakingPool = new OperatorStakingPool(
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
    address[] memory operators = _getDefaultOperators();
    vm.expectRevert(IStakingPool.RewardVaultNotSet.selector);
    s_operatorStakingPool.addOperators(operators);
  }

  /// @notice Test that verifies that the number of operators in the pool is
  /// updated
  function test_UpdatesTheNumberOfOperatorsInThePool() public {
    changePrank(OWNER);

    uint256 numOperatorsBefore = s_operatorStakingPool.getNumOperators();
    address[] memory operators = _getDefaultOperators();
    s_operatorStakingPool.addOperators(operators);
    assertEq(s_operatorStakingPool.getNumOperators(), numOperatorsBefore + operators.length);
  }
}

contract OperatorStakingPool_AddOperators_WithStakers is StakingPool_WithStakers {
  function test_RevertWhen_OperatorListContainsCommunityStaker() public {
    changePrank(OWNER);

    address[] memory operators = new address[](2);
    operators[0] = COMMUNITY_STAKER_ONE;
    operators[1] = OPERATOR_STAKER_ONE;
    vm.expectRevert(
      abi.encodeWithSelector(
        OperatorStakingPool.OperatorCannotBeCommunityStaker.selector, COMMUNITY_STAKER_ONE
      )
    );
    s_operatorStakingPool.addOperators(operators);
  }
}

contract OperatorStakingPool_RemoveOperators_WhenPoolNotOpen is BaseTest {
  function test_RevertWhen_PoolNotOpen() public {
    changePrank(OWNER);

    address[] memory operatorsToRemove = new address[](1);
    operatorsToRemove[0] = OPERATOR_STAKER_ONE;
    vm.expectRevert(IStakingOwner.PoolNotOpen.selector);
    s_operatorStakingPool.removeOperators(operatorsToRemove);
  }

  function test_RevertWhen_PoolHasBeenClosed() public {
    changePrank(OWNER);

    s_operatorStakingPool.addOperators(_getDefaultOperators());
    s_operatorStakingPool.open();
    s_operatorStakingPool.close();
    address[] memory operatorsToRemove = new address[](1);
    operatorsToRemove[0] = OPERATOR_STAKER_ONE;
    vm.expectRevert(IStakingOwner.PoolNotOpen.selector);
    s_operatorStakingPool.removeOperators(operatorsToRemove);
  }
}

contract OperatorStakingPool_RemoveOperators_WhenPoolOpen is StakingPool_WithStakers {
  event OperatorRemoved(address indexed operator, uint256 principal);

  function test_RevertWhen_NotOwnerRemoveOperators() public {
    changePrank(STRANGER);
    vm.expectRevert(
      _getExpectedMissingRoleErrorMessage(STRANGER, s_operatorStakingPool.DEFAULT_ADMIN_ROLE())
    );
    s_operatorStakingPool.removeOperators(_getDefaultOperators());
  }

  function test_RevertWhen_RemovingOperatorsWithNotUniqueInputList() public {
    changePrank(OWNER);
    address[] memory operatorsToRemove = new address[](2);
    operatorsToRemove[0] = OPERATOR_STAKER_ONE;
    operatorsToRemove[1] = OPERATOR_STAKER_ONE;

    vm.expectRevert(
      abi.encodeWithSelector(OperatorStakingPool.OperatorDoesNotExist.selector, OPERATOR_STAKER_ONE)
    );

    s_operatorStakingPool.removeOperators(operatorsToRemove);
  }

  function test_RevertWhen_RemoveNonOperators() public {
    changePrank(OWNER);
    address[] memory operatorsToRemove = new address[](1);
    operatorsToRemove[0] = COMMUNITY_STAKER_ONE;
    vm.expectRevert(
      abi.encodeWithSelector(
        OperatorStakingPool.OperatorDoesNotExist.selector, COMMUNITY_STAKER_ONE
      )
    );
    s_operatorStakingPool.removeOperators(operatorsToRemove);
  }

  function test_RevertWhen_RemoveAlreadyRemovedOperators() public {
    changePrank(OWNER);
    address[] memory operatorsToRemove = new address[](1);
    operatorsToRemove[0] = OPERATOR_STAKER_ONE;
    s_operatorStakingPool.removeOperators(operatorsToRemove);

    vm.expectRevert(
      abi.encodeWithSelector(OperatorStakingPool.OperatorDoesNotExist.selector, OPERATOR_STAKER_ONE)
    );
    s_operatorStakingPool.removeOperators(_getDefaultOperators());
  }

  function test_RevertWhen_AddAlreadyRemovedOperators() public {
    changePrank(OWNER);
    address[] memory operatorsToRemove = new address[](1);
    operatorsToRemove[0] = OPERATOR_STAKER_ONE;
    s_operatorStakingPool.removeOperators(operatorsToRemove);

    vm.expectRevert(
      abi.encodeWithSelector(
        OperatorStakingPool.OperatorHasBeenRemoved.selector, OPERATOR_STAKER_ONE
      )
    );
    s_operatorStakingPool.addOperators(operatorsToRemove);
  }

  function test_MarksTheOperatorsAsRemoved() public {
    changePrank(OWNER);
    assertEq(s_operatorStakingPool.isOperator(OPERATOR_STAKER_ONE), true);
    assertEq(s_operatorStakingPool.isRemoved(OPERATOR_STAKER_ONE), false);

    address[] memory operatorsToRemove = new address[](1);
    operatorsToRemove[0] = OPERATOR_STAKER_ONE;
    s_operatorStakingPool.removeOperators(operatorsToRemove);

    assertEq(s_operatorStakingPool.isOperator(OPERATOR_STAKER_ONE), false);
    assertEq(s_operatorStakingPool.isRemoved(OPERATOR_STAKER_ONE), true);
  }

  function test_UpdatesRemovedOperatorsPrincipal() public {
    uint256 principal = s_operatorStakingPool.getStakerPrincipal(OPERATOR_STAKER_ONE);

    changePrank(OWNER);
    address[] memory operatorsToRemove = new address[](1);
    operatorsToRemove[0] = OPERATOR_STAKER_ONE;
    s_operatorStakingPool.removeOperators(operatorsToRemove);

    assertEq(s_operatorStakingPool.getStakerPrincipal(OPERATOR_STAKER_ONE), 0);
    assertEq(s_operatorStakingPool.getRemovedPrincipal(OPERATOR_STAKER_ONE), principal);
  }

  function test_UpdatesRemovedOperatorsRewards() public {
    // accrue some rewards
    vm.warp(block.timestamp + 14 days);

    uint256 totalReward = s_rewardVault.getReward(OPERATOR_STAKER_ONE);

    changePrank(OWNER);
    address[] memory operatorsToRemove = new address[](1);
    operatorsToRemove[0] = OPERATOR_STAKER_ONE;
    s_operatorStakingPool.removeOperators(operatorsToRemove);

    // finalizes the operator's rewards
    RewardVault.StakerReward memory stakerReward =
      s_rewardVault.getStoredReward(OPERATOR_STAKER_ONE);
    assertEq(stakerReward.storedBaseReward, 0);
    assertEq(stakerReward.finalizedBaseReward + stakerReward.finalizedDelegatedReward, totalReward);
  }

  function test_RedistributesRemovedOperatorsForfeitedRewards() public {
    // accrue some rewards
    vm.warp(block.timestamp + 14 days);
    changePrank(address(s_operatorStakingPool));
    s_rewardVault.updateReward(address(0), 0);

    ForfeitedRewardDistribution memory distribution = _calculateForfeitedRewardDistribution({
      staker: OPERATOR_STAKER_ONE,
      isOperator: true,
      isPrincipalDecreased: true
    });
    RewardVault.RewardBuckets memory bucketsBefore = s_rewardVault.getRewardBuckets();

    changePrank(OWNER);
    address[] memory operatorsToRemove = new address[](1);
    operatorsToRemove[0] = OPERATOR_STAKER_ONE;
    s_operatorStakingPool.removeOperators(operatorsToRemove);

    RewardVault.RewardBuckets memory bucketsAfter = s_rewardVault.getRewardBuckets();
    assertEq(
      bucketsAfter.communityBase.vestedRewardPerToken,
      bucketsBefore.communityBase.vestedRewardPerToken
    );
    assertEq(
      bucketsAfter.operatorBase.vestedRewardPerToken,
      bucketsBefore.operatorBase.vestedRewardPerToken + distribution.vestedRewardPerToken
    );
    assertEq(
      bucketsAfter.operatorDelegated.vestedRewardPerToken,
      bucketsBefore.operatorDelegated.vestedRewardPerToken
    );
  }

  function test_ResetsRemovedOperatorsMultipliers() public {
    // accrue some rewards
    vm.warp(block.timestamp + 14 days);

    changePrank(OWNER);
    address[] memory operatorsToRemove = new address[](1);
    operatorsToRemove[0] = OPERATOR_STAKER_ONE;
    s_operatorStakingPool.removeOperators(operatorsToRemove);

    assertEq(s_operatorStakingPool.getStakerStakedAtTime(OPERATOR_STAKER_ONE), 0);
    assertEq(s_rewardVault.getMultiplier(OPERATOR_STAKER_ONE), 0);
  }

  function test_RemovedOperatorsDoNotEarnMoreRewards() public {
    // accrue some rewards
    vm.warp(block.timestamp + 14 days);

    uint256 rewardBefore = s_rewardVault.getReward(OPERATOR_STAKER_ONE);

    changePrank(OWNER);
    address[] memory operatorsToRemove = new address[](1);
    operatorsToRemove[0] = OPERATOR_STAKER_ONE;
    s_operatorStakingPool.removeOperators(operatorsToRemove);
    assertEq(s_rewardVault.getReward(OPERATOR_STAKER_ONE), rewardBefore);

    vm.warp(block.timestamp + 14 days);

    assertEq(s_rewardVault.getReward(OPERATOR_STAKER_ONE), rewardBefore);
  }

  function test_RemoveOperatorsEmitsEvent() public {
    uint256 principal = s_operatorStakingPool.getStakerPrincipal(OPERATOR_STAKER_ONE);

    changePrank(OWNER);
    address[] memory operatorsToRemove = new address[](1);
    operatorsToRemove[0] = OPERATOR_STAKER_ONE;
    vm.expectEmit(false, false, false, true, address(s_operatorStakingPool));
    emit OperatorRemoved(OPERATOR_STAKER_ONE, principal);
    s_operatorStakingPool.removeOperators(operatorsToRemove);
  }

  function test_UpdatesTheNumberOfOperatorsInThePool() public {
    changePrank(OWNER);

    uint256 numOperatorsBefore = s_operatorStakingPool.getNumOperators();
    address[] memory operatorsToRemove = new address[](1);
    operatorsToRemove[0] = OPERATOR_STAKER_ONE;
    s_operatorStakingPool.removeOperators(operatorsToRemove);
    assertEq(s_operatorStakingPool.getNumOperators(), numOperatorsBefore - operatorsToRemove.length);
  }
}

contract OperatorStakingPool_IsOperator is BaseTest {
  /// @notice Test that verifies the getter function for operators returns the correct value
  function test_IsOperator() public {
    changePrank(OWNER);

    address[] memory operators = new address[](1);
    operators[0] = OPERATOR_STAKER_ONE;

    assertEq(s_operatorStakingPool.isOperator(OPERATOR_STAKER_ONE), false);
    s_operatorStakingPool.addOperators(operators);
    assertEq(s_operatorStakingPool.isOperator(OPERATOR_STAKER_ONE), true);
  }
}

contract OperatorStakingPool_UnstakeRemovedPrincipal_WhenPoolClosed is StakingPool_WithStakers {
  function setUp() public override {
    StakingPool_WithStakers.setUp();
    changePrank(OWNER);

    // Remove operators
    address[] memory operatorsToRemove = new address[](1);
    operatorsToRemove[0] = OPERATOR_STAKER_ONE;
    s_operatorStakingPool.removeOperators(operatorsToRemove);

    s_operatorStakingPool.close();
  }

  function test_CorrectlyUpdatesStakerStatePrincipal() public {
    changePrank(OPERATOR_STAKER_ONE);
    s_operatorStakingPool.unstakeRemovedPrincipal();
    assertEq(s_operatorStakingPool.getRemovedPrincipal(OPERATOR_STAKER_ONE), 0);
  }

  function test_CorrectlyTransferTokensToStaker() public {
    uint256 initialBalance = s_LINK.balanceOf(OPERATOR_STAKER_ONE);
    uint256 removedPrincipal = s_operatorStakingPool.getRemovedPrincipal(OPERATOR_STAKER_ONE);
    changePrank(OPERATOR_STAKER_ONE);
    s_operatorStakingPool.unstakeRemovedPrincipal();
    assertEq(s_LINK.balanceOf(OPERATOR_STAKER_ONE), initialBalance + removedPrincipal);
  }

  function test_EmitsEvent() public {
    changePrank(OPERATOR_STAKER_ONE);
    vm.expectEmit(true, true, true, true, address(s_operatorStakingPool));
    emit Unstaked(
      OPERATOR_STAKER_ONE, s_operatorStakingPool.getRemovedPrincipal(OPERATOR_STAKER_ONE), 0
    );
    s_operatorStakingPool.unstakeRemovedPrincipal();
  }
}

contract OperatorStakingPool_UnstakeRemovedPrincipal_WhenUnbondingNotStarted is
  StakingPool_WithStakers
{
  function test_RevertWhen_UnstakeRemovedPrincipal() external {
    vm.expectRevert(
      abi.encodeWithSelector(StakingPoolBase.StakerNotInClaimPeriod.selector, OPERATOR_STAKER_ONE)
    );
    changePrank(OPERATOR_STAKER_ONE);
    s_operatorStakingPool.unstakeRemovedPrincipal();
  }
}

contract OperatorStakingPool_UnstakeRemovedPrincipal_WhenPoolOpen_InUnbondingPeriod is
  StakingPool_InUnbondingPeriod
{
  function setUp() public override {
    StakingPool_InUnbondingPeriod.setUp();

    changePrank(OWNER);

    // Remove operators
    address[] memory operatorsToRemove = new address[](1);
    operatorsToRemove[0] = OPERATOR_STAKER_ONE;
    s_operatorStakingPool.removeOperators(operatorsToRemove);
  }

  function test_RevertWhen_StakerTriesToUnstake() external {
    vm.expectRevert(
      abi.encodeWithSelector(StakingPoolBase.StakerNotInClaimPeriod.selector, OPERATOR_STAKER_ONE)
    );
    changePrank(OPERATOR_STAKER_ONE);
    s_operatorStakingPool.unstakeRemovedPrincipal();
  }
}

contract OperatorStakingPool_UnstakeRemovedPrincipal_WhenPoolOpen_InClaimPeriod is
  StakingPool_InClaimPeriod
{
  function setUp() public override {
    StakingPool_InClaimPeriod.setUp();

    changePrank(OWNER);

    // Remove operators
    address[] memory operatorsToRemove = new address[](1);
    operatorsToRemove[0] = OPERATOR_STAKER_ONE;
    s_operatorStakingPool.removeOperators(operatorsToRemove);
  }

  function test_RevertWhen_NonRemovedOperatorTriesToUnstake() external {
    vm.expectRevert(IStakingPool.UnstakeExceedsPrincipal.selector);
    changePrank(OPERATOR_STAKER_TWO);
    s_operatorStakingPool.unstakeRemovedPrincipal();
  }

  function test_CorrectlyUpdatesStakerStatePrincipal() public {
    changePrank(OPERATOR_STAKER_ONE);
    s_operatorStakingPool.unstakeRemovedPrincipal();
    assertEq(s_operatorStakingPool.getRemovedPrincipal(OPERATOR_STAKER_ONE), 0);
  }

  function test_CorrectlyTransferTokensToStaker() public {
    uint256 initialBalance = s_LINK.balanceOf(OPERATOR_STAKER_ONE);
    uint256 removedPrincipal = s_operatorStakingPool.getRemovedPrincipal(OPERATOR_STAKER_ONE);
    changePrank(OPERATOR_STAKER_ONE);
    s_operatorStakingPool.unstakeRemovedPrincipal();
    assertEq(s_LINK.balanceOf(OPERATOR_STAKER_ONE), initialBalance + removedPrincipal);
  }

  function test_EmitsEvent() public {
    changePrank(OPERATOR_STAKER_ONE);
    vm.expectEmit(true, true, true, true, address(s_operatorStakingPool));
    emit Unstaked(
      OPERATOR_STAKER_ONE, s_operatorStakingPool.getRemovedPrincipal(OPERATOR_STAKER_ONE), 0
    );
    s_operatorStakingPool.unstakeRemovedPrincipal();
  }
}

contract OperatorStakingPool_Constructor is IStakingPool_Constructor, BaseTest {
  function test_RevertWhen_MinUnbondingPeriodIsGreaterThanMaxUnbondingPeriod() public {
    vm.expectRevert(
      abi.encodeWithSelector(
        StakingPoolBase.InvalidUnbondingPeriodRange.selector,
        MIN_UNBONDING_PERIOD,
        MIN_UNBONDING_PERIOD - 1
      )
    );
    new OperatorStakingPool(
            OperatorStakingPool.ConstructorParams({
                minInitialOperatorCount: MIN_INITIAL_OPERATOR_COUNT,
                baseParams: StakingPoolBase.ConstructorParamsBase({
                    LINKAddress: s_LINK,
                    initialMaxPoolSize: OPERATOR_MAX_POOL_SIZE,
                    initialMaxPrincipalPerStaker: OPERATOR_MAX_PRINCIPAL,
                    minPrincipalPerStaker: OPERATOR_MIN_PRINCIPAL,
                    initialUnbondingPeriod: INITIAL_UNBONDING_PERIOD,
                    maxUnbondingPeriod: MIN_UNBONDING_PERIOD - 1,
                    initialClaimPeriod: INITIAL_CLAIM_PERIOD,
                    minClaimPeriod: MIN_CLAIM_PERIOD,
                    maxClaimPeriod: MAX_CLAIM_PERIOD,
                    adminRoleTransferDelay: ADMIN_ROLE_TRANSFER_DELAY
                })
            })
        );
  }

  function test_RevertWhen_UnbondingPeriodIsLessThanMinUnbondingPeriod() public {
    vm.expectRevert(StakingPoolBase.InvalidUnbondingPeriod.selector);
    new OperatorStakingPool(
            OperatorStakingPool.ConstructorParams({
                minInitialOperatorCount: MIN_INITIAL_OPERATOR_COUNT,
                baseParams: StakingPoolBase.ConstructorParamsBase({
                    LINKAddress: s_LINK,
                    initialMaxPoolSize: OPERATOR_MAX_POOL_SIZE,
                    initialMaxPrincipalPerStaker: OPERATOR_MAX_PRINCIPAL,
                    minPrincipalPerStaker: OPERATOR_MIN_PRINCIPAL,
                    initialUnbondingPeriod: MIN_UNBONDING_PERIOD - 1,
                    maxUnbondingPeriod: MAX_UNBONDING_PERIOD,
                    initialClaimPeriod: INITIAL_CLAIM_PERIOD,
                    minClaimPeriod: MIN_CLAIM_PERIOD,
                    maxClaimPeriod: MAX_CLAIM_PERIOD,
                    adminRoleTransferDelay: ADMIN_ROLE_TRANSFER_DELAY
                })
            })
        );
  }

  function test_RevertWhen_UnbondingPeriodIsGreaterThanMaxUnbondingPeriod() public {
    vm.expectRevert(StakingPoolBase.InvalidUnbondingPeriod.selector);
    new OperatorStakingPool(
            OperatorStakingPool.ConstructorParams({
                minInitialOperatorCount: MIN_INITIAL_OPERATOR_COUNT,
                baseParams: StakingPoolBase.ConstructorParamsBase({
                    LINKAddress: s_LINK,
                    initialMaxPoolSize: OPERATOR_MAX_POOL_SIZE,
                    initialMaxPrincipalPerStaker: OPERATOR_MAX_PRINCIPAL,
                    minPrincipalPerStaker: OPERATOR_MIN_PRINCIPAL,
                    initialUnbondingPeriod: MAX_UNBONDING_PERIOD + 1,
                    maxUnbondingPeriod: MAX_UNBONDING_PERIOD,
                    initialClaimPeriod: INITIAL_CLAIM_PERIOD,
                    minClaimPeriod: MIN_CLAIM_PERIOD,
                    maxClaimPeriod: MAX_CLAIM_PERIOD,
                    adminRoleTransferDelay: ADMIN_ROLE_TRANSFER_DELAY
                })
            })
        );
  }

  function test_RevertWhen_ClaimPeriodIsZero() external override {
    vm.expectRevert(StakingPoolBase.InvalidClaimPeriod.selector);
    new OperatorStakingPool(
            OperatorStakingPool.ConstructorParams({
                minInitialOperatorCount: MIN_INITIAL_OPERATOR_COUNT,
                baseParams: StakingPoolBase.ConstructorParamsBase({
                    LINKAddress: s_LINK,
                    initialMaxPoolSize: OPERATOR_MAX_POOL_SIZE,
                    initialMaxPrincipalPerStaker: OPERATOR_MAX_PRINCIPAL,
                    minPrincipalPerStaker: OPERATOR_MIN_PRINCIPAL,
                    initialUnbondingPeriod: INITIAL_UNBONDING_PERIOD,
                    maxUnbondingPeriod: MAX_UNBONDING_PERIOD,
                    initialClaimPeriod: 0,
                    minClaimPeriod: MIN_CLAIM_PERIOD,
                    maxClaimPeriod: MAX_CLAIM_PERIOD,
                    adminRoleTransferDelay: ADMIN_ROLE_TRANSFER_DELAY
                })
            })
        );
  }

  function test_RevertWhen_MinClaimPeriodIsGreaterThanMaxClaimPeriod() public {
    vm.expectRevert(
      abi.encodeWithSelector(
        StakingPoolBase.InvalidClaimPeriodRange.selector, MAX_CLAIM_PERIOD, MIN_CLAIM_PERIOD
      )
    );
    new OperatorStakingPool(
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
    new OperatorStakingPool(
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
    new OperatorStakingPool(
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
                    minClaimPeriod: MAX_CLAIM_PERIOD,
                    maxClaimPeriod: MAX_CLAIM_PERIOD,
                    adminRoleTransferDelay: ADMIN_ROLE_TRANSFER_DELAY
                })
            })
        );
  }

  function test_RevertWhen_MaxPoolSizeIsZero() public {
    vm.expectRevert(abi.encodeWithSelector(IStakingOwner.InvalidPoolSize.selector, 0));
    new OperatorStakingPool(
            OperatorStakingPool.ConstructorParams({
                minInitialOperatorCount: MIN_INITIAL_OPERATOR_COUNT,
                baseParams: StakingPoolBase.ConstructorParamsBase({
                    LINKAddress: s_LINK,
                    initialMaxPoolSize: 0,
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

  function test_RevertWhen_MinStakeAmountIsEqualToMaxStakeAmount() public {
    vm.expectRevert(IStakingOwner.InvalidMinStakeAmount.selector);
    new OperatorStakingPool(
            OperatorStakingPool.ConstructorParams({
                minInitialOperatorCount: MIN_INITIAL_OPERATOR_COUNT,
                baseParams: StakingPoolBase.ConstructorParamsBase({
                    LINKAddress: s_LINK,
                    initialMaxPoolSize: OPERATOR_MAX_POOL_SIZE,
                    initialMaxPrincipalPerStaker: OPERATOR_MAX_PRINCIPAL,
                    minPrincipalPerStaker: OPERATOR_MAX_PRINCIPAL,
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
    new OperatorStakingPool(
            OperatorStakingPool.ConstructorParams({
                minInitialOperatorCount: MIN_INITIAL_OPERATOR_COUNT,
                baseParams: StakingPoolBase.ConstructorParamsBase({
                    LINKAddress: s_LINK,
                    initialMaxPoolSize: OPERATOR_MAX_POOL_SIZE,
                    initialMaxPrincipalPerStaker: OPERATOR_MAX_PRINCIPAL,
                    minPrincipalPerStaker: OPERATOR_MAX_PRINCIPAL + 1000,
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
    new OperatorStakingPool(
            OperatorStakingPool.ConstructorParams({
                minInitialOperatorCount: MIN_INITIAL_OPERATOR_COUNT,
                baseParams: StakingPoolBase.ConstructorParamsBase({
                    LINKAddress: s_LINK,
                    initialMaxPoolSize: OPERATOR_MAX_POOL_SIZE,
                    initialMaxPrincipalPerStaker: OPERATOR_MAX_PRINCIPAL,
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
    new OperatorStakingPool(
            OperatorStakingPool.ConstructorParams({
                minInitialOperatorCount: MIN_INITIAL_OPERATOR_COUNT,
                baseParams: StakingPoolBase.ConstructorParamsBase({
                    LINKAddress: s_LINK,
                    initialMaxPoolSize: OPERATOR_MAX_POOL_SIZE,
                    initialMaxPrincipalPerStaker: 0,
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

  function test_RevertWhen_LINKAddressIsZero() public {
    vm.expectRevert(IStakingPool.InvalidZeroAddress.selector);
    new OperatorStakingPool(
            OperatorStakingPool.ConstructorParams({
                minInitialOperatorCount: MIN_INITIAL_OPERATOR_COUNT,
                baseParams: StakingPoolBase.ConstructorParamsBase({
                    LINKAddress: LinkTokenInterface(address(0)),
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

  function test_InitializesUnbondingParams() external override {
    (uint256 unbondingPeriod, uint256 claimPeriod) = s_operatorStakingPool.getUnbondingParams();
    assertEq(unbondingPeriod, UNBONDING_PERIOD);
    assertEq(claimPeriod, CLAIM_PERIOD);
  }

  function test_InitializesUnbondingPeriodLimits() public {
    (uint256 minUnbondingPeriod, uint256 maxUnbondingPeriod) =
      s_operatorStakingPool.getUnbondingPeriodLimits();
    assertEq(minUnbondingPeriod, MIN_UNBONDING_PERIOD);
    assertEq(maxUnbondingPeriod, MAX_UNBONDING_PERIOD);
  }

  function test_SetsTheLINKToken() public {
    assertEq(s_operatorStakingPool.getChainlinkToken(), address(s_LINK));
  }

  function test_HasCorrectInitialLimits() public {
    uint256 operatorMaxPoolSize = s_operatorStakingPool.getMaxPoolSize();
    (uint256 operatorMinPrincipal, uint256 operatorMaxPrincipal) =
      s_operatorStakingPool.getStakerLimits();
    assertEq(operatorMaxPoolSize, OPERATOR_MAX_POOL_SIZE);
    assertEq(operatorMinPrincipal, OPERATOR_MIN_PRINCIPAL);
    assertEq(operatorMaxPrincipal, OPERATOR_MAX_PRINCIPAL);
  }

  function test_HasCorrectInitialClaimPeriodLimits() public {
    (uint256 minClaimPeriod, uint256 maxClaimPeriod) = s_operatorStakingPool.getClaimPeriodLimits();
    assertEq(minClaimPeriod, MIN_CLAIM_PERIOD);
    assertEq(maxClaimPeriod, MAX_CLAIM_PERIOD);
  }

  function test_CheckpointIdIsZero() public {
    assertEq(s_operatorStakingPool.getCurrentCheckpointId(), 0);
  }

  function test_InitializesRoles() public {
    assertEq(s_operatorStakingPool.hasRole(s_operatorStakingPool.DEFAULT_ADMIN_ROLE(), OWNER), true);
  }
}

contract OperatorStakingPool_GetStaker is IStakingPool_GetStaker, StakingPool_WithStakers {
  function test_ReturnsZeroIfStakerHasNotStaked() public override {
    assertEq(s_operatorStakingPool.getStakerPrincipal(STRANGER), 0);
    assertEq(s_operatorStakingPool.getStakerStakedAtTime(STRANGER), 0);
  }

  function test_ReturnsZeroIfStakerIsInAnotherPool() public override {
    assertEq(s_operatorStakingPool.getStakerPrincipal(STRANGER), 0);
    assertEq(s_operatorStakingPool.getStakerStakedAtTime(COMMUNITY_STAKER_ONE), 0);
  }

  function test_ReturnsCorrectStakeAmountIfStakerHasStaked() public override {
    assertEq(s_operatorStakingPool.getStakerPrincipal(OPERATOR_STAKER_ONE), OPERATOR_MIN_PRINCIPAL);
    assertEq(s_operatorStakingPool.getStakerStakedAtTime(OPERATOR_STAKER_ONE), block.timestamp);
  }
}

contract OperatorStakingPool_GetClaimPeriodEndsAtDuringClaimPeriod is
  IStakingPool_GetClaimPeriodEndsAt,
  StakingPool_InUnbondingPeriod
{
  event UnbondingPeriodStarted(address indexed staker);

  function test_ReturnsCorrectClaimPeriodEndsAt() public override {
    changePrank(OPERATOR_STAKER_ONE);
    uint256 claimPeriodEndsAt = s_operatorStakingPool.getClaimPeriodEndsAt(OPERATOR_STAKER_ONE);

    assertEq(claimPeriodEndsAt, block.timestamp + CLAIM_PERIOD + UNBONDING_PERIOD);
  }
}

contract OperatorStakingPool_GetClaimPeriodEndsAtBeforeUnbondingPeriod is
  IStakingPool_GetClaimPeriodEndsAt,
  StakingPool_WithStakers
{
  function test_ReturnsCorrectClaimPeriodEndsAt() public override {
    changePrank(OPERATOR_STAKER_ONE);
    uint256 claimPeriodEndsAt = s_operatorStakingPool.getClaimPeriodEndsAt(OPERATOR_STAKER_ONE);

    assertEq(claimPeriodEndsAt, 0);
  }
}

contract OperatorStakingPool_SetPoolConfig is IStakingPool_SetPoolConfig, StakingPool_WithStakers {
  uint256 internal constant NEW_MAX_POOL_SIZE = 40_000_000 ether;
  uint256 internal constant NEW_MAX_PRINCIPAL = 80_000 ether;

  function setUp() public override {
    StakingPool_WithStakers.setUp();
    changePrank(OWNER);
  }

  function test_RevertWhen_MaxPoolSizeLessThanReservedOperatorSpace() public {
    vm.expectRevert(
      abi.encodeWithSelector(
        OperatorStakingPool.InsufficientPoolSpace.selector,
        OPERATOR_MAX_POOL_SIZE,
        OPERATOR_MAX_PRINCIPAL * MIN_INITIAL_OPERATOR_COUNT,
        MIN_INITIAL_OPERATOR_COUNT
      )
    );
    changePrank(OWNER);

    s_operatorStakingPool.setPoolConfig(
      OPERATOR_MAX_POOL_SIZE, OPERATOR_MAX_PRINCIPAL * MIN_INITIAL_OPERATOR_COUNT
    );
  }

  function test_RevertWhen_ConfigChangedByNonAdmin() public {
    vm.expectRevert(
      _getExpectedMissingRoleErrorMessage(STRANGER, s_operatorStakingPool.DEFAULT_ADMIN_ROLE())
    );
    changePrank(STRANGER);
    s_operatorStakingPool.setPoolConfig(OPERATOR_MAX_POOL_SIZE, OPERATOR_MAX_PRINCIPAL);
  }

  function test_RevertWhen_PoolNotOpen() public {
    OperatorStakingPool notOpenedNopStakingPool = new OperatorStakingPool(
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
    vm.expectRevert(IStakingOwner.PoolNotOpen.selector);
    notOpenedNopStakingPool.setPoolConfig(OPERATOR_MAX_POOL_SIZE, OPERATOR_MAX_PRINCIPAL);
  }

  function test_RevertWhen_PoolHasBeenClosed() public {
    changePrank(OWNER);

    s_operatorStakingPool.close();
    vm.expectRevert(IStakingOwner.PoolNotOpen.selector);
    s_operatorStakingPool.setPoolConfig(OPERATOR_MAX_POOL_SIZE, OPERATOR_MAX_PRINCIPAL);
  }

  function test_RevertWhen_TryingToDecreaseMaxPoolSize() public {
    uint256 newMaxPoolSize = OPERATOR_MAX_POOL_SIZE / 2;
    vm.expectRevert(abi.encodeWithSelector(IStakingOwner.InvalidPoolSize.selector, newMaxPoolSize));
    s_operatorStakingPool.setPoolConfig(newMaxPoolSize, OPERATOR_MAX_PRINCIPAL / 2);
  }

  function test_RevertWhen_NewMaxStakerPrincipalLowerThanCurrentMaxPrincipal() public {
    uint256 newPrincipal = OPERATOR_MAX_PRINCIPAL / 2;
    vm.expectRevert(
      abi.encodeWithSelector(IStakingOwner.InvalidMaxStakeAmount.selector, newPrincipal)
    );
    s_operatorStakingPool.setPoolConfig(OPERATOR_MAX_POOL_SIZE, newPrincipal);
  }

  function test_RevertWhen_MaxPoolSizeLowerThanMaxPrincipal() public {
    uint256 newPrincipal = OPERATOR_MAX_POOL_SIZE * 2;
    vm.expectRevert(
      abi.encodeWithSelector(
        OperatorStakingPool.InsufficientPoolSpace.selector,
        OPERATOR_MAX_POOL_SIZE,
        newPrincipal,
        MIN_INITIAL_OPERATOR_COUNT
      )
    );
    s_operatorStakingPool.setPoolConfig(OPERATOR_MAX_POOL_SIZE, newPrincipal);
  }

  function test_MaxPoolSizeIncreased() public {
    uint256 newMaxPoolSize = OPERATOR_MAX_POOL_SIZE * 2;
    s_operatorStakingPool.setPoolConfig(newMaxPoolSize, OPERATOR_MAX_PRINCIPAL);
    assertEq(s_operatorStakingPool.getMaxPoolSize(), newMaxPoolSize);
  }

  function test_MaxPrincipalIncreased() public {
    uint256 newMaxPrincipal = OPERATOR_MAX_PRINCIPAL * 2;
    s_operatorStakingPool.setPoolConfig(OPERATOR_MAX_POOL_SIZE, newMaxPrincipal);
    (, uint256 operatorMaxPrincipal) = s_operatorStakingPool.getStakerLimits();
    assertEq(operatorMaxPrincipal, newMaxPrincipal);
  }

  function test_RevertWhen_TryingToStakeLessThanMinPrincipal() public {
    address operator = _getDefaultOperators()[2];
    changePrank(OWNER);
    s_LINK.transfer(operator, 10_000 ether);

    changePrank(operator);
    uint256 stakeAmount = OPERATOR_MIN_PRINCIPAL - 1;

    vm.expectRevert(IStakingPool.InsufficientStakeAmount.selector);
    s_LINK.transferAndCall(address(s_operatorStakingPool), stakeAmount, '');
  }

  function test_RevertWhen_TryingToStakeMoreThanMaxPrincipal() public {
    changePrank(OPERATOR_STAKER_ONE);
    uint256 stakeAmount = OPERATOR_MAX_PRINCIPAL + 1;

    vm.expectRevert(IStakingPool.ExceedsMaxStakeAmount.selector);
    s_LINK.transferAndCall(address(s_operatorStakingPool), stakeAmount, '');
  }

  function test_RevertWhen_AddingToStakeBringsPrincipalOverMax() public {
    changePrank(OPERATOR_STAKER_ONE);
    uint256 stakeAmount = OPERATOR_MIN_PRINCIPAL;
    s_LINK.transferAndCall(address(s_operatorStakingPool), stakeAmount, '');

    stakeAmount = OPERATOR_MAX_PRINCIPAL;
    vm.expectRevert(IStakingPool.ExceedsMaxStakeAmount.selector);
    s_LINK.transferAndCall(address(s_operatorStakingPool), stakeAmount, '');
  }
}

contract OperatorStakingPool_SetMigrationProxy is
  IStakingPool_SetMigrationProxy,
  StakingPool_MigrationProxyUnset
{
  event MigrationProxySet(address indexed migrationProxy);

  function test_RevertWhen_NotOwnerSetsMigrationProxy() public {
    changePrank(STRANGER);

    vm.expectRevert(
      _getExpectedMissingRoleErrorMessage(STRANGER, s_operatorStakingPool.DEFAULT_ADMIN_ROLE())
    );
    s_operatorStakingPool.setMigrationProxy(address(s_migrationProxy));
  }

  function test_RevertWhen_OwnerSetsMigrationProxyToZero() public {
    changePrank(OWNER);

    vm.expectRevert(abi.encodeWithSelector(IStakingPool.InvalidZeroAddress.selector));
    s_operatorStakingPool.setMigrationProxy(address(0));
  }

  function test_OwnerCanSetMigrationProxy() public {
    changePrank(OWNER);

    assertEq(s_operatorStakingPool.getMigrationProxy(), address(0));
    s_operatorStakingPool.setMigrationProxy(address(s_migrationProxy));
    assertEq(s_operatorStakingPool.getMigrationProxy(), address(s_migrationProxy));
  }

  function test_EmitsEventWhenMigrationProxySet() public {
    changePrank(OWNER);
    vm.expectEmit(true, true, true, true, address(s_operatorStakingPool));
    emit MigrationProxySet(address(s_migrationProxy));
    s_operatorStakingPool.setMigrationProxy(address(s_migrationProxy));
  }
}

contract OperatorStakingPool_Openable is IOpenableTest, BaseTest {
  event PoolOpened();
  event PoolClosed();

  function test_RevertWhen_NotOwnerOpens() public {
    changePrank(STRANGER);

    vm.expectRevert(
      _getExpectedMissingRoleErrorMessage(STRANGER, s_operatorStakingPool.DEFAULT_ADMIN_ROLE())
    );
    s_operatorStakingPool.open();
  }

  function test_OwnerCanOpen() public {
    changePrank(OWNER);

    s_operatorStakingPool.addOperators(_getDefaultOperators());

    vm.expectEmit(true, true, true, true, address(s_operatorStakingPool));
    emit PoolOpened();
    s_operatorStakingPool.open();

    assertEq(s_operatorStakingPool.isOpen(), true);
  }

  function test_RevertWhen_AlreadyOpened() public {
    changePrank(OWNER);

    s_operatorStakingPool.addOperators(_getDefaultOperators());

    s_operatorStakingPool.open();
    vm.expectRevert(abi.encodeWithSelector(IStakingOwner.PoolHasBeenOpened.selector));
    s_operatorStakingPool.open();
  }

  function test_RevertWhen_NoOperatorsAdded() public {
    changePrank(OWNER);
    vm.expectRevert(
      abi.encodeWithSelector(
        OperatorStakingPool.InadequateInitialOperatorCount.selector, 0, MIN_INITIAL_OPERATOR_COUNT
      )
    );
    s_operatorStakingPool.open();
  }

  function test_RevertWhen_OperatorsAddedButLessThanMinInitialOperatorCount() public {
    changePrank(OWNER);
    address[] memory operators = new address[](1);
    operators[0] = OPERATOR_STAKER_ONE;
    s_operatorStakingPool.addOperators(operators);
    vm.expectRevert(
      abi.encodeWithSelector(
        OperatorStakingPool.InadequateInitialOperatorCount.selector, 1, MIN_INITIAL_OPERATOR_COUNT
      )
    );
    s_operatorStakingPool.open();
  }

  function test_RevertWhen_NotOwnerCloses() public {
    changePrank(OWNER);

    s_operatorStakingPool.addOperators(_getDefaultOperators());
    s_operatorStakingPool.open();

    changePrank(STRANGER);

    vm.expectRevert(
      _getExpectedMissingRoleErrorMessage(STRANGER, s_operatorStakingPool.DEFAULT_ADMIN_ROLE())
    );
    s_operatorStakingPool.close();
  }

  function test_OwnerCanClose() public {
    changePrank(OWNER);

    s_operatorStakingPool.addOperators(_getDefaultOperators());
    s_operatorStakingPool.open();
    assertEq(s_operatorStakingPool.isOpen(), true);
    vm.expectEmit(true, true, true, true, address(s_operatorStakingPool));
    emit PoolClosed();
    s_operatorStakingPool.close();
    assertEq(s_operatorStakingPool.isOpen(), false);
  }

  function test_RevertWhen_NotYetOpened() public {
    changePrank(OWNER);

    vm.expectRevert(IStakingOwner.PoolNotOpen.selector);
    s_operatorStakingPool.close();
  }

  function test_RevertWhen_AlreadyClosed() public {
    changePrank(OWNER);

    s_operatorStakingPool.addOperators(_getDefaultOperators());
    s_operatorStakingPool.open();
    s_operatorStakingPool.close();
    vm.expectRevert(IStakingOwner.PoolNotOpen.selector);
    s_operatorStakingPool.close();
  }

  function test_RevertWhen_TryingToOpenAgain() public {
    changePrank(OWNER);

    // Make sure block.timestamp is not 0
    vm.warp(block.timestamp + 10);

    s_operatorStakingPool.addOperators(_getDefaultOperators());
    s_operatorStakingPool.open();
    s_operatorStakingPool.close();
    vm.expectRevert(IStakingOwner.PoolHasBeenClosed.selector);
    s_operatorStakingPool.open();
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
    s_operatorStakingPool.open();
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
    s_operatorStakingPool.open();
  }
}

contract OperatorStakingPool_Pausable is IPausableTest, BaseTest {
  function test_RevertWhen_NotPauserEmergencyPause() public {
    changePrank(STRANGER);
    vm.expectRevert(
      _getExpectedMissingRoleErrorMessage(STRANGER, s_operatorStakingPool.PAUSER_ROLE())
    );

    s_operatorStakingPool.emergencyPause();
    assertEq(s_operatorStakingPool.paused(), false);
  }

  function test_PauserCanEmergencyPause() public {
    changePrank(PAUSER);

    s_operatorStakingPool.emergencyPause();
    assertEq(s_operatorStakingPool.paused(), true);
  }

  function test_RevertWhen_PausingWhenAlreadyPaused() public {
    changePrank(PAUSER);
    s_operatorStakingPool.emergencyPause();

    vm.expectRevert('Pausable: paused');
    s_operatorStakingPool.emergencyPause();
  }

  function test_RevertWhen_NotPauserEmergencyUnpause() public {
    changePrank(PAUSER);
    s_operatorStakingPool.emergencyPause();

    changePrank(STRANGER);
    vm.expectRevert(
      _getExpectedMissingRoleErrorMessage(STRANGER, s_operatorStakingPool.PAUSER_ROLE())
    );
    s_operatorStakingPool.emergencyUnpause();

    assertEq(s_operatorStakingPool.paused(), true);
  }

  function test_PauserCanEmergencyUnpause() public {
    changePrank(PAUSER);
    s_operatorStakingPool.emergencyPause();
    s_operatorStakingPool.emergencyUnpause();
    assertEq(s_operatorStakingPool.paused(), false);
  }

  function test_RevertWhen_UnpausingWhenAlreadyUnpaused() public {
    changePrank(PAUSER);

    vm.expectRevert('Pausable: not paused');
    s_operatorStakingPool.emergencyUnpause();
  }
}

contract OperatorStakingPool_Unbond_WhenStakeIsNotUnbonding is
  IStakingPool_Unbond_WhenStakeIsNotUnbonding,
  StakingPool_WithStakers
{
  event UnbondingPeriodStarted(address indexed staker);

  function test_RevertWhen_StakerHasNotStaked() external override {
    changePrank(STRANGER);
    vm.expectRevert(abi.encodeWithSelector(IStakingPool.StakeNotFound.selector, STRANGER));
    s_operatorStakingPool.unbond();
  }

  function test_CorrectlySetsTheStakersUnbondingPeriod() external override {
    changePrank(OPERATOR_STAKER_ONE);
    (uint256 unbondingPeriod,) = s_operatorStakingPool.getUnbondingParams();
    s_operatorStakingPool.unbond();

    assertEq(
      s_operatorStakingPool.getUnbondingEndsAt(OPERATOR_STAKER_ONE),
      block.timestamp + unbondingPeriod
    );
  }

  function test_EmitsEvent() external override {
    vm.expectEmit(true, true, true, true, address(s_operatorStakingPool));
    changePrank(OPERATOR_STAKER_ONE);
    emit UnbondingPeriodStarted(OPERATOR_STAKER_ONE);
    s_operatorStakingPool.unbond();
  }

  function test_CorrectlySetsTheStakersClaimPeriod() external override {
    changePrank(OPERATOR_STAKER_ONE);
    (uint256 unbondingPeriod, uint256 claimPeriod) = s_operatorStakingPool.getUnbondingParams();
    s_operatorStakingPool.unbond();

    assertEq(
      s_operatorStakingPool.getClaimPeriodEndsAt(OPERATOR_STAKER_ONE),
      block.timestamp + unbondingPeriod + claimPeriod
    );
  }
}

contract OperatorStakingPool_Unbond_WhenStakeIsUnbonding is
  IStakingPool_Unbond_WhenStakeIsUnbonding,
  StakingPool_InUnbondingPeriod
{
  function test_RevertWhen_StakerIsAlreadyInUnbondingPeriod() external override {
    changePrank(OPERATOR_STAKER_ONE);
    vm.expectRevert(
      abi.encodeWithSelector(
        StakingPoolBase.UnbondingPeriodActive.selector,
        s_operatorStakingPool.getUnbondingEndsAt(OPERATOR_STAKER_ONE)
      )
    );
    s_operatorStakingPool.unbond();
  }

  function test_RevertWhen_StakerIsInClaimPeriod() external override {
    uint256 stakerUnbondingEndsAt = s_operatorStakingPool.getUnbondingEndsAt(OPERATOR_STAKER_ONE);
    vm.warp(stakerUnbondingEndsAt + 1);
    changePrank(OPERATOR_STAKER_ONE);
    vm.expectRevert(
      abi.encodeWithSelector(
        StakingPoolBase.UnbondingPeriodActive.selector,
        s_operatorStakingPool.getUnbondingEndsAt(OPERATOR_STAKER_ONE)
      )
    );
    s_operatorStakingPool.unbond();
  }

  function test_CorrectlySetsTheStakersUnbondingPeriodWhenOutsideClaimPeriod() external override {
    uint256 stakerUnbondingEndsAt = s_operatorStakingPool.getUnbondingEndsAt(OPERATOR_STAKER_ONE);
    (uint256 unbondingPeriod, uint256 claimPeriod) = s_operatorStakingPool.getUnbondingParams();
    uint256 unbondedAt = block.timestamp + stakerUnbondingEndsAt + claimPeriod + 1;
    vm.warp(unbondedAt);
    changePrank(OPERATOR_STAKER_ONE);
    s_operatorStakingPool.unbond();
    assertEq(
      s_operatorStakingPool.getUnbondingEndsAt(OPERATOR_STAKER_ONE), unbondedAt + unbondingPeriod
    );
  }
}

contract OperatorStakingPool_Unbond_WhenClaimPeriodEndsAt is StakingPool_WhenClaimPeriodEndsAt {
  function test_RevertWhen_StakerIsAtClaimPeriodEndsAt() public {
    changePrank(OPERATOR_STAKER_ONE);
    vm.expectRevert(
      abi.encodeWithSelector(
        StakingPoolBase.UnbondingPeriodActive.selector,
        s_operatorStakingPool.getUnbondingEndsAt(OPERATOR_STAKER_ONE)
      )
    );
    s_operatorStakingPool.unbond();
  }
}

contract OperatorStakingPool_Unbond_WhenStakerStakesAgainDuringUnbondingPeriod is
  IStakingPool_Unbond_WhenStakerStakesAgainDuringUnbondingPeriod,
  StakingPool_StakeInUnbondingPeriod
{
  function test_CorrectlyStartsTheUnbondingPeriod() external {
    changePrank(OPERATOR_STAKER_ONE);
    s_operatorStakingPool.unbond();
    assertEq(
      s_operatorStakingPool.getUnbondingEndsAt(OPERATOR_STAKER_ONE),
      block.timestamp + UNBONDING_PERIOD
    );
  }
}

contract OperatorStakingPool_OnTokenTransfer_WhenPoolNotOpen is BaseTest {
  function setUp() public override {
    BaseTest.setUp();

    changePrank(OWNER);
    s_operatorStakingPool.addOperators(_getDefaultOperators());

    // fund the migration proxy with LINK
    s_LINK.transfer(address(s_migrationProxy), OPERATOR_MIN_PRINCIPAL);
  }

  function test_RevertWhen_PoolNotOpen() public {
    changePrank(OPERATOR_STAKER_ONE);

    vm.expectRevert(IStakingOwner.PoolNotOpen.selector);
    s_LINK.transferAndCall(
      address(s_operatorStakingPool), OPERATOR_MIN_PRINCIPAL, abi.encode(OPERATOR_STAKER_ONE, '')
    );
  }

  function test_RevertWhen_PoolHasBeenClosed() public {
    changePrank(OWNER);

    s_operatorStakingPool.open();
    s_operatorStakingPool.close();

    changePrank(OPERATOR_STAKER_ONE);

    vm.expectRevert(IStakingOwner.PoolNotOpen.selector);
    s_LINK.transferAndCall(
      address(s_operatorStakingPool), OPERATOR_MIN_PRINCIPAL, abi.encode(OPERATOR_STAKER_ONE, '')
    );
  }
}

contract OperatorStakingPool_OnTokenTransfer_WhenPaused is
  IStakingPool_OnTokenTransfer_WhenPaused,
  StakingPool_WhenPaused
{
  function test_RevertWhen_AttemptingToStakeWhenPaused() public {
    changePrank(OPERATOR_STAKER_ONE);

    vm.expectRevert('Pausable: paused');
    s_LINK.transferAndCall(address(s_operatorStakingPool), OPERATOR_MIN_PRINCIPAL, '');
  }

  function test_RevertWhen_AttemptingToMigrateWhenPaused() public {
    changePrank(MOCK_STAKING_V01);

    vm.expectRevert('Pausable: paused');
    s_LINK.transferAndCall(
      address(s_migrationProxy),
      OPERATOR_MIN_PRINCIPAL + 100 ether,
      abi.encode(OPERATOR_STAKER_ONE, '')
    );
  }

  function test_CanStakeAfterUnpausing() public {
    changePrank(PAUSER);
    s_operatorStakingPool.emergencyUnpause();

    changePrank(OPERATOR_STAKER_ONE);
    s_LINK.transferAndCall(address(s_operatorStakingPool), OPERATOR_MIN_PRINCIPAL, '');
  }

  function test_CanMigrateIntoPoolAfterUnpausing() public {
    changePrank(PAUSER);
    s_operatorStakingPool.emergencyUnpause();

    changePrank(MOCK_STAKING_V01);
    s_LINK.transferAndCall(
      address(s_migrationProxy),
      OPERATOR_MIN_PRINCIPAL + 100 ether,
      abi.encode(OPERATOR_STAKER_ONE, '')
    );
  }
}

contract OperatorStakingPool_OnTokenTransfer_WhenPoolOpen is
  IStakingPool_OnTokenTransfer,
  StakingPool_WithStakers
{
  function setUp() public override {
    StakingPool_WithStakers.setUp();

    changePrank(OWNER);

    // fund the migration proxy with LINK
    s_LINK.transfer(address(s_migrationProxy), OPERATOR_MIN_PRINCIPAL);
  }

  function test_RevertWhen_OnTokenTransferNotFromLINK() public {
    vm.expectRevert(IStakingPool.SenderNotLinkToken.selector);
    s_operatorStakingPool.onTokenTransfer(address(0), 0, new bytes(0));
  }

  function test_RevertWhen_RewardVaultPaused() public {
    changePrank(PAUSER);
    s_rewardVault.emergencyPause();
    changePrank(address(s_LINK));
    vm.expectRevert(StakingPoolBase.RewardVaultNotActive.selector);
    s_communityStakingPool.onTokenTransfer(address(0), 0, new bytes(0));
  }

  function test_RevertWhen_StakerIsNotAOperator() public {
    changePrank(COMMUNITY_STAKER_ONE);

    vm.expectRevert(OperatorStakingPool.StakerNotOperator.selector);
    s_LINK.transferAndCall(
      address(s_operatorStakingPool), OPERATOR_MIN_PRINCIPAL, abi.encode(OPERATOR_STAKER_ONE, '')
    );
  }

  function test_RevertWhen_StakerAddressInDataIsZero() public {
    changePrank(address(s_migrationProxy));
    vm.expectRevert(IStakingPool.InvalidZeroAddress.selector);
    s_LINK.transferAndCall(
      address(s_operatorStakingPool), OPERATOR_MIN_PRINCIPAL, abi.encode(address(0), '')
    );
  }

  function test_StakingUpdatesPoolStateTotalPrincipal() public {
    changePrank(OPERATOR_STAKER_ONE);

    uint256 totalPrincipalBefore = s_operatorStakingPool.getTotalPrincipal();
    s_LINK.transferAndCall(
      address(s_operatorStakingPool), OPERATOR_MIN_PRINCIPAL, abi.encode(OPERATOR_STAKER_ONE, '')
    );
    assertEq(
      s_operatorStakingPool.getTotalPrincipal(), totalPrincipalBefore + OPERATOR_MIN_PRINCIPAL
    );
  }

  function test_StakingUpdatesStakerState() public {
    changePrank(OPERATOR_STAKER_ONE);

    uint256 stakerPrincipalBefore = s_operatorStakingPool.getStakerPrincipal(OPERATOR_STAKER_ONE);
    s_LINK.transferAndCall(
      address(s_operatorStakingPool), OPERATOR_MIN_PRINCIPAL, abi.encode(OPERATOR_STAKER_ONE, '')
    );
    assertEq(
      s_operatorStakingPool.getStakerPrincipal(OPERATOR_STAKER_ONE),
      stakerPrincipalBefore + OPERATOR_MIN_PRINCIPAL
    );

    // stake more
    vm.warp(block.timestamp + 10);
    stakerPrincipalBefore = s_operatorStakingPool.getStakerPrincipal(OPERATOR_STAKER_ONE);
    s_LINK.transferAndCall(address(s_operatorStakingPool), OPERATOR_MIN_PRINCIPAL, '');

    assertEq(
      s_operatorStakingPool.getStakerPrincipal(OPERATOR_STAKER_ONE),
      stakerPrincipalBefore + OPERATOR_MIN_PRINCIPAL
    );
    assertEq(s_operatorStakingPool.getStakerStakedAtTime(OPERATOR_STAKER_ONE), block.timestamp);
  }

  function test_StakingZeroAmountHasNoStateChanges() public {
    changePrank(OPERATOR_STAKER_ONE);

    uint256 stakerPrincipalBefore = s_operatorStakingPool.getStakerPrincipal(OPERATOR_STAKER_ONE);
    s_LINK.transferAndCall(
      address(s_operatorStakingPool), OPERATOR_MIN_PRINCIPAL, abi.encode(OPERATOR_STAKER_ONE, '')
    );
    assertEq(
      s_operatorStakingPool.getStakerPrincipal(OPERATOR_STAKER_ONE),
      stakerPrincipalBefore + OPERATOR_MIN_PRINCIPAL
    );

    // stake more
    vm.warp(block.timestamp + 10);
    stakerPrincipalBefore = s_operatorStakingPool.getStakerPrincipal(OPERATOR_STAKER_ONE);
    uint256 stakedAtTimeBefore = s_operatorStakingPool.getStakerStakedAtTime(OPERATOR_STAKER_ONE);
    s_LINK.transferAndCall(address(s_operatorStakingPool), 0, abi.encode(OPERATOR_STAKER_ONE, ''));

    assertEq(s_operatorStakingPool.getStakerPrincipal(OPERATOR_STAKER_ONE), stakerPrincipalBefore);
    assertEq(s_operatorStakingPool.getStakerStakedAtTime(OPERATOR_STAKER_ONE), stakedAtTimeBefore);
  }

  function test_StakingWithNoTimePassedSinceAvgStakingDoesNotUpdateAvgStakingTime() public {
    changePrank(OPERATOR_STAKER_ONE);

    uint256 stakedAtTimeBefore = s_operatorStakingPool.getStakerStakedAtTime(OPERATOR_STAKER_ONE);
    assertEq(s_operatorStakingPool.getStakerStakedAtTime(OPERATOR_STAKER_ONE), block.timestamp);

    s_LINK.transferAndCall(
      address(s_operatorStakingPool), OPERATOR_MIN_PRINCIPAL, abi.encode(OPERATOR_STAKER_ONE, '')
    );

    assertEq(s_operatorStakingPool.getStakerStakedAtTime(OPERATOR_STAKER_ONE), stakedAtTimeBefore);
  }

  function test_StakingUpdatesTheCheckpointId() public {
    uint256 prevCheckpointId = s_communityStakingPool.getCurrentCheckpointId();
    changePrank(OPERATOR_STAKER_ONE);
    s_LINK.transferAndCall(
      address(s_operatorStakingPool), OPERATOR_MIN_PRINCIPAL, abi.encode(s_communityStakerOneProof)
    );
    assertEq(s_operatorStakingPool.getCurrentCheckpointId(), prevCheckpointId + 1);
  }

  function test_RevertWhen_MigrationProxyNotSet() public {
    // deploy a new OperatorStakingPool
    OperatorStakingPool operatorStakingPool = new OperatorStakingPool(
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

    changePrank(OPERATOR_STAKER_ONE);

    vm.expectRevert(IStakingPool.MigrationProxyNotSet.selector);
    s_LINK.transferAndCall(address(operatorStakingPool), OPERATOR_MIN_PRINCIPAL, '');
  }

  function test_RevertWhen_OnTokenTransferDataIsEmptyFromMigrationProxy() public {
    changePrank(address(s_migrationProxy));

    vm.expectRevert(IStakingPool.InvalidData.selector);
    s_LINK.transferAndCall(address(s_operatorStakingPool), OPERATOR_MIN_PRINCIPAL, '');
  }

  function test_StakingThroughMigrationProxyUpdatesPoolStateTotalPrincipal() public {
    // define staker data
    bytes memory stakerData = abi.encode(OPERATOR_MIN_PRINCIPAL, 0);
    // define migration proxy data
    bytes memory migrationProxyData = abi.encode(OPERATOR_STAKER_ONE, stakerData);

    changePrank(address(s_migrationProxy));

    uint256 totalPrincipalBefore = s_operatorStakingPool.getTotalPrincipal();

    s_LINK.transferAndCall(
      address(s_operatorStakingPool), OPERATOR_MIN_PRINCIPAL, migrationProxyData
    );
    assertEq(
      s_operatorStakingPool.getTotalPrincipal(), totalPrincipalBefore + OPERATOR_MIN_PRINCIPAL
    );
  }

  function test_StakingThroughMigrationProxyUpdatesStakerState() public {
    // define staker data
    bytes memory stakerData = abi.encode(OPERATOR_MIN_PRINCIPAL, OPERATOR_MIN_PRINCIPAL);
    // define migration proxy data
    bytes memory migrationProxyData = abi.encode(OPERATOR_STAKER_ONE, stakerData);

    changePrank(address(s_migrationProxy));

    uint256 stakerPrincipalBefore = s_operatorStakingPool.getStakerPrincipal(OPERATOR_STAKER_ONE);
    s_LINK.transferAndCall(
      address(s_operatorStakingPool), OPERATOR_MIN_PRINCIPAL, migrationProxyData
    );
    assertEq(
      s_operatorStakingPool.getStakerPrincipal(OPERATOR_STAKER_ONE),
      stakerPrincipalBefore + OPERATOR_MIN_PRINCIPAL
    );
    assertEq(s_operatorStakingPool.getStakerStakedAtTime(OPERATOR_STAKER_ONE), block.timestamp);
  }

  function test_RevertWhen_StakerIsNotOperator() public {
    changePrank(COMMUNITY_STAKER_ONE);

    vm.expectRevert(OperatorStakingPool.StakerNotOperator.selector);
    s_LINK.transferAndCall(
      address(s_operatorStakingPool), OPERATOR_MIN_PRINCIPAL, abi.encode(COMMUNITY_STAKER_ONE, '')
    );
  }

  function test_StakingUpdatesTheStakerTypeInRewardVault() public {
    IRewardVault.StakerReward memory stakerReward =
      s_rewardVault.getStoredReward(OPERATOR_STAKER_THREE);
    assertEq(uint256(stakerReward.stakerType), uint256(IRewardVault.StakerType.NOT_STAKED));
    changePrank(OPERATOR_STAKER_THREE);
    s_LINK.transferAndCall(address(s_operatorStakingPool), OPERATOR_MIN_PRINCIPAL, '');
    stakerReward = s_rewardVault.getStoredReward(OPERATOR_STAKER_THREE);
    assertEq(uint256(stakerReward.stakerType), uint256(IRewardVault.StakerType.OPERATOR));
  }

  function test_RestakingDoesNotUpdateTheStakerTypeInRewardVault() public {
    changePrank(OPERATOR_STAKER_THREE);
    s_LINK.transferAndCall(address(s_operatorStakingPool), OPERATOR_MIN_PRINCIPAL, '');
    IRewardVault.StakerReward memory stakerReward =
      s_rewardVault.getStoredReward(OPERATOR_STAKER_THREE);
    assertEq(uint256(stakerReward.stakerType), uint256(IRewardVault.StakerType.OPERATOR));
    s_LINK.transferAndCall(address(s_operatorStakingPool), OPERATOR_MIN_PRINCIPAL, '');
    stakerReward = s_rewardVault.getStoredReward(OPERATOR_STAKER_THREE);
    assertEq(uint256(stakerReward.stakerType), uint256(IRewardVault.StakerType.OPERATOR));
  }

  function test_RemovingAsOperatorDoesNotUpdateTheStakerTypeInRewardVault() public {
    changePrank(OPERATOR_STAKER_THREE);
    s_LINK.transferAndCall(address(s_operatorStakingPool), OPERATOR_MIN_PRINCIPAL, '');
    IRewardVault.StakerReward memory stakerReward =
      s_rewardVault.getStoredReward(OPERATOR_STAKER_THREE);
    assertEq(uint256(stakerReward.stakerType), uint256(IRewardVault.StakerType.OPERATOR));

    changePrank(OWNER);
    address[] memory operatorToRemove = new address[](1);
    operatorToRemove[0] = OPERATOR_STAKER_THREE;
    s_operatorStakingPool.removeOperators(operatorToRemove);

    stakerReward = s_rewardVault.getStoredReward(OPERATOR_STAKER_THREE);
    assertEq(uint256(stakerReward.stakerType), uint256(IRewardVault.StakerType.OPERATOR));
  }
}

contract OperatorStakingPool_OnTokenTransfer_WhenThereAreOtherStakers is
  IStakingPool_OnTokenTransfer_WhenThereOtherStakers,
  StakingPool_WithStakers
{
  uint256 private s_currentCheckpointId;

  function setUp() public override {
    StakingPool_WithStakers.setUp();
    s_currentCheckpointId = s_operatorStakingPool.getCurrentCheckpointId();
  }

  function test_StakingMultipleTimesTracksPreviousBalance() public {
    changePrank(OPERATOR_STAKER_ONE);
    s_LINK.transferAndCall(address(s_operatorStakingPool), OPERATOR_MIN_PRINCIPAL, abi.encode(''));

    assertEq(
      s_operatorStakingPool.getStakerPrincipalAt(OPERATOR_STAKER_ONE, s_currentCheckpointId - 1),
      OPERATOR_MIN_PRINCIPAL
    );
  }

  function test_StakingMultipleTimesTracksPreviousAverageStakedAtTime() public {
    uint256 stakedAtTimeBefore = s_operatorStakingPool.getStakerStakedAtTime(OPERATOR_STAKER_ONE);
    changePrank(OPERATOR_STAKER_ONE);
    s_LINK.transferAndCall(address(s_operatorStakingPool), OPERATOR_MIN_PRINCIPAL, abi.encode(''));

    assertEq(
      s_operatorStakingPool.getStakerStakedAtTimeAt(OPERATOR_STAKER_ONE, s_currentCheckpointId - 1),
      stakedAtTimeBefore
    );
  }

  function test_StakingUpdatesTheLatestBalance() public {
    changePrank(OPERATOR_STAKER_ONE);
    s_LINK.transferAndCall(address(s_operatorStakingPool), OPERATOR_MIN_PRINCIPAL, abi.encode(''));

    assertEq(
      s_operatorStakingPool.getStakerPrincipal(OPERATOR_STAKER_ONE), 2 * OPERATOR_MIN_PRINCIPAL
    );
  }

  function test_StakingDoesNotAffectOtherStakersHistoricalBalance() public {
    changePrank(OPERATOR_STAKER_TWO);
    s_LINK.transferAndCall(address(s_operatorStakingPool), OPERATOR_MIN_PRINCIPAL, abi.encode(''));

    assertEq(
      s_operatorStakingPool.getStakerPrincipalAt(OPERATOR_STAKER_ONE, s_currentCheckpointId - 1),
      OPERATOR_MIN_PRINCIPAL
    );
  }

  function test_StakingDoesNotAffectOtherStakersAverageStakedAtTime() public {
    uint256 stakedAtTimeBefore = s_operatorStakingPool.getStakerStakedAtTime(OPERATOR_STAKER_ONE);
    changePrank(OPERATOR_STAKER_TWO);
    s_LINK.transferAndCall(address(s_operatorStakingPool), OPERATOR_MIN_PRINCIPAL, abi.encode(''));

    assertEq(
      s_operatorStakingPool.getStakerStakedAtTimeAt(OPERATOR_STAKER_ONE, s_currentCheckpointId - 1),
      stakedAtTimeBefore
    );
  }
}

contract OperatorStakingPool_OnTokenTransfer_WhenRewardVaultNotActive is StakingPool_WithStakers {
  function test_RevertWhen_RewardVaultHasBeenClosed() public {
    changePrank(OWNER);
    s_rewardVault.close();

    changePrank(OPERATOR_STAKER_ONE);
    vm.expectRevert(StakingPoolBase.RewardVaultNotActive.selector);
    s_LINK.transferAndCall(
      address(s_operatorStakingPool), OPERATOR_MIN_PRINCIPAL, abi.encode(OPERATOR_STAKER_ONE, '')
    );
  }
}

contract OperatorStakingPool_OnTokenTransfer_WhenStakeIsUnbonding is
  IStakingPool_OnTokenTransfer_WhenStakeIsUnbonding,
  StakingPool_InUnbondingPeriod
{
  event UnbondingPeriodReset(address indexed staker);

  function test_ResetsUnbondingPeriod() external {
    assertGt(s_operatorStakingPool.getUnbondingEndsAt(OPERATOR_STAKER_ONE), 0);
    changePrank(OPERATOR_STAKER_ONE);
    s_LINK.transferAndCall(address(s_operatorStakingPool), OPERATOR_MIN_PRINCIPAL, '');
    assertEq(s_operatorStakingPool.getUnbondingEndsAt(OPERATOR_STAKER_ONE), 0);
  }

  function test_EmitsCorrectEvent() external {
    vm.expectEmit(true, true, true, true, address(s_operatorStakingPool));
    emit UnbondingPeriodReset(OPERATOR_STAKER_ONE);
    changePrank(OPERATOR_STAKER_ONE);
    s_LINK.transferAndCall(address(s_operatorStakingPool), OPERATOR_MIN_PRINCIPAL, '');
  }
}

contract OperatorStakingPool_Unstake is
  IStakingPool_Unstake,
  IStakingPool_Unstake_WhenPoolClosed,
  StakingPool_InClaimPeriod
{
  event RewardClaimed(address indexed staker, uint256 claimedRewards);

  function test_RevertWhen_UnstakeAmountIsZero() public {
    changePrank(OPERATOR_STAKER_ONE);
    vm.expectRevert(IStakingPool.UnstakeZeroAmount.selector);
    s_operatorStakingPool.unstake(0, false);
  }

  function test_RevertWhen_UnstakeAmountIsGreaterThanPrincipal() public {
    changePrank(OPERATOR_STAKER_ONE);
    vm.expectRevert(IStakingPool.UnstakeExceedsPrincipal.selector);
    s_operatorStakingPool.unstake(OPERATOR_MIN_PRINCIPAL + 1, false);
  }

  function test_RevertWhen_UnstakeAmountLeavesStakerWithLessThanMinPrincipal() public {
    uint256 unstakeAmount =
      s_operatorStakingPool.getStakerPrincipal(OPERATOR_STAKER_TWO) - OPERATOR_MIN_PRINCIPAL + 1;
    changePrank(OPERATOR_STAKER_TWO);
    vm.expectRevert(IStakingPool.UnstakePrincipalBelowMinAmount.selector);
    s_operatorStakingPool.unstake(unstakeAmount, false);
  }

  function test_CorrectlyUpdatesPoolStateTotalPrincipal() public {
    uint256 totalPrincipalBefore = s_operatorStakingPool.getTotalPrincipal();
    changePrank(OPERATOR_STAKER_ONE);
    s_operatorStakingPool.unstake(OPERATOR_MIN_PRINCIPAL, false);
    assertEq(
      s_operatorStakingPool.getTotalPrincipal(), totalPrincipalBefore - OPERATOR_MIN_PRINCIPAL
    );
  }

  function test_CorrectlyUpdatesStakerStatePrincipal() public {
    uint256 stakerPrincipalBefore = s_operatorStakingPool.getStakerPrincipal(OPERATOR_STAKER_ONE);
    changePrank(OPERATOR_STAKER_ONE);
    s_operatorStakingPool.unstake(OPERATOR_MIN_PRINCIPAL, false);
    assertEq(
      s_operatorStakingPool.getStakerPrincipal(OPERATOR_STAKER_ONE),
      stakerPrincipalBefore - OPERATOR_MIN_PRINCIPAL
    );
  }

  function test_CorrectlyTransferTokensToStaker() public {
    uint256 stakerBalanceBefore = s_LINK.balanceOf(OPERATOR_STAKER_ONE);
    changePrank(OPERATOR_STAKER_ONE);
    s_operatorStakingPool.unstake(OPERATOR_MIN_PRINCIPAL, false);
    assertEq(s_LINK.balanceOf(OPERATOR_STAKER_ONE), stakerBalanceBefore + OPERATOR_MIN_PRINCIPAL);
  }

  function test_AllowsMultipleUnstakesInClaimPeriod() public {
    uint256 initialPrincipal = s_operatorStakingPool.getStakerPrincipal(OPERATOR_STAKER_TWO);
    changePrank(OPERATOR_STAKER_TWO);
    s_operatorStakingPool.unstake(OPERATOR_MIN_PRINCIPAL, false);
    s_operatorStakingPool.unstake(OPERATOR_MIN_PRINCIPAL, false);
    assertEq(
      s_operatorStakingPool.getStakerPrincipal(OPERATOR_STAKER_TWO),
      initialPrincipal - OPERATOR_MIN_PRINCIPAL * 2
    );
  }

  function test_EmitsEvent() public {
    vm.expectEmit(true, true, true, true, address(s_operatorStakingPool));
    emit Unstaked(OPERATOR_STAKER_ONE, OPERATOR_MIN_PRINCIPAL, 0);
    changePrank(OPERATOR_STAKER_ONE);
    s_operatorStakingPool.unstake(OPERATOR_MIN_PRINCIPAL, false);
  }

  function test_ClaimsRewardsIfShouldClaimRewardSetToTrue() public {
    uint256 initialBalance = s_LINK.balanceOf(OPERATOR_STAKER_ONE);
    uint256 reward = s_rewardVault.getReward(OPERATOR_STAKER_ONE);

    changePrank(OPERATOR_STAKER_ONE);

    vm.expectEmit(true, true, true, true, address(s_rewardVault));
    emit RewardClaimed(OPERATOR_STAKER_ONE, reward);

    s_operatorStakingPool.unstake(OPERATOR_MIN_PRINCIPAL, true);
    assertEq(
      s_LINK.balanceOf(OPERATOR_STAKER_ONE), initialBalance + OPERATOR_MIN_PRINCIPAL + reward
    );
    assertEq(s_rewardVault.getStoredReward(OPERATOR_STAKER_ONE).storedBaseReward, 0);
  }

  function test_DoesNotClaimRewardIfShouldClaimRewardSetToTrueButNoRewardAccrued() public {
    changePrank(OPERATOR_STAKER_TWO);

    uint256 principal = s_operatorStakingPool.getStakerPrincipal(OPERATOR_STAKER_TWO);
    (uint256 minPrincipal,) = s_operatorStakingPool.getStakerLimits();
    s_operatorStakingPool.unstake(principal - minPrincipal, true);

    assertEq(s_rewardVault.getReward(OPERATOR_STAKER_TWO), 0);

    vm.expectRevert(RewardVault.NoRewardToClaim.selector);
    s_operatorStakingPool.unstake(minPrincipal, true);
  }

  function test_CanUnstakeIfPoolClosed() public {
    changePrank(OWNER);

    s_operatorStakingPool.close();

    changePrank(OPERATOR_STAKER_ONE);

    vm.expectEmit(true, true, true, true, address(s_operatorStakingPool));
    emit Unstaked(OPERATOR_STAKER_ONE, OPERATOR_MIN_PRINCIPAL, 0);
    s_operatorStakingPool.unstake(OPERATOR_MIN_PRINCIPAL, false);
  }

  function test_CorrectlyIncrementsTheCheckpointId() public {
    uint256 prevCheckpointId = s_operatorStakingPool.getCurrentCheckpointId();
    changePrank(OPERATOR_STAKER_ONE);
    s_operatorStakingPool.unstake(OPERATOR_MIN_PRINCIPAL, false);
    assertEq(s_operatorStakingPool.getCurrentCheckpointId(), prevCheckpointId + 1);
  }
}

contract OperatorStakingPool_Unstake_WhenThereAreMoreThanTwoStakers is
  StakingPool_InClaimPeriod,
  IStakingPool_Unstake_WhenMoreThanTwoStakers
{
  uint256 private constant TIME_AFTER_THIRD_STAKER_STAKES = 5 days;
  uint256 private s_timeThirdStakerStakes;

  function setUp() public override {
    StakingPool_InClaimPeriod.setUp();

    changePrank(OPERATOR_STAKER_THREE);
    s_LINK.transferAndCall(
      address(s_operatorStakingPool), OPERATOR_MIN_PRINCIPAL * 2, abi.encode('')
    );
    s_timeThirdStakerStakes = block.timestamp;
    skip(TIME_AFTER_THIRD_STAKER_STAKES);
  }

  function test_DistributesCorrectAmountToFirstStakerIfFullyUnstaking() public {
    changePrank(OPERATOR_STAKER_TWO);
    s_operatorStakingPool.unstake(OPERATOR_MIN_PRINCIPAL * 3, false);

    uint256 multiplier =
      _calculateStakerMultiplier(s_stakedAtTime, block.timestamp, INITIAL_MULTIPLIER_DURATION);

    // Calculate amount of forfeited rewards
    uint256 unstakingStakerFullReward = _calculateStakerExpectedReward(
      3 * OPERATOR_MIN_PRINCIPAL,
      4 * OPERATOR_MIN_PRINCIPAL,
      _calculateBucketVestedRewards(
        s_rewardVault.getRewardBuckets().operatorBase, s_stakedAtTime, s_timeThirdStakerStakes
      )
    )
      + _calculateStakerExpectedReward(
        3 * OPERATOR_MIN_PRINCIPAL,
        6 * OPERATOR_MIN_PRINCIPAL,
        _calculateBucketVestedRewards(
          s_rewardVault.getRewardBuckets().operatorBase, s_timeThirdStakerStakes, block.timestamp
        )
      );
    uint256 forfeitedRewards =
      unstakingStakerFullReward - (multiplier * unstakingStakerFullReward) / FixedPointMathLib.WAD;
    uint256 remainingStakerPrincipal = OPERATOR_MIN_PRINCIPAL;
    uint256 totalPrincipal = OPERATOR_MIN_PRINCIPAL * 3;
    uint256 forfeitedRewardsPerToken =
      FixedPointMathLib.divWadDown(forfeitedRewards, totalPrincipal);

    uint256 rewardsForfeitedToRemainingStaker =
      FixedPointMathLib.mulWadDown(forfeitedRewardsPerToken, remainingStakerPrincipal);

    uint256 remainingStakerFullRewards = _calculateStakerExpectedReward(
      OPERATOR_MIN_PRINCIPAL,
      4 * OPERATOR_MIN_PRINCIPAL,
      _calculateBucketVestedRewards(
        s_rewardVault.getRewardBuckets().operatorBase, s_stakedAtTime, s_timeThirdStakerStakes
      )
    )
      + _calculateStakerExpectedReward(
        OPERATOR_MIN_PRINCIPAL,
        6 * OPERATOR_MIN_PRINCIPAL,
        _calculateBucketVestedRewards(
          s_rewardVault.getRewardBuckets().operatorBase, s_timeThirdStakerStakes, block.timestamp
        )
      );
    uint256 remainingStakerDelegatedRewards = _calculateStakerExpectedReward(
      OPERATOR_MIN_PRINCIPAL,
      4 * OPERATOR_MIN_PRINCIPAL,
      _calculateBucketVestedRewards(
        s_rewardVault.getRewardBuckets().operatorDelegated, s_stakedAtTime, s_timeThirdStakerStakes
      )
    )
      + _calculateStakerExpectedReward(
        OPERATOR_MIN_PRINCIPAL,
        6 * OPERATOR_MIN_PRINCIPAL,
        _calculateBucketVestedRewards(
          s_rewardVault.getRewardBuckets().operatorDelegated, s_timeThirdStakerStakes, block.timestamp
        )
      );

    assertEq(
      s_rewardVault.getReward(OPERATOR_STAKER_ONE),
      remainingStakerDelegatedRewards
        + ((remainingStakerFullRewards + rewardsForfeitedToRemainingStaker) * multiplier)
          / FixedPointMathLib.WAD
    );
  }

  function test_DistributesCorrectAmountToSecondStakerIfFullyUnstaking() public {
    changePrank(OPERATOR_STAKER_TWO);
    s_operatorStakingPool.unstake(OPERATOR_MIN_PRINCIPAL * 3, false);

    uint256 multiplier =
      _calculateStakerMultiplier(s_stakedAtTime, block.timestamp, INITIAL_MULTIPLIER_DURATION);

    // Calculate amount of forfeited rewards
    uint256 unstakingStakerFullReward = _calculateStakerExpectedReward(
      3 * OPERATOR_MIN_PRINCIPAL,
      4 * OPERATOR_MIN_PRINCIPAL,
      _calculateBucketVestedRewards(
        s_rewardVault.getRewardBuckets().operatorBase, s_stakedAtTime, s_timeThirdStakerStakes
      )
    )
      + _calculateStakerExpectedReward(
        3 * OPERATOR_MIN_PRINCIPAL,
        6 * OPERATOR_MIN_PRINCIPAL,
        _calculateBucketVestedRewards(
          s_rewardVault.getRewardBuckets().operatorBase, s_timeThirdStakerStakes, block.timestamp
        )
      );
    uint256 forfeitedRewards =
      unstakingStakerFullReward - (multiplier * unstakingStakerFullReward) / FixedPointMathLib.WAD;
    uint256 remainingStakerPrincipal = OPERATOR_MIN_PRINCIPAL * 2;
    // Total remaining staked LINK amount from the remaining 2 stakers plus
    // the remainder of the unstaking staker's staked LINK amount
    uint256 totalPrincipal = 3 * OPERATOR_MIN_PRINCIPAL;
    uint256 forfeitedRewardsPerToken =
      FixedPointMathLib.divWadDown(forfeitedRewards, totalPrincipal);

    uint256 rewardsForfeitedToRemainingStaker =
      FixedPointMathLib.mulWadDown(forfeitedRewardsPerToken, remainingStakerPrincipal);

    uint256 remainingStakerMultiplier = _calculateStakerMultiplier(
      s_timeThirdStakerStakes, block.timestamp, INITIAL_MULTIPLIER_DURATION
    );

    uint256 remainingStakerFullReward = _calculateStakerExpectedReward(
      2 * OPERATOR_MIN_PRINCIPAL,
      6 * OPERATOR_MIN_PRINCIPAL,
      _calculateBucketVestedRewards(
        s_rewardVault.getRewardBuckets().operatorBase, s_timeThirdStakerStakes, block.timestamp
      )
    );
    uint256 remainingStakerDelegatedReward = _calculateStakerExpectedReward(
      2 * OPERATOR_MIN_PRINCIPAL,
      6 * OPERATOR_MIN_PRINCIPAL,
      _calculateBucketVestedRewards(
        s_rewardVault.getRewardBuckets().operatorDelegated, s_timeThirdStakerStakes, block.timestamp
      )
    );
    assertEq(
      s_rewardVault.getReward(OPERATOR_STAKER_THREE),
      remainingStakerDelegatedReward
        + (
          (remainingStakerFullReward + rewardsForfeitedToRemainingStaker) * remainingStakerMultiplier
        ) / FixedPointMathLib.WAD
    );
  }

  function test_DistributesCorrectAmountToFirstStakerIfPartiallyUnstaking() public {
    changePrank(OPERATOR_STAKER_TWO);
    uint256 stakerPrincipalBefore = OPERATOR_MIN_PRINCIPAL * 3;
    uint256 unstakeAmount = OPERATOR_MIN_PRINCIPAL / 2;
    s_operatorStakingPool.unstake(unstakeAmount, false);

    uint256 multiplier =
      _calculateStakerMultiplier(s_stakedAtTime, block.timestamp, INITIAL_MULTIPLIER_DURATION);

    // Calculate amount of forfeited rewards
    uint256 stakerFullRewards = _calculateStakerExpectedReward(
      3 * OPERATOR_MIN_PRINCIPAL,
      4 * OPERATOR_MIN_PRINCIPAL,
      _calculateBucketVestedRewards(
        s_rewardVault.getRewardBuckets().operatorBase, s_stakedAtTime, s_timeThirdStakerStakes
      )
    )
      + _calculateStakerExpectedReward(
        3 * OPERATOR_MIN_PRINCIPAL,
        6 * OPERATOR_MIN_PRINCIPAL,
        _calculateBucketVestedRewards(
          s_rewardVault.getRewardBuckets().operatorBase, s_timeThirdStakerStakes, block.timestamp
        )
      );
    uint256 unclaimableAmount =
      stakerFullRewards - (multiplier * stakerFullRewards) / FixedPointMathLib.WAD;
    uint256 forfeitedRewardAmount = (unclaimableAmount * unstakeAmount) / stakerPrincipalBefore;

    uint256 remainingStakerPrincipal = OPERATOR_MIN_PRINCIPAL;

    // Total remaining staked LINK amount from the remaining 2 stakers plus
    // the remainder of the unstaking staker's staked LINK amount
    uint256 totalPrincipal = 3 * OPERATOR_MIN_PRINCIPAL;
    uint256 forfeitedRewardsPerToken =
      FixedPointMathLib.divWadDown(forfeitedRewardAmount, totalPrincipal);

    uint256 rewardsForfeitedToRemainingStaker =
      FixedPointMathLib.mulWadDown(forfeitedRewardsPerToken, remainingStakerPrincipal);

    uint256 remainingStakerFullRewards = _calculateStakerExpectedReward(
      OPERATOR_MIN_PRINCIPAL,
      4 * OPERATOR_MIN_PRINCIPAL,
      _calculateBucketVestedRewards(
        s_rewardVault.getRewardBuckets().operatorBase, s_stakedAtTime, s_timeThirdStakerStakes
      )
    )
      + _calculateStakerExpectedReward(
        OPERATOR_MIN_PRINCIPAL,
        6 * OPERATOR_MIN_PRINCIPAL,
        _calculateBucketVestedRewards(
          s_rewardVault.getRewardBuckets().operatorBase, s_timeThirdStakerStakes, block.timestamp
        )
      );
    uint256 remainingStakerDelegatedRewards = _calculateStakerExpectedReward(
      OPERATOR_MIN_PRINCIPAL,
      4 * OPERATOR_MIN_PRINCIPAL,
      _calculateBucketVestedRewards(
        s_rewardVault.getRewardBuckets().operatorDelegated, s_stakedAtTime, s_timeThirdStakerStakes
      )
    )
      + _calculateStakerExpectedReward(
        OPERATOR_MIN_PRINCIPAL,
        6 * OPERATOR_MIN_PRINCIPAL,
        _calculateBucketVestedRewards(
          s_rewardVault.getRewardBuckets().operatorDelegated, s_timeThirdStakerStakes, block.timestamp
        )
      );

    assertEq(
      s_rewardVault.getReward(OPERATOR_STAKER_ONE),
      remainingStakerDelegatedRewards
        + ((remainingStakerFullRewards + rewardsForfeitedToRemainingStaker) * multiplier)
          / FixedPointMathLib.WAD
    );
  }

  function test_DistributesCorrectAmountToSecondStakerIfPartiallyUnstaking() public {
    changePrank(OPERATOR_STAKER_TWO);
    uint256 stakerPrincipalBefore = OPERATOR_MIN_PRINCIPAL * 3;
    uint256 unstakeAmount = OPERATOR_MIN_PRINCIPAL / 2;
    s_operatorStakingPool.unstake(unstakeAmount, false);

    uint256 multiplier =
      _calculateStakerMultiplier(s_stakedAtTime, block.timestamp, INITIAL_MULTIPLIER_DURATION);

    // Calculate amount of forfeited rewards
    uint256 unstakingStakerFullReward = _calculateStakerExpectedReward(
      3 * OPERATOR_MIN_PRINCIPAL,
      4 * OPERATOR_MIN_PRINCIPAL,
      _calculateBucketVestedRewards(
        s_rewardVault.getRewardBuckets().operatorBase, s_stakedAtTime, s_timeThirdStakerStakes
      )
    )
      + _calculateStakerExpectedReward(
        3 * OPERATOR_MIN_PRINCIPAL,
        6 * OPERATOR_MIN_PRINCIPAL,
        _calculateBucketVestedRewards(
          s_rewardVault.getRewardBuckets().operatorBase, s_timeThirdStakerStakes, block.timestamp
        )
      );
    uint256 unclaimableAmount =
      unstakingStakerFullReward - (multiplier * unstakingStakerFullReward) / FixedPointMathLib.WAD;
    uint256 forfeitedRewardAmount = (unclaimableAmount * unstakeAmount) / stakerPrincipalBefore;

    uint256 remainingStakerPrincipal = OPERATOR_MIN_PRINCIPAL * 2;
    uint256 totalRemainingStakersPrincipal = 3 * OPERATOR_MIN_PRINCIPAL;
    uint256 forfeitedRewardsPerToken =
      FixedPointMathLib.divWadDown(forfeitedRewardAmount, totalRemainingStakersPrincipal);

    uint256 rewardsForfeitedToRemainingStaker =
      FixedPointMathLib.mulWadDown(forfeitedRewardsPerToken, remainingStakerPrincipal);

    uint256 remainingStakerMultiplier = _calculateStakerMultiplier(
      s_timeThirdStakerStakes, block.timestamp, INITIAL_MULTIPLIER_DURATION
    );

    uint256 remainingStakerFullReward = _calculateStakerExpectedReward(
      2 * OPERATOR_MIN_PRINCIPAL,
      6 * OPERATOR_MIN_PRINCIPAL,
      _calculateBucketVestedRewards(
        s_rewardVault.getRewardBuckets().operatorBase, s_timeThirdStakerStakes, block.timestamp
      )
    );
    uint256 remainingStakerDelegatedReward = _calculateStakerExpectedReward(
      2 * OPERATOR_MIN_PRINCIPAL,
      6 * OPERATOR_MIN_PRINCIPAL,
      _calculateBucketVestedRewards(
        s_rewardVault.getRewardBuckets().operatorDelegated, s_timeThirdStakerStakes, block.timestamp
      )
    );
    assertEq(
      s_rewardVault.getReward(OPERATOR_STAKER_THREE),
      remainingStakerDelegatedReward
        + (
          (remainingStakerFullReward + rewardsForfeitedToRemainingStaker) * remainingStakerMultiplier
        ) / FixedPointMathLib.WAD
    );
  }
}

contract OperatorStakingPool_Unstake_WhenUnbondingNotStarted is
  IStakingPool_Unstake_WhenUnbondingNotStarted,
  IStakingPool_Unstake_WhenPoolClosed,
  StakingPool_WithStakers
{
  function test_RevertWhen_StakerTriesToUnstake() external override {
    vm.expectRevert(
      abi.encodeWithSelector(StakingPoolBase.StakerNotInClaimPeriod.selector, OPERATOR_STAKER_ONE)
    );
    changePrank(OPERATOR_STAKER_ONE);
    s_operatorStakingPool.unstake(OPERATOR_MIN_PRINCIPAL, true);
  }

  function test_CanUnstakeIfPoolClosed() public {
    changePrank(OWNER);

    s_operatorStakingPool.close();

    changePrank(OPERATOR_STAKER_ONE);

    vm.expectEmit(true, true, true, true, address(s_operatorStakingPool));
    emit Unstaked(OPERATOR_STAKER_ONE, OPERATOR_MIN_PRINCIPAL, 0);
    s_operatorStakingPool.unstake(OPERATOR_MIN_PRINCIPAL, false);
  }
}

contract OperatorStakingPool_Unstake_WhenLastStakerUnstakesAndClaims is
  IStakingPool_Unstake_WhenLastStakerUnstakesAndClaims,
  StakingPool_InClaimPeriod
{
  function setUp() public override {
    StakingPool_InClaimPeriod.setUp();

    changePrank(OPERATOR_STAKER_ONE);
    s_operatorStakingPool.unstake(OPERATOR_MIN_PRINCIPAL, false);
  }

  function test_DoesNotForfeitRewards() external {
    uint256 operatorTwoPrincipal = OPERATOR_MIN_PRINCIPAL * 3;

    uint256 operatorLINKBalanceBefore = s_LINK.balanceOf(OPERATOR_STAKER_TWO);

    uint256 multiplier =
      _calculateStakerMultiplier(s_stakedAtTime, block.timestamp, INITIAL_MULTIPLIER_DURATION);

    uint256 operatorOneFullRewards = _calculateStakerExpectedReward(
      OPERATOR_MIN_PRINCIPAL,
      4 * OPERATOR_MIN_PRINCIPAL,
      _calculateBucketVestedRewards(
        s_rewardVault.getRewardBuckets().operatorBase, s_stakedAtTime, block.timestamp
      )
    );

    uint256 operatorOneForfeitedRewards =
      operatorOneFullRewards - (multiplier * operatorOneFullRewards) / FixedPointMathLib.WAD;

    uint256 operatorOneForfeitedRewardsPerToken =
      FixedPointMathLib.divWadDown(operatorOneForfeitedRewards, operatorTwoPrincipal);

    // Calculate amount of forfeited rewards
    uint256 operatorTwoBaseRewards = _calculateStakerExpectedReward(
      3 * OPERATOR_MIN_PRINCIPAL,
      4 * OPERATOR_MIN_PRINCIPAL,
      _calculateBucketVestedRewards(
        s_rewardVault.getRewardBuckets().operatorBase, s_stakedAtTime, block.timestamp
      )
    );

    uint256 operatorTwoDelegatedRewards = _calculateStakerExpectedReward(
      3 * OPERATOR_MIN_PRINCIPAL,
      4 * OPERATOR_MIN_PRINCIPAL,
      _calculateBucketVestedRewards(
        s_rewardVault.getRewardBuckets().operatorDelegated, s_stakedAtTime, block.timestamp
      )
    );

    uint256 expectedReward = FixedPointMathLib.mulWadDown(
      operatorOneForfeitedRewardsPerToken, operatorTwoPrincipal
    ) + operatorTwoBaseRewards + operatorTwoDelegatedRewards;

    changePrank(OPERATOR_STAKER_TWO);
    s_operatorStakingPool.unstake(operatorTwoPrincipal, true);

    assertEq(
      s_LINK.balanceOf(OPERATOR_STAKER_TWO),
      operatorLINKBalanceBefore + expectedReward + operatorTwoPrincipal
    );
  }
}

contract OperatorStakingPool_Unstake_WhileUnbonding is
  IStakingPool_Unstake_WhileUnbonding,
  IStakingPool_Unstake_WhenPoolClosed,
  StakingPool_InUnbondingPeriod
{
  function test_RevertWhen_StakerTriesToUnstake() external {
    vm.expectRevert(
      abi.encodeWithSelector(StakingPoolBase.StakerNotInClaimPeriod.selector, OPERATOR_STAKER_ONE)
    );
    changePrank(OPERATOR_STAKER_ONE);
    s_operatorStakingPool.unstake(OPERATOR_MIN_PRINCIPAL, true);
  }

  function test_CanUnstakeIfPoolClosed() public {
    changePrank(OWNER);

    s_operatorStakingPool.close();

    changePrank(OPERATOR_STAKER_ONE);

    vm.expectEmit(true, true, true, true, address(s_operatorStakingPool));
    emit Unstaked(OPERATOR_STAKER_ONE, OPERATOR_MIN_PRINCIPAL, 0);
    s_operatorStakingPool.unstake(OPERATOR_MIN_PRINCIPAL, false);
  }
}

contract OperatorStakingPool_Unstake_WhenClaimPeriodEndsAt is StakingPool_WhenClaimPeriodEndsAt {
  function test_CanUnstakeAtClaimPeriodEndsAt() public {
    changePrank(OPERATOR_STAKER_ONE);
    vm.expectEmit(true, true, true, true, address(s_operatorStakingPool));
    emit Unstaked(OPERATOR_STAKER_ONE, OPERATOR_MIN_PRINCIPAL, 0);
    s_operatorStakingPool.unstake(OPERATOR_MIN_PRINCIPAL, false);
  }
}

contract OperatorStakingPool_Unstake_WhenClaimPeriodFinished is
  IStakingPool_Unstake_WhenClaimPeriodFinished,
  IStakingPool_Unstake_WhenPoolClosed,
  StakingPool_InUnbondingPeriod
{
  function setUp() public override {
    StakingPool_InUnbondingPeriod.setUp();

    uint256 stakerUnbondingEndsAt = s_operatorStakingPool.getUnbondingEndsAt(OPERATOR_STAKER_ONE);

    (, uint256 claimPeriod) = s_operatorStakingPool.getUnbondingParams();
    // Move one day past the claim period
    vm.warp(stakerUnbondingEndsAt + claimPeriod + 1);
  }

  function test_RevertWhen_StakerTriesToUnstake() external {
    vm.expectRevert(
      abi.encodeWithSelector(StakingPoolBase.StakerNotInClaimPeriod.selector, OPERATOR_STAKER_ONE)
    );
    changePrank(OPERATOR_STAKER_ONE);
    s_operatorStakingPool.unstake(OPERATOR_MIN_PRINCIPAL, true);
  }

  function test_CanUnstakeIfPoolClosed() public {
    changePrank(OWNER);

    s_operatorStakingPool.close();

    changePrank(OPERATOR_STAKER_ONE);

    uint256 reward = s_rewardVault.getReward(OPERATOR_STAKER_ONE);
    vm.expectEmit(true, true, true, true, address(s_operatorStakingPool));
    emit Unstaked(OPERATOR_STAKER_ONE, OPERATOR_MIN_PRINCIPAL, reward);
    s_operatorStakingPool.unstake(OPERATOR_MIN_PRINCIPAL, true);
  }
}

contract OperatorStakingPool_Unstake_WhenPaused is
  IStakingPool_Unstake_WhenPaused,
  StakingPool_WhenPaused
{
  function test_CanUnstakeWithoutInitiatingUnbondingPeriod() public {
    changePrank(OPERATOR_STAKER_ONE);
    s_operatorStakingPool.unstake(
      s_operatorStakingPool.getStakerPrincipal(OPERATOR_STAKER_ONE), false
    );
  }

  function test_CanUnstakeAfterInitiatingUnbondingPeriodWithoutWaiting() public {
    changePrank(OPERATOR_STAKER_ONE);
    s_operatorStakingPool.unbond();
    s_operatorStakingPool.unstake(
      s_operatorStakingPool.getStakerPrincipal(OPERATOR_STAKER_ONE), false
    );
  }

  function test_CanUnstakeAfterUnbondingPeriod() public {
    changePrank(OPERATOR_STAKER_ONE);
    s_operatorStakingPool.unbond();

    skip(UNBONDING_PERIOD);

    s_operatorStakingPool.unstake(
      s_operatorStakingPool.getStakerPrincipal(OPERATOR_STAKER_ONE), false
    );
  }

  function test_RevertWhen_UnstakeAfterUnpausingAndBeforeUnbonding() public {
    changePrank(PAUSER);
    s_operatorStakingPool.emergencyUnpause();

    changePrank(OPERATOR_STAKER_ONE);
    uint256 principal = s_operatorStakingPool.getStakerPrincipal(OPERATOR_STAKER_ONE);
    vm.expectRevert(
      abi.encodeWithSelector(StakingPoolBase.StakerNotInClaimPeriod.selector, OPERATOR_STAKER_ONE)
    );
    s_operatorStakingPool.unstake(principal, false);
  }

  function test_RevertWhen_UnstakeWithShouldClaimRewardsTrue() public {
    changePrank(OPERATOR_STAKER_ONE);
    uint256 unstakeAmount = s_operatorStakingPool.getStakerPrincipal(OPERATOR_STAKER_ONE);
    vm.expectRevert(StakingPoolBase.CannotClaimRewardWhenPaused.selector);
    s_operatorStakingPool.unstake(unstakeAmount, true);
  }
}

contract OperatorStakingPool_Unstake_WhenThereAreOtherStakers is
  IStakingPool_Unstake_WhenThereAreOtherStakers,
  StakingPool_InClaimPeriod
{
  uint256 private s_currentCheckpointId;

  function setUp() public override {
    StakingPool_InClaimPeriod.setUp();
    s_currentCheckpointId = s_operatorStakingPool.getCurrentCheckpointId();
  }

  function test_CorrectlyTracksHistoricalBalance() external {
    changePrank(OPERATOR_STAKER_ONE);
    s_operatorStakingPool.unstake(OPERATOR_MIN_PRINCIPAL, true);
    assertEq(
      s_operatorStakingPool.getStakerPrincipalAt(OPERATOR_STAKER_ONE, s_currentCheckpointId - 1),
      OPERATOR_MIN_PRINCIPAL
    );
  }

  function test_DoesNotAffectOtherStakerBalances() external {
    changePrank(OPERATOR_STAKER_TWO);
    s_operatorStakingPool.unstake(OPERATOR_MIN_PRINCIPAL, true);
    assertEq(s_operatorStakingPool.getStakerPrincipal(OPERATOR_STAKER_ONE), OPERATOR_MIN_PRINCIPAL);
  }

  function test_CorrectlyTracksHistoricalAverageStakedAtTime() public {
    uint256 stakedAtTimeBefore = s_operatorStakingPool.getStakerStakedAtTime(OPERATOR_STAKER_ONE);
    changePrank(OPERATOR_STAKER_ONE);
    s_operatorStakingPool.unstake(OPERATOR_MIN_PRINCIPAL, true);
    assertEq(
      s_operatorStakingPool.getStakerStakedAtTimeAt(OPERATOR_STAKER_ONE, s_currentCheckpointId - 1),
      stakedAtTimeBefore
    );
  }

  function test_DoesNotAffectOtherStakerAverageStakedAtTime() public {
    uint256 stakedAtTimeBefore = s_operatorStakingPool.getStakerStakedAtTime(OPERATOR_STAKER_ONE);
    changePrank(OPERATOR_STAKER_TWO);
    s_operatorStakingPool.unstake(OPERATOR_MIN_PRINCIPAL, true);
    assertEq(
      s_operatorStakingPool.getStakerStakedAtTimeAt(OPERATOR_STAKER_ONE, s_currentCheckpointId - 1),
      stakedAtTimeBefore
    );
  }
}

contract OperatorStakingPool_SetUnbondingPeriod_WhenPoolOpenedAndStakersAreUnbonding is
  IStakingPool_SetUnbondingPeriod_WhenPoolOpenedAndStakersAreUnbonding,
  StakingPool_InUnbondingPeriod
{
  event UnbondingPeriodSet(uint256 oldUnbondingPeriod, uint256 newUnbondingPeriod);

  function test_RevertWhen_CalledByNonAdmin() external {
    vm.expectRevert(
      _getExpectedMissingRoleErrorMessage(STRANGER, s_operatorStakingPool.DEFAULT_ADMIN_ROLE())
    );
    changePrank(STRANGER);
    s_operatorStakingPool.setUnbondingPeriod(MAX_UNBONDING_PERIOD);
  }

  function test_RevertWhen_UnbondingPeriodIsZero() external {
    vm.expectRevert(StakingPoolBase.InvalidUnbondingPeriod.selector);
    changePrank(OWNER);
    s_operatorStakingPool.setUnbondingPeriod(0);
  }

  function test_RevertWhen_UnbondingPeriodIsGreaterThanMax() external {
    vm.expectRevert(StakingPoolBase.InvalidUnbondingPeriod.selector);
    changePrank(OWNER);
    s_operatorStakingPool.setUnbondingPeriod(MAX_UNBONDING_PERIOD + 1);
  }

  function test_UpdatesUnbondingPeriod() external {
    uint256 newUnbondingPeriod = MAX_UNBONDING_PERIOD;
    changePrank(OWNER);
    s_operatorStakingPool.setUnbondingPeriod(newUnbondingPeriod);
    (uint256 unbondingPeriod,) = s_operatorStakingPool.getUnbondingParams();
    assertEq(unbondingPeriod, newUnbondingPeriod);
  }

  function test_DoesNotAffectStakersThatAreUnbonding() external {
    uint256 newUnbondingPeriod = MAX_UNBONDING_PERIOD;
    uint256 unbondingEndsAt = s_operatorStakingPool.getUnbondingEndsAt(OPERATOR_STAKER_ONE);
    changePrank(OWNER);
    s_operatorStakingPool.setUnbondingPeriod(newUnbondingPeriod);
    assertEq(s_operatorStakingPool.getUnbondingEndsAt(OPERATOR_STAKER_ONE), unbondingEndsAt);
  }

  function test_EmitsEvent() external {
    uint256 newUnbondingPeriod = MAX_UNBONDING_PERIOD;
    (uint256 oldUnbondingPeriod,) = s_operatorStakingPool.getUnbondingParams();
    vm.expectEmit(true, true, true, true, address(s_operatorStakingPool));
    emit UnbondingPeriodSet(oldUnbondingPeriod, newUnbondingPeriod);
    changePrank(OWNER);
    s_operatorStakingPool.setUnbondingPeriod(newUnbondingPeriod);
  }
}

contract OperatorStakingPool_DepositAlerterReward_PoolsHaveNotBeenOpened is BaseTest {
  event AlerterRewardDeposited(uint256 amountFunded, uint256 totalBalance);

  function test_RevertWhen_CalledByNonAdmin() public {
    vm.expectRevert(
      _getExpectedMissingRoleErrorMessage(STRANGER, s_operatorStakingPool.DEFAULT_ADMIN_ROLE())
    );
    changePrank(STRANGER);
    s_operatorStakingPool.depositAlerterReward(1000 ether);
  }

  function test_RevertWhen_AdminTriesToFundAInvalidAlerterRewardFundAmount() public {
    vm.expectRevert(OperatorStakingPool.InvalidAlerterRewardFundAmount.selector);
    changePrank(OWNER);
    s_operatorStakingPool.depositAlerterReward(0);
  }

  function test_AddsFundsToAlertingBucket() public {
    uint256 amountFunded = 1 ether;
    uint256 alertingBucketBefore = s_operatorStakingPool.getAlerterRewardFunds();
    changePrank(OWNER);
    s_LINK.approve(address(s_operatorStakingPool), amountFunded);
    s_operatorStakingPool.depositAlerterReward(amountFunded);
    uint256 alertingBucketAfter = s_operatorStakingPool.getAlerterRewardFunds();
    assertEq(alertingBucketAfter, alertingBucketBefore + amountFunded);
  }

  function test_EmitsEvent() public {
    uint256 amountFunded = 1 ether;
    uint256 alertingBucketBefore = s_operatorStakingPool.getAlerterRewardFunds();
    changePrank(OWNER);
    s_LINK.approve(address(s_operatorStakingPool), amountFunded);
    vm.expectEmit(true, true, true, true, address(s_operatorStakingPool));
    emit AlerterRewardDeposited(amountFunded, alertingBucketBefore + amountFunded);
    s_operatorStakingPool.depositAlerterReward(amountFunded);
  }
}

contract OperatorStakingPool_DepositAlerterReward_PoolsHaveBeenOpened is StakingPool_WithStakers {
  event AlerterRewardDeposited(uint256 amountFunded, uint256 totalBalance);

  function test_RevertWhen_CalledByNonAdmin() public {
    vm.expectRevert(
      _getExpectedMissingRoleErrorMessage(STRANGER, s_operatorStakingPool.DEFAULT_ADMIN_ROLE())
    );
    changePrank(STRANGER);
    s_operatorStakingPool.depositAlerterReward(1000 ether);
  }

  function test_RevertWhen_AdminTriesToFundAInvalidAlerterRewardFundAmount() public {
    vm.expectRevert(OperatorStakingPool.InvalidAlerterRewardFundAmount.selector);
    changePrank(OWNER);
    s_operatorStakingPool.depositAlerterReward(0);
  }

  function test_AddsFundsToAlertingBucket() public {
    uint256 amountFunded = 1 ether;
    uint256 alertingBucketBefore = s_operatorStakingPool.getAlerterRewardFunds();
    changePrank(OWNER);
    s_LINK.approve(address(s_operatorStakingPool), amountFunded);
    s_operatorStakingPool.depositAlerterReward(amountFunded);
    uint256 alertingBucketAfter = s_operatorStakingPool.getAlerterRewardFunds();
    assertEq(alertingBucketAfter, alertingBucketBefore + amountFunded);
  }

  function test_EmitsEvent() public {
    uint256 amountFunded = 1 ether;
    uint256 alertingBucketBefore = s_operatorStakingPool.getAlerterRewardFunds();
    changePrank(OWNER);
    s_LINK.approve(address(s_operatorStakingPool), amountFunded);
    vm.expectEmit(true, true, true, true, address(s_operatorStakingPool));
    emit AlerterRewardDeposited(amountFunded, alertingBucketBefore + amountFunded);
    s_operatorStakingPool.depositAlerterReward(amountFunded);
  }
}

contract OperatorStakingPool_depositAlerterReward_PoolsAreClosed is StakingPool_WhenPoolsAreClosed {
  function test_RevertWhen_OperatorPoolIsClosed() public {
    vm.expectRevert(IStakingOwner.PoolHasBeenClosed.selector);
    changePrank(OWNER);
    s_operatorStakingPool.depositAlerterReward(1000 ether);
  }
}

contract OperatorStakingPool_WithdrawFundsFromAlertsBucket_PoolIsOpened is StakingPool_Opened {
  function test_RevertWhen_PoolIsOpen() public {
    uint256 amountWithdrawn = 1 ether;
    changePrank(OWNER);
    vm.expectRevert(IStakingOwner.PoolNotClosed.selector);
    s_operatorStakingPool.withdrawAlerterReward(amountWithdrawn);
  }
}

contract OperatorStakingPool_WithdrawFundsFromAlertsBucket_PoolIsClosed is
  StakingPool_WhenPoolsAreClosed
{
  function test_CanWithdrawFundsFromTheAlertingBucketAfterClosing() public {
    uint256 amountWithdrawn = 1 ether;
    changePrank(OWNER);
    uint256 alertingBucketBefore = s_operatorStakingPool.getAlerterRewardFunds();
    s_operatorStakingPool.withdrawAlerterReward(amountWithdrawn);
    uint256 alertingBucketAfter = s_operatorStakingPool.getAlerterRewardFunds();
    assertEq(alertingBucketAfter, alertingBucketBefore - amountWithdrawn);
  }
}

contract OperatorStakingPool_WithdrawFundsFromAlertsBucket is BaseTest {
  event AlerterRewardWithdrawn(uint256 amountWithdrawn, uint256 totalBalance);

  function test_RevertWhen_CalledByNonAdmin() public {
    vm.expectRevert(
      _getExpectedMissingRoleErrorMessage(STRANGER, s_operatorStakingPool.DEFAULT_ADMIN_ROLE())
    );
    changePrank(STRANGER);
    s_operatorStakingPool.withdrawAlerterReward(1000 ether);
  }

  function test_RevertWhen_AdminTriesToWithdrawMoreThanBalance() public {
    uint256 amountWithdrawn = 2 * INITIAL_ALERTING_BUCKET_BALANCE;
    vm.expectRevert(
      abi.encodeWithSelector(
        OperatorStakingPool.InsufficientAlerterRewardFunds.selector,
        amountWithdrawn,
        INITIAL_ALERTING_BUCKET_BALANCE
      )
    );
    changePrank(OWNER);
    s_operatorStakingPool.withdrawAlerterReward(amountWithdrawn);
  }

  function test_WithdrawsFundsFromTheAlertingBucket() public {
    uint256 amountWithdrawn = 1 ether;
    uint256 alertingBucketBefore = s_operatorStakingPool.getAlerterRewardFunds();
    changePrank(OWNER);
    s_operatorStakingPool.withdrawAlerterReward(amountWithdrawn);
    uint256 alertingBucketAfter = s_operatorStakingPool.getAlerterRewardFunds();
    assertEq(alertingBucketAfter, alertingBucketBefore - amountWithdrawn);
  }

  function test_EmitsEvent() public {
    uint256 amountWithdrawn = 1 ether;
    uint256 alertingBucketBefore = s_operatorStakingPool.getAlerterRewardFunds();
    vm.expectEmit(true, true, true, true, address(s_operatorStakingPool));
    emit AlerterRewardWithdrawn(amountWithdrawn, alertingBucketBefore - amountWithdrawn);
    changePrank(OWNER);
    s_operatorStakingPool.withdrawAlerterReward(amountWithdrawn);
  }
}

contract OperatorStakingPool_Slash_WhenOperatorsHaveStakedTheSlashableFeedAmount is
  PriceFeedAlertsController_WithSlasherRole
{
  event AlertingRewardPaid(
    address indexed alerter, uint256 alerterRewardActual, uint256 alerterRewardExpected
  );
  event Slashed(address indexed operator, uint256 slashedAmount, uint256 updatedStakerPrincipal);

  function setUp() public override {
    PriceFeedAlertsController_WithSlasherRole.setUp();
    changePrank(OPERATOR_STAKER_ONE);
    s_LINK.transferAndCall(address(s_operatorStakingPool), FEED_SLASHABLE_AMOUNT, '');
    changePrank(OPERATOR_STAKER_TWO);
    s_LINK.transferAndCall(address(s_operatorStakingPool), FEED_SLASHABLE_AMOUNT, '');
  }

  function test_RevertWhen_CalledByNonSlasher() public {
    changePrank(STRANGER);

    vm.expectRevert(IStakingPool.AccessForbidden.selector);
    s_operatorStakingPool.slashAndReward(
      _getDefaultOperators(), COMMUNITY_STAKER_ONE, FEED_SLASHABLE_AMOUNT, ALERTER_REWARD_AMOUNT
    );
  }

  function test_RewardsAlerterFullAmountIfSlashedAmountAndAlertingBucketCanCoverReward() public {
    uint256 alerterLINKBalanceBefore = s_LINK.balanceOf(COMMUNITY_STAKER_ONE);
    changePrank(address(s_pfAlertsController));
    s_operatorStakingPool.slashAndReward(
      _getSlashableOperators(), COMMUNITY_STAKER_ONE, FEED_SLASHABLE_AMOUNT, ALERTER_REWARD_AMOUNT
    );
    assertEq(
      s_LINK.balanceOf(COMMUNITY_STAKER_ONE), alerterLINKBalanceBefore + ALERTER_REWARD_AMOUNT
    );
  }

  function test_UpdatesalerterRewardFundsIfSlashedAmountCanBeCovered() public {
    address[] memory slashedOperators = _getSlashableOperators();
    uint256 expectedTotalSlashedAmount = FEED_SLASHABLE_AMOUNT * 2;
    uint256 operatorPoolLINKBalanceBefore = s_LINK.balanceOf(address(s_operatorStakingPool));
    uint256 alerterRewardBucketBefore = s_operatorStakingPool.getAlerterRewardFunds();
    changePrank(address(s_pfAlertsController));
    s_operatorStakingPool.slashAndReward(
      slashedOperators, COMMUNITY_STAKER_ONE, FEED_SLASHABLE_AMOUNT, ALERTER_REWARD_AMOUNT
    );
    assertEq(
      s_operatorStakingPool.getAlerterRewardFunds(),
      alerterRewardBucketBefore + expectedTotalSlashedAmount - ALERTER_REWARD_AMOUNT
    );
    assertEq(
      s_LINK.balanceOf(address(s_operatorStakingPool)),
      operatorPoolLINKBalanceBefore - ALERTER_REWARD_AMOUNT
    );
  }

  function test_EmitsCorrectEventIfSlashedAmountAndAlertingBucketCanCoverReward() public {
    address[] memory slashedOperators = _getSlashableOperators();

    vm.expectEmit(true, true, true, true, address(s_operatorStakingPool));
    emit AlertingRewardPaid(COMMUNITY_STAKER_ONE, ALERTER_REWARD_AMOUNT, ALERTER_REWARD_AMOUNT);
    changePrank(address(s_pfAlertsController));
    s_operatorStakingPool.slashAndReward(
      slashedOperators, COMMUNITY_STAKER_ONE, FEED_SLASHABLE_AMOUNT, ALERTER_REWARD_AMOUNT
    );
  }

  function test_SlashesTheCorrectAmountOfOperatorPrincipal() public {
    address[] memory slashedOperators = _getSlashableOperators();
    uint256 operatorPrincipalBefore = s_operatorStakingPool.getStakerPrincipal(OPERATOR_STAKER_ONE);

    changePrank(address(s_pfAlertsController));
    for (uint256 i; i < slashedOperators.length; ++i) {
      uint256 operatorPrincipal = s_operatorStakingPool.getStakerPrincipal(slashedOperators[i]);
      vm.expectEmit(true, true, true, true, address(s_operatorStakingPool));
      emit Slashed(
        slashedOperators[i], FEED_SLASHABLE_AMOUNT, operatorPrincipal - FEED_SLASHABLE_AMOUNT
      );
    }
    s_operatorStakingPool.slashAndReward(
      slashedOperators, COMMUNITY_STAKER_ONE, FEED_SLASHABLE_AMOUNT, ALERTER_REWARD_AMOUNT
    );
    assertEq(
      s_operatorStakingPool.getStakerPrincipal(OPERATOR_STAKER_ONE),
      operatorPrincipalBefore - FEED_SLASHABLE_AMOUNT
    );
  }

  function test_OperatorCanStillEarnUnclaimableRewards() public {
    address[] memory slashedOperators = _getSlashableOperators();

    (RewardVault.StakerReward memory operatorRewardsBefore, uint256 unclaimedBaseRewards) =
      s_rewardVault.calculateLatestStakerReward(OPERATOR_STAKER_ONE);

    uint256 finalizedBaseRewards = operatorRewardsBefore.finalizedBaseReward;
    uint256 finalizedDelegatedRewards = operatorRewardsBefore.finalizedDelegatedReward;

    changePrank(address(s_pfAlertsController));
    s_operatorStakingPool.slashAndReward(
      slashedOperators, COMMUNITY_STAKER_ONE, FEED_SLASHABLE_AMOUNT, ALERTER_REWARD_AMOUNT
    );

    uint256 timeAfterSlash = 28 days;

    uint256 operatorBaseRewardsAfterSlash = _calculateStakerExpectedReward(
      s_operatorStakingPool.getStakerPrincipal(OPERATOR_STAKER_ONE),
      s_operatorStakingPool.getTotalPrincipal(),
      _calculateBucketVestedRewards(
        s_rewardVault.getRewardBuckets().operatorBase,
        block.timestamp,
        block.timestamp + timeAfterSlash
      )
    );

    uint256 operatorDelegatedRewardsAfterSlash = _calculateStakerExpectedReward(
      s_operatorStakingPool.getStakerPrincipal(OPERATOR_STAKER_ONE),
      s_operatorStakingPool.getTotalPrincipal(),
      _calculateBucketVestedRewards(
        s_rewardVault.getRewardBuckets().operatorDelegated,
        block.timestamp,
        block.timestamp + timeAfterSlash
      )
    );

    // Move time forward
    skip(timeAfterSlash);

    uint256 multiplier = s_rewardVault.getMultiplier(OPERATOR_STAKER_ONE);
    uint256 totalBaseRewards = (multiplier * (unclaimedBaseRewards + operatorBaseRewardsAfterSlash))
      / FixedPointMathLib.WAD + finalizedBaseRewards;
    uint256 totalDelegatedRewards = finalizedDelegatedRewards + operatorDelegatedRewardsAfterSlash;

    assertEq(s_rewardVault.getReward(OPERATOR_STAKER_ONE), totalBaseRewards + totalDelegatedRewards);
  }

  function test_DecreasesTheTotalPrincipalStaked() public {
    address[] memory slashedOperators = _getSlashableOperators();
    uint256 expectedTotalSlashedAmount = slashedOperators.length * FEED_SLASHABLE_AMOUNT;
    uint256 poolTotalPrincipalBefore = s_operatorStakingPool.getTotalPrincipal();
    changePrank(address(s_pfAlertsController));
    s_operatorStakingPool.slashAndReward(
      slashedOperators, COMMUNITY_STAKER_ONE, FEED_SLASHABLE_AMOUNT, ALERTER_REWARD_AMOUNT
    );
    assertEq(
      s_operatorStakingPool.getTotalPrincipal(),
      poolTotalPrincipalBefore - expectedTotalSlashedAmount
    );
  }

  function test_DoesNotResetTheMultiplier() public {
    address[] memory slashedOperators = _getSlashableOperators();
    uint256 operatorMultiplierBefore = s_rewardVault.getMultiplier(OPERATOR_STAKER_ONE);
    changePrank(address(s_pfAlertsController));
    s_operatorStakingPool.slashAndReward(
      slashedOperators, COMMUNITY_STAKER_ONE, FEED_SLASHABLE_AMOUNT, ALERTER_REWARD_AMOUNT
    );
    assertEq(s_rewardVault.getMultiplier(OPERATOR_STAKER_ONE), operatorMultiplierBefore);
  }

  function test_RewardsAlerterPartialAmountIfSlashedAmountAndAlertingBucketCannnotCoverReward()
    public
  {
    address[] memory slashedOperators = _getSlashableOperators();
    uint256 expectedTotalSlashedAmount = FEED_SLASHABLE_AMOUNT * slashedOperators.length;
    uint256 expectedExcessReward = 500 ether;
    uint256 alerterRewardAmount =
      expectedTotalSlashedAmount + INITIAL_ALERTING_BUCKET_BALANCE + expectedExcessReward;
    uint256 alerterLINKBalanceBefore = s_LINK.balanceOf(COMMUNITY_STAKER_ONE);
    changePrank(address(s_pfAlertsController));
    s_operatorStakingPool.slashAndReward(
      slashedOperators, COMMUNITY_STAKER_ONE, FEED_SLASHABLE_AMOUNT, alerterRewardAmount
    );
    assertEq(
      s_LINK.balanceOf(COMMUNITY_STAKER_ONE),
      alerterLINKBalanceBefore + alerterRewardAmount - expectedExcessReward
    );
  }

  function test_EmitsCorrectEventIfSlashedAmountAndAlertingBucketCannnotCoverReward() public {
    address[] memory slashedOperators = _getSlashableOperators();
    uint256 expectedTotalSlashedAmount = FEED_SLASHABLE_AMOUNT * slashedOperators.length;
    uint256 expectedExcessReward = 500 ether;
    uint256 alerterRewardAmount =
      expectedTotalSlashedAmount + INITIAL_ALERTING_BUCKET_BALANCE + expectedExcessReward;

    vm.expectEmit(true, true, true, true, address(s_operatorStakingPool));
    emit AlertingRewardPaid(
      COMMUNITY_STAKER_ONE,
      INITIAL_ALERTING_BUCKET_BALANCE + expectedTotalSlashedAmount,
      alerterRewardAmount
    );
    changePrank(address(s_pfAlertsController));
    s_operatorStakingPool.slashAndReward(
      slashedOperators, COMMUNITY_STAKER_ONE, FEED_SLASHABLE_AMOUNT, alerterRewardAmount
    );
  }
}

contract OperatorStakingPool_Slash_WhenOperatorsHaveStakedLessThanTheSlashableFeedAmount is
  PriceFeedAlertsController_WithSlasherRole
{
  event AlertingRewardPaid(
    address indexed alerter, uint256 alerterRewardActual, uint256 alerterRewardExpected
  );
  event Slashed(address indexed operator, uint256 slashedAmount, uint256 updatedStakerPrincipal);

  function setUp() public override {
    PriceFeedAlertsController_WithSlasherRole.setUp();
    changePrank(OPERATOR_STAKER_THREE);
    s_LINK.transferAndCall(address(s_operatorStakingPool), OPERATOR_MIN_PRINCIPAL, abi.encode(''));
  }

  function test_UpdatesAlerterRewardFundsIfSlashedAmountCanBeCovered() public {
    address[] memory slashedOperators = _getSlashableOperators();
    uint256 expectedTotalSlashedAmount = OPERATOR_MIN_PRINCIPAL * 2;
    uint256 operatorPoolLINKBalanceBefore = s_LINK.balanceOf(address(s_operatorStakingPool));
    uint256 alerterRewardBucketBefore = s_operatorStakingPool.getAlerterRewardFunds();
    changePrank(address(s_pfAlertsController));
    s_operatorStakingPool.slashAndReward(
      slashedOperators, COMMUNITY_STAKER_ONE, FEED_SLASHABLE_AMOUNT, ALERTER_REWARD_AMOUNT
    );
    assertEq(
      s_operatorStakingPool.getAlerterRewardFunds(),
      alerterRewardBucketBefore + expectedTotalSlashedAmount - ALERTER_REWARD_AMOUNT
    );
    assertEq(
      s_LINK.balanceOf(address(s_operatorStakingPool)),
      operatorPoolLINKBalanceBefore - ALERTER_REWARD_AMOUNT
    );
  }

  function test_RewardsAlerterFullAmountIfSlashedAmountAndAlertingBucketCanCoverReward() public {
    uint256 alerterLINKBalanceBefore = s_LINK.balanceOf(COMMUNITY_STAKER_ONE);
    changePrank(address(s_pfAlertsController));
    s_operatorStakingPool.slashAndReward(
      _getSlashableOperators(), COMMUNITY_STAKER_ONE, FEED_SLASHABLE_AMOUNT, ALERTER_REWARD_AMOUNT
    );
    assertEq(
      s_LINK.balanceOf(COMMUNITY_STAKER_ONE), alerterLINKBalanceBefore + ALERTER_REWARD_AMOUNT
    );
  }

  function test_EmitsCorrectEventIfSlashedAmountAndAlertingBucketCanCoverReward() public {
    address[] memory slashedOperators = _getSlashableOperators();

    vm.expectEmit(true, true, true, true, address(s_operatorStakingPool));
    emit AlertingRewardPaid(COMMUNITY_STAKER_ONE, ALERTER_REWARD_AMOUNT, ALERTER_REWARD_AMOUNT);
    changePrank(address(s_pfAlertsController));
    s_operatorStakingPool.slashAndReward(
      slashedOperators, COMMUNITY_STAKER_ONE, FEED_SLASHABLE_AMOUNT, ALERTER_REWARD_AMOUNT
    );
  }

  function test_RewardsAlerterPartialAmountIfSlashedAmountAndAlertingBucketCannnotCoverReward()
    public
  {
    address[] memory slashedOperators = _getSlashableOperators();
    uint256 expectedTotalSlashedAmount = OPERATOR_MIN_PRINCIPAL * slashedOperators.length;
    uint256 expectedExcessReward = 500 ether;
    uint256 alerterRewardAmount =
      expectedTotalSlashedAmount + INITIAL_ALERTING_BUCKET_BALANCE + expectedExcessReward;
    uint256 alerterLINKBalanceBefore = s_LINK.balanceOf(COMMUNITY_STAKER_ONE);
    changePrank(address(s_pfAlertsController));
    s_operatorStakingPool.slashAndReward(
      slashedOperators, COMMUNITY_STAKER_ONE, FEED_SLASHABLE_AMOUNT, alerterRewardAmount
    );
    assertEq(
      s_LINK.balanceOf(COMMUNITY_STAKER_ONE),
      alerterLINKBalanceBefore + alerterRewardAmount - expectedExcessReward
    );
  }

  function test_EmitsCorrectEventIfSlashedAmountAndAlertingBucketCannnotCoverReward() public {
    address[] memory slashedOperators = _getSlashableOperators();
    uint256 expectedTotalSlashedAmount = OPERATOR_MIN_PRINCIPAL * slashedOperators.length;
    uint256 expectedExcessReward = 500 ether;
    uint256 alerterRewardAmount =
      expectedTotalSlashedAmount + INITIAL_ALERTING_BUCKET_BALANCE + expectedExcessReward;

    vm.expectEmit(true, true, true, true, address(s_operatorStakingPool));
    emit AlertingRewardPaid(
      COMMUNITY_STAKER_ONE,
      INITIAL_ALERTING_BUCKET_BALANCE + expectedTotalSlashedAmount,
      alerterRewardAmount
    );
    changePrank(address(s_pfAlertsController));
    s_operatorStakingPool.slashAndReward(
      slashedOperators, COMMUNITY_STAKER_ONE, FEED_SLASHABLE_AMOUNT, alerterRewardAmount
    );
  }

  function test_SlashesTheFullOperatorPrincipal() public {
    address[] memory slashedOperators = _getSlashableOperators();

    changePrank(address(s_pfAlertsController));
    for (uint256 i; i < slashedOperators.length; ++i) {
      vm.expectEmit(true, true, true, true, address(s_operatorStakingPool));
      emit Slashed(slashedOperators[i], OPERATOR_MIN_PRINCIPAL, 0);
    }
    s_operatorStakingPool.slashAndReward(
      slashedOperators, COMMUNITY_STAKER_ONE, FEED_SLASHABLE_AMOUNT, ALERTER_REWARD_AMOUNT
    );
    assertEq(s_operatorStakingPool.getStakerPrincipal(OPERATOR_STAKER_ONE), 0);
  }

  function test_OperatorCanStillEarnUnclaimableRewards() public {
    address[] memory slashedOperators = _getSlashableOperators();

    (RewardVault.StakerReward memory operatorRewardsBefore, uint256 unclaimedRewards) =
      s_rewardVault.calculateLatestStakerReward(OPERATOR_STAKER_ONE);

    uint256 operatorEarnedRewards = operatorRewardsBefore.finalizedBaseReward + unclaimedRewards;
    uint256 operatorEarnedDelegatedRewards = operatorRewardsBefore.finalizedDelegatedReward;

    changePrank(address(s_pfAlertsController));
    s_operatorStakingPool.slashAndReward(
      slashedOperators, COMMUNITY_STAKER_ONE, FEED_SLASHABLE_AMOUNT, ALERTER_REWARD_AMOUNT
    );

    // Move time forward
    skip(28 days);

    uint256 multiplier = s_rewardVault.getMultiplier(OPERATOR_STAKER_ONE);
    operatorEarnedRewards = (multiplier * operatorEarnedRewards) / FixedPointMathLib.WAD;

    assertEq(
      s_rewardVault.getReward(OPERATOR_STAKER_ONE),
      operatorEarnedRewards + operatorEarnedDelegatedRewards
    );
  }

  function test_DecreasesTheTotalPrincipalStaked() public {
    address[] memory slashedOperators = _getSlashableOperators();
    uint256 expectedTotalSlashedAmount = slashedOperators.length * OPERATOR_MIN_PRINCIPAL;
    uint256 poolTotalPrincipalBefore = s_operatorStakingPool.getTotalPrincipal();
    changePrank(address(s_pfAlertsController));
    s_operatorStakingPool.slashAndReward(
      slashedOperators, COMMUNITY_STAKER_ONE, FEED_SLASHABLE_AMOUNT, ALERTER_REWARD_AMOUNT
    );
    assertEq(
      s_operatorStakingPool.getTotalPrincipal(),
      poolTotalPrincipalBefore - expectedTotalSlashedAmount
    );
  }

  function test_TypeAndVersion() public {
    string memory typeAndVersion = s_operatorStakingPool.typeAndVersion();
    assertEq(typeAndVersion, 'OperatorStakingPool 1.0.0');
  }
}

contract OperatorStakingPool_Slash_WhenPoolIsNotActive is
  PriceFeedAlertsController_WithSlasherRole
{
  function test_RevertWhen_PoolIsClosed() public {
    changePrank(OWNER);
    s_operatorStakingPool.close();

    changePrank(address(s_pfAlertsController));
    vm.expectRevert(StakingPoolBase.PoolNotActive.selector);
    s_operatorStakingPool.slashAndReward(
      _getSlashableOperators(), COMMUNITY_STAKER_ONE, FEED_SLASHABLE_AMOUNT, ALERTER_REWARD_AMOUNT
    );
  }

  function test_RevertWhen_RewardHasStoppedEmitting() public {
    RewardVault.RewardBuckets memory buckets = s_rewardVault.getRewardBuckets();
    vm.warp(buckets.operatorBase.rewardDurationEndsAt);
    changePrank(address(s_pfAlertsController));
    vm.expectRevert(StakingPoolBase.PoolNotActive.selector);
    s_operatorStakingPool.slashAndReward(
      _getSlashableOperators(), COMMUNITY_STAKER_ONE, FEED_SLASHABLE_AMOUNT, ALERTER_REWARD_AMOUNT
    );
  }
}

contract OperatorStakingPool_AddSlasher is PriceFeedAlertsController_WhenPoolOpen {
  event SlasherConfigSet(address indexed slasher, uint256 refillRate, uint256 slashCapacity);
  event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

  function test_RevertWhen_NotOwnerAddsSlasher() public {
    changePrank(STRANGER);
    vm.expectRevert(
      _getExpectedMissingRoleErrorMessage(STRANGER, s_operatorStakingPool.DEFAULT_ADMIN_ROLE())
    );
    s_operatorStakingPool.addSlasher(
      address(s_pfAlertsController),
      ISlashable.SlasherConfig({refillRate: SLASH_REFILL_RATE, slashCapacity: SLASH_MAX_AMOUNT})
    );
  }

  function test_RevertWhen_SlashCapacityIsZero() public {
    changePrank(OWNER);
    vm.expectRevert(ISlashable.InvalidSlasherConfig.selector);
    s_operatorStakingPool.addSlasher(
      address(s_pfAlertsController),
      ISlashable.SlasherConfig({refillRate: SLASH_REFILL_RATE, slashCapacity: 0})
    );
  }

  function test_RevertWhen_RefillRateIsZero() public {
    changePrank(OWNER);
    vm.expectRevert(ISlashable.InvalidSlasherConfig.selector);
    s_operatorStakingPool.addSlasher(
      address(s_pfAlertsController),
      ISlashable.SlasherConfig({refillRate: 0, slashCapacity: SLASH_MAX_AMOUNT})
    );
  }

  function test_RevertWhen_DirectlyGrantsSlasherRole() public {
    changePrank(OWNER);
    bytes32 slasherRole = s_operatorStakingPool.SLASHER_ROLE();
    vm.expectRevert(ISlashable.InvalidRole.selector);
    s_operatorStakingPool.grantRole(slasherRole, address(s_pfAlertsController));
  }

  function test_CanAddSlasher() public {
    changePrank(OWNER);
    vm.expectEmit(true, true, true, true, address(s_operatorStakingPool));
    emit RoleGranted(s_operatorStakingPool.SLASHER_ROLE(), address(s_pfAlertsController), OWNER);
    vm.expectEmit(true, true, true, true, address(s_operatorStakingPool));
    emit SlasherConfigSet(address(s_pfAlertsController), SLASH_REFILL_RATE, SLASH_MAX_AMOUNT);
    s_operatorStakingPool.addSlasher(
      address(s_pfAlertsController),
      ISlashable.SlasherConfig({refillRate: SLASH_REFILL_RATE, slashCapacity: SLASH_MAX_AMOUNT})
    );
    assertTrue(
      s_operatorStakingPool.hasRole(
        s_operatorStakingPool.SLASHER_ROLE(), address(s_pfAlertsController)
      )
    );
    assertEq(
      s_operatorStakingPool.getSlasherConfig(address(s_pfAlertsController)).slashCapacity,
      SLASH_MAX_AMOUNT
    );
    assertEq(
      s_operatorStakingPool.getSlasherConfig(address(s_pfAlertsController)).refillRate,
      SLASH_REFILL_RATE
    );
    assertEq(
      s_operatorStakingPool.getSlashCapacity(address(s_pfAlertsController)), SLASH_MAX_AMOUNT
    );
  }
}

contract OperatorStakingPool_SetSlasherConfig is
  PriceFeedAlertsController_WithSlasherRoleAndMaxStakedAmount
{
  event SlasherConfigSet(address indexed slasher, uint256 refillRate, uint256 slashCapacity);

  function test_RevertWhen_SlashCapacityIsZero() public {
    changePrank(OWNER);
    vm.expectRevert(ISlashable.InvalidSlasherConfig.selector);
    s_operatorStakingPool.setSlasherConfig(
      address(s_pfAlertsController),
      ISlashable.SlasherConfig({refillRate: SLASH_REFILL_RATE, slashCapacity: 0})
    );
  }

  function test_RevertWhen_RefillRateIsZero() public {
    changePrank(OWNER);
    vm.expectRevert(ISlashable.InvalidSlasherConfig.selector);
    s_operatorStakingPool.setSlasherConfig(
      address(s_pfAlertsController),
      ISlashable.SlasherConfig({refillRate: 0, slashCapacity: SLASH_MAX_AMOUNT})
    );
  }

  function test_RevertWhen_NotOwnerSetsSlashConfig() public {
    changePrank(STRANGER);
    vm.expectRevert(
      _getExpectedMissingRoleErrorMessage(STRANGER, s_operatorStakingPool.DEFAULT_ADMIN_ROLE())
    );
    s_operatorStakingPool.setSlasherConfig(
      address(s_pfAlertsController),
      ISlashable.SlasherConfig({refillRate: SLASH_REFILL_RATE, slashCapacity: SLASH_MAX_AMOUNT})
    );
  }

  function test_RevertWhen_SettingConfigForNotSlasher() public {
    changePrank(OWNER);
    vm.expectRevert(ISlashable.InvalidSlasher.selector);
    s_operatorStakingPool.setSlasherConfig(
      STRANGER,
      ISlashable.SlasherConfig({refillRate: SLASH_REFILL_RATE, slashCapacity: SLASH_MAX_AMOUNT})
    );
  }

  function test_CanSetSlasherConfig() public {
    changePrank(OWNER);
    s_operatorStakingPool.addSlasher(
      STRANGER,
      ISlashable.SlasherConfig({refillRate: SLASH_REFILL_RATE, slashCapacity: SLASH_MAX_AMOUNT})
    );

    assertEq(s_operatorStakingPool.getSlashCapacity(STRANGER), SLASH_MAX_AMOUNT);
    assertEq(s_operatorStakingPool.getSlasherConfig(STRANGER).slashCapacity, SLASH_MAX_AMOUNT);
    assertEq(s_operatorStakingPool.getSlasherConfig(STRANGER).refillRate, SLASH_REFILL_RATE);

    vm.expectEmit(true, true, true, true, address(s_operatorStakingPool));
    emit SlasherConfigSet(STRANGER, SLASH_REFILL_RATE + 1, SLASH_MAX_AMOUNT + 1);
    s_operatorStakingPool.setSlasherConfig(
      STRANGER,
      ISlashable.SlasherConfig({
        refillRate: SLASH_REFILL_RATE + 1,
        slashCapacity: SLASH_MAX_AMOUNT + 1
      })
    );

    assertEq(s_operatorStakingPool.getSlashCapacity(STRANGER), SLASH_MAX_AMOUNT + 1);
    assertEq(s_operatorStakingPool.getSlasherConfig(STRANGER).slashCapacity, SLASH_MAX_AMOUNT + 1);
    assertEq(s_operatorStakingPool.getSlasherConfig(STRANGER).refillRate, SLASH_REFILL_RATE + 1);
  }

  function test_ResetSlashCapacityUsedAfterSettingANewSlasherConfig() public {
    address[] memory slashedOperators = _getSlashableOperators();
    uint256 slashableAmount = SLASH_MAX_AMOUNT / slashedOperators.length;
    uint256 newSlashCapacity = SLASH_MAX_AMOUNT * 2;

    changePrank(address(s_pfAlertsController));
    s_operatorStakingPool.slashAndReward(
      slashedOperators, COMMUNITY_STAKER_ONE, slashableAmount, ALERTER_REWARD_AMOUNT
    );

    assertEq(s_operatorStakingPool.getSlashCapacity(address(s_pfAlertsController)), 0);

    changePrank(OWNER);
    s_operatorStakingPool.setSlasherConfig(
      address(s_pfAlertsController),
      ISlashable.SlasherConfig({refillRate: SLASH_REFILL_RATE, slashCapacity: newSlashCapacity})
    );

    assertEq(
      s_operatorStakingPool.getSlashCapacity(address(s_pfAlertsController)), newSlashCapacity
    );
  }
}

contract OperatorStakingPool_SlashCapacity is
  PriceFeedAlertsController_WithSlasherRoleAndMaxStakedAmount
{
  function test_ShouldRefillSlashCapacityAfterSlashing() public {
    address[] memory slashedOperators = _getSlashableOperators();
    uint256 refillDuration = 30 seconds;
    uint256 refillAmount = SLASH_REFILL_RATE * refillDuration;

    changePrank(address(s_pfAlertsController));
    s_operatorStakingPool.slashAndReward(
      slashedOperators, COMMUNITY_STAKER_ONE, FEED_SLASHABLE_AMOUNT, ALERTER_REWARD_AMOUNT
    );

    assertEq(
      s_operatorStakingPool.getSlashCapacity(address(s_pfAlertsController)),
      SLASH_MAX_AMOUNT - (FEED_SLASHABLE_AMOUNT * slashedOperators.length)
    );

    skip(refillDuration);

    assertEq(
      s_operatorStakingPool.getSlashCapacity(address(s_pfAlertsController)),
      SLASH_MAX_AMOUNT - (FEED_SLASHABLE_AMOUNT * slashedOperators.length) + refillAmount
    );
  }

  function test_SlashCapacityShouldNeverExceedConfigAmount() public {
    address[] memory slashedOperators = _getSlashableOperators();
    uint256 refillDuration = 1000 days;
    uint256 refillAmount = SLASH_REFILL_RATE * refillDuration;

    assertGt(refillAmount, SLASH_MAX_AMOUNT);

    changePrank(address(s_pfAlertsController));
    s_operatorStakingPool.slashAndReward(
      slashedOperators, COMMUNITY_STAKER_ONE, FEED_SLASHABLE_AMOUNT, ALERTER_REWARD_AMOUNT
    );

    assertEq(
      s_operatorStakingPool.getSlashCapacity(address(s_pfAlertsController)),
      SLASH_MAX_AMOUNT - (FEED_SLASHABLE_AMOUNT * slashedOperators.length)
    );

    skip(refillDuration);

    assertEq(
      s_operatorStakingPool.getSlashCapacity(address(s_pfAlertsController)), SLASH_MAX_AMOUNT
    );
  }

  function test_ShouldSlashMultipleTimesWithinTheSlashCapacityWithoutRefilling() public {
    address[] memory slashedOperators = _getSlashableOperators();
    uint256 slashableAmount = (SLASH_MAX_AMOUNT / 2) / slashedOperators.length;

    changePrank(address(s_pfAlertsController));
    // slash half the max amount
    s_operatorStakingPool.slashAndReward(
      slashedOperators, COMMUNITY_STAKER_ONE, slashableAmount, ALERTER_REWARD_AMOUNT
    );

    // should be able to slash half again
    assertEq(
      s_operatorStakingPool.getSlashCapacity(address(s_pfAlertsController)), SLASH_MAX_AMOUNT / 2
    );

    // slash half again
    s_operatorStakingPool.slashAndReward(
      slashedOperators, COMMUNITY_STAKER_ONE, slashableAmount, ALERTER_REWARD_AMOUNT
    );

    // should no longer be able to slash
    assertEq(s_operatorStakingPool.getSlashCapacity(address(s_pfAlertsController)), 0);
  }

  function test_ShouldRefillCompletelyAfterMaxSlashAndAllowToSlashAgain() public {
    address[] memory slashedOperators = _getSlashableOperators();
    uint256 slashAmount = SLASH_MAX_AMOUNT / slashedOperators.length;
    uint256 refillDuration = SLASH_MAX_AMOUNT / SLASH_REFILL_RATE;

    changePrank(address(s_pfAlertsController));
    s_operatorStakingPool.slashAndReward(
      slashedOperators, COMMUNITY_STAKER_ONE, slashAmount, ALERTER_REWARD_AMOUNT
    );

    assertEq(s_operatorStakingPool.getSlashCapacity(address(s_pfAlertsController)), 0);

    skip(refillDuration);

    s_operatorStakingPool.slashAndReward(
      slashedOperators, COMMUNITY_STAKER_ONE, slashAmount, ALERTER_REWARD_AMOUNT
    );

    assertEq(s_operatorStakingPool.getSlashCapacity(address(s_pfAlertsController)), 0);
  }
}

contract OperatorStakingPool_SlashCapacityWithAmountSlashed is
  PriceFeedAlertsController_WithSlasherRoleAndMaxStakedAmount
{
  event Slashed(address indexed operator, uint256 slashedAmount, uint256 updatedStakerPrincipal);

  uint256 internal s_remainingSlashableAmount;

  function setUp() public override {
    PriceFeedAlertsController_WithSlasherRoleAndMaxStakedAmount.setUp();

    s_remainingSlashableAmount = SLASH_MAX_AMOUNT / 2;
    address[] memory slashedOperators = _getSlashableOperators();

    uint256 totalAmountToSlash = SLASH_MAX_AMOUNT / 2;

    changePrank(address(s_pfAlertsController));
    s_operatorStakingPool.slashAndReward(
      slashedOperators,
      COMMUNITY_STAKER_ONE,
      totalAmountToSlash / slashedOperators.length,
      ALERTER_REWARD_AMOUNT
    );
  }

  function test_SlashesUpToCapacity() public {
    address[] memory slashedOperators = _getSlashableOperators();
    uint256 operatorPrincipalBefore = s_operatorStakingPool.getStakerPrincipal(OPERATOR_STAKER_ONE);
    uint256 expectedSlashedAmountPerOperator = s_remainingSlashableAmount / slashedOperators.length;

    changePrank(address(s_pfAlertsController));
    for (uint256 i; i < slashedOperators.length; ++i) {
      uint256 operatorPrincipal = s_operatorStakingPool.getStakerPrincipal(slashedOperators[i]);
      vm.expectEmit(true, true, true, true, address(s_operatorStakingPool));
      emit Slashed(
        slashedOperators[i],
        expectedSlashedAmountPerOperator,
        operatorPrincipal - expectedSlashedAmountPerOperator
      );
    }
    s_operatorStakingPool.slashAndReward(
      slashedOperators, COMMUNITY_STAKER_ONE, SLASH_MAX_AMOUNT, ALERTER_REWARD_AMOUNT
    );
    assertEq(
      s_operatorStakingPool.getStakerPrincipal(OPERATOR_STAKER_ONE),
      operatorPrincipalBefore - expectedSlashedAmountPerOperator
    );
  }
}

contract OperatorStakingPool_AccessControlDefaultAdminRules is
  IAccessControlDefaultAdminRulesTest,
  BaseTest
{
  using SafeCast for uint256;

  event DefaultAdminTransferScheduled(address indexed newAdmin, uint48 acceptSchedule);
  event DefaultAdminTransferCanceled();
  event DefaultAdminDelayChangeScheduled(uint48 newDelay, uint48 effectSchedule);
  event DefaultAdminDelayChangeCanceled();

  function test_DefaultValuesAreInitialized() public {
    assertEq(s_operatorStakingPool.hasRole(s_operatorStakingPool.DEFAULT_ADMIN_ROLE(), OWNER), true);
    assertEq(s_operatorStakingPool.defaultAdmin(), OWNER);
    (address pendingDefaultAdmin, uint48 adminSchedule) =
      s_operatorStakingPool.pendingDefaultAdmin();
    assertEq(pendingDefaultAdmin, address(0));
    assertEq(adminSchedule, 0);
    assertEq(s_operatorStakingPool.defaultAdminDelay(), 0);
    (uint48 pendingDelay, uint48 delaySchedule) = s_operatorStakingPool.pendingDefaultAdminDelay();
    assertEq(pendingDelay, 0);
    assertEq(delaySchedule, 0);
    assertEq(s_operatorStakingPool.defaultAdminDelayIncreaseWait(), 5 days);
  }

  function test_RevertWhen_DirectlyGrantDefaultAdminRole() public {
    changePrank(OWNER);
    bytes32 defaultAdminRole = s_operatorStakingPool.DEFAULT_ADMIN_ROLE();
    vm.expectRevert("AccessControl: can't directly grant default admin role");
    s_operatorStakingPool.grantRole(defaultAdminRole, NEW_OWNER);
  }

  function test_RevertWhen_DirectlyRevokeDefaultAdminRole() public {
    changePrank(OWNER);
    bytes32 defaultAdminRole = s_operatorStakingPool.DEFAULT_ADMIN_ROLE();
    vm.expectRevert("AccessControl: can't directly revoke default admin role");
    s_operatorStakingPool.revokeRole(defaultAdminRole, NEW_OWNER);
  }

  function test_RevertWhen_NonAdminBeginsDefaultAdminTransfer() public {
    changePrank(NEW_OWNER);
    vm.expectRevert(
      _getExpectedMissingRoleErrorMessage(NEW_OWNER, s_operatorStakingPool.DEFAULT_ADMIN_ROLE())
    );
    s_operatorStakingPool.beginDefaultAdminTransfer(NEW_OWNER);
  }

  function test_CurrentAdminCanBeginDefaultAdminTransfer() public {
    changePrank(OWNER);
    address newAdmin = NEW_OWNER;
    uint48 newSchedule = SafeCast.toUint48(block.timestamp);
    vm.expectEmit(true, true, true, true, address(s_operatorStakingPool));
    emit DefaultAdminTransferScheduled(newAdmin, newSchedule);

    s_operatorStakingPool.beginDefaultAdminTransfer(newAdmin);

    assertEq(s_operatorStakingPool.hasRole(s_operatorStakingPool.DEFAULT_ADMIN_ROLE(), OWNER), true);
    assertEq(s_operatorStakingPool.defaultAdmin(), OWNER);
    (address pendingDefaultAdmin, uint48 schedule) = s_operatorStakingPool.pendingDefaultAdmin();
    assertEq(pendingDefaultAdmin, newAdmin);
    assertEq(schedule, newSchedule);
  }

  function test_CurrentAdminCanOverwritePendingDefaultAdminTransfer() public {
    changePrank(OWNER);
    s_operatorStakingPool.beginDefaultAdminTransfer(NEW_OWNER);

    address newAdmin = PAUSER;
    uint48 newSchedule = SafeCast.toUint48(block.timestamp);
    vm.expectEmit(true, true, true, true, address(s_operatorStakingPool));
    emit DefaultAdminTransferCanceled();
    vm.expectEmit(true, true, true, true, address(s_operatorStakingPool));
    emit DefaultAdminTransferScheduled(newAdmin, newSchedule);

    s_operatorStakingPool.beginDefaultAdminTransfer(newAdmin);

    assertEq(s_operatorStakingPool.hasRole(s_operatorStakingPool.DEFAULT_ADMIN_ROLE(), OWNER), true);
    assertEq(s_operatorStakingPool.defaultAdmin(), OWNER);
    (address pendingDefaultAdmin, uint48 schedule) = s_operatorStakingPool.pendingDefaultAdmin();
    assertEq(pendingDefaultAdmin, newAdmin);
    assertEq(schedule, newSchedule);
  }

  function test_CurrentAdminCanOverwriteDefaultAdminTransferAfterDelayPassedAndIfNotAccepted()
    public
  {
    changePrank(OWNER);
    s_operatorStakingPool.beginDefaultAdminTransfer(NEW_OWNER);
    (, uint48 scheduleBefore) = s_operatorStakingPool.pendingDefaultAdmin();

    // After the delay is over
    skip(2);

    address newAdmin = PAUSER;
    uint48 newSchedule = scheduleBefore + 2;
    vm.expectEmit(true, true, true, true, address(s_operatorStakingPool));
    emit DefaultAdminTransferCanceled();
    vm.expectEmit(true, true, true, true, address(s_operatorStakingPool));
    emit DefaultAdminTransferScheduled(newAdmin, newSchedule);

    s_operatorStakingPool.beginDefaultAdminTransfer(PAUSER);

    assertEq(s_operatorStakingPool.hasRole(s_operatorStakingPool.DEFAULT_ADMIN_ROLE(), OWNER), true);
    assertEq(s_operatorStakingPool.defaultAdmin(), OWNER);
    (address pendingDefaultAdmin, uint48 schedule) = s_operatorStakingPool.pendingDefaultAdmin();
    assertEq(pendingDefaultAdmin, newAdmin);
    assertEq(schedule, newSchedule);
  }

  function test_RevertWhen_NonAdminCancelPendingDefaultAdminTransfer() public {
    changePrank(OWNER);
    s_operatorStakingPool.beginDefaultAdminTransfer(NEW_OWNER);

    changePrank(NEW_OWNER);
    vm.expectRevert(
      _getExpectedMissingRoleErrorMessage(NEW_OWNER, s_operatorStakingPool.DEFAULT_ADMIN_ROLE())
    );
    s_operatorStakingPool.cancelDefaultAdminTransfer();
  }

  function test_CurrentAdminCanCancelPendingDefaultAdminTransfer() public {
    changePrank(OWNER);
    s_operatorStakingPool.beginDefaultAdminTransfer(NEW_OWNER);

    vm.expectEmit(true, true, true, true, address(s_operatorStakingPool));
    emit DefaultAdminTransferCanceled();
    s_operatorStakingPool.cancelDefaultAdminTransfer();

    (address pendingDefaultAdmin, uint48 schedule) = s_operatorStakingPool.pendingDefaultAdmin();
    assertEq(pendingDefaultAdmin, address(0));
    assertEq(schedule, 0);
  }

  function test_RevertWhen_NonPendingDefaultAdminAcceptsTransfer() public {
    changePrank(OWNER);
    s_operatorStakingPool.beginDefaultAdminTransfer(NEW_OWNER);

    changePrank(STRANGER);
    vm.expectRevert('AccessControl: pending admin must accept');
    s_operatorStakingPool.acceptDefaultAdminTransfer();
  }

  function test_RevertWhen_PendingDefaultAdminAcceptsTransferBeforeDelayPassed() public {
    changePrank(OWNER);
    s_operatorStakingPool.changeDefaultAdminDelay(1 days);
    s_operatorStakingPool.beginDefaultAdminTransfer(NEW_OWNER);

    changePrank(NEW_OWNER);
    vm.expectRevert('AccessControl: transfer delay not passed');
    s_operatorStakingPool.acceptDefaultAdminTransfer();
  }

  function test_PendingDefaultAdminCanAcceptTransferImmediatelyIfDelayIsZero() public {
    changePrank(OWNER);
    s_operatorStakingPool.beginDefaultAdminTransfer(NEW_OWNER);

    skip(1); // needs to satisfy: schedule < block.timestamp

    changePrank(NEW_OWNER);
    s_operatorStakingPool.acceptDefaultAdminTransfer();

    assertEq(
      s_operatorStakingPool.hasRole(s_operatorStakingPool.DEFAULT_ADMIN_ROLE(), OWNER), false
    );
    assertEq(
      s_operatorStakingPool.hasRole(s_operatorStakingPool.DEFAULT_ADMIN_ROLE(), NEW_OWNER), true
    );
    assertEq(s_operatorStakingPool.defaultAdmin(), NEW_OWNER);
    (address pendingDefaultAdmin, uint48 schedule) = s_operatorStakingPool.pendingDefaultAdmin();
    assertEq(pendingDefaultAdmin, address(0));
    assertEq(schedule, 0);
  }

  function test_PendingDefaultAdminCanAcceptTransferAfterDelayPassed() public {
    changePrank(OWNER);
    s_operatorStakingPool.changeDefaultAdminDelay(30 days);
    s_operatorStakingPool.beginDefaultAdminTransfer(NEW_OWNER);

    skip(30 days);

    changePrank(NEW_OWNER);
    s_operatorStakingPool.acceptDefaultAdminTransfer();

    assertEq(
      s_operatorStakingPool.hasRole(s_operatorStakingPool.DEFAULT_ADMIN_ROLE(), OWNER), false
    );
    assertEq(
      s_operatorStakingPool.hasRole(s_operatorStakingPool.DEFAULT_ADMIN_ROLE(), NEW_OWNER), true
    );
    assertEq(s_operatorStakingPool.defaultAdmin(), NEW_OWNER);
    (address pendingDefaultAdmin, uint48 schedule) = s_operatorStakingPool.pendingDefaultAdmin();
    assertEq(pendingDefaultAdmin, address(0));
    assertEq(schedule, 0);
  }

  function test_RevertWhen_NonAdminChangesDelay() public {
    changePrank(NEW_OWNER);
    vm.expectRevert(
      _getExpectedMissingRoleErrorMessage(NEW_OWNER, s_operatorStakingPool.DEFAULT_ADMIN_ROLE())
    );
    s_operatorStakingPool.changeDefaultAdminDelay(30 days);
  }

  function test_CurrentAdminCanChangeDelay() public {
    changePrank(OWNER);
    uint48 newDelay = 30 days;
    uint48 newSchedule = SafeCast.toUint48(block.timestamp + 5 days);
    vm.expectEmit(true, true, true, true, address(s_operatorStakingPool));
    emit DefaultAdminDelayChangeScheduled(newDelay, newSchedule);
    s_operatorStakingPool.changeDefaultAdminDelay(newDelay);

    assertEq(s_operatorStakingPool.defaultAdminDelay(), 0);
    (uint48 pendingDelay, uint48 schedule) = s_operatorStakingPool.pendingDefaultAdminDelay();
    assertEq(pendingDelay, newDelay);
    assertEq(schedule, newSchedule);
  }

  function test_RevertWhen_NonAdminRollbackDelayChange() public {
    changePrank(OWNER);
    s_operatorStakingPool.changeDefaultAdminDelay(30 days);

    changePrank(NEW_OWNER);
    vm.expectRevert(
      _getExpectedMissingRoleErrorMessage(NEW_OWNER, s_operatorStakingPool.DEFAULT_ADMIN_ROLE())
    );
    s_operatorStakingPool.rollbackDefaultAdminDelay();
  }

  function test_CurrentAdminCanRollbackDelayChange() public {
    changePrank(OWNER);
    s_operatorStakingPool.changeDefaultAdminDelay(30 days);

    vm.expectEmit(true, true, true, true, address(s_operatorStakingPool));
    emit DefaultAdminDelayChangeCanceled();
    s_operatorStakingPool.rollbackDefaultAdminDelay();

    assertEq(s_operatorStakingPool.defaultAdminDelay(), 0);
    (uint48 pendingDelay, uint48 schedule) = s_operatorStakingPool.pendingDefaultAdminDelay();
    assertEq(pendingDelay, 0);
    assertEq(schedule, 0);
  }
}

contract OperatorStakingPool_SetClaimPeriod is
  IStakingPool_SetClaimPeriod,
  StakingPool_WithStakers
{
  event ClaimPeriodSet(uint256 oldClaimPeriod, uint256 claimPeriod);

  function test_RevertWhen_CalledByNonAdmin() public {
    changePrank(STRANGER);
    vm.expectRevert(
      _getExpectedMissingRoleErrorMessage(STRANGER, s_operatorStakingPool.DEFAULT_ADMIN_ROLE())
    );
    s_operatorStakingPool.setClaimPeriod(1 days);
  }

  function test_RevertWhen_ClaimPeriodIsZero() public {
    changePrank(OWNER);
    vm.expectRevert(StakingPoolBase.InvalidClaimPeriod.selector);
    s_operatorStakingPool.setClaimPeriod(0);
  }

  function test_RevertWhen_ClaimPeriodIsGreaterThanMax() public {
    changePrank(OWNER);
    vm.expectRevert(StakingPoolBase.InvalidClaimPeriod.selector);
    s_operatorStakingPool.setClaimPeriod(MAX_CLAIM_PERIOD + 1);
  }

  function test_RevertWhen_ClaimPeriodIsLessThanMin() public {
    changePrank(OWNER);
    vm.expectRevert(StakingPoolBase.InvalidClaimPeriod.selector);
    s_operatorStakingPool.setClaimPeriod(MIN_CLAIM_PERIOD - 1);
  }

  function test_UpdatesClaimPeriod() public {
    changePrank(OWNER);
    uint256 newClaimPeriod = MIN_CLAIM_PERIOD + 2 days;
    s_operatorStakingPool.setClaimPeriod(newClaimPeriod);
    (, uint256 claimPeriod) = s_operatorStakingPool.getUnbondingParams();
    assertEq(claimPeriod, newClaimPeriod);
  }

  function test_EmitsEvent() public {
    changePrank(OWNER);
    uint256 newClaimPeriod = MIN_CLAIM_PERIOD + 2 days;
    vm.expectEmit(true, true, true, true, address(s_operatorStakingPool));
    emit ClaimPeriodSet(CLAIM_PERIOD, newClaimPeriod);
    s_operatorStakingPool.setClaimPeriod(newClaimPeriod);
  }

  function test_DoesNotAffectStakersThatAreUnbonding() public {
    changePrank(OPERATOR_STAKER_ONE);
    s_operatorStakingPool.unbond();
    uint256 claimPeriodEndsAt = block.timestamp + UNBONDING_PERIOD + CLAIM_PERIOD;
    assertEq(s_operatorStakingPool.getClaimPeriodEndsAt(OPERATOR_STAKER_ONE), claimPeriodEndsAt);
    changePrank(OWNER);
    uint256 newClaimPeriod = MIN_CLAIM_PERIOD;
    assertTrue(newClaimPeriod != CLAIM_PERIOD);
    s_operatorStakingPool.setClaimPeriod(newClaimPeriod);
    assertEq(s_operatorStakingPool.getClaimPeriodEndsAt(OPERATOR_STAKER_ONE), claimPeriodEndsAt);
  }
}

contract OperatorStakingPool_isActive is StakingPool_WithStakers {
  function test_IsActiveWhenPoolIsOpenAndEmittingRewards() public {
    assertEq(s_operatorStakingPool.isOpen(), true);
    assertEq(s_operatorStakingPool.isActive(), true);
  }

  function test_IsNotActiveWhenPoolIsClosedAndEmittingRewards() public {
    changePrank(OWNER);
    s_operatorStakingPool.close();
    assertEq(s_operatorStakingPool.isActive(), false);
  }

  function test_IsActiveWhenPoolIsOpenAndPartiallyStoppedEmittingRewards() public {
    // add more rewards to the community staking pool so that the operator delegated reward bucket
    // has a longer duration than the base's
    changePrank(REWARDER);
    RewardVault.RewardBuckets memory buckets = s_rewardVault.getRewardBuckets();
    s_rewardVault.addReward(
      address(s_communityStakingPool), REWARD_AMOUNT, buckets.communityBase.emissionRate
    );
    buckets = s_rewardVault.getRewardBuckets();
    assertLt(
      buckets.operatorBase.rewardDurationEndsAt + 1, buckets.operatorDelegated.rewardDurationEndsAt
    );

    vm.warp(buckets.operatorBase.rewardDurationEndsAt + 1);
    assertEq(s_operatorStakingPool.isOpen(), true);
    assertEq(s_operatorStakingPool.isActive(), true);

    vm.warp(buckets.operatorDelegated.rewardDurationEndsAt + 1);
    assertEq(s_operatorStakingPool.isOpen(), true);
    assertEq(s_operatorStakingPool.isActive(), false);
  }

  function test_IsNotActiveWhenPoolIsOpenAndStoppedEmittingRewards() public {
    RewardVault.RewardBuckets memory buckets = s_rewardVault.getRewardBuckets();
    uint256 rewardDurationEndsAt = Math.max(
      buckets.operatorBase.rewardDurationEndsAt, buckets.operatorDelegated.rewardDurationEndsAt
    );
    vm.warp(rewardDurationEndsAt + 1);
    assertEq(s_operatorStakingPool.isOpen(), true);
    assertEq(s_operatorStakingPool.isActive(), false);
  }

  function test_IsNotActiveWhenPoolIsClosedAndStoppedEmittingRewards() public {
    changePrank(OWNER);
    RewardVault.RewardBuckets memory buckets = s_rewardVault.getRewardBuckets();
    uint256 rewardDurationEndsAt = buckets.operatorBase.rewardDurationEndsAt;
    vm.warp(rewardDurationEndsAt + 1);
    s_operatorStakingPool.close();
    assertEq(s_operatorStakingPool.isActive(), false);
  }
}
