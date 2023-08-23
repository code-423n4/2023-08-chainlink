// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

interface IAlertsController {
  /// @notice This function creates an alert for an unhealthy Chainlink service
  /// @param data Optional payload
  function raiseAlert(bytes calldata data) external;

  /// @notice This function returns true if the alerter may raise an alert
  /// to claim rewards and false otherwise
  /// @param alerter The alerter's address
  /// @param data Optional payload
  /// @return True if alerter can alert, false otherwise
  function canAlert(address alerter, bytes calldata data) external view returns (bool);

  /// @notice This function returns the staking pools connected to this alerts controller
  /// @return address[] The staking pools
  function getStakingPools() external view returns (address[] memory);
}
