
import {Test, console2 as console} from "forge-std/Test.sol";
import {TransferCount} from "../src/TransferCount.sol";
import {TestTransfer} from "../src/TestTransfer.sol";
contract TransferTest is Test {
    TransferCount public transferCount;
    TestTransfer public testTransfer;

    function setUp() public {
         vm.startBroadcast();
        transferCount = new TransferCount();
        
        vm.stopBroadcast();
        vm.startBroadcast();
        testTransfer = new  TestTransfer(payable(address(transferCount)));
        vm.stopBroadcast();
        
    }
    function testBalance() public {
        testTransfer.sendOut {gas:500000,value:333}(11);


        assertEq(address(testTransfer).balance,322);
        assertEq(address(transferCount).balance,11);
    }
}