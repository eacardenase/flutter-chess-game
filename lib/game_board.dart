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

  // USER SELECTED A PIECE
  void pieceSelected(int row, int col) {
    setState(() {
      // selected a piece if there is a piece in that position
      if (board[row][col] != null) {
        selectedPiece = board[row][col];
        selectedRow = row;
        selectedCol = col;
      }
    });
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

          return Square(
            isWhite: isWhite(index),
            piece: board[row][col],
            isSelected: isSelected,
            onTap: () => pieceSelected(row, col),
          );
        },
      ),
    );
  }
}
