// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract MiniCounter46 {
    uint256 public count;

    function add(uint256 amount) external {
        count += amount;
    }

    function reset() external {
        count = 0;
    }
}
