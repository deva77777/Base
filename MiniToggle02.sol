// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract MiniToggle02 {
    bool public enabled;

    function flip() external {
        enabled = !enabled;
    }
}
