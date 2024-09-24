//SPDX-License-Identifier:MIT
pragma solidity >0.8.0;
contract StringUtil{
    function getDigits(uint256 temp) public pure returns (uint256 digits){
     
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
    }
 function toString(uint256 value) public pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        uint256 index = digits - 1;
        temp = value;
        while (temp != 0) {
            buffer[index] = bytes1(uint8(48 + temp % 10));
            if(index >0) index --;
            temp /= 10;
        }
        return string(buffer);
    }
    
   function sliceToString( bytes calldata arr , uint start ) pure external returns (string memory){
        return string(arr[start:]);
    }

    //gas 6706
   function toString2(uint256  _num )  public view returns (string memory){
        if(_num == 0) return "0";
        bytes memory arr = new bytes (78); // utin256 max  1.15e77
        uint256 curr = _num;
        uint i ;
        for(  i = arr.length -1 ; i >= 0 && curr > 0 ; -- i){
            arr[i] = bytes1(uint8( curr % 10) + uint8(0x30));// digit + '0'
            curr = curr / 10;
        }
        return this.sliceToString(arr,i + 1);
    }



//3757
   function toString3(uint256  _num )  public pure returns (string memory){
        if(_num == 0) return "0";
        bytes memory arr = new bytes (78); // utin256 max  1.15e77
        uint256 curr = _num;
        uint i ;
        for(  i = arr.length -1 ; i >= 0 && curr > 0 ; -- i){
            arr[i] = bytes1(uint8( curr % 10) + uint8(0x30));// digit + '0'
            curr = curr / 10;
        }
        i += 1;
        bytes memory ret = new bytes(arr.length - i);
        for(uint j = 0 ; j < ret.length; ++ j){
            ret[j] = arr[j + i];
        }
        
        return string(ret);
    }
}