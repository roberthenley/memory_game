import 'package:meta/meta.dart';

import 'card_faces.dart';
import 'card_model.dart';
import 'default_game_settings.dart';
import 'game_state.dart';

class GameModel {
  final int layoutWidth;
  final int layoutHeight;
  final int initialFaceUpSeconds;
  final int nonMatchingCardsFaceUpSeconds;
  final int durationSeconds;
  final List<CardModel> cards;
  final GameState state;
  final int cardMatchCount;

  int get numberOfCards {
    return layoutHeight * layoutWidth;
  }

  int get numberOfUniqueCards {
    return (numberOfCards / 2).floor();
  }

  int get gameDurationSeconds {
    return this.durationSeconds ?? this.numberOfCards * 6;
  }

  GameModel({
    this.layoutWidth = DefaultGameSettings.layoutWidth,
    this.layoutHeight = DefaultGameSettings.layoutHeight,
    this.initialFaceUpSeconds = DefaultGameSettings.initialFaceUpSeconds,
    this.nonMatchingCardsFaceUpSeconds =
        DefaultGameSettings.nonMatchingCardsFaceUpSeconds,
    this.durationSeconds,
    @required this.cards,
    @required this.state,
    @required this.cardMatchCount,
  });

  static GameModel newGame({
    int layoutWidth = DefaultGameSettings.layoutWidth,
    int layoutHeight = DefaultGameSettings.layoutHeight,
    int initialFaceUpSeconds,
    int nonMatchingCardsFaceUpSeconds,
    int durationSeconds,
  }) {
    // Initialize game board with two copies of each cards.
    // Cards are face-up for the initial display state.
    List<String> cardPaths =
        CardFaces.getCardAssetPaths((layoutWidth * layoutHeight / 2).floor());
    List<CardModel> cards = [];
    for (String cardPath in cardPaths) {
      cards.add(CardModel(cardFaceAssetPath: cardPath, isFaceUp: true));
      cards.add(CardModel(cardFaceAssetPath: cardPath, isFaceUp: true));
    }
    cards.shuffle();
    return GameModel(
      layoutWidth: layoutWidth,
      layoutHeight: layoutHeight,
      initialFaceUpSeconds: initialFaceUpSeconds,
      nonMatchingCardsFaceUpSeconds: nonMatchingCardsFaceUpSeconds,
      durationSeconds: durationSeconds,
      cards: cards,
      state: GameState.newGame,
      cardMatchCount: 0,
    );
  }

  GameModel copyWithCardFlags({
    GameState newState,
    int newCardMatchCount,
    bool isFaceUp,
    bool isMatched,
    bool isSelectable,
    bool isSelected,
  }) {
    List<CardModel> newCards = [];
    for (CardModel card in cards) {
      newCards.add(card.copyWith(
        isFaceUp: isFaceUp,
        isMatched: isMatched,
        isSelectable: isSelectable,
        isSelected: isSelected,
      ));
    }
    return this.copyWith(
      cards: newCards,
      state: newState ?? state,
      cardMatchCount: newCardMatchCount ?? cardMatchCount,
    );
  }

  GameModel copyWithNewCards({
    @required GameState newState,
    @required Map<CardModel, CardModel> replacementCards,
    int newMatchCount,
  }) {
    // replace the modified cards and set the new game state
    return this.copyWith(
      cards: _replaceCardsInList(cards, replacementCards),
      state: newState,
      cardMatchCount: newMatchCount ?? cardMatchCount,
    );
  }

  // static List<CardModel> _replaceCardInList(
  //     List<CardModel> cards,
  //     CardModel oldCard,
  //     CardModel newCard,) {
  //   int cardIndex = cards.indexOf(oldCard);
  //   List<CardModel> newCards = List<CardModel>.from(cards);
  //   newCards[cardIndex] = newCard;
  //   return newCards;
  // }

  static List<CardModel> _replaceCardsInList(
    List<CardModel> cards,
    Map<CardModel, CardModel> replacementCards,
  ) {
    List<CardModel> newCardList = List<CardModel>.from(cards);
    replacementCards.forEach((CardModel oldCard, CardModel newCard) {
      int cardIndex = cards.indexOf(oldCard);
      newCardList[cardIndex] = newCard;
    });
    return newCardList;
  }

  CardModel getSelectedCard() {
    return cards.firstWhere((element) => element.isSelected);
  }

  Iterable<CardModel> getAllSelectedCards() {
    return cards.where((element) => element.isSelected);
  }

  GameModel copyWith({
    List<CardModel> cards,
    GameState state,
    int cardMatchCount,
  }) =>
      GameModel(
        layoutWidth: layoutWidth,
        layoutHeight: layoutHeight,
        initialFaceUpSeconds: initialFaceUpSeconds,
        nonMatchingCardsFaceUpSeconds: nonMatchingCardsFaceUpSeconds,
        durationSeconds: durationSeconds,
        cards: cards ?? this.cards,
        state: state ?? this.state,
        cardMatchCount: cardMatchCount ?? this.cardMatchCount,
      );
}
