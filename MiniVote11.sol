// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract MiniVote11 {
    uint256 public yes;
    uint256 public no;

    function voteYes() external {
        yes += 1;
    }

    function voteNo() external {
        no += 1;
    }
}
