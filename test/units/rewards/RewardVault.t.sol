// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {ERC677ReceiverInterface} from
  '@chainlink/contracts/src/v0.8/interfaces/ERC677ReceiverInterface.sol';
import {LinkTokenInterface} from '@chainlink/contracts/src/v0.8/interfaces/LinkTokenInterface.sol';
import {SafeCast} from '@openzeppelin/contracts/utils/math/SafeCast.sol';
import {IERC165} from '@openzeppelin/contracts/interfaces/IERC165.sol';
import {FixedPointMathLib} from '@solmate/utils/FixedPointMathLib.sol';
import {BaseTest} from '../../BaseTest.t.sol';
import {CommunityStakingPool} from '../../../src/pools/CommunityStakingPool.sol';
import {IAccessControlDefaultAdminRulesTest} from
  '../../interfaces/IAccessControlDefaultAdminRulesTest.t.sol';
import {IMigratable} from '../../../src/interfaces/IMigratable.sol';
import {IPausableTest} from '../../interfaces/IPausableTest.t.sol';
import {
  IRewardVault_GetMultiplier,
  IRewardVault_SetDelegationRateDenominator,
  IRewardVault_SetMultiplierDuration
} from '../../interfaces/IRewardVaultTest.t.sol';
import {IRewardVault} from '../../../src/interfaces/IRewardVault.sol';
import {OperatorStakingPool} from '../../../src/pools/OperatorStakingPool.sol';
import {RewardVault} from '../../../src/rewards/RewardVault.sol';
import {
  RewardVault_ConfigurablePoolSizes_DelegationDenominatorNotZero,
  RewardVault_DelegationDenominatorIsZero,
  RewardVault_WithoutStakersAndTimePassed,
  RewardVault_WithStakersAndTimeDidNotPass,
  RewardVault_WithStakersAndTimePassed,
  RewardVault_WithUpgradedVaultDeployedButNotMigrated
} from '../../base-scenarios/RewardVaultScenarios.t.sol';

// Use calculations based on amounts from
// https://www.notion.so/chainlink/Changing-Dynamic-Delegation-Rate-f80d702fd6e44b3282ca20e4c0f7e0b0
// this is different algorithm than the prod code, so we are correctly testing the algorithm
function getExpectedEmissionRates(
  uint256 stakeAmount,
  uint256 emissionRate,
  uint256 operatorDenominator,
  uint256 newDelegationRateDenominator
) pure returns (uint256, uint256) {
  uint256 rewardDuration = emissionRate == 0 ? 0 : stakeAmount / emissionRate;
  uint256 totalCommunityRewards = stakeAmount - (stakeAmount / operatorDenominator);

  uint256 delegatedRewards =
    newDelegationRateDenominator == 0 ? 0 : (totalCommunityRewards / newDelegationRateDenominator);
  uint256 expectedCommunityRewards = totalCommunityRewards - delegatedRewards;
  uint256 expectedCommunityEmissionRate =
    emissionRate == 0 ? 0 : expectedCommunityRewards / rewardDuration;
  uint256 expectedDelegatedEmissionRate = emissionRate == 0 ? 0 : delegatedRewards / rewardDuration;
  return (expectedDelegatedEmissionRate, expectedCommunityEmissionRate);
}

contract RewardVault_Constructor is BaseTest {
  function test_RevertWhen_LinkTokenAddressIsZero() public {
    vm.expectRevert(RewardVault.InvalidZeroAddress.selector);
    new RewardVault(
      RewardVault.ConstructorParams({
        linkToken: LinkTokenInterface(address(0)),
        communityStakingPool: s_communityStakingPool,
        operatorStakingPool: s_operatorStakingPool,
        delegationRateDenominator: DELEGATION_RATE_DENOMINATOR,
        initialMultiplierDuration: INITIAL_MULTIPLIER_DURATION,
        adminRoleTransferDelay: ADMIN_ROLE_TRANSFER_DELAY
      })
    );
  }

  function test_RevertWhen_communityPoolAddressIsZero() public {
    vm.expectRevert(RewardVault.InvalidZeroAddress.selector);
    new RewardVault(
      RewardVault.ConstructorParams({
        linkToken: s_LINK,
        communityStakingPool: CommunityStakingPool(address(0)),
        operatorStakingPool: s_operatorStakingPool,
        delegationRateDenominator: DELEGATION_RATE_DENOMINATOR,
        initialMultiplierDuration: INITIAL_MULTIPLIER_DURATION,
        adminRoleTransferDelay: ADMIN_ROLE_TRANSFER_DELAY
      })
    );
  }

  function test_RevertWhen_OPERATORPoolAddressIsZero() public {
    vm.expectRevert(RewardVault.InvalidZeroAddress.selector);
    new RewardVault(
      RewardVault.ConstructorParams({
        linkToken: s_LINK,
        communityStakingPool: s_communityStakingPool,
        operatorStakingPool: OperatorStakingPool(address(0)),
        delegationRateDenominator: DELEGATION_RATE_DENOMINATOR,
        initialMultiplierDuration: INITIAL_MULTIPLIER_DURATION,
        adminRoleTransferDelay: ADMIN_ROLE_TRANSFER_DELAY
      })
    );
  }

  function test_InitializesDelegationRateDenominator() public {
    RewardVault rewardVault = new RewardVault(
      RewardVault.ConstructorParams({
        linkToken: s_LINK,
        communityStakingPool: s_communityStakingPool,
        operatorStakingPool: s_operatorStakingPool,
        delegationRateDenominator: DELEGATION_RATE_DENOMINATOR,
        initialMultiplierDuration: INITIAL_MULTIPLIER_DURATION,
        adminRoleTransferDelay: ADMIN_ROLE_TRANSFER_DELAY
      })
    );
    assertEq(rewardVault.getDelegationRateDenominator(), DELEGATION_RATE_DENOMINATOR);
  }

  function test_InitializesMultiplierDuration() public {
    RewardVault rewardVault = new RewardVault(
      RewardVault.ConstructorParams({
        linkToken: s_LINK,
        communityStakingPool: s_communityStakingPool,
        operatorStakingPool: s_operatorStakingPool,
        delegationRateDenominator: DELEGATION_RATE_DENOMINATOR,
        initialMultiplierDuration: INITIAL_MULTIPLIER_DURATION,
        adminRoleTransferDelay: ADMIN_ROLE_TRANSFER_DELAY
      })
    );
    assertEq(rewardVault.getMultiplierDuration(), INITIAL_MULTIPLIER_DURATION);
  }

  function test_CanSetMultiplierDurationToZero() public {
    new RewardVault(
      RewardVault.ConstructorParams({
        linkToken: s_LINK,
        communityStakingPool: s_communityStakingPool,
        operatorStakingPool: s_operatorStakingPool,
        delegationRateDenominator: DELEGATION_RATE_DENOMINATOR,
        initialMultiplierDuration: 0,
        adminRoleTransferDelay: ADMIN_ROLE_TRANSFER_DELAY
      })
    );
  }

  function test_InitializesRoles() public {
    assertEq(s_rewardVault.hasRole(s_rewardVault.DEFAULT_ADMIN_ROLE(), OWNER), true);
  }

  function test_TypeAndVersion() public {
    RewardVault rewardVault = new RewardVault(
      RewardVault.ConstructorParams({
        linkToken: s_LINK,
        communityStakingPool: s_communityStakingPool,
        operatorStakingPool: s_operatorStakingPool,
        delegationRateDenominator: DELEGATION_RATE_DENOMINATOR,
        initialMultiplierDuration: INITIAL_MULTIPLIER_DURATION,
        adminRoleTransferDelay: ADMIN_ROLE_TRANSFER_DELAY
      })
    );
    string memory typeAndVersion = rewardVault.typeAndVersion();
    assertEq(typeAndVersion, 'RewardVault 1.0.0');
  }
}

contract RewardVault_Roles is BaseTest {
  function test_GrantRewarderRole() public {
    changePrank(OWNER);
    s_rewardVault.grantRole(s_rewardVault.REWARDER_ROLE(), REWARDER);
    assertEq(s_rewardVault.hasRole(s_rewardVault.REWARDER_ROLE(), REWARDER), true);
  }

  function test_RevertWhen_NotRewarderAddReward() public {
    changePrank(STRANGER);
    vm.expectRevert(RewardVault.AccessForbidden.selector);
    s_rewardVault.addReward(address(0), REWARD_AMOUNT, EMISSION_RATE);
  }

  function test_RevertWhen_NotRewardUpdaterUpdateReward() public {
    changePrank(OWNER);
    vm.expectRevert(RewardVault.AccessForbidden.selector);
    s_rewardVault.updateReward(COMMUNITY_STAKER_ONE, COMMUNITY_MIN_PRINCIPAL);
  }

  function test_RevertWhen_NotRewardUpdaterFinalizeReward() public {
    changePrank(OWNER);
    vm.expectRevert(RewardVault.AccessForbidden.selector);
    s_rewardVault.finalizeReward({
      staker: COMMUNITY_STAKER_ONE,
      oldPrincipal: uint112(COMMUNITY_MIN_PRINCIPAL),
      unstakedAmount: 0,
      shouldClaim: false,
      stakedAt: 0
    });
  }
}

contract RewardVault_SupportsInterface is BaseTest {
  function test_IsERC677Compatible() public {
    assertEq(
      s_rewardVault.supportsInterface(ERC677ReceiverInterface.onTokenTransfer.selector), true
    );
  }
}

