// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

interface IStakingOwner {
  /// @notice This event is emitted when the staking pool is opened for staking
  event PoolOpened();
  /// @notice This event is emitted when the staking pool is closed
  event PoolClosed();

  /// @notice This error is thrown when an invalid min operator stake amount is
  /// supplied
  error InvalidMinStakeAmount();
  /// @notice This error is raised when attempting to decrease maximum pool size
  /// @param maxPoolSize the proposed maximum pool size
  error InvalidPoolSize(uint256 maxPoolSize);
  /// @notice This error is raised when attempting to decrease maximum stake amount
  /// for the pool members
  /// @param maxStakeAmount the proposed maximum stake amount
  error InvalidMaxStakeAmount(uint256 maxStakeAmount);

  /// @notice This error is thrown when the staking pool is closed.
  error PoolNotOpen();

  /// @notice This error is thrown when the staking pool is open.
  error PoolNotClosed();

  /// @notice This error is thrown when the staking pool has been opened and contract manager tries
  /// to re-open.
  error PoolHasBeenOpened();

  /// @notice This error is thrown when the pool has been closed and contract manager tries to
  /// re-open
  error PoolHasBeenClosed();

  /// @notice Set the pool config
  /// @param maxPoolSize The max amount of staked LINK allowed in the pool
  /// @param maxPrincipalPerStaker The max amount of LINK a staker can stake
  /// in the pool.
  function setPoolConfig(uint256 maxPoolSize, uint256 maxPrincipalPerStaker) external;

  /// @notice Opens the pool for staking
  function open() external;

  /// @notice Closes the pool
  function close() external;

  /// @notice Sets the migration proxy contract address
  /// @param migrationProxy The migration proxy contract address
  function setMigrationProxy(address migrationProxy) external;
}
