// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {IERC165} from "@openzeppelin/contracts/interfaces/IERC165.sol";
import {Diamond, DiamondArgs} from "../../src/Diamond.sol";
import {ERC1155Tesseract} from "../../src/core/ERC1155Tesseract.sol";
import {IDiamondCut} from "../../src/interfaces/IDiamondCut.sol";
import {IDiamondLoupe} from "../../src/interfaces/IDiamondLoupe.sol";
import {IERC173} from "../../src/interfaces/IERC173.sol";
import {AccessControlFacet} from "../../src/facets/AccessControlFacet.sol";
import {BondingHelixFacet} from "../../src/facets/BondingHelixFacet.sol";
import {DiamondCutFacet} from "../../src/facets/DiamondCutFacet.sol";
import {DiamondLoupeFacet} from "../../src/facets/DiamondLoupeFacet.sol";
import {ManagerFacet} from "../../src/facets/ManagerFacet.sol";
import {OwnershipFacet} from "../../src/facets/OwnershipFacet.sol";
import {HelixFacet} from "../../src/facets/HelixFacet.sol";
import {MarketPoolFacet} from "../../src/facets/MarketPoolFacet.sol";
import {DiamondInit} from "../../src/upgradeInitializers/DiamondInit.sol";
import {DiamondTestHelper} from "../helpers/DiamondTestHelper.sol";
import {UUPSTestHelper} from "../helpers/UUPSTestHelper.sol";
import {GOVERNANCE_TOKEN_MINTER_ROLE, GOVERNANCE_TOKEN_BURNER_ROLE, HEALTH_PROVIDER_ROLE, PAUSER_ROLE, MINTER_ROLE, BURNER_ROLE} from "../../src/libraries/Constants.sol";


