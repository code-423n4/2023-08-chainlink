// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {IMigratable} from './interfaces/IMigratable.sol';

abstract contract Migratable is IMigratable {
  /// @notice The address of the new contract that this contract will be upgraded to.
  address internal s_migrationTarget;

  /// @inheritdoc IMigratable
  function setMigrationTarget(address newMigrationTarget) external virtual override {
    _validateMigrationTarget(newMigrationTarget);

    address oldMigrationTarget = s_migrationTarget;
    s_migrationTarget = newMigrationTarget;

    emit MigrationTargetSet(oldMigrationTarget, newMigrationTarget);
  }

  /// @notice Helper function for validating the migration target
  /// @param newMigrationTarget The address of the new migration target
  function _validateMigrationTarget(address newMigrationTarget) internal virtual {
    if (
      newMigrationTarget == address(0) || newMigrationTarget == address(this)
        || newMigrationTarget == s_migrationTarget || newMigrationTarget.code.length == 0
    ) {
      revert InvalidMigrationTarget();
    }
  }

  /// @inheritdoc IMigratable
  function getMigrationTarget() external view virtual override returns (address) {
    return s_migrationTarget;
  }

  /// @dev Reverts if the migration target is not set
  modifier validateMigrationTargetSet() {
    if (s_migrationTarget == address(0)) {
      revert InvalidMigrationTarget();
    }
    _;
  }
}
