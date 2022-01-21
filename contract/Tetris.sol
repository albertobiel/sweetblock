// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";

contract Tetris is Ownable{

    //Account Structure for their own game
    struct accountGame {
        address connectedAccount1;
        address connectedAccount2;
    }

    //Store the accounts as the game ID
    mapping(uint => accountGame) public gameControl;

    //Store the amount following address to the betBNBamount
    mapping(address => uint256) public betBNBamount;

    //Using isbetting mapping for the flag of the bet performance
    mapping(address => bool) public isbetting;

    //Contract comision
    uint16 feePercent = 10;

    //Event return token to the Owner
    event ReturnToOwner(uint256 amount);

    //Event return token to the Winner
    event WithDraw(address winner, uint256 amount);

    //transaction successfully performed and receive BNB
    event Received (address , uint);
    
    //Return the GameState as the GameID
    function getGameState(uint gameID) public view returns(address account1, address account2 ) {
        accountGame memory accountGameById = gameControl[gameID];
        return (accountGameById.connectedAccount1, accountGameById.connectedAccount2);
    }
    
    //Create the Game and Set GameID
    function createGame(uint gameID, address account1, address account2) public returns(bool) {
        accountGame memory newGame = accountGame(account1, account2);
        gameControl[gameID] = newGame;
        return true;
    }
    //Transform the BNB from account to the SC
    function transferBNB() payable public returns(bool){
        betBNBamount[msg.sender] = msg.value;
        emit Received(msg.sender, msg.value);
        return true;
    }
    
    //Transform all of the SC's BNB.---for the test deploy.
    function returnToOwner() public{
        payable(owner()).transfer(address(this).balance);
        emit ReturnToOwner(address(this).balance);
    }

    //Return the BNB to the winner, some comision to the owner.
    function withdraw(uint gameID) external payable {
        uint256 amount = betBNBamount[gameControl[gameID].connectedAccount1]+(betBNBamount[gameControl[gameID].connectedAccount2]);
        payable(msg.sender).transfer(amount*(100-feePercent)/(100));
        payable(owner()).transfer(amount*(feePercent)/(100));
        emit WithDraw(msg.sender, amount*(100-feePercent)/(100));
    }
}