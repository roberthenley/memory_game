import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memory_game/score_display_widget.dart';

void main() {
  testWidgets('Score display shows current score and total',
      (WidgetTester tester) async {
    // Build a skeleton app with the widget under test and trigger a frame.
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ScoreDisplayWidget(score: 4, total: 6),
        ),
      ),
    );

    // Verify card is shown.
    Finder card = find.text('Matched 4 of 6 pairs');
    expect(card, findsOneWidget);
  });
}
