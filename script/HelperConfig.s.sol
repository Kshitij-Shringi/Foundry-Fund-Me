// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/Mocks/MockV3Aggregator.s.sol";

struct NetworkConfig {
    address priceFeed;
}

contract HelperConfig is Script {
    NetworkConfig public activeNetworkConfig;

    uint8 public constant ETH_DECIMALS = 8;
    int256 public constant INITIAL_PRICE = 2000e8;

    constructor() {
        if (block.chainid == 11155111) {
            activeNetworkConfig = getSepoliaNetworkConfig();
        } else {
            activeNetworkConfig = getAnvilNetworkConfig();
        }
    }

    function getSepoliaNetworkConfig() public pure returns (NetworkConfig memory) {
        NetworkConfig memory sepoliaPriceFeed = NetworkConfig({priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306});
        return sepoliaPriceFeed;
    }

    function getETHNetworkConfig() public pure returns (NetworkConfig memory) {
        NetworkConfig memory sepoliaPriceFeed = NetworkConfig({priceFeed: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419});
        return sepoliaPriceFeed;
    }

    function getAnvilNetworkConfig() public returns (NetworkConfig memory) {
        // 1.Deploy the mock
        vm.startBroadcast();
        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(ETH_DECIMALS, INITIAL_PRICE);
        vm.stopBroadcast();
        // 2.Return the mock addresses

        NetworkConfig memory anvilConfig = NetworkConfig({priceFeed: address(mockPriceFeed)});
        return anvilConfig;
    }
}
