// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract NumberGuess {
    uint8 private secret;

    event GuessResult(address indexed player, bool correct);

    constructor(uint8 initialSecret) {
        secret = initialSecret;
    }

    function guess(uint8 value) external returns (bool) {
        bool correct = value == secret;
        emit GuessResult(msg.sender, correct);
        return correct;
    }
}
