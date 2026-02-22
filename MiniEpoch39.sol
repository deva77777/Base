// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract MiniEpoch39 {
    uint256 public epoch;

    function advance() external {
        epoch += 1;
    }

    function setEpoch(uint256 newEpoch) external {
        epoch = newEpoch;
    }
}
