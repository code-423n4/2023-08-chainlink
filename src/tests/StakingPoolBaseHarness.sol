// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {StakingPoolBase} from '../pools/StakingPoolBase.sol';

contract StakingPoolBaseHarness is StakingPoolBase {
  constructor(ConstructorParamsBase memory params) StakingPoolBase(params) {}

  function _validateOnTokenTransfer(address, address, bytes calldata) internal pure override {
    revert('Not implemented');
  }

  function _handleOpen() internal pure override {
    revert('Not implemented');
  }

  /// @dev This function is needed to bypass the whenOpen checks
  /// in StakingPoolBase functions while keeping _handleOpen unimplemented.
  function setIsOpen(bool isOpen) external onlyRole(DEFAULT_ADMIN_ROLE) {
    s_isOpen = isOpen;
  }
}
