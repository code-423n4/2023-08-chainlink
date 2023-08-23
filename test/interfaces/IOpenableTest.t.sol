// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

interface IOpenableTest {
  function test_RevertWhen_NotOwnerOpens() external;
  function test_OwnerCanOpen() external;
  function test_RevertWhen_AlreadyOpened() external;
  function test_RevertWhen_NotOwnerCloses() external;
  function test_OwnerCanClose() external;
  function test_RevertWhen_NotYetOpened() external;
  function test_RevertWhen_AlreadyClosed() external;
  function test_RevertWhen_TryingToOpenAgain() external;
  function test_RevertWhen_RewardVaultNotOpen() external;
  function test_RevertWhen_RewardVaultPaused() external;
}
