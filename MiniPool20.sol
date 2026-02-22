// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract MiniPool20 {
    address public owner;
    uint256 public total;

    constructor() {
        owner = msg.sender;
    }

    function contribute() external payable {
        total += msg.value;
    }

    function withdrawAll() external {
        require(msg.sender == owner, "Only owner");
        uint256 amount = total;
        total = 0;
        payable(owner).transfer(amount);
    }
}
