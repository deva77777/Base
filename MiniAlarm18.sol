// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract MiniAlarm18 {
    uint256 public alarmAt;

    function setAlarm(uint256 timestamp) external {
        alarmAt = timestamp;
    }

    function timeRemaining() external view returns (uint256) {
        if (block.timestamp >= alarmAt) {
            return 0;
        }
        return alarmAt - block.timestamp;
    }
}