contract RewardVault_SetDelegationRateDenominatorFromNotZero is
  IRewardVault_SetDelegationRateDenominator,
  RewardVault_ConfigurablePoolSizes_DelegationDenominatorNotZero
{
  event DelegationRateDenominatorSet(
    uint256 oldDelegationRateDenominator, uint256 newDelegationRateDenominator
  );

  function test_OwnerCanIncreaseDelegationRateDenominatorNoRewards() public {
    // default is 20
    uint256 newDelegationRateDenominator = 50;
    uint256 emissionRate = 0;
    uint256 operatorDenominator = 2;
    uint256 stakeAmount = 0;

    RewardVault.RewardBuckets memory bucketsBefore = s_rewardVault.getRewardBuckets();

    (uint256 expectedDelegatedEmissionRate, uint256 expectedCommunityEmissionRate) =
    getExpectedEmissionRates(
      stakeAmount, emissionRate, operatorDenominator, newDelegationRateDenominator
    );

    vm.expectEmit(true, true, true, true, address(s_rewardVault));
    emit DelegationRateDenominatorSet(DELEGATION_RATE_DENOMINATOR, newDelegationRateDenominator);
    changePrank(OWNER);
    s_rewardVault.setDelegationRateDenominator(newDelegationRateDenominator);
    assertEq(s_rewardVault.getDelegationRateDenominator(), newDelegationRateDenominator);

    RewardVault.RewardBuckets memory bucketsAfter = s_rewardVault.getRewardBuckets();
    assertEq(
      bucketsAfter.communityBase.rewardDurationEndsAt,
      bucketsBefore.communityBase.rewardDurationEndsAt
    );
    assertEq(
      bucketsAfter.operatorDelegated.rewardDurationEndsAt,
      bucketsBefore.operatorDelegated.rewardDurationEndsAt
    );
    assertEq(bucketsAfter.operatorDelegated.emissionRate, expectedDelegatedEmissionRate);
    assertEq(bucketsAfter.communityBase.emissionRate, expectedCommunityEmissionRate);
  }

  function test_OwnerCanIncreaseDelegationRateDenominator() public {
    // default is 20
    uint256 newDelegationRateDenominator = 50;
    uint256 emissionRate = 1 ether;
    uint256 operatorDenominator = 2;
    uint256 stakeAmount = STAKE_AMOUNT;
    changePrank(REWARDER);
    s_rewardVault.addReward(address(0), stakeAmount, emissionRate);

    RewardVault.RewardBuckets memory bucketsBefore = s_rewardVault.getRewardBuckets();

    (uint256 expectedDelegatedEmissionRate, uint256 expectedCommunityEmissionRate) =
    getExpectedEmissionRates(
      stakeAmount, emissionRate, operatorDenominator, newDelegationRateDenominator
    );

    vm.expectEmit(true, true, true, true, address(s_rewardVault));
    emit DelegationRateDenominatorSet(DELEGATION_RATE_DENOMINATOR, newDelegationRateDenominator);
    changePrank(OWNER);
    s_rewardVault.setDelegationRateDenominator(newDelegationRateDenominator);
    assertEq(s_rewardVault.getDelegationRateDenominator(), newDelegationRateDenominator);

    RewardVault.RewardBuckets memory bucketsAfter = s_rewardVault.getRewardBuckets();
    assertEq(
      bucketsAfter.communityBase.rewardDurationEndsAt,
      bucketsBefore.communityBase.rewardDurationEndsAt
    );
    assertEq(
      bucketsAfter.operatorDelegated.rewardDurationEndsAt,
      bucketsBefore.operatorDelegated.rewardDurationEndsAt
    );
    assertEq(bucketsAfter.operatorDelegated.emissionRate, expectedDelegatedEmissionRate);
    assertEq(bucketsAfter.communityBase.emissionRate, expectedCommunityEmissionRate);
  }

  function test_OwnerCanIncreaseDelegationRateDenominatorAfterRewardsEnded() public {
    // default is 20
    uint256 newDelegationRateDenominator = 50;
    uint256 emissionRate = 1 ether;
    uint256 operatorDenominator = 2;
    uint256 stakeAmount = STAKE_AMOUNT;
    changePrank(REWARDER);
    s_rewardVault.addReward(address(0), stakeAmount, emissionRate);

    RewardVault.RewardBuckets memory bucketsBefore = s_rewardVault.getRewardBuckets();

    (uint256 expectedDelegatedEmissionRate, uint256 expectedCommunityEmissionRate) =
    getExpectedEmissionRates(
      stakeAmount, emissionRate, operatorDenominator, newDelegationRateDenominator
    );

    vm.warp(bucketsBefore.communityBase.rewardDurationEndsAt + 1);

    vm.expectEmit(true, true, true, true, address(s_rewardVault));
    emit DelegationRateDenominatorSet(DELEGATION_RATE_DENOMINATOR, newDelegationRateDenominator);
    changePrank(OWNER);
    s_rewardVault.setDelegationRateDenominator(newDelegationRateDenominator);
    assertEq(s_rewardVault.getDelegationRateDenominator(), newDelegationRateDenominator);

    RewardVault.RewardBuckets memory bucketsAfter = s_rewardVault.getRewardBuckets();
    assertEq(
      bucketsAfter.communityBase.rewardDurationEndsAt,
      bucketsBefore.communityBase.rewardDurationEndsAt
    );
    assertEq(
      bucketsAfter.operatorDelegated.rewardDurationEndsAt,
      bucketsBefore.operatorDelegated.rewardDurationEndsAt
    );
    assertEq(bucketsAfter.operatorDelegated.emissionRate, expectedDelegatedEmissionRate);
    assertEq(bucketsAfter.communityBase.emissionRate, expectedCommunityEmissionRate);
  }

  function test_OwnerCanDecreaseDelegationRateDenominatorNoRewards() public {
    // default is 20
    uint256 newDelegationRateDenominator = 5;
    uint256 emissionRate = 0; // must be higher than denominator
    uint256 operatorDenominator = 2;
    uint256 stakeAmount = 0;

    RewardVault.RewardBuckets memory bucketsBefore = s_rewardVault.getRewardBuckets();

    (uint256 expectedDelegatedEmissionRate, uint256 expectedCommunityEmissionRate) =
    getExpectedEmissionRates(
      stakeAmount, emissionRate, operatorDenominator, newDelegationRateDenominator
    );

    vm.expectEmit(true, true, true, true, address(s_rewardVault));
    emit DelegationRateDenominatorSet(DELEGATION_RATE_DENOMINATOR, newDelegationRateDenominator);
    changePrank(OWNER);
    s_rewardVault.setDelegationRateDenominator(newDelegationRateDenominator);
    assertEq(s_rewardVault.getDelegationRateDenominator(), newDelegationRateDenominator);

    RewardVault.RewardBuckets memory bucketsAfter = s_rewardVault.getRewardBuckets();
    assertEq(
      bucketsAfter.communityBase.rewardDurationEndsAt,
      bucketsBefore.communityBase.rewardDurationEndsAt
    );
    assertEq(
      bucketsAfter.operatorDelegated.rewardDurationEndsAt,
      bucketsBefore.operatorDelegated.rewardDurationEndsAt
    );
    assertEq(bucketsAfter.operatorDelegated.emissionRate, expectedDelegatedEmissionRate);
    assertEq(bucketsAfter.communityBase.emissionRate, expectedCommunityEmissionRate);
  }

  function test_OwnerCanDecreaseDelegationRateDenominator() public {
    // default is 20
    uint256 newDelegationRateDenominator = 5;
    uint256 emissionRate = 1 ether; // must be higher than denominator
    uint256 operatorDenominator = 2;
    changePrank(REWARDER);
    s_rewardVault.addReward(address(0), STAKE_AMOUNT, emissionRate);

    RewardVault.RewardBuckets memory bucketsBefore = s_rewardVault.getRewardBuckets();

    (uint256 expectedDelegatedEmissionRate, uint256 expectedCommunityEmissionRate) =
    getExpectedEmissionRates(
      STAKE_AMOUNT, emissionRate, operatorDenominator, newDelegationRateDenominator
    );

    vm.expectEmit(true, true, true, true, address(s_rewardVault));
    emit DelegationRateDenominatorSet(DELEGATION_RATE_DENOMINATOR, newDelegationRateDenominator);
    changePrank(OWNER);
    s_rewardVault.setDelegationRateDenominator(newDelegationRateDenominator);
    assertEq(s_rewardVault.getDelegationRateDenominator(), newDelegationRateDenominator);

    RewardVault.RewardBuckets memory bucketsAfter = s_rewardVault.getRewardBuckets();
    assertEq(
      bucketsAfter.communityBase.rewardDurationEndsAt,
      bucketsBefore.communityBase.rewardDurationEndsAt
    );
    assertEq(
      bucketsAfter.operatorDelegated.rewardDurationEndsAt,
      bucketsBefore.operatorDelegated.rewardDurationEndsAt
    );
    assertEq(bucketsAfter.operatorDelegated.emissionRate, expectedDelegatedEmissionRate);
    assertEq(bucketsAfter.communityBase.emissionRate, expectedCommunityEmissionRate);
  }

  function test_OwnerCanSetDelegationRateDenominatorToZero() public {
    // default is 20
    uint256 emissionRate = 1 ether; // must be higher than denominator
    uint256 operatorDenominator = 2;
    uint256 newDelegationRateDenominator = 0;
    changePrank(REWARDER);
    s_rewardVault.addReward(address(0), STAKE_AMOUNT, emissionRate);
    RewardVault.RewardBuckets memory bucketsBefore = s_rewardVault.getRewardBuckets();

    (uint256 expectedDelegatedEmissionRate, uint256 expectedCommunityEmissionRate) =
    getExpectedEmissionRates(
      STAKE_AMOUNT, emissionRate, operatorDenominator, newDelegationRateDenominator
    );

    changePrank(OWNER);

    s_rewardVault.setDelegationRateDenominator(newDelegationRateDenominator);
    assertEq(s_rewardVault.getDelegationRateDenominator(), newDelegationRateDenominator);

    RewardVault.RewardBuckets memory bucketsAfter = s_rewardVault.getRewardBuckets();
    assertEq(
      bucketsAfter.communityBase.rewardDurationEndsAt,
      bucketsBefore.communityBase.rewardDurationEndsAt
    );
    assertEq(bucketsAfter.operatorDelegated.rewardDurationEndsAt, 0);
    assertEq(bucketsAfter.operatorDelegated.emissionRate, expectedDelegatedEmissionRate);
    assertEq(bucketsAfter.communityBase.emissionRate, expectedCommunityEmissionRate);
  }

  function test_OwnerCanSetDelegationRateDenominatorToOne() public {
    // default is 20
    uint256 newDelegationRateDenominator = 1;
    uint256 emissionRate = 1 ether; // must be higher than denominator
    uint256 operatorDenominator = 2;
    changePrank(REWARDER);
    s_rewardVault.addReward(address(0), STAKE_AMOUNT, emissionRate);

    RewardVault.RewardBuckets memory bucketsBefore = s_rewardVault.getRewardBuckets();

    (uint256 expectedDelegatedEmissionRate, uint256 expectedCommunityEmissionRate) =
    getExpectedEmissionRates(
      STAKE_AMOUNT, emissionRate, operatorDenominator, newDelegationRateDenominator
    );

    vm.expectEmit(true, true, true, true, address(s_rewardVault));
    emit DelegationRateDenominatorSet(DELEGATION_RATE_DENOMINATOR, newDelegationRateDenominator);
    changePrank(OWNER);
    s_rewardVault.setDelegationRateDenominator(newDelegationRateDenominator);

    assertEq(s_rewardVault.getDelegationRateDenominator(), newDelegationRateDenominator);

    RewardVault.RewardBuckets memory bucketsAfter = s_rewardVault.getRewardBuckets();
    assertEq(bucketsAfter.communityBase.rewardDurationEndsAt, 0);

    assertEq(
      bucketsAfter.operatorDelegated.rewardDurationEndsAt,
      bucketsBefore.operatorDelegated.rewardDurationEndsAt
    );
    assertEq(bucketsAfter.operatorDelegated.emissionRate, expectedDelegatedEmissionRate);
    assertEq(bucketsAfter.communityBase.emissionRate, expectedCommunityEmissionRate);
  }

  function test_RevertWhen_SetDelegationRateDenominatorToSameRate() public {
    // default is 20
    uint256 emissionRate = 1 ether; // must be higher than denominator
    uint256 newDelegationRateDenominator = 20;
    changePrank(REWARDER);
    s_rewardVault.addReward(address(0), STAKE_AMOUNT, emissionRate);

    changePrank(OWNER);
    vm.expectRevert(RewardVault.InvalidDelegationRateDenominator.selector);
    s_rewardVault.setDelegationRateDenominator(newDelegationRateDenominator);
  }

  function test_RevertWhen_SetDelegationRateDenominatorToTooLargeValue() public {
    // default is 20
    uint256 emissionRate = 1 ether; // must be higher than denominator
    uint256 newDelegationRateDenominator = 2 ether;
    changePrank(REWARDER);
    s_rewardVault.addReward(address(0), STAKE_AMOUNT, emissionRate);

    changePrank(OWNER);
    vm.expectRevert(RewardVault.InsufficentRewardsForDelegationRate.selector);
    s_rewardVault.setDelegationRateDenominator(newDelegationRateDenominator);
  }

  function test_RevertWhen_RewardRemainingLessThanEmissionRate() public {
    // how to get reward remaining less than emission?
    // say emitting 1 ether (1 ether/second). How can rewards remaining be less than
    // so low emission to get close to denominator.
    // default is 20
    // emissionRate must be > 1e16;
    uint256 emissionRate = 1e17; // must be higher than denominator
    uint256 newDelegationRateDenominator = emissionRate * 2;
    uint256 stakeAmount = 1 ether;
    changePrank(REWARDER);
    s_rewardVault.addReward(address(0), stakeAmount, emissionRate);
    RewardVault.RewardBuckets memory bucketsBefore = s_rewardVault.getRewardBuckets();
    vm.warp(bucketsBefore.communityBase.rewardDurationEndsAt - 1);
    changePrank(OWNER);
    vm.expectRevert(RewardVault.InsufficentRewardsForDelegationRate.selector);
    s_rewardVault.setDelegationRateDenominator(newDelegationRateDenominator);
  }
}

contract RewardVault_SetDelegationRateDenominatorFromZero is
  IRewardVault_SetDelegationRateDenominator,
  RewardVault_DelegationDenominatorIsZero
{
  event DelegationRateDenominatorSet(
    uint256 oldDelegationRateDenominator, uint256 delegationRateDenominator
  );

  function test_RevertWhen_NotOwnerSetsDelegationRateDenominator() public {
    changePrank(STRANGER);
    vm.expectRevert(
      _getExpectedMissingRoleErrorMessage(STRANGER, s_rewardVault.DEFAULT_ADMIN_ROLE())
    );
    s_rewardVault.setDelegationRateDenominator(50);
  }

  function test_OwnerCanIncreaseDelegationRateDenominator() public {
    // default is 0
    uint256 emissionRate = 1 ether; // must be higher than denominator
    uint256 operatorDenominator =
      (OPERATOR_MAX_POOL_SIZE + COMMUNITY_MAX_POOL_SIZE) / OPERATOR_MAX_POOL_SIZE;
    uint256 newDelegationRateDenominator = 20;
    changePrank(REWARDER);
    s_rewardVault.addReward(address(0), STAKE_AMOUNT, emissionRate);
    RewardVault.RewardBuckets memory bucketsBefore = s_rewardVault.getRewardBuckets();

    (uint256 expectedDelegatedEmissionRate, uint256 expectedCommunityEmissionRate) =
    getExpectedEmissionRates(
      STAKE_AMOUNT, emissionRate, operatorDenominator, newDelegationRateDenominator
    );

    vm.expectEmit(true, true, true, true, address(s_rewardVault));
    emit DelegationRateDenominatorSet(0, newDelegationRateDenominator);
    changePrank(OWNER);

    s_rewardVault.setDelegationRateDenominator(newDelegationRateDenominator);
    assertEq(s_rewardVault.getDelegationRateDenominator(), newDelegationRateDenominator);

    RewardVault.RewardBuckets memory bucketsAfter = s_rewardVault.getRewardBuckets();
    assertEq(
      bucketsAfter.communityBase.rewardDurationEndsAt,
      bucketsBefore.communityBase.rewardDurationEndsAt
    );
    assertEq(bucketsAfter.operatorDelegated.rewardDurationEndsAt, 1001);
    assertEq(bucketsAfter.operatorDelegated.emissionRate, expectedDelegatedEmissionRate);
    assertEq(bucketsAfter.communityBase.emissionRate, expectedCommunityEmissionRate);
  }
}

