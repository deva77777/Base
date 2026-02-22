// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title TimelockWallet
 * @dev A wallet with time-locked withdrawals for multiple beneficiaries
 */
contract TimelockWallet {
    address public owner;
    uint256 public lockDuration;

    struct Beneficiary {
        uint256 amount;
        uint256 unlockTime;
        bool withdrawn;
        bool exists;
    }

    mapping(address => Beneficiary) public beneficiaries;
    address[] public beneficiaryList;

    event OwnerSet(address indexed owner);
    event BeneficiaryAdded(address indexed beneficiary, uint256 amount, uint256 unlockTime);
    event FundsWithdrawn(address indexed beneficiary, uint256 amount);
    event LockDurationUpdated(uint256 newDuration);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this");
        _;
    }

    modifier isBeneficiary() {
        require(beneficiaries[msg.sender].exists, "Not a beneficiary");
        _;
    }

    modifier canWithdraw() {
        require(block.timestamp >= beneficiaries[msg.sender].unlockTime, "Funds still locked");
        require(!beneficiaries[msg.sender].withdrawn, "Already withdrawn");
        _;
    }

    constructor(uint256 _lockDuration) {
        owner = msg.sender;
        lockDuration = _lockDuration;
        emit OwnerSet(msg.sender);
    }

    receive() external payable {}

    function addBeneficiary(address _beneficiary, uint256 _amount) external onlyOwner {
        require(_beneficiary != address(0), "Invalid address");
        require(_amount > 0, "Amount must be > 0");
        require(address(this).balance >= getTotalAllocated() + _amount, "Insufficient balance");

        if (!beneficiaries[_beneficiary].exists) {
            beneficiaryList.push(_beneficiary);
            beneficiaries[_beneficiary].exists = true;
        }

        beneficiaries[_beneficiary].amount += _amount;
        beneficiaries[_beneficiary].unlockTime = block.timestamp + lockDuration;

        emit BeneficiaryAdded(_beneficiary, _amount, beneficiaries[_beneficiary].unlockTime);
    }

    function addBeneficiaryWithCustomTime(address _beneficiary, uint256 _amount, uint256 _unlockTime) external onlyOwner {
        require(_beneficiary != address(0), "Invalid address");
        require(_amount > 0, "Amount must be > 0");
        require(_unlockTime > block.timestamp, "Unlock time must be in future");
        require(address(this).balance >= getTotalAllocated() + _amount, "Insufficient balance");

        if (!beneficiaries[_beneficiary].exists) {
            beneficiaryList.push(_beneficiary);
            beneficiaries[_beneficiary].exists = true;
        }

        beneficiaries[_beneficiary].amount += _amount;
        beneficiaries[_beneficiary].unlockTime = _unlockTime;

        emit BeneficiaryAdded(_beneficiary, _amount, _unlockTime);
    }

    function withdraw() external isBeneficiary canWithdraw {
        uint256 amount = beneficiaries[msg.sender].amount;
        require(amount > 0, "No funds available");

        beneficiaries[msg.sender].withdrawn = true;

        (bool sent, ) = msg.sender.call{value: amount}("");
        require(sent, "Withdrawal failed");

        emit FundsWithdrawn(msg.sender, amount);
    }

    function getTotalAllocated() public view returns (uint256) {
        uint256 total = 0;
        for (uint256 i = 0; i < beneficiaryList.length; i++) {
            if (!beneficiaries[beneficiaryList[i]].withdrawn) {
                total += beneficiaries[beneficiaryList[i]].amount;
            }
        }
        return total;
    }

    function getAvailableBalance() external view returns (uint256) {
        return address(this).balance - getTotalAllocated();
    }

    function getBeneficiaryInfo(address _beneficiary) external view returns (
        uint256 amount,
        uint256 unlockTime,
        bool withdrawn,
        bool exists,
        uint256 timeRemaining
    ) {
        Beneficiary memory ben = beneficiaries[_beneficiary];
        uint256 remaining = 0;
        if (ben.unlockTime > block.timestamp) {
            remaining = ben.unlockTime - block.timestamp;
        }
        return (ben.amount, ben.unlockTime, ben.withdrawn, ben.exists, remaining);
    }

    function getBeneficiaryCount() external view returns (uint256) {
        return beneficiaryList.length;
    }

    function getAllBeneficiaries() external view returns (address[] memory) {
        return beneficiaryList;
    }

    function setLockDuration(uint256 _newDuration) external onlyOwner {
        lockDuration = _newDuration;
        emit LockDurationUpdated(_newDuration);
    }

    function transferOwnership(address _newOwner) external onlyOwner {
        require(_newOwner != address(0), "Invalid address");
        owner = _newOwner;
        emit OwnerSet(_newOwner);
    }

    function withdrawOwnerFunds() external onlyOwner {
        uint256 available = getAvailableBalance();
        require(available > 0, "No available funds");

        (bool sent, ) = owner.call{value: available}("");
        require(sent, "Withdrawal failed");
    }
}
