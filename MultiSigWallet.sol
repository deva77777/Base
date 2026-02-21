// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title MultiSigWallet
 * @dev A multi-signature wallet requiring multiple confirmations
 */
contract MultiSigWallet {
    struct Transaction {
        address to;
        uint256 value;
        bool executed;
        uint256 confirmations;
    }

    address[] public owners;
    mapping(address => bool) public isOwner;
    mapping(uint256 => mapping(address => bool)) public confirmations;
    Transaction[] public transactions;
    uint256 public requiredConfirmations;

    event Deposit(address indexed sender, uint256 amount);
    event Submission(uint256 indexed txId);
    event Confirmation(address indexed owner, uint256 indexed txId);
    event Execution(uint256 indexed txId);

    constructor(address[] memory _owners, uint256 _requiredConfirmations) {
        require(_owners.length > 0, "Owners required");
        require(_requiredConfirmations > 0 && _requiredConfirmations <= _owners.length, "Invalid confirmations");

        for (uint256 i = 0; i < _owners.length; i++) {
            require(!isOwner[_owners[i]], "Owner not unique");
            isOwner[_owners[i]] = true;
            owners.push(_owners[i]);
        }
        requiredConfirmations = _requiredConfirmations;
    }

    receive() external payable {
        emit Deposit(msg.sender, msg.value);
    }

    function submitTransaction(address _to, uint256 _value) public onlyOwner {
        transactions.push(Transaction({
            to: _to,
            value: _value,
            executed: false,
            confirmations: 0
        }));
        emit Submission(transactions.length - 1);
    }

    function confirmTransaction(uint256 _txId) public onlyOwner {
        require(_txId < transactions.length, "Invalid txId");
        require(!confirmations[_txId][msg.sender], "Already confirmed");
        require(!transactions[_txId].executed, "Already executed");

        confirmations[_txId][msg.sender] = true;
        transactions[_txId].confirmations++;
        
        emit Confirmation(msg.sender, _txId);
    }

    function executeTransaction(uint256 _txId) public onlyOwner {
        require(_txId < transactions.length, "Invalid txId");
        require(transactions[_txId].confirmations >= requiredConfirmations, "Not enough confirmations");
        require(!transactions[_txId].executed, "Already executed");

        Transaction storage tx = transactions[_txId];
        tx.executed = true;
        payable(tx.to).transfer(tx.value);
        
        emit Execution(_txId);
    }

    function getTransactionCount() public view returns (uint256) {
        return transactions.length;
    }

    modifier onlyOwner() {
        require(isOwner[msg.sender], "Not an owner");
        _;
    }
}
