// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract MiniPing30 {
    event Ping(address indexed sender);

    function ping() external {
        emit Ping(msg.sender);
    }
}
