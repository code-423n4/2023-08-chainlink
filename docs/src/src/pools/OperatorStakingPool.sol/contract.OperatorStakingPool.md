# OperatorStakingPool
[Git Source](https://github.com/code-423n4/2023-08-chainlink/blob/38d594fd52a417af576ce44eee67744196ba1094/src/pools/OperatorStakingPool.sol)

**Inherits:**
[ISlashable](/src/interfaces/ISlashable.sol/interface.ISlashable.md), [StakingPoolBase](/src/pools/StakingPoolBase.sol/abstract.StakingPoolBase.md), TypeAndVersionInterface

This contract manages the staking of LINK tokens for the operator stakers.

*This contract inherits the StakingPoolBase contract and interacts with the MigrationProxy,
PriceFeedAlertsController, CommunityStakingPool, and RewardVault contracts.*

*invariant Only addresses added as operators by the contract manager can stake in this pool.*

*invariant contract's LINK token balance should be greater than or equal to the sum of
totalPrincipal and s_alerterRewardFunds.*


## State Variables
### s_operators
Mapping of addresses to the Operator struct.


```solidity
mapping(address => Operator) private s_operators;
```


### s_slasherConfigs
Mapping of the slashers to slasher config struct.


```solidity
mapping(address => ISlashable.SlasherConfig) private s_slasherConfigs;
```


### s_slasherState
Mapping of slashers to slasher state struct.


```solidity
mapping(address => ISlashable.SlasherState) private s_slasherState;
```


### s_numOperators
The number of node operators that have been set in the pool


```solidity
uint256 private s_numOperators;
```


### s_alerterRewardFunds
Tracks the balance of the alerter reward funds.  This bucket holds all
slashed funds and also funds alerter rewards.


```solidity
uint256 private s_alerterRewardFunds;
```


### i_minInitialOperatorCount
The minimum number of node operators required to open the
staking pool.


```solidity
uint256 private immutable i_minInitialOperatorCount;
```


### SLASHER_ROLE
This is the ID for the slasher role, which will be given to the
AlertsController contract.

*Hash: 12b42e8a160f6064dc959c6f251e3af0750ad213dbecf573b4710d67d6c28e39*


```solidity
bytes32 public constant SLASHER_ROLE = keccak256('SLASHER_ROLE');
```


## Functions
### constructor


```solidity
constructor(ConstructorParams memory params) StakingPoolBase(params.baseParams);
```

### depositAlerterReward

Adds LINK to the alerter reward funds

*precondition The caller must have the default admin role.*

*precondition The caller must have at least `amount` LINK tokens.*

*precondition The caller must have approved this contract for the transfer of at least
`amount` LINK tokens.*


```solidity
function depositAlerterReward(uint256 amount)
  external
  onlyRole(DEFAULT_ADMIN_ROLE)
  whenBeforeClosing;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`amount`|`uint256`|The amount of LINK to add to the alerter reward funds|


### withdrawAlerterReward

Withdraws LINK from the alerter reward funds

*precondition The caller must have the default admin role.*

*precondition This contract must have at least `amount` LINK tokens as the alerter reward
funds.*

*precondition This contract must be closed (before opening or after closing).*


```solidity
function withdrawAlerterReward(uint256 amount) external onlyRole(DEFAULT_ADMIN_ROLE);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`amount`|`uint256`|The amount of LINK withdrawn from the alerter reward funds|


### getAlerterRewardFunds

Returns the balance of the pool's alerter reward funds


```solidity
function getAlerterRewardFunds() external view returns (uint256);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|uint256 The balance of the pool's alerter reward funds|


### grantRole

Grants `role` to `account`. Reverts if the contract manager tries to grant the default
admin or
slasher role.

*The default admin role must be granted through `beginDefaultAdminTransfer` and
`acceptDefaultAdminTransfer`.*

*The slasher role must be granted through `addSlasher`.*


```solidity
function grantRole(
  bytes32 role,
  address account
) public virtual override(AccessControlDefaultAdminRules);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`role`|`bytes32`|The role to grant|
|`account`|`address`|The address to grant the role to|


### addSlasher

Adds a new slasher with the given config

*precondition The caller must have the default admin role.*


```solidity
function addSlasher(
  address slasher,
  SlasherConfig calldata config
) external override onlyRole(DEFAULT_ADMIN_ROLE);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`slasher`|`address`|The address of the slasher|
|`config`|`SlasherConfig`|The slasher config|


### setSlasherConfig

Sets the slasher config

*precondition The caller must have the default admin role.*


```solidity
function setSlasherConfig(
  address slasher,
  SlasherConfig calldata config
) external override onlyRole(DEFAULT_ADMIN_ROLE);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`slasher`|`address`|The address of the slasher|
|`config`|`SlasherConfig`|The slasher config|


### _setSlasherConfig

Helper function to set the slasher config


```solidity
function _setSlasherConfig(address slasher, SlasherConfig calldata config) private;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`slasher`|`address`|The slasher|
|`config`|`SlasherConfig`|The slasher config|


### getSlasherConfig

Returns the slasher config


```solidity
function getSlasherConfig(address slasher) external view override returns (SlasherConfig memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`slasher`|`address`|The slasher|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`SlasherConfig`|The slasher config|


### getSlashCapacity

Returns the slash capacity for a slasher


```solidity
function getSlashCapacity(address slasher) external view override returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`slasher`|`address`|The slasher|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|The slash capacity|


### slashAndReward

Slashes stakers and rewards the alerter.  Moves slashed staker
funds into the alerter reward funds.  The alerter is then
rewarded by the funds in the alerter reward funds.

*In the current implementation, on-feed operators can raise alerts to rescue a portion of
their slashed staked LINK amount. All operators can raise alerts in the priority period. Note
that this may change in the future as we add alerting for additional services.*

*We will operationally make sure to remove an operator from the slashable (on-feed)
operators list in alerts controllers if they are removed from the operators list in this
contract, so there won't be a case where we slash a removed operator.*

*precondition The caller must have the slasher role.*

*precondition This contract must be active (open and stakers are earning rewards).*

*precondition The slasher must have enough capacity to slash.*


```solidity
function slashAndReward(
  address[] calldata stakers,
  address alerter,
  uint256 principalAmount,
  uint256 alerterRewardAmount
) external override onlySlasher whenActive;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`stakers`|`address[]`|The list of stakers to slash|
|`alerter`|`address`|The alerter that successfully raised the alert|
|`principalAmount`|`uint256`|The amount of the staker's staked LINK amount to slash|
|`alerterRewardAmount`|`uint256`|The reward amount to be given to the alerter|


### _slashOperators

Helper function to slash operators

*If a slashing occurs with an amount to be slashed that is higher than the remaining
slashing capacity, only an amount equal to the remaining capacity is slashed.*


```solidity
function _slashOperators(
  address[] calldata operators,
  uint256 principalAmount
) private returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`operators`|`address[]`|The list of operators to slash|
|`principalAmount`|`uint256`|The amount to slash from each operator's staked LINK amount|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|The total amount slashed from all operators|


### _payAlerter

Helper function to reward the alerter


```solidity
function _payAlerter(
  address alerter,
  uint256 totalSlashedAmount,
  uint256 alerterRewardAmount
) private;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`alerter`|`address`|The alerter|
|`totalSlashedAmount`|`uint256`|The total amount slashed from all the operators|
|`alerterRewardAmount`|`uint256`|The amount to reward the alerter|


### _getRemainingSlashCapacity

Helper function to return the current remaining slash capacity for a slasher


```solidity
function _getRemainingSlashCapacity(
  SlasherConfig memory slasherConfig,
  address slasher
) private view returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`slasherConfig`|`SlasherConfig`|The slasher's config|
|`slasher`|`address`|The slasher|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|The remaining slashing capacity|


### _validateOnTokenTransfer

Validate for when LINK is staked or migrated into the pool


```solidity
function _validateOnTokenTransfer(address, address staker, bytes calldata) internal view override;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`address`||
|`staker`|`address`|The address staking or migrating LINK into the pool|
|`<none>`|`bytes`||


### setPoolConfig

*The access control is done in StakingPoolBase.*


```solidity
function setPoolConfig(
  uint256 maxPoolSize,
  uint256 maxPrincipalPerStaker
)
  external
  override
  validatePoolSpace(maxPoolSize, maxPrincipalPerStaker, s_numOperators)
  whenOpen
  onlyRole(DEFAULT_ADMIN_ROLE);
```

### _handleOpen

Handler for opening the pool


```solidity
function _handleOpen() internal view override(StakingPoolBase);
```

### addOperators

Registers operators from a list of unique, sorted addresses
Addresses must be provided in sorted order so that
address(0xNext) > address(0xPrev)

*Previously removed operators cannot be readded to the pool.*

*precondition The caller must have the default admin role.*


```solidity
function addOperators(address[] calldata operators)
  external
  validateRewardVaultSet
  validatePoolSpace(
    s_pool.configs.maxPoolSize,
    s_pool.configs.maxPrincipalPerStaker,
    s_numOperators + operators.length
  )
  onlyRole(DEFAULT_ADMIN_ROLE);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`operators`|`address[]`|The sorted list of operator addresses|


### removeOperators

Removes one or more operators from a list of operators.

*Should only be callable by the owner when the pool is open.
When an operator is removed, we store their staked LINK amount in a separate mapping to
stop it from accruing reward.
Removed operators are still slashable until they withdraw their removedPrincipal
and exit the system. When they withdraw their removedPrincipal, they must
go through the unbonding period.
Note that the function doesn't check if the operators are still on-feed (slashable).
This is so that we can slash the removed operators if an alert is raised against them.*

*precondition The caller must have the default admin role.*

*precondition The pool must be open.*

*precondition The operators must be currently added operators.*


```solidity
function removeOperators(address[] calldata operators)
  external
  onlyRole(DEFAULT_ADMIN_ROLE)
  whenOpen;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`operators`|`address[]`|A list of operator addresses to remove|


### isOperator

Getter function to check if an address is registered as an operator


```solidity
function isOperator(address staker) external view returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`staker`|`address`|The address of the staker|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|bool True if the staker is an operator|


### isRemoved

Getter function to check if an address is a removed operator


```solidity
function isRemoved(address staker) external view returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`staker`|`address`|The address of the staker|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|bool True if the operator has been removed|


### getRemovedPrincipal

Getter function for a removed operator's total staked LINK amount


```solidity
function getRemovedPrincipal(address staker) external view returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`staker`|`address`|The address of the staker|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|uint256 The removed operator's staked LINK amount that hasn't been withdrawn|


### unstakeRemovedPrincipal

Called by removed operators to withdraw their removed stake

*precondition The caller must be in the claim period or the pool must be closed or paused.*

*precondition The caller must be a removed operator with some removed
staked LINK amount.*


```solidity
function unstakeRemovedPrincipal() external;
```

### getNumOperators

Returns the number of operators configured in the pool.


```solidity
function getNumOperators() external view returns (uint256);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|uint256 The number of operators configured in the pool|


### supportsInterface

This function allows the calling contract to
check if the contract deployed at this address is a valid
LINKTokenReceiver.  A contract is a valid LINKTokenReceiver
if it implements the onTokenTransfer function.


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
|`<none>`|`bool`|bool True if the contract is a valid LINKTokenReceiver.|


### onlySlasher

*Reverts if not sent by an address that has the SLASHER role*


```solidity
modifier onlySlasher();
```

### validatePoolSpace

Checks that the maximum pool size is greater than or equal to
the reserved space for operators.

*The reserved space is calculated by multiplying the number of
operators and the maximum staked LINK amount per operator*


```solidity
modifier validatePoolSpace(
  uint256 maxPoolSize,
  uint256 maxPrincipalPerStaker,
  uint256 numOperators
);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`maxPoolSize`|`uint256`|The maximum pool size of the operator staking pool|
|`maxPrincipalPerStaker`|`uint256`|The maximum amount a operator can stake in the|
|`numOperators`|`uint256`|The number of operators in the pool|


### typeAndVersion


```solidity
function typeAndVersion() external pure virtual override returns (string memory);
```

## Events
### OperatorRemoved
This event is emitted when an operator is removed


```solidity
event OperatorRemoved(address indexed operator, uint256 principal);
```

### OperatorAdded
This event is emitted when an operator is added


```solidity
event OperatorAdded(address indexed operator);
```

### AlerterRewardDeposited
This event is emitted whenever the alerter reward funds is funded


```solidity
event AlerterRewardDeposited(uint256 amountFunded, uint256 totalBalance);
```

### AlerterRewardWithdrawn
This event is emitted whenever the contract manager withdraws from the
alerter reward funds


```solidity
event AlerterRewardWithdrawn(uint256 amountWithdrawn, uint256 remainingBalance);
```

### AlertingRewardPaid
This event is emitted whenever the alerter is paid the full
alerter reward amount


```solidity
event AlertingRewardPaid(
  address indexed alerter, uint256 alerterRewardActual, uint256 alerterRewardExpected
);
```

### SlasherConfigSet
This event is emitted when the slasher config is set


```solidity
event SlasherConfigSet(address indexed slasher, uint256 refillRate, uint256 slashCapacity);
```

### Slashed
This event is emitted when an operator is slashed


```solidity
event Slashed(address indexed operator, uint256 slashedAmount, uint256 updatedStakerPrincipal);
```

## Errors
### InvalidOperatorList
Error code for when the operator list is invalid


```solidity
error InvalidOperatorList();
```

### StakerNotOperator
Error code for when the staker is not an operator


```solidity
error StakerNotOperator();
```

### OperatorAlreadyExists
This error is raised when an address is duplicated in the supplied list of operators.
This can happen in addOperators and setFeedOperators functions.


```solidity
error OperatorAlreadyExists(address operator);
```

### OperatorDoesNotExist
This error is raised when removing an operator that doesn't exist.


```solidity
error OperatorDoesNotExist(address operator);
```

### OperatorHasBeenRemoved
This error is raised when an operator to add has been removed previously.


```solidity
error OperatorHasBeenRemoved(address operator);
```

### OperatorCannotBeCommunityStaker
This error is raised when an operator to add is already a community staker.


```solidity
error OperatorCannotBeCommunityStaker(address operator);
```

### InsufficientPoolSpace
This error is thrown whenever the max pool size is less than the
reserved space for operators


```solidity
error InsufficientPoolSpace(
  uint256 maxPoolSize, uint256 maxPrincipalPerStaker, uint256 numOperators
);
```

### InadequateInitialOperatorCount
This error is raised when attempting to open the staking pool with less
than the minimum required node operators


```solidity
error InadequateInitialOperatorCount(uint256 numOperators, uint256 minInitialOperatorCount);
```

### InvalidAlerterRewardFundAmount
This error is thrown when the contract manager tries to add a zero amount
to the alerter reward funds


```solidity
error InvalidAlerterRewardFundAmount();
```

### InsufficientAlerterRewardFunds
This error is thrown whenever the contract manager tries to withdraw
more than the remaining balance in the alerter reward funds


```solidity
error InsufficientAlerterRewardFunds(uint256 amountToWithdraw, uint256 remainingBalance);
```

## Structs
### ConstructorParams
This struct defines the params required by the Staking contract's
constructor.


```solidity
struct ConstructorParams {
  ConstructorParamsBase baseParams;
  uint256 minInitialOperatorCount;
}
```

### Operator
This struct defines the operator-specific states.


```solidity
struct Operator {
  uint256 removedPrincipal;
  bool isOperator;
  bool isRemoved;
}
```

