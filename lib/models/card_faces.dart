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

  static List<String> getCardAssetPaths(int n) {
    List<String> randomizedList = List<String>.from(_cardPathNames.keys);
    randomizedList.shuffle();
    return randomizedList.take(n).toList(growable: false);
  }

  static String getCardName(String cardPath) {
    String cardName = _cardPathNames[cardPath];
    // print('getCardName: ${cardName}');
    return cardName;
  }
}
