import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:memory_game/domain/game_logic/game_machine_state.dart';
import 'package:memory_game/domain/models/card_faces.dart';
import 'package:memory_game/domain/models/card_model.dart';
import 'package:memory_game/domain/models/game_model.dart';
import 'package:memory_game/presentation/pages/game_page.dart';
import 'package:memory_game/presentation/widgets/card_widget.dart';

void main() {
  late GameModel startingGameModel;
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

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
      durationSeconds: 60,
      initialFaceUpSeconds: 5,
    );
  });

  testWidgets('Play 2x2 game to win', (WidgetTester tester) async {
    // Build a skeleton app with the widget under test and trigger a frame.
    await tester.pumpWidget(
      MaterialApp(
        home: GamePage(initialGameModel: startingGameModel),
      ),
      Duration(seconds: 20),
    );
    // Find GameBoardWidget components
    expect(find.text('Matched 0 of 2 pairs'), findsOneWidget);
    expect(find.text('60 seconds'), findsOneWidget);
    expect(find.byType(GridView), findsOneWidget);
    expect(find.byType(CardWidget), findsNWidgets(4));

    // Wait for cards to turn face down.
    await tester.pump(new Duration(seconds: 10));
    // Declare card finders.
    Finder card11 = find.byKey(Key('Card 0'));
    Finder card12 = find.byKey(Key('Card 1'));
    Finder card21 = find.byKey(Key('Card 2'));
    Finder card22 = find.byKey(Key('Card 3'));
    // Tap cards (1,1) and (2,2)
    await tester.tap(card11);
    await tester.pumpAndSettle();
    await tester.tap(card22);
    await tester.pumpAndSettle();
    expect(find.text('Matched 1 of 2 pairs'), findsOneWidget);
    // Tap cards (1,2) and (2,1)
    await tester.tap(card12);
    await tester.pumpAndSettle();
    await tester.tap(card21);
    await tester.pumpAndSettle();
    expect(find.text('Matched 2 of 2 pairs'), findsOneWidget);
    // Verify game won
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text('You won!'), findsOneWidget);
  });

  testWidgets('Play 2x2 game to lose by doing nothing',
      (WidgetTester tester) async {
    // Build a skeleton app with the widget under test and trigger a frame.
    await tester.pumpWidget(
      MaterialApp(
        home: GamePage(initialGameModel: startingGameModel),
      ),
      Duration(seconds: 20),
    );
    // Find GameBoardWidget components
    expect(find.text('Matched 0 of 2 pairs'), findsOneWidget);
    expect(find.text('60 seconds'), findsOneWidget);
    expect(find.byType(GridView), findsOneWidget);
    expect(find.byType(CardWidget), findsNWidgets(4));

    // Wait for timer to run out.
    await tester.pump(new Duration(seconds: 10));
    await tester.pump(new Duration(seconds: 10));
    await tester.pump(new Duration(seconds: 10));
    await tester.pump(new Duration(seconds: 10));
    await tester.pump(new Duration(seconds: 10));
    await tester.pump(new Duration(seconds: 10));
    await tester.pump(new Duration(seconds: 10));
    await tester.pump(new Duration(seconds: 10));
    await tester.pump(new Duration(seconds: 10));

    // Verify game lost
    expect(find.text('Matched 0 of 2 pairs'), findsOneWidget);
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text('Game over.'), findsOneWidget);
    await tester.pump(new Duration(seconds: 10));
  });
}
