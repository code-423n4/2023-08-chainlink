// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

contract ConstantsTimelocked {
  uint256 internal constant MIN_DELAY = 2 days;
  uint256 internal constant DONE_TIMESTAMP = 1;
  uint256 internal constant DELAY_ONE_MONTH = 31 days;
  uint256 internal constant DELAY_TWO_DAYS = 48 hours;

  address internal constant ADMIN = address(10001);
  address internal constant PROPOSER_ONE = address(10002);
  address internal constant PROPOSER_TWO = address(10003);

  address internal constant EXECUTOR_ONE = address(10004);
  address internal constant EXECUTOR_TWO = address(10005);

  address internal constant CANCELLER_ONE = address(10006);
  address internal constant CANCELLER_TWO = address(10007);

  address internal constant BYPASSER_ONE = address(10008);
  address internal constant BYPASSER_TWO = address(10009);

  bytes32 internal constant NO_PREDECESSOR = bytes32('');
  bytes32 internal constant EMPTY_SALT = bytes32('');
}
