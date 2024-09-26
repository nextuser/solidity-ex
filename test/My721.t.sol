// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;


import {Test, console} from "forge-std/Test.sol";
import {ContractAddressNotERC721Receiver,My721} from "../src/My721.sol";
import {NftDex} from "./mocks/NftDex.sol";
import {NftNonReceiver} from "./mocks/NftNonReceiver.sol";
import {IERC721} from "@openzeppelin/contracts/interfaces/IERC721.sol";

error InvalidToAddress();
contract My721Test is Test {
    My721 public token;
    string name = "Renminbi";
    string symbol = "RMB";
    string uri = "ipfs://tokesn/rmb/";
    address accountA = 0x70997970C51812dc3A010C7d01b50e0d17dc79C8;
    address accountB = 0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC;
    NftDex nftReceiver;
    NftNonReceiver nftNonReceiver;

    function setUp() public {
        token = new My721(name,symbol,uri);

        console.log("minter",token.minter());

        vm.startBroadcast();
        nftReceiver = new NftDex();
        nftNonReceiver = new NftNonReceiver();

        console.log("after broad cast minter",token.minter());
        vm.stopBroadcast();
    }


    function testCount() public {
        
         mintTokens(18);
         assertEq(token.totalSupply(),18);
         assertEq(token.minter(),token.ownerOf(1));

    }

    function testTransfer() public {
        mintTokens(18);
        assertEq(token.balanceOf(accountA),0);
        assertEq(token.balanceOf(token.minter()),18);

        token.safeTransferFrom(token.minter(),accountA,3);
        token.safeTransferFrom(token.minter(),accountA,4);
        assertEq(token.balanceOf(token.minter()),16);
        assertEq(token.balanceOf(accountA),2);

        token.safeTransferFrom(token.minter(),accountB,5);
        token.safeTransferFrom(token.minter(),accountB,6);
        token.safeTransferFrom(token.minter(),accountB,7);
        token.safeTransferFrom(token.minter(),accountB,9);
        token.safeTransferFrom(token.minter(),accountB,8);
        assertEq(token.balanceOf(token.minter()),11);
        assertEq(token.balanceOf(accountB),5);

    }

    function testApprove() public{
        mintTokens(18);
        address minter = token.minter();
        assertEq(token.balanceOf(accountA),0);
        assertEq(token.balanceOf(minter),18);
        vm.expectEmit(true,true,true,false);
        emit IERC721.Approval(token.minter(),accountA,3);
        token.approve(accountA,3);
        vm.expectEmit(true,true,true,false);
        emit IERC721.Approval(token.minter(),accountA,4);
        token.approve(accountA,4);
        vm.expectEmit(true,true,true,false);
        emit IERC721.Approval(token.minter(),accountA,6);
        token.approve(accountA,6);
        assertEq(token.ownerOf(3),minter);
        assertEq(token.getApproved(3),accountA);
        assertEq(token.getApproved(4),accountA);
        assertEq(token.getApproved(6),accountA);

        vm.startPrank(accountA);
        token.safeTransferFrom(token.minter(),accountB,3);
        token.safeTransferFrom(token.minter(),accountB,6);

        assertEq(token.getApproved(3),address(0));
        assertEq(token.getApproved(4),accountA);
        assertEq(token.getApproved(6),address(0));

        assertEq(token.balanceOf(accountB),2);
        assertEq(token.balanceOf(accountA),0);
        vm.stopPrank();
              
    }

    function mintTokens(uint256 n) internal {
         for(uint256 i = 0 ; i< n; ++ i){
            token.mint();
        }
    }

    function  testTransferContractNonReceiver() public {
        mintTokens(18);
        assertEq(token.balanceOf(token.minter()),18);
        address addr = address(nftNonReceiver);
        assertEq(token.balanceOf(addr),0);

        console.log("address nftNonReceiver",addr);
        

        vm.expectRevert("NonReceiver");
        /**revert InvalidToAddress();
        bool ret = token._checkERC721Receiver(token.minter(),addr,17,"");
        console.log("token._check return:" , ret);
        if(!ret){
            revert InvalidToAddress();
        }*/
        token.safeTransferFrom(token.minter(),addr ,17);

    }

    /**
    function testLowLevelCallRevert() public {
        vm.expectRevert(bytes("error message"));
        (bool revertsAsExpected, ) = accountA.call("");
        assertTrue(revertsAsExpected, "expectRevert: call did not revert");
    }*/

    function testApproveAll() public {
        mintTokens(18);
        assertFalse(token.isApprovedForAll(token.minter(),accountB));
        vm.expectEmit(true,true,false,false);
        emit IERC721.ApprovalForAll(token.minter(),accountB,true);
        token.setApprovalForAll(accountB, true);
        assertTrue(token.isApprovedForAll(token.minter(),accountB));


        vm.startPrank(accountB);
        vm.expectEmit(true,true,true,false);
        emit IERC721.Transfer(token.minter(), accountA, 3);
        token.safeTransferFrom(token.minter(), accountA, 3);
        vm.expectEmit(true,true,true,false);
        emit IERC721.Transfer(token.minter(), accountA, 4);
        token.safeTransferFrom(token.minter(), accountA, 4);
        assertEq(token.balanceOf(accountA),2);
        assertEq(token.ownerOf(3),accountA);
        assertEq(token.ownerOf(4),accountA);
        
        vm.stopPrank();
    }

    function  testTransferNftDex() public {
        mintTokens(18);
       
        assertEq(token.balanceOf(token.minter()),18);
        address dex = address(nftReceiver);
        assertEq(token.balanceOf(dex),0);

        console.log("address dex",dex);
        token.safeTransferFrom(token.minter(),dex ,17);
        token.safeTransferFrom(token.minter(),dex ,0);
        assertEq(token.balanceOf(dex),2);
    }

 

    function testMeta() public view {
        assertEq(token.name() ,name);
        assertEq(token.symbol(),symbol);
        assertEq(token.tokenURI(12), "ipfs://tokesn/rmb/12");
    }


}