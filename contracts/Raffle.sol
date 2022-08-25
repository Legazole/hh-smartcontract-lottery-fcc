// Raffle

//Enter the lottery (paying some amount)
//verifably random winner picked
//Winner to be selected after x amount of time

//Chainlink Oracle randomness and automation

// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.8;

error Raffle__NotEnoughETHEntered();

contract Raffle {
    // State variables
    uint256 private immutable i_entranceFee;
    address payable[] private s_players;

    //events
    event RaffleEnter(address indexedPlayer);

    constructor(uint256 _entraceFee) {
        i_entranceFee = _entraceFee;
    }

    function enterRaffle() public payable {
        //require(i_entranceFee < msg.value);
        if (msg.value < i_entranceFee) {
            revert Raffle__NotEnoughETHEntered();
        }
        s_players.push(payable(msg.sender));
        //name events with functions name reversed
        emit RaffleEnter(msg.sender);
    }

    function pickRandomWinner() public {}

    function getEntranceFee() public view returns (uint256) {
        return i_entranceFee;
    }

    function getPlayer(uint256 _index) public view returns (address) {
        return s_players[_index];
    }
}
