// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import {IERC721} from "@openzeppelin/contracts/interfaces/IERC721.sol";
import {IERC165} from "@openzeppelin/contracts/interfaces/IERC165.sol";
import {IERC721Metadata} from "@openzeppelin/contracts/interfaces/IERC721Metadata.sol";
import {IERC721Receiver} from "@openzeppelin/contracts/interfaces/IERC721Receiver.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
import {IERC721Enumerable} from "@openzeppelin/contracts/interfaces/IERC721Enumerable.sol";
import { console} from "forge-std/Test.sol";
using Strings for uint256;
contract My721 is 

    IERC165,IERC721,
    IERC721Metadata,IERC721Enumerable{
    bytes4 constant _receiverSelector = bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"));

    string _name;
    string _symbol;
    string _baseURI;
    address public minter;
    uint256 [] _tokens;
    mapping(uint256 => address) tokenOwner;
    mapping(uint256 => address ) tokenSpender;
    mapping(address => uint256[]) ownerTokens;
    // holder => ( spender => [tokenId] )
    mapping(address=>mapping(address=>bool))  allowances;

    error  ContractAddressNotERC721Receiver();
    

    error SenderIsNotOwnerError(address sender);

    constructor(string memory name_,string memory  symbol_, 
                string memory baseURI_){
        
        _name = name_;
        _symbol = symbol_;
        _baseURI = baseURI_;
        minter = msg.sender;
    }

    modifier onlyCreator() {
        if(msg.sender != minter){
            revert  SenderIsNotOwnerError(msg.sender);
        }
        _;
    }

    function mint() onlyCreator external returns (uint256) {
        uint256 tokenId = _tokens.length;
        require(tokenOwner[tokenId] == address(0), "tokenId exists");
        tokenOwner[tokenId] = msg.sender;
        ownerTokens[msg.sender].push(tokenId);
        _tokens.push(tokenId);
        return tokenId;
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
        return string.concat(_baseURI,Strings.toString(tokenId));
    }

    function supportsInterface(bytes4 interfaceId) public pure   returns (bool){
        return interfaceId == type(IERC165).interfaceId 
                || interfaceId == type(IERC721Metadata).interfaceId
                || interfaceId == type(IERC721).interfaceId 
                || interfaceId == type(IERC721Enumerable).interfaceId ;
    }

    event Received(address indexed from,address indexed to,uint256 tokenId, bytes   data);

    /**function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external  returns (bytes4){
        emit Received(from,operator,tokenId,data);
        return _receiverSelector;
    }**/



    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance){
        return ownerTokens[owner].length;
    }

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner){
        return tokenOwner[tokenId];
    }

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon
     *   a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external{

        if(!_checkERC721Receiver(from,to,tokenId,data)){
            console.log("check fail, call revert ContractAddressNotERC721Receiver");
            revert ContractAddressNotERC721Receiver();
        }
        console.log("begin transfer");
        _transferFrom(from,to,tokenId);        
    }

    function isEOA(address to) public view returns (bool ret){

        assembly {
            ret := iszero(extcodesize(to))
        }

    }


    function _checkERC721Receiver(address from,address to,uint tokenId, bytes memory data) public  returns (bool){
       if(isEOA(to)){
            console.log("is EOA");
            return true;
       } 
       console.log("before onERC721Received");
       bytes4 retSelector = IERC721Receiver(to).onERC721Received(to,from,tokenId,data);
       console.log('onERC721Received',uint256(uint32(retSelector)).toString(),
                    uint256(uint32(IERC721Receiver.onERC721Received.selector)).toString());
       return retSelector == IERC721Receiver.onERC721Received.selector;
    }

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must have been allowed to move this token by either {approve} or
     *   {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon
     *   a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId) external{
        bool ret = _checkERC721Receiver(from,to,tokenId,bytes(""));
        if(!ret) {
            console.log("check fail, call revert ContractAddressNotERC721Receiver");
            revert ContractAddressNotERC721Receiver();
        }
        
        
        _transferFrom(from,to,tokenId);   
    }

    error NotOwnerOfTokenError(uint256 tokenId,address from);

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Note that the caller is responsible to confirm that the recipient is capable of receiving ERC721
     * or else they may be permanently lost. Usage of {safeTransferFrom} prevents loss, though the caller must
     * understand this adds an external call which potentially creates a reentrancy vulnerability.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 tokenId) external {
        _transferFrom(from,to,tokenId);
    }

     
    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Note that the caller is responsible to confirm that the recipient is capable of receiving ERC721
     * or else they may be permanently lost. Usage of {safeTransferFrom} prevents loss, though the caller must
     * understand this adds an external call which potentially creates a reentrancy vulnerability.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function _transferFrom(address from, address to, uint256 tokenId) internal {
        require(from != address(0) && to != address(0),"unsupport zero address");
        address owner = tokenOwner[tokenId];
        require(owner == from,"tokenId owner is not equal from address" );
        bool isOwner = msg.sender == owner;
        bool isSpender = false;

        if(!isOwner){
            isSpender = tokenSpender[tokenId] == msg.sender || allowances[from][msg.sender];
        }
        
        if(!isOwner && !isSpender){
            revert NotOwnerOfTokenError(tokenId,from);
        }

      
        tokenOwner[tokenId] = to;
        delete tokenSpender[tokenId];
        ownerTokens[to].push(tokenId);
        uint256 [] storage tokens = ownerTokens[from];          

        assert(tokens.length > 0);
        uint256 last = tokens.length -1 ;
        for( uint256 i = 0;  i < last ; ++ i){
            if(tokenId == tokens[i]){
                tokens[i] = tokens[last];
                break;
            }
        }
        tokens.pop();
        
        emit Transfer(from,to,tokenId);
        console.log('emit transfer');
      

    }


    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external{
        if(tokenSpender[tokenId] == to){
            revert("token is Approved yet");
        }

        tokenSpender[tokenId] = to;
        emit Approval(msg.sender, to, tokenId);
    }

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the address zero.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool approved) external{
        require(operator != address(0));

        bool oldValue = allowances[msg.sender][operator];
        require(oldValue != approved, "approved status not changed");
        allowances[msg.sender][operator] = approved;

        emit ApprovalForAll(msg.sender, operator,  approved);
    }

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator){
            return tokenSpender[tokenId];
    }

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool){
        return allowances[owner][operator];
    }


   
    /**
     * @dev Returns the total amount of tokens stored by the contract.
     */
    function totalSupply() external view returns (uint256){
        return _tokens.length;
    }

    /**
     * @dev Returns a token ID owned by `owner` at a given `index` of its token list.
     * Use along with {balanceOf} to enumerate all of ``owner``'s tokens.
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256){
        uint256[] storage tokens = ownerTokens[owner];
        require(index < tokens.length, "index too large");
        return tokens[index];
    }

    /**
     * @dev Returns a token ID at a given `index` of all the tokens stored by the contract.
     * Use along with {totalSupply} to enumerate all tokens.
     */
    function tokenByIndex(uint256 index) external view returns (uint256){
        require(index < _tokens.length,"index too large");
        return _tokens[index];
    }


}

