import 'package:flutter/material.dart';

import 'package:chess_game/components/piece.dart';
import 'package:chess_game/values/colors.dart';

class Square extends StatelessWidget {
  const Square({
    super.key,
    required this.piece,
    required this.isWhite,
    required this.isSelected,
    required this.isValidMove,
    required this.onTap,
  });

  final ChessPiece? piece;
  final bool isWhite;
  final bool isSelected;
  final bool isValidMove;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    Color? squareColor;

    if (isSelected) {
      squareColor = Colors.green;
    } else if (isValidMove) {
      squareColor = Colors.green.shade300;
    } else {
      squareColor = isWhite ? foregroundColor : backgroundColor;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: squareColor,
        child: piece != null
            ? Image.asset(
                piece!.imagePath,
              )
            : null,
      ),
    );
  }
}
