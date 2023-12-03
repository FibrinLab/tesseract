// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Pausable.sol";
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

import "../interfaces/IAccessControl.sol";
import {IERC20Tesseract} from "../interfaces/IERC20Tesseract.sol";
import "../libraries/Constants.sol";

abstract contract ERC20Tesseract is ERC20Permit, ERC20Pausable, IERC20Tesseract {

    string private _symbol;

    IAccessControl public accessControl;

    modifier onlyPauser() {
        require(
            accessControl.hasRole(PAUSER_ROLE, msg.sender),
            "ERC20Ubiquity: not pauser"
        );
        _;
    }

    modifier onlyAdmin() {
        require(
            accessControl.hasRole(DEFAULT_ADMIN_ROLE, msg.sender),
            "ERC20Ubiquity: not admin"
        );
        _;
    }

    constructor(
        address _manager,
        string memory name_,
        string memory symbol_
    ) ERC20(name_, symbol_) ERC20Permit(name_) {
        _symbol = symbol_;
        accessControl = IAccessControl(_manager);
    }

    function __ERC20Ubiquity_init(
        address _manager,
        string memory name_,
        string memory symbol_
    ) internal onlyInitializing {
        // init base contracts
        __ERC20_init(name_, symbol_);
        __ERC20Permit_init(name_);
        __ERC20Pausable_init();
        __UUPSUpgradeable_init();
        // init the current contract
        __ERC20Ubiquity_init_unchained(_manager, symbol_);
    }

    function setSymbol(string memory newSymbol) external onlyAdmin {
        _symbol = newSymbol;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function getManager() external view returns (address) {
        return address(accessControl);
    }

    function setManager(address _manager) external onlyAdmin {
        accessControl = IAccessControl(_manager);
    }

    function pause() public onlyPauser {
        _pause();
    }

    function unpause() public onlyPauser {
        _unpause();
    }

    function burn(uint256 amount) public virtual whenNotPaused {
        _burn(_msgSender(), amount);
        emit Burning(msg.sender, amount);
    }

    function burnFrom(address account, uint256 amount) public virtual;

    function nonces(address owner) public view override(IERC20Permit, ERC20Permit) returns (uint256) {
        return super.nonces(owner);
    }

    function _update(
        address from,
        address to,
        uint256 value
    ) internal virtual override(ERC20, ERC20Pausable) {
        super._update(from, to, value);
    }

}