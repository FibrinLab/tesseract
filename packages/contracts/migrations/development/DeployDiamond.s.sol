// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {IERC165} from "@openzeppelin/contracts/interfaces/IERC165.sol";
import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {Script} from "forge-std/Script.sol";
import {Diamond, DiamondArgs} from "../../src/Diamond.sol";
import {TesseractToken} from "../../src/core/TesseractToken.sol";
import {AccessControlFacet} from "../../src/facets/AccessControlFacet.sol";
import {DiamondCutFacet} from "../../src/facets/DiamondCutFacet.sol";
import {DiamondLoupeFacet} from "../../src/facets/DiamondLoupeFacet.sol";
import {ManagerFacet} from "../../src/facets/ManagerFacet.sol";
import {OwnershipFacet} from "../../src/facets/OwnershipFacet.sol";
import {BondingHelixFacet} from "../../src/facets/BondingHelixFacet.sol";
import {HelixFacet} from "../../src/facets/HelixFacet.sol";
import {MarketPoolFacet} from "../../src/facets/MarketPoolFacet.sol";
import {IDiamondCut} from "../../src/interfaces/IDiamondCut.sol";
import {IDiamondLoupe} from "../../src/interfaces/IDiamondLoupe.sol";
import {IERC173} from "../../src/interfaces/IERC173.sol";
import {DEFAULT_ADMIN_ROLE, GOVERNANCE_TOKEN_MINTER_ROLE, GOVERNANCE_TOKEN_BURNER_ROLE, HEALTH_PROVIDER_ROLE, PAUSER_ROLE} from "../../src/libraries/Constants.sol";
import {LibAccessControl} from "../../src/libraries/LibAccessControl.sol";
import {AppStorage, LibAppStorage, Modifiers} from "../../src/libraries/LibAppStorage.sol";
import {LibDiamond} from "../../src/libraries/LibDiamond.sol";
import {DiamondTestHelper} from "../../test/helpers/DiamondTestHelper.sol";

/**
 * @notice It is expected that this contract is customized if you want to deploy your diamond
 * with data from a deployment script. Use the init function to initialize state variables
 * of your diamond. Add parameters to the init function if you need to.
 *
 * @notice How it works:
 * 1. New `Diamond` contract is created
 * 2. Inside the diamond's constructor there is a `delegatecall()` to `DiamondInit` with the provided args
 * 3. `DiamondInit` updates diamond storage
 */
contract DiamondInit is Modifiers {
    /// @notice Struct used for diamond initialization
    struct Args {
        address admin;
    }

    /**
     * @notice Initializes a diamond with state variables
     * @dev You can add parameters to this function in order to pass in data to set your own state variables
     * @param _args Init args
     */
    function init(Args memory _args) external {
        // adding ERC165 data
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        ds.supportedInterfaces[type(IERC165).interfaceId] = true;
        ds.supportedInterfaces[type(IDiamondCut).interfaceId] = true;
        ds.supportedInterfaces[type(IDiamondLoupe).interfaceId] = true;
        ds.supportedInterfaces[type(IERC173).interfaceId] = true;

        LibAccessControl.grantRole(DEFAULT_ADMIN_ROLE, _args.admin);
        LibAccessControl.grantRole(GOVERNANCE_TOKEN_MINTER_ROLE, _args.admin);
        LibAccessControl.grantRole(GOVERNANCE_TOKEN_BURNER_ROLE, _args.admin);
        LibAccessControl.grantRole(HEALTH_PROVIDER_ROLE, _args.admin);
        LibAccessControl.grantRole(PAUSER_ROLE, _args.admin);

        AppStorage storage appStore = LibAppStorage.appStorage();
        appStore.paused = false;
        appStore.treasuryAddress = _args.admin;

        // reentrancy guard
        _initReentrancyGuard();
    }
}

