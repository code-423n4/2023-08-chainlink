// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {AccessControlEnumerable} from '@openzeppelin/contracts/access/AccessControlEnumerable.sol';
import {EnumerableSet} from '@openzeppelin/contracts/utils/structs/EnumerableSet.sol';

/**
 * @notice Contract module which acts as a timelocked controller with role-based
 * access control. When set as the owner of an `Ownable` smart contract, it
 * can enforce a timelock on `onlyOwner` maintenance operations.
 *
 * Non-emergency actions are expected to follow the timelock.
 *
 * The contract has the multiple roles. Each role can be inhabited by multiple
 * (potentially overlapping) addresses.
 *
 * 1) Admin: The admin manages membership for all roles (including the admin
 *    role itself). The admin automatically inhabits all other roles. In practice, the admin
 *    role is expected to (1) be inhabited by a contract requiring a secure
 *    quorum of votes before taking any action and (2) to be used rarely, namely
 *    only for emergency actions or configuration of the Timelock.
 *    For Staking v0.2, the Admin will be assigned to address(this)
 *
 * 2) Proposer: The proposer can schedule delayed operations.
 *
 * 3) Executor: The executor can execute previously scheduled operations once
 *    their delay has expired.
 *
 * 4) Canceller: The canceller can cancel operations that have been scheduled
 *    but not yet executed.
 *
 *
 * @dev This contract is a modified version of OpenZeppelin's TimelockController
 * contract from v4.7.0, accessed in commit
 * 561d1061fc568f04c7a65853538e834a889751e8 of
 * github.com/OpenZeppelin/openzeppelin-contracts
 *
 * @dev invariant An operation's delay must be greater than or equal to the minimum delay.
 * @dev invariant once scheduled, an operation's delay cannot be modified unless cancelled.
 */
