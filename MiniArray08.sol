// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract MiniArray08 {
    uint256[] public values;

    function pushValue(uint256 value) external {
        values.push(value);
    }

    function length() external view returns (uint256) {
        return values.length;
    }
}
