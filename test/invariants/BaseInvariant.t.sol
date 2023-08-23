// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {StdInvariant} from 'forge-std/StdInvariant.sol';

import {StakingPool_Opened} from '../base-scenarios/StakingPoolScenarios.t.sol';
import {CommunityStakingPoolHandler} from './handlers/CommunityStakingPoolHandler.t.sol';
import {OperatorStakingPoolHandler} from './handlers/OperatorStakingPoolHandler.t.sol';
import {RewardVaultHandler} from './handlers/RewardVaultHandler.t.sol';
import {TimeWarper} from './helpers/TimeWarper.t.sol';
import {IBaseInvariantTest} from '../interfaces/IInvariantTest.t.sol';

abstract contract BaseInvariant is IBaseInvariantTest, StakingPool_Opened {
  CommunityStakingPoolHandler internal s_communityStakingPoolHandler;
  OperatorStakingPoolHandler internal s_operatorStakingPoolHandler;
  RewardVaultHandler internal s_rewardVaultHandler;
  TimeWarper internal s_timeWarper;
  uint256 internal s_currentTimestamp;

  function setUp() public virtual override {
    StakingPool_Opened.setUp();

    s_currentTimestamp = block.timestamp;

    changePrank(OWNER);
    s_communityStakingPool.setMerkleRoot(bytes32(''));

    s_timeWarper = new TimeWarper(IBaseInvariantTest(this));
    bytes4[] memory timeWarperSelectors = new bytes4[](1);
    timeWarperSelectors[0] = TimeWarper.warp.selector;

    targetSelector(
      StdInvariant.FuzzSelector({addr: address(s_timeWarper), selectors: timeWarperSelectors})
    );
    targetContract(address(s_timeWarper));

    s_communityStakingPoolHandler =
    new CommunityStakingPoolHandler(s_communityStakingPool, s_operatorStakingPool, s_rewardVault, s_LINK, IBaseInvariantTest(this));
    bytes4[] memory targetCommunityStakingHandlerFns = new bytes4[](3);
    targetCommunityStakingHandlerFns[0] = CommunityStakingPoolHandler.stake.selector;
    targetCommunityStakingHandlerFns[1] = CommunityStakingPoolHandler.unstake.selector;
    targetCommunityStakingHandlerFns[2] = CommunityStakingPoolHandler.createNewStaker.selector;

    targetSelector(
      StdInvariant.FuzzSelector({
        addr: address(s_communityStakingPoolHandler),
        selectors: targetCommunityStakingHandlerFns
      })
    );
    targetContract(address(s_communityStakingPoolHandler));

    s_operatorStakingPoolHandler = new OperatorStakingPoolHandler(
      s_operatorStakingPool,
      s_rewardVault,
      s_LINK,
      _getDefaultOperators(),
      IBaseInvariantTest(this)
    );

    bytes4[] memory targetedOperatorStakingHandlerFns = new bytes4[](2);
    targetedOperatorStakingHandlerFns[0] = OperatorStakingPoolHandler.stake.selector;
    targetedOperatorStakingHandlerFns[1] = OperatorStakingPoolHandler.unstake.selector;

    targetSelector(
      StdInvariant.FuzzSelector({
        addr: address(s_operatorStakingPoolHandler),
        selectors: targetedOperatorStakingHandlerFns
      })
    );

    targetContract(address(s_operatorStakingPoolHandler));

    s_rewardVaultHandler = new RewardVaultHandler(
      s_communityStakingPool,
      s_operatorStakingPool,
      s_rewardVault,
      s_LINK,
      s_communityStakingPoolHandler,
      s_operatorStakingPoolHandler,
      IBaseInvariantTest(this)
    );

    bytes4[] memory targetedRewardVaultHandlerFns = new bytes4[](6);
    targetedRewardVaultHandlerFns[0] = RewardVaultHandler.addRewardToAllPools.selector;
    targetedRewardVaultHandlerFns[1] = RewardVaultHandler.addRewardToCommunityPool.selector;
    targetedRewardVaultHandlerFns[2] = RewardVaultHandler.addRewardToOperatorPool.selector;
    targetedRewardVaultHandlerFns[3] = RewardVaultHandler.setDelegationRateDenominator.selector;
    targetedRewardVaultHandlerFns[4] = RewardVaultHandler.setMultiplierDuration.selector;
    targetedRewardVaultHandlerFns[5] = RewardVaultHandler.claimReward.selector;

    targetSelector(
      StdInvariant.FuzzSelector({
        addr: address(s_rewardVaultHandler),
        selectors: targetedRewardVaultHandlerFns
      })
    );
    targetContract(address(s_rewardVaultHandler));

    _excludeSenderDeployedContracts();
  }

  function _excludeSenderDeployedContracts() private {
    // manually need to exclude all deployed contracts from sending transactions
    excludeSender(address(s_communityStakingPoolHandler));
    excludeSender(address(s_operatorStakingPoolHandler));
    excludeSender(address(s_operatorStakingPool));
    excludeSender(address(s_communityStakingPool));
    excludeSender(address(s_LINK));
    excludeSender(address(s_migrationProxy));
    excludeSender(address(s_rewardVault));
  }

  /// @notice Returns a random staker from the given pool
  /// @dev If the pool is address(0), then a random staker from either the operator or community
  /// @param pool The pool to get a random staker from
  /// @return A random staker from the given pool
  function _getRandomStaker(address pool) internal view returns (address) {
    address[] memory stakers;
    if (pool == address(0)) {
      stakers = block.timestamp % 2 == 0
        ? s_operatorStakingPoolHandler.getStakers()
        : s_communityStakingPoolHandler.getStakers();
    } else {
      stakers = pool == address(s_operatorStakingPool)
        ? s_operatorStakingPoolHandler.getStakers()
        : s_communityStakingPoolHandler.getStakers();
    }
    return stakers[_getRandomNumber(0, stakers.length - 1)];
  }

  /// @notice Returns a random number between min and max (both inclusive)
  /// @param min The minimum number
  /// @param max The maximum number
  /// @return A random number between min and max
  function _getRandomNumber(uint256 min, uint256 max) internal view returns (uint256) {
    return min + uint256(keccak256(abi.encode(block.timestamp))) % (max - min + 1);
  }

  /// @notice Returns the current stored timestamp, set during the last invariant test run
  /// @return The current stored timestamp
  function currentTimestamp() external view returns (uint256) {
    return s_currentTimestamp;
  }

  /// @notice Sets the current stored timestamp
  /// @param time The timestamp to set
  function setCurrentTimestamp(uint256 time) external {
    s_currentTimestamp = time;
  }

  /// @notice Sets the block timestamp to the current stored timestamp
  /// @dev Invariant tests should use this modifier to use the correct timestamp.
  /// See this issue for more info: https://github.com/foundry-rs/foundry/issues/4994.
  modifier useCurrentTimestamp() {
    vm.warp(s_currentTimestamp);
    _;
  }

  function test() public virtual override {}
}
