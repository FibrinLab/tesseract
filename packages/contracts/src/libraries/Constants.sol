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

bytes32 constant HEALTH_PROVIDER_ROLE = keccak256(
    "HEALTH_PROVIDER_ROLE"
);

/// @dev Role name for pauser
bytes32 constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
bytes32 constant MINTER_ROLE = keccak256("MINTER_ROLE");
bytes32 constant BURNER_ROLE = keccak256("BURNER_ROLE");

/// @dev Reentrancy constant
uint256 constant _NOT_ENTERED = 1;

/// @dev Reentrancy constant
uint256 constant _ENTERED = 2;

uint256 constant ONE = uint256(1 ether);
uint256 constant ACCURACY = 10e18;
uint32 constant MAX_WEIGHT = 1e6;