contract Timelock is AccessControlEnumerable {
  using EnumerableSet for EnumerableSet.Bytes32Set;

  /**
   * @dev Emitted when a call is scheduled as part of operation `id`.
   * @dev The target is not indexed in order to keep the original event signature
   * @param id Unique identifier for the operation.
   * @param index Index of the call within the operation.
   * @param target Address that the call will be made to.
   * @param value ETH value that will be passed to the call.
   * @param data Data that will be passed to the call.
   * @param predecessor ID of the preceding operation.
   * @param salt Arbitrary number to facilitate uniqueness of the operation's hash.
   * @param delay Duration before the operation can be executed.
   */
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

  /**
   * @dev Emitted when a call is performed as part of operation `id`.
   * @dev The target is not indexed in order to keep the original event signature
   * @param id Unique identifier for the operation.
   * @param index Index of the call within the operation.
   * @param target Address that the call is made to.
   * @param value ETH value that is passed to the call.
   * @param data Data that is passed to the call.
   */
  event CallExecuted(
    bytes32 indexed id, uint256 indexed index, address target, uint256 value, bytes data
  );

  /**
   * @dev Emitted when operation `id` is cancelled.
   * @param id Unique identifier for the operation.
   */
  event Cancelled(bytes32 indexed id);

  /**
   * @dev Emitted when the minimum delay for future operations is modified.
   * @param oldDuration Old duration of minimum timelock delay.
   * @param newDuration New duration of minimum timelock delay.
   */
  event MinDelayChange(uint256 oldDuration, uint256 newDuration);

  /**
   * @dev Emitted when the delay for future operations of a specific function selector is modified.
   * @param target The target contract address that's min delay has been changed.
   * @param selector The first four bytes of a function signature.
   * @param oldDuration Old duration of minimum timelock delay.
   * @param newDuration New duration of minimum timelock delay.
   */
  event MinDelayChange(
    address indexed target, bytes4 selector, uint256 oldDuration, uint256 newDuration
  );

  /// @notice This struct defines a contract call to be made as part of an operation
  struct Call {
    /// @notice contract address called by the Timelock
    address target;
    /// @notice amount of ETH to send with the call
    uint256 value;
    /// @notice calldata to send with the call
    bytes data;
  }

  /// @notice This struct defines the params required to update
  /// the timelock delay for a target contract's function
  struct UpdateDelayParams {
    /// @notice target contract address called by the Timelock
    address target;
    /// @notice selector is the first four bytes of a function signature
    bytes4 selector;
    /// @notice Number of seconds to set as the minimum timelock delay when
    uint256 newDelay;
  }

  /// @notice The role that manages membership for all roles
  /// @dev Hash: a49807205ce4d355092ef5a8a18f56e8913cf4a201fbe287825b095693c21775
  bytes32 public constant ADMIN_ROLE = keccak256('ADMIN_ROLE');
  /// @notice The role that can schedule delayed operations
  /// @dev Hash: b09aa5aeb3702cfd50b6b62bc4532604938f21248a27a1d5ca736082b6819cc1
  bytes32 public constant PROPOSER_ROLE = keccak256('PROPOSER_ROLE');
  /// @notice The role that can execute scheduled operations
  /// @dev Hash: d8aa0f3194971a2a116679f7c2090f6939c8d4e01a2a8d7e41d55e5351469e63
  bytes32 public constant EXECUTOR_ROLE = keccak256('EXECUTOR_ROLE');
  /// @notice The role that can cancel scheduled operations
  /// @dev Hash: fd643c72710c63c0180259aba6b2d05451e3591a24e58b62239378085726f783
  bytes32 public constant CANCELLER_ROLE = keccak256('CANCELLER_ROLE');
  /// @notice The timestamp when an operation is done. This helps distinguish a registered operation
  /// (could be either pending/ready/done) vs an unregistered operation.
  uint256 private constant _DONE_TIMESTAMP = uint256(1);

  /// @notice The timestamp when an operation ID can be executed
  mapping(bytes32 => uint256) private s_timestamps;

  /// @notice The minimum timelock delay in seconds applied to any calls
  /// scheduled made from this Timelock contract
  uint256 private s_minDelay;

  /// @notice Custom timelock delays for a specific function signature
  /// @dev This contract maps a target contract address and function selector
  /// to delay durations in seconds.
  mapping(address => mapping(bytes4 => uint256)) private s_delays;

  /**
   * @dev Initializes the contract with the following parameters:
   *
   * - `minDelay`: initial minimum delay for operations
   * - `admin`: account to be granted admin role
   * - `proposers`: accounts to be granted proposer role
   * - `executors`: accounts to be granted executor role
   * - `cancellers`: accounts to be granted canceller role
   *
   * The admin is the most powerful role. Only an admin can manage membership
   * of all roles.
   */
  constructor(
    uint256 minDelay,
    address admin,
    address[] memory proposers,
    address[] memory executors,
    address[] memory cancellers
  ) {
    _setRoleAdmin(ADMIN_ROLE, ADMIN_ROLE);
    _setRoleAdmin(PROPOSER_ROLE, ADMIN_ROLE);
    _setRoleAdmin(EXECUTOR_ROLE, ADMIN_ROLE);
    _setRoleAdmin(CANCELLER_ROLE, ADMIN_ROLE);

    _grantRole(ADMIN_ROLE, admin);

    // register proposers
    uint256 proposersLength = proposers.length;
    for (uint256 i; i < proposersLength; ++i) {
      _grantRole(PROPOSER_ROLE, proposers[i]);
    }

    // register executors
    uint256 executorsLength = executors.length;
    for (uint256 i; i < executorsLength; ++i) {
      _grantRole(EXECUTOR_ROLE, executors[i]);
    }

    // register cancellers
    uint256 cancellersLength = cancellers.length;
    for (uint256 i; i < cancellersLength; ++i) {
      _grantRole(CANCELLER_ROLE, cancellers[i]);
    }

    s_minDelay = minDelay;
    emit MinDelayChange(0, minDelay);
  }

  /**
   * @dev Modifier to make a function callable only by a certain role or the
   * admin role.
   * @param role Role that the caller must have.
   */
  modifier onlyRoleOrAdminRole(bytes32 role) {
    address sender = _msgSender();
    if (!hasRole(ADMIN_ROLE, sender)) {
      _checkRole(role, sender);
    }
    _;
  }

  /**
   * @dev Contract might receive/hold ETH as part of the maintenance process.
   */
  receive() external payable {}

  /**
   * @dev Returns whether an id correspond to a registered operation. This
   * includes both Pending, Ready and Done operations.
   * @param id Unique identifier for the operation.
   * @return bool True if the id correspond to a registered operation.
   */
  function isOperation(bytes32 id) public view virtual returns (bool) {
    return getTimestamp(id) != 0;
  }

  /**
   * @dev Returns whether an operation is pending or not.
   * @param id Unique identifier for the operation.
   * @return bool True if the operation is pending.
   */
  function isOperationPending(bytes32 id) public view virtual returns (bool) {
    return getTimestamp(id) > _DONE_TIMESTAMP;
  }

  /**
   * @dev Returns whether an operation is ready or not.
   * @param id Unique identifier for the operation.
   * @return bool True if the operation is ready.
   */
  function isOperationReady(bytes32 id) public view virtual returns (bool) {
    uint256 timestamp = getTimestamp(id);
    return timestamp > _DONE_TIMESTAMP && timestamp <= block.timestamp;
  }

  /**
   * @dev Returns whether an operation is done or not.
   * @param id Unique identifier for the operation.
   * @return bool True if the operation is done.
   */
  function isOperationDone(bytes32 id) public view virtual returns (bool) {
    return getTimestamp(id) == _DONE_TIMESTAMP;
  }

  /**
   * @dev Returns the timestamp at with an operation becomes ready (0 for
   * unset operations, 1 for done operations).
   * @param id Unique identifier for the operation.
   * @return uint256 Timestamp at which the operation becomes ready to be executed.
   */
  function getTimestamp(bytes32 id) public view virtual returns (uint256) {
    return s_timestamps[id];
  }

  /**
   * @dev Returns the minimum delay for an operation to become valid.
   * This value can be changed by executing an operation that calls `updateDelay`.
   * @return uint256 The minimum timelock delay in seconds
   */
  function getMinDelay() external view virtual returns (uint256) {
    return s_minDelay;
  }

  /// @notice Returns the delay for an operation with a specific function selector to become valid.
  /// @param target contract address called by the Timelock
  /// @param selector The first four bytes of a function signature
  /// @return uint256 The minimum timelock delay in seconds
  function getMinDelay(address target, bytes4 selector) public view returns (uint256) {
    uint256 delay = s_delays[target][selector];
    return delay >= s_minDelay ? delay : s_minDelay;
  }

  /// @notice Returns the delay for a batch of contract calls.
  /// @param calls List of contract calls to include in a batch
  /// @return uint256 The minimum timelock delay in seconds
  function getMinDelay(Call[] calldata calls) public view returns (uint256) {
    uint256 largestDelay;
    uint256 callsLength = calls.length;
    for (uint256 i; i < callsLength; ++i) {
      uint256 selectorDelay = getMinDelay(calls[i].target, bytes4(calls[i].data[:4]));
      if (selectorDelay > largestDelay) {
        largestDelay = selectorDelay;
      }
    }
    return largestDelay;
  }

  /**
   * @dev Returns the identifier of an operation containing a batch of
   * transactions.
   * @param calls List of contract calls to include in a batch.
   * @param predecessor ID of the preceding operation.
   * @param salt Arbitrary number to facilitate uniqueness of the operation's hash.
   * @return bytes32 The operation's hash (unique identifier).
   */
  function hashOperationBatch(
    Call[] calldata calls,
    bytes32 predecessor,
    bytes32 salt
  ) public pure virtual returns (bytes32) {
    return keccak256(abi.encode(calls, predecessor, salt));
  }

  /**
   * @dev Schedule an operation containing a batch of transactions.
   *
   * Emits one {CallScheduled} event per transaction in the batch.
   *
   * Requirements:
   *
   * - the caller must have the 'proposer' or 'admin' role.
   *
   * @dev precondition `calls` must not be already scheduled
   *
   * @param calls List of contract calls to include in a batch.
   * @param predecessor ID of the preceding operation.
   * @param salt Arbitrary number to facilitate uniqueness of the operation's hash.
   * @param delay Duration before the operation can be executed.
   */
  function scheduleBatch(
    Call[] calldata calls,
    bytes32 predecessor,
    bytes32 salt,
    uint256 delay
  ) public virtual onlyRoleOrAdminRole(PROPOSER_ROLE) {
    bytes32 id = hashOperationBatch({calls: calls, predecessor: predecessor, salt: salt});
    _schedule({id: id, delay: delay, calls: calls});
    uint256 callsLength = calls.length;
    for (uint256 i; i < callsLength; ++i) {
      emit CallScheduled(
        id, i, calls[i].target, calls[i].value, calls[i].data, predecessor, salt, delay
      );
    }
  }

  /**
   * @dev Schedule an operation that is to becomes valid after a given delay.
   * For a batch of calls with multiple function selectors, the largest delay is used as the
   * minimum.
   * @param id Unique identifier for the operation.
   * @param delay Duration before the operation can be executed.
   * @param calls List of contract calls to include in a batch.
   */
  function _schedule(bytes32 id, uint256 delay, Call[] calldata calls) private {
    require(!isOperation(id), 'Timelock: operation already scheduled');
    require(delay >= getMinDelay(calls), 'Timelock: insufficient delay');

    s_timestamps[id] = block.timestamp + delay;
  }

  /**
   * @dev Cancel an operation.
   *
   * Requirements:
   *
   * - the caller must have the 'canceller' or 'admin' role.
   *
   * @dev precondition `id` must be scheduled and not done
   *
   * @param id Unique identifier for the operation.
   */
  function cancel(bytes32 id) external virtual onlyRoleOrAdminRole(CANCELLER_ROLE) {
    require(isOperationPending(id), 'Timelock: operation cannot be cancelled');
    delete s_timestamps[id];

    emit Cancelled(id);
  }

  /**
   * @dev Execute an (ready) operation containing a batch of transactions.
   * Note that we perform a raw call to each target. Raw calls to targets that
   * don't have associated contract code will always succeed regardless of
   * payload.
   *
   * Emits one {CallExecuted} event per transaction in the batch.
   *
   * Requirements:
   *
   * - the caller must have the 'executor' or 'admin' role.
   *
   * @dev precondition `calls` must be scheduled and not done
   * @dev precondition delay must have passed
   * @dev precondition `predecessor` must be not set or must be done
   *
   * @param calls List of contract calls to include in a batch.
   * @param predecessor ID of the preceding operation.
   * @param salt Arbitrary number to facilitate uniqueness of the operation's hash.
   */
  function executeBatch(
    Call[] calldata calls,
    bytes32 predecessor,
    bytes32 salt
  ) public payable virtual onlyRoleOrAdminRole(EXECUTOR_ROLE) {
    bytes32 id = hashOperationBatch({calls: calls, predecessor: predecessor, salt: salt});

    _beforeCall(id, predecessor);
    uint256 callsLength = calls.length;
    for (uint256 i; i < callsLength; ++i) {
      _execute(calls[i]);
      emit CallExecuted(id, i, calls[i].target, calls[i].value, calls[i].data);
    }
    _afterCall(id);
  }

  /**
   * @dev Execute an operation's call.
   *
   * @param call The call to execute.
   */
  function _execute(Call calldata call) internal virtual {
    (bool success,) = call.target.call{value: call.value}(call.data);
    require(success, 'Timelock: underlying transaction reverted');
  }

  /**
   * @dev Checks before execution of an operation's calls.
   * @param id Unique identifier for the operation.
   * @param predecessor ID of the preceding operation.
   */
  function _beforeCall(bytes32 id, bytes32 predecessor) private view {
    require(isOperationReady(id), 'Timelock: operation is not ready');
    require(
      predecessor == bytes32(0) || isOperationDone(predecessor), 'Timelock: missing dependency'
    );
  }

  /**
   * @dev Checks after execution of an operation's calls.
   * @param id Unique identifier for the operation.
   */
  function _afterCall(bytes32 id) private {
    require(isOperationReady(id), 'Timelock: operation is not ready');
    s_timestamps[id] = _DONE_TIMESTAMP;
  }

  /**
   * @dev Changes the minimum timelock duration for future operations.
   *
   * Emits a {MinDelayChange} event.
   *
   * Requirements:
   *
   * - the caller must have the 'admin' role.
   *
   * @param newDelay Number of seconds to set as the minimum timelock delay.
   */
  function updateDelay(uint256 newDelay) external virtual onlyRole(ADMIN_ROLE) {
    uint256 oldDelay = s_minDelay;
    s_minDelay = newDelay;
    emit MinDelayChange(oldDelay, newDelay);
  }

  /// @notice Changes the minimum timelock duration for future operations of a
  /// specific function selector. In a batch, the largest value is used as the timelock delay.
  /// @param params List of (target address, function selector, delay in seconds)
  /// the specified function selector is scheduled in an operation
  function updateDelay(UpdateDelayParams[] calldata params) external virtual onlyRole(ADMIN_ROLE) {
    uint256 paramsLength = params.length;
    for (uint256 i; i < paramsLength; ++i) {
      _setDelay({
        target: params[i].target,
        selector: params[i].selector,
        newDelay: params[i].newDelay
      });
    }
  }

  /// @notice Sets the minimum timelock duration for a specific function selector
  /// @param target contract address called by the Timelock
  /// @param selector The first four bytes of a function signature
  /// @param newDelay Number of seconds to set as the minimum timelock delay when
  /// the specified function selector is scheduled in an operation
  function _setDelay(address target, bytes4 selector, uint256 newDelay) internal {
    require(newDelay >= s_minDelay, 'Timelock: insufficient delay');
    uint256 oldDelay = s_delays[target][selector];
    s_delays[target][selector] = newDelay;
    emit MinDelayChange(target, selector, oldDelay, newDelay);
  }
}
