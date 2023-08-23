// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Counter} from '../src/tests/Counter.sol';
import {TimelockReentrant} from '../src/tests/TimelockReentrant.sol';
import {Timelock} from '../src/timelock/Timelock.sol';

import {BaseTestTimelocked} from './BaseTestTimelocked.t.sol';

contract Timelock_Constructor is BaseTestTimelocked {
  function test_AdminRoleSet() public {
    bool hasAdminRole = s_timelock.hasRole(s_timelock.ADMIN_ROLE(), ADMIN);
    assertEq(hasAdminRole, true);
  }

  function test_ProposersDoNotHaveAdminRole() public {
    BaseTestTimelocked.checkRoleNotSetForAddresses(s_timelock, s_timelock.ADMIN_ROLE(), PROPOSERS);
  }

  function test_ExecutorsDoNotHaveAdminRole() public {
    BaseTestTimelocked.checkRoleNotSetForAddresses(s_timelock, s_timelock.ADMIN_ROLE(), EXECUTORS);
  }

  function test_CancellersDoNotHaveAdminRole() public {
    BaseTestTimelocked.checkRoleNotSetForAddresses(s_timelock, s_timelock.ADMIN_ROLE(), CANCELLERS);
  }

  function test_ProposerRolesSet() public {
    assertEq(s_timelock.hasRole(s_timelock.PROPOSER_ROLE(), PROPOSER_ONE), true);
    assertEq(s_timelock.hasRole(s_timelock.PROPOSER_ROLE(), PROPOSER_TWO), true);
  }

  function test_AdminDoesNotHaveProposerRole() public {
    assertFalse(s_timelock.hasRole(s_timelock.PROPOSER_ROLE(), ADMIN));
  }

  function test_ExecutorsDoNotHaveProposerRole() public {
    BaseTestTimelocked.checkRoleNotSetForAddresses(
      s_timelock, s_timelock.PROPOSER_ROLE(), EXECUTORS
    );
  }

  function test_CancellersDoNotHaveProposerRole() public {
    BaseTestTimelocked.checkRoleNotSetForAddresses(
      s_timelock, s_timelock.PROPOSER_ROLE(), CANCELLERS
    );
  }

  function test_ExecutorRolesSet() public {
    assertEq(s_timelock.hasRole(s_timelock.EXECUTOR_ROLE(), EXECUTOR_ONE), true);
    assertEq(s_timelock.hasRole(s_timelock.EXECUTOR_ROLE(), EXECUTOR_TWO), true);
  }

  function test_AdminDoesNotHaveExecutorRole() public {
    assertFalse(s_timelock.hasRole(s_timelock.EXECUTOR_ROLE(), ADMIN));
  }

  function test_ProposersDoNotHaveExecutorRole() public {
    BaseTestTimelocked.checkRoleNotSetForAddresses(
      s_timelock, s_timelock.EXECUTOR_ROLE(), PROPOSERS
    );
  }

  function test_CancellersDoNotHaveExecutorRole() public {
    BaseTestTimelocked.checkRoleNotSetForAddresses(
      s_timelock, s_timelock.EXECUTOR_ROLE(), CANCELLERS
    );
  }

  function test_CancellerRolesSet() public {
    assertEq(s_timelock.hasRole(s_timelock.CANCELLER_ROLE(), CANCELLER_ONE), true);
    assertEq(s_timelock.hasRole(s_timelock.CANCELLER_ROLE(), CANCELLER_TWO), true);
  }

  function test_AdminDoesNotHaveCancellerRole() public {
    assertFalse(s_timelock.hasRole(s_timelock.CANCELLER_ROLE(), ADMIN));
  }

  function test_ExecutorsDoNotHaveCancellerRole() public {
    BaseTestTimelocked.checkRoleNotSetForAddresses(
      s_timelock, s_timelock.CANCELLER_ROLE(), EXECUTORS
    );
  }

  function test_ProposersDoNotHaveCancellerRole() public {
    BaseTestTimelocked.checkRoleNotSetForAddresses(
      s_timelock, s_timelock.CANCELLER_ROLE(), PROPOSERS
    );
  }

  function test_MinDelaySet() public {
    assertEq(s_timelock.getMinDelay(), MIN_DELAY);
  }
}

contract Timelock_HashOperationBatch is BaseTestTimelocked {
  function test_HashesBatchedOperationsCorrectly() public {
    Timelock.Call[] memory calls = new Timelock.Call[](2);
    calls[0] = Timelock.Call({
      target: address(s_counter),
      value: 0,
      data: abi.encodeWithSelector(Counter.increment.selector)
    });
    calls[1] = Timelock.Call({
      target: address(s_counter),
      value: 1,
      data: abi.encodeWithSelector(Counter.setNumber.selector, 10)
    });
    bytes32 predecessor = NO_PREDECESSOR;
    bytes32 salt = EMPTY_SALT;

    bytes32 hashedOperation = s_timelock.hashOperationBatch(calls, predecessor, salt);
    bytes32 expectedHash = keccak256(abi.encode(calls, predecessor, salt));
    assertEq(hashedOperation, expectedHash);
  }
}

contract Timelock_UpdateDelay is BaseTestTimelocked {
  event MinDelayChange(uint256 oldDuration, uint256 newDuration);

  function test_RevertWhen_NotAdminRole() public {
    vm.expectRevert(_getExpectedMissingRoleErrorMessage(STRANGER, s_timelock.ADMIN_ROLE()));
    changePrank(STRANGER);
    s_timelock.updateDelay(3 days);
  }

  function test_UpdatesMinDelay() public {
    changePrank(ADMIN);
    s_timelock.updateDelay(3 days);
    uint256 minDelay = s_timelock.getMinDelay();
    assertEq(minDelay, 3 days);
  }

  function test_EmitsEvent() public {
    changePrank(ADMIN);
    vm.expectEmit(true, true, true, true, address(s_timelock));
    emit MinDelayChange(MIN_DELAY, 3 days);
    s_timelock.updateDelay(3 days);
  }
}

