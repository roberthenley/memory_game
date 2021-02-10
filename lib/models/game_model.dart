import 'package:meta/meta.dart';

import 'card_assets.dart';
import 'card_model.dart';
import 'game_settings.dart';
import 'game_state.dart';

class GameModel {
  final List<CardModel> cards;
  final GameState state;
  final int cardMatchCount;
  // TODO: Game timer

  GameModel({
    @required this.cards,
    @required this.state,
    @required this.cardMatchCount,
  });

  static GameModel newGame() {
    // Initialize game board with two copies of each cards.
    // Cards are face-up for the initial display state.
    List<String> cardPaths =
        CardAssets().getCardAssetPaths(GameSettings.numberOfUniqueCards);
    List<CardModel> cards = [];
    for (String cardPath in cardPaths) {
      cards.add(CardModel(cardFace: cardPath, isFaceUp: true));
      cards.add(CardModel(cardFace: cardPath, isFaceUp: true));
    }
    cards.shuffle();
    return GameModel(
      cards: cards,
      state: GameState.NEW_GAME,
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
    for (CardModel card in this.cards) {
      newCards.add(card.copyWith(
        isFaceUp: isFaceUp,
        isMatched: isMatched,
        isSelectable: isSelectable,
        isSelected: isSelected,
      ));
    }
    return GameModel(
      cards: newCards,
      state: newState ?? this.state,
      cardMatchCount: newCardMatchCount ?? this.cardMatchCount,
    );
  }

  GameModel copyWithNewCards({
    @required GameState newState,
    @required Map<CardModel, CardModel> replacementCards,
    int newMatchCount,
  }) {
    // replace the modified cards and set the new game state
    return GameModel(
      cards: replaceCardsInList(this.cards, replacementCards),
      state: newState,
      cardMatchCount: newMatchCount ?? this.cardMatchCount,
    );
  }

  // static List<CardModel> replaceCardInList(
  //     List<CardModel> cards,
  //     CardModel oldCard,
  //     CardModel newCard,) {
  //   int cardIndex = cards.indexOf(oldCard);
  //   List<CardModel> newCards = List<CardModel>.from(cards);
  //   newCards[cardIndex] = newCard;
  //   return newCards;
  // }

  static List<CardModel> replaceCardsInList(
    @required List<CardModel> cards,
    @required Map<CardModel, CardModel> replacementCards,
  ) {
    List<CardModel> newCardList = List<CardModel>.from(cards);
    replacementCards.forEach((CardModel oldCard, CardModel newCard) {
      int cardIndex = cards.indexOf(oldCard);
      newCardList[cardIndex] = newCard;
    });
    return newCardList;
  }

  CardModel getSelectedCard() {
    return this.cards.firstWhere((element) => element.isSelected);
  }

  Iterable<CardModel> getAllSelectedCards() {
    return this.cards.where((element) => element.isSelected);
  }

  GameModel copyWith({
    List<CardModel> cards,
    GameState state,
    int cardMatchCount,
  }) =>
      GameModel(
        cards: cards ?? this.cards,
        state: state ?? this.state,
        cardMatchCount: cardMatchCount ?? this.cardMatchCount,
      );
}
