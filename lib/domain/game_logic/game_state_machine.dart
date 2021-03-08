import 'package:memory_game/domain/game_logic/game_machine_state.dart';
import 'package:memory_game/domain/models/card_faces.dart';
import 'package:memory_game/domain/models/card_model.dart';
import 'package:memory_game/domain/models/game_model.dart';

class GameStateMachine {
  /// Set the next game machine state from a new GameState value.
  ///
  /// This method is called by game timers.
  static GameModel setNextState({
    required GameModel model,
    required GameMachineState newState,
  }) =>
      _nextState(model: model, newState: newState);

  /// Set the next game machine state from a new card selection.
  ///
  /// This method is called when the user selects a card.
  static GameModel nextStateFromCard({
    required GameModel model,
    required CardModel cardSelected,
  }) =>
      _nextState(model: model, cardSelected: cardSelected);

  /// Handles all game machine state transitions.
  ///
  /// This method is private and guarded against calls with both a new state and
  /// a card selection.
  static GameModel _nextState({
    required GameModel model,
    GameMachineState? newState,
    CardModel? cardSelected,
  }) {
    assert(newState == null || cardSelected == null);
    assert(newState != null || cardSelected != null);
    // print(
    //   '_nextState: current state: ${model.state}, new state: $newState, cardSelected: ${cardSelected?.cardFaceAssetPath ?? "null"}',
    // );

    if (model.state == GameMachineState.newGame &&
        newState == GameMachineState.noCardsSelected) {
      // print('_nextState case 1: transition to cards face-down');
      // Turn all cards face down and make them selectable.
      return model.copyWithCardFlags(
        newState: newState,
        isFaceUp: false,
        isSelectable: true,
        announcement: "Begin game.",
      );
    }
    if (model.state == GameMachineState.noCardsSelected &&
        cardSelected != null) {
      // print('_nextState case 2: first card selection');
      return _handleFirstCardSelection(cardSelected, model);
    }
    if (model.state == GameMachineState.oneCardSelected &&
        cardSelected != null) {
      // print('_nextState case 3: second card selection');
      return _handleSecondCardSelection(model, cardSelected);
    }
    if (model.state == GameMachineState.twoCardsSelectedNotMatching &&
        cardSelected != null) {
      // print(
      //     '_nextState case 4: selected a card while 2 non-matching cards are displayed');
      return _handleCardSelectionWhileNonMatchingCardsDisplayed(
          model, cardSelected);
    }
    if (model.state == GameMachineState.twoCardsSelectedNotMatching &&
        newState == GameMachineState.noCardsSelected) {
      // print('_nextState case 5: flip 2 non-matching cards face-down');
      return _handleFlippingNonMatchingCardsFaceDown(model, newState!);
    }
    if (model.state == GameMachineState.wonGame) {
      // print('_nextState case 6: game won already, no-op');
      return model; // No-op
    }
    if (newState == GameMachineState.lostGame) {
      if (model.state == GameMachineState.lostGame) {
        // print('_nextState case 7: game lost already, no-op');
        return model; // No-op
      }
      // print('_nextState case 8: game was just lost');
      // Flip all cards face-up and unselectable.
      return model.copyWithCardFlags(
        newState: GameMachineState.lostGame,
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
      newState: GameMachineState.oneCardSelected,
      replacementCards: {cardSelected: newCard},
      announcement: _announceOneCardSelected(cardSelected),
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
    List<CardModel> cards = model.getAllSelectedCards().toList(growable: false);
    assert(cards.length == 1);
    CardModel firstCardSelected =
        cards.first; // Note: Will crash if no selected cards.
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
      GameMachineState newState =
          model.cardMatchCount + 1 == model.numberOfUniqueCards
              ? GameMachineState.wonGame
              : GameMachineState.noCardsSelected;
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
        announcement: _announceTwoCardsMatching(model, cardSelected),
      );
    } else {
      // print(
      //     '_handleSecondCardSelection: isMatch false; new game state = TWO_CARDS_SELECTED_NOT_MATCHING');
      return model.copyWithNewCards(
        newState: GameMachineState.twoCardsSelectedNotMatching,
        replacementCards: {cardSelected: newCardSelected},
        announcement:
            _announceTwoCardsNotMatching(firstCardSelected, cardSelected),
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
      newState: GameMachineState.oneCardSelected,
      replacementCards: replacementCards,
      announcement: _announceOneCardSelected(cardSelected),
    );
  }

  /// Handle flipping non-matching cards face down.
  ///
  /// Timer switching state. Turn non-matching cards face-down again.
  static GameModel _handleFlippingNonMatchingCardsFaceDown(
      GameModel model, GameMachineState newState) {
    // print('_handleFlippingNonMatchingCardsFaceDown');
    Map<CardModel, CardModel> replacementCards = _flipNonMatchingCards(model);
    return model.copyWithNewCards(
      newState: newState,
      replacementCards: replacementCards,
    );
  }

  static String _announceOneCardSelected(CardModel card) {
    final String cardName = CardFaces.getCardName(card.cardFaceAssetPath);
    final String announcement = 'Selected $cardName.';
    // print('GameStateMachine: _announceOneCardSelected(): $announcement');
    return announcement;
  }

  static String _announceTwoCardsNotMatching(CardModel card1, CardModel card2) {
    final String firstCardName = CardFaces.getCardName(card1.cardFaceAssetPath);
    final String secondCardName =
        CardFaces.getCardName(card2.cardFaceAssetPath);
    final String announcement =
        'Selected $firstCardName and $secondCardName which do not match.';
    // print('GameStateMachine: _announceTwoCardsNotMatching(): $announcement');
    return announcement;
  }

  static String _announceTwoCardsMatching(GameModel gameModel, CardModel card) {
    final String cardName = CardFaces.getCardName(card.cardFaceAssetPath);
    final String announcement =
        'Matched two $cardName cards. Score is now ${gameModel.cardMatchCount + 1} out of ${gameModel.numberOfUniqueCards}.';
    // print('GameStateMachine: _announceTwoCardsMatching(): $announcement');
    return announcement;
  }
}
