// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    address USER = makeAddr("User");
    FundMe fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
    uint256 constant GAS_PRICE = 1;

    function setUp() external {
        //  Always runs first
        // ALWAYS
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, 10 ether);
    }

    function testMinimumUSDBal() public view {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testOwnerIsMsgSenders() public view {
        // console.log(fundMe.i_owner());
        console.log(msg.sender);
        console.log(address(this));
        assertEq(fundMe.getOwner(), msg.sender);
    }

    function testgetAccurateVersion() public view {
        uint256 version = fundMe.getVersion();
        console.log(fundMe.getVersion());
        assertEq(version, 4);
    }

    function testFundFailsWhenNotEnoughEther() public {
        vm.expectRevert();
        //assert(This transaction reverts)
        fundMe.fund();
    }

    function testFundUpdatesFundDataStructures() public funded {
        console.log(USER);
        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
        assertEq(amountFunded, 10e18);
    }

    function testFundersGettingUpdated() public funded {
        // uint256 len = fundMe.s_funders.length;

        address funder = fundMe.getfunder(0);
        assertEq(funder, USER);
    }

    modifier funded() {
        vm.prank(USER);
        fundMe.fund{value: 10e18}();
        _;
    }

    function testOnlyOwnerCanWithdraw() public funded {
        vm.prank(USER);
        vm.expectRevert();
        fundMe.withdraw();
    }

    function testOnlyOwnerCanWithdrawCheaper() public funded {
        vm.prank(USER);
        vm.expectRevert();
        fundMe.withdraw();
    }

    function testWithdrawWithSingleFunderCheaper() public funded {
        // Arrange
        uint256 ownerStartingBalance = fundMe.getOwner().balance;
        uint256 fundMeStartingBalance = address(fundMe).balance;

        // Act
        uint256 gasStart = gasleft();
        vm.txGasPrice(GAS_PRICE);

        vm.prank(fundMe.getOwner());
        fundMe.cheaperWithdraw();
        uint256 gasEnd = gasleft();
        uint256 gasUsed = (gasStart - gasEnd) * tx.gasprice;
        console.log(gasUsed);

        // Assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 fundMeEndingBalance = address(fundMe).balance;
        assertEq(endingOwnerBalance - ownerStartingBalance, fundMeStartingBalance - fundMeEndingBalance);
    }

    function testWithdrawWithSingleFunder() public funded {
        // Arrange
        uint256 ownerStartingBalance = fundMe.getOwner().balance;
        uint256 fundMeStartingBalance = address(fundMe).balance;

        // Act
        uint256 gasStart = gasleft();
        vm.txGasPrice(GAS_PRICE);

        vm.prank(fundMe.getOwner());
        fundMe.withdraw();
        uint256 gasEnd = gasleft();
        uint256 gasUsed = (gasStart - gasEnd) * tx.gasprice;
        console.log(gasUsed);

        // Assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 fundMeEndingBalance = address(fundMe).balance;
        assertEq(endingOwnerBalance - ownerStartingBalance, fundMeStartingBalance - fundMeEndingBalance);
    }

    function testWithdrawWithMultipleFunder() public funded {
        // Arange
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;
        for (uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
            hoax(address(i), 10 ether);
            fundMe.fund{value: 1 ether}();
        }
        uint256 ownerStartingBalance = fundMe.getOwner().balance;
        uint256 fundMeStartingBalance = address(fundMe).balance;

        // Act
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();
        // Assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 fundMeEndingBalance = address(fundMe).balance;
        assertEq(endingOwnerBalance - ownerStartingBalance, fundMeStartingBalance - fundMeEndingBalance);
    }
}
/**
 * Handwritten letters
 * How did day really go-> show genuine curiosity
 * Physical compassion
 * Remembering the details
 * Ransom surprises
 * Make her treat included
 * Feeling of safety
 *
 */
