# Timelock
[Git Source](https://github.com/smartcontractkit/destiny-next/blob/93e1115f8d7fb0029b73a936d125afb837306065/src/timelock/Timelock.sol)

**Inherits:**
AccessControlEnumerable

Contract module which acts as a timelocked controller with role-based
access control. When set as the owner of an `Ownable` smart contract, it
can enforce a timelock on `onlyOwner` maintenance operations.
Non-emergency actions are expected to follow the timelock.
The contract has the multiple roles. Each role can be inhabited by multiple
(potentially overlapping) addresses.
1) Admin: The admin manages membership for all roles (including the admin
role itself). The admin automatically inhabits all other roles. In practice, the admin
role is expected to (1) be inhabited by a contract requiring a secure
quorum of votes before taking any action and (2) to be used rarely, namely
only for emergency actions or configuration of the Timelock.
For Staking v0.2, the Admin will be assigned to address(this)
2) Proposer: The proposer can schedule delayed operations.
3) Executor: The executor can execute previously scheduled operations once
their delay has expired.
4) Canceller: The canceller can cancel operations that have been scheduled
but not yet executed.

*This contract is a modified version of OpenZeppelin's TimelockController
contract from v4.7.0, accessed in commit
561d1061fc568f04c7a65853538e834a889751e8 of
github.com/OpenZeppelin/openzeppelin-contracts*

*invariant An operation's delay must be greater than or equal to the minimum delay.*

*invariant once scheduled, an operation's delay cannot be modified unless cancelled.*


## State Variables
### ADMIN_ROLE
The role that manages membership for all roles

*Hash: a49807205ce4d355092ef5a8a18f56e8913cf4a201fbe287825b095693c21775*


```solidity
bytes32 public constant ADMIN_ROLE = keccak256('ADMIN_ROLE');
```


### PROPOSER_ROLE
The role that can schedule delayed operations

*Hash: b09aa5aeb3702cfd50b6b62bc4532604938f21248a27a1d5ca736082b6819cc1*


```solidity
bytes32 public constant PROPOSER_ROLE = keccak256('PROPOSER_ROLE');
```


### EXECUTOR_ROLE
The role that can execute scheduled operations

*Hash: d8aa0f3194971a2a116679f7c2090f6939c8d4e01a2a8d7e41d55e5351469e63*


```solidity
bytes32 public constant EXECUTOR_ROLE = keccak256('EXECUTOR_ROLE');
```


### CANCELLER_ROLE
The role that can cancel scheduled operations

*Hash: fd643c72710c63c0180259aba6b2d05451e3591a24e58b62239378085726f783*


```solidity
bytes32 public constant CANCELLER_ROLE = keccak256('CANCELLER_ROLE');
```


### _DONE_TIMESTAMP
The timestamp when an operation is done. This helps distinguish a registered operation
(could be either pending/ready/done) vs an unregistered operation.


```solidity
uint256 private constant _DONE_TIMESTAMP = uint256(1);
```


### s_timestamps
The timestamp when an operation ID can be executed


```solidity
mapping(bytes32 => uint256) private s_timestamps;
```


### s_minDelay
The minimum timelock delay in seconds applied to any calls
scheduled made from this Timelock contract


```solidity
uint256 private s_minDelay;
```


### s_delays
Custom timelock delays for a specific function signature

*This contract maps a target contract address and function selector
to delay durations in seconds.*


```solidity
mapping(address => mapping(bytes4 => uint256)) private s_delays;
```


## Functions
### constructor

*Initializes the contract with the following parameters:
- `minDelay`: initial minimum delay for operations
- `admin`: account to be granted admin role
- `proposers`: accounts to be granted proposer role
- `executors`: accounts to be granted executor role
- `cancellers`: accounts to be granted canceller role
The admin is the most powerful role. Only an admin can manage membership
of all roles.*


```solidity
constructor(
  uint256 minDelay,
  address admin,
  address[] memory proposers,
  address[] memory executors,
  address[] memory cancellers
);
```

### onlyRoleOrAdminRole

*Modifier to make a function callable only by a certain role or the
admin role.*


