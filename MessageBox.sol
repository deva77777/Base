// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract MessageBox {
    string public message = "Hello";

    function updateMessage(string calldata nextMessage) external {
        message = nextMessage;
    }
}
