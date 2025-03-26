// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {Funding} from "../../src/Funding.sol";
import {FundingFund, FundingWithdraw} from "../../script/Interactions.s.sol";

// Import deploy script
import {DeployFunding} from "../../script/DeployFunding.s.sol";

contract FundingTestIntegration is Test {
    Funding funding;

    address USER = makeAddr("user");
    uint256 constant STARTING_BALANCE = 100 ether;
    uint256 constant ETH_AMOUNT = 0.1 ether;

    function setUp() external {
        DeployFunding deploy = new DeployFunding();
        funding = deploy.run();

        vm.deal(USER, STARTING_BALANCE);
    }

    function testUserFundingInteractions() public {
        FundingFund fundingFund = new FundingFund();
        // call fundingFund func. on new (instance) deployed fundingFund contract
        fundingFund.fundingFund(address(funding));

        FundingWithdraw fundingWithdraw = new FundingWithdraw();
        fundingWithdraw.fundingWithdraw(address(funding));

        assertEq(address(funding).balance, 0);
    }
}
