// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {DiamondTestSetup} from "../diamond/DiamondTestSetup.sol";
import {MockMetaPool} from "../../src/mocks/MockMetaPool.sol";

abstract contract LocalTestHelper is DiamondTestSetup {
    address public constant NATIVE_ASSET = address(0);
    address public treasuryAddress = address(0x111222333);
    address metaPoolAddress;

    function setUp() public virtual override {
        super.setUp();

        vm.startPrank(admin);

        tesseractToken.mint(address(0x1045256), 10000e18);
        require(
            tesseractToken.balanceOf(address(0x1045256)) == 10000e18,
            "token balance is not 10000e18"
        );

        // set treasury address
        managerFacet.setTreasuryAddress(treasuryAddress);

        vm.stopPrank();
    }
}