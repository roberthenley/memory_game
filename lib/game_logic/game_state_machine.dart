import 'package:memory_game/models/card_model.dart';
import 'package:memory_game/models/game_model.dart';
import 'package:memory_game/models/game_state.dart';
import 'package:meta/meta.dart';

class GameStateMachine {
  /// Set the next game machine state from a new GameState value.
  ///
  /// This method is called by game timers.
  static GameModel setNextState({
    @required GameModel model,
    GameState newState,
  }) =>
      _nextState(model: model, newState: newState);

  /// Set the next game machine state from a new card selection.
  ///
  /// This method is called when the user selects a card.
  static GameModel nextStateFromCard({
    @required GameModel model,
    CardModel cardSelected,
  }) =>
      _nextState(model: model, cardSelected: cardSelected);

  /// Handles all game machine state transitions.
  ///
  /// This method is private and guarded against calls with both a new state and
  /// a card selection.
  static GameModel _nextState({
    @required GameModel model,
    GameState newState,
    CardModel cardSelected,
  }) {
    assert(newState == null || cardSelected == null);
    // print(
    //   '_nextState: current state: ${model.state}, new state: $newState, cardSelected: ${cardSelected?.cardFaceAssetPath ?? "null"}',
    // );

    if (model.state == GameState.newGame &&
        newState == GameState.noCardsSelected) {
      // print('_nextState case 1: transition to cards face-down');
      // Turn all cards face down and make them selectable.
      return model.copyWithCardFlags(
        newState: newState,
        isFaceUp: false,
        isSelectable: true,
      );
    }
    if (model.state == GameState.noCardsSelected && cardSelected != null) {
      // print('_nextState case 2: first card selection');
      return _handleFirstCardSelection(cardSelected, model);
    }
    if (model.state == GameState.oneCardSelected && cardSelected != null) {
      // print('_nextState case 3: second card selection');
      return _handleSecondCardSelection(model, cardSelected);
    }
    if (model.state == GameState.twoCardsSelectedNotMatching &&
        cardSelected != null) {
      // print(
      //     '_nextState case 4: selected a card while 2 non-matching cards are displayed');
      return _handleCardSelectionWhileNonMatchingCardsDisplayed(
          model, cardSelected);
    }
    if (model.state == GameState.twoCardsSelectedNotMatching &&
        newState == GameState.noCardsSelected) {
      // print('_nextState case 5: flip 2 non-matching cards face-down');
      return _handleFlippingNonMatchingCardsFaceDown(model, newState);
    }
    if (model.state == GameState.wonGame) {
      // print('_nextState case 6: game won already, no-op');
      return model; // No-op
    }
    if (newState == GameState.lostGame) {
      if (model.state == GameState.lostGame) {
        // print('_nextState case 7: game lost already, no-op');
        return model; // No-op
      }
      // print('_nextState case 8: game was just lost');
      // Flip all cards face-up and unselectable.
      return model.copyWithCardFlags(
        newState: GameState.lostGame,
        isFaceUp: true,
        isSelectable: false,
      );
    }
    // print(
    //     'Impossible game state: current state: ${model.state}, new state: $newState, cardSelected: ${cardSelected != null}');
    throw Exception(
        'Impossible game state: current state: ${model.state}, new state: $newState, cardSelected: ${cardSelected != null}');
  }

  /// Handle the first card selected.
  ///
  /// Select the indicated card, turning it face up and marking it selected
  /// and unselectable.
  static GameModel _handleFirstCardSelection(
      CardModel cardSelected, GameModel model) {
    CardModel newCard = cardSelected.copyWith(
        isFaceUp: true, isSelected: true, isSelectable: false);
    return model.copyWithNewCards(
      newState: GameState.oneCardSelected,
      replacementCards: {cardSelected: newCard},
    );
  }