contract RewardVault_SetDelegationRateDenominator_WhenThereAreStakers is
  RewardVault_WithStakersAndTimePassed
{
  function test_CommunityStakerEarnsCorrectAmountOfRewardsIfDelegatonRateChanged() public {
    uint256 expectedRewardBeforeDelegationRateDenominatorChange = _calculateStakerExpectedReward(
      COMMUNITY_MIN_PRINCIPAL,
      COMMUNITY_MIN_PRINCIPAL * 4,
      _calculateBucketVestedRewards(
        s_rewardVault.getRewardBuckets().communityBase, rewardAddedAt, block.timestamp
      )
    );
    changePrank(OWNER);
    s_rewardVault.setDelegationRateDenominator(10);
    uint256 timeDelegationRateDenominatorChanged = block.timestamp;
    skip(30 days);
    uint256 expectedRewardAfterDelegationRateDenominatorChange = _calculateStakerExpectedReward(
      COMMUNITY_MIN_PRINCIPAL,
      COMMUNITY_MIN_PRINCIPAL * 4,
      _calculateBucketVestedRewards(
        s_rewardVault.getRewardBuckets().communityBase,
        timeDelegationRateDenominatorChanged,
        block.timestamp
      )
    );
    uint256 multiplier =
      _calculateStakerMultiplier(s_stakedAtTime, block.timestamp, INITIAL_MULTIPLIER_DURATION);
    uint256 expectedReward = multiplier
      * (
        expectedRewardAfterDelegationRateDenominatorChange
          + expectedRewardBeforeDelegationRateDenominatorChange
      ) / FixedPointMathLib.WAD;
    assertEq(s_rewardVault.getReward(COMMUNITY_STAKER_ONE), expectedReward);
  }
}

contract RewardVault_SetDelegationRateDenominator_WhenTheDurationEndTimesAreDifferent is BaseTest {
  function test_OwnerCanSetDelegationRateDenominator() public {
    // make the rewardDurationEndsAt of communityBase and operatorDelegated buckets different.
    changePrank(REWARDER);
    s_rewardVault.addReward(address(0), REWARD_AMOUNT, EMISSION_RATE);
    s_rewardVault.addReward(address(s_communityStakingPool), REWARD_AMOUNT - 1, 1000000000000000);

    RewardVault.RewardBuckets memory bucketsBefore = s_rewardVault.getRewardBuckets();
    (,, uint256 unvestedCommunityBaseRewards, uint256 unvestedOperatorDelegatedRewards) =
      _getTotalUnvestedRewards(s_rewardVault);

    assertFalse(
      bucketsBefore.communityBase.rewardDurationEndsAt
        == bucketsBefore.operatorDelegated.rewardDurationEndsAt
    );

    changePrank(OWNER);
    uint256 newDelegationRateDenominator = 50;
    s_rewardVault.setDelegationRateDenominator(newDelegationRateDenominator);
    RewardVault.RewardBuckets memory bucketsAfter = s_rewardVault.getRewardBuckets();

    assertEq(s_rewardVault.getDelegationRateDenominator(), newDelegationRateDenominator);

    uint256 unvestedDelegatedRewards = (
      unvestedCommunityBaseRewards + unvestedOperatorDelegatedRewards
    ) / newDelegationRateDenominator;
    uint256 unvestedCommunityRewards =
      unvestedCommunityBaseRewards + unvestedOperatorDelegatedRewards - unvestedDelegatedRewards;
    uint256 expectedOperatorDelegatedEmissionRate = (
      bucketsBefore.communityBase.emissionRate + bucketsBefore.operatorDelegated.emissionRate
    ) / newDelegationRateDenominator;
    uint256 expectedCommunityBaseEmissionRate = bucketsBefore.communityBase.emissionRate
      + bucketsBefore.operatorDelegated.emissionRate - expectedOperatorDelegatedEmissionRate;
    assertEq(
      bucketsAfter.communityBase.rewardDurationEndsAt,
      block.timestamp + (unvestedCommunityRewards / expectedCommunityBaseEmissionRate)
    );
    assertEq(
      bucketsAfter.operatorDelegated.rewardDurationEndsAt,
      block.timestamp + (unvestedDelegatedRewards / expectedOperatorDelegatedEmissionRate)
    );
  }
}

contract RewardVault_FinalizeReward is RewardVault_WithStakersAndTimeDidNotPass {
  event RewardFinalized(address staker, bool shouldForfeit);
  event StakerRewardUpdated(
    address indexed staker,
    uint256 finalizedBaseReward,
    uint256 finalizedDelegatedReward,
    uint256 baseRewardPerToken,
    uint256 operatorDelegatedRewardPerToken,
    uint256 claimedBaseRewardsInPeriod
  );

  function setUp() public override {
    RewardVault_WithStakersAndTimeDidNotPass.setUp();

    changePrank(address(s_communityStakingPool));
    // update staker's stored reward
    s_rewardVault.updateReward(address(COMMUNITY_STAKER_ONE), COMMUNITY_MIN_PRINCIPAL);
  }

  function test_RevertWhen_CalledByNonValidPool() public {
    changePrank(STRANGER);
    vm.expectRevert(RewardVault.AccessForbidden.selector);
    s_rewardVault.finalizeReward({
      staker: COMMUNITY_STAKER_ONE,
      oldPrincipal: uint112(COMMUNITY_MIN_PRINCIPAL),
      unstakedAmount: 0,
      shouldClaim: false,
      stakedAt: 0
    });
  }

  function test_RevertWhen_ShouldClaimSetToTrueAndVaultIsPaused() public {
    changePrank(PAUSER);
    s_rewardVault.emergencyPause();

    changePrank(address(s_communityStakingPool));
    vm.expectRevert(RewardVault.CannotClaimRewardWhenPaused.selector);
    s_rewardVault.finalizeReward({
      staker: COMMUNITY_STAKER_ONE,
      oldPrincipal: uint112(COMMUNITY_MIN_PRINCIPAL),
      unstakedAmount: 0,
      shouldClaim: true,
      stakedAt: 0
    });
  }

  function test_SetsStoredRewardToTheUnclaimedRewardsIfIsForfeitingFalse() public {
    changePrank(address(s_communityStakingPool));

    assertGt(s_rewardVault.getStoredReward(COMMUNITY_STAKER_ONE).storedBaseReward, 0);

    uint256 fullReward = _calculateStakerExpectedReward(
      COMMUNITY_MIN_PRINCIPAL,
      4 * COMMUNITY_MIN_PRINCIPAL,
      _calculateBucketVestedRewards(
        s_rewardVault.getRewardBuckets().communityBase, s_stakedAtTime, block.timestamp
      )
    );
    uint256 multiplier =
      _calculateStakerMultiplier(s_stakedAtTime, block.timestamp, INITIAL_MULTIPLIER_DURATION);

    uint256 unclaimableRewards = fullReward - multiplier * fullReward / FixedPointMathLib.WAD;
    uint256 expectedReward = s_rewardVault.getReward(COMMUNITY_STAKER_ONE);
    uint256 rewardPerTokenUpdatedAtBefore = s_rewardVault.getRewardPerTokenUpdatedAt();
    uint256 communityTotalPrincipalBefore = s_communityStakingPool.getTotalPrincipal();
    uint256 expectedCommunityBaseRewardPerToken = _calculateVestedRewardPerToken(
      s_rewardVault.getRewardBuckets().communityBase.vestedRewardPerToken,
      s_rewardVault.getRewardBuckets().communityBase.rewardDurationEndsAt,
      rewardPerTokenUpdatedAtBefore,
      s_rewardVault.getRewardBuckets().communityBase.emissionRate,
      communityTotalPrincipalBefore,
      block.timestamp
    );

    vm.expectEmit(true, true, true, true, address(s_rewardVault));
    emit RewardFinalized(COMMUNITY_STAKER_ONE, false);
    vm.expectEmit(true, true, true, true, address(s_rewardVault));
    emit StakerRewardUpdated(
      COMMUNITY_STAKER_ONE, expectedReward, 0, expectedCommunityBaseRewardPerToken, 0, 0
    );

    s_rewardVault.finalizeReward({
      staker: COMMUNITY_STAKER_ONE,
      oldPrincipal: uint112(COMMUNITY_MIN_PRINCIPAL),
      unstakedAmount: 0,
      shouldClaim: false,
      stakedAt: uint112(s_stakedAtTime)
    });

    assertEq(
      s_rewardVault.getStoredReward(COMMUNITY_STAKER_ONE).storedBaseReward, unclaimableRewards
    );
  }

  function test_SetsStoredRewardToTheRemainingUnclaimedRewardsIfUnstakingPartialAmount() public {
    changePrank(address(s_communityStakingPool));

    assertGt(s_rewardVault.getStoredReward(COMMUNITY_STAKER_ONE).storedBaseReward, 0);

    s_rewardVault.finalizeReward({
      staker: COMMUNITY_STAKER_ONE,
      oldPrincipal: uint112(COMMUNITY_MIN_PRINCIPAL),
      unstakedAmount: COMMUNITY_MIN_PRINCIPAL / 2,
      shouldClaim: false,
      stakedAt: uint112(s_stakedAtTime)
    });

    uint256 fullReward = _calculateStakerExpectedReward(
      COMMUNITY_MIN_PRINCIPAL,
      4 * COMMUNITY_MIN_PRINCIPAL,
      _calculateBucketVestedRewards(
        s_rewardVault.getRewardBuckets().communityBase, s_stakedAtTime, block.timestamp
      )
    );
    uint256 multiplier =
      _calculateStakerMultiplier(s_stakedAtTime, block.timestamp, INITIAL_MULTIPLIER_DURATION);

    uint256 forfeitedRewards = fullReward - multiplier * fullReward / FixedPointMathLib.WAD;

    // Staker unstaked half so the the other half should be stored in the stored reward
    assertEq(
      s_rewardVault.getStoredReward(COMMUNITY_STAKER_ONE).storedBaseReward, forfeitedRewards / 2
    );
  }

  function test_SetsStoredRewardToZeroIfIsUnstakingFullAmount() public {
    changePrank(address(s_communityStakingPool));

    assertGt(s_rewardVault.getStoredReward(COMMUNITY_STAKER_ONE).storedBaseReward, 0);

    s_rewardVault.finalizeReward({
      staker: COMMUNITY_STAKER_ONE,
      oldPrincipal: uint112(COMMUNITY_MIN_PRINCIPAL),
      unstakedAmount: COMMUNITY_MIN_PRINCIPAL,
      shouldClaim: false,
      stakedAt: 0
    });

    assertEq(s_rewardVault.getStoredReward(COMMUNITY_STAKER_ONE).storedBaseReward, 0);
  }

  //TODO:  Add test to ensure that stored amount is correctly set when partially unstaking

  function test_UpdatesStakerFinalizedReward() public {
    changePrank(address(s_communityStakingPool));

    assertEq(s_rewardVault.getStoredReward(COMMUNITY_STAKER_ONE).finalizedBaseReward, 0);
    uint256 expectedReward = s_rewardVault.getReward(COMMUNITY_STAKER_ONE);

    s_rewardVault.finalizeReward({
      staker: COMMUNITY_STAKER_ONE,
      oldPrincipal: uint112(COMMUNITY_MIN_PRINCIPAL),
      unstakedAmount: 0,
      shouldClaim: false,
      stakedAt: uint112(s_stakedAtTime)
    });
    assertEq(
      s_rewardVault.getStoredReward(COMMUNITY_STAKER_ONE).finalizedBaseReward, expectedReward
    );
    assertEq(s_rewardVault.getStoredReward(COMMUNITY_STAKER_ONE).finalizedDelegatedReward, 0);
  }
}

