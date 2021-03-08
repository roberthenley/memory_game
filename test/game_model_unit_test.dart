import 'package:memory_game/domain/game_logic/game_machine_state.dart';
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

  test('No game duration defaults to 6 seconds per card', () {
    // Assumes 2x2 starting game with game duration not specified.
    expect(startingGameModel.gameDurationSeconds, 24);
  });

  test('Game duration override is honored', () {
    GameModel model = GameModel(
      layoutWidth: 2,
      layoutHeight: 2,
      cards: startingGameModel.cards,
      state: GameMachineState.newGame,
      cardMatchCount: 0,
      durationSeconds: 10,
    );
    expect(model.gameDurationSeconds, 10);
  });

  test('newGame produces pairs of the same card', () {
    GameModel model = GameModel.newGame(layoutWidth: 2, layoutHeight: 2);
    bool match01 = model.compareCards(0, 1);
    bool match02 = model.compareCards(0, 2);
    bool match03 = model.compareCards(0, 3);
    bool match12 = model.compareCards(1, 2);
    bool match13 = model.compareCards(1, 3);
    bool match23 = model.compareCards(2, 3);
    bool case1 = match01 && match23 && !match02;
    bool case2 = match02 && match13 && !match01;
    bool case3 = match03 && match12 && !match01;
    expect(case1 || case2 || case3, true);
  });

  test('copyWithCardFlags changes given values', () {
    var newGame = startingGameModel.copyWithCardFlags(
      newState: GameMachineState.noCardsSelected,
      newCardMatchCount: 2,
      isFaceUp: false,
      isMatched: true,
      isSelected: true,
      isSelectable: true,
    );
    expect(newGame.state, GameMachineState.noCardsSelected);
    expect(newGame.cardMatchCount, 2);
    expect(newGame.cards.every((card) => card.isFaceUp), false);
    expect(newGame.cards.every((card) => card.isMatched), true);
    expect(newGame.cards.every((card) => card.isSelected), true);
    expect(newGame.cards.every((card) => card.isSelectable), true);
  });

  test('copyWithCardFlags does not change values not given', () {
    var gameWithNoChanges = startingGameModel.copyWithCardFlags();
    expect(gameWithNoChanges.state, GameMachineState.newGame);
    expect(gameWithNoChanges.cardMatchCount, 0);
    expect(gameWithNoChanges.cards.every((card) => card.isFaceUp), true);
    expect(gameWithNoChanges.cards.every((card) => card.isMatched), false);
    expect(gameWithNoChanges.cards.every((card) => card.isSelected), false);
    expect(gameWithNoChanges.cards.every((card) => card.isSelectable), false);

    var gameWithOneFlagChanged =
        startingGameModel.copyWithCardFlags(isFaceUp: false);
    expect(gameWithOneFlagChanged.state, GameMachineState.newGame);
    expect(gameWithOneFlagChanged.cardMatchCount, 0);
    expect(gameWithOneFlagChanged.cards.every((card) => card.isFaceUp), false);
    expect(gameWithOneFlagChanged.cards.every((card) => card.isMatched), false);
    expect(
        gameWithOneFlagChanged.cards.every((card) => card.isSelected), false);
    expect(
        gameWithOneFlagChanged.cards.every((card) => card.isSelectable), false);

    var gameWithStateChanged =
        startingGameModel.copyWithCardFlags(newState: GameMachineState.wonGame);
    expect(gameWithStateChanged.state, GameMachineState.wonGame);
    expect(gameWithStateChanged.cardMatchCount, 0);
    expect(gameWithStateChanged.cards.every((card) => card.isFaceUp), true);
    expect(gameWithStateChanged.cards.every((card) => card.isMatched), false);
    expect(gameWithStateChanged.cards.every((card) => card.isSelected), false);
    expect(
        gameWithStateChanged.cards.every((card) => card.isSelectable), false);

    var gameWithMatchCountChanged =
        startingGameModel.copyWithCardFlags(newCardMatchCount: 1);
    expect(gameWithMatchCountChanged.state, GameMachineState.newGame);
    expect(gameWithMatchCountChanged.cardMatchCount, 1);
    expect(
        gameWithMatchCountChanged.cards.every((card) => card.isFaceUp), true);
    expect(
        gameWithMatchCountChanged.cards.every((card) => card.isMatched), false);
    expect(gameWithMatchCountChanged.cards.every((card) => card.isSelected),
        false);
    expect(gameWithMatchCountChanged.cards.every((card) => card.isSelectable),
        false);
  });

  test('copyWithNewCards replaces the cards, state, and cardMatchCount given',
      () {
    var newCard0 = startingGameModel.cards[0].copyWith(
      isFaceUp: false,
      isMatched: true,
    );
    var newCard2 = startingGameModel.cards[2].copyWith(
      isFaceUp: false,
      isMatched: true,
    );
    var newGame = startingGameModel.copyWithNewCards(
      newState: GameMachineState.noCardsSelected,
      newMatchCount: 1,
      replacementCards: {
        startingGameModel.cards[0]: newCard0,
        startingGameModel.cards[2]: newCard2,
      },
    );
    expect(newGame.state, GameMachineState.noCardsSelected);
    expect(newGame.cardMatchCount, 1);
    expect(newGame.cards[0], newCard0);
    expect(newGame.cards[1], startingGameModel.cards[1]);
    expect(newGame.cards[2], newCard2);
    expect(newGame.cards[3], startingGameModel.cards[3]);
  });

  test('copyWithNewCards does not change cardMatchCount if not given', () {
    var newGame = startingGameModel.copyWithNewCards(
      newState: startingGameModel.state,
      replacementCards: {},
    );
    expect(newGame.cardMatchCount, startingGameModel.cardMatchCount);
  });

  test('copyWithNewCards works with no new cards', () {
    var newGame = startingGameModel.copyWithNewCards(
      newState: startingGameModel.state,
      replacementCards: {},
    );
    expect(newGame.state, startingGameModel.state);
    expect(newGame.cardMatchCount, startingGameModel.cardMatchCount);
    expect(newGame.cards, startingGameModel.cards);
  });

  test('copyWithNewCards ignores requests to replace cards not in the game',
      () {
    CardModel newCard = CardModel(
      cardFaceAssetPath: 'non-asset',
    );
    var newGame = startingGameModel.copyWithNewCards(
      newState: startingGameModel.state,
      replacementCards: {newCard: startingGameModel.cards[0]},
    );
    expect(newGame.state, startingGameModel.state);
    expect(newGame.cardMatchCount, startingGameModel.cardMatchCount);
    expect(newGame.cards, startingGameModel.cards);
  });

  test('getFirstSelectedCard throws if no cards are selected', () {
    expect(() => startingGameModel.getFirstSelectedCard(), throwsException);
  });

  test('getFirstSelectedCard returns first selected card', () {
    var newCard1 = startingGameModel.cards[1].copyWith(isSelected: true);
    var newCard3 = startingGameModel.cards[3].copyWith(isSelected: true);
    var newGame = startingGameModel.copyWithNewCards(
      newState: GameMachineState.twoCardsSelectedNotMatching,
      replacementCards: {
        startingGameModel.cards[1]: newCard1,
        startingGameModel.cards[3]: newCard3,
      },
    );
    expect(newGame.getFirstSelectedCard(), newCard1);
  });

  test('getAllSelectedCards returns empty list if no cards are selected', () {
    expect(startingGameModel.getAllSelectedCards(), []);
  });

  test('getAllSelectedCards returns all cards selected', () {
    var newCard1 = startingGameModel.cards[1].copyWith(isSelected: true);
    var newCard3 = startingGameModel.cards[3].copyWith(isSelected: true);
    var newGame = startingGameModel.copyWithNewCards(
      newState: GameMachineState.twoCardsSelectedNotMatching,
      replacementCards: {
        startingGameModel.cards[1]: newCard1,
        startingGameModel.cards[3]: newCard3,
      },
    );
    expect(newGame.getAllSelectedCards(), [newCard1, newCard3]);
  });

  test('copyWith can not change card count', () {
    List<String> cardAssetPaths = CardFaces.getFirstCardAssetPaths(1);
    CardModel c11 = CardModel(
      cardFaceAssetPath: cardAssetPaths[0],
      isFaceUp: true,
    );
    CardModel c12 = CardModel(
      cardFaceAssetPath: cardAssetPaths[0],
      isFaceUp: true,
    );
    List<CardModel> newCards = [c11, c12];
    expect(
      () => startingGameModel.copyWith(cards: newCards),
      throwsA(
        isA<AssertionError>(),
      ),
    );
  });
}

extension CardComparison on GameModel {
  bool compareCards(int first, int second) =>
      cards[first].cardFaceAssetPath == cards[second].cardFaceAssetPath;
}
