//  SPDX-License-Identifier: GPL 3.0
pragma solidity >0.8.0  ;
contract Coin{
    address immutable public minter;
    mapping(address => uint)  balances;
    event Sent(address from,address to ,uint amount);

    constructor()  {
        minter  = msg.sender;
    }

    function mint(address receiver,uint amount) public{
        require(receiver == minter);
        balances[receiver] += amount;
    }

    function send(address from ,address to , uint amount ) public {
        require(balances[from] > amount);
        balances[from]  -= amount;
        balances[to] += amount;
        emit Sent(from,to,amount);
    }

    function getBalance(address from) public view returns (uint ){
        return balances[from];
    }
}