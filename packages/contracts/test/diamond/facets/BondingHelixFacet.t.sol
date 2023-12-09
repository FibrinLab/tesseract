// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "../DiamondTestSetup.sol";
import "../../../src/libraries/Constants.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";
import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {MockERC20} from "../../../src/mocks/MockERC20.sol";
import {ERC1155Tesseract} from "../../../src/core/ERC1155Tesseract.sol";
import "forge-std/Test.sol";

contract BondingHelixFacetTest is DiamondTestSetup {
    address treasury = address(0x3);
    address secondAccount = address(0x4);
    address thirdAccount = address(0x5);
    address fourthAccount = address(0x6);
    address fifthAccount = address(0x7);

    uint256 constant _ACCURACY = 10e18;
    uint32 constant _MAX_WEIGHT = 1e6;
    bytes32 constant _ONE = keccak256(abi.encodePacked(uint256(1)));

    mapping(address => uint256) public share;

    event Deposit(address indexed user, uint256 amount);
    event Withdraw(uint256 amount);
    event ParamsSet(uint32 connectorWeight, uint256 baseY);

    function setUp() public virtual override {
        super.setUp();

        vm.startPrank(admin);

        accessControlFacet.grantRole(
            GOVERNANCE_TOKEN_MINTER_ROLE,
            address(diamond)
        );

        // deploy UbiquiStick
        ERC1155Tesseract tNFT = new ERC1155Tesseract(admin, "Tesseract");
        tNFT.setMinter(address(diamond));
        managerFacet.setTesseractNFTAddress(address(tNFT));

        vm.stopPrank();
    }
}

contract ZeroStateBonding is BondingHelixFacetTest {
    using Math for uint256;
    using stdStorage for StdStorage;

    function testSetParams(uint32 connectorWeight, uint256 baseY) public {
        uint256 connWeight;
        connectorWeight = uint32(bound(connWeight, 1, 1000000));
        baseY = bound(baseY, 1, 1000000);

        vm.expectEmit(true, false, false, true);
        emit ParamsSet(connectorWeight, baseY);

        vm.prank(admin);
        bondingHelixFacet.setParams(connectorWeight, baseY);

        assertEq(connectorWeight, bondingHelixFacet.connectorWeight());
        assertEq(baseY, bondingHelixFacet.baseY());
    }

    function testSetParamsShouldRevertNotAdmin() public {
        uint32 connWeight;
        uint256 base;
        uint32 connectorWeight = uint32(bound(connWeight, 1, 1000000));
        uint256 baseY = bound(base, 1, 1000000);

        vm.expectRevert("Manager: Caller is not admin");
        vm.prank(secondAccount);
        bondingHelixFacet.setParams(connectorWeight, baseY);
    }

    function testDeposit(uint32 connectorWeight, uint256 baseY) public {
        uint256 collateralDeposited;
        uint256 connWeight;
        connectorWeight = uint32(bound(connWeight, 1, 1000000));
        baseY = bound(baseY, 1, 1000000);

        vm.prank(admin);
        bondingHelixFacet.setParams(connectorWeight, baseY);

        uint256 initBal = tesseractToken.balanceOf(secondAccount);

        vm.expectEmit(true, false, false, true);
        emit Deposit(secondAccount, collateralDeposited);
        bondingHelixFacet.deposit(collateralDeposited, secondAccount);

        uint256 finBal = tesseractToken.balanceOf(secondAccount);

        uint256 tokReturned = bondingHelixFacet.purchaseTargetAmountFromZero(
            collateralDeposited,
            connectorWeight,
            ACCURACY,
            baseY
        );

        // Logic Test
        uint256 baseN = collateralDeposited + baseY;
        uint256 power = (baseN * (10 ** 18)) / (baseY);
        uint256 result = ACCURACY * (((power ** (connectorWeight)) - 10 ** 18))
            / (10 ** 18);

        assertEq(collateralDeposited, bondingHelixFacet.poolBalance());
        assertEq(collateralDeposited, finBal - initBal);
        assertEq(tokReturned, result);
    }
}