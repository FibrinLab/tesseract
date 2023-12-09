// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {LibMarketPool} from "../libraries/LibMarketPool.sol";
import {Modifiers} from "../libraries/LibAppStorage.sol";

contract MarketPoolFacet is Modifiers {

    function init(uint256 _initialReward, uint256 _decreaseRate) external {
        LibMarketPool.init(_initialReward, _decreaseRate);
    }

    function initialReward() external view returns(uint256) {
        return LibMarketPool.initialReward();
    }

    function decreaseRate() external view returns(uint256) {
        return LibMarketPool.decreaseRate();
    }

    function addPool(address _owner, uint256 _bounty) external returns(uint256) {
        return LibMarketPool.addPool(_owner, _bounty);
    }

    function listNFTdata(address _patient, address _poolAddr) external {
        LibMarketPool.listNFTdata(_patient, _poolAddr);
    }


    function calculateReward(address _poolAddr) external view returns(uint256) {
        return LibMarketPool.calculateReward(_poolAddr);
    }
}
