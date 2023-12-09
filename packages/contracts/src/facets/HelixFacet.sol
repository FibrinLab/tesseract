// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {LibHelix} from "../libraries/LibHelix.sol";
import {Modifiers} from "../libraries/LibAppStorage.sol";

contract HelixFacet is Modifiers {

    function createPatient(address _patient) external onlyHealthProvider {
        return LibHelix.createPatient(_patient);
    }

    function updatePatientData(address _patient, string memory _medicalDataHash) external onlyHealthProvider {
        LibHelix.updatePatientData(_patient, _medicalDataHash);
    } 

    function togglePatientData(address _patient, uint256 _key) external view {
        LibHelix.togglePatientData(_patient, _key);
    }

    function getPatientStatus(address _patient) internal view returns(bool) {
        return LibHelix.getPatientStatus(_patient);
    }

    function authorizeProvider(address _patient, address _provider) external {
        LibHelix.authorizeProvider(_patient, _provider);
    }

    function revokeProvider(address _patient, address _provider) external {
        LibHelix.revokeProvider(_patient, _provider);
    }

    function findProviderIndex(address _patient, address _provider) external view returns (uint256) {
        return LibHelix.findProviderIndex(_patient, _provider);
    }

    function removeProviderFromList(uint256 _index, address _patient) external {
        LibHelix.removeProviderFromList(_index, _patient);
    }

    function isProviderAuthorized(address _patient, address _provider) external view returns (bool) {
        return LibHelix.isProviderAuthorized(_patient, _provider);
    }

    function createUniqueString() external view returns (string memory) {
        return LibHelix.createUniqueString();
    }

    function uintToString(uint _value) external pure returns (string memory) {
       return LibHelix.uintToString(_value);
    }

    function addressToString(address _addr) external pure returns(string memory) {
        return LibHelix.addressToString(_addr);
    }

    function stringToUint(string memory str) external pure returns (uint256) {
        return LibHelix.stringToUint(str);
    }
}