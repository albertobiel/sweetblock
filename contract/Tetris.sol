// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/math/SafeMath.sol";


contract Tetris is Ownable {
    
    // using SafeMath for uint256;
    // using SafeMath32 for uint32;
    // using SafeMath16 for uint16;

    using SafeMath for uint;

    // mapping(address => uint256) public ownerBNBamount;
    mapping(address => uint256) public betBNBamount;
    mapping(address => bool) public isbetting;
    address[] connectedAccount;
    uint16 feePercent = 10;
    
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

    function transferBNB(address _from, uint256 _amount) external ownerOfBNB(_from, _amount) onlyOwnerOf(_from) payable returns(bool){
        _from.balance.sub(_amount);
        address(this).balance.add(_amount);
        betBNBamount[_from] = _amount;  
        connectedAccount.push(address(this));
        return true;
    }
    
    function withdraw() external onlyOwner onlyWinner(msg.sender) payable {
        uint256 amount = betBNBamount[connectedAccount[0]].add(betBNBamount[connectedAccount[1]]);
        payable(msg.sender).transfer(amount.mul(9).div(10));
        payable(owner()).transfer(amount.div(10));
        delete connectedAccount;
    }
}