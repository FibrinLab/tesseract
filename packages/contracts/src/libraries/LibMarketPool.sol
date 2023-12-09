// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";
import {LibAppStorage} from "./LibAppStorage.sol";
import "../interfaces/IERC1155Tesseract.sol";
import "./Constants.sol";


library LibMarketPool {
    using Math for uint256;

    bytes32 constant MARKET_CONTROL_STORAGE_SLOT = 
        bytes32(uint256(keccak256("tesseract.contracts.market.storage")) - 1);

    event Deposit(address indexed user, uint256 amount);
    event Withdraw(uint256 amount);
    event PoolCreated(uint256 poolId, address owner);
    event ParamsSet(uint256 initialReward, uint256 decreaseRate);
    event NFTListed(address patient, address pool);

    struct MarketPool {
        uint256 poolId;
        uint256 totalDeposited;
        bool isActive;
        address[] permit;
        uint256 startTimestamp;
    }

    struct MarketData {
        mapping(uint256 => mapping(address => uint256)) deposits;
        mapping(address => MarketPool) pools;
        uint256 initialReward;
        uint256 decreaseRate;
        uint256 poolId;
    }

    function marketStorage()
        internal
        pure
        returns (MarketData storage l)
    {
        bytes32 slot = MARKET_CONTROL_STORAGE_SLOT;
        assembly {
            l.slot := slot
        }
    }

    function init(uint256 _initialReward, uint256 _decreaseRate) internal {
        require(
            _initialReward > 0 && _initialReward <= 1000, "Tesseract: Invalid Values"
        );
        require(_decreaseRate > 0, "Tesseract: Invalid Values");

        marketStorage().initialReward = _initialReward;
        marketStorage().decreaseRate = _decreaseRate;
        emit ParamsSet(_initialReward, _decreaseRate);
    }

    function initialReward() internal view returns(uint256) {
        return marketStorage().initialReward;
    }

    function decreaseRate() internal view returns(uint256) {
        return marketStorage().decreaseRate;
    }

    function addPool(address _owner, uint256 _bounty) internal returns(uint256) {
        require(_owner != address(0), "Zero Address");

        uint256 id = marketStorage().poolId + 1;

        IERC20 token = IERC20(LibAppStorage.appStorage().tesseractTokenAddress);
        token.transferFrom(_owner, address(this), _bounty);

        marketStorage().pools[_owner] = MarketPool({
            poolId: id,
            totalDeposited: _bounty,
            isActive: false,
            permit: new address[](10),
            startTimestamp: block.timestamp + DAYS
        });


        emit PoolCreated(id, _owner);
        return id;
    }

    function togglePatientData(uint256 _key, address _poolAddr) internal {
        require(block.timestamp > marketStorage().pools[_poolAddr].startTimestamp + DAYS, "Not started yet");
        if (_key == 200) {
            marketStorage().pools[_poolAddr].isActive = true;
        } else (
            marketStorage().pools[_poolAddr].isActive = false
        );
    }

    function listNFTdata(address _patient, address _poolAddr) internal {
        require(_patient != address(0), "Zero Address");
        require(_poolAddr != address(0), "Zero Address");
        require(marketStorage().pools[_poolAddr].isActive == true, "Not active");

        marketStorage().pools[_poolAddr].permit.push(_patient);

        uint256 reward = calculateReward(_poolAddr);

        IERC20 token = IERC20(LibAppStorage.appStorage().tesseractTokenAddress);
        token.transferFrom(address(this), _patient, reward);

        emit NFTListed(_patient, _poolAddr);

    }

    function calculateReward(address _poolAddr) public view returns (uint256) {
        uint256 deposited = marketStorage().pools[_poolAddr].totalDeposited;
        uint256 rate = marketStorage().decreaseRate;
        uint256 initial = marketStorage().decreaseRate;
        uint256 reward = initial - (rate * deposited);
        return reward;
    }
}
