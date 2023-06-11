import 'dart:math';

import 'package:flutter/material.dart';

import 'package:chess_game/components/piece.dart';
import 'package:chess_game/components/square.dart';
import 'package:chess_game/components/captured_piece.dart';
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

  // A list of white pieces that have been captured
  List<ChessPiece> whitePiecesTaken = [];

  // A list of black pieces that have been captured
  List<ChessPiece> blackPiecesTaken = [];

  // A boolean to indicate whose turn it is
  bool isWhiteTurn = true;

  // initial position of kings
  // keep track of this to make it easier to see if king is in check
  List<int> whiteKingPosition = [7, 4];
  List<int> blackKingPosition = [0, 4];
  bool checkStatus = false;

  // USER SELECTED A PIECE
  void pieceSelected(int row, int col) {
    setState(() {
      // No piece has been selected yet, this is the first selection
      if (selectedPiece == null && board[row][col] != null) {
        if (board[row][col]!.isWhite == isWhiteTurn) {
          selectedPiece = board[row][col];
          selectedRow = row;
          selectedCol = col;
        }
      }
      // There is a piece already selected,
      // but user can select another one of their pieces
      else if (board[row][col] != null &&
          board[row][col]!.isWhite == selectedPiece!.isWhite) {
        selectedPiece = board[row][col];
        selectedRow = row;
        selectedCol = col;
      } else if (selectedPiece != null &&
          validMoves.any((element) => element[0] == row && element[1] == col)) {
        // if there is a piece selected and user taps on
        // a square that is a valid move, move the piece there
        movePiece(row, col);
      }

      // if a piece is selected, calculate it's valid moves
      validMoves = calculateRealValidMoves(
          selectedRow, selectedCol, selectedPiece, true);
    });
  }

  // CALCULATE RAW VALID MOVES
  List<List<int>> calculateRawValidMoves(int row, int col, ChessPiece? piece) {
    List<List<int>> candidateMoves = [];

    if (piece == null) {
      return [];
    }

    // different directions based on their color
    int direction = piece.isWhite ? -1 : 1;

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
            board[row + direction][col - 1]!.isWhite != piece.isWhite) {
          candidateMoves.add([row + direction, col - 1]);
        }

        if (isInBoard(row + direction, col + 1) &&
            board[row + direction][col + 1] != null &&
            board[row + direction][col + 1]!.isWhite != piece.isWhite) {
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
          var newRow = row + direction[0];
          var newCol = col + direction[1];

          if (!isInBoard(newRow, newCol)) {
            continue;
          }

          if (board[newRow][newCol] != null) {
            if (board[newRow][newCol]!.isWhite != piece.isWhite) {
              candidateMoves.add([newRow, newCol]); // capture enemy piece
            }

            continue; // bloqued
          }

          candidateMoves.add([newRow, newCol]);
        }

        break;
      default:
    }

    return candidateMoves;
  }

  // CALCULATE REAL VALID MOVES
  List<List<int>> calculateRealValidMoves(
      int row, int col, ChessPiece? piece, bool checkSimulation) {
    List<List<int>> realValidMoves = [];
    List<List<int>> candidateMoves = calculateRawValidMoves(row, col, piece);

    // after generating all candidate moves
    // filter out any that would result in a king check
    if (checkSimulation) {
      for (var move in candidateMoves) {
        int endRow = move[0];
        int endCol = move[1];

        // this will simulate the future move
        if (simulatedMoveIsSafe(
          piece!,
          startRow: row,
          startCol: col,
          endRow: endRow,
          endCol: endCol,
        )) {
          realValidMoves.add(move);
        }
      }
    } else {
      realValidMoves = candidateMoves;
    }

    return realValidMoves;
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

    // random piece for testing purposes
    // newBoard[3][3] = ChessPiece(type: ChessPieceType.king, isWhite: true);

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

    newBoard[7][3] = const ChessPiece(
      type: ChessPieceType.queen,
      isWhite: true,
    );

    // Place kings
    newBoard[0][4] = const ChessPiece(
      type: ChessPieceType.king,
      isWhite: false,
    );

    newBoard[7][4] = const ChessPiece(
      type: ChessPieceType.king,
      isWhite: true,
    );

    board = newBoard;
  }

  // MOVE PIECE
  void movePiece(int newRow, int newCol) {
    // if the new spot has an enemy piece
    if (board[newRow][newCol] != null) {
      // add captured piece to appropriate list
      var capturedPiece = board[newRow][newCol];

      if (capturedPiece!.isWhite) {
        whitePiecesTaken.add(capturedPiece);
      } else {
        blackPiecesTaken.add(capturedPiece);
      }
    }

    // check if piece being moved is a king
    if (selectedPiece!.type == ChessPieceType.king) {
      // update the appropriate king position
      if (selectedPiece!.isWhite) {
        whiteKingPosition = [newRow, newCol];
      } else {
        blackKingPosition = [newRow, newCol];
      }
    }

    // move the piece and clear the old spot
    board[newRow][newCol] = selectedPiece;
    board[selectedRow][selectedCol] = null;

    // see if any king are under attack
    if (isKingInCheck(!isWhiteTurn)) {
      checkStatus = true;
    } else {
      checkStatus = false;
    }

    // clear selection
    setState(() {
      selectedPiece = null;
      selectedRow = -1;
      selectedCol = -1;
      validMoves = [];
    });

    // check if it's check mate
    if (isCheckMate(!isWhiteTurn)) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text(
            'CHECK MATE!',
          ),
          actions: [
            // play again button
            TextButton(
              onPressed: resetGame,
              child: const Text(
                'Play Again',
              ),
            )
          ],
        ),
      );
    }

    // change turns
    isWhiteTurn = !isWhiteTurn;
  }

  // IS KING IN CHECK
  bool isKingInCheck(bool isWhiteKing) {
    // get position of the king
    List<int> kingPosition =
        isWhiteKing ? whiteKingPosition : blackKingPosition;

    // check if any enemy piece can attack the king
    for (var i = 0; i < 8; i++) {
      for (var j = 0; j < 8; j++) {
        // skip empty squares and pieces of the same color as the king
        if (board[i][j] == null || board[i][j]!.isWhite == isWhiteKing) {
          continue;
        }

        List<List<int>> pieceValidMoves =
            calculateRealValidMoves(i, j, board[i][j], false);

        // check if the king's position is in any of this piece's moves
        if (pieceValidMoves.any((move) =>
            move[0] == kingPosition[0] && move[1] == kingPosition[1])) {
          return true;
        }
      }
    }

    return false;
  }

