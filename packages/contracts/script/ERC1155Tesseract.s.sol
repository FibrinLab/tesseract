// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "forge-std/Script.sol";
import "../src/core/ERC1155Tesseract.sol";

contract MyScript is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        new ERC1155Tesseract(0x115588402b1a27202a033bFcA6e0bd50f1218E27, "baseUri");

        vm.stopBroadcast();
    }
}
