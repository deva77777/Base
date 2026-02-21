// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Charity
 * @dev A charity contract for collecting and distributing donations
 */
contract Charity {
    address public owner;
    address public beneficiary;
    uint256 public totalDonated;
    bool public isActive;

    struct Donation {
        address donor;
        uint256 amount;
        uint256 timestamp;
    }

    Donation[] public donations;
    mapping(address => uint256) public donorContributions;

    event Donated(address indexed donor, uint256 amount);
    event BeneficiaryChanged(address indexed oldBeneficiary, address indexed newBeneficiary);
    event Withdrawn(address indexed beneficiary, uint256 amount);

    constructor(address _beneficiary) {
        owner = msg.sender;
        beneficiary = _beneficiary;
        isActive = true;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    modifier onlyWhenActive() {
        require(isActive, "Charity is not active");
        _;
    }

    function donate() public payable onlyWhenActive {
        require(msg.value > 0, "Must donate something");

        donations.push(Donation({
            donor: msg.sender,
            amount: msg.value,
            timestamp: block.timestamp
        }));

        donorContributions[msg.sender] += msg.value;
        totalDonated += msg.value;

        emit Donated(msg.sender, msg.value);
    }

    function withdraw() public {
        require(msg.sender == beneficiary, "Not beneficiary");
        require(address(this).balance > 0, "No funds available");

        uint256 amount = address(this).balance;
        payable(beneficiary).transfer(amount);

        emit Withdrawn(beneficiary, amount);
    }

    function setBeneficiary(address _newBeneficiary) public onlyOwner {
        require(_newBeneficiary != address(0), "Invalid address");
        emit BeneficiaryChanged(beneficiary, _newBeneficiary);
        beneficiary = _newBeneficiary;
    }

    function setActive(bool _isActive) public onlyOwner {
        isActive = _isActive;
    }

    function getDonationCount() public view returns (uint256) {
        return donations.length;
    }

    function getDonation(uint256 index) public view returns (address donor, uint256 amount, uint256 timestamp) {
        require(index < donations.length, "Invalid index");
        Donation memory donation = donations[index];
        return (donation.donor, donation.amount, donation.timestamp);
    }
}
