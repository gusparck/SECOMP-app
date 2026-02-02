import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/auth/login_page.dart';
import 'package:frontend/features/home/logged_user_home_page.dart';

void main() {
  Widget createWidget() {
    return const MaterialApp(home: LoginPage());
  }

  testWidgets('Should render login page fields', (WidgetTester tester) async {
    await tester.pumpWidget(createWidget());

    expect(find.text('Bem-vindo de volta!'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Senha'), findsOneWidget);
    expect(find.text('Entrar'), findsOneWidget);
  });

  testWidgets('Should validate empty email', (WidgetTester tester) async {
    await tester.pumpWidget(createWidget());

    // Tap button without entering text
    await tester.tap(find.text('Entrar'));
    await tester.pump();

    expect(find.text('Email inválido'), findsOneWidget);
  });

  testWidgets('Should navigate to Home on successful login', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(createWidget());

    // Enter valid credentials
    await tester.enterText(
      find.ancestor(
        of: find.text('Email'),
        matching: find.byType(TextFormField),
      ),
      'test@example.com',
    );
    await tester.enterText(
      find.ancestor(
        of: find.text('Senha'),
        matching: find.byType(TextFormField),
      ),
      'password123',
    );

    // Tap enter
    await tester.tap(find.text('Entrar'));
    await tester.pump(); // Start animation (loading)

    await tester.pump(const Duration(seconds: 1)); // Wait mock delay
    await tester.pump(); // Rebuild without loader

    await tester.pump(const Duration(seconds: 1));

    expect(find.byType(LoggedUserHomePage), findsOneWidget);

    expect(find.text('Pedro Henrique'), findsOneWidget);
  });
}