contract Timelock_UpdateDelay_Selector is BaseTestTimelocked {
  function test_RevertWhen_NotAdminRole() public {
    Timelock.UpdateDelayParams[] memory params = new Timelock.UpdateDelayParams[](1);
    params[0] = Timelock.UpdateDelayParams({
      target: address(s_counter),
      selector: Counter.increment.selector,
      newDelay: 31 days
    });

    vm.expectRevert(_getExpectedMissingRoleErrorMessage(STRANGER, s_timelock.ADMIN_ROLE()));
    changePrank(STRANGER);
    s_timelock.updateDelay(params);
  }

  function test_RevertWhen_LessThanMinDelay() public {
    Timelock.UpdateDelayParams[] memory params = new Timelock.UpdateDelayParams[](1);
    params[0] = Timelock.UpdateDelayParams({
      target: address(s_counter),
      selector: Counter.increment.selector,
      newDelay: MIN_DELAY - 1
    });

    changePrank(ADMIN);
    vm.expectRevert('Timelock: insufficient delay');
    s_timelock.updateDelay(params);
  }

  function test_UpdatesDelay() public {
    Timelock.UpdateDelayParams[] memory params = new Timelock.UpdateDelayParams[](1);
    params[0] = Timelock.UpdateDelayParams({
      target: address(s_counter),
      selector: Counter.increment.selector,
      newDelay: 31 days
    });

    changePrank(ADMIN);
    s_timelock.updateDelay(params);
    uint256 minDelay = s_timelock.getMinDelay(address(s_counter), Counter.increment.selector);
    assertEq(minDelay, 31 days);
  }

  function test_UpdatesDelay_AtLeastMinDelay() public {
    changePrank(ADMIN);
    s_timelock.updateDelay(0); // set min delay to 0

    Timelock.UpdateDelayParams[] memory params = new Timelock.UpdateDelayParams[](1);
    params[0] = Timelock.UpdateDelayParams({
      target: address(s_counter),
      selector: Counter.increment.selector,
      newDelay: MIN_DELAY - 1 // set to less than min delay
    });
    changePrank(ADMIN);
    s_timelock.updateDelay(params);

    // Global Min delay should be applied to all targets and functions
    changePrank(ADMIN);
    s_timelock.updateDelay(MIN_DELAY);
    uint256 minDelay = s_timelock.getMinDelay(address(s_counter), Counter.increment.selector);
    assertEq(minDelay, MIN_DELAY);
  }
}

contract Timelock_ScheduleBatch_Multiple is BaseTestTimelocked {
  Counter internal s_counterTwo;
  Timelock.Call[] internal s_calls;

  function setUp() public override {
    BaseTestTimelocked.setUp();

    s_calls.push(
      Timelock.Call({
        target: address(s_counter),
        value: 0,
        data: abi.encodeWithSelector(Counter.increment.selector)
      })
    );
    s_calls.push(
      Timelock.Call({
        target: address(s_counterTwo),
        value: 0,
        data: abi.encodeWithSelector(Counter.setNumber.selector, 10)
      })
    );
  }

  function test_RevertWhen_NotProposer() public {
    vm.expectRevert(_getExpectedMissingRoleErrorMessage(STRANGER, s_timelock.PROPOSER_ROLE()));
    changePrank(STRANGER);
    s_timelock.scheduleBatch(s_calls, NO_PREDECESSOR, EMPTY_SALT, MIN_DELAY);
  }

  function test_ProposerCanBatchSchedule() public {
    _scheduleBatchedOperation(PROPOSER_ONE);
  }

  function test_AdminCanBatchSchedule() public {
    _scheduleBatchedOperation(ADMIN);
  }

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

  function _scheduleBatchedOperation(address proposer) internal {
    bytes32 batchedOperationID = s_timelock.hashOperationBatch(s_calls, NO_PREDECESSOR, EMPTY_SALT);

    assertEq(s_timelock.isOperation(batchedOperationID), false);

    for (uint256 i = 0; i < s_calls.length; ++i) {
      vm.expectEmit(true, true, true, true, address(s_timelock));

      emit CallScheduled(
        batchedOperationID,
        i,
        s_calls[i].target,
        s_calls[i].value,
        s_calls[i].data,
        NO_PREDECESSOR,
        EMPTY_SALT,
        MIN_DELAY
      );
    }

    changePrank(proposer);
    s_timelock.scheduleBatch(s_calls, NO_PREDECESSOR, EMPTY_SALT, MIN_DELAY);

    assertEq(s_timelock.isOperation(batchedOperationID), true);
  }
}

contract Timelock_ScheduleBatch_Single is BaseTestTimelocked {
  function test_RevertWhen_Proposer() public {
    vm.expectRevert(_getExpectedMissingRoleErrorMessage(STRANGER, s_timelock.PROPOSER_ROLE()));
    changePrank(STRANGER);
    s_timelock.scheduleBatch(
      _singletonCalls(
        Timelock.Call({
          target: address(s_counter),
          value: 0,
          data: abi.encodeWithSelector(Counter.increment.selector)
        })
      ),
      NO_PREDECESSOR,
      EMPTY_SALT,
      MIN_DELAY
    );
  }

  function test_RevertWhen_ScheduleIfOperationScheduled() public {
    changePrank(PROPOSER_ONE);
    s_timelock.scheduleBatch(
      _singletonCalls(
        Timelock.Call({
          target: address(s_counter),
          value: 0,
          data: abi.encodeWithSelector(Counter.increment.selector)
        })
      ),
      NO_PREDECESSOR,
      EMPTY_SALT,
      MIN_DELAY
    );
    vm.expectRevert('Timelock: operation already scheduled');
    changePrank(PROPOSER_ONE);
    s_timelock.scheduleBatch(
      _singletonCalls(
        Timelock.Call({
          target: address(s_counter),
          value: 0,
          data: abi.encodeWithSelector(Counter.increment.selector)
        })
      ),
      NO_PREDECESSOR,
      EMPTY_SALT,
      MIN_DELAY
    );
  }

  function test_RevertWhen_ScheduleIfDelayLessThanMinDelay() public {
    vm.expectRevert('Timelock: insufficient delay');
    changePrank(PROPOSER_ONE);
    s_timelock.scheduleBatch(
      _singletonCalls(
        Timelock.Call({
          target: address(s_counter),
          value: 0,
          data: abi.encodeWithSelector(Counter.increment.selector)
        })
      ),
      NO_PREDECESSOR,
      EMPTY_SALT,
      2 days - 1
    );
  }

  function test_ProposerCanScheduleOperation() public {
    _scheduleOperation(PROPOSER_ONE);
  }

  function test_AdminCanScheduleOperation() public {
    _scheduleOperation(ADMIN);
  }

  function _scheduleOperation(address proposer) internal {
    changePrank(proposer);
    s_timelock.scheduleBatch(
      _singletonCalls(
        Timelock.Call({
          target: address(s_counter),
          value: 0,
          data: abi.encodeWithSelector(Counter.increment.selector)
        })
      ),
      NO_PREDECESSOR,
      EMPTY_SALT,
      MIN_DELAY
    );
    bytes32 operationID = s_timelock.hashOperationBatch(
      _singletonCalls(
        Timelock.Call({
          target: address(s_counter),
          value: 0,
          data: abi.encodeWithSelector(Counter.increment.selector)
        })
      ),
      NO_PREDECESSOR,
      EMPTY_SALT
    );
    assertTrue(s_timelock.isOperation(operationID));
  }
}

