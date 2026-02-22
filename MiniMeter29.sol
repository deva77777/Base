// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract MiniMeter29 {
    uint256 public reading;

    function record(uint256 value) external {
        reading = value;
    }

    function reset() external {
        reading = 0;
    }
}
