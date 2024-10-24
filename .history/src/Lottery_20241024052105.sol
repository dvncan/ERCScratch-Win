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
        uint256[] ticketNumbers;
        uint256 amount;
        uint256 ticketsSold;
        uint256 firstTicketNumber;
        uint256 lastTicketNumber;
        uint256 winningTicketNumber;
    }

    mapping(uint8 => LotteryDetails) public lotteryDetails; // lotteryId => lotteryDetails

    mapping(address => Ticket[]) public userTickets;
    mapping(uint256 => address) public ticketOwners;

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
            amount: 0,
            ticketsSold: 0,
            firstTicketNumber: 0,
            lastTicketNumber: 0,
            winningTicketNumber: 0
        });
        lotteryDetails[lotteryId].firstTicketNumber = ticketNumber;
    }

    function _updateLotteryDetails() internal {
        lotteryDetails[lotteryId].ticketsSold++;
        lotteryDetails[lotteryId].lastTicketNumber = ticketNumber;
        lotteryDetails[lotteryId].amount += msg.value;
    }

    function purchaseTicket(uint256 amount) external payable {
        if (playersBets[msg.sender] == 0) {
            players.push(msg.sender);
        }
        playersBets[msg.sender] += amount;

        _updateLotteryDetails();

        userTickets[msg.sender].push(
            Ticket({
                id: lotteryId,
                number: ticketNumber,
                player: msg.sender,
                purchased: true,
                winner: false
            })
        );
        ticketOwners[ticketNumber] = msg.sender;
        lotteryDetails[lotteryId].ticketNumbers.push(ticketNumber);
        ticketNumber++;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    event WinnerPicked(uint256 winningTicketNumber, address winner);
    function pickWinner() external returns (uint256) {
        uint256 randomNumber = uint256(
            keccak256(
                abi.encodePacked(block.timestamp, block.difficulty, msg.sender)
            )
        );
        lotteryDetails[lotteryId].winningTicketNumber =
            lotteryDetails[lotteryId].ticketNumbers[
                randomNumber % lotteryDetails[lotteryId].ticketNumbers.length
            ] +
            1;
        emit WinnerPicked(lotteryDetails[lotteryId].winningTicketNumber, )
        return lotteryDetails[lotteryId].winningTicketNumber;

    }

    function getPlayers() external view virtual returns (address[] memory) {
        return players;
    }
    function getBalance() external view virtual returns (uint256);

    receive() external payable {
        this.purchaseTicket(msg.value);
    }
}
