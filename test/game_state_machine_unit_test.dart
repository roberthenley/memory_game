import 'package:memory_game/domain/game_logic/game_machine_state.dart';
import 'package:memory_game/domain/game_logic/game_state_machine.dart';
import 'package:memory_game/domain/models/card_faces.dart';
import 'package:memory_game/domain/models/card_model.dart';
import 'package:memory_game/domain/models/game_model.dart';
import 'package:test/test.dart';

void main() {
  late GameModel startingGameModel;

  /// Set up starting game model as a 2x2 card grid in newGame state.
  setUp(() {
    List<String> cardAssetPaths = CardFaces.getFirstCardAssetPaths(2);
    CardModel c11 = CardModel(
      cardFaceAssetPath: cardAssetPaths.first,
      isFaceUp: true,
    );
    CardModel c12 = CardModel(
      cardFaceAssetPath: cardAssetPaths.last,
      isFaceUp: true,
    );
    CardModel c21 = CardModel(
      cardFaceAssetPath: cardAssetPaths.last,
      isFaceUp: true,
    );
    CardModel c22 = CardModel(
      cardFaceAssetPath: cardAssetPaths.first,
      isFaceUp: true,
    );
    List<CardModel> cardsFaceUp = [c11, c12, c21, c22];
    startingGameModel = GameModel(
      layoutWidth: 2,
      layoutHeight: 2,
      cards: cardsFaceUp,
      state: GameMachineState.newGame,
      cardMatchCount: 0,
    );
  });

  group('Happy path transitions do what is expected', () {
    test('newGame to noCardsSelected turns all cards face down', () {
      GameModel newModel = GameStateMachine.setNextState(
        model: startingGameModel,
        newState: GameMachineState.noCardsSelected,
      );
      expect(newModel.state, GameMachineState.noCardsSelected);
      expect(newModel.cardMatchCount, 0);
      expect(newModel.cards, predicate((List<CardModel> cards) {
        for (CardModel card in cards) {
          if (card.isFaceUp ||
              !card.isSelectable ||
              card.isSelected ||
              card.isMatched) {
            return false;
          }
        }
        return true;
      }));
    });

    test('noCardsSelected plus first card turns card face up', () {
      GameModel gameModel = startingGameModel.copyWithCardFlags(
        newState: GameMachineState.noCardsSelected,
        isFaceUp: false,
        isSelectable: true,
        isSelected: false,
        isMatched: false,
        newCardMatchCount: 0,
      );
      GameModel newModel = GameStateMachine.nextStateFromCard(
        model: gameModel,
        cardSelected: gameModel.cards[0],
      );
      expect(newModel.state, GameMachineState.oneCardSelected);
      expect(newModel.cardMatchCount, 0);
      expect(newModel.cards, predicate(
        (List<CardModel> cards) {
          for (CardModel card in cards) {
            if (card == newModel.cards[0]) {
              if (!card.isFaceUp ||
                  card.isSelectable ||
                  card.isMatched ||
                  !card.isSelected) {
                return false;
              }
            } else {
              if (card.isFaceUp ||
                  !card.isSelectable ||
                  card.isSelected ||
                  card.isMatched) {
                return false;
              }
            }
          }
          return true;
        },
      ));
    });

    test(
        'oneCardSelected plus matching card shows cards face up and highlighted',
        () {
      GameModel gameModel = startingGameModel.copyWithCardFlags(
        newState: GameMachineState.noCardsSelected,
        isFaceUp: false,
        isSelectable: true,
        isSelected: false,
        isMatched: false,
        newCardMatchCount: 0,
      );
      gameModel = gameModel.copyWithNewCards(
        newState: GameMachineState.oneCardSelected,
        replacementCards: {
          gameModel.cards[0]: gameModel.cards[0].copyWith(
            isFaceUp: true,
            isSelectable: false,
            isSelected: true,
          )
        },
      );
      GameModel newModel = GameStateMachine.nextStateFromCard(
        model: gameModel,
        cardSelected: gameModel.cards[3],
      );
      expect(newModel.state, GameMachineState.noCardsSelected);
      expect(newModel.cardMatchCount, 1);
      expect(newModel.cards, predicate(
        (List<CardModel> cards) {
          for (CardModel card in cards) {
            if (card == newModel.cards[0] || card == newModel.cards[3]) {
              if (!card.isFaceUp ||
                  card.isSelectable ||
                  !card.isMatched ||
                  card.isSelected) {
                return false;
              }
            } else {
              if (card.isFaceUp ||
                  !card.isSelectable ||
                  card.isSelected ||
                  card.isMatched) {
                return false;
              }
            }
          }
          return true;
        },
      ));
    });

    test(
        'oneCardSelected plus non-matching card shows cards face up and not highlighted',
        () {
      GameModel gameModel = startingGameModel.copyWithCardFlags(
        newState: GameMachineState.noCardsSelected,
        isFaceUp: false,
        isSelectable: true,
        isSelected: false,
        isMatched: false,
        newCardMatchCount: 0,
      );
      gameModel = gameModel.copyWithNewCards(
        newState: GameMachineState.oneCardSelected,
        replacementCards: {
          gameModel.cards[0]: gameModel.cards[0].copyWith(
            isFaceUp: true,
            isSelectable: false,
            isSelected: true,
          )
        },
      );
      GameModel newModel = GameStateMachine.nextStateFromCard(
        model: gameModel,
        cardSelected: gameModel.cards[1],
      );
      expect(newModel.state, GameMachineState.twoCardsSelectedNotMatching);
      expect(newModel.cardMatchCount, 0);
      expect(newModel.cards, predicate(
        (List<CardModel> cards) {
          for (CardModel card in cards) {
            if (card == newModel.cards[0] || card == newModel.cards[1]) {
              if (!card.isFaceUp ||
                  card.isSelectable ||
                  card.isMatched ||
                  !card.isSelected) {
                return false;
              }
            } else {
              if (card.isFaceUp ||
                  !card.isSelectable ||
                  card.isSelected ||
                  card.isMatched) {
                return false;
              }
            }
          }
          return true;
        },
      ));
    });

    test(
        'two non-matching cards and state set to noCardsSelected flips cards over',
        () {
      GameModel gameModel = startingGameModel.copyWithNewCards(
        newState: GameMachineState.twoCardsSelectedNotMatching,
        newMatchCount: 0,
        replacementCards: {
          startingGameModel.cards[0]: startingGameModel.cards[0].copyWith(
            isFaceUp: true,
            isSelectable: false,
            isSelected: true,
            isMatched: false,
          ),
          startingGameModel.cards[1]: startingGameModel.cards[1].copyWith(
            isFaceUp: true,
            isSelectable: false,
            isSelected: true,
            isMatched: false,
          ),
          startingGameModel.cards[2]: startingGameModel.cards[2].copyWith(
            isFaceUp: false,
            isSelectable: true,
            isSelected: false,
            isMatched: false,
          ),
          startingGameModel.cards[3]: startingGameModel.cards[3].copyWith(
            isFaceUp: false,
            isSelectable: true,
            isSelected: false,
            isMatched: false,
          ),
        },
      );
      GameModel newModel = GameStateMachine.setNextState(
        model: gameModel,
        newState: GameMachineState.noCardsSelected,
      );
      expect(newModel.state, GameMachineState.noCardsSelected);
      expect(newModel.cardMatchCount, 0);
      expect(newModel.cards, predicate(
        (List<CardModel> cards) {
          for (CardModel card in cards) {
            if (card.isFaceUp ||
                !card.isSelectable ||
                card.isMatched ||
                card.isSelected) {
              return false;
            }
          }
          return true;
        },
      ));
    });

    test(
        'can pick a card with two non-matching cards displayed and it is selected',
        () {
      GameModel gameModel = startingGameModel.copyWithNewCards(
        newState: GameMachineState.twoCardsSelectedNotMatching,
        newMatchCount: 0,
        replacementCards: {
          startingGameModel.cards[0]: startingGameModel.cards[0].copyWith(
            isFaceUp: true,
            isSelectable: false,
            isSelected: true,
            isMatched: false,
          ),
          startingGameModel.cards[1]: startingGameModel.cards[1].copyWith(
            isFaceUp: true,
            isSelectable: false,
            isSelected: true,
            isMatched: false,
          ),
          startingGameModel.cards[2]: startingGameModel.cards[2].copyWith(
            isFaceUp: false,
            isSelectable: true,
            isSelected: false,
            isMatched: false,
          ),
          startingGameModel.cards[3]: startingGameModel.cards[3].copyWith(
            isFaceUp: false,
            isSelectable: true,
            isSelected: false,
            isMatched: false,
          ),
        },
      );
      GameModel newModel = GameStateMachine.nextStateFromCard(
        model: gameModel,
        cardSelected: gameModel.cards[3],
      );
      expect(newModel.state, GameMachineState.oneCardSelected);
      expect(newModel.cardMatchCount, 0);
      expect(newModel.cards, predicate(
        (List<CardModel> cards) {
          for (CardModel card in cards) {
            if (card == newModel.cards[3]) {
              if (!card.isFaceUp ||
                  card.isSelectable ||
                  card.isMatched ||
                  !card.isSelected) {
                return false;
              }
            } else {
              if (card.isFaceUp ||
                  !card.isSelectable ||
                  card.isMatched ||
                  card.isSelected) {
                return false;
              }
            }
          }
          return true;
        },
      ));
    });

    test(
        'the last matching card shows all cards face up and highlighted and game won',
        () {
      GameModel gameModel = startingGameModel.copyWithNewCards(
        newState: GameMachineState.oneCardSelected,
        newMatchCount: 1,
        replacementCards: {
          startingGameModel.cards[0]: startingGameModel.cards[0].copyWith(
            isFaceUp: true,
            isSelectable: false,
            isSelected: false,
            isMatched: true,
          ),
          startingGameModel.cards[1]: startingGameModel.cards[1].copyWith(
            isFaceUp: true,
            isSelectable: false,
            isSelected: true,
            isMatched: false,
          ),
          startingGameModel.cards[2]: startingGameModel.cards[2].copyWith(
            isFaceUp: false,
            isSelectable: true,
            isSelected: false,
            isMatched: false,
          ),
          startingGameModel.cards[3]: startingGameModel.cards[3].copyWith(
            isFaceUp: true,
            isSelectable: false,
            isSelected: false,
            isMatched: true,
          ),
        },
      );
      GameModel newModel = GameStateMachine.nextStateFromCard(
        model: gameModel,
        cardSelected: gameModel.cards[2],
      );
      expect(newModel.state, GameMachineState.wonGame);
      expect(newModel.cardMatchCount, 2);
      expect(newModel.cards, predicate(
        (List<CardModel> cards) {
          for (CardModel card in cards) {
            if (!card.isFaceUp ||
                card.isSelectable ||
                !card.isMatched ||
                card.isSelected) {
              return false;
            }
          }
          return true;
        },
      ));
    });
  });

  group('Transitions to lostGame show all cards face up, non-selectable', () {
    test('newGame to lostGame shows all cards face up, non-selectable', () {
      GameModel newModel = GameStateMachine.setNextState(
        model: startingGameModel,
        newState: GameMachineState.lostGame,
      );
      _testLostGame(newModel);
    });

    test('noCardsSelected to lostGame shows all cards face up, non-selectable',
        () {
      GameModel newModel = GameStateMachine.setNextState(
        model:
            startingGameModel.copyWith(state: GameMachineState.noCardsSelected),
        newState: GameMachineState.lostGame,
      );
      _testLostGame(newModel);
    });

    test('oneCardSelected to lostGame shows all cards face up, non-selectable',
        () {
      GameModel newModel = GameStateMachine.setNextState(
        model:
            startingGameModel.copyWith(state: GameMachineState.oneCardSelected),
        newState: GameMachineState.lostGame,
      );
      _testLostGame(newModel);
    });

    test(
        'twoCardsSelectedNotMatching to lostGame shows all cards face up, non-selectable',
        () {
      GameModel newModel = GameStateMachine.setNextState(
        model: startingGameModel.copyWith(
            state: GameMachineState.twoCardsSelectedNotMatching),
        newState: GameMachineState.lostGame,
      );
      _testLostGame(newModel);
    });
  });

  group('Unexpected state transitions throw an exception', () {
    test(
        'newGame to any state other than lostGame or noCardsSelected throws Exception',
        () {
      _setNewGameStateThrowsException(startingGameModel);
      _setOneCardSelectedGameStateThrowsException(startingGameModel);
      _setTwoCardsSelectedNotMatchingThrowsException(startingGameModel);
      _setWonGameStateThrowsException(startingGameModel);
    });

    test('newGame plus card selected throws Exception', () {
      expect(
        () {
          GameStateMachine.nextStateFromCard(
            model: startingGameModel,
            cardSelected: startingGameModel.cards[0],
          );
        },
        throwsException,
      );
    });

    test('noCardSelected to any state other than lostGame throws Exception',
        () {
      GameModel gameModel =
          startingGameModel.copyWith(state: GameMachineState.noCardsSelected);

      _setNewGameStateThrowsException(gameModel);
      _setNoCardsSelectedGameStateThrowsException(gameModel);
      _setOneCardSelectedGameStateThrowsException(gameModel);
      _setTwoCardsSelectedNotMatchingThrowsException(gameModel);
      _setWonGameStateThrowsException(gameModel);
    });

    test('oneCardSelected to any state other than lostGame throws Exception',
        () {
      GameModel gameModel =
          startingGameModel.copyWith(state: GameMachineState.oneCardSelected);

      _setNewGameStateThrowsException(gameModel);
      _setNoCardsSelectedGameStateThrowsException(gameModel);
      _setOneCardSelectedGameStateThrowsException(gameModel);
      _setTwoCardsSelectedNotMatchingThrowsException(gameModel);
      _setWonGameStateThrowsException(gameModel);
    });

    test(
        'twoCardsSelectedNotMatching to any state other than lostGame or noCardsSelected throws Exception',
        () {
      GameModel gameModel = startingGameModel.copyWith(
          state: GameMachineState.twoCardsSelectedNotMatching);
      _setNewGameStateThrowsException(gameModel);
      _setOneCardSelectedGameStateThrowsException(gameModel);
      _setTwoCardsSelectedNotMatchingThrowsException(gameModel);
      _setWonGameStateThrowsException(gameModel);
    });
  });
}

