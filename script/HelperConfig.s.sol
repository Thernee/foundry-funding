// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";

contract HelperConfig is Script {
    // Use named constants to avoid  magic numbers
    uint8 public constant DECIMALS = 8;
    int256 public constant INITIAL_ANSWER = 2000e18;

    // Struct to store network config
    struct NetworkConfig {
        address pricefeed;
    }

    NetworkConfig public activeConfig;

    constructor() {
        if (block.chainid == 111555111) {
            activeConfig = getSepoliaConfig();
        } else if (block.chainid == 1) {
            activeConfig = getMainnetConfig();
        } else {
            activeConfig = getAnvilConfig();
        }
    }

    // function to get sepolia network config
    function getSepoliaConfig() public pure returns (NetworkConfig memory) {
        NetworkConfig memory sepoliaConfig = NetworkConfig({
            pricefeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306
        });

        return sepoliaConfig;
    }

    // Function to get ETH mainnet network config
    function getMainnetConfig() public pure returns (NetworkConfig memory) {
        NetworkConfig memory mainnetConfig = NetworkConfig({
            pricefeed: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419
        });

        return mainnetConfig;
    }

    function getAnvilConfig() public returns (NetworkConfig memory) {
        // Check if pricefeed is already set
        if (activeConfig.pricefeed != address(0)) {
            return activeConfig;
        }

        vm.startBroadcast();
        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(
            DECIMALS,
            INITIAL_ANSWER
        );
        vm.stopBroadcast();

        NetworkConfig memory anvilConfig = NetworkConfig({
            pricefeed: address(mockPriceFeed)
        });

        return anvilConfig;
    }
}
