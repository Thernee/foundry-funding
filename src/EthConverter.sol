// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

// Creating a custom library for Eth Price conversion

// Import AggregatorV3Interface interface
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

// Library to get and convert ETH price
library EthConverter {
    // Get current, real-world ETH price in terms of wei
    function getETHPrice(
        AggregatorV3Interface pricefeed
    ) internal view returns (uint256) {
        // ETH/Sepolia address: 0x694AA1769357215DE4FAC081bf1f309aDC325306
        // AggregatorV3Interface datafeed = AggregatorV3Interface(pricefeed);

        // Destructure and get only price from the returned data
        // Price is returned with 8 decimals
        (, int256 price, , , ) = pricefeed.latestRoundData();

        // Add 10 decimals to standardize (ETH in wei) the price to 18 decimal places (8 + 10)
        return uint256(price * 1e10);
    }

    // Get ETH price in USD
    function getPriceUsd(
        uint256 ethAmount,
        AggregatorV3Interface pricefeed
    ) internal view returns (uint256) {
        uint256 ethPrice = getETHPrice(pricefeed);
        //     AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306)
        // );
        ethAmount = ethAmount * 1e18;
        uint256 priceUsd = (ethAmount * ethPrice) / 1e18;
        return priceUsd;
    }

    function getVersion() internal view returns (uint256) {
        return
            AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306)
                .version();
    }
}
