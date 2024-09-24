//SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract StakePool{
    //amount = deposits[uer][token]
    error StakeFailed();
    mapping(address =>mapping(address=>uint256))  deposits;
    function stake(address token ,uint256 amount ) external returns  (bool succ){
        succ = IERC20(token).transferFrom(msg.sender,address(this),amount);
        if(!succ) revert StakeFailed();
        deposits[msg.sender][token] = amount;
    }

    function untake(address token) external {
        uint256 amount = deposits[msg.sender][token];
        if(amount > 0 ){
            deposits[msg.sender][token] = 0;
            IERC20(token).transfer(msg.sender,amount);
        }
    }
}