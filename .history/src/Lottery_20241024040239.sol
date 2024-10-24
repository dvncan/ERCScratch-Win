// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

abstract contract Lottery {
    function purchaseTicket(uint256 amount) external payable;
    function pickWinner() external virtual;
    function getPlayers() external view virtual returns (address[] memory);
    function getBalance() external view virtual returns (uint256);
}
