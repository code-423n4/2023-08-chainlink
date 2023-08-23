// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {ConfirmedOwner} from '@chainlink/contracts/src/v0.8/ConfirmedOwner.sol';
import {AggregatorV3Interface} from
  '@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol';

import {ERC165} from '@openzeppelin/contracts/utils/introspection/ERC165.sol';

import {IMigrationDataReceiver} from '../interfaces/IMigrationDataReceiver.sol';

/// @notice This is a sample PriceFeedAlertsController version 2 contract.
/// @dev The next version of PriceFeedAlertsController contract will need to implement a
/// setMigrationSource(), getMigrationSource(), supportsInterface(), and receiveMigrationData()
/// functions here or something similar on top of other functions.
contract PriceFeedAlertsControllerV2 is IMigrationDataReceiver, ERC165, ConfirmedOwner {
  /// @notice This error is thrown when alerting conditions are not met and the
  /// alert is invalid.
  error AlertInvalid();

  /// @notice Emitted when a valid alert is raised for a feed round
  /// @param alerter The address of an alerter
  /// @param roundId The feed's round ID that an alert has been raised for
  event AlertRaised(address indexed alerter, uint256 indexed roundId);

  /// @notice This error is thrown when the owner tries to set the migration source to the
  /// zero address
  error InvalidMigrationSource();

  /// @notice This error is thrown when the sender is not the migration source.
  error SenderNotMigrationSource();

  /// @notice This event is emitted when the migration data is sent to the migration target
  /// @param migrationTarget The migration target
  /// @param feeds The list of feeds that the migration data is sent for
  /// @param migrationData The migration data
  event MigrationDataSent(address indexed migrationTarget, address[] feeds, bytes migrationData);

  /// @notice This event is emitted when the contract receives the migration data
  /// @param lastAlertedRoundIds The list of last alerted round IDs
  event MigrationDataReceived(LastAlertedRoundId[] lastAlertedRoundIds);

  /// @notice This event is emitted when the alerts controller is migrated.
  /// @param migrationTarget The migration target
  event AlertsControllerMigrated(address indexed migrationTarget);

  /// @notice This struct defines the params required by the AlertsController contract's
  /// constructor.
  struct ConstructorParams {
    /// @notice The address of the migration source
    address migrationSource;
  }

  struct LastAlertedRoundId {
    /// @notice The feed address
    address feed;
    /// @notice The last alerted round ID of the feed
    uint256 roundId;
  }

  /// @notice The round ID of the last feed round an alert was raised
  mapping(address => uint256) private s_lastAlertedRoundIds;
  /// @notice The address of the migration source
  address private s_migrationSource;

  constructor(ConstructorParams memory params) ConfirmedOwner(msg.sender) {
    s_migrationSource = params.migrationSource;
  }

  /// @inheritdoc IMigrationDataReceiver
  function receiveMigrationData(bytes calldata data)
    external
    override(IMigrationDataReceiver)
    onlyMigrationSource
  {
    (LastAlertedRoundId[] memory lastAlertedRoundIds) = abi.decode(data, (LastAlertedRoundId[]));
    uint256 lastAlertedRoundIdsLength = lastAlertedRoundIds.length;
    for (uint256 i; i < lastAlertedRoundIdsLength; ++i) {
      LastAlertedRoundId memory lastAlertedRoundId = lastAlertedRoundIds[i];
      s_lastAlertedRoundIds[lastAlertedRoundId.feed] = lastAlertedRoundId.roundId;
    }

    emit MigrationDataReceived(lastAlertedRoundIds);
  }

  /// @notice Function for getting the last alerted round ID of a feed.
  /// @param feed The feed address.
  function getLastAlertedRoundId(address feed) external view returns (uint256) {
    return s_lastAlertedRoundIds[feed];
  }

  /// @notice This function allows the calling contract to
  /// check if the contract deployed at this address is a valid
  /// AlertsController.  A contract is a valid AlertsController
  /// if it implements the receiveMigrationData function.
  /// @param interfaceID The ID of the interface to check against
  /// @return bool True if the contract is a valid AlertsController.
  function supportsInterface(bytes4 interfaceID) public view override returns (bool) {
    return interfaceID == this.receiveMigrationData.selector || super.supportsInterface(interfaceID);
  }

  /// @notice This function creates an alert for an unhealthy Chainlink service.
  /// @dev This function has been simplified to perform minimal checks and just update the last
  /// alerted round id of the feed and emit an event.
  /// @param feed The address of the feed being alerted
  function raiseAlert(address feed) external {
    if (!_canAlert(feed)) revert AlertInvalid();
    (uint256 roundId,,,,) = AggregatorV3Interface(feed).latestRoundData();
    s_lastAlertedRoundIds[feed] = roundId;

    emit AlertRaised(msg.sender, roundId);
  }

  /// @notice Helper function to check whether an alerter can raise an alert
  /// for a feed.
  /// @dev This function has been simplified to check only the roundId for testing purposes.
  /// @param feed The address of the feed being alerted for
  /// @return True if alerter can alert, false otherwise
  function _canAlert(address feed) private view returns (bool) {
    (uint256 roundId,,,,) = AggregatorV3Interface(feed).latestRoundData();

    if (s_lastAlertedRoundIds[feed] >= roundId) return false;

    return true;
  }

  /// @dev Reverts if the migration source is not set or the sender is not the migration source.
  modifier onlyMigrationSource() {
    if (s_migrationSource == address(0)) revert InvalidMigrationSource();
    if (msg.sender != s_migrationSource) revert SenderNotMigrationSource();
    _;
  }
}
