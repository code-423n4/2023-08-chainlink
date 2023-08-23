# PriceFeedAlertsController
[Git Source](https://github.com/smartcontractkit/destiny-next/blob/93e1115f8d7fb0029b73a936d125afb837306065/src/alerts/PriceFeedAlertsController.sol)

**Inherits:**
[Migratable](/src/Migratable.sol/abstract.Migratable.md), [PausableWithAccessControl](/src/PausableWithAccessControl.sol/abstract.PausableWithAccessControl.md), TypeAndVersionInterface

This contract allows alerters to raise alerts for feeds that are down.

*When an alert is raised, the operators of the feed are slashed and the alerter is rewarded
by the operator staking pool.*

*invariant An alert can only be raised for a feed if the feed is stale.*

*invariant An alert can only be raised for a feed if the alerter is staking in one of the
staking pools.*

*invariant Only one alert can be raised for a feed per round.*


## State Variables
### s_communityStakingPool
The community staking pool contract


```solidity
CommunityStakingPool private s_communityStakingPool;
```


### s_operatorStakingPool
The Node Operator staking contract.


```solidity
OperatorStakingPool private s_operatorStakingPool;
```


### s_feedConfigs
The feeds that alerters can raise alerts for.


```solidity
mapping(address => FeedConfig) private s_feedConfigs;
```


### s_feedSlashableOperators
The slashable operators of each feed


```solidity
mapping(address => address[]) private s_feedSlashableOperators;
```


### s_lastAlertedRoundIds
The round ID of the last feed round an alert was raised


```solidity
mapping(address => uint256) private s_lastAlertedRoundIds;
```


## Functions
### constructor


```solidity
constructor(ConstructorParams memory params)
  PausableWithAccessControl(params.adminRoleTransferDelay, msg.sender);
```

### setCommunityStakingPool

Sets the community staking pool


```solidity
function setCommunityStakingPool(CommunityStakingPool newCommunityStakingPool)
  external
  onlyRole(DEFAULT_ADMIN_ROLE);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`newCommunityStakingPool`|`CommunityStakingPool`|The community staking pool|


### setOperatorStakingPool

Sets the operator staking pool


```solidity
function setOperatorStakingPool(OperatorStakingPool newOperatorStakingPool)
  external
  onlyRole(DEFAULT_ADMIN_ROLE);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`newOperatorStakingPool`|`OperatorStakingPool`|The operator staking pool|


### setFeedConfigs

Sets the feed config of one or more feeds

*precondition The caller must be the default admin*


```solidity
function setFeedConfigs(SetFeedConfigParams[] calldata configs)
  external
  onlyRole(DEFAULT_ADMIN_ROLE);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`configs`|`SetFeedConfigParams[]`|The array of feed configs and the feed address to set the config|


### removeFeedConfig

Removes the feed's config and resets the last alerted round ID and
slashable operators of the feed.

*precondition The caller must be the default admin*


```solidity
function removeFeedConfig(address feed) external onlyRole(DEFAULT_ADMIN_ROLE);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`feed`|`address`|The address of the feed to remove|


### getFeedConfig

Returns the config of the given feed


```solidity
function getFeedConfig(address feed) external view returns (FeedConfig memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`feed`|`address`|The feed address|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`FeedConfig`|The config of the feed|


### raiseAlert

This function creates an alert for an unhealthy Chainlink feed

*The PriceFeedAlertsControllers should encode the feed address and
pass it as the data arg.*

*precondition This contract must not be in paused state*

*precondition The feed slashing condition must be registered by the admin*

*The operator staking pool must be active*

*precondition This contract must be given the slasher role in the operator staking
contract*

*precondition The caller must be staking in one of the staking pools*

*precondition The feed must be stale (in the priority or regular period)*

*precondition No alert has been raised for the feed in the current round*


```solidity
function raiseAlert(address feed) external whenNotPaused;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`feed`|`address`|The address of the feed being alerted on|


### canAlert

This function returns true if the alerter may raise an alert
to claim rewards and false otherwise


```solidity
function canAlert(address alerter, address feed) external view returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`alerter`|`address`|The alerter's address|
|`feed`|`address`|The address of the feed being queried for|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|True if alerter can alert, false otherwise|


### getStakingPools

This function returns the staking pools connected to this alerts controller


```solidity
function getStakingPools() external view returns (address[] memory);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`address[]`|address[] The staking pools|


### setSlashableOperators

Allows the contract owner to set the list of operator addresses who are
subject to slashing.

*precondition The caller must be the default admin*


```solidity
function setSlashableOperators(
  address[] calldata operators,
  address feed
) external onlyRole(DEFAULT_ADMIN_ROLE);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`operators`|`address[]`|New list of operator staker addresses|
|`feed`|`address`|The address of the feed to set slashable operators for|


### getSlashableOperators

Returns the slashable operators.


```solidity
function getSlashableOperators(address feed) external view returns (address[] memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`feed`|`address`|The feed address to get slashable operators for|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`address[]`|The list of slashable operators' addresses.|


### migrate

Migrates the contract

*Renounces the slasher role of self from the staking contract.*

*precondition The caller must be the default admin*

*precondition This contract should have the slasher role on the operator staking pool*

*precondition The migration target should be set*


```solidity
function migrate(bytes calldata)
  external
  override(IMigratable)
  onlyRole(DEFAULT_ADMIN_ROLE)
  withSlasherRole
  validateMigrationTargetSet;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bytes`||


### _validateMigrationTarget

Helper function for validating the migration target

*This function is called when setting the migration target to validate the migration
target*

*precondition The caller must be the default admin*

*precondition The migration target must implement the IMigrationDataReceiver interface*


```solidity
function _validateMigrationTarget(address newMigrationTarget)
  internal
  override(Migratable)
  onlyRole(DEFAULT_ADMIN_ROLE);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`newMigrationTarget`|`address`|The address of the new migration target|


### sendMigrationData

Function for migrating the data to the migration target.

*precondition The caller must be the default admin*

*precondition The migration target must be set*

*precondition The `feeds` should be registered in this contract*


```solidity
function sendMigrationData(address[] calldata feeds)
  external
  onlyRole(DEFAULT_ADMIN_ROLE)
  validateMigrationTargetSet;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`feeds`|`address[]`|The list of feed addresses to migrate the data for.|


### _setFeedConfigs

Util function to set the feed config of one or more feeds

*operational guarantee that slashCapacity <= configParams.slashableAmount * numNops
Code guarantee results in circular dependency between PFAC creation using setFeedConfig and
created PFAC having slasher with sufficient slash capacity*


```solidity
function _setFeedConfigs(SetFeedConfigParams[] memory configs) private;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`configs`|`SetFeedConfigParams[]`|The array of feed configs and the feed address to set the config|


### _canAlert

Helper function to check whether an alerter can raise an alert
for a feed.


```solidity
function _canAlert(
  address alerter,
  address feed
) private view returns (CanAlertReturnValues memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`alerter`|`address`|The alerter's address|
|`feed`|`address`|The feed address|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`CanAlertReturnValues`|A CanAlertReturnValues struct, which contains a canAlert boolean, the round id, and the feed config|


### _hasSlasherRole

Helper function for checking if this contract has the slasher role


```solidity
function _hasSlasherRole() private view returns (bool);
```

### _setSlashableOperators

Helper function for setting the slashable operators of a feed


```solidity
function _setSlashableOperators(address feed, address[] memory operators) private;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`feed`|`address`|The feed address|
|`operators`|`address[]`|The slashable operators|


### withSlasherRole

*Reverts if the alerts controller doesn't have the slasher role
in the staking contract*


```solidity
modifier withSlasherRole();
```

### typeAndVersion


```solidity
function typeAndVersion() external pure virtual override returns (string memory);
```

## Events
### AlertRaised
Emitted when a valid alert is raised for a feed round


```solidity
event AlertRaised(address indexed alerter, uint256 indexed roundId, uint96 rewardAmount);
```

### FeedConfigSet
This event is emitted when a feed config is set.


```solidity
event FeedConfigSet(
  address indexed feed,
  uint32 priorityPeriodThreshold,
  uint32 regularPeriodThreshold,
  uint96 slashableAmount,
  uint96 alerterRewardAmount
);
```

### FeedConfigRemoved
This event is emitted when a feed config is removed.


```solidity
event FeedConfigRemoved(address indexed feed);
```

### SlashableOperatorsSet
This event is emitted when a slashable operator list is set.


```solidity
event SlashableOperatorsSet(address indexed feed, address[] operators);
```

### CommunityStakingPoolSet
this event is emitted when a community staking pool is set


```solidity
event CommunityStakingPoolSet(
  address indexed oldCommunityStakingPool, address indexed newCommunityStakingPool
);
```

### OperatorStakingPoolSet
this event is emitted when an operator staking pool is set


```solidity
event OperatorStakingPoolSet(
  address indexed oldOperatorStakingPool, address indexed newOperatorStakingPool
);
```

### MigrationDataSent
This event is emitted when the migration data is sent to the migration target


```solidity
event MigrationDataSent(address indexed migrationTarget, address[] feeds, bytes migrationData);
```

### AlertsControllerMigrated
This event is emitted when the alerts controller is migrated.


```solidity
event AlertsControllerMigrated(address indexed migrationTarget);
```

## Errors
### InvalidZeroAddress
This error is thrown whenever a zero-address is supplied when
a non-zero address is required


```solidity
error InvalidZeroAddress();
```

### InvalidPriorityPeriodThreshold
This error is thrown when an invalid priority period threshold is supplied.


```solidity
error InvalidPriorityPeriodThreshold();
```

### InvalidRegularPeriodThreshold
This error is thrown when an invalid regular period threshold is supplied.


```solidity
error InvalidRegularPeriodThreshold();
```

### DoesNotHaveSlasherRole
This error is thrown when the AlertsController hasn't been set as the slasher by the
staking contract.


```solidity
error DoesNotHaveSlasherRole();
```

### InvalidPoolStatus
Surfaces the required pool status to perform an operation


```solidity
error InvalidPoolStatus(bool currentStatus, bool requiredStatus);
```

### FeedDoesNotExist
This error is thrown when the given feed is not known to this AlertsController.


```solidity
error FeedDoesNotExist();
```

### InvalidOperatorList
This error is thrown when the operator list is invalid.


```solidity
error InvalidOperatorList();
```

### InvalidSlashableAmount
This error is thrown when the feed's slashable amount is 0 or
greater than the max operator stake principal


```solidity
error InvalidSlashableAmount();
```

### InvalidAlerterRewardAmount
This error is thrown when the alerter reward amount is 0


```solidity
error InvalidAlerterRewardAmount();
```

### AlertInvalid
This error is thrown when alerting conditions are not met and the
alert is invalid.


```solidity
error AlertInvalid();
```

## Structs
### ConstructorParams
This struct defines the params required by the AlertsController contract's
constructor.


```solidity
struct ConstructorParams {
  CommunityStakingPool communityStakingPool;
  OperatorStakingPool operatorStakingPool;
  ConstructorFeedConfigParams[] feedConfigs;
  uint48 adminRoleTransferDelay;
}
```

### ConstructorFeedConfigParams
The struct defines the parameters for setting feed configs in the constructor


```solidity
struct ConstructorFeedConfigParams {
  address feed;
  uint32 priorityPeriodThreshold;
  uint32 regularPeriodThreshold;
  uint96 slashableAmount;
  uint96 alerterRewardAmount;
  address[] slashableOperators;
}
```

### SetFeedConfigParams
The struct defines the parameters for the `setFeedConfig` function.


```solidity
struct SetFeedConfigParams {
  address feed;
  uint32 priorityPeriodThreshold;
  uint32 regularPeriodThreshold;
  uint96 slashableAmount;
  uint96 alerterRewardAmount;
}
```

### FeedConfig
This struct defines the configs for each feed that alerts can be raised for.


```solidity
struct FeedConfig {
  uint32 priorityPeriodThreshold;
  uint32 regularPeriodThreshold;
  uint96 slashableAmount;
  uint96 alerterRewardAmount;
}
```

### LastAlertedRoundId
This struct defines the last alerted round ID of a feed.

*This is used when a feed's round ID data is migrated to the migration target.*


```solidity
struct LastAlertedRoundId {
  address feed;
  uint256 roundId;
}
```

### CanAlertReturnValues
The return values of the `_canAlert` function

*This struct is for internal use, it was introduced to help with gas savings*


```solidity
struct CanAlertReturnValues {
  bool canAlert;
  uint256 roundId;
  FeedConfig feedConfig;
}
```

