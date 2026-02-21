// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract EventLogger {
    event ValueChanged(address indexed changer, uint256 newValue);

    uint256 public value;

    function setValue(uint256 newValue) external {
        value = newValue;
        emit ValueChanged(msg.sender, newValue);
    }
}
