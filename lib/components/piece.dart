enum ChessPieceType { pawn, rook, knight, bishop, queen, king }

class ChessPiece {
  const ChessPiece({
    required this.type,
    required this.isWhite,
    required this.imagePath,
  });

  final ChessPieceType type;
  final bool isWhite;
  final String imagePath;
}