contract RewardVault_Close is RewardVault_WithStakersAndTimePassed {
  event VaultClosed(uint256 totalUnvestedRewards);

  function test_InitializedAsOpen() public {
    assertEq(s_rewardVault.isOpen(), true);
  }

  function test_RevertWhen_NotOwnerCloses() public {
    changePrank(STRANGER);
    vm.expectRevert(
      _getExpectedMissingRoleErrorMessage(STRANGER, s_rewardVault.DEFAULT_ADMIN_ROLE())
    );
    s_rewardVault.close();
  }

  function test_OwnerCanClose() public {
    changePrank(OWNER);
    assertEq(s_rewardVault.hasRewardDurationEnded(address(s_operatorStakingPool)), false);
    assertEq(s_rewardVault.hasRewardDurationEnded(address(s_communityStakingPool)), false);
    (
      uint256 unvestedCommunityBaseRewards,
      uint256 unvestedOperatorBaseRewards,
      uint256 unvestedOperatorDelegatedRewards
    ) = s_rewardVault.getUnvestedRewards();
    uint256 unvestedRewards =
      unvestedCommunityBaseRewards + unvestedOperatorBaseRewards + unvestedOperatorDelegatedRewards;
    vm.expectEmit(true, true, true, true, address(s_rewardVault));
    emit VaultClosed(unvestedRewards);
    s_rewardVault.close();
    assertEq(s_rewardVault.isOpen(), false);
    assertEq(s_rewardVault.hasRewardDurationEnded(address(s_operatorStakingPool)), true);
    assertEq(s_rewardVault.hasRewardDurationEnded(address(s_communityStakingPool)), true);
  }

  function test_RevertWhen_PoolAlreadyClosed() public {
    changePrank(OWNER);
    s_rewardVault.close();
    vm.expectRevert(RewardVault.VaultAlreadyClosed.selector);
    s_rewardVault.close();
  }

  function test_CommunityRewardsStopVesting() public {
    (RewardVault.StakerReward memory stakerRewardsBefore, uint256 forfeitedRewardsBefore) =
      s_rewardVault.calculateLatestStakerReward(COMMUNITY_STAKER_ONE);
    changePrank(OWNER);
    s_rewardVault.close();
    skip(30 days);
    uint256 multiplier = s_rewardVault.getMultiplier(COMMUNITY_STAKER_ONE);
    (RewardVault.StakerReward memory stakerRewardsAfter, uint256 forfeitedRewardsAfter) =
      s_rewardVault.calculateLatestStakerReward(COMMUNITY_STAKER_ONE);
    assertEq(
      s_rewardVault.getReward(COMMUNITY_STAKER_ONE),
      (stakerRewardsBefore.finalizedBaseReward + forfeitedRewardsBefore) * multiplier
        / FixedPointMathLib.WAD
    );
    assertEq(
      stakerRewardsAfter.finalizedBaseReward + forfeitedRewardsAfter,
      stakerRewardsBefore.finalizedBaseReward + forfeitedRewardsBefore
    );
  }

  function test_OperatorRewardsStopVesting() public {
    (RewardVault.StakerReward memory stakerRewardsBefore, uint256 forfeitedRewardsBefore) =
      s_rewardVault.calculateLatestStakerReward(OPERATOR_STAKER_ONE);
    changePrank(OWNER);
    s_rewardVault.close();
    skip(30 days);
    uint256 multiplier = s_rewardVault.getMultiplier(OPERATOR_STAKER_ONE);
    (RewardVault.StakerReward memory stakerRewardsAfter, uint256 forfeitedRewardsAfter) =
      s_rewardVault.calculateLatestStakerReward(OPERATOR_STAKER_ONE);
    assertEq(
      s_rewardVault.getReward(OPERATOR_STAKER_ONE),
      stakerRewardsBefore.finalizedDelegatedReward
        + (stakerRewardsBefore.finalizedBaseReward + forfeitedRewardsBefore) * multiplier
          / FixedPointMathLib.WAD
    );
    assertEq(
      stakerRewardsAfter.finalizedDelegatedReward, stakerRewardsBefore.finalizedDelegatedReward
    );
    assertEq(
      stakerRewardsAfter.finalizedBaseReward + stakerRewardsAfter.finalizedDelegatedReward
        + forfeitedRewardsAfter,
      stakerRewardsBefore.finalizedBaseReward + stakerRewardsBefore.finalizedDelegatedReward
        + forfeitedRewardsBefore
    );
  }
}

contract RewardVault_Close_WhenPoolsHaveStakers is RewardVault_WithStakersAndTimePassed {
  uint256 private constant TIME_AFTER_VAULT_CLOSED = 30 days;

  function test_CommunityRewardsStopVesting() public {
    uint256 stakerPrincipal = s_communityStakingPool.getStakerPrincipal(COMMUNITY_STAKER_ONE);
    uint256 totalPrincipal = s_communityStakingPool.getTotalPrincipal();
    uint256 baseEmissionRate = s_rewardVault.getRewardBuckets().communityBase.emissionRate;

    changePrank(OWNER);
    s_rewardVault.close();
    uint256 elapsedTime = block.timestamp - s_stakedAtTime;

    skip(TIME_AFTER_VAULT_CLOSED);

    uint256 multiplier = s_rewardVault.getMultiplier(COMMUNITY_STAKER_ONE);
    uint256 earnedBaseReward = stakerPrincipal * baseEmissionRate * elapsedTime / totalPrincipal;
    uint256 expectedReward = earnedBaseReward * multiplier / FixedPointMathLib.WAD;

    assertEq(s_rewardVault.getReward(COMMUNITY_STAKER_ONE), expectedReward);
  }

  function test_OperatorRewardsStopVesting() public {
    uint256 stakerPrincipal = s_operatorStakingPool.getStakerPrincipal(OPERATOR_STAKER_ONE);
    uint256 totalPrincipal = s_operatorStakingPool.getTotalPrincipal();
    uint256 baseEmissionRate = s_rewardVault.getRewardBuckets().operatorBase.emissionRate;
    uint256 delegatedEmissionRate = s_rewardVault.getRewardBuckets().operatorDelegated.emissionRate;

    changePrank(OWNER);
    s_rewardVault.close();
    uint256 elapsedTime = block.timestamp - s_stakedAtTime;

    skip(TIME_AFTER_VAULT_CLOSED);

    uint256 multiplier = s_rewardVault.getMultiplier(OPERATOR_STAKER_ONE);
    uint256 earnedBaseReward = stakerPrincipal * baseEmissionRate * elapsedTime / totalPrincipal;
    uint256 earnedDelegatedReward =
      stakerPrincipal * delegatedEmissionRate * elapsedTime / totalPrincipal;
    uint256 expectedReward =
      (earnedBaseReward * multiplier / FixedPointMathLib.WAD) + earnedDelegatedReward;

    assertEq(s_rewardVault.getReward(OPERATOR_STAKER_ONE), expectedReward);
  }

  function test_WithdrawsUnvestedRewards() public {
    RewardVault.RewardBuckets memory rewardBuckets = s_rewardVault.getRewardBuckets();
    RewardVault.RewardBucket memory operatorBaseBucket = rewardBuckets.operatorBase;
    uint256 unvestedOperatorBaseRewards =
      operatorBaseBucket.emissionRate * (operatorBaseBucket.rewardDurationEndsAt - block.timestamp);
    RewardVault.RewardBucket memory operatorDelegateBucket = rewardBuckets.operatorDelegated;
    uint256 unvestedOperatorDelegatedRewards = operatorDelegateBucket.emissionRate
      * (operatorDelegateBucket.rewardDurationEndsAt - block.timestamp);
    RewardVault.RewardBucket memory communityBaseBucket = rewardBuckets.communityBase;
    uint256 unvestedCommunityBaseRewards = communityBaseBucket.emissionRate
      * (communityBaseBucket.rewardDurationEndsAt - block.timestamp);
    uint256 totalUnvestedRewards =
      unvestedOperatorBaseRewards + unvestedCommunityBaseRewards + unvestedOperatorDelegatedRewards;

    uint256 ownerBalanceBefore = s_LINK.balanceOf(OWNER);
    changePrank(OWNER);
    s_rewardVault.close();
    assertEq(s_LINK.balanceOf(OWNER), ownerBalanceBefore + totalUnvestedRewards);
  }
}

contract RewardVault_SetMultiplierDuration is
  IRewardVault_SetMultiplierDuration,
  RewardVault_WithStakersAndTimePassed
{
  event MultiplierDurationSet(uint256 oldMultiplierDuration, uint256 newMultiplierDuration);

  function test_RevertWhen_CalledByNonAdmin() public {
    vm.expectRevert(
      _getExpectedMissingRoleErrorMessage(STRANGER, s_rewardVault.DEFAULT_ADMIN_ROLE())
    );
    changePrank(STRANGER);
    s_rewardVault.setMultiplierDuration(INITIAL_MULTIPLIER_DURATION * 2);
  }

  function test_UpdatesMultiplierDuration() public {
    changePrank(OWNER);
    uint256 newMultiplierDuration = INITIAL_MULTIPLIER_DURATION * 2;
    s_rewardVault.setMultiplierDuration(newMultiplierDuration);
    assertEq(s_rewardVault.getMultiplierDuration(), newMultiplierDuration);
  }

  function test_UpdatesStakerReward() public {
    changePrank(OWNER);
    uint256 rewardBefore = s_rewardVault.getReward(COMMUNITY_STAKER_ONE);
    uint256 newMultiplierDuration = INITIAL_MULTIPLIER_DURATION / 2;
    s_rewardVault.setMultiplierDuration(newMultiplierDuration);
    assertEq(s_rewardVault.getReward(COMMUNITY_STAKER_ONE), rewardBefore * 2);
  }

  function test_DoesNotAffectFinalizedRewards() public {
    changePrank(OWNER);
    uint256 finalizedRewardBefore =
      s_rewardVault.getStoredReward(COMMUNITY_STAKER_ONE).finalizedBaseReward;
    s_rewardVault.setMultiplierDuration(INITIAL_MULTIPLIER_DURATION * 2);
    assertEq(
      s_rewardVault.getStoredReward(COMMUNITY_STAKER_ONE).finalizedBaseReward, finalizedRewardBefore
    );
  }

  function test_EmitsEvent() public {
    changePrank(OWNER);
    uint256 oldMultiplierDuration = s_rewardVault.getMultiplierDuration();
    uint256 newMultiplierDuration = INITIAL_MULTIPLIER_DURATION * 2;
    vm.expectEmit(true, true, true, true, address(s_rewardVault));
    emit MultiplierDurationSet(oldMultiplierDuration, newMultiplierDuration);
    s_rewardVault.setMultiplierDuration(newMultiplierDuration);
  }

  function test_CanSetMultiplierDurationToZero() public {
    changePrank(OWNER);
    s_rewardVault.setMultiplierDuration(0);
    assertEq(s_rewardVault.getMultiplierDuration(), 0);
  }
}

