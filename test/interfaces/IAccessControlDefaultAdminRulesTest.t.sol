// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

interface IAccessControlDefaultAdminRulesTest {
  function test_DefaultValuesAreInitialized() external;
  function test_RevertWhen_DirectlyGrantDefaultAdminRole() external;
  function test_RevertWhen_DirectlyRevokeDefaultAdminRole() external;
  function test_RevertWhen_NonAdminBeginsDefaultAdminTransfer() external;
  function test_CurrentAdminCanBeginDefaultAdminTransfer() external;
  function test_CurrentAdminCanOverwritePendingDefaultAdminTransfer() external;
  function test_CurrentAdminCanOverwriteDefaultAdminTransferAfterDelayPassedAndIfNotAccepted()
    external;
  function test_RevertWhen_NonAdminCancelPendingDefaultAdminTransfer() external;
  function test_CurrentAdminCanCancelPendingDefaultAdminTransfer() external;
  function test_RevertWhen_NonPendingDefaultAdminAcceptsTransfer() external;
  function test_RevertWhen_PendingDefaultAdminAcceptsTransferBeforeDelayPassed() external;
  function test_PendingDefaultAdminCanAcceptTransferImmediatelyIfDelayIsZero() external;
  function test_PendingDefaultAdminCanAcceptTransferAfterDelayPassed() external;
  function test_RevertWhen_NonAdminChangesDelay() external;
  function test_CurrentAdminCanChangeDelay() external;
  function test_RevertWhen_NonAdminRollbackDelayChange() external;
  function test_CurrentAdminCanRollbackDelayChange() external;
}