contract Timelock_ScheduleBatch_Multiple_CustomDelays is BaseTestTimelocked {
  Counter internal s_counterTwo;
  Timelock.Call[] internal s_calls;
  uint256 internal constant CUSTOM_DELAY = 31 days;

  function setUp() public override {
    BaseTestTimelocked.setUp();

    s_calls.push(
      Timelock.Call({
        target: address(s_counter),
        value: 0,
        data: abi.encodeWithSelector(Counter.increment.selector)
      })
    );
    s_calls.push(
      Timelock.Call({
        target: address(s_counterTwo),
        value: 0,
        data: abi.encodeWithSelector(Counter.setNumber.selector, 10)
      })
    );

    // Set a custom delay for an operation in the batch of calls
    // The highest delay in a batch should be used when scheduling.
    Timelock.UpdateDelayParams[] memory params = new Timelock.UpdateDelayParams[](1);
    params[0] = Timelock.UpdateDelayParams({
      target: address(s_counter),
      selector: Counter.increment.selector,
      newDelay: CUSTOM_DELAY
    });
    changePrank(ADMIN);
    s_timelock.updateDelay(params);
  }

  function test_Returns_MinDelayForCalls() public {
    uint256 minDelay = s_timelock.getMinDelay(s_calls);
    assertEq(minDelay, CUSTOM_DELAY);
  }

  function test_RevertWhen_DelayTooLow() public {
    vm.expectRevert('Timelock: insufficient delay');
    changePrank(ADMIN);
    s_timelock.scheduleBatch(s_calls, NO_PREDECESSOR, EMPTY_SALT, CUSTOM_DELAY - 1);
  }

  function test_AdminCanBatchSchedule_GreaterEqualToMinDelay() public {
    _scheduleBatchedOperation(ADMIN, CUSTOM_DELAY);
  }

  function test_UpdateDelay_DoesNotChangeExistingOperationTimestamps() public {
    bytes32 batchedOperationID = s_timelock.hashOperationBatch(s_calls, NO_PREDECESSOR, EMPTY_SALT);

    changePrank(PROPOSER_ONE);
    s_timelock.scheduleBatch(s_calls, NO_PREDECESSOR, EMPTY_SALT, CUSTOM_DELAY);

    uint256 operationTimestampBefore = s_timelock.getTimestamp(batchedOperationID);

    // Set a new delay value
    Timelock.UpdateDelayParams[] memory params = new Timelock.UpdateDelayParams[](1);
    params[0] = Timelock.UpdateDelayParams({
      target: address(s_counter),
      selector: Counter.increment.selector,
      newDelay: CUSTOM_DELAY + 1
    });
    changePrank(ADMIN);
    s_timelock.updateDelay(params);

    // New delay value should only apply on future operations, not existing ones
    uint256 operationTimestampAfter = s_timelock.getTimestamp(batchedOperationID);
    assertEq(operationTimestampAfter, operationTimestampBefore);
  }

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

  function _scheduleBatchedOperation(address proposer, uint256 delay) internal {
    bytes32 batchedOperationID = s_timelock.hashOperationBatch(s_calls, NO_PREDECESSOR, EMPTY_SALT);

    assertEq(s_timelock.isOperation(batchedOperationID), false);

    for (uint256 i = 0; i < s_calls.length; ++i) {
      vm.expectEmit(true, true, true, true, address(s_timelock));

      emit CallScheduled(
        batchedOperationID,
        i,
        s_calls[i].target,
        s_calls[i].value,
        s_calls[i].data,
        NO_PREDECESSOR,
        EMPTY_SALT,
        delay
      );
    }

    changePrank(proposer);
    s_timelock.scheduleBatch(s_calls, NO_PREDECESSOR, EMPTY_SALT, delay);

    assertEq(s_timelock.isOperation(batchedOperationID), true);

    uint256 operationTimestamp = s_timelock.getTimestamp(batchedOperationID);
    assertEq(operationTimestamp, block.timestamp + delay);
  }
}

