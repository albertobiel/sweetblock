// SPDX-License-Identifier: MIT
pragma solidity >=0.6.2 <0.9.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/math/SafeMath.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol";

contract Tetris is Ownable{
    
    // using SafeMath for uint256;
    // using SafeMath32 for uint32;
    // using SafeMath16 for uint16;

    using SafeMath for uint;

    // mapping(address => uint256) public ownerBNBamount;
    mapping(address => uint256) public betBNBamount;
    mapping(address => bool) public isbetting;
    address[] connectedAccount;
    uint16 feePercent = 10;
    
    event Received (address , uint);
    
    modifier ownerOfBNB(address _account, uint256 _betAmount) {
        require(_account.balance >= _betAmount);
        _;
    }

    modifier onlyOwnerOf(address _ownerOf) {
        require(msg.sender == _ownerOf);
        _;
    }

    modifier onlyWinner(address _winner) {
        require(connectedAccount[0] == _winner || connectedAccount[1] == _winner);
        _;
    }

    function balanceOf(address _account) external view returns(uint256) {
        return _account.balance;
    }

    function transferBNB() payable public returns(bool){
        // _from.balance.sub(_amount);
        // owner().balance.add(_amount);   
        // betBNBamount[_from] = _amount;  
        // connectedAccount.push(_from);
        emit Received(msg.sender, msg.value);
        return true;
    }
    
    // function transferBNB() payable public returns(bool){
    //     address(msg.sender).call{value: 1000000000000000}("");
    //     return true;
    // }

    // fallback() external payable {  }

    // // This function is called for plain Ether transfers, i.e.
    // // for every call with empty calldata.
    // receive() external payable {  }
    
    function withdraw() external onlyOwner onlyWinner(msg.sender) payable {
        uint256 amount = betBNBamount[connectedAccount[0]].add(betBNBamount[connectedAccount[1]]);
        payable(msg.sender).transfer(amount.mul(100-feePercent).div(100));
        payable(owner()).transfer(amount.mul(feePercent).div(100));
        delete connectedAccount;
    }
}