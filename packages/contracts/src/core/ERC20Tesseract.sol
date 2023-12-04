// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Pausable.sol";
import {Initializable} from "openzeppelin-contracts-upgradeable/contracts/proxy/utils/Initializable.sol";
import {UUPSUpgradeable} from "openzeppelin-contracts-upgradeable/contracts/proxy/utils/UUPSUpgradeable.sol";
import {ERC20Upgradeable} from "openzeppelin-contracts-upgradeable/contracts/token/ERC20/ERC20Upgradeable.sol";
import {ERC20PermitUpgradeable} from "openzeppelin-contracts-upgradeable/contracts/token/ERC20/extensions/ERC20PermitUpgradeable.sol";
import {ERC20PausableUpgradeable} from "openzeppelin-contracts-upgradeable/contracts/token/ERC20/extensions/ERC20PausableUpgradeable.sol";

import "../interfaces/IAccessControl.sol";
import {IERC20Tesseract} from "../interfaces/IERC20Tesseract.sol";
import "../libraries/Constants.sol";

abstract contract ERC20Tesseract is 
    Initializable,
    UUPSUpgradeable,
    ERC20Upgradeable,
    ERC20PermitUpgradeable,
    ERC20PausableUpgradeable
{

    string private _symbol;

    IAccessControl public accessControl;

    event Burning(address indexed _burned, uint256 _amount);

    event Minting(
        address indexed _to,
        address indexed _minter,
        uint256 _amount
    );

    modifier onlyPauser() {
        require(
            accessControl.hasRole(PAUSER_ROLE, msg.sender),
            "ERC20Tesseract: not pauser"
        );
        _;
    }

    modifier onlyAdmin() {
        require(
            accessControl.hasRole(DEFAULT_ADMIN_ROLE, msg.sender),
            "ERC20Tesseract: not admin"
        );
        _;
    }

    constructor() {
        _disableInitializers();
    }

    function __ERC20Tesseract_init(
        address _manager,
        string memory name_,
        string memory symbol_
    ) internal onlyInitializing {
        __ERC20_init(name_, symbol_);
        __ERC20Permit_init(name_);
        __ERC20Pausable_init();
        __UUPSUpgradeable_init();
        __ERC20Tesseract_init_unchained(_manager, symbol_);
    }

    function __ERC20Tesseract_init_unchained(
        address _manager,
        string memory symbol_
    ) internal onlyInitializing {
        _symbol = symbol_;
        accessControl = IAccessControl(_manager);
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

    function _update(
        address from,
        address to,
        uint256 value
    ) internal virtual override(ERC20Upgradeable, ERC20PausableUpgradeable) {
        super._update(from, to, value);
    }

}