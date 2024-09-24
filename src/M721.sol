// https://eips.ethereum.org/EIPS/eip-721 
// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.9.0;

import {IERC721} from "@openzeppelin/contracts/interfaces/IERC721.sol";
import {IERC165} from "@openzeppelin/contracts/interfaces/IERC165.sol";
import {IERC721Metadata} from "@openzeppelin/contracts/interfaces/IERC721Metadata.sol";
import {IERC721Receiver} from "@openzeppelin/contracts/interfaces/IERC721Receiver.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";



/// @title ERC-721 Non-Fungible Token Standard
/// @dev See https://eips.ethereum.org/EIPS/eip-721
///  Note: the ERC-165 identifier for this interface is 0x80ac58cd.
contract  M721 is IERC165 ,IERC721,IERC721Metadata {
    
    //owner => tokenCont
    mapping(address => uint256) balances;
    //tokenId => owners
    mapping(uint256 => address) owners;

    //tokenId => approver 
    mapping(uint256 => address) approvers;
    using Strings for uint256;

    string _name;
    string _symbol;
    string _baseURI;
    address _creator;

    //owner => { spender => aproved? }
    mapping(address => mapping(address=> bool))  allApproved;

    bytes4 constant RECEIVER_SELECTOR = bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"));

    /// @notice Count all NFTs assigned to an owner
    /// @dev NFTs assigned to the zero address are considered invalid, and this
    ///  function throws for queries about the zero address.
    /// @param owner_ An address for whom to query the balance
    /// @return The number of NFTs owned by `_owner`, possibly zero
    function balanceOf(address owner_) external view returns (uint256){
        return balances[owner_];
    }

    constructor(string memory name_, string memory symbol_, string memory baseURI_) {
        _name = name_;
        _symbol = symbol_;
        _baseURI = baseURI_;
        _creator = msg.sender;
    }

    function mint(uint256 tokenId) external {
        require(_creator == msg.sender,"msg sender is not the contract creator");
        require(owners[tokenId] == address(0),"token is minted");
        owners[tokenId] = msg.sender;
        balances[msg.sender] += 1;
    }
        /**
     * @dev Returns the token collection name.
     */
    function name() external view returns (string memory){
        return _name;
    }

    /**
     * @dev Returns the token collection symbol.
     */
    function symbol() external view returns (string memory){
        return _symbol;
    }

    /**
     * @dev Returns the Uniform Resource Identifier (URI) for `tokenId` token.
     */
    function tokenURI(uint256 tokenId) external view returns (string memory){
        return string.concat(_baseURI,tokenId.toString());
    }


    /// @notice Find the owner of an NFT
    /// @dev NFTs assigned to zero address are considered invalid, and queries
    ///  about them do throw.
    /// @param _tokenId The identifier for an NFT
    /// @return The address of the owner of the NFT
    function ownerOf(uint256 _tokenId) external view returns (address){
        return owners[_tokenId];
    }

    /// @notice Transfers the ownership of an NFT from one address to another address
    /// @dev Throws unless `msg.sender` is the current owner, an authorized
    ///  operator, or the approved address for this NFT. Throws if `_from` is
    ///  not the current owner. Throws if `_to` is the zero address. Throws if
    ///  `_tokenId` is not a valid NFT. When transfer is complete, this function
    ///  checks if `_to` is a smart contract (code size > 0). If so, it calls
    ///  `onERC721Received` on `_to` and throws if the return value is not
    ///  `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`.
    /// @param _from The current owner of the NFT
    /// @param _to The new owner
    /// @param _tokenId The NFT to transfer
    /// @param data Additional data with no specified format, sent in call to `_to`
    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes memory data) external {
         _safeTransferFrom(_from,_to,_tokenId,data);
    }


    function _safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes memory data) internal {
        if(_to.code.length > 0){
            bytes4 selector = IERC721Receiver(_to).onERC721Received(_from,_to,_tokenId,data);
            require(selector == RECEIVER_SELECTOR,"onERC721Received implements not ok ");
 
        }

         _transferFrom(_from,_to,_tokenId);
    }



    /// @notice Transfers the ownership of an NFT from one address to another address
    /// @dev This works identically to the other function with an extra data parameter,
    ///  except this function just sets data to "".
    /// @param _from The current owner of the NFT
    /// @param _to The new owner
    /// @param _tokenId The NFT to transfer
    function safeTransferFrom(address _from, address _to, uint256 _tokenId) external {

        _safeTransferFrom(_from,_to,_tokenId,bytes(""));
    }

    /// @notice Transfer ownership of an NFT -- THE CALLER IS RESPONSIBLE
    ///  TO CONFIRM THAT `_to` IS CAPABLE OF RECEIVING NFTS OR ELSE
    ///  THEY MAY BE PERMANENTLY LOST
    /// @dev Throws unless `msg.sender` is the current owner, an authorized
    ///  operator, or the approved address for this NFT. Throws if `_from` is
    ///  not the current owner. Throws if `_to` is the zero address. Throws if
    ///  `_tokenId` is not a valid NFT.
    /// @param _from The current owner of the NFT
    /// @param _to The new owner
    /// @param _tokenId The NFT to transfer
    function transferFrom(address _from, address _to, uint256 _tokenId) external {

        _transferFrom(_from,_to,_tokenId);
    }

    function _transferFrom(address _from, address _to, uint256 _tokenId) internal {

        require(msg.sender == _from || approvers[_tokenId] == msg.sender ||  allApproved[_from][msg.sender] ,
            "msg.sender have no right to transfer");
       
        require(owners[_tokenId]  == _from,"_from is not the owner of tokenId");
        delete approvers[_tokenId]; 

        
        owners[_tokenId] = _to;
        balances[_from ] -= 1;
        balances[_to] += 1;

        emit Transfer(_from,_to,_tokenId);
    }


    /// @notice Change or reaffirm the approved address for an NFT
    /// @dev The zero address indicates there is no approved address.
    ///  Throws unless `msg.sender` is the current NFT owner, or an authorized
    ///  operator of the current owner.
    /// @param _operator The new approved NFT controller
    /// @param _tokenId The NFT to approve
    function approve(address _operator, uint256 _tokenId) external {
        require(owners[_tokenId] == msg.sender, "Only owner can approve");
        if(approvers[_tokenId] == _operator || allApproved[msg.sender][_operator] ){
                revert(" tokenId is approved yet");
        }

        approvers[_tokenId] = _operator;
        emit Approval(msg.sender, _operator,  _tokenId);
    }

    /// @notice Enable or disable approval for a third party ("operator") to manage
    ///  all of `msg.sender` assets
    /// @dev Emits the ApprovalForAll event. The contract MUST allow
    ///  multiple operators per owner.
    /// @param _operator Address to add to the set of authorized operators
    /// @param _approved True if the operator is approved, false to revoke approval
    function setApprovalForAll(address _operator, bool _approved) external{
         if(allApproved[msg.sender][_operator] == _approved ){
            revert(" tokenId is all approved yet");
        }
        allApproved[msg.sender][_operator] = _approved;
        emit ApprovalForAll( msg.sender, _operator,  _approved);
    }

    /// @notice Get the approved address for a single NFT
    /// @dev Throws if `_tokenId` is not a valid NFT.
    /// @param _tokenId The NFT to find the approved address for
    /// @return The approved address for this NFT, or the zero address if there is none
    function getApproved(uint256 _tokenId) external view returns (address){
        return approvers[_tokenId];
    }

    /// @notice Query if an address is an authorized operator for another address
    /// @param _owner The address that owns the NFTs
    /// @param _operator The address that acts on behalf of the owner
    /// @return True if `_operator` is an approved operator for `_owner`, false otherwise
    function isApprovedForAll(address _owner, address _operator) external view returns (bool){
        return allApproved[_owner][_operator];
    }

    /// @notice Query if a contract implements an interface
    /// @param interfaceID The interface identifier, as specified in ERC-165
    /// @dev Interface identification is specified in ERC-165. This function
    ///  uses less than 30,000 gas.
    /// @return `true` if the contract implements `interfaceID` and
    ///  `interfaceID` is not 0xffffffff, `false` otherwise
    function supportsInterface(bytes4 interfaceID) external pure returns (bool){
        return type(IERC721).interfaceId == interfaceID || type(IERC721Metadata).interfaceId == interfaceID;
    }
}

