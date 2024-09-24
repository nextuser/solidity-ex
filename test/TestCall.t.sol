// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import {Test, console2 as console} from "forge-std/Test.sol";
contract C {
    function showSender() external view  {
        console.log(address(msg.sender), "ContractC sender");
        console.log(address(this),"ContractC.this");
    }    
}

contract B{
    function showSender() external  {
        console.log(address(msg.sender), "ContractB sender");
        console.log(address(this),"ContractB.this");

        C c = new C();
        bytes memory data = abi.encodeWithSignature("showSender()");
        address(c).call(data);
    }    
}


contract A{
    function showSender() external  {
        console.log(address(msg.sender), "ContractA sender");
        console.log(address(this),"ContractA.this");
        B b = new B();
        bytes memory data = abi.encodeWithSignature("showSender()");
        address(b).call(data);
    }    
}


contract TestCall is Test{

    function testCall() external {
        console.log(address(this),"TestCall.this");
        A a = new A();
        a.showSender();
    }
}


