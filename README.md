# Healthcare_blockchain
Project: Healthcare Record Manager



This Solidity smart contract, HealthcareRecordManager, manages patient health records with strict access control.

Admin (contract deployer) can assign or remove doctor privileges to other addresses.

Only doctors can add medical records for patients, which include a timestamp, data hash (e.g., IPFS), and the address of the doctor.

Each patient has a list of medical records stored privately in the contract.

Patients can grant or revoke access to their records for specific viewer addresses (e.g., family or other doctors).

The contract emits audit events whenever records are added or access rights change.

Records can only be viewed by the patient, authorized viewers, or a doctor.

This ensures data privacy, traceability, and controlled access in a decentralized healthcare application.

