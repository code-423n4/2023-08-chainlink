// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

interface IPausableTest {
  function test_RevertWhen_NotPauserEmergencyPause() external;
  function test_PauserCanEmergencyPause() external;
  function test_RevertWhen_PausingWhenAlreadyPaused() external;
  function test_RevertWhen_NotPauserEmergencyUnpause() external;
  function test_PauserCanEmergencyUnpause() external;
  function test_RevertWhen_UnpausingWhenAlreadyUnpaused() external;
}
