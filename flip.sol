// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract CoinFlip {
    address public player1;
    address public player2;
    uint256 public pot;
    uint256 public winner;
    address public winnerAddress;

    event GameStarted(address indexed player1, address indexed player2, uint256 pot);
    event GameFinished(address indexed winnerAddress, string winner, uint256 pot);

    function enter() public payable {
        require(msg.value == 0.001 ether, "Must send 0.001 ether to enter");
        if (player1 == address(0)) {
            player1 = msg.sender;
        } else {
            require(player2 == address(0), "Both players have already entered");
            player2 = msg.sender;
            emit GameStarted(player1, player2, pot);
        }
        pot += msg.value;
        winner = 0;
        winnerAddress = address(0);
    }

    function flipCoin() public {
        require(msg.sender == player1 || msg.sender == player2, "Sender is not a player");
        uint256 result = uint256(keccak256(abi.encodePacked(block.timestamp, block.prevrandao, block.coinbase))) % 2;
        winner = result == 0 ? 1 : 2;
        winnerAddress = winner == 1 ? player1 : player2;
        string memory winnerName = winner == 1 ? "player1" : "player2";
        emit GameFinished(winnerAddress, winnerName, pot);
        payable(winnerAddress).transfer(pot);
        pot = 0;
        player1 = address(0);
        player2 = address(0);
    }
}