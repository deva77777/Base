// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract MiniOwner04 {
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    function setOwner(address newOwner) external {
        require(msg.sender == owner, "Only owner");
        owner = newOwner;
    }
}
