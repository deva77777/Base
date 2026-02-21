// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract MiniBucket27 {
    bytes32[] public items;

    function add(bytes32 item) external {
        items.push(item);
    }

    function count() external view returns (uint256) {
        return items.length;
    }
}
