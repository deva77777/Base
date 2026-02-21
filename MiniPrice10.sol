// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract MiniPrice10 {
    uint256 public price;

    function updatePrice(uint256 newPrice) external {
        price = newPrice;
    }
}
