class CardAssets {
  List<String> _cardPathNames = [
    'assets/svg/bear-animal.svg',
    'assets/svg/bee-honey.svg',
    'assets/svg/butterfly.svg',
    'assets/svg/cat-animal.svg',
    'assets/svg/chicken-rooster-line.svg',
    'assets/svg/cow-animal-face.svg',
    'assets/svg/elephant.svg',
    'assets/svg/fish-line.svg',
    'assets/svg/fox.svg',
    'assets/svg/kangaroo.svg',
    'assets/svg/lion-face.svg',
    'assets/svg/owl-bird.svg',
    'assets/svg/penguin.svg',
    'assets/svg/pig-piggy.svg',
    'assets/svg/sheep.svg',
    'assets/svg/sparrow-bird.svg',
    'assets/svg/squirrel.svg',
    'assets/svg/tiger.svg',
    'assets/svg/turtle-sea.svg',
    'assets/svg/worm.svg',
  ];

  List<String> getCardAssetPaths(int n) {
    List<String> randomizedList = List<String>.from(_cardPathNames);
    randomizedList.shuffle();
    return randomizedList.take(n);
  }
}
