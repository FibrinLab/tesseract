// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "@openzeppelin/contracts/utils/Strings.sol";


library LibHelix {

    bytes32 constant HELIX_CONTROL_STORAGE_SLOT =
        bytes32(uint256(keccak256("tesseract.contracts.helix.storage")) - 1);

    struct Patient {
        string[] medicalDataHash;
        address[] authorizedProviders;
        uint256 nextUpdateTimestamp;
        bool isActive;
    }

    event PatientCreated(address indexed patient, uint256 timestamp);
    event PatientDataUpdated(address indexed patient, string dataHash, uint256 timestamp);
    event ProviderAuthorized(address indexed patient, address indexed provider);
    event ProviderRevoked(address indexed patient, address indexed provider);

    struct HelixData {

        mapping(address => Patient) patients;
    }

    function helixStorage() internal pure returns (HelixData storage l) {
        bytes32 slot = HELIX_CONTROL_STORAGE_SLOT;
        assembly {
            l.slot := slot
        }
    }

    function updatePatientData(address _patient, string memory _medicalDataHash) internal {
        
        require(bytes(_medicalDataHash).length > 0, "Invalid data hash");
        require(block.timestamp >= helixStorage().patients[_patient].nextUpdateTimestamp, "Update rate limit exceeded");
        require(helixStorage().patients[_patient].isActive, "Inactive Patient");

        helixStorage().patients[_patient].medicalDataHash.push(_medicalDataHash);
        helixStorage().patients[_patient].nextUpdateTimestamp = block.timestamp + 1 days;

        emit PatientDataUpdated(_patient, _medicalDataHash, block.timestamp);
    }

    function createPatient(address _patient) internal {
        require(_patient != address(0), "Invalid provider address");
        require(helixStorage().patients[_patient].isActive != true, "Inactive Patient");

        helixStorage().patients[_patient].isActive = true;

        string memory placeholder = createUniqueString();
        helixStorage().patients[_patient].medicalDataHash.push(placeholder);

        emit PatientCreated(_patient, block.timestamp);
    }

    function authorizeProvider(address _patient, address _provider) internal {

        require(_provider != address(0), "Invalid provider address");

        helixStorage().patients[_patient].authorizedProviders.push(_provider);

        emit ProviderAuthorized(_patient, _provider);

    }

    function revokeProvider(address _patient, address _provider) external {
        require(_provider != address(0), "Invalid provider address");

        uint256 index = findProviderIndex(_patient, _provider);
        require(index < helixStorage().patients[_patient].authorizedProviders.length, "Provider not authorized");

        removeProviderFromList(index, _patient);
    }

    function findProviderIndex(address _patient, address _provider) internal view returns (uint256) {
        for (uint256 i = 0; i < helixStorage().patients[_patient].authorizedProviders.length; i++) {
            if (helixStorage().patients[_patient].authorizedProviders[i] == _provider) {
                return i;
            }
        }

        return helixStorage().patients[_patient].authorizedProviders.length;
    }

    function removeProviderFromList(uint256 index, address _patient) internal {

        uint256 lastIndex = helixStorage().patients[_patient].authorizedProviders.length - 1;
        helixStorage().patients[_patient].authorizedProviders[index] = helixStorage().patients[_patient].authorizedProviders[lastIndex];
        
        helixStorage().patients[_patient].authorizedProviders.pop();
    }

    function isProviderAuthorized(address _patient, address _provider) internal view returns (bool) {
        require(_patient != address(0), "Invalid patient address");
        require(_provider != address(0), "Invalid provider address");

        address[] memory authorizedProviders = helixStorage().patients[_patient].authorizedProviders;

        for (uint256 i = 0; i < authorizedProviders.length; i++) {
            if (authorizedProviders[i] == _provider) {
                return true;
            }
        }

        return false;
    }

    function createUniqueString() internal view returns (string memory) {
        return string(abi.encodePacked(
            "Timestamp:", uintToString(block.timestamp),
            "_BlockNumber:", uintToString(block.number),
            "_Sender:", addressToString(msg.sender),
            "_Contract:", addressToString(address(this))
        ));
    }

    function uintToString(uint _value) internal pure returns (string memory) {
       return Strings.toString(_value);
    }

    function addressToString(address _addr) internal pure returns(string memory) {
        return Strings.toHexString(uint256(uint160(_addr)), 20);
    }

}