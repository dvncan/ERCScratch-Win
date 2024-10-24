// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

abstract contract Lottery {
    uint256 public constant TICKET_PRICE = 0.0015 ether;
    uint256 public constant MAX_TICKETS = 100;
    enum LotteryStatus {
        NONE,
        OPEN,
        CLOSED,
        DISPUTED
    }

    struct Ticket {
        uint8 id;
        uint256 number;
        address player;
        bool purchased;
        bool winner;
    }

    struct LotteryDetails {
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

    address public owner;
    uint8 public lotteryId;
    uint256 public ticketNumber;
    constructor() {
        lotteryId = 0;
        ticketNumber = 1000;
        openNewLottery();
    }

    function getLotteryId() external view returns (uint8) {
        return lotteryId;
    }

    function openNewLottery() internal {
        lotteryId++;
        lotteryDetails[lotteryId] = LotteryDetails({
            status: LotteryStatus.OPEN,
            lotteryId: lotteryId,
            winners: new address[](0),
            amount: 0
        });
    }

    function purchaseTicket(uint256 amount) external payable {
        if (playersBets[msg.sender] == 0) {
            players.push(msg.sender);
        }
        playersBets[msg.sender] += amount;

        lotteryDetails[lotteryId].amount += amount;

        userTickets[msg.sender].push(
            Ticket({
                id: lotteryId,
                number: ticketNumber,
                player: msg.sender,
                purchased: true,
                winner: false
            })
        );
        ticketNumber++;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    function pickWinner() external {}
    function getPlayers() external view virtual returns (address[] memory) {
        return players;
    }
    function getBalance() external view virtual returns (uint256);

    receive() external payable {
        this.purchaseTicket(msg.value);
    }
}
