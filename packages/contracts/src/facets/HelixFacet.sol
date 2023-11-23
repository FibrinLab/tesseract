// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {LibHelix} from "../libraries/LibHelix.sol";
import {Modifiers} from "../libraries/LibAppStorage.sol";

contract HelixFacet is Modifiers {

    function updatePatientData(address _patient, string memory _medicalDataHash) external onlyHealthProvider {
        LibHelix.updatePatientData(_patient, _medicalDataHash);
    } 

    function createPatient(address _patient) external onlyHealthProvider {
        return LibHelix.createPatient(_patient);
    }

    function authorizeProvider(address _patient, address _provider) external {
        LibHelix.authorizeProvider(_patient, _provider);
    }

    function revokeProvider(address _patient, address _provider) external {
        LibHelix.revokeProvider(_patient, _provider);
    }

    function isProviderAuthorized(address _patient, address _provider) external view returns (bool) {
        LibHelix.isProviderAuthorized(_patient, _provider);
    }
}