// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

interface IAlertsControllerOwner {
  /// @notice Allows the contract owner to set the list of operator addresses who are
  /// subject to slashing.
  /// @param operators New list of operator staker addresses
  /// @param data Optional payload
  function setSlashableOperators(address[] calldata operators, bytes calldata data) external;

  /// @notice Returns the slashable operators.
  /// @param data Optional payload
  /// @return The list of slashable operators' addresses.
  function getSlashableOperators(bytes calldata data) external view returns (address[] memory);
}
