// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {BaseTestTimelocked} from './BaseTestTimelocked.t.sol';

contract CounterTest is BaseTestTimelocked {
  function testIncrement() public {
    changePrank(address(s_timelock));
    s_counter.increment();
    assertEq(s_counter.number(), 1);
  }

  function testSetNumber(uint256 x) public {
    changePrank(address(s_timelock));
    s_counter.setNumber(x);
    assertEq(s_counter.number(), x);
  }
}
