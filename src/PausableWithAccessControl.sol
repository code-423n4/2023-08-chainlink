// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {AccessControlDefaultAdminRules} from
  '@openzeppelin/contracts/access/AccessControlDefaultAdminRules.sol';
import {Pausable} from '@openzeppelin/contracts/security/Pausable.sol';

import {IPausable} from './interfaces/IPausable.sol';

abstract contract PausableWithAccessControl is IPausable, Pausable, AccessControlDefaultAdminRules {
  /// @notice This is the ID for the pauser role, which is given to the addresses that can pause and
  /// unpause the contract.
  /// @dev Hash: 65d7a28e3265b37a6474929f336521b332c1681b933f6cb9f3376673440d862a
  bytes32 public constant PAUSER_ROLE = keccak256('PAUSER_ROLE');

  constructor(
    uint48 adminRoleTransferDelay,
    address defaultAdmin
  ) AccessControlDefaultAdminRules(adminRoleTransferDelay, defaultAdmin) {}

  /// @inheritdoc IPausable
  function emergencyPause() external override onlyRole(PAUSER_ROLE) {
    _pause();
  }

  /// @inheritdoc IPausable
  function emergencyUnpause() external override onlyRole(PAUSER_ROLE) {
    _unpause();
  }
}
