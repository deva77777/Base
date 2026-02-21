// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract NotePad {
    string private note;

    event NoteUpdated(address indexed author, string note);

    function setNote(string calldata newNote) external {
        note = newNote;
        emit NoteUpdated(msg.sender, newNote);
    }

    function getNote() external view returns (string memory) {
        return note;
    }
}
