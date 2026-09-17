import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tokens/main.dart';

void main() {
  testWidgets('PsgTokenApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: PsgTokenApp(),
      ),
    );

    // Verify that the login screen renders
    expect(find.text('PSG Mess Token'), findsOneWidget);
    expect(find.text('Sign In'), findsWidgets);
  });
}
