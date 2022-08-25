// Raffle

//Enter the lottery (paying some amount)
//verifably random winner picked
//Winner to be selected after x amount of time

//Chainlink Oracle randomness and automation

// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.8;

error Raffle__NotEnoughETHEntered();

import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";

contract Raffle is VRFConsumerBaseV2 {
    // State variables
    uint256 private immutable i_entranceFee;
    address payable[] private s_players;
    VRFCoordinatorV2Interface private immutable i_vrfCoordinator;
    bytes32 private immutable i_gasLane;
    uint64 private immutable i_subscriptionId;

    //events
    event RaffleEnter(address indexedPlayer);

    constructor(
        address vrfCoordinatorV2,
        uint256 _entraceFee,
        bytes32 gasLane,
        uint64 subscriptionId
    ) VRFConsumerBaseV2(vrfCoordinatorV2) {
        i_entranceFee = _entraceFee;
        i_vrfCoordinator = VRFCoordinatorV2Interface(vrfCoordinatorV2);
        i_gasLane = gasLane;
        i_subscriptionId = subscriptionId;
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

    //Finish of request function
    function requestRandomWinner() external {
        i_vrfCoordinator.requestRandomWords(i_gasLane,i_subscriptionId,,,)
    }

    function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords)
        internal
        override
    {}

    function getEntranceFee() public view returns (uint256) {
        return i_entranceFee;
    }

    function getPlayer(uint256 _index) public view returns (address) {
        return s_players[_index];
    }
}
