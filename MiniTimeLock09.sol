// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract MiniTimeLock09 {
    uint256 public unlockAt;

    function setUnlockAt(uint256 timestamp) external {
        unlockAt = timestamp;
    }

    function isUnlocked() external view returns (bool) {
        return block.timestamp >= unlockAt;
    }
}
