// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {IRewardVault} from './IRewardVault.sol';
import {Checkpoints} from '@openzeppelin/contracts/utils/Checkpoints.sol';

interface IStakingPool {
  /// @notice This error is thrown when a caller tries to execute a transaction
  /// that they do not have permissions for
  error AccessForbidden();

  /// @notice This event is emitted when the migration proxy address has been set
  /// @param migrationProxy The migration proxy contract address
  event MigrationProxySet(address indexed migrationProxy);

  /// @notice This event is emitted when the staking pool's maximum size is
  /// increased
  /// @param maxPoolSize the new maximum pool size
  event PoolSizeIncreased(uint256 maxPoolSize);

  /// @notice This event is emitted when the maximum stake amount
  // for the stakers in the pool is increased
  /// @param maxPrincipalPerStaker the new maximum stake amount
  event MaxPrincipalAmountIncreased(uint256 maxPrincipalPerStaker);

  /// @notice This event is emitted when a staker adds stake to the pool.
  /// @param staker Staker address
  /// @param newStake New staked LINK amount staked
  /// @param totalStake Total staked LINK amount staked
  event Staked(address indexed staker, uint256 newStake, uint256 totalStake);

  /// @notice This event is emitted when a staker removes stake from the pool.
  /// @param staker Staker address
  /// @param amount Amount of stake removed
  /// @param claimedReward Amount of claimed rewards
  event Unstaked(address indexed staker, uint256 amount, uint256 claimedReward);

  /// @notice This error is thrown whenever a zero-address is supplied when
  /// a non-zero address is required
  error InvalidZeroAddress();

  /// @notice This error is thrown whenever the sender is not the LINK token
  error SenderNotLinkToken();

  /// @notice This error is thrown whenever the migration proxy address has not been set
  error MigrationProxyNotSet();

  /// @notice This error is thrown whenever the reward vault address has not been set
  error RewardVaultNotSet();

  /// @notice This error is thrown when invalid data is passed to the onTokenTransfer function
  error InvalidData();

  /// @notice This error is thrown when the staker tries to stake less than the min amount
  error InsufficientStakeAmount();

  /// @notice This error is thrown when the staker tries to stake more than the max amount
  error ExceedsMaxStakeAmount();

  /// @notice This error is thrown when the staker tries to stake more than the max pool size
  error ExceedsMaxPoolSize();

  /// @notice This error is raised when stakers attempt to exit the pool
  /// @param staker address of the staker
  error StakeNotFound(address staker);

  /// @notice This error is thrown when the staker tries to unstake a zero amount
  error UnstakeZeroAmount();

  /// @notice This error is thrown when the staker tries to unstake more than the
  /// staked LINK amount
  error UnstakeExceedsPrincipal();

  /// @notice This error is thrown when the staker tries to unstake an amount that leaves their
  /// staked LINK amount below the minimum amount
  error UnstakePrincipalBelowMinAmount();

  /// @notice This struct defines the state of a staker
  struct Staker {
    /// @notice The combined staked LINK amount and staked at time history
    /// @dev Both the staker staked LINK amount and staked at timestamp are stored in uint112 to
    /// save space
    /// @dev The max value of uint112 is greater than the total supply of LINK
    /// @dev The max value of uint112 can represent a timestamp in the year 3615, long after the
    /// staking program has ended
    /// @dev The combination is performed as such:
    /// uint224 history = (uint224(uint112(principal)) << 112) |
    /// uint224(uint112(stakedAtTime))
    Checkpoints.Trace224 history;
    /// @notice The staker's unbonding period end time
    uint128 unbondingPeriodEndsAt;
    /// @notice The staker's claim period end time
    uint128 claimPeriodEndsAt;
  }

  /// @notice Unstakes amount LINK tokens from the staker’s staked LINK amount
  /// Also claims all of the earned rewards if claimRewards is true
  /// @param amount The amount of LINK tokens to unstake
  /// @param shouldClaimReward If true will claim all reward
  function unstake(uint256 amount, bool shouldClaimReward) external;

  /// @notice Returns the total amount staked in the pool
  /// @return The total amount staked in pool
  function getTotalPrincipal() external view returns (uint256);

  /// @notice Returns the staker's staked LINK amount
  /// @param staker The address of the staker to query for
  /// @return uint256 The staker's staked LINK amount
  function getStakerPrincipal(address staker) external view returns (uint256);

  /// @notice Returns the staker's staked LINK amount
  /// @param staker The address of the staker to query for
  /// @param checkpointId The checkpoint ID to fetch the staker's balance for.  Pass 0
  /// to return the staker's latest staked LINK amount
  /// @return uint256 The staker's staked LINK amount
  function getStakerPrincipalAt(
    address staker,
    uint256 checkpointId
  ) external view returns (uint256);

  /// @notice Returns the staker's average staked at time
  /// @param staker The address of the staker to query for
  /// @return uint256 The staker's average staked at time
  function getStakerStakedAtTime(address staker) external view returns (uint256);

  /// @notice Returns the staker's average staked at time for a checkpoint ID
  /// @param staker The address of the staker to query for
  /// @param checkpointId The checkpoint to query for
  /// @return uint256 The staker's average staked at time
  function getStakerStakedAtTimeAt(
    address staker,
    uint256 checkpointId
  ) external view returns (uint256);

  /// @notice Returns the current reward vault address
  /// @return The reward vault
  function getRewardVault() external view returns (IRewardVault);

  /// @notice Returns the address of the LINK token contract
  /// @return The LINK token contract's address that is used by the pool
  function getChainlinkToken() external view returns (address);

  /// @notice Returns the migration proxy contract address
  /// @return The migration proxy contract address
  function getMigrationProxy() external view returns (address);

  /// @notice Returns a boolean that is true if the pool is open
  /// @return True if the pool is open, false otherwise
  function isOpen() external view returns (bool);

  /// @notice Returns a boolean that is true if the pool is active,
  /// i.e. is open and there are remaining rewards to vest in the pool.
  /// @return True if the pool is active, false otherwise
  function isActive() external view returns (bool);

  /// @notice Returns the minimum and maximum amounts a staker can stake in the
  /// pool
  /// @return uint256 minimum amount that can be staked by a staker
  /// @return uint256 maximum amount that can be staked by a staker
  function getStakerLimits() external view returns (uint256, uint256);

  /// @notice uint256 Returns the maximum amount that can be staked in the pool
  /// @return uint256 current maximum staking pool size
  function getMaxPoolSize() external view returns (uint256);
}
