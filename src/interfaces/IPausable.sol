// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

interface IPausable {
  /// @notice This function pauses the contract
  /// @dev Sets the pause flag to true
  function emergencyPause() external;

  /// @notice This function unpauses the contract
  /// @dev Sets the pause flag to false
  function emergencyUnpause() external;
}
