// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract MiniCapsule15 {
    uint256 public cap;

    function setCap(uint256 newCap) external {
        cap = newCap;
    }

    function isAbove(uint256 value) external view returns (bool) {
        return value > cap;
    }
}
