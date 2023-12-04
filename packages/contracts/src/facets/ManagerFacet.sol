// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Modifiers} from "../libraries/LibAppStorage.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "../interfaces/ITesseractToken.sol";
import "../libraries/LibAccessControl.sol";

contract ManagerFacet is Modifiers {

    function setTesseractTokenAddress(
        address _tesseractTokenAddress
    ) external onlyAdmin {
        store.tesseractTokenAddress = _tesseractTokenAddress;
    }

    function setBondingHelixAddress(
        address _bondingHelixAddress
    ) external onlyAdmin {
        store.bondingHelixAddress = _bondingHelixAddress;
    }

    function setBancorFormulaAddress(
        address _bancorFormulaAddress
    ) external onlyAdmin {
        store.bancorFormulaAddress = _bancorFormulaAddress;
    }

    function setTreasuryAddress(address _treasuryAddress) external onlyAdmin {
        store.treasuryAddress = _treasuryAddress;
    }

    function dollarTokenAddress() external view returns (address) {
        return store.tesseractTokenAddress;
    }

    function bondingCurveAddress() external view returns (address) {
        return store.bondingHelixAddress;
    }

    function bancorFormulaAddress() external view returns (address) {
        return store.bancorFormulaAddress;
    }

    function treasuryAddress() external view returns (address) {
        return store.treasuryAddress;
    }

}