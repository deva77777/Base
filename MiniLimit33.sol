// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract MiniLimit33 {
    uint256 public limit;

    function setLimit(uint256 newLimit) external {
        limit = newLimit;
    }

    function isWithin(uint256 value) external view returns (bool) {
        return value <= limit;
    }
}