contract Timelock_ExecuteBatch_Multiple is BaseTestTimelocked {
  Counter internal s_counterTwo;
  Timelock.Call[] internal s_calls;

  function setUp() public override {
    BaseTestTimelocked.setUp();
    s_counterTwo = new Counter(address(s_timelock));

    s_calls.push(
      Timelock.Call({
        target: address(s_counter),
        value: 0,
        data: abi.encodeWithSelector(Counter.increment.selector)
      })
    );
    s_calls.push(
      Timelock.Call({
        target: address(s_counterTwo),
        value: 0,
        data: abi.encodeWithSelector(Counter.setNumber.selector, 10)
      })
    );
  }

  function test_RevertWhen_NotExecutor() public {
    vm.expectRevert(_getExpectedMissingRoleErrorMessage(STRANGER, s_timelock.EXECUTOR_ROLE()));
    changePrank(STRANGER);
    s_timelock.executeBatch(s_calls, NO_PREDECESSOR, EMPTY_SALT);
  }

  function test_RevertWhen_OperationNotReady() public {
    changePrank(PROPOSER_ONE);
    s_timelock.scheduleBatch(s_calls, NO_PREDECESSOR, EMPTY_SALT, MIN_DELAY);
    vm.warp(block.timestamp + MIN_DELAY - 2 days);
    vm.expectRevert('Timelock: operation is not ready');
    changePrank(EXECUTOR_ONE);
    s_timelock.executeBatch(s_calls, NO_PREDECESSOR, EMPTY_SALT);
  }

  function test_RevertWhen_PredecessorOperationNotExecuted() public {
    changePrank(PROPOSER_ONE);

    // Schedule predecessor job
    s_timelock.scheduleBatch(
      _singletonCalls(
        Timelock.Call({
          target: address(s_counter),
          value: 0,
          data: abi.encodeWithSelector(Counter.increment.selector)
        })
      ),
      NO_PREDECESSOR,
      EMPTY_SALT,
      MIN_DELAY
    );
    bytes32 operationOneID = s_timelock.hashOperationBatch(
      _singletonCalls(
        Timelock.Call({
          target: address(s_counter),
          value: 0,
          data: abi.encodeWithSelector(Counter.increment.selector)
        })
      ),
      NO_PREDECESSOR,
      EMPTY_SALT
    );

    // Schedule dependent job
    changePrank(PROPOSER_ONE);
    s_timelock.scheduleBatch(s_calls, operationOneID, EMPTY_SALT, MIN_DELAY);

    // Check that executing the dependent job reverts
    vm.warp(block.timestamp + MIN_DELAY + 2 days);
    vm.expectRevert('Timelock: missing dependency');
    changePrank(EXECUTOR_ONE);
    s_timelock.executeBatch(s_calls, operationOneID, EMPTY_SALT);
  }

  function test_RevertWhen_PredecessorOperationNotScheduled() public {
    changePrank(PROPOSER_ONE);

    // Prepare predecessor job
    bytes32 operationOneID = s_timelock.hashOperationBatch(
      _singletonCalls(
        Timelock.Call({
          target: address(s_counter),
          value: 0,
          data: abi.encodeWithSelector(Counter.increment.selector)
        })
      ),
      NO_PREDECESSOR,
      EMPTY_SALT
    );

    // Schedule dependent job
    changePrank(PROPOSER_ONE);
    s_timelock.scheduleBatch(s_calls, operationOneID, EMPTY_SALT, MIN_DELAY);

    // Check that executing the dependent job reverts
    vm.warp(block.timestamp + MIN_DELAY + 2 days);
    vm.expectRevert('Timelock: missing dependency');
    changePrank(EXECUTOR_ONE);
    s_timelock.executeBatch(s_calls, operationOneID, EMPTY_SALT);
  }

  function test_RevertWhen_PredecessorOperationInvalid() public {
    // Prepare invalid predecessor
    bytes32 invalidPredecessor = 0xe685571b7e25a4a0391fb8daa09dc8d3fbb3382504525f89a2334fbbf8f8e92c;

    // Schedule dependent job
    changePrank(PROPOSER_ONE);
    s_timelock.scheduleBatch(s_calls, invalidPredecessor, EMPTY_SALT, MIN_DELAY);

    // Check that executing the dependent job reverts
    vm.warp(block.timestamp + MIN_DELAY + 2 days);
    vm.expectRevert('Timelock: missing dependency');
    changePrank(EXECUTOR_ONE);
    s_timelock.executeBatch(s_calls, invalidPredecessor, EMPTY_SALT);
  }

  function test_RevertWhen_OneTargetReverts() public {
    changePrank(PROPOSER_ONE);

    // Schedule a job where one target will revert
    s_calls[1].data = abi.encodeWithSelector(Counter.mockRevert.selector);
    s_timelock.scheduleBatch(s_calls, NO_PREDECESSOR, EMPTY_SALT, MIN_DELAY);

    vm.warp(block.timestamp + MIN_DELAY + 2 days);
    changePrank(EXECUTOR_ONE);
    vm.expectRevert('Timelock: underlying transaction reverted');
    s_timelock.executeBatch(s_calls, NO_PREDECESSOR, EMPTY_SALT);
  }

  function test_ExecutorCanBatchExecuteOperation() public {
    _executeBatchedOperation(EXECUTOR_ONE);
  }

  function test_AdminCanBatchExecuteOperation() public {
    _executeBatchedOperation(ADMIN);
  }

  function _executeBatchedOperation(address executor) internal {
    changePrank(PROPOSER_ONE);

    // Schedule batch executon
    s_timelock.scheduleBatch(s_calls, NO_PREDECESSOR, EMPTY_SALT, MIN_DELAY);

    vm.warp(block.timestamp + MIN_DELAY);

    changePrank(executor);
    s_timelock.executeBatch(s_calls, NO_PREDECESSOR, EMPTY_SALT);

    bytes32 operationID = s_timelock.hashOperationBatch(s_calls, NO_PREDECESSOR, EMPTY_SALT);
    uint256 operationTimestamp = s_timelock.getTimestamp(operationID);
    assertEq(operationTimestamp, DONE_TIMESTAMP);
  }
}

