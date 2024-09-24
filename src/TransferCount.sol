pragma solidity >0.8.0 ;

contract TransferCount {
    uint public fallbackCount = 0;
    uint public receiveCount = 0;
    event Log(string title,address addr,uint value);
    constructor() payable{

    }
    function deposit() payable external{

    }
    receive() external payable {
       emit Log('receive',msg.sender,msg.value);
    }
    fallback() external payable{
        fallbackCount ++;
    }


}