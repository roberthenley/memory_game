import 'package:flutter_test/flutter_test.dart';
import 'package:memory_game/presentation/memory_app.dart';

void main() {
  testWidgets('Home screen has 3 New Game buttons',
      (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MemoryApp());

    // Find 'New game' buttons
    expect(find.text('New game (2 x 2)'), findsOneWidget);
    expect(find.text('New game (2 x 3)'), findsOneWidget);
    expect(find.text('New game (3 x 4)'), findsOneWidget);
  });
}
