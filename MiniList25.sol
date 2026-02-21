// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract MiniList25 {
    address[] public list;

    function add(address account) external {
        list.push(account);
    }

    function count() external view returns (uint256) {
        return list.length;
    }
}