```solidity
modifier onlyRoleOrAdminRole(bytes32 role);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`role`|`bytes32`|Role that the caller must have.|


### receive

*Contract might receive/hold ETH as part of the maintenance process.*


```solidity
receive() external payable;
```

### isOperation

*Returns whether an id correspond to a registered operation. This
includes both Pending, Ready and Done operations.*


```solidity
function isOperation(bytes32 id) public view virtual returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`id`|`bytes32`|Unique identifier for the operation.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|bool True if the id correspond to a registered operation.|


### isOperationPending

*Returns whether an operation is pending or not.*


```solidity
function isOperationPending(bytes32 id) public view virtual returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`id`|`bytes32`|Unique identifier for the operation.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|bool True if the operation is pending.|


### isOperationReady

*Returns whether an operation is ready or not.*


```solidity
function isOperationReady(bytes32 id) public view virtual returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`id`|`bytes32`|Unique identifier for the operation.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|bool True if the operation is ready.|


### isOperationDone

*Returns whether an operation is done or not.*


```solidity
function isOperationDone(bytes32 id) public view virtual returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`id`|`bytes32`|Unique identifier for the operation.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|bool True if the operation is done.|


### getTimestamp

*Returns the timestamp at with an operation becomes ready (0 for
unset operations, 1 for done operations).*


```solidity
function getTimestamp(bytes32 id) public view virtual returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`id`|`bytes32`|Unique identifier for the operation.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|uint256 Timestamp at which the operation becomes ready to be executed.|


### getMinDelay

*Returns the minimum delay for an operation to become valid.
This value can be changed by executing an operation that calls `updateDelay`.*


```solidity
function getMinDelay() external view virtual returns (uint256);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|uint256 The minimum timelock delay in seconds|


### getMinDelay

Returns the delay for an operation with a specific function selector to become valid.


```solidity
function getMinDelay(address target, bytes4 selector) public view returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`target`|`address`|contract address called by the Timelock|
|`selector`|`bytes4`|The first four bytes of a function signature|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|uint256 The minimum timelock delay in seconds|


### getMinDelay

Returns the delay for a batch of contract calls.


```solidity
function getMinDelay(Call[] calldata calls) public view returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`calls`|`Call[]`|List of contract calls to include in a batch|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|uint256 The minimum timelock delay in seconds|


### hashOperationBatch

*Returns the identifier of an operation containing a batch of
transactions.*


```solidity
function hashOperationBatch(
  Call[] calldata calls,
  bytes32 predecessor,
  bytes32 salt
) public pure virtual returns (bytes32);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`calls`|`Call[]`|List of contract calls to include in a batch.|
|`predecessor`|`bytes32`|ID of the preceding operation.|
|`salt`|`bytes32`|Arbitrary number to facilitate uniqueness of the operation's hash.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bytes32`|bytes32 The operation's hash (unique identifier).|


### scheduleBatch

*Schedule an operation containing a batch of transactions.
Emits one {CallScheduled} event per transaction in the batch.
Requirements:
- the caller must have the 'proposer' or 'admin' role.*

*precondition `calls` must not be already scheduled*


```solidity
function scheduleBatch(
  Call[] calldata calls,
  bytes32 predecessor,
  bytes32 salt,
  uint256 delay
) public virtual onlyRoleOrAdminRole(PROPOSER_ROLE);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`calls`|`Call[]`|List of contract calls to include in a batch.|
|`predecessor`|`bytes32`|ID of the preceding operation.|
|`salt`|`bytes32`|Arbitrary number to facilitate uniqueness of the operation's hash.|
|`delay`|`uint256`|Duration before the operation can be executed.|


### _schedule

*Schedule an operation that is to becomes valid after a given delay.
For a batch of calls with multiple function selectors, the largest delay is used as the
minimum.*


```solidity
function _schedule(bytes32 id, uint256 delay, Call[] calldata calls) private;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`id`|`bytes32`|Unique identifier for the operation.|
|`delay`|`uint256`|Duration before the operation can be executed.|
|`calls`|`Call[]`|List of contract calls to include in a batch.|


### cancel

*Cancel an operation.
Requirements:
- the caller must have the 'canceller' or 'admin' role.*

*precondition `id` must be scheduled and not done*


