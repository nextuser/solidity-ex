pragma solidity >0.8.0;
import {console,Test} from "forge-std/Test.sol" ;
import {Vm} from "forge-std/Vm.sol";
contract VmTest is Test{
     event LogCompleted(
       uint256 indexed topic1,
       bytes data
     );
    function testLogs() public{
        vm.recordLogs();

        emit LogCompleted(10, "operation completed");

        Vm.Log[] memory entries = vm.getRecordedLogs();

        assertEq(entries.length, 1);
        assertEq(entries[0].topics[0], keccak256("LogCompleted(uint256,bytes)"));
        assertEq(entries[0].topics[1], bytes32(uint256(10)));
        assertEq(abi.decode(entries[0].data, (string)), "operation completed");
    }

    function testTimestamp() public{
        vm.warp(1640000000);
        assertEq(block.timestamp,1640000000);
        emit log_uint(block.timestamp);
    }

   function testBlockNumber() public{
    vm.roll(100);
    emit log_uint(block.number);
    assertEq(block.number,100);
   }

   function testBasefee() public{
     vm.fee(25 gwei);
     emit log_uint(block.basefee);
     assertEq(block.basefee,25 gwei);
   } 

   function testDifficulty() public {
    vm.prevrandao(5000);
    emit log_uint(block.prevrandao);
   }

   function testBalance() public {
    address alice = makeAddr("alice");
    vm.deal(alice,1 ether);
    assertEq(alice.balance,1 ether);
    emit log_uint(alice.balance);
   }

    function testNonce() public {
        address alice = makeAddr("alice");
        vm.setNonce(alice,123);
        assertEq(vm.getNonce(alice),123);
        emit log_uint(vm.getNonce(alice));
   }

    function testCoinbase() public {
        address alice = makeAddr("alice");
        vm.coinbase(alice);
        assertEq(alice,block.coinbase);
        
   }

   function testGasPrice() public {
        vm.txGasPrice(2);
        assertEq(tx.gasprice,2);
        vm.txGasPrice(3);
        assertEq(tx.gasprice,3);
   }
}