  /// Handle the second card selected.
  ///
  /// Select the indicated card, turning it face up and making it
  /// unselectable. If both it and the first selected card match,
  /// mark them as matching, increment the match count and determine if
  /// the game is won; set the new game state to GameState.WON,
  /// GameState.IN_GAME_NO_CARDS_SELECTED or
  /// GameState.IN_GAME_2_CARDS_SELECTED_NO_MATCH. If the later, the UI
  /// layer has to set a timer to flip the cards back over and continue.
  static GameModel _handleSecondCardSelection(
      GameModel model, CardModel cardSelected) {
    CardModel firstCardSelected = model.getFirstSelectedCard();
    assert(firstCardSelected != null);
    // print(
    //     '_handleSecondCardSelection: firstCardSelected = ${firstCardSelected?.cardFaceAssetPath ?? "none"}');
    bool isMatch =
        firstCardSelected.cardFaceAssetPath == cardSelected.cardFaceAssetPath;
    // print('_handleSecondCardSelection: isMatch = $isMatch');
    CardModel newCardSelected = cardSelected.copyWith(
        isFaceUp: true,
        isSelected:
            !isMatch, // needed so only non-matching cards are flipped face-down
        isSelectable: false,
        isMatched: isMatch);
    // Note: the other cards are not marked as unselectable during
    // the time when the non-matching cards are displayed. Is that a bug or a
    // feature?! The game could skip from IN_GAME_2_CARDS_SELECTED_NO_MATCH to
    // IN_GAME_1_CARD_SELECTED directly...
    if (isMatch) {
      GameState newState = model.cardMatchCount + 1 == model.numberOfUniqueCards
          ? GameState.wonGame
          : GameState.noCardsSelected;
      // print('_handleSecondCardSelection: isMatch; new game state = $newState');
      return model.copyWithNewCards(
        newState: newState,
        replacementCards: {
          firstCardSelected: firstCardSelected.copyWith(
            isMatched: true,
            isSelected: false,
            isSelectable: false,
          ),
          cardSelected: newCardSelected,
        },
        newMatchCount: model.cardMatchCount + 1,
      );
    } else {
      // print(
      //     '_handleSecondCardSelection: isMatch false; new game state = TWO_CARDS_SELECTED_NOT_MATCHING');
      return model.copyWithNewCards(
        newState: GameState.twoCardsSelectedNotMatching,
        replacementCards: {cardSelected: newCardSelected},
      );
    }
  }

  /// Flips all non-matching cards face-down again.
  ///
  /// Called from _handleCardSelectionWhileNonMatchingCardsDisplayed() and
  /// _handleFlippingNonMatchingCardsFaceDown.
  static Map<CardModel, CardModel> _flipNonMatchingCards(GameModel model) {
    // print('_flipNonMatchingCards');
    Iterable<CardModel> selectedCards = model.getAllSelectedCards();
    assert(selectedCards.length == 2);
    Map<CardModel, CardModel> replacementCards = Map();
    for (CardModel card in selectedCards) {
      // print('_flipNonMatchingCards - flipping ${card.cardFaceAssetPath}');
      replacementCards.putIfAbsent(
        card,
        () => card.copyWith(
          isFaceUp: false,
          isSelected: false,
          isSelectable: true,
        ),
      );
    }
    return replacementCards;
  }

  /// Handle the case where the user was quick on the draw and short-circuited
  /// the timer to flip the non-matching cards over.
  ///
  /// Flips the previously selected cards face-down and flips the newly selected
  /// card face-up.
  static GameModel _handleCardSelectionWhileNonMatchingCardsDisplayed(
      GameModel model, CardModel cardSelected) {
    // print('_handleCardSelectionWhileNonMatchingCardsDisplayed');
    Map<CardModel, CardModel> replacementCards = _flipNonMatchingCards(model);
    CardModel newCard = cardSelected.copyWith(
        isFaceUp: true, isSelected: true, isSelectable: false);
    // print(
    //     '_handleCardSelectionWhileNonMatchingCardsDisplayed new card is ${cardSelected.cardFaceAssetPath}');
    replacementCards.putIfAbsent(cardSelected, () => newCard);
    return model.copyWithNewCards(
      newState: GameState.oneCardSelected,
      replacementCards: replacementCards,
    );
  }

  /// Handle flipping non-matching cards face down.
  ///
  /// Timer switching state. Turn non-matching cards face-down again.
  static GameModel _handleFlippingNonMatchingCardsFaceDown(
      GameModel model, GameState newState) {
    // print('_handleFlippingNonMatchingCardsFaceDown');
    Map<CardModel, CardModel> replacementCards = _flipNonMatchingCards(model);
    return model.copyWithNewCards(
      newState: newState,
      replacementCards: replacementCards,
    );
  }
}
