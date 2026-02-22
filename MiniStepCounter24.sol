// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract MiniStepCounter24 {
    uint256 public count;
    uint256 public step = 2;

    function setStep(uint256 newStep) external {
        step = newStep;
    }

    function increment() external {
        count += step;
    }
}
