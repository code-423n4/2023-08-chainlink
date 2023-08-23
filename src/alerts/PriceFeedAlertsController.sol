// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {AggregatorV3Interface} from
  '@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol';
import {TypeAndVersionInterface} from
  '@chainlink/contracts/src/v0.8/interfaces/TypeAndVersionInterface.sol';

import {IERC165} from '@openzeppelin/contracts/interfaces/IERC165.sol';
import {Checkpoints} from '@openzeppelin/contracts/utils/Checkpoints.sol';

import {IMigratable} from '../interfaces/IMigratable.sol';
import {IMigrationDataReceiver} from '../interfaces/IMigrationDataReceiver.sol';
import {Migratable} from '../Migratable.sol';
import {PausableWithAccessControl} from '../PausableWithAccessControl.sol';
import {CommunityStakingPool} from '../pools/CommunityStakingPool.sol';
import {OperatorStakingPool} from '../pools/OperatorStakingPool.sol';

/// @notice This contract allows alerters to raise alerts for feeds that are down.
/// @dev When an alert is raised, the operators of the feed are slashed and the alerter is rewarded
/// by the operator staking pool.
/// @dev invariant An alert can only be raised for a feed if the feed is stale.
/// @dev invariant An alert can only be raised for a feed if the alerter is staking in one of the
/// staking pools.
/// @dev invariant Only one alert can be raised for a feed per round.
contract PriceFeedAlertsController is
  Migratable,
  PausableWithAccessControl,
  TypeAndVersionInterface
{
  using Checkpoints for Checkpoints.Trace224;

  /// @notice This error is thrown whenever a zero-address is supplied when
  /// a non-zero address is required
  error InvalidZeroAddress();
  /// @notice This error is thrown when an invalid priority period threshold is supplied.
  error InvalidPriorityPeriodThreshold();
  /// @notice This error is thrown when an invalid regular period threshold is supplied.
  error InvalidRegularPeriodThreshold();
  /// @notice This error is thrown when the AlertsController hasn't been set as the slasher by the
  /// staking contract.
  error DoesNotHaveSlasherRole();
  /// @notice Surfaces the required pool status to perform an operation
  /// @param currentStatus current status of the pool (true if open / false if closed)
  /// @param requiredStatus required status of the pool to proceed
  /// (true if pool must be open / false if pool must be closed)
  error InvalidPoolStatus(bool currentStatus, bool requiredStatus);
  /// @notice This error is thrown when the given feed is not known to this AlertsController.
  error FeedDoesNotExist();
  /// @notice This error is thrown when the operator list is invalid.
  error InvalidOperatorList();
  /// @notice This error is thrown when the feed's slashable amount is 0 or
  /// greater than the max operator stake staked LINK
  error InvalidSlashableAmount();
  /// @notice This error is thrown when the alerter reward amount is 0
  error InvalidAlerterRewardAmount();
  /// @notice This error is thrown when alerting conditions are not met and the
  /// alert is invalid.
  error AlertInvalid();

  /// @notice Emitted when a valid alert is raised for a feed round
  /// @param alerter The address of an alerter
  /// @param roundId The feed's round ID that an alert has been raised for
  /// @param rewardAmount The amount of juels rewarded to the alerter
  event AlertRaised(address indexed alerter, uint256 indexed roundId, uint96 rewardAmount);

  /// @notice This event is emitted when a feed config is set.
  /// @param feed The address of the feed an alert was configured for
  /// @param priorityPeriodThreshold The configured priority period threshold
  /// @param regularPeriodThreshold The configured regular period threshold
  /// @param slashableAmount The configured amount of juels each operator should be slashed
  /// when the feed is down
  /// @param alerterRewardAmount The configured amount of juels an alerter will be rewarded
  event FeedConfigSet(
    address indexed feed,
    uint32 priorityPeriodThreshold,
    uint32 regularPeriodThreshold,
    uint96 slashableAmount,
    uint96 alerterRewardAmount
  );
  /// @notice This event is emitted when a feed config is removed.
  /// @param feed The address of the feed the config was removed for
  event FeedConfigRemoved(address indexed feed);

  /// @notice This event is emitted when a slashable operator list is set.
  /// @param feed The address of the feed the slashable operators were set for
  /// @param operators The slashable operators
  event SlashableOperatorsSet(address indexed feed, address[] operators);

  /// @notice this event is emitted when a community staking pool is set
  /// @param oldCommunityStakingPool The old community staking pool
  /// @param newCommunityStakingPool The new community staking pool
  event CommunityStakingPoolSet(
    address indexed oldCommunityStakingPool, address indexed newCommunityStakingPool
  );

  /// @notice this event is emitted when an operator staking pool is set
  /// @param oldOperatorStakingPool The old operator staking pool
  /// @param newOperatorStakingPool The new operator staking pool
  event OperatorStakingPoolSet(
    address indexed oldOperatorStakingPool, address indexed newOperatorStakingPool
  );

  /// @notice This event is emitted when the migration data is sent to the migration target
  /// @param migrationTarget The migration target
  /// @param feeds The list of feeds that the migration data is sent for
  /// @param migrationData The migration data
  event MigrationDataSent(address indexed migrationTarget, address[] feeds, bytes migrationData);

  /// @notice This event is emitted when the alerts controller is migrated.
  /// @param migrationTarget The migration target
  event AlertsControllerMigrated(address indexed migrationTarget);

  /// @notice This struct defines the params required by the AlertsController contract's
  /// constructor.
  struct ConstructorParams {
    /// @notice The community staking pool contract
    CommunityStakingPool communityStakingPool;
    /// @notice The operator staking pool contract
    OperatorStakingPool operatorStakingPool;
    /// @notice The feed configs and slashable operators
    ConstructorFeedConfigParams[] feedConfigs;
    /// @notice The time it requires to transfer admin role
    uint48 adminRoleTransferDelay;
  }

  /// @notice The struct defines the parameters for setting feed configs in the constructor
  struct ConstructorFeedConfigParams {
    /// @notice The feed address to set the config for
    address feed;
    /// @notice The number of seconds until the feed is considered stale
    /// and the priority period begins.
    /// max value of uint32 is a timestamp in the year 2106, long after the staking program has
    /// ended
    uint32 priorityPeriodThreshold;
    /// @notice The number of seconds until the priority period ends
    /// and the regular period begins.
    /// max value of uint32 is a timestamp in the year 2106, long after the staking program has
    /// ended
    uint32 regularPeriodThreshold;
    /// @notice The amount of juels each operator will be slashed when an
    /// alert is raised for the feed being down
    /// max value of uint96 is greated than total supply of LINK
    uint96 slashableAmount;
    /// @notice The amount of juels an alerter will receive for successfully
    /// raising an alert for a feed
    /// max value of uint96 is greated than total supply of LINK
    uint96 alerterRewardAmount;
    /// @notice The slashable (on-feed) operators
    address[] slashableOperators;
  }

  /// @notice The struct defines the parameters for the `setFeedConfig` function.
  struct SetFeedConfigParams {
    /// @notice The feed address to set the config for
    address feed;
    /// @notice The number of seconds until the feed is considered stale
    /// and the priority period begins.
    /// max value of uint32 is a timestamp in the year 2106, long after the staking program has
    /// ended
    uint32 priorityPeriodThreshold;
    /// @notice The number of seconds until the priority period ends
    /// and the regular period begins.
    /// max value of uint32 is a timestamp in the year 2106, long after the staking program has
    /// ended
    uint32 regularPeriodThreshold;
    /// @notice The amount of juels each operator will be slashed when an
    /// alert is raised for the feed being down
    /// max value of uint96 is greated than total supply of LINK
    uint96 slashableAmount;
    /// @notice The amount of juels an alerter will receive for successfully
    /// raising an alert for a feed
    /// max value of uint96 is greated than total supply of LINK
    uint96 alerterRewardAmount;
  }

  /// @notice This struct defines the configs for each feed that alerts can be raised for.
  struct FeedConfig {
    /// @notice The number of seconds until the feed is considered stale
    /// and the priority period begins.
    /// max value of uint32 is a timestamp in the year 2106, long after the staking program has
    /// ended
    uint32 priorityPeriodThreshold;
    /// @notice The number of seconds until the priority period ends
    /// and the regular period begins.
    /// max value of uint32 is a timestamp in the year 2106, long after the staking program has
    /// ended
    uint32 regularPeriodThreshold;
    /// @notice The amount of juels each operator will be slashed when an
    /// alert is raised for the feed being down
    /// max value of uint96 is greated than total supply of LINK
    uint96 slashableAmount;
    /// @notice The amount of juels an alerter will receive for successfully
    /// raising an alert for a feed
    /// max value of uint96 is greated than total supply of LINK
    uint96 alerterRewardAmount;
  }

  /// @notice This struct defines the last alerted round ID of a feed.
  /// @dev This is used when a feed's round ID data is migrated to the migration target.
  struct LastAlertedRoundId {
    /// @notice The feed address
    address feed;
    /// @notice The last alerted round ID of the feed
    uint256 roundId;
  }

  /// @notice The return values of the `_canAlert` function
  /// @dev This struct is for internal use, it was introduced to help with gas savings
  struct CanAlertReturnValues {
    /// @notice True if the alerter can alert, false otherwise
    bool canAlert;
    /// @notice The round ID of the feed
    uint256 roundId;
    /// @notice The feed config
    FeedConfig feedConfig;
  }

  /// @notice The community staking pool contract
  CommunityStakingPool private s_communityStakingPool;
  /// @notice The Node Operator staking contract.
  OperatorStakingPool private s_operatorStakingPool;
  /// @notice The feeds that alerters can raise alerts for.
  mapping(address => FeedConfig) private s_feedConfigs;
  /// @notice The slashable operators of each feed
  mapping(address => address[]) private s_feedSlashableOperators;
  /// @notice The round ID of the last feed round an alert was raised
  mapping(address => uint256) private s_lastAlertedRoundIds;

  constructor(ConstructorParams memory params)
    PausableWithAccessControl(params.adminRoleTransferDelay, msg.sender)
  {
    if (address(params.communityStakingPool) == address(0)) {
      revert InvalidZeroAddress();
    }
    if (address(params.operatorStakingPool) == address(0)) {
      revert InvalidZeroAddress();
    }

    s_communityStakingPool = params.communityStakingPool;
    s_operatorStakingPool = params.operatorStakingPool;

    SetFeedConfigParams[] memory setFeedConfigParams = new SetFeedConfigParams[](1);
    for (uint256 i; i < params.feedConfigs.length; ++i) {
      ConstructorFeedConfigParams memory config = params.feedConfigs[i];
      setFeedConfigParams[0] = SetFeedConfigParams({
        feed: config.feed,
        priorityPeriodThreshold: config.priorityPeriodThreshold,
        regularPeriodThreshold: config.regularPeriodThreshold,
        slashableAmount: config.slashableAmount,
        alerterRewardAmount: config.alerterRewardAmount
      });
      _setFeedConfigs(setFeedConfigParams);

      _setSlashableOperators(config.feed, config.slashableOperators);
    }
  }

  /// @notice Sets the community staking pool
  /// @param newCommunityStakingPool The community staking pool
  function setCommunityStakingPool(CommunityStakingPool newCommunityStakingPool)
    external
    onlyRole(DEFAULT_ADMIN_ROLE)
  {
    if (address(newCommunityStakingPool) == address(0)) revert InvalidZeroAddress();

    CommunityStakingPool oldCommunityStakingPool = s_communityStakingPool;
    s_communityStakingPool = newCommunityStakingPool;
    emit CommunityStakingPoolSet(address(oldCommunityStakingPool), address(newCommunityStakingPool));
  }

  /// @notice Sets the operator staking pool
  /// @param newOperatorStakingPool The operator staking pool
  function setOperatorStakingPool(OperatorStakingPool newOperatorStakingPool)
    external
    onlyRole(DEFAULT_ADMIN_ROLE)
  {
    if (address(newOperatorStakingPool) == address(0)) revert InvalidZeroAddress();

    OperatorStakingPool oldOperatorStakingPool = s_operatorStakingPool;
    s_operatorStakingPool = newOperatorStakingPool;
    emit OperatorStakingPoolSet(address(oldOperatorStakingPool), address(newOperatorStakingPool));
  }

  /// @notice Sets the feed config of one or more feeds
  /// @param configs The array of feed configs and the feed address to set the config
  /// @dev precondition The caller must be the default admin
  function setFeedConfigs(SetFeedConfigParams[] calldata configs)
    external
    onlyRole(DEFAULT_ADMIN_ROLE)
  {
    _setFeedConfigs(configs);
  }

  /// @notice Removes the feed's config and resets the last alerted round ID and
  /// slashable operators of the feed.
  /// @param feed The address of the feed to remove
  /// @dev precondition The caller must be the default admin
  function removeFeedConfig(address feed) external onlyRole(DEFAULT_ADMIN_ROLE) {
    if (s_feedConfigs[feed].priorityPeriodThreshold == 0) {
      revert FeedDoesNotExist();
    }

    delete s_feedConfigs[feed];
    delete s_lastAlertedRoundIds[feed];
    delete s_feedSlashableOperators[feed];

    emit FeedConfigRemoved(feed);
  }

  /// @notice Returns the config of the given feed
  /// @param feed The feed address
  /// @return The config of the feed
  function getFeedConfig(address feed) external view returns (FeedConfig memory) {
    return s_feedConfigs[feed];
  }

  /// @notice This function creates an alert for an unhealthy Chainlink feed
  /// @param feed The address of the feed being alerted on
  /// @dev The PriceFeedAlertsControllers should encode the feed address and
  /// pass it as the data arg.
  /// @dev precondition This contract must not be in paused state
  /// @dev precondition The feed slashing condition must be registered by the admin
  /// @dev The operator staking pool must be active
  /// @dev precondition This contract must be given the slasher role in the operator staking
  /// contract
  /// @dev precondition The caller must be staking in one of the staking pools
  /// @dev precondition The feed must be stale (in the priority or regular period)
  /// @dev precondition No alert has been raised for the feed in the current round
  function raiseAlert(address feed) external whenNotPaused {
    CanAlertReturnValues memory returnValues = _canAlert(msg.sender, feed);
    if (!returnValues.canAlert) revert AlertInvalid();

    s_lastAlertedRoundIds[feed] = returnValues.roundId;

    // slash the operators with the values found in the feed config
    s_operatorStakingPool.slashAndReward({
      stakers: s_feedSlashableOperators[feed],
      alerter: msg.sender,
      principalAmount: returnValues.feedConfig.slashableAmount,
      alerterRewardAmount: returnValues.feedConfig.alerterRewardAmount
    });

    emit AlertRaised(msg.sender, returnValues.roundId, returnValues.feedConfig.alerterRewardAmount);
  }

  /// @notice This function returns true if the alerter may raise an alert
  /// to claim rewards and false otherwise
  /// @param alerter The alerter's address
  /// @param feed The address of the feed being queried for
  /// @return True if alerter can alert, false otherwise
  function canAlert(address alerter, address feed) external view returns (bool) {
    CanAlertReturnValues memory returnValues = _canAlert(alerter, feed);
    return !paused() && s_operatorStakingPool.isActive() && returnValues.canAlert;
  }

  /// @notice This function returns the staking pools connected to this alerts controller
  /// @return address[] The staking pools
  function getStakingPools() external view returns (address[] memory) {
    address[] memory pools = new address[](2);
    pools[0] = address(s_operatorStakingPool);
    pools[1] = address(s_communityStakingPool);
    return pools;
  }

  /// @notice Allows the contract owner to set the list of operator addresses who are
  /// subject to slashing.
  /// @param operators New list of operator staker addresses
  /// @param feed The address of the feed to set slashable operators for
  /// @dev precondition The caller must be the default admin
  function setSlashableOperators(
    address[] calldata operators,
    address feed
  ) external onlyRole(DEFAULT_ADMIN_ROLE) {
    if (feed == address(0)) revert InvalidZeroAddress();

    FeedConfig storage config = s_feedConfigs[feed];
    if (config.priorityPeriodThreshold == 0) revert FeedDoesNotExist();

    _setSlashableOperators(feed, operators);
  }

  /// @notice Returns the slashable operators.
  /// @param feed The feed address to get slashable operators for
  /// @return The list of slashable operators' addresses.
  function getSlashableOperators(address feed) external view returns (address[] memory) {
    return s_feedSlashableOperators[feed];
  }

  // ===========
  // IMigratable
  // ===========

  /// @inheritdoc IMigratable
  /// @dev Renounces the slasher role of self from the staking contract.
  /// @dev precondition The caller must be the default admin
  /// @dev precondition This contract should have the slasher role on the operator staking pool
  /// @dev precondition The migration target should be set
  function migrate(bytes calldata)
    external
    override(IMigratable)
    onlyRole(DEFAULT_ADMIN_ROLE)
    withSlasherRole
    validateMigrationTargetSet
  {
    s_operatorStakingPool.renounceRole(s_operatorStakingPool.SLASHER_ROLE(), address(this));

    emit AlertsControllerMigrated(s_migrationTarget);
  }

  /// @inheritdoc Migratable
  /// @dev This function is called when setting the migration target to validate the migration
  /// target
  /// @dev precondition The caller must be the default admin
  /// @dev precondition The migration target must implement the IMigrationDataReceiver interface
  function _validateMigrationTarget(address newMigrationTarget)
    internal
    override(Migratable)
    onlyRole(DEFAULT_ADMIN_ROLE)
  {
    Migratable._validateMigrationTarget(newMigrationTarget);
    if (
      !IERC165(newMigrationTarget).supportsInterface(
        IMigrationDataReceiver.receiveMigrationData.selector
      )
    ) {
      revert InvalidMigrationTarget();
    }
  }

  /// @notice Function for migrating the data to the migration target.
  /// @param feeds The list of feed addresses to migrate the data for.
  /// @dev precondition The caller must be the default admin
  /// @dev precondition The migration target must be set
  /// @dev precondition The `feeds` should be registered in this contract
  function sendMigrationData(address[] calldata feeds)
    external
    onlyRole(DEFAULT_ADMIN_ROLE)
    validateMigrationTargetSet
  {
    LastAlertedRoundId[] memory lastAlertedRoundIds = new LastAlertedRoundId[](feeds.length);
    for (uint256 i; i < feeds.length; ++i) {
      address feed = feeds[i];
      if (s_feedConfigs[feed].priorityPeriodThreshold == 0) {
        revert FeedDoesNotExist();
      }
      lastAlertedRoundIds[i] =
        LastAlertedRoundId({feed: feed, roundId: s_lastAlertedRoundIds[feed]});

      // remove the feed config so future alerts can't be raised, and keep the last alerted round ID
      // of the feed for reference
      delete s_feedConfigs[feed];
      emit FeedConfigRemoved(feed);
    }

    bytes memory migrationData = abi.encode(lastAlertedRoundIds);

    IMigrationDataReceiver(s_migrationTarget).receiveMigrationData(migrationData);

    emit MigrationDataSent(s_migrationTarget, feeds, migrationData);
  }

  // =======
  // Private
  // =======

  /// @notice Util function to set the feed config of one or more feeds
  /// @param configs The array of feed configs and the feed address to set the config
  /// @dev operational guarantee that slashCapacity <= configParams.slashableAmount * numNops
  /// Code guarantee results in circular dependency between PFAC creation using setFeedConfig and
  /// created PFAC having slasher with sufficient slash capacity
  function _setFeedConfigs(SetFeedConfigParams[] memory configs) private {
    (, uint256 operatorMaxPrincipal) = s_operatorStakingPool.getStakerLimits();
    for (uint256 i; i < configs.length; ++i) {
      SetFeedConfigParams memory configParams = configs[i];
      if (configParams.feed == address(0)) revert InvalidZeroAddress();
      if (configParams.priorityPeriodThreshold == 0) {
        revert InvalidPriorityPeriodThreshold();
      }
      if (configParams.regularPeriodThreshold < configParams.priorityPeriodThreshold) {
        revert InvalidRegularPeriodThreshold();
      }
      if (configParams.slashableAmount == 0 || configParams.slashableAmount > operatorMaxPrincipal)
      {
        revert InvalidSlashableAmount();
      }
      if (configParams.alerterRewardAmount == 0) {
        revert InvalidAlerterRewardAmount();
      }

      FeedConfig storage config = s_feedConfigs[configParams.feed];
      config.priorityPeriodThreshold = configParams.priorityPeriodThreshold;
      config.regularPeriodThreshold = configParams.regularPeriodThreshold;
      config.slashableAmount = configParams.slashableAmount;
      config.alerterRewardAmount = configParams.alerterRewardAmount;

      emit FeedConfigSet(
        configParams.feed,
        configParams.priorityPeriodThreshold,
        configParams.regularPeriodThreshold,
        configParams.slashableAmount,
        configParams.alerterRewardAmount
      );
    }
  }

  /// @notice Helper function to check whether an alerter can raise an alert
  /// for a feed.
  /// @param alerter The alerter's address
  /// @param feed The feed address
  /// @return A CanAlertReturnValues struct, which contains a canAlert boolean, the round id, and
  /// the feed config
  function _canAlert(
    address alerter,
    address feed
  ) private view returns (CanAlertReturnValues memory) {
    (uint256 roundId,,, uint256 updatedAt,) = AggregatorV3Interface(feed).latestRoundData();
    FeedConfig memory feedConfig = s_feedConfigs[feed];
    CanAlertReturnValues memory returnValues =
      CanAlertReturnValues({canAlert: false, roundId: roundId, feedConfig: feedConfig});

    if (
      !_hasSlasherRole() || feedConfig.priorityPeriodThreshold == 0
        || s_lastAlertedRoundIds[feed] >= roundId
    ) return returnValues;

    // must be staking to alert
    uint256 principalInOperatorPool = s_operatorStakingPool.getStakerPrincipal(alerter);
    uint256 principalInCommunityStakingPool = s_communityStakingPool.getStakerPrincipal(alerter);
    if (principalInOperatorPool == 0 && principalInCommunityStakingPool == 0) return returnValues;

    // nobody can (feed is not stale)
    if (block.timestamp < updatedAt + feedConfig.priorityPeriodThreshold) return returnValues;

    // all stakers can (regular alerters)
    if (block.timestamp >= updatedAt + feedConfig.regularPeriodThreshold) {
      returnValues.canAlert = true;
      return returnValues;
    }

    // only operators can (priority alerters)
    returnValues.canAlert = s_operatorStakingPool.isOperator(alerter);
    return returnValues;
  }

  /// @notice Helper function for checking if this contract has the slasher role
  function _hasSlasherRole() private view returns (bool) {
    return s_operatorStakingPool.hasRole(s_operatorStakingPool.SLASHER_ROLE(), address(this));
  }

  /// @notice Helper function for setting the slashable operators of a feed
  /// @param feed The feed address
  /// @param operators The slashable operators
  function _setSlashableOperators(address feed, address[] memory operators) private {
    for (uint256 i; i < operators.length; ++i) {
      address operator = operators[i];
      // verify input list is sorted and addresses are unique
      if (i < operators.length - 1 && operator >= operators[i + 1]) {
        revert InvalidOperatorList();
      }
      if (operator == address(0)) revert InvalidZeroAddress();
    }

    s_feedSlashableOperators[feed] = operators;
    emit SlashableOperatorsSet(feed, operators);
  }

  // =========
  // Modifiers
  // =========

  /// @dev Reverts if the alerts controller doesn't have the slasher role
  /// in the staking contract
  modifier withSlasherRole() {
    if (!_hasSlasherRole()) revert DoesNotHaveSlasherRole();
    _;
  }

  /// @inheritdoc TypeAndVersionInterface
  function typeAndVersion() external pure virtual override returns (string memory) {
    return 'PriceFeedAlertsController 1.0.0';
  }
}
