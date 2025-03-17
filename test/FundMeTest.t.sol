//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";

contract FundMeTest is Test{
    FundMe fundMe;
    DeployFundMe deployFundMe;
    function setUp() external{
        //fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
    }
    function testMinimumDollarIsFive() view public{
        uint256 expected = 5 * 10 ** 18;
        uint256 actual = fundMe.MINIMUM_USD();
        assertEq(actual, expected, "Minimum USD is not 5");
    }

    function testOwnerIsDeployer() view public{
        address expected = msg.sender;
        address actual = fundMe.i_owner();
        console.log(address(this));
        assertEq(actual, expected, "Owner is not the deployer");
    }

    function testPriceFeedVersion() view public{
        uint256 expected = 4;
        uint256 actual = fundMe.getVersion();
        assertEq(actual, expected, "Price feed version is not 0");
    }
}