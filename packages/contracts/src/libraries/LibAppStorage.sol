// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {LibDiamond} from "./LibDiamond.sol";
import {LibAccessControl} from "./LibAccessControl.sol";
import "./Constants.sol";


struct AppStorage {
    // reentrancy guard
    uint256 reentrancyStatus;
    // others
    address tessTokenAddress;
    // pausable
    bool paused;
}

library LibAppStorage {
    function appStorage() internal pure returns (AppStorage storage ds) {
        assembly {
            ds.slot := 0
        }
    }
}

contract Modifier {

    AppStorage internal store;

    modifier nonReentrant() {
        require(
            store.reentrancyStatus != _ENTERED,
            "ReentrancyGuard: reentrant call"
        );

        // Any calls to nonReentrant after this point will fail
        store.reentrancyStatus = _ENTERED;
        _;
        store.reentrancyStatus = _NOT_ENTERED;
    }

    modifier onlyOwner() {
        LibDiamond.enforceIsContractOwner();
        _;
    }

    modifier onlyAdmin() {
        require(
            LibAccessControl.hasRole(DEFAULT_ADMIN_ROLE, msg.sender),
            "Manager: Caller is not admin"
        );
        _;
    }

    modifier whenNotPaused() {
        require(!LibAccessControl.paused(), "Pausable: paused");
        _;
    }

    modifier whenPaused() {
        require(LibAccessControl.paused(), "Pausable: not paused");
        _;
    }

    function _initReentrancyGuard() internal {
        store.reentrancyStatus = _NOT_ENTERED;
    }

}