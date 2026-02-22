// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract MiniSavings17 {
    mapping(address => uint256) private savings;

    function deposit() external payable {
        savings[msg.sender] += msg.value;
    }

    function balanceOf(address account) external view returns (uint256) {
        return savings[account];
    }
}
