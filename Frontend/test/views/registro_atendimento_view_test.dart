import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:software_brava/views/assistencial/registro_atendimento_view.dart';
import 'package:software_brava/views/assistencial/widgets/registro_field_card.dart';

void main() {
  testWidgets('RegistroAtendimentoView exibe todos os campos das imagens 2 e 3 do Figma',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: RegistroAtendimentoView(),
      ),
    );

    expect(find.text('Registro'), findsOneWidget);
    expect(find.byType(RegistroFieldCard), findsNWidgets(5));
    expect(find.text('Número de Registro'), findsOneWidget);
    expect(find.text('Base'), findsOneWidget);
    expect(find.text('Selecionar Base'), findsOneWidget);
    expect(find.text('Data'), findsOneWidget);
    expect(find.text('Técnico de enfermagem responsável:'), findsOneWidget);
    expect(find.text('Condutor socorrista:'), findsOneWidget);
    expect(find.text('Finalizar Cadastro'), findsOneWidget);
  });
}