abstract contract DiamondTestSetup is DiamondTestHelper, UUPSTestHelper {
    // diamond related contracts
    Diamond diamond;
    DiamondInit diamondInit;

    AccessControlFacet accessControlFacet;
    BondingHelixFacet bondingHelixFacet;
    DiamondCutFacet diamondCutFacet;
    DiamondLoupeFacet diamondLoupeFacet;
    ManagerFacet managerFacet;
    OwnershipFacet ownershipFacet;
    HelixFacet helixFacet;
    MarketPoolFacet marketPoolfacet;

    AccessControlFacet accessControlFacetImplementation;
    BondingHelixFacet bondingHelixFacetImplementation;
    DiamondCutFacet diamondCutFacetImplementation;
    DiamondLoupeFacet diamondLoupeFacetImplementation;
    ManagerFacet managerFacetImplementation;
    OwnershipFacet ownershipFacetImplementation;
    HelixFacet helixFacetImplementation;
    MarketPoolFacet marketPoolfacetImplementation;

    // facet names with addresses
    string[] facetNames;
    address[] facetAddressList;

    // helper addresses
    address owner;
    address admin;
    address user1;
    address contract1;
    address contract2;

    // selectors for all of the facets
    bytes4[] selectorsOfAccessControlFacet;
    bytes4[] selectorsOfBondingHelixFacet;
    bytes4[] selectorsOfDiamondCutFacet;
    bytes4[] selectorsOfDiamondLoupeFacet;
    bytes4[] selectorsOfManagerFacet;
    bytes4[] selectorsOfOwnershipFacet;
    bytes4[] selectorsOfHelixFacet;
    bytes4[] selectorsOfMarketPoolFacet;

    /// @notice Deploys diamond and connects facets
    function setUp() public virtual {
        // setup helper addresses
        owner = generateAddress("Owner", false, 10 ether);
        admin = generateAddress("Admin", false, 10 ether);
        user1 = generateAddress("User1", false, 10 ether);
        contract1 = generateAddress("Contract1", true, 10 ether);
        contract2 = generateAddress("Contract2", true, 10 ether);

        // set all function selectors
        selectorsOfAccessControlFacet = getSelectorsFromAbi(
            "/out/AccessControlFacet.sol/AccessControlFacet.json"
        );
        selectorsOfBondingHelixFacet = getSelectorsFromAbi(
            "/out/BondingHelixFacet.sol/BondingHelixFacet.json"
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
        selectorsOfHelixFacet = getSelectorsFromAbi(
            "/out/HelixFacet.sol/HelixFacet.json"
        );
        selectorsOfMarketPoolFacet = getSelectorsFromAbi(
            "/out/MarketPoolFacet.sol/MarketPoolFacet.json"
        );

        // deploy facet implementation instances
        accessControlFacetImplementation = new AccessControlFacet();
        bondingHelixFacetImplementation = new BondingHelixFacet();
        diamondCutFacetImplementation = new DiamondCutFacet();
        diamondLoupeFacetImplementation = new DiamondLoupeFacet();
        managerFacetImplementation = new ManagerFacet();
        ownershipFacetImplementation = new OwnershipFacet();
        helixFacetImplementation = new HelixFacet();
        marketPoolfacetImplementation = new MarketPoolFacet();


        // prepare diamond init args
        diamondInit = new DiamondInit();

        facetNames = [
            "AccessControlFacet",
            "BondingHelixFacet",
            "DiamondCutFacet",
            "DiamondLoupeFacet",
            "ManagerFacet",
            "OwnershipFacet"
        ];

        DiamondInit.Args memory initArgs = DiamondInit.Args({
            admin: admin
        });
        // diamond arguments
        DiamondArgs memory _args = DiamondArgs({
            owner: owner,
            init: address(diamondInit),
            initCalldata: abi.encodeWithSelector(
                DiamondInit.init.selector,
                initArgs
            )
        });

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
                facetAddress: address(bondingHelixFacetImplementation),
                action: FacetCutAction.Add,
                functionSelectors: selectorsOfBondingHelixFacet
            })
        );
        cuts[2] = (
            FacetCut({
                facetAddress: address(diamondCutFacetImplementation),
                action: FacetCutAction.Add,
                functionSelectors: selectorsOfDiamondCutFacet
            })
        );
        cuts[3] = (
            FacetCut({
                facetAddress: address(diamondLoupeFacetImplementation),
                action: FacetCutAction.Add,
                functionSelectors: selectorsOfDiamondLoupeFacet
            })
        );
        cuts[4] = (
            FacetCut({
                facetAddress: address(managerFacetImplementation),
                action: FacetCutAction.Add,
                functionSelectors: selectorsOfManagerFacet
            })
        );
        cuts[5] = (
            FacetCut({
                facetAddress: address(ownershipFacetImplementation),
                action: FacetCutAction.Add,
                functionSelectors: selectorsOfOwnershipFacet
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
        vm.prank(owner);
        diamond = new Diamond(_args, cuts);

        // initialize diamond facets which point to the core diamond contract
        accessControlFacet = AccessControlFacet(address(diamond));
        bondingHelixFacet = BondingHelixFacet(address(diamond));
        diamondCutFacet = DiamondCutFacet(address(diamond));
        diamondLoupeFacet = DiamondLoupeFacet(address(diamond));
        managerFacet = ManagerFacet(address(diamond));
        ownershipFacet = OwnershipFacet(address(diamond));
        helixFacet = HelixFacet(address(diamond));
        managerFacet = ManagerFacet(address(diamond));


        // get all addresses
        facetAddressList = diamondLoupeFacet.facetAddresses();
        vm.startPrank(admin);

        accessControlFacet.grantRole(
            GOVERNANCE_TOKEN_MINTER_ROLE,
            address(diamond)
        );

        accessControlFacet.grantRole(
            GOVERNANCE_TOKEN_BURNER_ROLE,
            address(diamond)
        );

        accessControlFacet.grantRole(
            HEALTH_PROVIDER_ROLE,
            address(diamond)
        );

        accessControlFacet.grantRole(
            PAUSER_ROLE,
            address(diamond)
        );

        accessControlFacet.grantRole(
            MINTER_ROLE,
            address(diamond)
        );

        accessControlFacet.grantRole(
            BURNER_ROLE,
            address(diamond)
        );

        // init UUPS core contracts
        __setupUUPS(address(diamond));
        vm.stopPrank();
    }
}