// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";
import {LibAppStorage} from "./LibAppStorage.sol";
import "../interfaces/IERC1155Tesseract.sol";
import "./Constants.sol";
import "../utils/ABDKMathQuad.sol";

import "chainlink/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "chainlink/v0.8/VRFConsumerBaseV2.sol";

/**
 * @notice Bonding Curve library based on Bancor formula
 * @notice Inspired from Bancor protocol https://github.com/bancorprotocol/contracts
 * @notice 
 */
library LibBondingHelix {
    using SafeERC20 for IERC20;
    using ABDKMathQuad for uint256;
    using ABDKMathQuad for bytes16;

    bytes32 constant BONDING_CONTROL_STORAGE_SLOT =
        bytes32(uint256(keccak256("tesseract.contracts.bonding.storage")) - 1);

    event Deposit(address indexed user, uint256 amount);
    event Withdraw(uint256 amount);
    event ParamsSet(uint32 connectorWeight, uint256 baseY);

    struct BondingHelixData {
        uint32 connectorWeight;
        uint256 baseY;
        uint256 poolBalance;
        uint256 tokenIds;
        mapping(address => uint256) share;
    }

    function bondingHelixStorage()
        internal
        pure
        returns (BondingHelixData storage l)
    {
        bytes32 slot = BONDING_CONTROL_STORAGE_SLOT;
        assembly {
            l.slot := slot
        }
    }

    function setParams(uint32 _connectorWeight, uint256 _baseY) internal {
        require(
            _connectorWeight > 0 && _connectorWeight <= 1000000,
            "invalid values"
        );
        require(_baseY > 0, "must valid baseY");

        bondingHelixStorage().connectorWeight = _connectorWeight;
        bondingHelixStorage().baseY = _baseY;
        emit ParamsSet(_connectorWeight, _baseY);
    }

    function connectorWeight() internal view returns (uint32) {
        return bondingHelixStorage().connectorWeight;
    }

    function baseY() internal view returns (uint256) {
        return bondingHelixStorage().baseY;
    }

    function poolBalance() internal view returns (uint256) {
        return bondingHelixStorage().poolBalance;
    }

    function deposit(
        uint256 _collateralDeposited,
        address _recipient
    ) internal {
        BondingHelixData storage ss = bondingHelixStorage();
        require(ss.connectorWeight != 0 && ss.baseY != 0, "not set");

        uint256 tokensReturned;

        if (ss.tokenIds > 0) {
            tokensReturned = purchaseTargetAmount(
                _collateralDeposited,
                ss.connectorWeight,
                ss.tokenIds,
                ss.poolBalance
            );
        } else {
            tokensReturned = purchaseTargetAmountFromZero(
                _collateralDeposited,
                ss.connectorWeight,
                ACCURACY,
                ss.baseY
            );
        }

        IERC20 tesseract = IERC20(LibAppStorage.appStorage().tesseractTokenAddress);
        tesseract.transferFrom(_recipient, address(this), _collateralDeposited);

        ss.poolBalance = ss.poolBalance + _collateralDeposited;
        bytes memory tokReturned = toBytes(tokensReturned);
        ss.share[_recipient] += tokensReturned;
        ss.tokenIds += 1;

        IERC1155Tesseract bNFT = IERC1155Tesseract(
            LibAppStorage.appStorage().tesseractNFTAddress
        );
        bNFT.mint(_recipient, ss.tokenIds, tokensReturned, tokReturned);

        emit Deposit(_recipient, _collateralDeposited);
    }

    function getShare(address _recipient) internal view returns (uint256) {
        BondingHelixData storage ss = bondingHelixStorage();
        return ss.share[_recipient];
    }

    function toBytes(uint256 x) internal pure returns (bytes memory b) {
        b = new bytes(32);
        assembly {
            mstore(add(b, 32), x)
        }
    }

    function withdraw(uint256 _amount) internal {
        BondingHelixData storage ss = bondingHelixStorage();
        require(_amount <= ss.poolBalance, "invalid amount");

        IERC20 tesseract = IERC20(LibAppStorage.appStorage().tesseractTokenAddress);
        uint256 toTransfer = _amount;
        tesseract.safeTransfer(
            LibAppStorage.appStorage().treasuryAddress,
            toTransfer
        );

        ss.poolBalance -= _amount;

        emit Withdraw(_amount);
    }

    function purchaseTargetAmount(
        uint256 _tokensDeposited,
        uint32 _connectorWeight,
        uint256 _supply,
        uint256 _connectorBalance
    ) internal pure returns (uint256) {
        // validate input
        require(_connectorBalance > 0, "ERR_INVALID_SUPPLY");
        require(
            _connectorWeight > 0 && _connectorWeight <= MAX_WEIGHT,
            "ERR_INVALID_WEIGHT"
        );

        // special case for 0 deposit amount
        if (_tokensDeposited == 0) {
            return 0;
        }
        // special case if the weight = 100%
        if (_connectorWeight == MAX_WEIGHT) {
            return (_supply * _tokensDeposited) / _connectorBalance;
        }

        bytes16 _one = uintToBytes16(ONE);

        bytes16 exponent = uint256(_connectorWeight).fromUInt().div(
            uint256(MAX_WEIGHT).fromUInt()
        );

        bytes16 connBal = _connectorBalance.fromUInt();
        bytes16 temp = _one.add(_tokensDeposited.fromUInt().div(connBal));
        //Instead of calculating "base ^ exp", we calculate "e ^ (log(base) * exp)".
        bytes16 result = _supply.fromUInt().mul(
            (temp.ln().mul(exponent)).exp().sub(_one)
        );
        return result.toUInt();
    }

    function purchaseTargetAmountFromZero(
        uint256 _tokensDeposited,
        uint256 _connectorWeight,
        uint256 _baseX,
        uint256 _baseY
    ) internal pure returns (uint256) {
        // (MAX_WEIGHT/reserveWeight -1)
        bytes16 _one = uintToBytes16(ONE);

        bytes16 exponent = uint256(MAX_WEIGHT)
            .fromUInt()
            .div(_connectorWeight.fromUInt())
            .sub(_one);

        // Instead of calculating "x ^ exp", we calculate "e ^ (log(x) * exp)".
        // _baseY ^ (MAX_WEIGHT/reserveWeight -1)
        bytes16 denominator = (_baseY.fromUInt().ln().mul(exponent)).exp();

        // ( baseX * tokensDeposited  ^ (MAX_WEIGHT/reserveWeight -1) ) /  _baseY ^ (MAX_WEIGHT/reserveWeight -1)
        bytes16 res = _tokensDeposited.fromUInt().ln().mul(exponent).exp();
        bytes16 result = _baseX.fromUInt().mul(res).div(denominator);

        return result.toUInt();
    }

    function uintToBytes16(uint256 x) internal pure returns (bytes16 b) {
        require(
            x <= 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF,
            "Value too large for bytes16"
        );
        b = bytes16(abi.encodePacked(x));
    }
}