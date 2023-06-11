bool isWhite(int index) {
  int xCoordinate = index ~/ 8; // integer division -> row
  int yCoordinate = index % 8; // remainder division -> column

  // alternate colors for each square
  bool isWhite = (xCoordinate + yCoordinate) % 2 == 0;

  return isWhite;
}

bool isInBoard(int row, int col) {
  return row >= 0 && row < 8 && col >= 0 && col < 8;
}
