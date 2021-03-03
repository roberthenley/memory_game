import 'package:meta/meta.dart';

import '../game_logic/game_machine_state.dart';
import 'card_faces.dart';
import 'card_model.dart';
import 'default_game_settings.dart';

/// Models the state of a game of Memory, including game settings.
///
/// Immutable. Game state and cards can be modified with copyWith...() methods.
/// However, game settings, especially the number of cards, are unchangeable
/// after model construction.
class GameModel {
  final int layoutWidth;
  final int layoutHeight;
  final int initialFaceUpSeconds;
  final int nonMatchingCardsFaceUpSeconds;
  final int _durationSeconds;
  final List<CardModel> cards;
  final GameMachineState state;
  final int cardMatchCount;
  final String announcement;

  int get numberOfCards {
    return layoutHeight * layoutWidth;
  }

  int get numberOfUniqueCards {
    return (numberOfCards / 2).floor();
  }

  int get gameDurationSeconds {
    return this._durationSeconds ?? this.numberOfCards * 6;
  }

  GameModel({
    this.layoutWidth = DefaultGameSettings.layoutWidth,
    this.layoutHeight = DefaultGameSettings.layoutHeight,
    this.initialFaceUpSeconds = DefaultGameSettings.initialFaceUpSeconds,
    this.nonMatchingCardsFaceUpSeconds =
        DefaultGameSettings.nonMatchingCardsFaceUpSeconds,
    int durationSeconds,
    @required this.cards,
    @required this.state,
    @required this.cardMatchCount,
    this.announcement,
  }) : this._durationSeconds = durationSeconds;

  /// Create a new game model with random card faces in random order.
  ///
  /// A layout with an even number of cards is required.
  /// Gets random card face assets from CardFaces.
  /// Creates two copies of each card and shuffles the resulting list of
  /// CardModels.
  static GameModel newGame({
    int layoutWidth = DefaultGameSettings.layoutWidth,
    int layoutHeight = DefaultGameSettings.layoutHeight,
    int initialFaceUpSeconds = DefaultGameSettings.initialFaceUpSeconds,
    int nonMatchingCardsFaceUpSeconds =
        DefaultGameSettings.nonMatchingCardsFaceUpSeconds,
    int durationSeconds,
  }) {
    assert((layoutWidth * layoutHeight) % 2 == 0);

    // Initialize game board with two copies of each cards.
    // Cards are face-up for the initial display state.
    List<String> cardPaths = CardFaces.getRandomCardAssetPaths(
        (layoutWidth * layoutHeight / 2).floor());
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
      state: GameMachineState.newGame,
      cardMatchCount: 0,
      announcement: _announceCardLayout(layoutWidth, cards),
    );
  }

  /// Announce the full face-up card layout for accessibility.
  static String _announceCardLayout(int boardWidth, List<CardModel> cards) {
    // Announce the game cards.
    List<String> messages = [' The game shows the following cards:'];
    messages.addAll(cards.asMap().map((int index, CardModel card) {
      final String rowId = index % boardWidth == 0
          ? ' row ${(index / boardWidth).floor() + 1}:'
          : '';
      return MapEntry(
        index,
        '$rowId ${CardFaces.getCardName(card.cardFaceAssetPath)},',
      );
    }).values);

    String announcement = messages.join('');
    print('GameStateMachine: _announceCardLayout(): $announcement');
    return announcement;
  }

  /// Create a new game model by setting all cards to a new state and optionally
  /// changing the game state and/or the count of matched game cards.
  ///
  /// Clears any existing announcement.
  GameModel copyWithCardFlags({
    GameMachineState newState,
    int newCardMatchCount,
    bool isFaceUp,
    bool isMatched,
    bool isSelectable,
    bool isSelected,
    String announcement,
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
      announcement: announcement,
    );
  }

  /// Create a new game state by replacing specific cards, changing the game
  /// state, and optionally changing the count of matched game cards.
  ///
  /// Clears any existing announcement.
  GameModel copyWithNewCards({
    @required GameMachineState newState,
    @required Map<CardModel, CardModel> replacementCards,
    int newMatchCount,
    String announcement,
  }) {
    // replace the modified cards and set the new game state
    return this.copyWith(
      cards: _replaceCardsInList(cards, replacementCards),
      state: newState,
      cardMatchCount: newMatchCount ?? cardMatchCount,
      announcement: announcement,
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

  /// Replace specific CardModels in a list, returning a new list.
  static List<CardModel> _replaceCardsInList(
    List<CardModel> cards,
    Map<CardModel, CardModel> replacementCards,
  ) {
    List<CardModel> newCardList = List<CardModel>.from(cards);
    replacementCards.forEach((CardModel oldCard, CardModel newCard) {
      int cardIndex = cards.indexOf(oldCard);
      if (cardIndex != -1) {
        newCardList[cardIndex] = newCard;
      }
    });
    return newCardList;
  }

  /// Get the first selected card.
  CardModel getFirstSelectedCard() {
    return cards.firstWhere((element) => element.isSelected,
        orElse: () => null);
  }

  /// Get all selected cards.
  Iterable<CardModel> getAllSelectedCards() {
    return cards.where((element) => element.isSelected);
  }

  /// Create a new game model by replacing all cards, game state, announcement,
  /// or the number of matched cards. Can not change game settings, especially
  /// card count.
  ///
  /// Preserves any existing announcement, so override that value if you want it
  /// cleared in the resulting copy.
  GameModel copyWith({
    List<CardModel> cards,
    GameMachineState state,
    int cardMatchCount,
    String announcement,
  }) {
    if (cards != null) {
      assert(layoutWidth * layoutHeight == cards.length);
    }
    return GameModel(
      layoutWidth: layoutWidth,
      layoutHeight: layoutHeight,
      initialFaceUpSeconds: initialFaceUpSeconds,
      nonMatchingCardsFaceUpSeconds: nonMatchingCardsFaceUpSeconds,
      durationSeconds: _durationSeconds,
      cards: cards ?? this.cards,
      state: state ?? this.state,
      cardMatchCount: cardMatchCount ?? this.cardMatchCount,
      announcement: announcement ?? this.announcement,
    );
  }
}
