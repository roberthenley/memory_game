import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memory_game/domain/game_logic/game_machine_state.dart';
import 'package:memory_game/domain/models/card_faces.dart';
import 'package:memory_game/domain/models/card_model.dart';
import 'package:memory_game/domain/models/game_model.dart';
import 'package:memory_game/presentation/widgets/card_widget.dart';
import 'package:memory_game/presentation/widgets/stateful_game_board_widget.dart';

void main() {
  GameModel startingGameModel;

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
      durationSeconds: 10,
      initialFaceUpSeconds: 0,
    );
  });

  tearDown(() {
    startingGameModel = null;
  });

  testWidgets(
      'Game page screen has ScoreDisplayWidget, TimerDisplayWidget, and 2x2 GridView of CardWidgets',
      (WidgetTester tester) async {
    // Build a skeleton app with the widget under test and trigger a frame.
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GameBoardWidget(initialGameModel: startingGameModel),
        ),
      ),
      Duration(seconds: 50),
    );
    // Find 'New game' buttons
    expect(find.text('Matched 0 of 2 pairs'), findsOneWidget);
    expect(find.text('10 seconds'), findsOneWidget);
    expect(find.byType(GridView), findsOneWidget);
    expect(find.byType(CardWidget), findsNWidgets(4));
  });
}
