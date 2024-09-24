// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import {Test, console2 as console} from "forge-std/Test.sol";
contract CallSelf {
    function callMe() external view
    {
        console.log(address(msg.sender), "msg.sender in CallSelf.Callme ");
    }
    function showSender() external view  {
        console.log(address(this),"CallSelf.this");        
        console.log(address(msg.sender), "msg.sender in CallSelf.showSender ");
        this.callMe();
    }    
}

contract ThisCallTest is Test{
    function testCall() external {
        console.log(address(this),"ThisCallTest.this");
         console.log("ThisCallTest.testCall => CallSelf.showSender");
        CallSelf a = new CallSelf();
        a.showSender();
    }
}


