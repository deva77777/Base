// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract MiniRatio45 {
    uint256 public numerator;
    uint256 public denominator;

    function setRatio(uint256 newNumerator, uint256 newDenominator) external {
        numerator = newNumerator;
        denominator = newDenominator;
    }

    function value() external view returns (uint256) {
        require(denominator > 0, "Zero denom");
        return (numerator * 1e18) / denominator;
    }
}
