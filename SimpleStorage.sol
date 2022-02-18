//SPDX-License-Identifier: MIT
pragma solidity ^0.7;

contract SimpleStorage {

    //will be init to 0
    uint256 public favoriteNumber;

    struct People {
        uint256 favoriteNumber;
        string name;
    }

    People[] public people;
    mapping(string => uint256) public nameToFavoriteNumber;


    function store(uint256 _favoriteNumber) public {
        favoriteNumber = _favoriteNumber;
    }

    //view just looks at stuff on the chain, doesnt change the state
    //pure functions do math/change state (require gas?)
    function retrieve() public view returns(uint256) {
        return favoriteNumber;
    }

    //memory only in execution
    //storage saved always
    function addPerson(string memory _name, uint256 _favoriteNumber) public {
        people.push(People(_favoriteNumber, _name));
        nameToFavoriteNumber[_name] = _favoriteNumber;
    } 

}