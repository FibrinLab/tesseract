// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";


interface IERC1155Tesseract is IERC1155 {

    function mint(
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) external;

    function mintBatch(
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) external;

    function burn(address account, uint256 id, uint256 value) external;

    function burnBatch(
        address account,
        uint256[] memory ids,
        uint256[] memory values
    ) external;

    function pause() external;

    function unpause() external;

    function totalSupply() external view returns (uint256);

    function exists(uint256 id) external view returns (bool);

    function holderTokens(
        address holder
    ) external view returns (uint256[] memory);
}