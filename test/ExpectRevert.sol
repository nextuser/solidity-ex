pragma solidity ^0.8.10;

import "forge-std/Test.sol";

error Unauthorized();

contract OwnerUpOnly {
    address public immutable owner;
    uint256 public count;

    constructor() {
        owner = msg.sender;
    }

    function checkParams() internal{
        if (msg.sender != owner) {
            revert Unauthorized();
        }
    }
    function increment() external {
        count ++;
        checkParams();
        //count++;
    }
}

contract Callee{
    
    function doNonZero(uint256 v) public {
        require(v != 0, 'zero error');

    }
}

contract OwnerUpOnlyTest is Test {
    OwnerUpOnly upOnly;
    Callee callee;

    function setUp() public {
        upOnly = new OwnerUpOnly();
        callee = new Callee();
    }

    function testIncrementAsOwner() public {
        assertEq(upOnly.count(), 0);
        upOnly.increment();
        assertEq(upOnly.count(), 1);
    }


    function testRevertString() public {
        vm.expectRevert('zero error');
        callee.doNonZero(0);
    }

    
    // Notice that we replaced `testFail` with `test`
    function testIncrementAsNotOwner() public {
        //vm.expectRevert();
        vm.expectRevert(Unauthorized.selector);
        vm.prank(address(0));
        upOnly.increment();
    }
}