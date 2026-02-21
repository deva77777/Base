// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract MiniStore37 {
    mapping(bytes32 => bytes32) private store;

    function set(bytes32 key, bytes32 value) external {
        store[key] = value;
    }

    function get(bytes32 key) external view returns (bytes32) {
        return store[key];
    }
}
