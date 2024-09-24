// SPDX-License-Identifier: MIT
pragma solidity >0.8.0;
contract Callee{
    uint public value;
    constructor(uint256 _value){
        value = _value;
    }

    function increase() public {
        value += 1;
    }
}

contract CalleeNoArg{
    uint public value;
    constructor(){
        
    }

    function increase() public {
        value += 1;
    }
}

contract TestCreate{
    address public addr1  ;
    address public addr2  ;
    address public addr3 ;

    event Deployed(address addr);

   //create 创建的合约，每次创建，地址会发生变化
   function doCreate(uint256 _arg) public {
        addr1 = address(new Callee(_arg));
        emit Deployed(addr1);
   }

    //判断合约是否已经创建/部署
    function  isContractCreated(uint256 _salt,uint256 _arg) public view  returns (bool,address){
       address addr = getCreate2Address(_salt,_arg);
       uint s;
       assembly{
        s := extcodesize(addr) 
       }
       return (s > 0,addr);
    }

   // 确保合约创建
   function getCallee(uint256 _salt,uint256 _arg) public returns (address ){
        (bool succ,address addr)= isContractCreated(_salt, _arg);
        if(succ){
            return addr;
        }
        return doCreate2(_salt,_arg);     
   }

//新版本create2 ，只要携带salt参数，不容易出错。
   function  doCreate2(uint256 _salt,uint256 _arg) public returns (address) {

        addr2 = address(new Callee{salt:bytes32(_salt)}(_arg));
        emit Deployed(addr2);
        return addr2;
    }

    //计算create2 的合约地址， 此时合约未必已经创建。
    function getCreate2Address( uint256 _salt, uint256 _arg) public view returns (address) {
        bytes memory bytecode = abi.encodePacked(type(Callee).creationCode, abi.encode(_arg));
        bytes32 hash = keccak256(abi.encodePacked(bytes1(0xff), address(this), _salt, keccak256(bytecode)));
        return address(uint160(uint256(hash)));
    }

    


    // 获取不带参数合约的create2 构建地址
    function getCreateNoArg(uint256 _salt) public view returns (address ) {
        bytes memory initcode =  abi.encodePacked(type(CalleeNoArg).creationCode);
        bytes32 hash = keccak256(abi.encodePacked(bytes1(0xff), 
                                                address(this), 
                                                bytes32(_salt), 
                                                keccak256(initcode)));
       return  address( uint160(uint256(hash)));//lower 160bits 20bytes,remove higher 12bytes
    }

    //判断不带参数合约的create2 构建地址是否已经创建
    function  isNoArgContractCreated(uint256 _salt) public view  returns (bool){
       address addr = getCreateNoArg(_salt);
       uint s;
       assembly{
        s := extcodesize(addr) 
       }
       return s > 0;
    }


  /// 老版本使用这种汇编的方式调用create2 创建合约   
  function create2_Old(uint256 _salt, uint256 _arg) public returns (address) {
    // 合约的字节码
    bytes memory bytecode = abi.encodePacked(
      type(Callee).creationCode,
      abi.encode(_arg)  //初始化参数
    );
    bytes32 salt = bytes32(_salt);
    address addr;
    assembly {
      // 使用 CREATE2 操作码部署合约  ，第一个参数是 value = 0,不转ether
      addr := create2(0, add(bytecode, 0x20), mload(bytecode), salt)
      // 检查合约是否部署成功
      if iszero(extcodesize(addr)) {
        revert(0, 0)
      }
     
    }
    emit Deployed(addr);
    return addr;
 }   
}

