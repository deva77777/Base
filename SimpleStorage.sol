// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract SimpleStorage {
    uint256 private storedValue;

    function set(uint256 value) external {
        storedValue = value;
    }

    function get() external view returns (uint256) {
        return storedValue;
    }
}