```solidity
function cancel(bytes32 id) external virtual onlyRoleOrAdminRole(CANCELLER_ROLE);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`id`|`bytes32`|Unique identifier for the operation.|


### executeBatch

*Execute an (ready) operation containing a batch of transactions.
Note that we perform a raw call to each target. Raw calls to targets that
don't have associated contract code will always succeed regardless of
payload.
Emits one {CallExecuted} event per transaction in the batch.
Requirements:
- the caller must have the 'executor' or 'admin' role.*

*precondition `calls` must be scheduled and not done*

*precondition delay must have passed*

*precondition `predecessor` must be not set or must be done*


```solidity
function executeBatch(
  Call[] calldata calls,
  bytes32 predecessor,
  bytes32 salt
) public payable virtual onlyRoleOrAdminRole(EXECUTOR_ROLE);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`calls`|`Call[]`|List of contract calls to include in a batch.|
|`predecessor`|`bytes32`|ID of the preceding operation.|
|`salt`|`bytes32`|Arbitrary number to facilitate uniqueness of the operation's hash.|


### _execute

*Execute an operation's call.*


```solidity
function _execute(Call calldata call) internal virtual;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`call`|`Call`|The call to execute.|


### _beforeCall

*Checks before execution of an operation's calls.*


```solidity
function _beforeCall(bytes32 id, bytes32 predecessor) private view;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`id`|`bytes32`|Unique identifier for the operation.|
|`predecessor`|`bytes32`|ID of the preceding operation.|


### _afterCall

*Checks after execution of an operation's calls.*


```solidity
function _afterCall(bytes32 id) private;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`id`|`bytes32`|Unique identifier for the operation.|


### updateDelay

*Changes the minimum timelock duration for future operations.
Emits a {MinDelayChange} event.
Requirements:
- the caller must have the 'admin' role.*


```solidity
function updateDelay(uint256 newDelay) external virtual onlyRole(ADMIN_ROLE);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`newDelay`|`uint256`|Number of seconds to set as the minimum timelock delay.|


### updateDelay

Changes the minimum timelock duration for future operations of a
specific function selector. In a batch, the largest value is used as the timelock delay.


```solidity
function updateDelay(UpdateDelayParams[] calldata params) external virtual onlyRole(ADMIN_ROLE);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`params`|`UpdateDelayParams[]`|List of (target address, function selector, delay in seconds) the specified function selector is scheduled in an operation|


### _setDelay

Sets the minimum timelock duration for a specific function selector


```solidity
function _setDelay(address target, bytes4 selector, uint256 newDelay) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`target`|`address`|contract address called by the Timelock|
|`selector`|`bytes4`|The first four bytes of a function signature|
|`newDelay`|`uint256`|Number of seconds to set as the minimum timelock delay when the specified function selector is scheduled in an operation|


## Events
### CallScheduled
*Emitted when a call is scheduled as part of operation `id`.*

*The target is not indexed in order to keep the original event signature*


```solidity
event CallScheduled(
  bytes32 indexed id,
  uint256 indexed index,
  address target,
  uint256 value,
  bytes data,
  bytes32 predecessor,
  bytes32 salt,
  uint256 delay
);
```

### CallExecuted
*Emitted when a call is performed as part of operation `id`.*

*The target is not indexed in order to keep the original event signature*


```solidity
event CallExecuted(
  bytes32 indexed id, uint256 indexed index, address target, uint256 value, bytes data
);
```

### Cancelled
*Emitted when operation `id` is cancelled.*


```solidity
event Cancelled(bytes32 indexed id);
```

### MinDelayChange
*Emitted when the minimum delay for future operations is modified.*


```solidity
event MinDelayChange(uint256 oldDuration, uint256 newDuration);
```

### MinDelayChange
*Emitted when the delay for future operations of a specific function selector is modified.*


```solidity
event MinDelayChange(
  address indexed target, bytes4 selector, uint256 oldDuration, uint256 newDuration
);
```

## Structs
### Call
This struct defines a contract call to be made as part of an operation


```solidity
struct Call {
  address target;
  uint256 value;
  bytes data;
}
```

### UpdateDelayParams
This struct defines the params required to update
the timelock delay for a target contract's function


```solidity
struct UpdateDelayParams {
  address target;
  bytes4 selector;
  uint256 newDelay;
}
```

