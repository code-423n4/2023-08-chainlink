// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

interface ISlashable {
  /// @notice This error is thrown when the slasher config is invalid
  error InvalidSlasherConfig();

  /// @notice This error is thrown when the contract manager tries to set the slasher role directly
  /// through
  /// `grantRole`
  error InvalidRole();

  /// @notice This error is thrown then the contract manager tries to set the slasher config for an
  /// address
  /// that doesn't have the slasher role
  error InvalidSlasher();

  /// @notice This struct defines the parameters of the slasher config
  struct SlasherConfig {
    /// @notice The pool's refill rate (Juels/sec)
    uint256 refillRate;
    /// @notice The refillable slash capacity amount
    uint256 slashCapacity;
  }

  /// @notice This struct defines the parameters of the slasher state
  struct SlasherState {
    /// @notice The last slash timestamp, will be 0 if never slashed
    /// The timestamp will be set to the time the slashing configuration was configured
    /// instead of 0 if slashing never occurs, refilling slash capacity to full.
    uint256 lastSlashTimestamp;
    /// @notice The current amount of remaining slash capacity
    uint256 remainingSlashCapacityAmount;
  }

  /// @notice Adds a new slasher with the given config
  /// @param slasher The address of the slasher
  /// @param config The slasher config
  function addSlasher(address slasher, SlasherConfig calldata config) external;

  /// @notice Sets the slasher config
  /// @param slasher The address of the slasher
  /// @param config The slasher config
  function setSlasherConfig(address slasher, SlasherConfig calldata config) external;

  /// @notice Returns the slasher config
  /// @param slasher The slasher
  /// @return The slasher config
  function getSlasherConfig(address slasher) external view returns (SlasherConfig memory);

  /// @notice Returns the slash capacity for a slasher
  /// @param slasher The slasher
  /// @return The slash capacity
  function getSlashCapacity(address slasher) external view returns (uint256);

  /// @notice Slashes stakers and rewards the alerter.  Moves slashed staker
  /// funds into the alerter reward funds.  The alerter is then
  /// rewarded by the funds in the alerter reward funds.
  /// @param stakers The list of stakers to slash
  /// @param alerter The alerter that successfully raised the alert
  /// @param principalAmount The amount of the staker's staked LINK amount to slash
  /// @param alerterRewardAmount The reward amount to be given to the alerter
  function slashAndReward(
    address[] calldata stakers,
    address alerter,
    uint256 principalAmount,
    uint256 alerterRewardAmount
  ) external;
}
