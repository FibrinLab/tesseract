// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

/// @dev Default admin role name
bytes32 constant DEFAULT_ADMIN_ROLE = 0x00;

/// @dev Role name for Governance tokens minter
bytes32 constant GOVERNANCE_TOKEN_MINTER_ROLE = keccak256(
    "GOVERNANCE_TOKEN_MINTER_ROLE"
);

/// @dev Role name for Governance tokens burner
bytes32 constant GOVERNANCE_TOKEN_BURNER_ROLE = keccak256(
    "GOVERNANCE_TOKEN_BURNER_ROLE"
);

/// @dev Role name for pauser
bytes32 constant PAUSER_ROLE = keccak256("PAUSER_ROLE");