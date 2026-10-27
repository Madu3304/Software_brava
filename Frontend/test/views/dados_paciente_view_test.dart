import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:software_brava/views/assistencial/dados_paciente_view.dart';

void main() {
  testWidgets('DadosPacienteView renderiza campos de paciente, Endereço no canto esquerdo, CEP no meio e campos de rua/número/bairro/complemento',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: DadosPacienteView(),
      ),
    );

    // Valida cabeçalho
    expect(find.text('Dados do Paciente'), findsOneWidget);

    // Valida dados pessoais do paciente
    expect(find.text('Nome do Paciente'), findsOneWidget);
    expect(find.text('Idade'), findsOneWidget);
    expect(find.text('Data de Nascimento'), findsOneWidget);
    expect(find.text('Sexo'), findsOneWidget);
    expect(find.text('CPF do paciente'), findsOneWidget);
    expect(find.text('Acompanhante'), findsOneWidget);
    expect(find.text('Grau de parentesco'), findsOneWidget);
    expect(find.text('Telefone de Contato'), findsOneWidget);
    expect(find.text('Medicamentos de uso continuo'), findsOneWidget);
    expect(find.text('Alergias'), findsOneWidget);

    // Valida "Endereço" no canto superior esquerdo da seção
    expect(find.text('Endereço'), findsOneWidget);

    // Valida campo CEP no meio com instrução de GPS
    expect(find.text('CEP'), findsOneWidget);

    // Valida campos de rua, número, bairro e complemento
    expect(find.text('Rua'), findsOneWidget);
    expect(find.text('Número'), findsOneWidget);
    expect(find.text('Bairro'), findsOneWidget);
    expect(find.text('Complemento'), findsOneWidget);

    // Testa preenchimento do CEP
    final cepFinder = find.widgetWithText(TextFormField, 'Digite o CEP (ex: 89201-000)');
    expect(cepFinder, findsOneWidget);
    await tester.enterText(cepFinder, '89201000');
    await tester.pump(const Duration(milliseconds: 200));

    // Valida botão Continuar
    expect(find.text('Continuar'), findsOneWidget);
  });
}
