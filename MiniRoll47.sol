// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract MiniRoll47 {
    uint256 public last;

    function roll() external {
        last = uint256(keccak256(abi.encode(block.timestamp, msg.sender, last)));
    }
}
