// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Bounty
 * @dev A bounty contract for rewarding completed tasks or bug reports
 */
contract Bounty {
    address public owner;
    uint256 public bountyAmount;
    string public description;
    bool public active;
    bool public completed;

    struct Submission {
        address submitter;
        string solution;
        uint256 timestamp;
        bool approved;
        bool rejected;
    }

    Submission[] public submissions;
    mapping(address => uint256[]) public userSubmissionIndices;

    event BountyCreated(address indexed owner, uint256 amount, string description);
    event SubmissionCreated(uint256 indexed submissionId, address indexed submitter);
    event SubmissionApproved(uint256 indexed submissionId, address indexed submitter);
    event SubmissionRejected(uint256 indexed submissionId);
    event BountyCompleted(uint256 indexed submissionId, address winner);
    event BountyCancelled();
    event FundsWithdrawn(address indexed owner, uint256 amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this");
        _;
    }

    modifier isActive() {
        require(active && !completed, "Bounty is not active");
        _;
    }

    constructor(uint256 _amount, string memory _description) payable {
        require(msg.value >= _amount, "Insufficient funds deposited");
        owner = msg.sender;
        bountyAmount = _amount;
        description = _description;
        active = true;
        completed = false;
        emit BountyCreated(owner, _amount, _description);
    }

    function submitSolution(string calldata _solution) external isActive returns (uint256) {
        uint256 submissionId = submissions.length;

        submissions.push(Submission({
            submitter: msg.sender,
            solution: _solution,
            timestamp: block.timestamp,
            approved: false,
            rejected: false
        }));

        userSubmissionIndices[msg.sender].push(submissionId);
        emit SubmissionCreated(submissionId, msg.sender);

        return submissionId;
    }

    function approveSubmission(uint256 _submissionId) external onlyOwner isActive {
        require(_submissionId < submissions.length, "Invalid submission ID");
        require(!submissions[_submissionId].approved && !submissions[_submissionId].rejected, "Already processed");

        Submission storage submission = submissions[_submissionId];
        submission.approved = true;
        completed = true;
        active = false;

        (bool sent, ) = submission.submitter.call{value: bountyAmount}("");
        require(sent, "Failed to send bounty");

        emit SubmissionApproved(_submissionId, submission.submitter);
        emit BountyCompleted(_submissionId, submission.submitter);
    }

    function rejectSubmission(uint256 _submissionId) external onlyOwner isActive {
        require(_submissionId < submissions.length, "Invalid submission ID");
        require(!submissions[_submissionId].approved && !submissions[_submissionId].rejected, "Already processed");

        submissions[_submissionId].rejected = true;
        emit SubmissionRejected(_submissionId);
    }

    function cancelBounty() external onlyOwner {
        require(!completed, "Bounty already completed");
        active = false;
        emit BountyCancelled();
    }

    function withdraw() external onlyOwner {
        require(!active || completed, "Bounty is still active");
        uint256 balance = address(this).balance;
        require(balance > 0, "No funds to withdraw");

        (bool sent, ) = owner.call{value: balance}("");
        require(sent, "Failed to withdraw");

        emit FundsWithdrawn(owner, balance);
    }

    function getSubmission(uint256 _submissionId) external view returns (
        address submitter,
        string memory solution,
        uint256 timestamp,
        bool approved,
        bool rejected
    ) {
        require(_submissionId < submissions.length, "Invalid submission ID");
        Submission memory sub = submissions[_submissionId];
        return (sub.submitter, sub.solution, sub.timestamp, sub.approved, sub.rejected);
    }

    function getUserSubmissions(address _user) external view returns (uint256[] memory) {
        return userSubmissionIndices[_user];
    }

    function getSubmissionCount() external view returns (uint256) {
        return submissions.length;
    }

    function getAllSubmissions() external view returns (Submission[] memory) {
        return submissions;
    }

    function getBountyInfo() external view returns (
        address owner_,
        uint256 amount,
        string memory desc,
        bool isActive_,
        bool isCompleted,
        uint256 balance
    ) {
        return (owner, bountyAmount, description, active, completed, address(this).balance);
    }

    receive() external payable {}
}
