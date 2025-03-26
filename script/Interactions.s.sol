// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script, console} from "forge-std/Script.sol";
import {DevOpsTools} from "../lib/foundry-devops/src/DevOpsTools.sol";
import {Funding} from "../src/Funding.sol";

contract FundingFund is Script {
    uint256 constant ETH_AMOUNT = 0.1 ether;

    function fundingFund(address lastDeployed) public {
        vm.startBroadcast();
        Funding(payable(lastDeployed)).fund{value: ETH_AMOUNT}();
        vm.stopBroadcast();
        console.log("Funded contract with %s ETH", ETH_AMOUNT);
    }

    function run() external {
        address lastDeployed = DevOpsTools.get_most_recent_deployment(
            "Funding",
            block.chainid
        );
        vm.startBroadcast();
        fundingFund(lastDeployed);
        vm.stopBroadcast();
    }
}

contract FundingWithdraw is Script {
    uint256 constant ETH_AMOUNT = 0.1 ether;

    function fundingWithdraw(address lastDeployed) public {
        vm.startBroadcast();
        Funding(payable(lastDeployed)).withdraw();
        vm.stopBroadcast();
    }

    function run() external {
        address lastDeployed = DevOpsTools.get_most_recent_deployment(
            "Funding",
            block.chainid
        );
        fundingWithdraw(lastDeployed);
    }
}
