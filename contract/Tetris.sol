// SPDX-License-Identifier: MIT
pragma solidity >=0.6.2 <0.9.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/math/SafeMath.sol";

contract Tetris is Ownable{

    using SafeMath for uint;

    //Store the amount following address to the betBNBamount
    mapping(address => uint256) public betBNBamount;

    //Using isbetting mapping for the flag of the bet performance
    mapping(address => bool) public isbetting;

    //Betting Account Array
    address[] connectedAccount;

    //Contract comision
    uint16 feePercent = 10;
    
    //transaction successfully performed and receive BNB
    event Received (address , uint);
    
    //Identify winner with connectedAccount
    modifier onlyWinner(address _winner) {
        require(connectedAccount[0] == _winner || connectedAccount[1] == _winner);
        _;
    }

    //Return specific account's balance
    function balanceOf(address _account) external view returns(uint256) {
        return _account.balance;
    }

    //Transform the BNB from account to the SC
    function transferBNB() payable public returns(bool){
        betBNBamount[msg.sender] = msg.value;
        connectedAccount.push(msg.sender);
        emit Received(msg.sender, msg.value);
        return true;
    }
    
    //Return the whole connectedAccount
    function getAccounts() public view returns(address[] memory ) {
        return connectedAccount;
    }

    //Transform all of the SC's BNB.---for the test deploy.
    function returnToOwner() public{
        payable(owner()).transfer(address(this).balance);
    }

    //Return the BNB to the winner, some comision to the owner.
    function withdraw() external onlyWinner(msg.sender) payable {
        uint256 amount = betBNBamount[connectedAccount[0]].add(betBNBamount[connectedAccount[1]]);
        payable(msg.sender).transfer(amount.mul(100-feePercent).div(100));
        payable(owner()).transfer(amount.mul(feePercent).div(100));
        delete connectedAccount;
    }
}