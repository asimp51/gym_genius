// Basic smoke test for GymGeniusApp
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gym_genius/app.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: GymGeniusApp()));
    // Just verify the app renders without crashing
    await tester.pumpAndSettle();
  });
}
