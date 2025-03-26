// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

/**
 * Get funds from users
 * Withdraw gotten funds
 * Specify minimum USD funding value
 **/

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import {EthConverter} from "./EthConverter.sol";

// Custom error
// convention, ContractName_errorName
error Funding_Unauthorized();

contract Funding {
    //
    using EthConverter for uint256;

    // Set to constant(gas efficient) because value is known and never chnages
    uint256 public constant MINIMUM = 5e18;

    // Set to immutable(gas efficient) - Never changes once assigned
    address private immutable i_owner;

    AggregatorV3Interface private s_pricefeed;

    // s_ prefix to all storage variables
    // Link address to amount funded
    mapping(address funder => uint256 fundedAmount) private s_fundingRecords;

    address[] private s_fundersList;

    // A constructor to define the owner
    constructor(address pricefeed) {
        s_pricefeed = AggregatorV3Interface(pricefeed);
        i_owner = msg.sender;
    }

    function getVersion() public view returns (uint256) {
        return s_pricefeed.version();
    }

    // Func. to receive and record funding
    function fund() public payable {
        require(
            msg.value.getPriceUsd(s_pricefeed) >= MINIMUM,
            "Not enough ETH sent"
        );

        // Store each funders's address
        s_fundersList.push(msg.sender);

        // Map all donations to addresses
        s_fundingRecords[msg.sender] = s_fundingRecords[msg.sender] + msg.value;
        // OR: s_fundingRecords[msg.sender] += msg.value;
    }

    // Func. to withdraw/clear record of recieved funds
    function withdraw() public ownerOnly {
        // Iterate through funders list and clear recorded funds
        for (uint256 idx = 0; idx < s_fundersList.length; idx++) {
            address funder = s_fundersList[idx];
            s_fundingRecords[funder] = 0;
        }
        // Reset all data in s_fundersList
        s_fundersList = new address[](0);

        // Using "call": recommended method. Returns status (bool) - gas not fixed
        // Destructure returned data to get status
        (
            bool callStatus /*bytes memory returnedData - Not needed here*/,

        ) = payable(msg.sender).call{value: address(this).balance}("");
        require(callStatus, "Withdrawal Failed");
    }

    // Func. modifier to veirfy owner
    // Parentheses are not required when parameters are not used - used here for consistency
    modifier ownerOnly() {
        // Restric withdrawal to only the owner
        // require(msg.sender == i_owner, "Not authorized to withdraw");

        // Used custom error instead - more gas efficient
        if (msg.sender != i_owner) {
            revert Funding_Unauthorized();
        }
        _;
    }

    // Funcs. to handle ether transfers that dont match any function
    receive() external payable {
        // call the fund func. to accept transfers without msg.data
        fund();
    }

    fallback() external payable {
        // call the fund func. to accept transfers with/without msg.data
        fund();
    }

    /**
     * view/pure functions (getters)
     */

    function getFundingRecords(address funder) external view returns (uint256) {
        return s_fundingRecords[funder];
    }

    function getFunder(uint256 index) external view returns (address) {
        return s_fundersList[index];
    }

    function getOwner() external view returns (address) {
        return i_owner;
    }
}

/*
        3 ways to send/withdraw ether:

        1. send
        2. transfer
        3. call
        */

// using "send": Returns status (bool) - 2300 gas max
// Send all balance of current contract to func caller
// bool sendStatus = payable(msg.sender).send(address(this).balance);
// require(sendStatus, "Failed to send");

// Using "transfer": Reverts when failed. 2300 gas max
// transfer all balance of current contract to func caller
// payable(msg.sender).transfer(address(this).balance);