contract Timelock_ExecuteBatch_Single is BaseTestTimelocked {
  // CallExecuted as defined in Timelock.sol. Redefine it here for testing.
  event CallExecuted(
    bytes32 indexed id, uint256 indexed index, address target, uint256 value, bytes data
  );

  function test_RevertWhen_ExecutedByNonExecutor() public {
    vm.expectRevert(_getExpectedMissingRoleErrorMessage(STRANGER, s_timelock.EXECUTOR_ROLE()));
    changePrank(STRANGER);
    s_timelock.executeBatch(
      _singletonCalls(
        Timelock.Call({
          target: address(s_counter),
          value: 0,
          data: abi.encodeWithSelector(Counter.increment.selector)
        })
      ),
      NO_PREDECESSOR,
      EMPTY_SALT
    );
  }

  function test_RevertWhen_OperationNotReady() public {
    changePrank(PROPOSER_ONE);
    s_timelock.scheduleBatch(
      _singletonCalls(
        Timelock.Call({
          target: address(s_counter),
          value: 0,
          data: abi.encodeWithSelector(Counter.increment.selector)
        })
      ),
      NO_PREDECESSOR,
      EMPTY_SALT,
      MIN_DELAY
    );
    vm.warp(block.timestamp + MIN_DELAY - 2 days);
    vm.expectRevert('Timelock: operation is not ready');
    changePrank(EXECUTOR_ONE);
    s_timelock.executeBatch(
      _singletonCalls(
        Timelock.Call({
          target: address(s_counter),
          value: 0,
          data: abi.encodeWithSelector(Counter.increment.selector)
        })
      ),
      NO_PREDECESSOR,
      EMPTY_SALT
    );
  }

  function test_RevertWhen_PredecessorOperationNotExecuted() public {
    changePrank(PROPOSER_ONE);

    // Schedule predecessor job
    s_timelock.scheduleBatch(
      _singletonCalls(
        Timelock.Call({
          target: address(s_counter),
          value: 0,
          data: abi.encodeWithSelector(Counter.increment.selector)
        })
      ),
      NO_PREDECESSOR,
      EMPTY_SALT,
      MIN_DELAY
    );
    bytes32 operationOneID = s_timelock.hashOperationBatch(
      _singletonCalls(
        Timelock.Call({
          target: address(s_counter),
          value: 0,
          data: abi.encodeWithSelector(Counter.increment.selector)
        })
      ),
      NO_PREDECESSOR,
      EMPTY_SALT
    );

    // Schedule dependent job
    changePrank(PROPOSER_ONE);
    s_timelock.scheduleBatch(
      _singletonCalls(
        Timelock.Call({
          target: address(s_counter),
          value: 0,
          data: abi.encodeWithSelector(Counter.setNumber.selector, 1)
        })
      ),
      operationOneID,
      EMPTY_SALT,
      MIN_DELAY
    );

    // Check that executing the dependent job reverts
    vm.warp(block.timestamp + MIN_DELAY + 2 days);
    vm.expectRevert('Timelock: missing dependency');
    changePrank(EXECUTOR_ONE);
    s_timelock.executeBatch(
      _singletonCalls(
        Timelock.Call({
          target: address(s_counter),
          value: 0,
          data: abi.encodeWithSelector(Counter.setNumber.selector, 1)
        })
      ),
      operationOneID,
      EMPTY_SALT
    );
  }

  function test_RevertWhen_TargetReverts() public {
    changePrank(PROPOSER_ONE);

    // Schedule predecessor job
    s_timelock.scheduleBatch(
      _singletonCalls(
        Timelock.Call({
          target: address(s_counter),
          value: 0,
          data: abi.encodeWithSelector(Counter.mockRevert.selector)
        })
      ),
      NO_PREDECESSOR,
      EMPTY_SALT,
      MIN_DELAY
    );

    vm.warp(block.timestamp + MIN_DELAY + 2 days);
    vm.expectRevert('Timelock: underlying transaction reverted');
    changePrank(EXECUTOR_ONE);
    s_timelock.executeBatch(
      _singletonCalls(
        Timelock.Call({
          target: address(s_counter),
          value: 0,
          data: abi.encodeWithSelector(Counter.mockRevert.selector)
        })
      ),
      NO_PREDECESSOR,
      EMPTY_SALT
    );
  }

  function test_ExecutorCanExecuteOperation() public {
    _executeOperation(EXECUTOR_ONE);
  }

  function test_AdminCanExecuteOperation() public {
    _executeOperation(ADMIN);
  }

  function _executeOperation(address executor) internal {
    changePrank(PROPOSER_ONE);
    uint256 num = 10;
    s_timelock.scheduleBatch(
      _singletonCalls(
        Timelock.Call({
          target: address(s_counter),
          value: 0,
          data: abi.encodeWithSelector(Counter.setNumber.selector, num)
        })
      ),
      NO_PREDECESSOR,
      EMPTY_SALT,
      MIN_DELAY
    );

    vm.warp(block.timestamp + MIN_DELAY + 2 days);
    changePrank(executor);
    s_timelock.executeBatch(
      _singletonCalls(
        Timelock.Call({
          target: address(s_counter),
          value: 0,
          data: abi.encodeWithSelector(Counter.setNumber.selector, num)
        })
      ),
      NO_PREDECESSOR,
      EMPTY_SALT
    );

    bytes32 operationID = s_timelock.hashOperationBatch(
      _singletonCalls(
        Timelock.Call({
          target: address(s_counter),
          value: 0,
          data: abi.encodeWithSelector(Counter.setNumber.selector, num)
        })
      ),
      NO_PREDECESSOR,
      EMPTY_SALT
    );
    uint256 operationTimestamp = s_timelock.getTimestamp(operationID);
    assertEq(operationTimestamp, DONE_TIMESTAMP);
    uint256 counterNumber = s_counter.number();
    assertEq(counterNumber, num);
  }

  function test_EmitsEvent() public {
    changePrank(PROPOSER_ONE);
    s_timelock.scheduleBatch(
      _singletonCalls(
        Timelock.Call({
          target: address(s_counter),
          value: 0,
          data: abi.encodeWithSelector(Counter.increment.selector)
        })
      ),
      NO_PREDECESSOR,
      EMPTY_SALT,
      MIN_DELAY
    );
    vm.warp(block.timestamp + MIN_DELAY + 2 days);
    Timelock.Call[] memory calls = _singletonCalls(
      Timelock.Call({
        target: address(s_counter),
        value: 0,
        data: abi.encodeCall(Counter.increment, ())
      })
    );
    bytes32 predecessor = NO_PREDECESSOR;
    bytes32 salt = EMPTY_SALT;
    bytes32 id = s_timelock.hashOperationBatch(calls, predecessor, salt);

    changePrank(EXECUTOR_ONE);
    vm.expectEmit(true, true, true, true);
    emit CallExecuted(id, 0, calls[0].target, calls[0].value, calls[0].data);
    s_timelock.executeBatch(
      _singletonCalls(
        Timelock.Call({
          target: address(s_counter),
          value: 0,
          data: abi.encodeCall(Counter.increment, ())
        })
      ),
      NO_PREDECESSOR,
      EMPTY_SALT
    );
  }
}

