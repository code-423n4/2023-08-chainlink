// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

interface IBaseInvariantTest {
  function currentTimestamp() external view returns (uint256);
  function setCurrentTimestamp(uint256 currentTimestamp) external;
}
