import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/app.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const App());

    expect(find.text('Semana da Computação'), findsOneWidget);
    expect(find.text('2026'), findsOneWidget);
  });
}
