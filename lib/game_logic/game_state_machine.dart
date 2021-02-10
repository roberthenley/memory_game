import 'package:memory_game/models/card_model.dart';
import 'package:memory_game/models/game_model.dart';
import 'package:memory_game/models/game_state.dart';
import 'package:meta/meta.dart';

class GameStateMachine {
  GameModel setNextState({
    @required GameModel model,
    GameState newState,
  }) =>
      _nextState(model: model, newState: newState);

  GameModel nextStateFromCard({
    @required GameModel model,
    CardModel cardSelected,
  }) =>
      _nextState(model: model, cardSelected: cardSelected);

  GameModel _nextState({
    @required GameModel model,
    GameState newState,
    CardModel cardSelected,
  }) {
    assert(newState == null || cardSelected == null);

    if (model.state == GameState.NEW_GAME &&
        newState == GameState.NO_CARDS_SELECTED) {
      // Turn all cards face down and make them selectable.
      return model.copyWithCardFlags(
        newState: newState,
        isFaceUp: false,
        isSelectable: true,
      );
    }
    if (model.state == GameState.NO_CARDS_SELECTED && cardSelected != null) {
      return handleFirstCardSelection(cardSelected, model);
    }
    if (model.state == GameState.ONE_CARD_SELECTED && cardSelected != null) {
      return handleSecondCardSelection(model, cardSelected);
    }
    if (model.state == GameState.TWO_CARDS_SELECTED_NOT_MATCHING &&
        cardSelected != null) {
      return handleCardSelectionWhileNonMatchingCardsDisplayed(
          model, cardSelected);
    }
    if (model.state == GameState.TWO_CARDS_SELECTED_NOT_MATCHING &&
        newState == GameState.NO_CARDS_SELECTED) {
      return handleFlippingNonMatchingCardsFaceDown(model, newState);
    }
    if (model.state == GameState.WON) {
      return model; // No-op
    }
    if (newState == GameState.LOST) {
      if (model.state == GameState.LOST) {
        return model; // No-op
      }
      // Flip all cards face-up and unselectable.
      return model.copyWithCardFlags(
        newState: GameState.LOST,
        isFaceUp: true,
        isSelectable: false,
      );
    }
    throw Exception(
        'Impossible game state: current state: ${model.state}, new state: ${newState}, cardSelected: ${cardSelected != null}');
  }

  GameModel handleFirstCardSelection(CardModel cardSelected, GameModel model) {
    // Select the indicated card, turning it face up and marking it selected
    // and unselectable.
    CardModel newCard = cardSelected.copyWith(
        isFaceUp: true, isSelected: true, isSelectable: false);
    return model.copyWithNewCards(
      newState: GameState.ONE_CARD_SELECTED,
      replacementCards: {cardSelected: newCard},
    );
  }

  GameModel handleSecondCardSelection(GameModel model, CardModel cardSelected) {
    // Select the indicated card, turning it face up and making it
    // unselectable. If both it and the first selected card match,
    // mark them as matching, increment the match count and determine if
    // the game is won; set the new game state to GameState.WON,
    // GameState.IN_GAME_NO_CARDS_SELECTED or
    // GameState.IN_GAME_2_CARDS_SELECTED_NO_MATCH. If the later, the UI
    // layer has to set a timer to flip the cards back over and continue.
    CardModel firstCardSelected = model.getSelectedCard();
    bool isMatch = firstCardSelected.cardFace == cardSelected.cardFace;
    CardModel newCardSelected = cardSelected.copyWith(
        isFaceUp: true,
        isSelected: true,
        isSelectable: false,
        isMatched: isMatch);
    // Defect: the other cards are not marked as unselectable during
    // the time when the non-matching cards are displayed. Or is that a
    // feature? The game could skip from IN_GAME_2_CARDS_SELECTED_NO_MATCH to
    // IN_GAME_1_CARD_SELECTED directly...
    if (isMatch) {
      GameState newState = model.cardMatchCount + 2 == model.cards.length
          ? GameState.WON
          : GameState.NO_CARDS_SELECTED;
      return model.copyWithNewCards(
        newState: newState,
        replacementCards: {
          firstCardSelected: firstCardSelected.copyWith(isMatched: true),
          cardSelected: newCardSelected,
        },
        newMatchCount: model.cardMatchCount + 2,
      );
    } else {
      return model.copyWithNewCards(
        newState: GameState.TWO_CARDS_SELECTED_NOT_MATCHING,
        replacementCards: {cardSelected: newCardSelected},
        newMatchCount: model.cardMatchCount + (isMatch ? 2 : 0),
      );
    }
  }

  Map<CardModel, CardModel> flipNonMatchingCards(GameModel model) {
    Iterable<CardModel> selectedCards = model.getAllSelectedCards();
    Map<CardModel, CardModel> replacementCards = Map();
    for (CardModel card in selectedCards) {
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

  GameModel handleCardSelectionWhileNonMatchingCardsDisplayed(
      GameModel model, CardModel cardSelected) {
    // User was quick on the draw and short-circuited the timer to flip the
    // non-matching cards over. Flip the previously selected cards face-down
    // and flip the newly selected card face-up.
    Map<CardModel, CardModel> replacementCards = flipNonMatchingCards(model);
    CardModel newCard = cardSelected.copyWith(
        isFaceUp: true, isSelected: true, isSelectable: false);
    replacementCards.putIfAbsent(cardSelected, () => newCard);
    return model.copyWithNewCards(
      newState: GameState.ONE_CARD_SELECTED,
      replacementCards: replacementCards,
    );
  }

  GameModel handleFlippingNonMatchingCardsFaceDown(
      GameModel model, GameState newState) {
    // Timer switching state. Turn non-matching cards face-down again.
    Map<CardModel, CardModel> replacementCards = flipNonMatchingCards(model);
    return model.copyWithNewCards(
      newState: newState,
      replacementCards: replacementCards,
    );
  }
}
