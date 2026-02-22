// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract MiniLedger35 {
    mapping(address => int256) public balances;

    function credit(address account, int256 amount) external {
        balances[account] += amount;
    }

    function debit(address account, int256 amount) external {
        balances[account] -= amount;
    }
}
