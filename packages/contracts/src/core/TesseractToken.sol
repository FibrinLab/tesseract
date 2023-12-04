// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import { ERC20Tesseract } from "./ERC20Tesseract.sol";
import "../libraries/Constants.sol";

contract TesseractToken is ERC20Tesseract {

    constructor() {
        _disableInitializers();
    }

    function initialize(address _manager) public initializer {
        __ERC20Tesseract_init(_manager, "Tesseract", "TESS");
    }

    modifier onlyMinter() {
        require(
            accessControl.hasRole(MINTER_ROLE, msg.sender),
            "ERC20Tesseract: not pauser"
        );
        _;
    }

    modifier onlyBurner() {
        require(
            accessControl.hasRole(BURNER_ROLE, msg.sender),
            "ERC20Tesseract: not pauser"
        );
        _;
    }

    function burnFrom(
        address account,
        uint256 amount
    ) public override onlyBurner whenNotPaused {
        _burn(account, amount);
        emit Burning(account, amount);
    }

    function mint(
        address to,
        uint256 amount
    ) public onlyMinter whenNotPaused {
        _mint(to, amount);
        emit Minting(to, _msgSender(), amount);
    }

    function _authorizeUpgrade(
        address newImplementation
    ) internal override onlyAdmin {}

}