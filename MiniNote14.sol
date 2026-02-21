// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract MiniNote14 {
    bytes32 public note;

    function setNote(bytes32 newNote) external {
        note = newNote;
    }
}
