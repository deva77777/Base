// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract MiniWhitelist06 {
    mapping(address => bool) public whitelisted;

    function add(address account) external {
        whitelisted[account] = true;
    }

    function remove(address account) external {
        whitelisted[account] = false;
    }
}
