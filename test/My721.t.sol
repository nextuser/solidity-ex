// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;


import {Test, console} from "forge-std/Test.sol";
import {RMB} from "../src/My721.sol";
import {NftDex} from "./mocks/NftDex.sol";
import {NftNonReceiver} from "./mocks/NftNonReceiver.sol";

contract M721Test is Test {
    RMB public token;
    string name = "Renminbi";
    string symbol = "RMB";
    string uri = "ipfs://tokesn/rmb/";
    address accountA = 0x70997970C51812dc3A010C7d01b50e0d17dc79C8;
    address accountB = 0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC;
    NftDex nftReceiver;
    NftNonReceiver nftNonReceiver;

    function setUp() public {
        token = new RMB(name,symbol,uri);

        console.log("minter",token.minter());
        nftReceiver = new NftDex();
        nftNonReceiver = new NftNonReceiver();
       /// vm.broadcast();

        //vm.prank(token.minter());
        console.log("after broad cast minter",token.minter());
    }


    function testCount() public {
        
         for(uint i = 0 ; i< 18; ++i){
            token.mint();
         }
         assertEq(token.totalSupply(),18);
         assertEq(token.minter(),token.ownerOf(1));

    }

    function testTransfer() public {
        for(uint i = 0 ; i< 18; ++i){
            token.mint();
        }
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
         for(uint i = 0 ; i< 18; ++i){
            token.mint();
        }
        address minter = token.minter();
        assertEq(token.balanceOf(accountA),0);
        assertEq(token.balanceOf(minter),18);

        token.approve(accountA,3);
        token.approve(accountA,4);
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

    function  testTransferContractNonReceiver() public {
         for(uint i = 0 ; i< 18; ++i){
            token.mint();
        }
       
        assertEq(token.balanceOf(token.minter()),18);
        address addr = address(nftNonReceiver);
        assertEq(token.balanceOf(addr),0);

        console.log("address nftNonReceiver",addr);
        vm.expectRevert(bytes("error message"));
        //vm.startPrank(token.minter());
        //token.safeTransferFrom(token.minter(),addr ,17);
        assertTrue(token._checkERC721Receiver(token.minter(),addr,17,""),"error message");
        //vm.stopPrank();
    }



    function  testTransferNftDex() public {
         for(uint i = 0 ; i< 18; ++i){
            token.mint();
        }
       
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