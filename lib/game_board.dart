import 'package:flutter/material.dart';

import 'package:chess_game/components/piece.dart';
import 'package:chess_game/components/square.dart';
import 'package:chess_game/helpers/helper_methods.dart';
import 'package:chess_game/values/colors.dart';

class GameBoard extends StatefulWidget {
  const GameBoard({super.key});

  @override
  State<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard> {
  // A 2-dimensional list representing the chessboard,
  // with each position possibly containing a chess piece
  late List<List<ChessPiece?>> board;

  // The currently selected piece on the chess board
  // If no piece is selected, this is null
  ChessPiece? selectedPiece;

  // The row index of the selected piece
  // Default value -1 indicates no piece is currently selected
  int selectedRow = -1;

  // The col index of the selected piece
  // Default value -1 indicates no piece is currently selected
  int selectedCol = -1;

  // A list of valid moves for the currently selected piece
  // each move is represented as a list with 2 elements: row and col
  List<List<int>> validMoves = [];

  // USER SELECTED A PIECE
  void pieceSelected(int row, int col) {
    setState(() {
      // selected a piece if there is a piece in that position
      if (board[row][col] != null) {
        selectedPiece = board[row][col];
        selectedRow = row;
        selectedCol = col;
      }

      // if a piece is selected, calculate it's valid moves
      validMoves =
          calculateRawValidMoves(selectedRow, selectedCol, selectedPiece);
    });
  }

  // CALCULATE RAW VALID MOVES
  List<List<int>> calculateRawValidMoves(int row, int col, ChessPiece? piece) {
    List<List<int>> candidateMoves = [];

    // different directions based on their color
    int direction = piece!.isWhite ? -1 : 1;

    switch (piece.type) {
      case ChessPieceType.pawn:
        // pawns can move forward if the square is not occupied
        if (isInBoard(row + direction, col) &&
            board[row + direction][col] == null) {
          candidateMoves.add([row + direction, col]);
        }

        // pawns can move 2 squares forward if they're at their initial positions
        if ((row == 1 && !piece.isWhite) || (row == 6 && piece.isWhite)) {
          if (isInBoard(row + 2 * direction, col) &&
              board[row + 2 * direction][col] == null &&
              board[row + direction][col] == null) {
            candidateMoves.add([row + 2 * direction, col]);
          }
        }

        // pawns can capture diagonally
        if (isInBoard(row + direction, col - 1) &&
            board[row + direction][col - 1] != null &&
            board[row + direction][col - 1]!.isWhite) {
          candidateMoves.add([row + direction, col - 1]);
        }

        if (isInBoard(row + direction, col + 1) &&
            board[row + direction][col + 1] != null &&
            board[row + direction][col + 1]!.isWhite) {
          candidateMoves.add([row + direction, col + 1]);
        }

        break;
      case ChessPieceType.rook:
        // horizontal and vertical directions
        var directions = [
          [-1, 0], // up
          [1, 0], // down
          [0, -1], // left
          [0, 1], // right
        ];

        for (final direction in directions) {
          var i = 1;

          while (true) {
            var newRow = row + i * direction[0];
            var newCol = col + i * direction[1];

            if (!isInBoard(newRow, newCol)) {
              break;
            }

            if (board[newRow][newCol] != null) {
              if (board[newRow][newCol]!.isWhite != piece.isWhite) {
                candidateMoves.add([newRow, newCol]); // capture enemy piece
              }

              break; // blocked
            }

            candidateMoves.add([newRow, newCol]);

            i++;
          }
        }

        break;
      case ChessPieceType.knight:
        // all eight possible L shapes the knight can move
        var knightMoves = [
          [-2, -1], // up 2 left 1
          [-2, 1], // up 2 right 1
          [-1, -2], // up 1 left 2
          [-1, 2], // up 1 right 2
          [1, -2], // down 1 left 2
          [1, 2], // down 1 right 2
          [2, -1], // down 2 left 1
          [2, 1], // down 2 right 1
        ];

        for (final move in knightMoves) {
          var newRow = row + move[0];
          var newCol = col + move[1];

          if (!isInBoard(newRow, newCol)) {
            continue;
          }

          if (board[newRow][newCol] != null) {
            if (board[newRow][newCol]!.isWhite != piece.isWhite) {
              candidateMoves.add([newRow, newCol]); // capture enemy piece
            }

            continue; // blocked
          }

          candidateMoves.add([newRow, newCol]);
        }

        break;
      case ChessPieceType.bishop:
        // diagonal directions
        var directions = [
          [-1, -1], // up left
          [-1, 1], // up right
          [1, -1], // down left
          [1, 1], // down right
        ];

        for (final direction in directions) {
          var i = 0;

          while (true) {
            var newRow = row + i * direction[0];
            var newCol = col + i * direction[1];

            if (!isInBoard(newRow, newCol)) {
              break;
            }

            if (board[newRow][newCol] != null) {
              if (board[newRow][newCol]!.isWhite != piece.isWhite) {
                candidateMoves.add([newRow, newCol]); // capture enemy piece
              }

              break; // blocked
            }

            candidateMoves.add([newRow, newCol]);

            i++;
          }
        }

        break;
      case ChessPieceType.queen:
        // all eight directions: up, down, left, right and 4 diagonals
        var directions = [
          [-1, 0], // up
          [1, 0], // down
          [0, -1], // left
          [0, 1], //  right
          [-1, -1], // up left
          [-1, 1], // up right
          [1, -1], // down left
          [1, 1], // down right
        ];

        for (final direction in directions) {
          var i = 1;

          while (true) {
            var newRow = row + i * direction[0];
            var newCol = col + i * direction[1];

            if (!isInBoard(newRow, newCol)) {
              break;
            }

            if (board[newRow][newCol] != null) {
              if (board[newRow][newCol]!.isWhite != piece.isWhite) {
                candidateMoves.add([newRow, newCol]); // capture enemy piece
              }

              break; // blocked
            }

            candidateMoves.add([newRow, newCol]);

            i++;
          }
        }

        break;
      case ChessPieceType.king:
        break;
      default:
    }

    return candidateMoves;
  }

  @override
  void initState() {
    super.initState();

    _initializeBoard();
  }

  void _initializeBoard() {
    // initialize the board with nulls, meaning no pieces in those positions
    List<List<ChessPiece?>> newBoard =
        List.generate(8, (index) => List.generate(8, (index) => null));

    // Place pawns
    for (int i = 0; i < 8; i++) {
      newBoard[1][i] = const ChessPiece(
        type: ChessPieceType.pawn,
        isWhite: false,
      );

      newBoard[6][i] = const ChessPiece(
        type: ChessPieceType.pawn,
        isWhite: true,
      );
    }

    // Place rooks
    for (int i = 0; i < 8; i++) {
      if (i == 0 || i == 7) {
        newBoard[0][i] = const ChessPiece(
          type: ChessPieceType.rook,
          isWhite: false,
        );

        newBoard[7][i] = const ChessPiece(
          type: ChessPieceType.rook,
          isWhite: true,
        );
      }
    }

    // Place knights
    for (int i = 0; i < 8; i++) {
      if (i == 1 || i == 6) {
        newBoard[0][i] = const ChessPiece(
          type: ChessPieceType.knight,
          isWhite: false,
        );

        newBoard[7][i] = const ChessPiece(
          type: ChessPieceType.knight,
          isWhite: true,
        );
      }
    }

    // Place bishops
    for (int i = 0; i < 8; i++) {
      if (i == 2 || i == 5) {
        newBoard[0][i] = const ChessPiece(
          type: ChessPieceType.bishop,
          isWhite: false,
        );

        newBoard[7][i] = const ChessPiece(
          type: ChessPieceType.bishop,
          isWhite: true,
        );
      }
    }

    // Place queens
    newBoard[0][3] = const ChessPiece(
      type: ChessPieceType.queen,
      isWhite: false,
    );

    newBoard[7][4] = const ChessPiece(
      type: ChessPieceType.queen,
      isWhite: true,
    );

    // Place kings
    newBoard[0][4] = const ChessPiece(
      type: ChessPieceType.king,
      isWhite: false,
    );

    newBoard[7][3] = const ChessPiece(
      type: ChessPieceType.king,
      isWhite: true,
    );

    board = newBoard;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: GridView.builder(
        itemCount: 8 * 8,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 8,
        ),
        itemBuilder: (context, index) {
          // get the row and col position of this square
          int row = index ~/ 8;
          int col = index % 8;

          // check if square is selected
          bool isSelected = selectedRow == row && selectedCol == col;

          // check if square is a valid move
          bool isValidMove = false;

          for (var position in validMoves) {
            if (position[0] == row && position[1] == col) {
              isValidMove = true;
            }
          }

          return Square(
            piece: board[row][col],
            isWhite: isWhite(index),
            isSelected: isSelected,
            isValidMove: isValidMove,
            onTap: () => pieceSelected(row, col),
          );
        },
      ),
    );
  }
}
