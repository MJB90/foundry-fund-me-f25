//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;
    DeployFundMe deployFundMe;

    address USER = makeAddr("USER");
    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant STARTING_BALANCE = 100e18;

    function setUp() external {
        //fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, STARTING_BALANCE);
    }

    function testMinimumDollarIsFive() public view {
        uint256 expected = 5 * 10 ** 18;
        uint256 actual = fundMe.MINIMUM_USD();
        assertEq(actual, expected, "Minimum USD is not 5");
    }

    function testOwnerIsDeployer() public view {
        address expected = msg.sender;
        address actual = fundMe.getOwner();
        console.log(address(this));
        assertEq(actual, expected, "Owner is not the deployer");
    }

    function testPriceFeedVersion() public view {
        uint256 expected = 4;
        uint256 actual = fundMe.getVersion();
        assertEq(actual, expected, "Price feed version is not 0");
    }

    function testFundFailsWithoutEnoughEth() public {
        vm.expectRevert();
        fundMe.fund();
    }

    function testFundUpdatesFundedDataStructure() public {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        uint256 expected = SEND_VALUE;
        uint256 actual = fundMe.getAddressToAmountFunded(USER);
        assertEq(actual, expected, "Funded amount is not 10");
    }

    function testAddsFunderToArrayOfFunders() public {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        address funder = fundMe.getFunder(0);
        assertEq(funder, USER, "Funder is not USER");
    }

    modifier funded() {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        _;
    }

    function testOwnerCanWithdraw() public funded {
        vm.expectRevert();
        vm.prank(USER);
        fundMe.withdraw();
        console.log("Owner", fundMe.getOwner());
        console.log("USER", USER);
    }

    function testWithdrawWithASingleFunder() public funded {
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 statingFundMeBalance = address(fundMe).balance;
        console.log("Starting Owner Balance", startingOwnerBalance);
        console.log("Starting FundMe Balance", statingFundMeBalance);

        vm.prank(fundMe.getOwner());

        fundMe.withdraw();

        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;

        console.log("Ending Owner Balance", endingOwnerBalance);
        console.log("Ending FundMe Balance", endingFundMeBalance);

        assertEq(endingFundMeBalance, 0);
        assertEq(endingOwnerBalance, startingOwnerBalance + statingFundMeBalance);
    }

    function testWithdrawWithASingleFunderCheaper() public funded {
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 statingFundMeBalance = address(fundMe).balance;
        console.log("Starting Owner Balance", startingOwnerBalance);
        console.log("Starting FundMe Balance", statingFundMeBalance);

        vm.prank(fundMe.getOwner());

        fundMe.cheaperWithdraw();

        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;

        console.log("Ending Owner Balance", endingOwnerBalance);
        console.log("Ending FundMe Balance", endingFundMeBalance);

        assertEq(endingFundMeBalance, 0);
        assertEq(endingOwnerBalance, startingOwnerBalance + statingFundMeBalance);
    }

    function testWithdrawFromMultipleFunders() public {
        uint160 numberOfFunders = 10;
        uint160 startingFundIndex = 1;
        for (uint160 i = startingFundIndex; i <= numberOfFunders; i++) {
            hoax(address(i), SEND_VALUE);
            fundMe.fund{value: SEND_VALUE}();
        }

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 statingFundMeBalance = address(fundMe).balance;

        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();

        assertEq(address(fundMe).balance, 0);
        assertEq(fundMe.getOwner().balance, startingOwnerBalance + statingFundMeBalance);
    }
}
