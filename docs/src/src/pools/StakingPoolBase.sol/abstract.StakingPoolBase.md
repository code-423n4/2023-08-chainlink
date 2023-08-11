# StakingPoolBase
[Git Source](https://github.com/smartcontractkit/destiny-next/blob/93e1115f8d7fb0029b73a936d125afb837306065/src/pools/StakingPoolBase.sol)

**Inherits:**
ERC677ReceiverInterface, [IStakingPool](/src/interfaces/IStakingPool.sol/interface.IStakingPool.md), [IStakingOwner](/src/interfaces/IStakingOwner.sol/interface.IStakingOwner.md), [Migratable](/src/Migratable.sol/abstract.Migratable.md), [PausableWithAccessControl](/src/PausableWithAccessControl.sol/abstract.PausableWithAccessControl.md)

This contract is the base contract for staking pools. Each staking pool extends this
contract.

*This contract is abstract and must be inherited.*

*invariant maxPoolSize must be greater than or equal to the totalPrincipal.*

*invariant maxPoolSize must be greater than or equal to the maxPrincipalPerStaker.*

*invariant contract's LINK token balance should be greater than or equal to the
totalPrincipal.*

*invariant The migrated principal must be less than or equal to the staker's principal +
rewards from the v0.1 staking pool.*

*invariant The migrated principal must be less than or equal to the maxPrincipalPerStaker.*

*We only support LINK token in v0.2 staking. Rebasing tokens, ERC777 tokens, fee-on-transfer
tokens or tokens that do not have 18 decimal places are not supported.*


## State Variables
### i_LINK
The LINK token


```solidity
LinkTokenInterface internal immutable i_LINK;
```


### MIN_UNBONDING_PERIOD
The min value that the unbonding period can be set to


```solidity
uint32 private constant MIN_UNBONDING_PERIOD = 1;
```


### s_pool
The staking pool state and configuration


```solidity
Pool internal s_pool;
```


### s_stakers
Mapping of a staker's address to their staker state


```solidity
mapping(address => IStakingPool.Staker) internal s_stakers;
```


### s_migrationProxy
Migration proxy address


```solidity
address internal s_migrationProxy;
```


### s_rewardVault
The latest reward vault address


```solidity
IRewardVault internal s_rewardVault;
```


### i_minPrincipalPerStaker
The min amount of LINK that a staker can stake


```solidity
uint256 internal immutable i_minPrincipalPerStaker;
```


### i_minClaimPeriod
The min value that the claim period can be set to


```solidity
uint32 private immutable i_minClaimPeriod;
```


### i_maxClaimPeriod
The max value that the claim period can be set to


```solidity
uint32 private immutable i_maxClaimPeriod;
```


### i_maxUnbondingPeriod
The max value that the unbonding period can be set to


```solidity
uint32 private immutable i_maxUnbondingPeriod;
```


### s_checkpointId
The current checkpoint ID


```solidity
uint32 private s_checkpointId;
```


### s_isOpen
Flag that signals if the staking pool is open for staking


```solidity
bool internal s_isOpen;
```


## Functions
### constructor


```solidity
constructor(ConstructorParamsBase memory params)
  PausableWithAccessControl(params.adminRoleTransferDelay, msg.sender);
```

### migrate

Migrates the contract

*This will migrate the staker's principal*

*precondition This contract must be closed and upgraded to a new pool.*

*precondition The migration target must be set.*

*precondition The caller must be staked in the pool.*


```solidity
function migrate(bytes calldata data)
  external
  override(IMigratable)
  whenClosed
  validateMigrationTargetSet
  validateRewardVaultSet;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`data`|`bytes`|Optional calldata to call on new contract|


### _validateMigrationTarget

Helper function for validating the migration target

*precondition The caller must have the default admin role.*

*precondition The migration target must implement the IMigrationDataReceiver interface.*


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


### unbond

Starts the unbonding period for the staker.  A staker may unstake
their principal during the claim period that follows the unbonding period.

*precondition The caller must be staked in the pool.*

*precondition The caller must not be in an unbonding period.*


```solidity
function unbond() external;
```

### setUnbondingPeriod

Sets the new unbonding period for the pool.  Stakers that are
already unbonding will not be affected.

*precondition The caller must have the default admin role.*


```solidity
function setUnbondingPeriod(uint256 newUnbondingPeriod) external onlyRole(DEFAULT_ADMIN_ROLE);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`newUnbondingPeriod`|`uint256`|The new unbonding period|


### getUnbondingPeriodLimits

Returns the unbonding period limits


```solidity
function getUnbondingPeriodLimits() external view returns (uint256, uint256);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|uint256 The min value that the unbonding period can be set to|
|`<none>`|`uint256`|uint256 The max value that the unbonding period can be set to|


### setClaimPeriod

Set the claim period


```solidity
function setClaimPeriod(uint256 claimPeriod) external onlyRole(DEFAULT_ADMIN_ROLE);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`claimPeriod`|`uint256`|The claim period|


### setRewardVault

Sets the new reward vault for the pool

*precondition The caller must have the default admin role.*


```solidity
function setRewardVault(IRewardVault newRewardVault) external onlyRole(DEFAULT_ADMIN_ROLE);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`newRewardVault`|`IRewardVault`|The new reward vault|


### onTokenTransfer

LINK transfer callback function called when transferAndCall is called with this
contract as a target.

*precondition The migration proxy must be set.*

*precondition This contract must be open and not paused.*

*precondition The reward vault must be open and not paused.*


```solidity
function onTokenTransfer(
  address sender,
  uint256 amount,
  bytes calldata data
)
  external
  override
  validateFromLINK
  validateMigrationProxySet
  whenOpen
  whenRewardVaultOpen
  whenNotPaused;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`sender`|`address`|staker's address if they stake into the pool by calling transferAndCall on the LINK token, or MigrationProxy contract when a staker migrates from V0.1 to V0.2|
|`amount`|`uint256`|Amount of LINK token transferred|
|`data`|`bytes`|Bytes data received, represents migration path|


### _validateOnTokenTransfer

Validate for when LINK is staked or migrated into the pool


```solidity
function _validateOnTokenTransfer(
  address sender,
  address staker,
  bytes calldata data
) internal view virtual;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`sender`|`address`|The address transferring LINK into the pool. Could be the migration proxy contract or the staker.|
|`staker`|`address`|The address staking or migrating LINK into the pool|
|`data`|`bytes`|Arbitrary data passed when staking or migrating|


### getClaimPeriodLimits

Returns the minimum and maximum claim periods that can be set by the owner


```solidity
function getClaimPeriodLimits() external view returns (uint256, uint256);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|uint256 minimum claim period|
|`<none>`|`uint256`|uint256 maximum claim period|


### setPoolConfig

Set the pool config

*precondition The caller must have the default admin role.*


```solidity
function setPoolConfig(
  uint256 maxPoolSize,
  uint256 maxPrincipalPerStaker
) external virtual override onlyRole(DEFAULT_ADMIN_ROLE) whenOpen;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`maxPoolSize`|`uint256`|The max amount of staked LINK allowed in the pool|
|`maxPrincipalPerStaker`|`uint256`|The max amount of LINK a staker can stake in the pool.|


### open

Opens the pool for staking

*precondition The caller must have the default admin role.*


```solidity
function open()
  external
  override(IStakingOwner)
  onlyRole(DEFAULT_ADMIN_ROLE)
  whenBeforeOpening
  whenRewardVaultOpen;
```

### close

Closes the pool

*precondition The caller must have the default admin role.*


```solidity
function close() external override(IStakingOwner) onlyRole(DEFAULT_ADMIN_ROLE) whenOpen;
```

### _handleOpen

Handler for opening the pool


```solidity
function _handleOpen() internal view virtual;
```

### setMigrationProxy

Sets the migration proxy contract address

*precondition The caller must have the default admin role.*


```solidity
function setMigrationProxy(address migrationProxy) external override onlyRole(DEFAULT_ADMIN_ROLE);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`migrationProxy`|`address`|The migration proxy contract address|


### unstake

Unstakes amount LINK tokens from the staker’s principal
Also claims all of the earned rewards if claimRewards is true

*precondition The caller must be staked in the pool.*

*precondition The caller must be in the claim period or the pool must be closed or paused.*


```solidity
function unstake(uint256 amount, bool shouldClaimReward) external override;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`amount`|`uint256`|The amount of LINK tokens to unstake|
|`shouldClaimReward`|`bool`|If true will claim all reward|


### getTotalPrincipal

Returns the total amount staked in the pool


```solidity
function getTotalPrincipal() external view override returns (uint256);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|The total amount staked in pool|


### getStakerPrincipal

Returns the staker's principal


```solidity
function getStakerPrincipal(address staker) external view override returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`staker`|`address`|The address of the staker to query for|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|uint256 The staker's principal|


### getStakerPrincipalAt

Returns the staker's principal

*Passing in a checkpointId of 0 will return the staker's initial
principal balance*


```solidity
function getStakerPrincipalAt(
  address staker,
  uint256 checkpointId
) external view override returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`staker`|`address`|The address of the staker to query for|
|`checkpointId`|`uint256`|The checkpoint ID to fetch the staker's balance for.  Pass 0 to return the staker's latest principal|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|uint256 The staker's principal|


### getStakerStakedAtTime

Returns the staker's average staked at time


```solidity
function getStakerStakedAtTime(address staker) external view override returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`staker`|`address`|The address of the staker to query for|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|uint256 The staker's average staked at time|


### getStakerStakedAtTimeAt

Returns the staker's average staked at time for a checkpoint ID

*Passing in a checkpointId of 0 will return the initial time the
staker staked*


```solidity
function getStakerStakedAtTimeAt(
  address staker,
  uint256 checkpointId
) external view override returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`staker`|`address`|The address of the staker to query for|
|`checkpointId`|`uint256`|The checkpoint to query for|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|uint256 The staker's average staked at time|


### getRewardVault

Returns the current reward vault address


```solidity
function getRewardVault() external view override returns (IRewardVault);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`IRewardVault`|The reward vault|


### getChainlinkToken

Returns the address of the LINK token contract


```solidity
function getChainlinkToken() external view override returns (address);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`address`|The LINK token contract's address that is used by the pool|


### getMigrationProxy

Returns the migration proxy contract address


```solidity
function getMigrationProxy() external view override returns (address);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`address`|The migration proxy contract address|


### isOpen

Returns a boolean that is true if the pool is open


```solidity
function isOpen() external view override returns (bool);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|True if the pool is open, false otherwise|


### isActive

Returns a boolean that is true if the pool is active,
i.e. is open and there are remaining rewards to vest in the pool.


```solidity
function isActive() public view override returns (bool);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|True if the pool is active, false otherwise|


### getStakerLimits

Returns the minimum and maximum amounts a staker can stake in the
pool


```solidity
function getStakerLimits() external view override returns (uint256, uint256);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|uint256 minimum amount that can be staked by a staker|
|`<none>`|`uint256`||


### getMaxPoolSize

uint256 Returns the maximum amount that can be staked in the pool


```solidity
function getMaxPoolSize() external view override returns (uint256);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|uint256 current maximum staking pool size|


### getUnbondingEndsAt

Returns the time a staker's unbonding period ends


```solidity
function getUnbondingEndsAt(address staker) external view returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`staker`|`address`|The address of the staker to query|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|uint256 The timestamp of when the staker's unbonding period ends. This value will be 0 if the unbonding period is not active.|


### getUnbondingParams

Returns the pool's unbonding parameters


```solidity
function getUnbondingParams() external view returns (uint256, uint256);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|uint256 The pool's unbonding period|
|`<none>`|`uint256`|uint256 The pools's claim period|


### getClaimPeriodEndsAt

Returns the time a staker's claim period ends


```solidity
function getClaimPeriodEndsAt(address staker) external view returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`staker`|`address`|The staker trying to unstake their principal|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|uint256 The timestamp of when the staker's claim period ends. This value will be 0 if the unbonding period has not started.|


### getCurrentCheckpointId

Returns the currenct checkpoint ID


```solidity
function getCurrentCheckpointId() external view returns (uint32);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint32`|uint32 The current checkpoint ID|


### _setPoolConfig

Util function for setting the pool config


```solidity
function _setPoolConfig(uint256 maxPoolSize, uint256 maxPrincipalPerStaker) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`maxPoolSize`|`uint256`|The max amount of staked LINK allowed in the pool|
|`maxPrincipalPerStaker`|`uint256`|The max amount of LINK a staker can stake in the pool.|


### _setUnbondingPeriod

Util function for setting the unbonding period


```solidity
function _setUnbondingPeriod(uint256 unbondingPeriod) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`unbondingPeriod`|`uint256`|The unbonding period|


### _setClaimPeriod

Util function for setting the claim period


```solidity
function _setClaimPeriod(uint256 claimPeriod) private;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`claimPeriod`|`uint256`|The claim period|


### _increaseStake

Updates the staking pool state and the staker state


```solidity
function _increaseStake(address sender, uint256 newPrincipal, uint256 amount) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`sender`|`address`|The staker address|
|`newPrincipal`|`uint256`|The staker's principal after staking|
|`amount`|`uint256`|The amount to stake|


### _getStakerAddress

Gets the staker address from the data passed by the MigrationProxy contract


```solidity
function _getStakerAddress(bytes calldata data) internal pure returns (address);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`data`|`bytes`|The data passed by the MigrationProxy contract|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`address`|The staker address|


### _canUnstake

Checks to see whether or not a staker is eligible to
unstake their principal (when the pool is closed or, when the pool is open and they
are in the claim period or, when pool is paused)


```solidity
function _canUnstake(Staker storage staker) internal view returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`staker`|`Staker`|The staker trying to unstake their principal|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|bool True if the staker is eligible to unstake|


### _inClaimPeriod

Checks to see whether or not a staker is within the claim period
to unstake their principal


```solidity
function _inClaimPeriod(Staker storage staker) private view returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`staker`|`Staker`|The staker trying to unstake their principal|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|bool True if the staker is inside the claim period|


### _updateStakerHistory

Updates the staker's principal history


```solidity
function _updateStakerHistory(
  Staker storage staker,
  uint256 latestPrincipal,
  uint256 latestStakedAtTime
) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`staker`|`Staker`|The staker to update|
|`latestPrincipal`|`uint256`|The staker's latest principal|
|`latestStakedAtTime`|`uint256`|The staker's latest average staked at time|


### validateFromLINK

*Reverts if not sent from the LINK token*


```solidity
modifier validateFromLINK();
```

### validateMigrationProxySet

*Reverts if migration proxy is not set*


```solidity
modifier validateMigrationProxySet();
```

### validateRewardVaultSet

*Reverts if reward vault is not set*


```solidity
modifier validateRewardVaultSet();
```

### whenBeforeOpening

*Reverts if pool is after an opening*


```solidity
modifier whenBeforeOpening();
```

### whenBeforeClosing

*Reverts if the pool is already closed*


```solidity
modifier whenBeforeClosing();
```

### whenOpen

*Reverts if pool is not open*


```solidity
modifier whenOpen();
```

### whenActive

*Reverts if pool is not active (is open and rewards are emitting for this pool)*


```solidity
modifier whenActive();
```

### whenClosed

*Reverts if pool is not closed*


```solidity
modifier whenClosed();
```

### whenRewardVaultOpen

*Reverts if reward vault is not open or is paused*


```solidity
modifier whenRewardVaultOpen();
```

## Events
### UnbondingPeriodStarted
This event is emitted whenever a staker initiates the unbonding
period.


```solidity
event UnbondingPeriodStarted(address indexed staker);
```

### UnbondingPeriodReset
This event is emitted when a staker's unbonding period is reset


```solidity
event UnbondingPeriodReset(address indexed staker);
```

### UnbondingPeriodSet
This event is emitted when the unbonding period has been changed


```solidity
event UnbondingPeriodSet(uint256 oldUnbondingPeriod, uint256 newUnbondingPeriod);
```

### ClaimPeriodSet
This event is emitted when the claim period is set


```solidity
event ClaimPeriodSet(uint256 oldClaimPeriod, uint256 newClaimPeriod);
```

### RewardVaultSet
This event is emitted when the reward vault is set


```solidity
event RewardVaultSet(address indexed oldRewardVault, address indexed newRewardVault);
```

### StakerMigrated
This event is emitted when the staker is migrated to the migration target


```solidity
event StakerMigrated(address indexed migrationTarget, uint256 amount, bytes migrationData);
```

## Errors
### PoolNotActive
This error is thrown when the staking pool is not active.


```solidity
error PoolNotActive();
```

### InvalidUnbondingPeriod
This error is thrown when the unbonding period is set to 0


```solidity
error InvalidUnbondingPeriod();
```

### InvalidClaimPeriod
This error is thrown when the claim period is set to 0


```solidity
error InvalidClaimPeriod();
```

### UnbondingPeriodActive
This error is thrown whenever a staker tries to unbond during
their unbonding period.


```solidity
error UnbondingPeriodActive(uint256 unbondingPeriodEndsAt);
```

### StakerNotInClaimPeriod
This error is thrown whenever a staker tries to unstake outside
the claim period


```solidity
error StakerNotInClaimPeriod(address staker);
```

### InvalidClaimPeriodRange
This error is thrown when an invalid claim period range is provided


```solidity
error InvalidClaimPeriodRange(uint256 minClaimPeriod, uint256 maxClaimPeriod);
```

### InvalidUnbondingPeriodRange
This error is thrown when an invalid unbonding period range is provided


```solidity
error InvalidUnbondingPeriodRange(uint256 minUnbondingPeriod, uint256 maxUnbondingPeriod);
```

### RewardVaultNotActive
This error is thrown when a staker tries to stake and the reward vault connected to
this pool is not open or is paused


```solidity
error RewardVaultNotActive();
```

### CannotClaimRewardWhenPaused
This error is thrown when the pool is paused and the staker tries to claim rewards
while unstaking


```solidity
error CannotClaimRewardWhenPaused();
```

## Structs
### ConstructorParamsBase
This struct defines the params required by the Staking contract's
constructor.


```solidity
struct ConstructorParamsBase {
  LinkTokenInterface LINKAddress;
  uint256 initialMaxPoolSize;
  uint256 initialMaxPrincipalPerStaker;
  uint256 minPrincipalPerStaker;
  uint32 initialUnbondingPeriod;
  uint32 maxUnbondingPeriod;
  uint32 initialClaimPeriod;
  uint32 minClaimPeriod;
  uint32 maxClaimPeriod;
  uint48 adminRoleTransferDelay;
}
```

### PoolConfigs
This struct defines the params that the pool is configured with


```solidity
struct PoolConfigs {
  uint96 maxPoolSize;
  uint96 maxPrincipalPerStaker;
  uint32 unbondingPeriod;
  uint32 claimPeriod;
}
```

### PoolState
This struct defines the state of the staking pool


```solidity
struct PoolState {
  uint256 totalPrincipal;
  uint256 closedAt;
}
```

### Pool
This struct defines the global state and configuration of the pool


```solidity
struct Pool {
  PoolConfigs configs;
  PoolState state;
}
```

