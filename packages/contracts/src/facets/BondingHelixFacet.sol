// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {LibBondingHelix} from "../libraries/LibBondingHelix.sol";
import {Modifiers} from "../libraries/LibAppStorage.sol";

import {IBondingHelix} from "../interfaces/IBondingHelix.sol";

/**
 * @notice Bonding curve contract based on Bancor formula
 * @notice Inspired from Bancor protocol https://github.com/bancorprotocol/contracts
 * @notice 
 */
contract BondingCurveFacet is Modifiers, IBondingHelix {

    function setParams(
        uint32 _connectorWeight,
        uint256 _baseY
    ) external onlyAdmin {
        LibBondingHelix.setParams(_connectorWeight, _baseY);
    }

    function connectorWeight() external view returns (uint32) {
        return LibBondingHelix.connectorWeight();
    }

    function baseY() external view returns (uint256) {
        return LibBondingHelix.baseY();
    }

    function poolBalance() external view returns (uint256) {
        return LibBondingHelix.poolBalance();
    }

    function deposit(
        uint256 _collateralDeposited,
        address _recipient
    ) external {
        LibBondingHelix.deposit(_collateralDeposited, _recipient);
    }

    function getShare(address _recipient) external view returns (uint256) {
        return LibBondingHelix.getShare(_recipient);
    }

    function withdraw(uint256 _amount) external onlyAdmin whenNotPaused {
        LibBondingHelix.withdraw(_amount);
    }

    function purchaseTargetAmount(
        uint256 _tokensDeposited,
        uint32 _connectorWeight,
        uint256 _supply,
        uint256 _connectorBalance
    ) external pure returns (uint256) {
        return
            LibBondingHelix.purchaseTargetAmount(
                _tokensDeposited,
                _connectorWeight,
                _supply,
                _connectorBalance
            );
    }

    function purchaseTargetAmountFromZero(
        uint256 _tokensDeposited,
        uint256 _connectorWeight,
        uint256 _baseX,
        uint256 _baseY
    ) external pure returns (uint256) {
        return
            LibBondingHelix.purchaseTargetAmountFromZero(
                _tokensDeposited,
                _connectorWeight,
                _baseX,
                _baseY
            );
    }
}