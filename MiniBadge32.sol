// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract MiniBadge32 {
    mapping(address => bool) private badges;

    function grant(address account) external {
        badges[account] = true;
    }

    function revoke(address account) external {
        badges[account] = false;
    }

    function hasBadge(address account) external view returns (bool) {
        return badges[account];
    }
}
