// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

interface IMigrationDataReceiver {
  /// @notice Function for receiving the data from the migration source.
  /// @param data The migration data.
  function receiveMigrationData(bytes calldata data) external;
}
