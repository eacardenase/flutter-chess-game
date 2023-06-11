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
  // ChessPiece myKing = const ChessPiece(
  //   type: ChessPieceType.king,
  //   isWhite: true,
  //   imagePath: 'assets/icons/king-white.png',
  // );
  ChessPiece myKing = const ChessPiece(
    type: ChessPieceType.king,
    isWhite: false,
    imagePath: 'assets/icons/king-black.png',
  );

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
          return Square(
            isWhite: isWhite(index),
            piece: myKing,
          );
        },
      ),
    );
  }
}
