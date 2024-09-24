// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {StakePool} from "../src/StakePool.sol";
import {MockERC20} from "./mocks/Token.sol";

contract CounterTest is Test {
    StakePool stake;
    MockERC20 token ;
    uint256 constant total = 1e8*1e18;
    function setUp() public {
        stake = new StakePool();

        token = new MockERC20(total,"token",18,"T");
    }

    function testStake(uint256 amount ) public {
        vm.assume(amount < total);
        //uint256 amount = 1e18;
        token.approve(address(stake),amount);
        assertTrue(stake.stake(address(token),amount));

    }
}