// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract MiniTracker41 {
    mapping(address => uint256) private updates;

    function track() external {
        updates[msg.sender] += 1;
    }

    function get(address account) external view returns (uint256) {
        return updates[account];
    }
}
