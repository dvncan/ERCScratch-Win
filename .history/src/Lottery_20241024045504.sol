// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

abstract contract Lottery {

    uint256 public constant TICKET_PRICE = 0.0015 ether;
    uint256 public constant MAX_TICKETS = 100;
    enum LotteryStatus{
        NONE, 
        OPEN,
        CLOSED, 
        DISPUTED
    }

    struct Ticket{
        uint8 id;
        uint256 number;
        address player;
        bool purchased;
        bool winner;
    }

    struct LotteryDetails{
        LotteryStatus status;
        uint8 lotteryId;
        address[] winners;
        uint256 amount;
    }

    uint8 public lotteryId;
    mapping(uint8 => LotteryDetails) public lotteryDetails; // lotteryId => lotteryDetails

    mapping(address => Ticket[]) public userTickets;

    mapping(address => uint256) public playersBets;
    address[] public players;


    uint8 public lotteryId;
    constructor(){
        lotteryId = 0;
        openNewLottery()
    }

    function getLotteryId() external view returns (uint8){
        return lotteryId;
    }

    function openNewLottery() external {
        lotteryId++;
        lotteryDetails[lotteryId] = LotteryDetails({
            status: LotteryStatus.OPEN,
            lotteryId: lotteryId,
            winners: new address[](0),
            amount: 0
        });
    }

    function purchaseTicket(uint256 amount) external payable {
        if(playersBets[msg.sender] == 0) {
            players.push(msg.sender);
        }
        playersBets[msg.sender] += amount;

        lotteryDetails[lotteryId].amount += amount;
    };
    function pickWinner() external virtual;
    function getPlayers() external view virtual returns (address[] memory){
        return players;
    }
    function getBalance() external view virtual returns (uint256);

    receive() external payable {
        this.purchaseTicket(msg.value);
    }
}
