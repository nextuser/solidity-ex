// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

contract Callee{
    string public name  ;
    uint8 public age  ;
    event  Transfer(address indexed from, address indexed to, uint amount ); 
    address owner;

    constructor() payable{
        owner = msg.sender;
    }

    receive() external payable{
        emit Transfer(msg.sender, address(this), msg.value);
    }

    function withdraw(uint256 amount) external {
        payable(owner).transfer(amount);
    }

    modifier onlyOwner(){
        require(owner== msg.sender, "only owner can call");
        _;
    }

    
    function setNameAndAge(string memory name_, uint8 age_ ) payable external  {
        name = name_;
        age = age_;
        if(msg.value > 0 ){
            emit Transfer(msg.sender, address(this), msg.value);
        }
    }


    function   getBalance() external view returns (uint){
        return address(this).balance;
    }


}
