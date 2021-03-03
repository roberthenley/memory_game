import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memory_game/presentation/widgets/timer_display_widget.dart';

void main() {
  testWidgets('Timer display shows time remaining',
      (WidgetTester tester) async {
    // Build a skeleton app with the widget under test and trigger a frame.
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TimerDisplayWidget(timeRemaining: 30),
        ),
      ),
    );

    // Verify card is shown.
    Finder card = find.text('30 seconds');
    expect(card, findsOneWidget);
  });
}