contract Timelock_ExecuteBatch_Reentrancy is BaseTestTimelocked {
  event CallExecuted(
    bytes32 indexed id, uint256 indexed index, address target, uint256 value, bytes data
  );

  Counter internal s_counterTwo;
  TimelockReentrant internal s_reentrant;

  function setUp() public override {
    BaseTestTimelocked.setUp();

    s_reentrant = new TimelockReentrant();
  }

  function test_RevertWhen_Reentrancy() public {
    Timelock.Call[] memory calls = _singletonCalls(
      Timelock.Call({
        target: address(s_reentrant),
        value: 0,
        data: abi.encodeWithSelector(TimelockReentrant.reenter.selector)
      })
    );

    // Schedule so it can be executed
    changePrank(PROPOSER_ONE);
    s_timelock.scheduleBatch(calls, NO_PREDECESSOR, EMPTY_SALT, MIN_DELAY);

    vm.warp(block.timestamp + MIN_DELAY + 2 days);

    // Grant executor role to the reentrant contract
    bool hasAdminRole = s_timelock.hasRole(s_timelock.ADMIN_ROLE(), ADMIN);
    assertEq(hasAdminRole, true);
    changePrank(ADMIN);
    s_timelock.grantRole(s_timelock.EXECUTOR_ROLE(), address(s_reentrant));

    // Prepare reenter
    bytes memory data =
      abi.encodeWithSelector(s_timelock.executeBatch.selector, calls, NO_PREDECESSOR, EMPTY_SALT);
    s_reentrant.enableRentrancy(address(s_timelock), data);

    // Expect to fail
    vm.expectRevert('Timelock: operation is not ready');
    changePrank(EXECUTOR_ONE);
    s_timelock.executeBatch(calls, NO_PREDECESSOR, EMPTY_SALT);

    // Disable reentrancy
    s_reentrant.disableReentrancy();

    // Try again successfully
    changePrank(EXECUTOR_ONE);
    s_timelock.executeBatch(calls, NO_PREDECESSOR, EMPTY_SALT);
  }
}

contract Timelock_Cancel is BaseTestTimelocked {
  function test_RevertWhen_NonCanceller() public {
    vm.expectRevert(_getExpectedMissingRoleErrorMessage(EXECUTOR_ONE, s_timelock.CANCELLER_ROLE()));
    changePrank(EXECUTOR_ONE);
    s_timelock.cancel(EMPTY_SALT);
  }

  function test_RevertWhen_FinishedOperation() public {
    changePrank(PROPOSER_ONE);
    s_timelock.scheduleBatch(
      _singletonCalls(
        Timelock.Call({
          target: address(s_counter),
          value: 0,
          data: abi.encodeWithSelector(Counter.increment.selector)
        })
      ),
      NO_PREDECESSOR,
      EMPTY_SALT,
      MIN_DELAY
    );

    vm.warp(block.timestamp + MIN_DELAY + 1);
    changePrank(EXECUTOR_ONE);
    s_timelock.executeBatch(
      _singletonCalls(
        Timelock.Call({
          target: address(s_counter),
          value: 0,
          data: abi.encodeWithSelector(Counter.increment.selector)
        })
      ),
      NO_PREDECESSOR,
      EMPTY_SALT
    );
    bytes32 operationID = s_timelock.hashOperationBatch(
      _singletonCalls(
        Timelock.Call({
          target: address(s_counter),
          value: 0,
          data: abi.encodeWithSelector(Counter.increment.selector)
        })
      ),
      NO_PREDECESSOR,
      EMPTY_SALT
    );
    changePrank(CANCELLER_ONE);
    vm.expectRevert('Timelock: operation cannot be cancelled');
    s_timelock.cancel(operationID);
  }

  function test_CancellerCanCancelOperation() public {
    _cancelOperation(CANCELLER_ONE);
  }

  function test_AdminCanCancelOperation() public {
    _cancelOperation(ADMIN);
  }

  function _cancelOperation(address canceller) internal {
    changePrank(PROPOSER_ONE);
    s_timelock.scheduleBatch(
      _singletonCalls(
        Timelock.Call({
          target: address(s_counter),
          value: 0,
          data: abi.encodeWithSelector(Counter.increment.selector)
        })
      ),
      NO_PREDECESSOR,
      EMPTY_SALT,
      MIN_DELAY
    );
    bytes32 operationID = s_timelock.hashOperationBatch(
      _singletonCalls(
        Timelock.Call({
          target: address(s_counter),
          value: 0,
          data: abi.encodeWithSelector(Counter.increment.selector)
        })
      ),
      NO_PREDECESSOR,
      EMPTY_SALT
    );
    changePrank(canceller);
    s_timelock.cancel(operationID);
    assertFalse(s_timelock.isOperation(operationID));
  }
}

contract Timelock_Receivable is BaseTestTimelocked {
  function test_canReceiveETH() public {
    changePrank(ADMIN);
    payable(address(s_timelock)).transfer(0.5 ether);
    assertEq(address(s_timelock).balance, 0.5 ether);
  }
}

