// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract MiniNonce21 {
    mapping(address => uint256) public nonces;

    function bump() external {
        nonces[msg.sender] += 1;
    }
}
