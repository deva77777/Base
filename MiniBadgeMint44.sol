// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract MiniBadgeMint44 {
    mapping(address => uint256) public balance;
    uint256 public total;

    function mint(address account) external {
        balance[account] += 1;
        total += 1;
    }
}
