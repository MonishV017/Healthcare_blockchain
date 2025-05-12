// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @title HealthcareRecordManager
/// @notice Manages patient records with doctor-only access control and audit logging.
contract HealthcareRecordManager {
    // Roles
    address public admin;
    mapping(address => bool) public doctors;

    // Patient record structure
    struct Record {
        uint256 timestamp;
        string dataHash;        // e.g. IPFS hash or encrypted data pointer
        address addedBy;
    }

    // Each patient has a list of records
    mapping(address => Record[]) private patientRecords;
    // Access rights: patient => viewer => allowed
    mapping(address => mapping(address => bool)) private accessRights;

    // Audit events
    event RecordAdded(address indexed patient, uint256 recordIndex, address indexed by);
    event AccessGranted(address indexed patient, address indexed viewer);
    event AccessRevoked(address indexed patient, address indexed viewer);

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin");
        _;
    }

    modifier onlyDoctor() {
        require(doctors[msg.sender], "Only doctors");
        _;
    }

    constructor() {
        admin = msg.sender;
    }

    // Admin functions
    function addDoctor(address _doc) external onlyAdmin {
        doctors[_doc] = true;
    }

    function removeDoctor(address _doc) external onlyAdmin {
        doctors[_doc] = false;
    }

    // Patient grants/revokes access
    function grantAccess(address _viewer) external {
        accessRights[msg.sender][_viewer] = true;
        emit AccessGranted(msg.sender, _viewer);
    }

    function revokeAccess(address _viewer) external {
        accessRights[msg.sender][_viewer] = false;
        emit AccessRevoked(msg.sender, _viewer);
    }

    // Doctors add a new record
    function addRecord(address _patient, string calldata _dataHash) external onlyDoctor {
        Record memory rec = Record({
            timestamp: block.timestamp,
            dataHash: _dataHash,
            addedBy: msg.sender
        });
        patientRecords[_patient].push(rec);
        emit RecordAdded(_patient, patientRecords[_patient].length - 1, msg.sender);
    }

    // Fetch records (patient, authorized viewer, or any doctor)
    function getRecords(address _patient)
        external
        view
        returns (Record[] memory)
    {
        require(
            msg.sender == _patient ||
            accessRights[_patient][msg.sender] ||
            doctors[msg.sender],
            "Access denied"
        );
        return patientRecords[_patient];
    }
}