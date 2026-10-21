import 'package:flutter_test/flutter_test.dart';
import 'package:commander_iq/main.dart';

void main() {
  testWidgets('home screen exposes the primary destinations', (tester) async {
    await tester.pumpWidget(const CommanderIqApp());

    expect(find.text('Decks'), findsWidgets);
    expect(find.text('Game Records'), findsOneWidget);
    expect(find.text('Insights'), findsWidgets);
    expect(find.text('Stats'), findsWidgets);
    expect(find.text('Quick log a game'), findsOneWidget);
  });
}