void _setNoCardsSelectedGameStateThrowsException(GameModel gameModel) {
  expect(
      () => {
            GameStateMachine.setNextState(
              model: gameModel,
              newState: GameMachineState.noCardsSelected,
            )
          },
      throwsException);
}

void _setWonGameStateThrowsException(GameModel gameModel) {
  expect(
      () => {
            GameStateMachine.setNextState(
              model: gameModel,
              newState: GameMachineState.wonGame,
            )
          },
      throwsException);
}

void _setTwoCardsSelectedNotMatchingThrowsException(GameModel gameModel) {
  expect(
      () => {
            GameStateMachine.setNextState(
              model: gameModel,
              newState: GameMachineState.twoCardsSelectedNotMatching,
            )
          },
      throwsException);
}

void _setOneCardSelectedGameStateThrowsException(GameModel gameModel) {
  expect(
      () => {
            GameStateMachine.setNextState(
              model: gameModel,
              newState: GameMachineState.oneCardSelected,
            )
          },
      throwsException);
}

void _setNewGameStateThrowsException(GameModel gameModel) {
  expect(
      () => {
            GameStateMachine.setNextState(
              model: gameModel,
              newState: GameMachineState.newGame,
            )
          },
      throwsException);
}

void _testLostGame(GameModel newModel) {
  expect(newModel.state, GameMachineState.lostGame);
  expect(newModel.cardMatchCount, 0);
  expect(newModel.cards, predicate((List<CardModel> cards) {
    for (CardModel card in cards) {
      if (!card.isFaceUp ||
          card.isSelectable ||
          card.isSelected ||
          card.isMatched) {
        return false;
      }
    }
    return true;
  }));
}
