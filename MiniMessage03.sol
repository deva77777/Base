// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract MiniMessage03 {
    string public message;

    function setMessage(string calldata newMessage) external {
        message = newMessage;
    }
}
