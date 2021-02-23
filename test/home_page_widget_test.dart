import 'package:flutter_test/flutter_test.dart';
import 'package:memory_game/memory_app.dart';

void main() {
  testWidgets('Home screen has New Game button', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MemoryApp());

    // Find 'New game' button
    expect(find.text('New game'), findsOneWidget);
  });
}
