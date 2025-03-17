//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
contract HelperConfig{
    NetworkConfig public activeEthConfig;
    struct NetworkConfig{
        address priceFeed;
    }

    constructor(){
        if(block.chainid == 11155111)
            activeEthConfig = getSepoliaEthConfig();
        else activeEthConfig = getAnvilEthConfig();
    }
    function getSepoliaEthConfig() public pure returns (NetworkConfig memory){
        return NetworkConfig(0x694AA1769357215DE4FAC081bf1f309aDC325306);
    }

    function getAnvilEthConfig() public pure returns (NetworkConfig memory){
        return NetworkConfig(0x8A753747A1Fa494EC906cE90E9f37563A8AF630e);

    }
}