

import {Test, console} from "forge-std/Test.sol";
import {StringUtil} from "../src/StringUtil.sol";

contract CoinTest is Test {
    StringUtil public util;

    function setUp() public {
        util = new StringUtil();
       
    }
    function testBalance() public view{
        assertEq(util.toString(77),'77');
    }
}