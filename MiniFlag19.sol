// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract MiniFlag19 {
    mapping(address => bool) private flags;

    function setFlag(address account, bool flag) external {
        flags[account] = flag;
    }

    function getFlag(address account) external view returns (bool) {
        return flags[account];
    }
}
