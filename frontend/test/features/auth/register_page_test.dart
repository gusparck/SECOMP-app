import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/auth/register_page.dart';
import 'package:frontend/features/home/logged_user_home_page.dart';

void main() {
  Widget createWidget() {
    return const MaterialApp(home: RegisterPage());
  }

  testWidgets('Should validate required fields', (WidgetTester tester) async {
    await tester.pumpWidget(createWidget());

    await tester.tap(find.text('Cadastrar'), warnIfMissed: false);
    await tester.pump();

    expect(find.text('Informe seu nome'), findsOneWidget);
    expect(find.text('Email inválido'), findsOneWidget);
    expect(find.text('Informe sua matrícula'), findsOneWidget);
  });

  testWidgets('Should register and navigate to Home', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(createWidget());

    // Fill form
    await tester.enterText(
      find.ancestor(
        of: find.text('Nome Completo'),
        matching: find.byType(TextFormField),
      ),
      'Pedro Teste',
    );
    await tester.enterText(
      find.ancestor(
        of: find.text('Email'),
        matching: find.byType(TextFormField),
      ),
      'pedro@teste.com',
    );
    await tester.enterText(
      find.ancestor(
        of: find.text('Matrícula'),
        matching: find.byType(TextFormField),
      ),
      '123456',
    );
    await tester.enterText(
      find.ancestor(
        of: find.text('Senha'),
        matching: find.byType(TextFormField),
      ),
      '123456',
    );

    await tester.ensureVisible(find.text('Cadastrar'));
    await tester.tap(find.text('Cadastrar'));

    await tester.pump(); // Start loading (isLoading = true)
    await tester.pump(const Duration(seconds: 1)); // Wait mock delay
    await tester.pump(); // Rebuild with isLoading = false (removes indicator)

    // GradientBackground has infinite animation, so pumpAndSettle times out.
    // We pump for a fixed duration to allow navigation transition to complete.
    await tester.pump(const Duration(seconds: 1));

    expect(find.byType(LoggedUserHomePage), findsOneWidget);
    expect(find.text('Pedro Teste'), findsOneWidget);
  });
}
