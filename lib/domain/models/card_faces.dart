/// Holds the card face asset paths and user-friendly card names.
class CardFaces {
  static final Map<String, String> _cardPathNames = {
    'assets/svg/bear-animal.svg': 'Bear',
    'assets/svg/bee-honey.svg': 'Honey Bee',
    'assets/svg/butterfly.svg': 'Butterfly',
    'assets/svg/cat-animal.svg': 'Cat',
    'assets/svg/chicken-rooster-line.svg': 'Rooster',
    'assets/svg/cow-animal-face.svg': 'Cow',
    'assets/svg/elephant.svg': 'Elephant',
    'assets/svg/fish-line.svg': 'Fish',
    'assets/svg/fox.svg': 'Fox',
    'assets/svg/kangaroo.svg': 'Kangaroo',
    'assets/svg/lion-face.svg': 'Lion',
    'assets/svg/owl-bird.svg': 'Owl',
    'assets/svg/penguin.svg': 'Penguin',
    'assets/svg/pig-piggy.svg': 'Pig',
    'assets/svg/sheep.svg': 'Sheep',
    'assets/svg/sparrow-bird.svg': 'Sparrow',
    'assets/svg/squirrel.svg': 'Squirrel',
    'assets/svg/tiger.svg': 'Tiger',
    'assets/svg/turtle-sea.svg': 'Sea Turtle',
    'assets/svg/worm.svg': 'Worm',
  };

  /// Returns a randomized list of n (<= 20) card asset paths.
  ///
  /// Used for populating the cards used in a new game.
  static List<String> getRandomCardAssetPaths(int n) {
    assert(n <= _cardPathNames.length);
    List<String> randomizedList = List<String>.from(_cardPathNames.keys);
    randomizedList.shuffle();
    return randomizedList.take(n).toList(growable: false);
  }

  /// Returns a list of the first n (<= 20) card asset paths -- use for testing
  /// purposes only.
  static List<String> getFirstCardAssetPaths(int n) {
    assert(n <= _cardPathNames.length);
    return _cardPathNames.keys.take(n).toList(growable: false);
  }

  /// Returns the user-friendly name for a card face asset.
  ///
  /// Used for both face-up card Semantics labelling and in announcements for
  /// accessibility.
  static String getCardName(String cardPath) {
    String cardName = _cardPathNames[cardPath];
    // print('getCardName: ${cardName}');
    return cardName;
  }
}
