// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract MiniMap50 {
    mapping(uint256 => address) private map;

    function set(uint256 key, address value) external {
        map[key] = value;
    }

    function get(uint256 key) external view returns (address) {
        return map[key];
    }
}
