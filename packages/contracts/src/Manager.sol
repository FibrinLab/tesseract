// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract Manager {

    struct File {
        string fileName;
        string fileType;
        string cid;
    }

    mapping(address => File[]) files;

    function addFile(string[] memory _fileInfo, string memory _cid) public {
        files[msg.sender].push(File(_fileInfo[0], _fileInfo[1], _cid));
    }

    function getFiles(address _account) public view returns(File[] memory) {
        return files[_account];
    }
}
