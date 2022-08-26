// Raffle

//Enter the lottery (paying some amount)
//verifably random winner picked
//Winner to be selected after x amount of time

//Chainlink Oracle randomness and automation

// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.8;

error Raffle__NotEnoughETHEntered();
error Raffle__TransferFailed();

import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/interfaces/KeeperCompatibleInterface.sol";

contract Raffle is VRFConsumerBaseV2, KeeperCompatibleInterface {
    // State variables
    uint256 private immutable i_entranceFee;
    address payable[] private s_players;
    VRFCoordinatorV2Interface private immutable i_vrfCoordinator;
    bytes32 private immutable i_gasLane;
    uint64 private immutable i_subscriptionId;
    uint16 private constant REQUEST_CONFIMARTIONS = 3;
    uint32 private immutable i_callBackGaslimit;
    uint32 private constant NUM_WORDS = 1;

    //lottery variables
    address private s_recentWinner;

    //events
    event RaffleEnter(address indexed Player);
    event RequestRaffleWinner(uint256 indexed RequestId);
    event RaffleWinners(address indexed Winners);

    constructor(
        address vrfCoordinatorV2,
        uint256 _entraceFee,
        bytes32 gasLane,
        uint64 subscriptionId,
        uint32 callBackGaslimit
    ) VRFConsumerBaseV2(vrfCoordinatorV2) {
        i_entranceFee = _entraceFee;
        i_vrfCoordinator = VRFCoordinatorV2Interface(vrfCoordinatorV2);
        i_gasLane = gasLane;
        i_subscriptionId = subscriptionId;
        i_callBackGaslimit = callBackGaslimit;
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

    function checkUpkeep(bytes calldata)
        external
        override
        returns (bool upKeepNeeded, bytes memory)
    {}

    //Finish of request function
    function requestRandomWinner() external {
        uint256 requestId = i_vrfCoordinator.requestRandomWords(
            i_gasLane,
            i_subscriptionId,
            REQUEST_CONFIMARTIONS,
            i_callBackGaslimit,
            NUM_WORDS
        );
        emit RequestRaffleWinner(requestId);
    }

    function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords) internal override {
        uint256 indexOfWinner = randomWords[0] % s_players.length;
        address payable recentWinner = s_players[indexOfWinner];
        s_recentWinner = recentWinner;
        (bool succes, ) = recentWinner.call{value: address(this).balance}("");
        if (!succes) {
            revert Raffle__TransferFailed();
        }
        emit RaffleWinners(recentWinner);
    }

    function getEntranceFee() public view returns (uint256) {
        return i_entranceFee;
    }

    function getPlayer(uint256 _index) public view returns (address) {
        return s_players[_index];
    }

    function getRecentWinner() public view returns (address) {
        return s_recentWinner;
    }
}
