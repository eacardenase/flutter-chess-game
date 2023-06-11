import 'package:flutter/material.dart';

import 'package:chess_game/components/piece.dart';
import 'package:chess_game/values/colors.dart';

class Square extends StatelessWidget {
  const Square({
    super.key,
    required this.isWhite,
    required this.piece,
  });

  final bool isWhite;
  final ChessPiece? piece;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: isWhite ? foregroundColor : backgroundColor,
      child: piece != null
          ? Image.asset(
              piece!.imagePath,
            )
          : null,
    );
  }
}