contract RewardVault_GetMultiplier is
  IRewardVault_GetMultiplier,
  RewardVault_WithoutStakersAndTimePassed
{
  function test_ReturnsZeroWhenStakerNotStaked() public {
    assertEq(s_rewardVault.getMultiplier(COMMUNITY_STAKER_ONE), 0);
  }

  function test_ReturnsZeroWhenStakerStakedAndNoTimePassed() public {
    changePrank(COMMUNITY_STAKER_ONE);
    s_LINK.transferAndCall(
      address(s_communityStakingPool),
      COMMUNITY_MIN_PRINCIPAL,
      abi.encode(s_communityStakerOneProof)
    );

    assertEq(s_rewardVault.getMultiplier(COMMUNITY_STAKER_ONE), 0);
  }

  function test_ReturnsCorrectValueWhenStakerStakedAndTimePassed() public {
    changePrank(COMMUNITY_STAKER_ONE);
    // first stake
    s_LINK.transferAndCall(
      address(s_communityStakingPool),
      COMMUNITY_MIN_PRINCIPAL,
      abi.encode(s_communityStakerOneProof)
    );

    // time passed
    uint256 elapsedTime = 100;
    vm.warp(block.timestamp + elapsedTime);

    uint256 multiplierDuration = s_rewardVault.getMultiplierDuration();
    uint256 expectedMultiplier = elapsedTime * FixedPointMathLib.WAD / multiplierDuration;
    assertEq(s_rewardVault.getMultiplier(COMMUNITY_STAKER_ONE), expectedMultiplier);
  }

  function test_ReducesMultiplierWhenStakerStakedAgain() public {
    changePrank(COMMUNITY_STAKER_ONE);

    s_LINK.transferAndCall(
      address(s_communityStakingPool),
      COMMUNITY_MIN_PRINCIPAL,
      abi.encode(s_communityStakerOneProof)
    );

    // time passed
    uint256 elapsedTime = 100;
    vm.warp(block.timestamp + elapsedTime);

    // second stake
    s_LINK.transferAndCall(
      address(s_communityStakingPool),
      COMMUNITY_MIN_PRINCIPAL,
      abi.encode(s_communityStakerOneProof)
    );

    assertEq(s_rewardVault.getMultiplier(COMMUNITY_STAKER_ONE), 0);
  }

  function test_ReturnsMaxValueWhenStakerStakedForFullMultiplierDuration() public {
    changePrank(COMMUNITY_STAKER_ONE);
    s_LINK.transferAndCall(
      address(s_communityStakingPool),
      COMMUNITY_MIN_PRINCIPAL,
      abi.encode(s_communityStakerOneProof)
    );

    vm.warp(block.timestamp + INITIAL_MULTIPLIER_DURATION);

    assertEq(s_rewardVault.getMultiplier(COMMUNITY_STAKER_ONE), MAX_MULTIPLIER);
  }

  function test_DoesNotChangeWhenStakerClaimsReward() public {
    changePrank(COMMUNITY_STAKER_ONE);
    s_LINK.transferAndCall(
      address(s_communityStakingPool),
      COMMUNITY_MIN_PRINCIPAL,
      abi.encode(s_communityStakerOneProof)
    );

    vm.warp(block.timestamp + INITIAL_MULTIPLIER_DURATION);

    s_rewardVault.claimReward();

    assertEq(s_rewardVault.getMultiplier(COMMUNITY_STAKER_ONE), MAX_MULTIPLIER);
  }

  function test_ReturnsZeroWhenStakerFullyUnstaked() public {
    changePrank(COMMUNITY_STAKER_ONE);
    s_LINK.transferAndCall(
      address(s_communityStakingPool),
      COMMUNITY_MIN_PRINCIPAL,
      abi.encode(s_communityStakerOneProof)
    );
    s_communityStakingPool.unbond();

    skip(UNBONDING_PERIOD);
    s_communityStakingPool.unstake(
      s_communityStakingPool.getStakerPrincipal(COMMUNITY_STAKER_ONE), false
    );
    assertEq(s_rewardVault.getMultiplier(COMMUNITY_STAKER_ONE), 0);
  }

  function test_DoesNotGrowAfterStakerFullyUnstaked() public {
    changePrank(COMMUNITY_STAKER_ONE);
    s_LINK.transferAndCall(
      address(s_communityStakingPool),
      COMMUNITY_MIN_PRINCIPAL,
      abi.encode(s_communityStakerOneProof)
    );
    s_communityStakingPool.unbond();

    skip(UNBONDING_PERIOD);
    s_communityStakingPool.unstake(
      s_communityStakingPool.getStakerPrincipal(COMMUNITY_STAKER_ONE), false
    );

    skip(10 days);
    assertEq(s_rewardVault.getMultiplier(COMMUNITY_STAKER_ONE), 0);
  }

  function test_ReturnsZeroWhenStakerStakedAgainAfterFullyUnstaked() public {
    changePrank(COMMUNITY_STAKER_ONE);
    s_LINK.transferAndCall(
      address(s_communityStakingPool),
      COMMUNITY_MIN_PRINCIPAL,
      abi.encode(s_communityStakerOneProof)
    );
    s_communityStakingPool.unbond();

    skip(UNBONDING_PERIOD);
    s_communityStakingPool.unstake(
      s_communityStakingPool.getStakerPrincipal(COMMUNITY_STAKER_ONE), false
    );

    s_LINK.transferAndCall(
      address(s_communityStakingPool),
      COMMUNITY_MIN_PRINCIPAL,
      abi.encode(s_communityStakerOneProof)
    );
    assertEq(s_rewardVault.getMultiplier(COMMUNITY_STAKER_ONE), 0);
  }

  function test_ReturnsCorrectValueWhenStakerStakedAgainAfterFullyUnstakedAndTimePassed() public {
    changePrank(COMMUNITY_STAKER_ONE);
    s_LINK.transferAndCall(
      address(s_communityStakingPool),
      COMMUNITY_MIN_PRINCIPAL,
      abi.encode(s_communityStakerOneProof)
    );
    s_communityStakingPool.unbond();

    skip(UNBONDING_PERIOD);
    s_communityStakingPool.unstake(
      s_communityStakingPool.getStakerPrincipal(COMMUNITY_STAKER_ONE), false
    );

    s_LINK.transferAndCall(
      address(s_communityStakingPool),
      COMMUNITY_MIN_PRINCIPAL,
      abi.encode(s_communityStakerOneProof)
    );
    assertEq(s_rewardVault.getMultiplier(COMMUNITY_STAKER_ONE), 0);

    // grows linearly as if it started from 0 at the time of staking
    skip(INITIAL_MULTIPLIER_DURATION / 2);
    assertEq(s_rewardVault.getMultiplier(COMMUNITY_STAKER_ONE), MAX_MULTIPLIER / 2);
  }

  function test_ReturnsZeroWhenStakerPartiallyUnstaked() public {
    changePrank(COMMUNITY_STAKER_ONE);
    s_LINK.transferAndCall(
      address(s_communityStakingPool),
      COMMUNITY_MIN_PRINCIPAL * 2,
      abi.encode(s_communityStakerOneProof)
    );
    s_communityStakingPool.unbond();

    skip(UNBONDING_PERIOD);
    s_communityStakingPool.unstake(COMMUNITY_MIN_PRINCIPAL, false);
    assertEq(s_rewardVault.getMultiplier(COMMUNITY_STAKER_ONE), 0);
  }

  function test_DoesGrowAfterStakerPartiallyUnstaked() public {
    changePrank(COMMUNITY_STAKER_ONE);
    s_LINK.transferAndCall(
      address(s_communityStakingPool),
      COMMUNITY_MIN_PRINCIPAL * 2,
      abi.encode(s_communityStakerOneProof)
    );
    s_communityStakingPool.unbond();

    skip(UNBONDING_PERIOD);
    s_communityStakingPool.unstake(COMMUNITY_MIN_PRINCIPAL, false);

    uint256 timeAfterUnstake = 90 days;
    uint256 expectedMultiplier = _calculateStakerMultiplier(
      block.timestamp, block.timestamp + timeAfterUnstake, INITIAL_MULTIPLIER_DURATION
    );

    skip(timeAfterUnstake);

    assertEq(s_rewardVault.getMultiplier(COMMUNITY_STAKER_ONE), expectedMultiplier);
  }

  function test_ReturnsCorrectValueWhenStakerStakedAgainAfterPartiallyUnstaked() public {
    changePrank(COMMUNITY_STAKER_ONE);
    s_LINK.transferAndCall(
      address(s_communityStakingPool),
      COMMUNITY_MIN_PRINCIPAL * 2,
      abi.encode(s_communityStakerOneProof)
    );
    s_communityStakingPool.unbond();

    skip(UNBONDING_PERIOD);
    s_communityStakingPool.unstake(COMMUNITY_MIN_PRINCIPAL, false);

    s_LINK.transferAndCall(
      address(s_communityStakingPool),
      COMMUNITY_MIN_PRINCIPAL,
      abi.encode(s_communityStakerOneProof)
    );
    assertEq(s_rewardVault.getMultiplier(COMMUNITY_STAKER_ONE), 0);
  }

  function test_ReturnsCorrectValueWhenStakerStakedAgainAfterPartiallyUnstakedAndTimePassed()
    public
  {
    changePrank(COMMUNITY_STAKER_ONE);
    s_LINK.transferAndCall(
      address(s_communityStakingPool),
      COMMUNITY_MIN_PRINCIPAL * 2,
      abi.encode(s_communityStakerOneProof)
    );
    s_communityStakingPool.unbond();

    skip(UNBONDING_PERIOD);
    s_communityStakingPool.unstake(COMMUNITY_MIN_PRINCIPAL, false);

    s_LINK.transferAndCall(
      address(s_communityStakingPool),
      COMMUNITY_MIN_PRINCIPAL,
      abi.encode(s_communityStakerOneProof)
    );

    // grows linearly as if it started from 0 at the time of staking
    skip(INITIAL_MULTIPLIER_DURATION / 2);
    assertEq(s_rewardVault.getMultiplier(COMMUNITY_STAKER_ONE), MAX_MULTIPLIER / 2);
  }

  function test_ReturnsMaxValueWhenMultiplierDurationIsChangedToZero() public {
    changePrank(COMMUNITY_STAKER_ONE);
    s_LINK.transferAndCall(
      address(s_communityStakingPool),
      COMMUNITY_MIN_PRINCIPAL,
      abi.encode(s_communityStakerOneProof)
    );

    assertLt(s_rewardVault.getMultiplier(COMMUNITY_STAKER_ONE), MAX_MULTIPLIER);

    changePrank(OWNER);
    s_rewardVault.setMultiplierDuration(0);

    assertEq(s_rewardVault.getMultiplier(COMMUNITY_STAKER_ONE), MAX_MULTIPLIER);
  }

  function test_ReturnsCorrectValueWhenMultiplierDurationIsIncreased() public {
    changePrank(COMMUNITY_STAKER_ONE);
    // first stake
    s_LINK.transferAndCall(
      address(s_communityStakingPool),
      COMMUNITY_MIN_PRINCIPAL,
      abi.encode(s_communityStakerOneProof)
    );

    // time passed
    uint256 elapsedTime = 100;
    vm.warp(block.timestamp + elapsedTime);

    uint256 multiplierDuration = s_rewardVault.getMultiplierDuration();
    uint256 expectedMultiplierBeforeChange =
      elapsedTime * FixedPointMathLib.WAD / multiplierDuration;

    // multiplier duration doubled
    changePrank(OWNER);
    s_rewardVault.setMultiplierDuration(INITIAL_MULTIPLIER_DURATION * 2);

    // multiplier halved
    assertEq(s_rewardVault.getMultiplier(COMMUNITY_STAKER_ONE), expectedMultiplierBeforeChange / 2);
  }

  function test_ReturnsCorrectValueWhenMultiplierDurationIsDecreased() public {
    changePrank(COMMUNITY_STAKER_ONE);
    // first stake
    s_LINK.transferAndCall(
      address(s_communityStakingPool),
      COMMUNITY_MIN_PRINCIPAL,
      abi.encode(s_communityStakerOneProof)
    );

    // time passed
    uint256 elapsedTime = 100;
    vm.warp(block.timestamp + elapsedTime);

    uint256 multiplierDuration = s_rewardVault.getMultiplierDuration();

    // multiplier duration halved
    changePrank(OWNER);
    s_rewardVault.setMultiplierDuration(multiplierDuration / 2);

    // multiplier doubled
    assertEq(
      s_rewardVault.getMultiplier(COMMUNITY_STAKER_ONE),
      elapsedTime * FixedPointMathLib.WAD * 2 / multiplierDuration
    );
  }
}

contract RewardVault_SetMigrationTarget is RewardVault_WithUpgradedVaultDeployedButNotMigrated {
  event MigrationTargetSet(address indexed oldMigrationTarget, address indexed newMigrationTarget);

  function test_RevertWhen_CalledByNonOwner() public {
    changePrank(STRANGER);
    vm.expectRevert(
      _getExpectedMissingRoleErrorMessage(STRANGER, s_rewardVault.DEFAULT_ADMIN_ROLE())
    );
    s_rewardVault.setMigrationTarget(address(s_rewardVaultVersion2));
  }

  function test_RevertWhen_PassedInZeroAddress() public {
    changePrank(OWNER);
    vm.expectRevert(IMigratable.InvalidMigrationTarget.selector);
    s_rewardVault.setMigrationTarget(address(0));
  }

  function test_RevertWhen_PassedInOwnAddress() public {
    changePrank(OWNER);
    vm.expectRevert(IMigratable.InvalidMigrationTarget.selector);
    s_rewardVault.setMigrationTarget(address(s_rewardVault));
  }

  function test_RevertWhen_PassedInTheSameMigrationTarget() public {
    changePrank(OWNER);
    s_rewardVault.setMigrationTarget(address(s_rewardVaultVersion2));
    vm.expectRevert(IMigratable.InvalidMigrationTarget.selector);
    s_rewardVault.setMigrationTarget(address(s_rewardVaultVersion2));
  }

  function test_RevertWhen_PassedInAnAddressThatIsNotERC677Compatible() public {
    changePrank(OWNER);
    vm.mockCall(
      address(s_pfAlertsController),
      abi.encodeWithSelector(
        IERC165.supportsInterface.selector, ERC677ReceiverInterface.onTokenTransfer.selector
      ),
      abi.encode(false)
    );
    vm.expectRevert(IMigratable.InvalidMigrationTarget.selector);
    s_rewardVault.setMigrationTarget(address(s_pfAlertsController));
  }

  function test_RevertWhen_PassedInANonContractAddress() public {
    changePrank(OWNER);
    vm.expectRevert(IMigratable.InvalidMigrationTarget.selector);
    s_rewardVault.setMigrationTarget(STRANGER);
  }

  function test_CorrectlySetsMigrationTarget() public {
    changePrank(OWNER);
    s_rewardVault.setMigrationTarget(address(s_rewardVaultVersion2));
    assertEq(s_rewardVault.getMigrationTarget(), address(s_rewardVaultVersion2));
  }

  function test_EmitsEvent() public {
    changePrank(OWNER);
    vm.expectEmit(true, true, true, true, address(s_rewardVault));
    emit MigrationTargetSet(address(0), address(s_rewardVaultVersion2));
    s_rewardVault.setMigrationTarget(address(s_rewardVaultVersion2));
  }
}

