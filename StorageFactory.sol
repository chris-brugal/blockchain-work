//SPDX-License-Identifier: MIT

pragma solidity ^0.7;

import "./SimpleStorage.sol";

contract StorageFactory {

    SimpleStorage[] public simpleStorageArray;

    //creates a simplestorage contract and adds it to array
    function createSimpleStorageContract() public {
        //deploys contract to blockchain and keeps track of them in array
        SimpleStorage simpleStorage = new SimpleStorage();
        simpleStorageArray.push(simpleStorage);
    }

    //updates the fav number in the specified simplestorage contract
    function sfStore(uint256 _simpleStorageIndex, uint256 _simpleStorageNumber) public {
        //to access contract, we need the address and the Application binary interface (ABI)
        return SimpleStorage(address(simpleStorageArray[_simpleStorageIndex])).store(_simpleStorageNumber);
    }

    //retrieves the fav number from a contract
    function sfGet(uint256 _simpleStorageIndex) public view returns (uint256) {
        return SimpleStorage(address(simpleStorageArray[_simpleStorageIndex])).retrieve();
    }

}
