// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {EnumerableSet} from "../libraries/EnumerableSet.sol";
import {AddressUtils} from "../libraries/AddressUtils.sol";
import {UintUtils} from "../libraries/UintUtils.sol";
import {LibAppStorage} from "./LibAppStorage.sol";

library LibAccessControl {
    using AddressUtils for address;
    using EnumerableSet for EnumerableSet.AddressSet;
    using UintUtils for uint256;

    bytes32 constant ACCESS_CONTROL_STORAGE_SLOT =
        bytes32(
            uint256(keccak256("ubiquity.contracts.access.control.storage")) - 1
        );

    struct RoleData {
        EnumerableSet.AddressSet members;
        bytes32 adminRole;
    }

    struct Layout {
        mapping(bytes32 => RoleData) roles;
    }

    event RoleAdminChanged(
        bytes32 indexed role,
        bytes32 indexed previousAdminRole,
        bytes32 indexed newAdminRole
    );

    event RoleGranted(
        bytes32 indexed role,
        address indexed account,
        address indexed sender
    );

    event RoleRevoked(
        bytes32 indexed role,
        address indexed account,
        address indexed sender
    );

    event Paused(address account);

    event Unpaused(address account);

    function accessControlStorage() internal pure returns (Layout storage l) {
        bytes32 slot = ACCESS_CONTROL_STORAGE_SLOT;
        assembly {
            l.slot := slot
        }
    }

    modifier onlyRole(bytes32 role) {
        checkRole(role);
        _;
    }

    function paused() internal view returns (bool) {
        return LibAppStorage.appStorage().paused;
    }

    function hasRole(
        bytes32 role,
        address account
    ) internal view returns (bool) {
        return accessControlStorage().roles[role].members.contains(account);
    }

    function checkRole(bytes32 role) internal view {
        checkRole(role, msg.sender);
    }

    function checkRole(bytes32 role, address account) internal view {
        if (!hasRole(role, account)) {
            revert(
                string(
                    abi.encodePacked(
                        "AccessControl: account ",
                        account.toString(),
                        " is missing role ",
                        uint256(role).toHexString(32)
                    )
                )
            );
        }
    }

    function getRoleAdmin(bytes32 role) internal view returns (bytes32) {
        return accessControlStorage().roles[role].adminRole;
    }

    function setRoleAdmin(bytes32 role, bytes32 adminRole) internal {
        bytes32 previousAdminRole = getRoleAdmin(role);
        accessControlStorage().roles[role].adminRole = adminRole;
        emit RoleAdminChanged(role, previousAdminRole, adminRole);
    }

    function grantRole(bytes32 role, address account) internal {
        accessControlStorage().roles[role].members.add(account);
        emit RoleGranted(role, account, msg.sender);
    }

    function revokeRole(bytes32 role, address account) internal {
        accessControlStorage().roles[role].members.remove(account);
        emit RoleRevoked(role, account, msg.sender);
    }

    function renounceRole(bytes32 role) internal {
        revokeRole(role, msg.sender);
    }

    function pause() internal {
        LibAppStorage.appStorage().paused = true;
        emit Paused(msg.sender);
    }

    function unpause() internal {
        LibAppStorage.appStorage().paused = false;
        emit Unpaused(msg.sender);
    }
}