// SIMULATE FUTURE MOVE
  bool simulatedMoveIsSafe(
    ChessPiece piece, {
    required int startRow,
    required int endRow,
    required int startCol,
    required int endCol,
  }) {
    // save the current board state
    ChessPiece? originalDestinationPiece = board[endRow][endCol];

    // if the piece is the king
    // save it's current position and update to the new one
    List<int>? originalKingPosition;

    if (piece.type == ChessPieceType.king) {
      originalKingPosition =
          piece.isWhite ? whiteKingPosition : blackKingPosition;

      // update the king position
      if (piece.isWhite) {
        whiteKingPosition = [endRow, endCol];
      } else {
        blackKingPosition = [endRow, endCol];
      }
    }

    // simulate the move
    board[endRow][endCol] = piece;
    board[startRow][startCol] = null;

    // check if our own king is under attack
    bool kingIsinCheck = isKingInCheck(piece.isWhite);

    // restore board to original state
    board[startRow][startCol] = piece;
    board[endRow][endCol] = originalDestinationPiece;

    // if the piece was the king,
    // restore it original position
    if (piece.type == ChessPieceType.king) {
      if (piece.isWhite) {
        whiteKingPosition = originalKingPosition!;
      } else {
        blackKingPosition = originalKingPosition!;
      }
    }

    // if king in check, is not a safe move
    return !kingIsinCheck;
  }

  // IS IT CHECK MATE?
  bool isCheckMate(bool isWhiteKing) {
    // if king is not in check, then it's not check mate
    if (!isKingInCheck(isWhiteKing)) {
      return false;
    }

    // if there's at least one legal move for any of the player pieces
    // then is not check mate

    for (int i = 0; i < 8; i++) {
      for (int j = 0; j < 8; j++) {
        // skip empty squares and enemy pieces
        if (board[i][j] == null || board[i][j]!.isWhite != isWhiteKing) {
          continue;
        }

        List<List<int>> pieceValidMoves =
            calculateRealValidMoves(i, j, board[i][j], true);

        if (pieceValidMoves.isNotEmpty) {
          return false;
        }
      }
    }

    // if none of the above conditions are met, then there're no legal moves
    // left to make, it's check mate!
    return true;
  }

  // RESET GAME
  void resetGame() {
    Navigator.pop(context);

    _initializeBoard();
    checkStatus = false;
    isWhiteTurn = true;
    whitePiecesTaken.clear();
    blackPiecesTaken.clear();
    whiteKingPosition = [7, 4];
    blackKingPosition = [0, 4];

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Column(
        children: [
          // WHITE PIECES CAPTURED
          Expanded(
            child: GridView.builder(
              itemCount: whitePiecesTaken.length,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 8),
              itemBuilder: (context, index) => DeadPiece(
                imagePath: whitePiecesTaken[index].imagePath,
                isWhite: true,
              ),
            ),
          ),
          // GAME STATUS
          Text(
            checkStatus ? 'CHECK' : "",
          ),
          // CHESS BOARD
          Expanded(
            flex: 3,
            child: GridView.builder(
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
          ),
          // BLACK PIECES CAPTURED
          Expanded(
            child: GridView.builder(
              itemCount: blackPiecesTaken.length,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 8),
              itemBuilder: (context, index) => DeadPiece(
                imagePath: blackPiecesTaken[index].imagePath,
                isWhite: false,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
