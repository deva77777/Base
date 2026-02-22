// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract MiniPermit22 {
    address public permitted;

    function setPermitted(address account) external {
        permitted = account;
    }

    function isPermitted(address account) external view returns (bool) {
        return account == permitted;
    }
}