contract RewardVault_SetMigrationSource is BaseTest {
  address private constant MIGRATION_SOURCE = address(999);

  event MigrationSourceSet(address indexed oldMigrationSource, address indexed newMigrationSource);

  function test_RevertWhen_CalledByNonOwner() public {
    changePrank(STRANGER);
    vm.expectRevert(
      _getExpectedMissingRoleErrorMessage(STRANGER, s_rewardVault.DEFAULT_ADMIN_ROLE())
    );
    s_rewardVault.setMigrationSource(MIGRATION_SOURCE);
  }

  function test_RevertWhen_ZeroAddress() public {
    vm.expectRevert(RewardVault.InvalidMigrationSource.selector);
    s_rewardVault.setMigrationSource(address(0));
  }

  function test_RevertWhen_OwnAddress() public {
    vm.expectRevert(RewardVault.InvalidMigrationSource.selector);
    s_rewardVault.setMigrationSource(address(s_rewardVault));
  }

  function test_CorrectlySetsTheMigrationSource() public {
    changePrank(OWNER);
    s_rewardVault.setMigrationSource(MIGRATION_SOURCE);
    assertEq(s_rewardVault.getMigrationSource(), MIGRATION_SOURCE);
  }

  function test_EmitsEvent() public {
    changePrank(OWNER);
    vm.expectEmit(true, true, true, true, address(s_rewardVault));
    emit MigrationSourceSet(address(0), MIGRATION_SOURCE);
    s_rewardVault.setMigrationSource(MIGRATION_SOURCE);
  }
}

contract RewardVault_OnTokenTransfer is RewardVault_WithUpgradedVaultDeployedButNotMigrated {
  function test_RevertWhen_CalledByNonLINKToken() public {
    vm.expectRevert(RewardVault.SenderNotLinkToken.selector);
    s_rewardVaultVersion2.onTokenTransfer(address(s_rewardVault), 1000 ether, bytes(''));
  }

  function test_RevertWhen_SenderIsNotMigrationSource() public {
    RewardVault.RewardBuckets memory originalVaultBuckets = s_rewardVault.getRewardBuckets();
    (
      uint256 totalUnvestedRewards,
      uint256 unvestedOperatorBaseRewards,
      uint256 unvestedCommunityBaseRewards,
      uint256 unvestedOperatorDelegatedRewards
    ) = _getTotalUnvestedRewards(s_rewardVault);
    changePrank(address(s_LINK));
    vm.expectRevert(RewardVault.AccessForbidden.selector);
    s_rewardVaultVersion2.onTokenTransfer(
      STRANGER,
      totalUnvestedRewards,
      abi.encode(
        originalVaultBuckets.operatorBase.emissionRate,
        unvestedOperatorBaseRewards,
        originalVaultBuckets.communityBase.emissionRate,
        unvestedCommunityBaseRewards,
        originalVaultBuckets.operatorDelegated.emissionRate,
        unvestedOperatorDelegatedRewards,
        bytes('')
      )
    );
  }

  function test_RevertWhen_TotalAmountAddedLessThanDelegationRateDenominator() public {
    vm.expectRevert(RewardVault.InvalidRewardAmount.selector);
    changePrank(address(s_LINK));

    uint256 amountOfRewards = DELEGATION_RATE_DENOMINATOR / 4;
    s_rewardVaultVersion2.onTokenTransfer(
      address(s_rewardVault),
      amountOfRewards,
      abi.encode(
        0.01 ether,
        amountOfRewards / 3,
        0.01 ether,
        amountOfRewards / 3,
        0.01 ether,
        amountOfRewards / 3,
        bytes('')
      )
    );
  }

  function test_RevertWhen_TotalEmissionRateIsZero() public {
    vm.expectRevert(RewardVault.InvalidEmissionRate.selector);
    changePrank(address(s_LINK));
    s_rewardVaultVersion2.onTokenTransfer(
      address(s_rewardVault),
      3000 ether,
      abi.encode(0, 1000 ether, 0, 1000 ether, 0, 1000 ether, bytes(''))
    );
  }

  function test_RevertWhen_TotalEmissionRateLessThanDelegationRateDenominator() public {
    vm.expectRevert(RewardVault.InvalidEmissionRate.selector);
    changePrank(address(s_LINK));
    s_rewardVaultVersion2.onTokenTransfer(
      address(s_rewardVault),
      3000 ether,
      abi.encode(
        DELEGATION_RATE_DENOMINATOR / 4,
        1000 ether,
        DELEGATION_RATE_DENOMINATOR / 4,
        1000 ether,
        DELEGATION_RATE_DENOMINATOR / 4,
        1000 ether,
        bytes('')
      )
    );
  }

  function test_CorrectlySetsTheRewardEmissionRates() public {
    RewardVault.RewardBuckets memory originalVaultBuckets = s_rewardVault.getRewardBuckets();
    (
      uint256 totalUnvestedRewards,
      uint256 unvestedOperatorBaseRewards,
      uint256 unvestedCommunityBaseRewards,
      uint256 unvestedOperatorDelegatedRewards
    ) = _getTotalUnvestedRewards(s_rewardVault);
    changePrank(address(s_LINK));
    s_rewardVaultVersion2.onTokenTransfer(
      address(s_rewardVault),
      totalUnvestedRewards,
      abi.encode(
        originalVaultBuckets.operatorBase.emissionRate,
        unvestedOperatorBaseRewards,
        originalVaultBuckets.communityBase.emissionRate,
        unvestedCommunityBaseRewards,
        originalVaultBuckets.operatorDelegated.emissionRate,
        unvestedOperatorDelegatedRewards,
        bytes('')
      )
    );

    RewardVault.RewardBuckets memory upgradedVaultBuckets = s_rewardVaultVersion2.getRewardBuckets();
    assertEq(
      upgradedVaultBuckets.operatorBase.emissionRate, originalVaultBuckets.operatorBase.emissionRate
    );
    assertEq(
      upgradedVaultBuckets.communityBase.emissionRate,
      originalVaultBuckets.communityBase.emissionRate
    );
    assertEq(
      upgradedVaultBuckets.operatorDelegated.emissionRate,
      originalVaultBuckets.operatorDelegated.emissionRate
    );
  }

  function test_CorrectlySetsTheRewardDurations() public {
    RewardVault.RewardBuckets memory originalVaultBuckets = s_rewardVault.getRewardBuckets();
    (
      uint256 totalUnvestedRewards,
      uint256 unvestedOperatorBaseRewards,
      uint256 unvestedCommunityBaseRewards,
      uint256 unvestedOperatorDelegatedRewards
    ) = _getTotalUnvestedRewards(s_rewardVault);
    changePrank(address(s_LINK));
    s_rewardVaultVersion2.onTokenTransfer(
      address(s_rewardVault),
      totalUnvestedRewards,
      abi.encode(
        originalVaultBuckets.operatorBase.emissionRate,
        unvestedOperatorBaseRewards,
        originalVaultBuckets.communityBase.emissionRate,
        unvestedCommunityBaseRewards,
        originalVaultBuckets.operatorDelegated.emissionRate,
        unvestedOperatorDelegatedRewards,
        bytes('')
      )
    );

    RewardVault.RewardBuckets memory upgradedVaultBuckets = s_rewardVaultVersion2.getRewardBuckets();
    assertEq(
      upgradedVaultBuckets.operatorBase.rewardDurationEndsAt,
      originalVaultBuckets.operatorBase.rewardDurationEndsAt
    );
    assertEq(
      upgradedVaultBuckets.communityBase.rewardDurationEndsAt,
      originalVaultBuckets.communityBase.rewardDurationEndsAt
    );
    assertEq(
      upgradedVaultBuckets.operatorDelegated.rewardDurationEndsAt,
      originalVaultBuckets.operatorDelegated.rewardDurationEndsAt
    );
  }
}

contract RewardVault_OnTokenTransfer_WithImbalancedBuckets is
  RewardVault_WithUpgradedVaultDeployedButNotMigrated
{
  uint256 private TIME_AFTER_REWARDS_ADDED = 28 days;

  function test_CorrectlySetsTheRewardEmissionRatesWhenRewardsAddedToOperatorPool() public {
    changePrank(REWARDER);
    s_rewardVault.addReward(address(s_operatorStakingPool), REWARD_AMOUNT, EMISSION_RATE);
    skip(TIME_AFTER_REWARDS_ADDED);
    RewardVault.RewardBuckets memory originalVaultBuckets = s_rewardVault.getRewardBuckets();
    (
      uint256 totalUnvestedRewards,
      uint256 unvestedOperatorBaseRewards,
      uint256 unvestedCommunityBaseRewards,
      uint256 unvestedOperatorDelegatedRewards
    ) = _getTotalUnvestedRewards(s_rewardVault);
    changePrank(address(s_LINK));
    s_rewardVaultVersion2.onTokenTransfer(
      address(s_rewardVault),
      totalUnvestedRewards,
      abi.encode(
        originalVaultBuckets.operatorBase.emissionRate,
        unvestedOperatorBaseRewards,
        originalVaultBuckets.communityBase.emissionRate,
        unvestedCommunityBaseRewards,
        originalVaultBuckets.operatorDelegated.emissionRate,
        unvestedOperatorDelegatedRewards,
        bytes('')
      )
    );

    RewardVault.RewardBuckets memory upgradedVaultBuckets = s_rewardVaultVersion2.getRewardBuckets();
    assertEq(
      upgradedVaultBuckets.operatorBase.emissionRate, originalVaultBuckets.operatorBase.emissionRate
    );
    assertEq(
      upgradedVaultBuckets.communityBase.emissionRate,
      originalVaultBuckets.communityBase.emissionRate
    );
    assertEq(
      upgradedVaultBuckets.operatorDelegated.emissionRate,
      originalVaultBuckets.operatorDelegated.emissionRate
    );
  }

  function test_CorrectlySetsTheRewardDurationsWhenRewardsAddedToOperatorPool() public {
    changePrank(REWARDER);
    s_rewardVault.addReward(address(s_operatorStakingPool), REWARD_AMOUNT, EMISSION_RATE);
    skip(TIME_AFTER_REWARDS_ADDED);
    RewardVault.RewardBuckets memory originalVaultBuckets = s_rewardVault.getRewardBuckets();

    (
      uint256 totalUnvestedRewards,
      uint256 unvestedOperatorBaseRewards,
      uint256 unvestedCommunityBaseRewards,
      uint256 unvestedOperatorDelegatedRewards
    ) = _getTotalUnvestedRewards(s_rewardVault);
    changePrank(address(s_LINK));
    s_rewardVaultVersion2.onTokenTransfer(
      address(s_rewardVault),
      totalUnvestedRewards,
      abi.encode(
        originalVaultBuckets.operatorBase.emissionRate,
        unvestedOperatorBaseRewards,
        originalVaultBuckets.communityBase.emissionRate,
        unvestedCommunityBaseRewards,
        originalVaultBuckets.operatorDelegated.emissionRate,
        unvestedOperatorDelegatedRewards,
        bytes('')
      )
    );

    RewardVault.RewardBuckets memory upgradedVaultBuckets = s_rewardVaultVersion2.getRewardBuckets();
    assertEq(
      upgradedVaultBuckets.operatorBase.rewardDurationEndsAt,
      originalVaultBuckets.operatorBase.rewardDurationEndsAt
    );
    assertEq(
      upgradedVaultBuckets.communityBase.rewardDurationEndsAt,
      originalVaultBuckets.communityBase.rewardDurationEndsAt
    );
    assertEq(
      upgradedVaultBuckets.operatorDelegated.rewardDurationEndsAt,
      originalVaultBuckets.operatorDelegated.rewardDurationEndsAt
    );
  }

  function test_CorrectlySetsTheRewardEmissionRatesWhenRewardsAddedToCommunityPool() public {
    changePrank(REWARDER);
    s_rewardVault.addReward(address(s_communityStakingPool), REWARD_AMOUNT, EMISSION_RATE);
    skip(TIME_AFTER_REWARDS_ADDED);
    RewardVault.RewardBuckets memory originalVaultBuckets = s_rewardVault.getRewardBuckets();

    (
      uint256 totalUnvestedRewards,
      uint256 unvestedOperatorBaseRewards,
      uint256 unvestedCommunityBaseRewards,
      uint256 unvestedOperatorDelegatedRewards
    ) = _getTotalUnvestedRewards(s_rewardVault);
    changePrank(address(s_LINK));
    s_rewardVaultVersion2.onTokenTransfer(
      address(s_rewardVault),
      totalUnvestedRewards,
      abi.encode(
        originalVaultBuckets.operatorBase.emissionRate,
        unvestedOperatorBaseRewards,
        originalVaultBuckets.communityBase.emissionRate,
        unvestedCommunityBaseRewards,
        originalVaultBuckets.operatorDelegated.emissionRate,
        unvestedOperatorDelegatedRewards,
        bytes('')
      )
    );

    RewardVault.RewardBuckets memory upgradedVaultBuckets = s_rewardVaultVersion2.getRewardBuckets();
    assertEq(
      upgradedVaultBuckets.operatorBase.emissionRate, originalVaultBuckets.operatorBase.emissionRate
    );
    assertEq(
      upgradedVaultBuckets.communityBase.emissionRate,
      originalVaultBuckets.communityBase.emissionRate
    );
    assertEq(
      upgradedVaultBuckets.operatorDelegated.emissionRate,
      originalVaultBuckets.operatorDelegated.emissionRate
    );
  }

  function test_CorrectlySetsTheRewardDurationsWhenRewardsAddedToCommunityPool() public {
    changePrank(REWARDER);
    s_rewardVault.addReward(address(s_communityStakingPool), REWARD_AMOUNT, EMISSION_RATE);
    skip(TIME_AFTER_REWARDS_ADDED);
    RewardVault.RewardBuckets memory originalVaultBuckets = s_rewardVault.getRewardBuckets();
    (
      uint256 totalUnvestedRewards,
      uint256 unvestedOperatorBaseRewards,
      uint256 unvestedCommunityBaseRewards,
      uint256 unvestedOperatorDelegatedRewards
    ) = _getTotalUnvestedRewards(s_rewardVault);
    changePrank(address(s_LINK));
    s_rewardVaultVersion2.onTokenTransfer(
      address(s_rewardVault),
      totalUnvestedRewards,
      abi.encode(
        originalVaultBuckets.operatorBase.emissionRate,
        unvestedOperatorBaseRewards,
        originalVaultBuckets.communityBase.emissionRate,
        unvestedCommunityBaseRewards,
        originalVaultBuckets.operatorDelegated.emissionRate,
        unvestedOperatorDelegatedRewards,
        bytes('')
      )
    );

    RewardVault.RewardBuckets memory upgradedVaultBuckets = s_rewardVaultVersion2.getRewardBuckets();
    assertEq(
      upgradedVaultBuckets.operatorBase.rewardDurationEndsAt,
      originalVaultBuckets.operatorBase.rewardDurationEndsAt
    );
    assertEq(
      upgradedVaultBuckets.communityBase.rewardDurationEndsAt,
      originalVaultBuckets.communityBase.rewardDurationEndsAt
    );
    assertEq(
      upgradedVaultBuckets.operatorDelegated.rewardDurationEndsAt,
      originalVaultBuckets.operatorDelegated.rewardDurationEndsAt
    );
  }
}

