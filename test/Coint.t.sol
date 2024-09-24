// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;


import {Test, console} from "forge-std/Test.sol";
import {Coin} from "../src/Coin.sol";

contract CoinTest is Test {
    Coin public coin;

    function setUp() public {
        coin = new Coin();
        
        coin.mint(coin.minter(),3000);

        
    }
    function testBalance() public view{
        assertEq(coin.getBalance(coin.minter()),3000);
    }
}