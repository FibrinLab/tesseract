// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import { LibDiamond } from "../libraries/LibDiamond.sol";
import { IDiamondLoupe } from "../interfaces/IDiamondLoupe.sol";
import { IDiamondCut } from "../interfaces/IDiamondCut.sol";
import { IERC173 } from "../interfaces/IERC173.sol";
import "../libraries/LibAccessControl.sol";
import "../libraries/LibAppStorage.sol";
import "@openzeppelin/contracts/interfaces/IERC165.sol";

// It is expected that this contract is customized if you want to deploy your diamond
// with data from a deployment script. Use the init function to initialize state variables
// of your diamond. Add parameters to the init funciton if you need to.

// Adding parameters to the `init` or other functions you add here can make a single deployed
// DiamondInit contract reusable accross upgrades, and can be used for multiple diamonds.

contract DiamondInit is Modifiers {    

    struct Args {
        address admin;
    }

    // You can add parameters to this function in order to pass in 
    // data to set your own state variables
    function init(Args memory _args) external {
        // adding ERC165 data
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        ds.supportedInterfaces[type(IERC165).interfaceId] = true;
        ds.supportedInterfaces[type(IDiamondCut).interfaceId] = true;
        ds.supportedInterfaces[type(IDiamondLoupe).interfaceId] = true;
        ds.supportedInterfaces[type(IERC173).interfaceId] = true;

        LibAccessControl.grantRole(DEFAULT_ADMIN_ROLE, _args.admin);
        LibAccessControl.grantRole(GOVERNANCE_TOKEN_MINTER_ROLE, _args.admin);
        LibAccessControl.grantRole(GOVERNANCE_TOKEN_BURNER_ROLE, _args.admin);
        LibAccessControl.grantRole(HEALTH_PROVIDER_ROLE, _args.admin);
        LibAccessControl.grantRole(PAUSER_ROLE, _args.admin);
        LibAccessControl.grantRole(MINTER_ROLE, _args.admin);
        LibAccessControl.grantRole(BURNER_ROLE, _args.admin);

        // add your own state variables 
        // EIP-2535 specifies that the `diamondCut` function takes two optional 
        // arguments: address _init and bytes calldata _calldata
        // These arguments are used to execute an arbitrary function using delegatecall
        // in order to set state variables in the diamond during deployment or an upgrade
        // More info here: https://eips.ethereum.org/EIPS/eip-2535#diamond-interface 

        AppStorage storage appStore = LibAppStorage.appStorage();

        appStore.paused = false;
        appStore.treasuryAddress = _args.admin;

        // reentrancy guard
        _initReentrancyGuard();

    }
}