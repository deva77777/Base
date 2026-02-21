// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title DepositBox
 * @dev A secure deposit box where users can lock funds with a secret
 */
contract DepositBox {
    address public owner;
    
    struct Deposit {
        address depositor;
        uint256 amount;
        bytes32 secretHash;
        uint256 lockTime;
        uint256 unlockTime;
        bool withdrawn;
        bool exists;
    }

    mapping(uint256 => Deposit) public deposits;
    uint256 public depositCount;
    mapping(address => uint256[]) public userDeposits;

    uint256 public constant MIN_LOCK_TIME = 1 days;
    uint256 public constant MAX_LOCK_TIME = 365 days;

    event DepositCreated(uint256 indexed depositId, address indexed depositor, uint256 amount, uint256 unlockTime);
    event DepositWithdrawn(uint256 indexed depositId, address indexed depositor, uint256 amount);
    event DepositForfeited(uint256 indexed depositId, address indexed owner);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function createDeposit(bytes32 _secretHash, uint256 _lockDuration) external payable returns (uint256) {
        require(msg.value > 0, "Must deposit something");
        require(_lockDuration >= MIN_LOCK_TIME, "Lock time too short");
        require(_lockDuration <= MAX_LOCK_TIME, "Lock time too long");

        uint256 depositId = depositCount++;

        deposits[depositId] = Deposit({
            depositor: msg.sender,
            amount: msg.value,
            secretHash: _secretHash,
            lockTime: block.timestamp,
            unlockTime: block.timestamp + _lockDuration,
            withdrawn: false,
            exists: true
        });

        userDeposits[msg.sender].push(depositId);

        emit DepositCreated(depositId, msg.sender, msg.value, deposits[depositId].unlockTime);

        return depositId;
    }

    function withdraw(uint256 _depositId, uint256 _secret) external {
        require(deposits[_depositId].exists, "Deposit does not exist");
        Deposit storage deposit = deposits[_depositId];

        require(msg.sender == deposit.depositor, "Not the depositor");
        require(!deposit.withdrawn, "Already withdrawn");
        require(block.timestamp >= deposit.unlockTime, "Lock period not ended");
        require(keccak256(abi.encodePacked(_secret)) == deposit.secretHash, "Invalid secret");

        uint256 amount = deposit.amount;
        deposit.withdrawn = true;

        (bool sent, ) = msg.sender.call{value: amount}("");
        require(sent, "Withdrawal failed");

        emit DepositWithdrawn(_depositId, msg.sender, amount);
    }

    function forfeitDeposit(uint256 _depositId) external onlyOwner {
        require(deposits[_depositId].exists, "Deposit does not exist");
        Deposit storage deposit = deposits[_depositId];

        require(!deposit.withdrawn, "Already withdrawn");
        require(block.timestamp > deposit.unlockTime + 30 days, "Grace period not ended");

        uint256 amount = deposit.amount;
        deposit.withdrawn = true;

        (bool sent, ) = owner.call{value: amount}("");
        require(sent, "Transfer failed");

        emit DepositForfeited(_depositId, owner);
    }

    function getDeposit(uint256 _depositId) external view returns (
        address depositor,
        uint256 amount,
        uint256 lockTime,
        uint256 unlockTime,
        bool withdrawn,
        bool exists,
        uint256 timeRemaining
    ) {
        require(deposits[_depositId].exists, "Deposit does not exist");
        Deposit memory deposit = deposits[_depositId];
        
        uint256 remaining = 0;
        if (deposit.unlockTime > block.timestamp) {
            remaining = deposit.unlockTime - block.timestamp;
        }

        return (
            deposit.depositor,
            deposit.amount,
            deposit.lockTime,
            deposit.unlockTime,
            deposit.withdrawn,
            deposit.exists,
            remaining
        );
    }

    function getUserDeposits(address _user) external view returns (uint256[] memory) {
        return userDeposits[_user];
    }

    function getTotalDeposits() external view returns (uint256) {
        return depositCount;
    }

    function getContractBalance() external view returns (uint256) {
        return address(this).balance;
    }

    function emergencyWithdraw() external onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "No funds");
        (bool sent, ) = owner.call{value: balance}("");
        require(sent, "Failed");
    }

    receive() external payable {}
}