contract RewardVault_Migrate_MigrationTargetUnset is
  RewardVault_WithUpgradedVaultDeployedButNotMigrated
{
  function test_RevertWhen_CalledByNonOwner() public {
    changePrank(STRANGER);
    vm.expectRevert(
      _getExpectedMissingRoleErrorMessage(STRANGER, s_rewardVault.DEFAULT_ADMIN_ROLE())
    );
    s_rewardVault.migrate(bytes(''));
  }

  function test_RevertWhen_MigrationTargetUnset() public {
    changePrank(OWNER);
    vm.expectRevert(IMigratable.InvalidMigrationTarget.selector);
    s_rewardVault.migrate(bytes(''));
  }
}

contract RewardVault_Migrate_MigrationTargetSet is
  RewardVault_WithUpgradedVaultDeployedButNotMigrated
{
  uint256 private constant TIME_AFTER_MIGRATE = 28 days;

  event VaultMigrated(
    address indexed migrationTarget, uint256 totalUnvestedRewards, uint256 totalEmissionRate
  );

  function setUp() public virtual override {
    RewardVault_WithUpgradedVaultDeployedButNotMigrated.setUp();
    changePrank(OWNER);
    s_rewardVault.setMigrationTarget(address(s_rewardVaultVersion2));
  }

  function test_RevertWhen_CalledByNonOwner() public {
    changePrank(STRANGER);
    vm.expectRevert(
      _getExpectedMissingRoleErrorMessage(STRANGER, s_rewardVault.DEFAULT_ADMIN_ROLE())
    );
    s_rewardVault.migrate(bytes(''));
  }

  function test_RevertWhen_VaultClosed() public {
    changePrank(OWNER);
    s_rewardVault.close();
    vm.expectRevert(RewardVault.VaultAlreadyClosed.selector);
    s_rewardVault.migrate(bytes(''));
  }

  function test_RevertWhen_MigrateReenters() public {
    RewardVault.RewardBuckets memory originalVaultBuckets = s_rewardVault.getRewardBuckets();
    (
      uint256 totalUnvestedRewards,
      uint256 unvestedOperatorBaseRewards,
      uint256 unvestedCommunityBaseRewards,
      uint256 unvestedOperatorDelegatedRewards
    ) = _getTotalUnvestedRewards(s_rewardVault);
    changePrank(address(s_LINK));
    s_rewardVaultVersion2.onTokenTransfer(
      address(s_rewardVault),
      totalUnvestedRewards,
      abi.encode(
        originalVaultBuckets.operatorBase.emissionRate,
        unvestedOperatorBaseRewards,
        originalVaultBuckets.communityBase.emissionRate,
        unvestedCommunityBaseRewards,
        originalVaultBuckets.operatorDelegated.emissionRate,
        unvestedOperatorDelegatedRewards,
        bytes('')
      )
    );
    vm.expectRevert(RewardVault.AccessForbidden.selector);
    s_rewardVaultVersion2.onTokenTransfer(
      address(s_rewardVault),
      totalUnvestedRewards,
      abi.encode(
        originalVaultBuckets.operatorBase.emissionRate,
        unvestedOperatorBaseRewards,
        originalVaultBuckets.communityBase.emissionRate,
        unvestedCommunityBaseRewards,
        originalVaultBuckets.operatorDelegated.emissionRate,
        unvestedOperatorDelegatedRewards,
        bytes('')
      )
    );
  }

  function test_RevertWhen_TokenAmountDifferentFromData() public {
    (
      uint256 totalUnvestedRewards,
      uint256 unvestedOperatorBaseRewards,
      uint256 unvestedCommunityBaseRewards,
      uint256 unvestedOperatorDelegatedRewards
    ) = _getTotalUnvestedRewards(s_rewardVault);
    uint256 invalidAmount = totalUnvestedRewards + 1;

    changePrank(address(s_LINK));
    vm.expectRevert(RewardVault.InvalidRewardAmount.selector);
    s_rewardVaultVersion2.onTokenTransfer(
      address(s_rewardVault),
      invalidAmount,
      abi.encode(
        0,
        unvestedOperatorBaseRewards,
        0,
        unvestedCommunityBaseRewards,
        0,
        unvestedOperatorDelegatedRewards,
        bytes('')
      )
    );
  }

  function test_VestingCheckpointDataCorrectlySet() public {
    changePrank(OWNER);
    s_rewardVault.migrate(bytes(''));
    RewardVault.VestingCheckpointData memory checkpointData =
      s_rewardVault.getVestingCheckpointData();
    assertEq(checkpointData.operatorPoolTotalPrincipal, s_operatorStakingPool.getTotalPrincipal());
    assertEq(checkpointData.communityPoolTotalPrincipal, s_communityStakingPool.getTotalPrincipal());
    assertEq(
      checkpointData.operatorPoolCheckpointId, s_operatorStakingPool.getCurrentCheckpointId() - 1
    );
    assertEq(
      checkpointData.communityPoolCheckpointId, s_communityStakingPool.getCurrentCheckpointId() - 1
    );
  }

  function test_ClosesRewardVault() public {
    changePrank(OWNER);
    s_rewardVault.migrate(bytes(''));
    assertEq(s_rewardVault.isOpen(), false);
  }

  function test_TransfersUnvestedLINKRewardsToTheNewVault() public {
    uint256 originalRewardVaultLINKBalanceBefore = s_LINK.balanceOf(address(s_rewardVault));
    (uint256 totalUnvestedRewards,,,) = _getTotalUnvestedRewards(s_rewardVault);
    changePrank(OWNER);
    s_rewardVault.migrate(bytes(''));
    assertEq(
      s_LINK.balanceOf(address(s_rewardVault)),
      originalRewardVaultLINKBalanceBefore - totalUnvestedRewards
    );
    assertEq(s_LINK.balanceOf(address(s_rewardVaultVersion2)), totalUnvestedRewards);
  }

  function test_StakerMultiplierIsTheSame() public {
    uint256 stakerMultiplier = s_rewardVault.getMultiplier(OPERATOR_STAKER_ONE);
    changePrank(OWNER);
    s_rewardVault.migrate(bytes(''));
    assertEq(s_rewardVaultVersion2.getMultiplier(OPERATOR_STAKER_ONE), stakerMultiplier);
  }

  function test_StakerStopsEarningRewardsFromOldRewardVault() public {
    uint256 vestedBucketRewardsAtMigrate = _calculateBucketVestedRewards(
      s_rewardVault.getRewardBuckets().communityBase, s_stakedAtTime, block.timestamp
    );
    changePrank(OWNER);
    s_rewardVault.migrate(bytes(''));
    skip(TIME_AFTER_MIGRATE);
    uint256 expectedRewards = _calculateStakerExpectedReward(
      s_communityStakingPool.getStakerPrincipal(COMMUNITY_STAKER_ONE),
      s_communityStakingPool.getTotalPrincipal(),
      vestedBucketRewardsAtMigrate
    ) * s_rewardVault.getMultiplier(COMMUNITY_STAKER_ONE) / FixedPointMathLib.WAD;
    assertEq(s_rewardVault.getReward(COMMUNITY_STAKER_ONE), expectedRewards);
  }

  function test_StakerStartsEarningRewardsFromNewVault() public {
    RewardVault.RewardBuckets memory rewardBuckets = s_rewardVault.getRewardBuckets();
    uint256 rewardDuration = rewardBuckets.communityBase.rewardDurationEndsAt - block.timestamp;
    uint256 unvestedCommunityBaseRewards =
      _calculateUnvestedRewardsInBucket(rewardBuckets.communityBase);

    changePrank(OWNER);
    s_rewardVault.migrate(bytes(''));
    skip(TIME_AFTER_MIGRATE);

    uint256 vestedCommunityBaseRewardsInNewVault =
      TIME_AFTER_MIGRATE * unvestedCommunityBaseRewards / rewardDuration;
    uint256 expectedRewards = _calculateStakerExpectedReward(
      s_communityStakingPool.getStakerPrincipal(COMMUNITY_STAKER_ONE),
      s_communityStakingPool.getTotalPrincipal(),
      vestedCommunityBaseRewardsInNewVault
    ) * s_rewardVault.getMultiplier(COMMUNITY_STAKER_ONE) / FixedPointMathLib.WAD;
    assertEq(s_rewardVaultVersion2.getReward(COMMUNITY_STAKER_ONE), expectedRewards);
  }

  function test_EmitsEvent() public {
    changePrank(OWNER);
    (uint256 totalUnvestedRewards,,,) = _getTotalUnvestedRewards(s_rewardVault);
    vm.expectEmit(true, true, true, true, address(s_rewardVault));
    emit VaultMigrated(address(s_rewardVaultVersion2), totalUnvestedRewards, EMISSION_RATE);
    s_rewardVault.migrate(bytes(''));
  }
}

contract RewardVault_Pausable is IPausableTest, BaseTest {
  function test_RevertWhen_NotPauserEmergencyPause() public {
    changePrank(STRANGER);
    vm.expectRevert(_getExpectedMissingRoleErrorMessage(STRANGER, s_rewardVault.PAUSER_ROLE()));
    s_rewardVault.emergencyPause();
    assertEq(s_rewardVault.paused(), false);
  }

  function test_PauserCanEmergencyPause() public {
    changePrank(PAUSER);
    s_rewardVault.emergencyPause();
    assertEq(s_rewardVault.paused(), true);
  }

  function test_RevertWhen_PausingWhenAlreadyPaused() public {
    changePrank(PAUSER);
    s_rewardVault.emergencyPause();

    vm.expectRevert('Pausable: paused');
    s_rewardVault.emergencyPause();
  }

  function test_RevertWhen_NotPauserEmergencyUnpause() public {
    changePrank(PAUSER);
    s_rewardVault.emergencyPause();

    changePrank(STRANGER);
    vm.expectRevert(_getExpectedMissingRoleErrorMessage(STRANGER, s_rewardVault.PAUSER_ROLE()));
    s_rewardVault.emergencyUnpause();
    assertEq(s_rewardVault.paused(), true);
  }

  function test_PauserCanEmergencyUnpause() public {
    changePrank(PAUSER);
    s_rewardVault.emergencyPause();
    s_rewardVault.emergencyUnpause();
    assertEq(s_rewardVault.paused(), false);
  }

  function test_RevertWhen_UnpausingWhenAlreadyUnpaused() public {
    changePrank(PAUSER);
    vm.expectRevert('Pausable: not paused');
    s_rewardVault.emergencyUnpause();
  }
}

