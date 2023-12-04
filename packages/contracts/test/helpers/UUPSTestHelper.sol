// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {TesseractToken} from "../../src/core/TesseractToken.sol";
import {ManagerFacet} from "../../src/facets/ManagerFacet.sol";
import "../../src/libraries/Constants.sol";
import "forge-std/Test.sol";

/**
 * Initializes core contracts with UUPS upgradeability:
 */
contract UUPSTestHelper {
    // core contracts pointing to proxies
    TesseractToken tesseractToken;

    // proxies for core contracts
    ERC1967Proxy proxyTesseractToken;

    /**
     * Initializes core contracts with UUPS upgradeability
     */
    function __setupUUPS(address diamond) public {
        bytes memory initData;

        // deploy CreditNft
        initData = abi.encodeWithSignature("initialize(address)", diamond);

        // deploy TesseractTokenToken
        initData = abi.encodeWithSignature("initialize(address)", diamond);
        proxyTesseractToken = new ERC1967Proxy(
            address(new TesseractToken()),
            initData
        );
        tesseractToken = TesseractToken(address(proxyTesseractToken));

        // set addresses of the newly deployed contracts in the Diamond
        ManagerFacet managerFacet = ManagerFacet(diamond);
        managerFacet.setTesseractTokenAddress(address(tesseractToken));
    }
}