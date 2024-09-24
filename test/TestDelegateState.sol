// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;
import {Test, console2 as console} from "forge-std/Test.sol";
// NOTE: Deploy this contract first
contract Old {
    // NOTE: storage layout must be the same as contract A
    uint public num;

    uint public value;
    address public sender;
 
    function setVars(uint _num) public payable {
        num = _num;
        sender = msg.sender;
        value = msg.value;
    }

    function getState() public returns (address _sender,uint _value, uint _num )  {
        _sender = sender;
        _num = num;
        _value = value;
    }
}
 
contract New1 {
    uint public num;
    uint public value;
    address public sender;




    constructor(uint num_){
        num = num_;
    }


    function setVars(address _contract, uint _num) public payable {
        // A's storage is set, B is not modified.
        (bool success, bytes memory data) = _contract.delegatecall(
            abi.encodeWithSignature("setVars(uint256)", _num)
        );
    }
    function getVars(address _contract) external returns (address , uint ,uint  ){
        (bool success, bytes memory data) = _contract.delegatecall(
            abi.encodeWithSignature("getState()")
        );
        if(success){
            return   abi.decode(data,(address,uint,uint));
        }
    } 
}
 
contract New2 {
    uint public num;
    uint public value;
    address public sender;
    constructor(uint num_){
        num = num_;
    }

    function setVars(address _contract, uint _num) public payable {
        // A's storage is set, B is not modified.
        (bool success, bytes memory data) = _contract.call(
            abi.encodeWithSignature("setVars(uint256)", _num)
        );
    }

    function getVars(address _contract) external returns (address , uint ,uint  ){
        (bool success, bytes memory data) = _contract.delegatecall(
            abi.encodeWithSignature("getState()")
        );
        if(success){
            return   abi.decode(data,(address,uint,uint));
        }
    } 
}
 
contract New3 {
    uint public otherNum;//这个变量布局的位置,导致delegateCall old.setVaer时修改了这变量
    uint public value1;
    uint public sender1;

    constructor(uint num_){
        otherNum = num_;
    }

    function setVars(address _contract, uint _num) public payable {
        // A's storage is set, B is not modified.
        (bool success, bytes memory data) = _contract.delegatecall(
            abi.encodeWithSignature("setVars(uint256)", _num)
        );
    }

    function getVars(address _contract) external returns (address , uint ,uint  ){
        (bool success, bytes memory data) = _contract.delegatecall(
            abi.encodeWithSignature("getState()")
        );
        if(success){
            return   abi.decode(data,(address,uint,uint));
        }
    } 
}

contract StateTest is Test {
    Old o;
    New1 n1;
    New2 n2;
    New3 n3;
    function setUp() public {
        o = new Old();
        n1 = new New1(1);
        n2 = new New2(2);
        n3 = new New3(3);
    }

    function testState() public {
        uint v1 = 4;
        uint v2 = 5;
        uint v3 = 6;
        address sender;
        uint value ;
        uint num;
        console.log('*********testState begin**********');

        n1.setVars(address(o), v1);
        (sender,value,num) = n1.getVars(address(o));
        console.log('n1 delegate calll record in n1');
        console.log(num,"n1.o.num");
        console.log(n1.num(),"n1.num");       

        n2.setVars(address(o),v2);
        console.log('n2 calll record in o');
        (sender,value,num) = n2.getVars(address(o));
        console.log(num,"n2.o.num");
        console.log(n2.num(),"n2.num");  

        n3.setVars(address(o), v3);
        console.log('n3 delegate calll record in n3');
        (sender,value,num) = n3.getVars(address(o));
        console.log(num,"n3.o.num");
        (sender,value,num) = n1.getVars(address(o));
        console.log(num,"n1.o.num");
        (sender,value,num) = o.getState();
        console.log(num,"o.num"); 
        console.log(n3.otherNum(),"n3.otherNum");  
   }
}