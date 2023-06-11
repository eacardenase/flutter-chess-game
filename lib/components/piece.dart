enum ChessPieceType { pawn, rook, knight, bishop, queen, king }

class ChessPiece {
  const ChessPiece({
    required this.type,
    required this.isWhite,
  });

  final ChessPieceType type;
  final bool isWhite;
  String get imagePath {
    const basePath = 'assets/icons/';

    return '$basePath${type.name}-${isWhite ? 'white' : 'black'}.png';
  }
}