contract Timelock_IsOperation is BaseTestTimelocked {
  function test_FalseIfNotAnOperation() public {
    bool isOperation = s_timelock.isOperation(bytes32('non-op'));
    assertEq(isOperation, false);
  }

  function test_TrueIfAnOperation() public {
    changePrank(PROPOSER_ONE);
    s_timelock.scheduleBatch(
      _singletonCalls(
        Timelock.Call({
          target: address(0),
          value: 0,
          data: abi.encodeWithSelector(Counter.increment.selector)
        })
      ),
      NO_PREDECESSOR,
      EMPTY_SALT,
      MIN_DELAY
    );

    bytes32 operationID = s_timelock.hashOperationBatch(
      _singletonCalls(
        Timelock.Call({
          target: address(0),
          value: 0,
          data: abi.encodeWithSelector(Counter.increment.selector)
        })
      ),
      NO_PREDECESSOR,
      EMPTY_SALT
    );

    bool isOperation = s_timelock.isOperation(operationID);
    assertEq(isOperation, true);
  }
}

contract Timelock_IsOperationPending is BaseTestTimelocked {
  function test_FalseIfNotAnOperation() public {
    bool isOperationPending = s_timelock.isOperationPending(bytes32('non-op'));
    assertEq(isOperationPending, false);
  }

  function test_TrueIfScheduledOperatonNotYetExecuted() public {
    changePrank(PROPOSER_ONE);
    s_timelock.scheduleBatch(
      _singletonCalls(
        Timelock.Call({
          target: address(s_counter),
          value: 0,
          data: abi.encodeWithSelector(Counter.increment.selector)
        })
      ),
      NO_PREDECESSOR,
      EMPTY_SALT,
      MIN_DELAY
    );

    bytes32 operationID = s_timelock.hashOperationBatch(
      _singletonCalls(
        Timelock.Call({
          target: address(s_counter),
          value: 0,
          data: abi.encodeWithSelector(Counter.increment.selector)
        })
      ),
      NO_PREDECESSOR,
      EMPTY_SALT
    );

    bool isOperationPending = s_timelock.isOperationPending(operationID);
    assertEq(isOperationPending, true);
  }

  function test_FalseIfOperationHasBeenExecuted() public {
    changePrank(PROPOSER_ONE);
    s_timelock.scheduleBatch(
      _singletonCalls(
        Timelock.Call({
          target: address(s_counter),
          value: 0,
          data: abi.encodeWithSelector(Counter.increment.selector)
        })
      ),
      NO_PREDECESSOR,
      EMPTY_SALT,
      MIN_DELAY
    );

    vm.warp(block.timestamp + MIN_DELAY);
    changePrank(EXECUTOR_ONE);
    s_timelock.executeBatch(
      _singletonCalls(
        Timelock.Call({
          target: address(s_counter),
          value: 0,
          data: abi.encodeWithSelector(Counter.increment.selector)
        })
      ),
      NO_PREDECESSOR,
      EMPTY_SALT
    );

    bytes32 operationID = s_timelock.hashOperationBatch(
      _singletonCalls(
        Timelock.Call({
          target: address(s_counter),
          value: 0,
          data: abi.encodeWithSelector(Counter.increment.selector)
        })
      ),
      NO_PREDECESSOR,
      EMPTY_SALT
    );

    bool isOperationPending = s_timelock.isOperationPending(operationID);
    assertEq(isOperationPending, false);
  }
}

contract Timelock_IsOperationReady is BaseTestTimelocked {
  function test_FalseIfNotAnOperation() public {
    bool isOperationReady = s_timelock.isOperationReady(bytes32('non-op'));
    assertEq(isOperationReady, false);
  }

  function test_TrueIfOnTheDelayedExecutionTime() public {
    changePrank(PROPOSER_ONE);
    s_timelock.scheduleBatch(
      _singletonCalls(
        Timelock.Call({
          target: address(s_counter),
          value: 0,
          data: abi.encodeWithSelector(Counter.increment.selector)
        })
      ),
      NO_PREDECESSOR,
      EMPTY_SALT,
      MIN_DELAY
    );

    vm.warp(block.timestamp + MIN_DELAY);

    bytes32 operationID = s_timelock.hashOperationBatch(
      _singletonCalls(
        Timelock.Call({
          target: address(s_counter),
          value: 0,
          data: abi.encodeWithSelector(Counter.increment.selector)
        })
      ),
      NO_PREDECESSOR,
      EMPTY_SALT
    );

    bool isOperationReady = s_timelock.isOperationReady(operationID);
    assertEq(isOperationReady, true);
  }

  function test_TrueIfAfterTheDelayedExecutionTime() public {
    changePrank(PROPOSER_ONE);
    s_timelock.scheduleBatch(
      _singletonCalls(
        Timelock.Call({
          target: address(s_counter),
          value: 0,
          data: abi.encodeWithSelector(Counter.increment.selector)
        })
      ),
      NO_PREDECESSOR,
      EMPTY_SALT,
      MIN_DELAY
    );

    vm.warp(block.timestamp + MIN_DELAY + 1 days);

    bytes32 operationID = s_timelock.hashOperationBatch(
      _singletonCalls(
        Timelock.Call({
          target: address(s_counter),
          value: 0,
          data: abi.encodeWithSelector(Counter.increment.selector)
        })
      ),
      NO_PREDECESSOR,
      EMPTY_SALT
    );

    bool isOperationReady = s_timelock.isOperationReady(operationID);
    assertEq(isOperationReady, true);
  }

  function test_FalseIfBeforeTheDelayedExecutionTime() public {
    changePrank(PROPOSER_ONE);
    s_timelock.scheduleBatch(
      _singletonCalls(
        Timelock.Call({
          target: address(s_counter),
          value: 0,
          data: abi.encodeWithSelector(Counter.increment.selector)
        })
      ),
      NO_PREDECESSOR,
      EMPTY_SALT,
      MIN_DELAY
    );

    vm.warp(block.timestamp + MIN_DELAY - 1 days);

    bytes32 operationID = s_timelock.hashOperationBatch(
      _singletonCalls(
        Timelock.Call({
          target: address(s_counter),
          value: 0,
          data: abi.encodeWithSelector(Counter.increment.selector)
        })
      ),
      NO_PREDECESSOR,
      EMPTY_SALT
    );

    bool isOperationReady = s_timelock.isOperationReady(operationID);
    assertEq(isOperationReady, false);
  }

  function test_falseIfOperationHasBeenExecuted() public {
    changePrank(PROPOSER_ONE);
    s_timelock.scheduleBatch(
      _singletonCalls(
        Timelock.Call({
          target: address(s_counter),
          value: 0,
          data: abi.encodeWithSelector(Counter.increment.selector)
        })
      ),
      NO_PREDECESSOR,
      EMPTY_SALT,
      MIN_DELAY
    );

    vm.warp(block.timestamp + MIN_DELAY);
    changePrank(EXECUTOR_ONE);
    s_timelock.executeBatch(
      _singletonCalls(
        Timelock.Call({
          target: address(s_counter),
          value: 0,
          data: abi.encodeWithSelector(Counter.increment.selector)
        })
      ),
      NO_PREDECESSOR,
      EMPTY_SALT
    );

    bytes32 operationID = s_timelock.hashOperationBatch(
      _singletonCalls(
        Timelock.Call({
          target: address(s_counter),
          value: 0,
          data: abi.encodeWithSelector(Counter.increment.selector)
        })
      ),
      NO_PREDECESSOR,
      EMPTY_SALT
    );

    bool isOperationReady = s_timelock.isOperationReady(operationID);
    assertEq(isOperationReady, false);
  }
}

