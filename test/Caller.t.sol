// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;


import {Test, console2 as console} from "forge-std/Test.sol";
import {Caller} from "../src/Caller.sol";
import {Callee} from "../src/Callee.sol";
contract CallerTest is Test {
    Caller public caller;
    Callee public callee;

    function setUp() public {
         vm.startBroadcast();
        caller = new Caller();
        callee = new  Callee();
        vm.stopBroadcast();
        
    }
    function testBalance() public {
        ///console.log(callee);
        uint old = caller.getBalance();
        /// broadcast 之后才能看到callee的地址
        caller.doCall {value:4000}(address(callee),'who are u' , 40,3000);
        /////console.log("***********coin callee **********");
        ///console.log(callee.getBalance());
        assertEq(caller.getBalance(),old + 1_000);
        assertEq(callee.getBalance(),3_000);
    }
}