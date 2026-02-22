// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract MiniScore07 {
    mapping(address => uint256) public scores;

    function setScore(address player, uint256 score) external {
        scores[player] = score;
    }
}