contract Deploy001_Diamond is Script, DiamondTestHelper {
    ERC1967Proxy public proxyTessToken;
    TesseractToken public tessToken;

    // diamond related contracts
    Diamond diamond;
    DiamondInit diamondInit;

    // diamond facet implementation instances (should not be used directly)
    AccessControlFacet accessControlFacetImplementation;
    DiamondCutFacet diamondCutFacetImplementation;
    DiamondLoupeFacet diamondLoupeFacetImplementation;
    ManagerFacet managerFacetImplementation;
    OwnershipFacet ownershipFacetImplementation;
    BondingHelixFacet bondingHelixFacetImplementation;
    HelixFacet helixFacetImplementation;
    MarketPoolFacet marketPoolfacetImplementation;

    // selectors for all of the facets
    bytes4[] selectorsOfAccessControlFacet;
    bytes4[] selectorsOfDiamondCutFacet;
    bytes4[] selectorsOfDiamondLoupeFacet;
    bytes4[] selectorsOfManagerFacet;
    bytes4[] selectorsOfOwnershipFacet;
    bytes4[] selectorsOfBondingHelixFacet;
    bytes4[] selectorsOfHelixFacet;
    bytes4[] selectorsOfMarketPoolFacet;

    function run() public virtual {
        // read env variables
        uint256 adminPrivateKey = vm.envUint("PRIVATE_KEY");
        uint256 ownerPrivateKey = vm.envUint("PRIVATE_KEY");

        address adminAddress = vm.addr(adminPrivateKey);
        address ownerAddress = vm.addr(ownerPrivateKey);

        //===================
        // Deploy Diamond
        //===================

        // start sending owner transactions
        vm.startBroadcast(ownerPrivateKey);

        // set all function selectors
        selectorsOfAccessControlFacet = getSelectorsFromAbi(
            "/out/AccessControlFacet.sol/AccessControlFacet.json"
        );
        selectorsOfDiamondCutFacet = getSelectorsFromAbi(
            "/out/DiamondCutFacet.sol/DiamondCutFacet.json"
        );
        selectorsOfDiamondLoupeFacet = getSelectorsFromAbi(
            "/out/DiamondLoupeFacet.sol/DiamondLoupeFacet.json"
        );
        selectorsOfManagerFacet = getSelectorsFromAbi(
            "/out/ManagerFacet.sol/ManagerFacet.json"
        );
        selectorsOfOwnershipFacet = getSelectorsFromAbi(
            "/out/OwnershipFacet.sol/OwnershipFacet.json"
        );
        selectorsOfBondingHelixFacet = getSelectorsFromAbi(
            "/out/BondingHelixFacet.sol/BondingHelixFacet.json"
        );
        selectorsOfHelixFacet = getSelectorsFromAbi(
            "/out/HelixFacet.sol/HelixFacet.json"
        );
        selectorsOfMarketPoolFacet = getSelectorsFromAbi(
            "/out/MarketPoolFacet.sol/MarketPoolFacet.json"
        );
        

        // deploy facet implementation instances
        accessControlFacetImplementation = new AccessControlFacet();
        diamondCutFacetImplementation = new DiamondCutFacet();
        diamondLoupeFacetImplementation = new DiamondLoupeFacet();
        managerFacetImplementation = new ManagerFacet();
        ownershipFacetImplementation = new OwnershipFacet();
        bondingHelixFacetImplementation = new BondingHelixFacet();
        helixFacetImplementation = new HelixFacet();
        marketPoolfacetImplementation = new MarketPoolFacet();
        
        // prepare DiamondInit args
        diamondInit = new DiamondInit();
        DiamondInit.Args memory diamondInitArgs = DiamondInit.Args({
            admin: adminAddress
        });
        // prepare Diamond arguments
        DiamondArgs memory diamondArgs = DiamondArgs({
            owner: ownerAddress,
            init: address(diamondInit),
            initCalldata: abi.encodeWithSelector(
                DiamondInit.init.selector,
                diamondInitArgs
            )
        });

        // prepare facet cuts
        FacetCut[] memory cuts = new FacetCut[](8);
        cuts[0] = (
            FacetCut({
                facetAddress: address(accessControlFacetImplementation),
                action: FacetCutAction.Add,
                functionSelectors: selectorsOfAccessControlFacet
            })
        );
        cuts[1] = (
            FacetCut({
                facetAddress: address(diamondCutFacetImplementation),
                action: FacetCutAction.Add,
                functionSelectors: selectorsOfDiamondCutFacet
            })
        );
        cuts[2] = (
            FacetCut({
                facetAddress: address(diamondLoupeFacetImplementation),
                action: FacetCutAction.Add,
                functionSelectors: selectorsOfDiamondLoupeFacet
            })
        );
        cuts[3] = (
            FacetCut({
                facetAddress: address(managerFacetImplementation),
                action: FacetCutAction.Add,
                functionSelectors: selectorsOfManagerFacet
            })
        );
        cuts[4] = (
            FacetCut({
                facetAddress: address(ownershipFacetImplementation),
                action: FacetCutAction.Add,
                functionSelectors: selectorsOfOwnershipFacet
            })
        );
        cuts[5] = (
            FacetCut({
                facetAddress: address(bondingHelixFacetImplementation),
                action: FacetCutAction.Add,
                functionSelectors: selectorsOfBondingHelixFacet
            })
        );
        cuts[6] = (
            FacetCut({
                facetAddress: address(helixFacetImplementation),
                action: FacetCutAction.Add,
                functionSelectors: selectorsOfHelixFacet
            })
        );
        cuts[7] = (
            FacetCut({
                facetAddress: address(marketPoolfacetImplementation),
                action: FacetCutAction.Add,
                functionSelectors: selectorsOfMarketPoolFacet
            })
        );

        // deploy diamond
        diamond = new Diamond(diamondArgs, cuts);

        vm.stopBroadcast();

        vm.startBroadcast(adminPrivateKey);

        AccessControlFacet accessControlFacet = AccessControlFacet(
            address(diamond)
        );

        accessControlFacet.grantRole(
            GOVERNANCE_TOKEN_MINTER_ROLE,
            address(diamond)
        );
        accessControlFacet.grantRole(
            GOVERNANCE_TOKEN_BURNER_ROLE,
            address(diamond)
        );

        vm.stopBroadcast();



        vm.startBroadcast(ownerPrivateKey);

        bytes memory initPayload = abi.encodeWithSignature(
            "initialize(address)",
            address(diamond)
        );
        proxyTessToken = new ERC1967Proxy(
            address(new TesseractToken()),
            initPayload
        );

        tessToken = TesseractToken(address(proxyTessToken));

        vm.stopBroadcast();

        vm.startBroadcast(adminPrivateKey);

        ManagerFacet managerFacet = ManagerFacet(address(diamond));
        managerFacet.setTesseractTokenAddress(address(tessToken));
        vm.stopBroadcast();
    }
}