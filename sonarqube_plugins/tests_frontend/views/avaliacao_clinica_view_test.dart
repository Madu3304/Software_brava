import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:software_brava/models/ficha_model.dart';
import 'package:software_brava/views/assistencial/avaliacao_clinica_view.dart';

void main() {
  testWidgets('AvaliacaoClinicaView renderiza cabeçalho, sinais vitais, resumo do paciente com acompanhante e botão finalizar',
      (WidgetTester tester) async {
    final ficha = FichaAtendimentoModel(
      id: 'fch_teste_1',
      numeroOcorrencia: 'REG-999',
      dataHora: DateTime.now(),
      pacienteNome: 'João da Silva',
      pacienteIdade: 45,
      pacienteSexo: 'Masculino',
      acompanhante: 'Pai',
      tipoOcorrencia: 'Atendimento Pré-Hospitalar',
      endereco: 'Rua das Flores, 123 - Centro',
      unidadeResponsavel: 'USB',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: AvaliacaoClinicaView(fichaParcial: ficha),
      ),
    );

    expect(find.text('Avaliação Clínica'), findsOneWidget);
    expect(find.text('João da Silva'), findsOneWidget);
    expect(find.textContaining('Ocorrência: REG-999'), findsOneWidget);
    expect(find.text('Acompanhante: Pai'), findsOneWidget);

    expect(find.text('2. Sinais Vitais e Histórico'), findsOneWidget);
    expect(find.text('PA (ex: 120/80)'), findsOneWidget);
    expect(find.text('FC (bpm)'), findsOneWidget);
    expect(find.text('FR (rpm)'), findsOneWidget);
    expect(find.text('SpO₂ (%)'), findsOneWidget);
    expect(find.text('Glicemia (mg/dL)'), findsOneWidget);
    expect(find.text('Temp (°C)'), findsOneWidget);
    expect(find.text('Glasgow'), findsOneWidget);

    expect(find.text('Queixa principal'), findsOneWidget);
    expect(find.text('Conduta Clínica'), findsOneWidget);
    expect(find.text('Conduta e procedimentos realizados'), findsOneWidget);
    expect(find.text('Ir para Assinatura →'), findsOneWidget);
  });
}
