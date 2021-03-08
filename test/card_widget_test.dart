import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memory_game/domain/models/card_faces.dart';
import 'package:memory_game/domain/models/card_model.dart';
import 'package:memory_game/orchestration/game_cubit.dart';
import 'package:memory_game/presentation/widgets/card_widget.dart';
import 'package:mockito/mockito.dart';

const String cardKeyId = 'test_card';

void main() {
  testWidgets(
    'Test card back shown if not face-up',
    (WidgetTester tester) async {
      // Create the CardModel under test.
      String testAssetPath = CardFaces.getFirstCardAssetPaths(1).first;
      CardModel testCardModel = CardModel(
        isFaceUp: false,
        cardFaceAssetPath: testAssetPath,
      );

      // Verify card is face-down, showing proper semantics label, and does not
      // show border.
      await createCardAndTestPredicates(
        tester,
        testCardModel,
        [
          (Widget widget) =>
              widget is SvgPicture && widget == CardWidget.faceDownCard,
          (Widget widget) =>
              widget is Semantics &&
              widget.properties.label == CardWidget.faceDownCardSemanticsLabel,
          (Widget widget) {
            if (widget is! Card) return false;
            Card card = widget;
            if (card.shape == null || card.shape is! RoundedRectangleBorder) {
              return false;
            }
            RoundedRectangleBorder border =
                card.shape as RoundedRectangleBorder;
            return border.side.color == CardWidget.nonHighlightBorderColor;
          },
        ],
      );
    },
  );

  testWidgets(
    'Test card face shown without border if face-up and unmatched',
    (WidgetTester tester) async {
      // Create the CardModel under test.
      String cardFaceAssetPath = CardFaces.getFirstCardAssetPaths(1).first;
      String cardSemanticsLabel = CardFaces.getCardName(cardFaceAssetPath);
      CardModel testCardModel = CardModel(
        isFaceUp: true,
        cardFaceAssetPath: cardFaceAssetPath,
      );

      // Verify card is face-up, showing proper semantics label, and does not
      // show border.
      await createCardAndTestPredicates(
        tester,
        testCardModel,
        [
          (Widget widget) =>
              widget is SvgPicture && widget != CardWidget.faceDownCard,
          (Widget widget) =>
              widget is Semantics &&
              widget.properties.label == cardSemanticsLabel,
          (Widget widget) {
            if (widget is! Card) return false;
            Card card = widget;
            if (card.shape == null || card.shape is! RoundedRectangleBorder) {
              return false;
            }
            RoundedRectangleBorder border =
                card.shape as RoundedRectangleBorder;
            return border.side.color == CardWidget.nonHighlightBorderColor;
          },
        ],
      );
    },
  );

  testWidgets(
    'Test card face shown with border if face-up and matched',
    (WidgetTester tester) async {
      // Create the CardModel under test.
      String cardFaceAssetPath = CardFaces.getFirstCardAssetPaths(1).first;
      String cardSemanticsLabel =
          '${CardFaces.getCardName(cardFaceAssetPath)} matched';
      CardModel testCardModel = CardModel(
        isFaceUp: true,
        isMatched: true,
        cardFaceAssetPath: cardFaceAssetPath,
      );

      // Verify card is face-up, showing proper semantics label, and does not
      // show border.
      await createCardAndTestPredicates(
        tester,
        testCardModel,
        [
          (Widget widget) =>
              widget is SvgPicture && widget != CardWidget.faceDownCard,
          (Widget widget) =>
              widget is Semantics &&
              widget.properties.label == cardSemanticsLabel,
          (Widget widget) {
            if (widget is! Card) return false;
            Card card = widget;
            if (card.shape == null || card.shape is! RoundedRectangleBorder) {
              return false;
            }
            RoundedRectangleBorder border =
                card.shape as RoundedRectangleBorder;
            return border.side.color == CardWidget.highlightBorderColor;
          },
        ],
      );
    },
  );

  testWidgets(
    'Test card callback is called when a selectable card is tapped',
    (WidgetTester tester) async {
      // Create the CardModel under test.
      String cardFaceAssetPath = CardFaces.getFirstCardAssetPaths(1).first;
      CardModel testCardModel = CardModel(
        isSelectable: true,
        cardFaceAssetPath: cardFaceAssetPath,
      );
      GameCubit testGameCubit = MockGameCubit();

      Finder card = await createCardAndTestExists(
        tester,
        testCardModel,
        testGameCubit,
      );

      await tester.tap(card);
      await tester.pumpAndSettle(Duration(seconds: 1));
      verify(testGameCubit.cardSelected(testCardModel));
    },
  );

  testWidgets(
    'Test card callback is not called when an un-selectable card is tapped',
    (WidgetTester tester) async {
      // Create the CardModel under test.
      String cardFaceAssetPath = CardFaces.getFirstCardAssetPaths(1).first;
      CardModel testCardModel = CardModel(
        isSelectable: false,
        cardFaceAssetPath: cardFaceAssetPath,
      );
      GameCubit testGameCubit = MockGameCubit();

      Finder card = await createCardAndTestExists(
        tester,
        testCardModel,
        testGameCubit,
      );

      await tester.tap(card);
      await tester.pumpAndSettle(Duration(seconds: 1));
      verifyNever(testGameCubit.cardSelected(testCardModel));
    },
  );
}

Future createCardAndTestPredicates(
  WidgetTester tester,
  CardModel testCardModel,
  List<WidgetPredicate> predicates,
) async {
  await createCardAndTestExists(tester, testCardModel, MockGameCubit());

  // Verify predicates each find a widget
  for (WidgetPredicate predicate in predicates) {
    expect(find.byWidgetPredicate(predicate), findsOneWidget);
  }
}

class MockGameCubit extends Mock implements GameCubit {}

Future<Finder> createCardAndTestExists(
  WidgetTester tester,
  CardModel testCardModel,
  GameCubit mockGameCubit,
) async {
  // Build a skeleton app with the card under test and trigger a frame.
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: BlocProvider<GameCubit>(
          create: (_) => mockGameCubit,
          child: CardWidget(
            key: Key(cardKeyId),
            cardModel: testCardModel,
          ),
        ),
      ),
    ),
  );

  // Verify card is shown.
  Finder card = find.byKey(Key(cardKeyId));
  expect(card, findsOneWidget);

  return card;
}
