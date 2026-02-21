// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title IdentityRegistry
 * @dev A decentralized identity registry for storing and verifying identity claims
 */
contract IdentityRegistry {
    address public admin;
    
    struct Identity {
        bool exists;
        string name;
        string email;
        uint256 createdAt;
        bool verified;
        mapping(string => Claim) claims;
        string[] claimTypes;
    }

    struct Claim {
        string value;
        address issuer;
        uint256 timestamp;
        bool verified;
    }

    mapping(address => Identity) public identities;
    mapping(address => bool) public issuers;
    address[] public registeredIdentities;

    event IdentityCreated(address indexed user, string name);
    event IdentityVerified(address indexed user);
    event ClaimAdded(address indexed user, string claimType, string value, address issuer);
    event IssuerAdded(address indexed issuer);
    event IssuerRemoved(address indexed issuer);

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can call this");
        _;
    }

    modifier onlyIssuer() {
        require(issuers[msg.sender], "Not an authorized issuer");
        _;
    }

    modifier identityExists() {
        require(identities[msg.sender].exists, "Identity does not exist");
        _;
    }

    constructor() {
        admin = msg.sender;
    }

    function createIdentity(string calldata _name, string calldata _email) external {
        require(!identities[msg.sender].exists, "Identity already exists");

        identities[msg.sender] = Identity({
            exists: true,
            name: _name,
            email: _email,
            createdAt: block.timestamp,
            verified: false
        });

        registeredIdentities.push(msg.sender);
        emit IdentityCreated(msg.sender, _name);
    }

    function verifyIdentity(address _user) external onlyAdmin {
        require(identities[_user].exists, "Identity does not exist");
        identities[_user].verified = true;
        emit IdentityVerified(_user);
    }

    function addIssuer(address _issuer) external onlyAdmin {
        require(_issuer != address(0), "Invalid address");
        issuers[_issuer] = true;
        emit IssuerAdded(_issuer);
    }

    function removeIssuer(address _issuer) external onlyAdmin {
        issuers[_issuer] = false;
        emit IssuerRemoved(_issuer);
    }

    function addClaim(address _user, string calldata _claimType, string calldata _value) external onlyIssuer {
        require(identities[_user].exists, "Identity does not exist");

        Identity storage identity = identities[_user];

        if (identity.claims[_claimType].timestamp == 0) {
            identity.claimTypes.push(_claimType);
        }

        identity.claims[_claimType] = Claim({
            value: _value,
            issuer: msg.sender,
            timestamp: block.timestamp,
            verified: true
        });

        emit ClaimAdded(_user, _claimType, _value, msg.sender);
    }

    function selfAddClaim(string calldata _claimType, string calldata _value) external identityExists {
        Identity storage identity = identities[msg.sender];

        if (identity.claims[_claimType].timestamp == 0) {
            identity.claimTypes.push(_claimType);
        }

        identity.claims[_claimType] = Claim({
            value: _value,
            issuer: msg.sender,
            timestamp: block.timestamp,
            verified: false
        });

        emit ClaimAdded(msg.sender, _claimType, _value, msg.sender);
    }

    function getIdentity(address _user) external view returns (
        bool exists,
        string memory name,
        string memory email,
        uint256 createdAt,
        bool verified
    ) {
        Identity memory identity = identities[_user];
        return (identity.exists, identity.name, identity.email, identity.createdAt, identity.verified);
    }

    function getClaim(address _user, string calldata _claimType) external view returns (
        string memory value,
        address issuer,
        uint256 timestamp,
        bool verified
    ) {
        Claim memory claim = identities[_user].claims[_claimType];
        return (claim.value, claim.issuer, claim.timestamp, claim.verified);
    }

    function getClaimTypes(address _user) external view returns (string[] memory) {
        return identities[_user].claimTypes;
    }

    function isVerified(address _user) external view returns (bool) {
        return identities[_user].verified;
    }

    function isIssuer(address _issuer) external view returns (bool) {
        return issuers[_issuer];
    }

    function getRegisteredCount() external view returns (uint256) {
        return registeredIdentities.length;
    }

    function getAllRegisteredIdentities() external view returns (address[] memory) {
        return registeredIdentities;
    }

    function updateProfile(string calldata _name, string calldata _email) external identityExists {
        identities[msg.sender].name = _name;
        identities[msg.sender].email = _email;
    }
}
