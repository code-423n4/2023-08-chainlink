// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {BaseTimeWarpable} from './BaseTimeWarpable.t.sol';
import {IBaseInvariantTest} from '../../interfaces/IInvariantTest.t.sol';
import {RewardVaultHandler} from '../handlers/RewardVaultHandler.t.sol';

/// @title This contract is used to randomly warp time during invariant tests by making this one of
/// the invariant target contracts.
contract TimeWarper is BaseTimeWarpable {
  constructor(IBaseInvariantTest testContract) BaseTimeWarpable(testContract) {}

  /// @notice Warps the time to a random timestamp.
  /// @param seed The seed used to generate the random timestamp
  function warp(uint256 seed) external useTimestamps {
    uint256 newTimestamp = bound(seed, block.timestamp + 1, block.timestamp + 30 days);
    vm.warp(newTimestamp);
  }

  function test() public override {}
}
