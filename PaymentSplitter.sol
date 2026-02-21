// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title PaymentSplitter
 * @dev Splits incoming payments among multiple recipients based on shares
 */
contract PaymentSplitter {
    address[] public payees;
    mapping(address => uint256) public shares;
    mapping(address => uint256) public released;
    mapping(address => bool) public isPayee;
    uint256 public totalShares;
    uint256 public totalReleased;

    event PaymentReceived(address from, uint256 amount);
    event PaymentReleased(address indexed payee, uint256 amount);
    event PayeeAdded(address indexed payee, uint256 shares);

    constructor(address[] memory _payees, uint256[] memory _shares) {
        require(_payees.length == _shares.length, "Arrays length mismatch");
        require(_payees.length > 0, "No payees");

        for (uint256 i = 0; i < _payees.length; i++) {
            require(_payees[i] != address(0), "Payee is zero address");
            require(_shares[i] > 0, "Shares must be > 0");
            require(!isPayee[_payees[i]], "Payee already exists");

            payees.push(_payees[i]);
            shares[_payees[i]] = _shares[i];
            isPayee[_payees[i]] = true;
            totalShares += _shares[i];

            emit PayeeAdded(_payees[i], _shares[i]);
        }
    }

    receive() external payable {
        emit PaymentReceived(msg.sender, msg.value);
    }

    function release(address payable _payee) external {
        require(isPayee[_payee], "Not a payee");
        require(shares[_payee] > 0, "No shares");

        uint256 totalReceived = address(this).balance + totalReleased;
        uint256 payeeTotal = (totalReceived * shares[_payee]) / totalShares;
        uint256 amount = payeeTotal - released[_payee];

        require(amount > 0, "No funds to release");

        released[_payee] = payeeTotal;
        totalReleased += amount;

        (bool sent, ) = _payee.call{value: amount}("");
        require(sent, "Failed to send");

        emit PaymentReleased(_payee, amount);
    }

    function getPayeeCount() external view returns (uint256) {
        return payees.length;
    }

    function getAllPayees() external view returns (address[] memory) {
        return payees;
    }

    function getPendingPayment(address _payee) external view returns (uint256) {
        require(isPayee[_payee], "Not a payee");
        
        uint256 totalReceived = address(this).balance + totalReleased;
        uint256 payeeTotal = (totalReceived * shares[_payee]) / totalShares;
        return payeeTotal - released[_payee];
    }

    function getShare(address _payee) external view returns (uint256) {
        return shares[_payee];
    }
}
