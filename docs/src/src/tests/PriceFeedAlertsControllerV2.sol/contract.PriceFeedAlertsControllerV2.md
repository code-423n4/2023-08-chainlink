# PriceFeedAlertsControllerV2
[Git Source](https://github.com/code-423n4/2023-08-chainlink/blob/38d594fd52a417af576ce44eee67744196ba1094/src/tests/PriceFeedAlertsControllerV2.sol)

**Inherits:**
[IMigrationDataReceiver](/src/interfaces/IMigrationDataReceiver.sol/interface.IMigrationDataReceiver.md), ERC165, ConfirmedOwner

This is a sample PriceFeedAlertsController version 2 contract.

*The next version of PriceFeedAlertsController contract will need to implement a
setMigrationSource(), getMigrationSource(), supportsInterface(), and receiveMigrationData()
functions here or something similar on top of other functions.*


## State Variables
### s_lastAlertedRoundIds
The round ID of the last feed round an alert was raised


```solidity
mapping(address => uint256) private s_lastAlertedRoundIds;
```


### s_migrationSource
The address of the migration source


```solidity
address private s_migrationSource;
```


## Functions
### constructor


```solidity
constructor(ConstructorParams memory params) ConfirmedOwner(msg.sender);
```

### receiveMigrationData

Function for receiving the data from the migration source.


```solidity
function receiveMigrationData(bytes calldata data)
  external
  override(IMigrationDataReceiver)
  onlyMigrationSource;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`data`|`bytes`|The migration data.|


### getLastAlertedRoundId

Function for getting the last alerted round ID of a feed.


```solidity
function getLastAlertedRoundId(address feed) external view returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`feed`|`address`|The feed address.|


### supportsInterface

This function allows the calling contract to
check if the contract deployed at this address is a valid
AlertsController.  A contract is a valid AlertsController
if it implements the receiveMigrationData function.


```solidity
function supportsInterface(bytes4 interfaceID) public view override returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`interfaceID`|`bytes4`|The ID of the interface to check against|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|bool True if the contract is a valid AlertsController.|


### raiseAlert

This function creates an alert for an unhealthy Chainlink service.

*This function has been simplified to perform minimal checks and just update the last
alerted round id of the feed and emit an event.*


```solidity
function raiseAlert(address feed) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`feed`|`address`|The address of the feed being alerted|


### _canAlert

Helper function to check whether an alerter can raise an alert
for a feed.

*This function has been simplified to check only the roundId for testing purposes.*


```solidity
function _canAlert(address feed) private view returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`feed`|`address`|The address of the feed being alerted for|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|True if alerter can alert, false otherwise|


### onlyMigrationSource

*Reverts if the migration source is not set or the sender is not the migration source.*


```solidity
modifier onlyMigrationSource();
```

## Events
### AlertRaised
Emitted when a valid alert is raised for a feed round


```solidity
event AlertRaised(address indexed alerter, uint256 indexed roundId);
```

### MigrationDataSent
This event is emitted when the migration data is sent to the migration target


```solidity
event MigrationDataSent(address indexed migrationTarget, address[] feeds, bytes migrationData);
```

### MigrationDataReceived
This event is emitted when the contract receives the migration data


```solidity
event MigrationDataReceived(LastAlertedRoundId[] lastAlertedRoundIds);
```

### AlertsControllerMigrated
This event is emitted when the alerts controller is migrated.


```solidity
event AlertsControllerMigrated(address indexed migrationTarget);
```

## Errors
### AlertInvalid
This error is thrown when alerting conditions are not met and the
alert is invalid.


```solidity
error AlertInvalid();
```

### InvalidMigrationSource
This error is thrown when the owner tries to set the migration source to the
zero address


```solidity
error InvalidMigrationSource();
```

### SenderNotMigrationSource
This error is thrown when the sender is not the migration source.


```solidity
error SenderNotMigrationSource();
```

## Structs
### ConstructorParams
This struct defines the params required by the AlertsController contract's
constructor.


```solidity
struct ConstructorParams {
  address migrationSource;
}
```

### LastAlertedRoundId

```solidity
struct LastAlertedRoundId {
  address feed;
  uint256 roundId;
}
```

