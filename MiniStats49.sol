// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract MiniStats49 {
    uint256 public min;
    uint256 public max;
    bool private initialized;

    function update(uint256 value) external {
        if (!initialized) {
            min = value;
            max = value;
            initialized = true;
        } else {
            if (value < min) {
                min = value;
            }
            if (value > max) {
                max = value;
            }
        }
    }
}
