// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Pausable.sol";
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

    function nonces(address owner) public view override(ERC20Permit, IERC20Permit) {
        super.nonces(owner);
    }

    function _update(
        address from,
        address to,
        uint256 value
    ) internal virtual override(ERC20, ERC20Pausable) {
        super._update(from, to, value);
    }

}