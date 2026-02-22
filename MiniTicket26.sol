// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract MiniTicket26 {
    uint256 public nextId = 1;

    function mint() external returns (uint256) {
        uint256 id = nextId;
        nextId += 1;
        return id;
    }
}
