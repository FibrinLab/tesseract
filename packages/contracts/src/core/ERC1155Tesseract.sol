// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Pausable.sol";

import "../interfaces/IAccessControl.sol";
import "../libraries/Constants.sol";
import "../utils/SafeAddArray.sol";

contract ERC1155Tesseract is ERC1155, ERC1155Burnable, ERC1155Pausable {
    using SafeAddArray for uint256[];

    IAccessControl public accessControl;
    address public minter;

    mapping(address => uint256[]) public holderBalances;
    mapping(uint256 => mapping(address => bool)) public accessRights;

    uint256 public totalSupply;

    modifier onlyMinter() virtual {
        require(
            accessControl.hasRole(GOVERNANCE_TOKEN_MINTER_ROLE, msg.sender),
            "ERC1155Tesseract: not minter"
        );
        _;
    }

    modifier onlyBurner() virtual {
        require(
            accessControl.hasRole(GOVERNANCE_TOKEN_BURNER_ROLE, msg.sender),
            "ERC1155Tesseract: not burner"
        );
        _;
    }

    modifier onlyPauser() virtual {
        require(
            accessControl.hasRole(PAUSER_ROLE, msg.sender),
            "ERC1155Tesseract: not pauser"
        );
        _;
    }

    modifier onlyAdmin() {
        require(
            accessControl.hasRole(DEFAULT_ADMIN_ROLE, msg.sender),
            "ERC1155Tesseract: not admin"
        );
        _;
    }

    constructor(address _manager, string memory uri) ERC1155(uri) {
        accessControl = IAccessControl(_manager);
    }

    function getManager() external view returns(address) {
        return address(accessControl);
    }

    function setManager(address _manager) external onlyAdmin {
        accessControl = IAccessControl(_manager);
    }

    function setUri(string memory newURI) external onlyAdmin {
        _setURI(newURI);
    }

    function mint(
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) public virtual onlyMinter {
        _mint(to, id, amount, data);
        totalSupply += amount;
        holderBalances[to].add(id);
    }

    function mintBatch(
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) public virtual onlyMinter whenNotPaused {
        _mintBatch(to, ids, amounts, data);
        uint256 localTotalSupply = totalSupply;
        for (uint256 i = 0; i < ids.length; ++i) {
            localTotalSupply += amounts[i];
        }
        totalSupply = localTotalSupply;
        holderBalances[to].add(ids);
    }

    function pause() public virtual onlyPauser {
        _pause();
    }

    function unpause() public virtual onlyPauser {
        _unpause();
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) public virtual override {
        require(from == msg.sender || isApprovedForAll(from, msg.sender), "ERC1155: caller is not owner nor approved");
        require(checkAccess(id, from), "No access rights to transfer");

        // Instead of transferring ownership, grant access rights to the recipient
        grantAccess(id, to);
    }


    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) public virtual override {
        super.safeBatchTransferFrom(from, to, ids, amounts, data);
        holderBalances[to].add(ids);
    }

    function holderTokens(
        address holder
    ) public view returns (uint256[] memory) {
        return holderBalances[holder];
    }

    function _update(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory values
    ) internal virtual override(ERC1155, ERC1155Pausable) {
        super._update(from, to, ids, values);
    }

    function setMinter(address minter_) public {
        minter = minter_;
    }

    function mintMedicalData(address to, uint256 id, uint256 amount) external onlyAdmin() {
        _mint(to, id, amount, "");
    }

    function grantAccess(uint256 id, address user) public {
        accessRights[id][user] = true;
    }

    function revokeAccess(uint256 id, address user) public {
        accessRights[id][user] = false;
    }

    function checkAccess(uint256 id, address user) public view returns (bool) {
        return accessRights[id][user];
    }
}