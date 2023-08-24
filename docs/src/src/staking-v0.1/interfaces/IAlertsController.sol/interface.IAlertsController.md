# IAlertsController
[Git Source](https://github.com/code-423n4/2023-08-chainlink/blob/38d594fd52a417af576ce44eee67744196ba1094/src/staking-v0.1/interfaces/IAlertsController.sol)


## Functions
### raiseAlert

This function creates an alert for a stalled feed


```solidity
function raiseAlert() external;
```

### canAlert

This function checks to see whether the alerter may raise an alert
to claim rewards


```solidity
function canAlert(address alerter) external view returns (bool);
```

## Events
### AlertRaised
Emitted when a valid alert is raised for a feed round


```solidity
event AlertRaised(address alerter, uint256 roundId, uint256 rewardAmount);
```

## Errors
### AlertAlreadyExists
This error is thrown when an alerter tries to raise an


```solidity
error AlertAlreadyExists(uint256 roundId);
```

### AlertInvalid
This error is thrown when alerting conditions are not met and the
alert is invalid.


```solidity
error AlertInvalid();
```

