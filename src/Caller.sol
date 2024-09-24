// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

contract Caller{

    address owner;

    constructor() payable{
        owner = msg.sender;
    }

    receive() external payable{
        
    }

    function withdraw(uint256 amount) external {
        payable(owner).transfer(amount);
    }   

    function   getBalance() external view returns (uint){
        return address(this).balance;
    }


    function doCall(address target,string memory name_,uint8 age_,uint256 amount) payable external {
        require(amount < address(this).balance + msg.value,"insufficient amount to docall");
        bytes memory data = abi.encodeWithSignature(
            "setNameAndAge(string,uint8)",name_,age_);
       (bool success,bytes memory retdata) = address(target).call{value:amount}(data);
       require(success,'call failed');
       retdata = retdata;
    }
}