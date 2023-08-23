// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {IAccessControlDefaultAdminRules} from
  '@openzeppelin/contracts/access/IAccessControlDefaultAdminRules.sol';
import {BaseTest} from './BaseTest.t.sol';
import {ConstantsTimelocked} from './ConstantsTimelocked.t.sol';
import {Counter} from '../src/tests/Counter.sol';
import {RewardVault_WithStakersAndTimePassed} from './base-scenarios/RewardVaultScenarios.t.sol';
import {StakingTimelock} from '../src/timelock/StakingTimelock.sol';
import {Timelock} from '../src/timelock/Timelock.sol';
import {ISlashable} from '../src/interfaces/ISlashable.sol';

contract BaseTestTimelocked is ConstantsTimelocked, RewardVault_WithStakersAndTimePassed {
  address[] internal PROPOSERS = new address[](2);
  address[] internal EXECUTORS = new address[](2);
  address[] internal CANCELLERS = new address[](2);

  Counter internal s_counter;
  Timelock internal s_timelock;

  StakingTimelock internal s_stakingTimelock;

  function setUp() public virtual override {
    RewardVault_WithStakersAndTimePassed.setUp();
    changePrank(OWNER);

    // Correctly configure slash capacity to slash all 31 node operators
    s_operatorStakingPool.setSlasherConfig(
      address(s_pfAlertsController),
      ISlashable.SlasherConfig({
        refillRate: SLASH_REFILL_RATE,
        slashCapacity: FEED_SLASHABLE_AMOUNT * MIN_INITIAL_OPERATOR_COUNT
      })
    );

    PROPOSERS[0] = PROPOSER_ONE;
    PROPOSERS[1] = PROPOSER_TWO;

    EXECUTORS[0] = EXECUTOR_ONE;
    EXECUTORS[1] = EXECUTOR_TWO;

    CANCELLERS[0] = CANCELLER_ONE;
    CANCELLERS[1] = CANCELLER_TWO;

    s_timelock = new Timelock(
            MIN_DELAY,
            ADMIN,
            PROPOSERS,
            EXECUTORS,
            CANCELLERS
        );

    s_counter = new Counter(address(s_timelock));
    vm.deal(ADMIN, 1 ether);

    s_stakingTimelock = new StakingTimelock(
      StakingTimelock.ConstructorParams({
        rewardVault: address(s_rewardVault),
        communityStakingPool: address(s_communityStakingPool),
        operatorStakingPool: address(s_operatorStakingPool),
        alertsController: address(s_pfAlertsController),
        minDelay: MIN_DELAY,
        admin: ADMIN,
        proposers: PROPOSERS,
        executors: EXECUTORS,
        cancellers: CANCELLERS
      })
    );

    s_rewardVault.beginDefaultAdminTransfer(address(s_stakingTimelock));
    s_communityStakingPool.beginDefaultAdminTransfer(address(s_stakingTimelock));
    s_operatorStakingPool.beginDefaultAdminTransfer(address(s_stakingTimelock));
    s_pfAlertsController.beginDefaultAdminTransfer(address(s_stakingTimelock));

    changePrank(PROPOSER_ONE);
    Timelock.Call[] memory calls = new Timelock.Call[](4);
    calls[0] = _timelockCall(
      address(s_rewardVault),
      abi.encodeWithSelector(IAccessControlDefaultAdminRules.acceptDefaultAdminTransfer.selector)
    );
    calls[1] = _timelockCall(
      address(s_communityStakingPool),
      abi.encodeWithSelector(IAccessControlDefaultAdminRules.acceptDefaultAdminTransfer.selector)
    );
    calls[2] = _timelockCall(
      address(s_operatorStakingPool),
      abi.encodeWithSelector(IAccessControlDefaultAdminRules.acceptDefaultAdminTransfer.selector)
    );
    calls[3] = _timelockCall(
      address(s_pfAlertsController),
      abi.encodeWithSelector(IAccessControlDefaultAdminRules.acceptDefaultAdminTransfer.selector)
    );
    s_stakingTimelock.scheduleBatch(calls, NO_PREDECESSOR, EMPTY_SALT, MIN_DELAY);

    skip(MIN_DELAY);

    changePrank(EXECUTOR_ONE);
    s_stakingTimelock.executeBatch(calls, NO_PREDECESSOR, EMPTY_SALT);
  }

  function checkRoleNotSetForAddresses(
    Timelock timelock,
    bytes32 role,
    address[] memory addresses
  ) internal {
    for (uint256 i = 0; i < addresses.length; ++i) {
      assertFalse(timelock.hasRole(role, addresses[i]));
    }
  }

  // helper function that turns a single Timelock.Call into a singleton
  // slice Timelock.Call[]
  function _singletonCalls(Timelock.Call memory call)
    internal
    pure
    returns (Timelock.Call[] memory)
  {
    Timelock.Call[] memory calls = new Timelock.Call[](1);
    calls[0] = call;
    return calls;
  }

  // helper function that returns a Timelock.Call with the given target and data
  function _timelockCall(
    address target,
    bytes memory data
  ) internal pure returns (Timelock.Call memory) {
    return Timelock.Call({target: target, value: 0, data: data});
  }

  // This is needed so that "forge coverage" will ignore this contract
  function test() public virtual override {}
}