contract Timelock_IsOperationDone is BaseTestTimelocked {
  function test_FalseIfNotAnOperation() public {
    bool isOperationDone = s_timelock.isOperationDone(bytes32('non-op'));
    assertEq(isOperationDone, false);
  }

  function test_FalseItTheOperationHasNotBeenExecuted() public {
    changePrank(PROPOSER_ONE);
    s_timelock.scheduleBatch(
      _singletonCalls(
        Timelock.Call({
          target: address(s_counter),
          value: 0,
          data: abi.encodeWithSelector(Counter.increment.selector)
        })
      ),
      NO_PREDECESSOR,
      EMPTY_SALT,
      MIN_DELAY
    );

    bytes32 operationID = s_timelock.hashOperationBatch(
      _singletonCalls(
        Timelock.Call({
          target: address(s_counter),
          value: 0,
          data: abi.encodeWithSelector(Counter.increment.selector)
        })
      ),
      NO_PREDECESSOR,
      EMPTY_SALT
    );

    bool isOperationDone = s_timelock.isOperationDone(operationID);
    assertEq(isOperationDone, false);
  }

  function test_TrueIfOperationHasBeenExecuted() public {
    changePrank(PROPOSER_ONE);
    s_timelock.scheduleBatch(
      _singletonCalls(
        Timelock.Call({
          target: address(s_counter),
          value: 0,
          data: abi.encodeWithSelector(Counter.increment.selector)
        })
      ),
      NO_PREDECESSOR,
      EMPTY_SALT,
      MIN_DELAY
    );

    vm.warp(block.timestamp + MIN_DELAY);
    changePrank(EXECUTOR_ONE);
    s_timelock.executeBatch(
      _singletonCalls(
        Timelock.Call({
          target: address(s_counter),
          value: 0,
          data: abi.encodeWithSelector(Counter.increment.selector)
        })
      ),
      NO_PREDECESSOR,
      EMPTY_SALT
    );

    bytes32 operationID = s_timelock.hashOperationBatch(
      _singletonCalls(
        Timelock.Call({
          target: address(s_counter),
          value: 0,
          data: abi.encodeWithSelector(Counter.increment.selector)
        })
      ),
      NO_PREDECESSOR,
      EMPTY_SALT
    );

    bool isOperationDone = s_timelock.isOperationDone(operationID);
    assertEq(isOperationDone, true);
  }
}

contract Timelock_GetTimestamp is BaseTestTimelocked {
  function test_returnsZeroIfNotAnOperation() public {
    uint256 operationTimestamp = s_timelock.getTimestamp(bytes32('non-op'));
    assertEq(operationTimestamp, 0);
  }

  function test_ReturnsTheCorrectTimestampIfTheOperationHasNotBeenExecuted() public {
    changePrank(PROPOSER_ONE);
    s_timelock.scheduleBatch(
      _singletonCalls(
        Timelock.Call({
          target: address(s_counter),
          value: 0,
          data: abi.encodeWithSelector(Counter.increment.selector)
        })
      ),
      NO_PREDECESSOR,
      EMPTY_SALT,
      MIN_DELAY
    );

    bytes32 operationID = s_timelock.hashOperationBatch(
      _singletonCalls(
        Timelock.Call({
          target: address(s_counter),
          value: 0,
          data: abi.encodeWithSelector(Counter.increment.selector)
        })
      ),
      NO_PREDECESSOR,
      EMPTY_SALT
    );

    uint256 operationTimestamp = s_timelock.getTimestamp(operationID);
    assertEq(operationTimestamp, block.timestamp + MIN_DELAY);
  }

  function test_ReturnsOneIfOperationHasBeenExecuted() public {
    changePrank(PROPOSER_ONE);
    s_timelock.scheduleBatch(
      _singletonCalls(
        Timelock.Call({
          target: address(s_counter),
          value: 0,
          data: abi.encodeWithSelector(Counter.increment.selector)
        })
      ),
      NO_PREDECESSOR,
      EMPTY_SALT,
      MIN_DELAY
    );

    vm.warp(block.timestamp + MIN_DELAY);
    changePrank(EXECUTOR_ONE);
    s_timelock.executeBatch(
      _singletonCalls(
        Timelock.Call({
          target: address(s_counter),
          value: 0,
          data: abi.encodeWithSelector(Counter.increment.selector)
        })
      ),
      NO_PREDECESSOR,
      EMPTY_SALT
    );

    bytes32 operationID = s_timelock.hashOperationBatch(
      _singletonCalls(
        Timelock.Call({
          target: address(s_counter),
          value: 0,
          data: abi.encodeWithSelector(Counter.increment.selector)
        })
      ),
      NO_PREDECESSOR,
      EMPTY_SALT
    );

    uint256 operationTimestamp = s_timelock.getTimestamp(operationID);
    assertEq(operationTimestamp, DONE_TIMESTAMP);
  }
}
