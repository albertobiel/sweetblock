// SPDX-License-Identifier: MIT
pragma solidity >=0.6.2 <0.9.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/math/SafeMath.sol";

contract Tetris is Ownable{

    using SafeMath for uint;

    mapping(address => uint256) public betBNBamount;
    mapping(address => bool) public isbetting;
    address[] connectedAccount;
    uint16 feePercent = 10;
    
    event Received (address , uint);
    

    modifier onlyWinner(address _winner) {
        require(connectedAccount[0] == _winner || connectedAccount[1] == _winner);
        _;
    }

    function balanceOf(address _account) external view returns(uint256) {
        return _account.balance;
    }

    function transferBNB() payable public returns(bool){
        betBNBamount[msg.sender] = msg.value;
        connectedAccount.push(msg.sender);
        emit Received(msg.sender, msg.value);
        return true;
    }
    
    function getAccounts() public view returns(address[] memory ) {
        return connectedAccount;
    }

    function returnToOwner() public{
        payable(owner()).transfer(address(this).balance);
    }

    function withdraw() external onlyWinner(msg.sender) payable {
        uint256 amount = betBNBamount[connectedAccount[0]].add(betBNBamount[connectedAccount[1]]);
        payable(msg.sender).transfer(amount.mul(100-feePercent).div(100));
        payable(owner()).transfer(amount.mul(feePercent).div(100));
        delete connectedAccount;
    }
}