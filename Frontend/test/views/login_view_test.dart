import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:software_brava/views/auth/login_view.dart';

void main() {
  testWidgets('LoginView deve exibir elementos da identidade visual do SAMU',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: LoginView(),
      ),
    );

    // Valida textos do cabeçalho
    expect(find.text('Bem-vindo ao Bravo'), findsOneWidget);
    expect(find.text('SAMU 192'), findsOneWidget);

    // Valida campos de formulário
    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Senha'), findsOneWidget);
    expect(find.text('Entrar'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(2));
  });
}
