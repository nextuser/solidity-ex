// SPDX-License-Identifier: GPL-3.0
pragma solidity >0.8.0 ;

contract TestTransfer{

    uint public fallbackCount = 0;
    uint public receiveCount = 0;
    address  public  tc;
    constructor(address payable addr) payable {
        tc = addr;

    }

    function sendOut(uint amount ) payable external{
        require(amount  <= address(this).balance, "insufficient balance");
        payable(tc).transfer(amount);
    }

    receive() external payable {
       // receiveCount ++;
    }
    fallback() external payable{
        fallbackCount ++;
    }
}