import 'package:flutter_test/flutter_test.dart';
import 'package:software_brava/main.dart';

void main() {
  testWidgets('App smoke test - carrega tela de login', (WidgetTester tester) async {
    await tester.pumpWidget(const SoftwareBravaApp());
    expect(find.text('Bem-vindo ao Bravo'), findsOneWidget);
    expect(find.text('SAMU 192'), findsOneWidget);
  });
}
