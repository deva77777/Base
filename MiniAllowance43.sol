// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract MiniAllowance43 {
    mapping(address => mapping(address => uint256)) private allowances;

    function approve(address spender, uint256 amount) external {
        allowances[msg.sender][spender] = amount;
    }

    function allowance(address owner, address spender) external view returns (uint256) {
        return allowances[owner][spender];
    }
}