contract RewardVault_AccessControlDefaultAdminRules is
  IAccessControlDefaultAdminRulesTest,
  BaseTest
{
  using SafeCast for uint256;

  event DefaultAdminTransferScheduled(address indexed newAdmin, uint48 acceptSchedule);
  event DefaultAdminTransferCanceled();
  event DefaultAdminDelayChangeScheduled(uint48 newDelay, uint48 effectSchedule);
  event DefaultAdminDelayChangeCanceled();

  function test_DefaultValuesAreInitialized() public {
    assertEq(s_rewardVault.hasRole(s_rewardVault.DEFAULT_ADMIN_ROLE(), OWNER), true);
    assertEq(s_rewardVault.defaultAdmin(), OWNER);
    (address pendingDefaultAdmin, uint48 adminSchedule) = s_rewardVault.pendingDefaultAdmin();
    assertEq(pendingDefaultAdmin, address(0));
    assertEq(adminSchedule, 0);
    assertEq(s_rewardVault.defaultAdminDelay(), 0);
    (uint48 pendingDelay, uint48 delaySchedule) = s_rewardVault.pendingDefaultAdminDelay();
    assertEq(pendingDelay, 0);
    assertEq(delaySchedule, 0);
    assertEq(s_rewardVault.defaultAdminDelayIncreaseWait(), 5 days);
  }

  function test_RevertWhen_DirectlyGrantDefaultAdminRole() public {
    changePrank(OWNER);
    bytes32 defaultAdminRole = s_rewardVault.DEFAULT_ADMIN_ROLE();
    vm.expectRevert("AccessControl: can't directly grant default admin role");
    s_rewardVault.grantRole(defaultAdminRole, NEW_OWNER);
  }

  function test_RevertWhen_DirectlyRevokeDefaultAdminRole() public {
    changePrank(OWNER);
    bytes32 defaultAdminRole = s_rewardVault.DEFAULT_ADMIN_ROLE();
    vm.expectRevert("AccessControl: can't directly revoke default admin role");
    s_rewardVault.revokeRole(defaultAdminRole, NEW_OWNER);
  }

  function test_RevertWhen_NonAdminBeginsDefaultAdminTransfer() public {
    changePrank(NEW_OWNER);
    vm.expectRevert(
      _getExpectedMissingRoleErrorMessage(NEW_OWNER, s_rewardVault.DEFAULT_ADMIN_ROLE())
    );
    s_rewardVault.beginDefaultAdminTransfer(NEW_OWNER);
  }

  function test_CurrentAdminCanBeginDefaultAdminTransfer() public {
    changePrank(OWNER);
    address newAdmin = NEW_OWNER;
    uint48 newSchedule = SafeCast.toUint48(block.timestamp);
    vm.expectEmit(true, true, true, true, address(s_rewardVault));
    emit DefaultAdminTransferScheduled(newAdmin, newSchedule);

    s_rewardVault.beginDefaultAdminTransfer(newAdmin);

    assertEq(s_rewardVault.hasRole(s_rewardVault.DEFAULT_ADMIN_ROLE(), OWNER), true);
    assertEq(s_rewardVault.defaultAdmin(), OWNER);
    (address pendingDefaultAdmin, uint48 schedule) = s_rewardVault.pendingDefaultAdmin();
    assertEq(pendingDefaultAdmin, newAdmin);
    assertEq(schedule, newSchedule);
  }

  function test_CurrentAdminCanOverwritePendingDefaultAdminTransfer() public {
    changePrank(OWNER);
    s_rewardVault.beginDefaultAdminTransfer(NEW_OWNER);

    address newAdmin = PAUSER;
    uint48 newSchedule = SafeCast.toUint48(block.timestamp);
    vm.expectEmit(true, true, true, true, address(s_rewardVault));
    emit DefaultAdminTransferCanceled();
    vm.expectEmit(true, true, true, true, address(s_rewardVault));
    emit DefaultAdminTransferScheduled(newAdmin, newSchedule);

    s_rewardVault.beginDefaultAdminTransfer(newAdmin);

    assertEq(s_rewardVault.hasRole(s_rewardVault.DEFAULT_ADMIN_ROLE(), OWNER), true);
    assertEq(s_rewardVault.defaultAdmin(), OWNER);
    (address pendingDefaultAdmin, uint48 schedule) = s_rewardVault.pendingDefaultAdmin();
    assertEq(pendingDefaultAdmin, newAdmin);
    assertEq(schedule, newSchedule);
  }

  function test_CurrentAdminCanOverwriteDefaultAdminTransferAfterDelayPassedAndIfNotAccepted()
    public
  {
    changePrank(OWNER);
    s_rewardVault.beginDefaultAdminTransfer(NEW_OWNER);
    (, uint48 scheduleBefore) = s_rewardVault.pendingDefaultAdmin();

    // After the delay is over
    skip(2);

    address newAdmin = PAUSER;
    uint48 newSchedule = scheduleBefore + 2;
    vm.expectEmit(true, true, true, true, address(s_rewardVault));
    emit DefaultAdminTransferCanceled();
    vm.expectEmit(true, true, true, true, address(s_rewardVault));
    emit DefaultAdminTransferScheduled(newAdmin, newSchedule);

    s_rewardVault.beginDefaultAdminTransfer(PAUSER);

    assertEq(s_rewardVault.hasRole(s_rewardVault.DEFAULT_ADMIN_ROLE(), OWNER), true);
    assertEq(s_rewardVault.defaultAdmin(), OWNER);
    (address pendingDefaultAdmin, uint48 schedule) = s_rewardVault.pendingDefaultAdmin();
    assertEq(pendingDefaultAdmin, newAdmin);
    assertEq(schedule, newSchedule);
  }

  function test_RevertWhen_NonAdminCancelPendingDefaultAdminTransfer() public {
    changePrank(OWNER);
    s_rewardVault.beginDefaultAdminTransfer(NEW_OWNER);

    changePrank(NEW_OWNER);
    vm.expectRevert(
      _getExpectedMissingRoleErrorMessage(NEW_OWNER, s_rewardVault.DEFAULT_ADMIN_ROLE())
    );
    s_rewardVault.cancelDefaultAdminTransfer();
  }

  function test_CurrentAdminCanCancelPendingDefaultAdminTransfer() public {
    changePrank(OWNER);
    s_rewardVault.beginDefaultAdminTransfer(NEW_OWNER);

    vm.expectEmit(true, true, true, true, address(s_rewardVault));
    emit DefaultAdminTransferCanceled();
    s_rewardVault.cancelDefaultAdminTransfer();

    (address pendingDefaultAdmin, uint48 schedule) = s_rewardVault.pendingDefaultAdmin();
    assertEq(pendingDefaultAdmin, address(0));
    assertEq(schedule, 0);
  }

  function test_RevertWhen_NonPendingDefaultAdminAcceptsTransfer() public {
    changePrank(OWNER);
    s_rewardVault.beginDefaultAdminTransfer(NEW_OWNER);

    changePrank(STRANGER);
    vm.expectRevert('AccessControl: pending admin must accept');
    s_rewardVault.acceptDefaultAdminTransfer();
  }

  function test_RevertWhen_PendingDefaultAdminAcceptsTransferBeforeDelayPassed() public {
    changePrank(OWNER);
    s_rewardVault.changeDefaultAdminDelay(1 days);
    s_rewardVault.beginDefaultAdminTransfer(NEW_OWNER);

    changePrank(NEW_OWNER);
    vm.expectRevert('AccessControl: transfer delay not passed');
    s_rewardVault.acceptDefaultAdminTransfer();
  }

  function test_PendingDefaultAdminCanAcceptTransferImmediatelyIfDelayIsZero() public {
    changePrank(OWNER);
    s_rewardVault.beginDefaultAdminTransfer(NEW_OWNER);

    skip(1); // needs to satisfy: schedule < block.timestamp

    changePrank(NEW_OWNER);
    s_rewardVault.acceptDefaultAdminTransfer();

    assertEq(s_rewardVault.hasRole(s_rewardVault.DEFAULT_ADMIN_ROLE(), OWNER), false);
    assertEq(s_rewardVault.hasRole(s_rewardVault.DEFAULT_ADMIN_ROLE(), NEW_OWNER), true);
    assertEq(s_rewardVault.defaultAdmin(), NEW_OWNER);
    (address pendingDefaultAdmin, uint48 schedule) = s_rewardVault.pendingDefaultAdmin();
    assertEq(pendingDefaultAdmin, address(0));
    assertEq(schedule, 0);
  }

  function test_PendingDefaultAdminCanAcceptTransferAfterDelayPassed() public {
    changePrank(OWNER);
    s_rewardVault.changeDefaultAdminDelay(30 days);
    s_rewardVault.beginDefaultAdminTransfer(NEW_OWNER);

    skip(30 days);

    changePrank(NEW_OWNER);
    s_rewardVault.acceptDefaultAdminTransfer();

    assertEq(s_rewardVault.hasRole(s_rewardVault.DEFAULT_ADMIN_ROLE(), OWNER), false);
    assertEq(s_rewardVault.hasRole(s_rewardVault.DEFAULT_ADMIN_ROLE(), NEW_OWNER), true);
    assertEq(s_rewardVault.defaultAdmin(), NEW_OWNER);
    (address pendingDefaultAdmin, uint48 schedule) = s_rewardVault.pendingDefaultAdmin();
    assertEq(pendingDefaultAdmin, address(0));
    assertEq(schedule, 0);
  }

  function test_RevertWhen_NonAdminChangesDelay() public {
    changePrank(NEW_OWNER);
    vm.expectRevert(
      _getExpectedMissingRoleErrorMessage(NEW_OWNER, s_rewardVault.DEFAULT_ADMIN_ROLE())
    );
    s_rewardVault.changeDefaultAdminDelay(30 days);
  }

  function test_CurrentAdminCanChangeDelay() public {
    changePrank(OWNER);
    uint48 newDelay = 30 days;
    uint48 newSchedule = SafeCast.toUint48(block.timestamp + 5 days);
    vm.expectEmit(true, true, true, true, address(s_rewardVault));
    emit DefaultAdminDelayChangeScheduled(newDelay, newSchedule);
    s_rewardVault.changeDefaultAdminDelay(newDelay);

    assertEq(s_rewardVault.defaultAdminDelay(), 0);
    (uint48 pendingDelay, uint48 schedule) = s_rewardVault.pendingDefaultAdminDelay();
    assertEq(pendingDelay, newDelay);
    assertEq(schedule, newSchedule);
  }

  function test_RevertWhen_NonAdminRollbackDelayChange() public {
    changePrank(OWNER);
    s_rewardVault.changeDefaultAdminDelay(30 days);

    changePrank(NEW_OWNER);
    vm.expectRevert(
      _getExpectedMissingRoleErrorMessage(NEW_OWNER, s_rewardVault.DEFAULT_ADMIN_ROLE())
    );
    s_rewardVault.rollbackDefaultAdminDelay();
  }

  function test_CurrentAdminCanRollbackDelayChange() public {
    changePrank(OWNER);
    s_rewardVault.changeDefaultAdminDelay(30 days);

    vm.expectEmit(true, true, true, true, address(s_rewardVault));
    emit DefaultAdminDelayChangeCanceled();
    s_rewardVault.rollbackDefaultAdminDelay();

    assertEq(s_rewardVault.defaultAdminDelay(), 0);
    (uint48 pendingDelay, uint48 schedule) = s_rewardVault.pendingDefaultAdminDelay();
    assertEq(pendingDelay, 0);
    assertEq(schedule, 0);
  }
}

contract RewardVault_HasRewardDurationEnded is RewardVault_WithStakersAndTimePassed {
  function test_ReturnsFalseWhenRewardDurationNotEnded() public {
    assertEq(s_rewardVault.hasRewardDurationEnded(address(s_communityStakingPool)), false);
    assertEq(s_rewardVault.hasRewardDurationEnded(address(s_operatorStakingPool)), false);
  }

  function test_ReturnsTrueWhenRewardDurationEnded() public {
    RewardVault.RewardBuckets memory buckets = s_rewardVault.getRewardBuckets();
    assertEq(buckets.communityBase.rewardDurationEndsAt, buckets.operatorBase.rewardDurationEndsAt);
    assertEq(
      buckets.communityBase.rewardDurationEndsAt, buckets.operatorDelegated.rewardDurationEndsAt
    );
    uint256 rewardDurationEndsAt = buckets.communityBase.rewardDurationEndsAt;
    vm.warp(rewardDurationEndsAt + 1);
    assertEq(s_rewardVault.hasRewardDurationEnded(address(s_communityStakingPool)), true);
    assertEq(s_rewardVault.hasRewardDurationEnded(address(s_operatorStakingPool)), true);
  }

  function test_RevertWhen_InvalidStakingPoolIsPassed() public {
    vm.expectRevert(RewardVault.InvalidPool.selector);
    s_rewardVault.hasRewardDurationEnded(STRANGER);
    vm.expectRevert(RewardVault.InvalidPool.selector);
    s_rewardVault.hasRewardDurationEnded(address(0));
  }
}
