// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {Funding} from "../../src/Funding.sol";
// Import deploy script
import {DeployFunding} from "../../script/DeployFunding.s.sol";

contract FundingTest is Test {
    Funding funding;
    address USER = makeAddr("user");
    uint256 constant STARTING_BALANCE = 100 ether;
    uint256 constant ETH_AMOUNT = 0.1 ether;

    function setUp() external {
        // set a starting balance for USER (fake addy)
        vm.deal(USER, STARTING_BALANCE);
        DeployFunding deployFunding = new DeployFunding();
        funding = deployFunding.run();
    }

    // Modifier for recurrent funding uses
    modifier funded() {
        vm.prank(USER);
        funding.fund{value: ETH_AMOUNT}();
        _;
    }

    function testMinimum() public view {
        assertEq(funding.MINIMUM(), 5e18);
    }

    function testOwnerIsSender() public view {
        // msg.sender is not contract deployer, i.e me. cos me->FundingTest->Funding
        // FundingTest contract is contract deployer
        // So address(this) is the correct owner
        assertEq(funding.getOwner(), msg.sender);
    }

    function testGetVersion() public view {
        // Version is different on sepolia and mainnet
        if (block.chainid == 111555111) {
            uint256 version = funding.getVersion();
            assertEq(version, 4);
        } else if (block.chainid == 1) {
            uint256 version = funding.getVersion();
            assertEq(version, 6);
        }
    }

    function testOutcomeWithInsufficientETH() public {
        vm.expectRevert("Not enough ETH sent");
        funding.fund();
    }

    function testFundingUpdatesStruct() public {
        vm.prank(USER);

        funding.fund{value: ETH_AMOUNT}();
        uint256 fundedAmount = funding.getFundingRecords(USER);
        assertEq(fundedAmount, ETH_AMOUNT);
    }

    function testAddsFunderToFundersList() public {
        vm.prank(USER);

        funding.fund{value: ETH_AMOUNT}();
        address funder = funding.getFunder(0);

        assertEq(funder, USER);
    }

    function testExclusiveOwnerWithdrawal() public funded {
        // vm.prank(USER);
        // console.log("USER", USER);
        // console.log("funding.getOwner()", funding.getOwner());
        // funding.fund{value: ETH_AMOUNT}();

        vm.expectRevert();
        vm.prank(USER);
        funding.withdraw();
    }

    function testSingleUserWithdrawal() public funded {
        uint256 initialFundingBalance = address(funding).balance;
        uint256 initialOwnerBalance = funding.getOwner().balance;

        vm.prank(funding.getOwner());
        funding.withdraw();

        assertEq(address(funding).balance, 0);
        assertEq(
            funding.getOwner().balance,
            initialOwnerBalance + initialFundingBalance
        );
    }

    function testMultipleUsersWithdrawal() public {
        // Arrange
        uint160 totalFunders = 8;
        uint160 startingIndex = 1;

        for (uint160 i = startingIndex; i < totalFunders; i++) {
            hoax(address(i), STARTING_BALANCE);
            funding.fund{value: ETH_AMOUNT}();
        }

        // Act
        uint256 initialFundingBalance = address(funding).balance;
        uint256 initialOwnerBalance = funding.getOwner().balance;

        vm.startPrank(funding.getOwner());
        funding.withdraw();
        vm.stopPrank();

        //assert
        assert(address(funding).balance == 0);
        assert(
            initialFundingBalance + initialOwnerBalance ==
                funding.getOwner().balance
        );
    }
}
