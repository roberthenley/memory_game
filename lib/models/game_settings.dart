class GameSettings {
  static const int layoutWidth = 2;
  static const int layoutHeight = 3;
  static const int numberOfCards = layoutHeight * layoutWidth;
  static int numberOfUniqueCards = (numberOfCards / 2).floor();
  static const int initialFaceUpSeconds = 5;
  static const int nonMatchingCardsFaceUpSeconds = 5;
}
