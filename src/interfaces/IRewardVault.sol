// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

interface IRewardVault {
  /// @notice This enum describes the different staker types
  enum StakerType {
    NOT_STAKED,
    COMMUNITY,
    OPERATOR
  }

  /// @notice This struct is used to store the reward information for a staker.
  struct StakerReward {
    /// @notice The staker's accrued multiplier-applied reward that's accounted for and stored.
    /// This is used for storing delegated rewards and preserving the staker's past rewards between
    /// unstakes or multiplier resets.
    /// To get the full claimable reward amount, this value is added to the stored reward *
    /// multiplier.
    /// @dev This value is reset when a staker calls claimRewards and rewards
    /// are transferred to the staker.
    uint112 finalizedBaseReward;
    /// @notice The staker's accrued delegated reward that's accounted for and stored.
    /// Delegated rewards are not subject to the ramp up multiplier and are immediately finalized.
    /// @dev This value is reset when a staker calls claimRewards and rewards
    /// are transferred to the staker.
    uint112 finalizedDelegatedReward;
    /// @notice The last updated per-token base reward of the staker.  This
    /// value only increases over time
    uint112 baseRewardPerToken;
    /// @notice The last updated per-token delegated reward of the operator
    uint112 operatorDelegatedRewardPerToken;
    /// @notice The amount of base rewards that the staker has claimed between
    /// the last time they staked/unstaked until they stake, unstake again or
    /// when an operator is removed
    /// @dev This is reset to 0 whenever finalizeReward is called
    /// @dev This is set to finalizedBaseReward whenever claimReward is called
    /// @dev Invariant: The sum of storedBaseReward and claimedBaseRewardsInPeriod
    /// is the total amount of base rewards a staker has earned since the last time
    /// they stake/unstake.
    uint112 claimedBaseRewardsInPeriod;
    /// @notice The staker type
    /// @dev This value is set once the first time a staker stakes. This value is used to enforce
    /// that a community staker is not added as an operator is not already staking as a community
    /// member.
    StakerType stakerType;
    /// @notice The staker's earned base rewards before their multiplier is
    /// applied.  To get the full claimable base reward amount, the staker's current multiplier
    /// is applied to this value and added to the rewards that the multiplier has
    /// already been applied to.
    /// @dev This field has intentionally been left as uint256 as it will still
    /// occupy an extra storage slot regardless due to there being an odd
    /// number of variables in this struct.  Leaving it as uint256 will save
    /// some gas as it the code will not have to convert between uint sizes
    /// during computation.
    /// @dev This value is increased by the amount of newly earned base rewards
    /// whenever a staker performs an action i.e in claimReward and finalizeReward.
    /// @dev This value is set to 0 in _applyMultiplier whenever rewards should be forfeited
    /// @dev This value is set to the amount of rewards a staker is not able to
    /// claim due to not reaching the maximum ramp up multiplier when
    /// _applyMultiplier is called and no rewards are being forfeited.
    /// @dev Invariant: The sum of earnedBaseRewardInPeriod and claimedBaseRewardsInPeriod
    /// is the total amount of base rewards a staker has earned since the last time
    /// they stake/unstake.
    uint256 storedBaseReward;
    /// @notice The amount of base rewards the staker has earned between
    /// the last time they staked, unstake or claim rewards until they stake, unstake or claim
    /// rewards again.  Unit is juels
    /// @dev This is reset to 0 whenever finalizeReward or claimReward is called
    /// @dev This value is different than the finalizedBaseReward as it tracks
    /// the amount of rewards a staker has earned since the last time they have
    /// staked, unstaked or claimed rewards instead of the total amount of base
    /// rewards the staked has earned over their lifetime.
    /// @dev Invariant: The sum of earnedBaseRewardInPeriod and claimedBaseRewardsInPeriod
    /// is the total amount of base rewards a staker has earned since the last time
    /// they stake/unstake.
    uint256 earnedBaseRewardInPeriod;
  }

  /// @notice Claims reward earned by a staker
  /// Called by staking pools to forward claim requests from stakers or called by the stakers
  /// themselves.
  /// @return uint256 The amount of rewards claimed in juels
  function claimReward() external returns (uint256);

  /// @notice Updates the staking pools' reward per token and staker’s reward state
  /// in the reward vault.  This function is called whenever the staker's reward
  /// state needs to be updated without resetting their multiplier
  /// @dev This is called whenever an operator is slashed as we want to update
  /// the operator's rewards state without resetting their multiplier.
  /// @param staker The staker's address. If this is set to zero address,
  /// staker's reward update will be skipped
  /// @param stakerPrincipal The staker's current staked LINK amount in juels
  function updateReward(address staker, uint256 stakerPrincipal) external;

  /// @notice Finalizes the staker's reward and resets their multiplier.
  /// This will apply the staker's current ramp up multiplier to their
  /// earned rewards and store the amount of rewards they have earned before
  /// their multiplier is reset.
  /// @dev This is called whenever 1) A staker stakes 2) A staker unstakes
  /// 3) An operator is removed as we want to update the staker's
  /// rewards AND reset their multiplier.
  /// @dev Staker rewards are not forfeited when they stake before they have
  /// reached their maximum ramp up period multiplier.  Instead these
  /// rewards are stored as already earned rewards and will be subject to the
  /// multiplier the next time the contract calculates the staker's claimable
  /// rewards.
  /// @dev Staker rewards are forfeited when a staker unstakes before they
  /// have reached their maximum ramp up period multiplier.  Additionally an
  /// operator will also forfeit any unclaimable rewards if they are removed
  /// before they reach the maximum ramp up period multiplier.  The amount of
  /// rewards forfeited is proportional to the amount unstaked relative to
  /// the staker's total staked LINK amount when unstaking.  A removed operator forfeits
  /// 100% of their unclaimable rewards.
  /// @param staker The staker addres
  /// @param oldPrincipal The staker's staked LINK amount before finalizing
  /// @param stakedAt The last time the staker staked at
  /// @param unstakedAmount The amount that the staker has unstaked in juels
  /// @param shouldClaim True if rewards should be transferred to the staker
  /// @return The claimed reward amount.
  function finalizeReward(
    address staker,
    uint256 oldPrincipal,
    uint256 stakedAt,
    uint256 unstakedAmount,
    bool shouldClaim
  ) external returns (uint256);

  /// @notice Closes the reward vault, disabling adding rewards and staking
  function close() external;

  /// @notice Returns a boolean that is true if the reward vault is open
  /// @return True if open, false otherwise
  function isOpen() external view returns (bool);

  /// @notice Returns the rewards that the staker would get if they withdraw now
  /// Rewards calculation is based on the staker's multiplier
  /// @param staker The staker's address
  /// @return The reward amount
  function getReward(address staker) external view returns (uint256);

  /// @notice Returns the stored reward info of the staker
  /// @param staker The staker address
  /// @return The staker's stored reward info
  function getStoredReward(address staker) external view returns (StakerReward memory);

  /// @notice Returns whether or not the vault is paused
  /// @return bool True if the vault is paused
  function isPaused() external view returns (bool);

  /// @notice Returns whether or not the reward duration for the pool has ended
  /// @param stakingPool The address of the staking pool rewards are being shared to
  /// @return bool True if the reward duration has ended
  function hasRewardDurationEnded(address stakingPool) external view returns (bool);
}
