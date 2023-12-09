// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "../DiamondTestSetup.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {LibAccessControl} from "../../../src/libraries/LibAccessControl.sol";
import {MockERC20} from "../../../src/mocks/MockERC20.sol";

contract ManagerFacetTest is DiamondTestSetup {
    function testSetDollarTokenAddress_ShouldSucceed() public prankAs(admin) {
        assertEq(managerFacet.tesseractTokenAddress(), address(tesseractToken));
    }

    function testSetTreasuryAddress_ShouldSucceed() public prankAs(admin) {
        managerFacet.setTreasuryAddress(contract1);
        assertEq(managerFacet.treasuryAddress(), contract1);
    }


    function testSetMinterRoleWhenInitializing_ShouldSucceed()
        public
        prankAs(admin)
    {
        assertEq(
            accessControlFacet.hasRole(GOVERNANCE_TOKEN_MINTER_ROLE, admin),
            true
        );
    }

    function testInitializeTesseractTokenAddress_ShouldSucceed()
        public
        prankAs(admin)
    {
        assertEq(managerFacet.tesseractTokenAddress(), address(tesseractToken));
    }
}