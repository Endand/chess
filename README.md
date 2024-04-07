# Chess Game

## Overview

Chess is a classic two-player strategy game played on an 8x8 grid called a chessboard. Each player starts with 16 pieces: one king, one queen, two rooks, two knights, two bishops, and eight pawns. The objective is to checkmate the opponent's king, putting it in a position where it is under immediate attack and cannot escape.

## Rules

1. **Movement**: Each type of chess piece moves in a specific way. The king moves one square in any direction, while the queen can move any number of squares diagonally, horizontally, or vertically. Rooks move any number of squares horizontally or vertically, bishops move diagonally, and knights move in an L-shape pattern. Pawns move forward one square, but can optionally move two squares on their first move and capture diagonally.

2. **Capture**: Pieces capture opponents' pieces by moving to their square. Only pawns capture differently from how they move: diagonally forward.

3. **Check and Checkmate**: When a king is threatened by an opponent's piece, it is in "check." The player must make a move to remove the threat. If a player's king is in check and there is no legal move to remove the threat, the game ends in checkmate, and that player loses.

4. **Stalemate**: If a player is not in check but has no legal moves, the game is a stalemate, resulting in a draw.

5. **Pawn Promotion**: When a pawn reaches the opposite end of the board, it can be promoted to any other piece except a king. This is usually to a queen, as it is the most powerful piece.

## Implementation Details

### Game Setup

- The game initializes with an empty chessboard and sets up the initial position with all pieces in their starting positions.

### Board Visualization

- The game provides a visually appealing representation of the chessboard, featuring alternating colors to emulate a real-life chess board. Notations are included to aid in understanding the board layout and piece positions.
- To enhance player experience, the board orientation automatically flips each turn, ensuring that each player views the board from their perspective.

### Movement and Validation

- Each piece type has its movement rules implemented. The game validates moves to ensure they are legal according to the rules of chess.

### Check and Checkmate Detection

- The game continuously checks for check and checkmate conditions after each move, updating the game state accordingly. It employs algorithms to determine if a player's king is under threat or in an undefended position.

### Game Loop

- The core game loop allows players to take turns making moves until a checkmate or stalemate occurs. It handles player input, move execution, and updating the board state.

### Replayability

- Players have the option to replay the game with the same opponents after each match. However, to add variety and balance, the turn order is reversed in subsequent rounds, with the first player becoming the second player and vice versa.

## Usage

To play the game, run `ruby main.rb` on command line and follow the prompts to make moves. Enjoy the game of chess!
