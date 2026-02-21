// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract MiniGate42 {
    address public gatekeeper;
    bool public opened;

    constructor() {
        gatekeeper = msg.sender;
    }

    function open() external {
        require(msg.sender == gatekeeper, "Only gatekeeper");
        opened = true;
    }
}
