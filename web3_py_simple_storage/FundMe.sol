//SPDX-License-Identifier: MIT

pragma solidity ^0.8;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract FundMe {
    //ETH -> USD conv rate (chain link data)

    mapping(address => uint256) public addressToAmountFunded;
    address[] public funders;
    address public owner;

    //constructor, gets called once contract deployed
    constructor() {
    owner = msg.sender;
    }

    //payable means can pay for things
    //pass in address 
    function fund() public payable{
        //min $50
        uint256 minimumUSD = 50 * 10**18;
        require(getConversionRate(msg.value) >= minimumUSD, "You need to spend more ETH");
        addressToAmountFunded[msg.sender] += msg.value;
        funders.push(msg.sender);

    }

    function getVersion() public view returns(uint256) {
        AggregatorV3Interface priceFeed = AggregatorV3Interface(0x8A753747A1Fa494EC906cE90E9f37563A8AF630e);
        return priceFeed.version();
    }

    function getPrice() public view returns(uint256) {
        AggregatorV3Interface priceFeed = AggregatorV3Interface(0x8A753747A1Fa494EC906cE90E9f37563A8AF630e);
        (,int price,,,) = priceFeed.latestRoundData();
         return uint256(price * 10000000000);
    }

    //returns USD amt
    function getConversionRate(uint256 ethAmount) public view returns(uint256) {
        uint256 ethPrice = getPrice();
        uint256 ethAmountInUsd = (ethPrice * ethAmount) / 1000000000000000000;
        return ethAmountInUsd;
    }

    // runs this code beforehand the below function
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    //withdraw all the ETH
    //reset the funders
    function withdraw() payable onlyOwner public {
        payable(msg.sender).transfer(address(this).balance);
        for(uint256 i = 0; i < funders.length; i++){
            address funder = funders[i];
            addressToAmountFunded[funder] = 0;
        }
        funders = new address[](0);
    }

}