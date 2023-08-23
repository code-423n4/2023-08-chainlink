// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Test} from 'forge-std/Test.sol';
import {IBaseInvariantTest} from '../../interfaces/IInvariantTest.t.sol';

/// @title This contract is used to warp and preserve current time for the targeted
/// contracts/functions. All invariant target contracts should inherit from this contract.
contract BaseTimeWarpable is Test {
  /// @notice The BaseInvariant test contract
  IBaseInvariantTest i_testContract;

  constructor(IBaseInvariantTest testContract) {
    i_testContract = testContract;
  }

  /// @notice Warps the time to the current stored timestamp in the test contract before executing a
  /// function and updates the current timestamp after the function execution.
  modifier useTimestamps() {
    vm.warp(i_testContract.currentTimestamp());
    _;
    i_testContract.setCurrentTimestamp(block.timestamp);
  }

  function test() public virtual {}
}
