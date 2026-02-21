// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract MiniBeacon36 {
    address public beacon;

    function setBeacon(address newBeacon) external {
        beacon = newBeacon;
    }

    function isBeacon(address account) external view returns (bool) {
        return account == beacon;
    }
}
