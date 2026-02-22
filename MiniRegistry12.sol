// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract MiniRegistry12 {
    mapping(address => string) private names;

    function register(string calldata name) external {
        names[msg.sender] = name;
    }

    function getName(address account) external view returns (string memory) {
        return names[account];
    }
}
