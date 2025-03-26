// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {Funding} from "../src/Funding.sol";

import {HelperConfig} from "./HelperConfig.s.sol";

contract DeployFunding is Script {
    function run() external returns (Funding) {
        HelperConfig config = new HelperConfig();

        // Get current chainId
        // Destructure if only struct has multi values

        address chainId = config.activeConfig();

        vm.startBroadcast();
        Funding funding = new Funding(
            chainId
            // 0x694AA1769357215DE4FAC081bf1f309aDC325306
        );
        vm.stopBroadcast();
        return funding;
    }
}
