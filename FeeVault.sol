// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract FeeVault {
    uint256 public feeBasisPoints = 250;

    function setFee(uint256 nextFee) external {
        require(nextFee <= 1000, "Too high");
        feeBasisPoints = nextFee;
    }

    function calculateFee(uint256 amount) external view returns (uint256) {
        return (amount * feeBasisPoints) / 10_000;
    }
}
