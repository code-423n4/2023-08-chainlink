// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

interface IMigratable {
  /// @notice This error is thrown when the owner tries to set the migration target to the
  /// zero address or an invalid address as well as when the migration target is not set and owner
  /// tries to migrate the contract.
  error InvalidMigrationTarget();

  /// @notice This event is emitted when the migration target is set
  /// @param oldMigrationTarget The previous migration target
  /// @param newMigrationTarget The updated migration target
  event MigrationTargetSet(address indexed oldMigrationTarget, address indexed newMigrationTarget);

  /// @notice Sets the address this contract will be upgraded to
  /// @param newMigrationTarget The address of the migration target
  function setMigrationTarget(address newMigrationTarget) external;

  /// @notice Returns the current migration target of the contract
  /// @return address The current migration target
  function getMigrationTarget() external view returns (address);

  /// @notice Migrates the contract
  /// @param data Optional calldata to call on new contract
  function migrate(bytes calldata data) external;
}
