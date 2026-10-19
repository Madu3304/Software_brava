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

    // Valida cabeçalho
    expect(find.text('Avaliação Clínica'), findsOneWidget);

    // Valida resumo do paciente
    expect(find.text('João da Silva'), findsOneWidget);
    expect(find.textContaining('Ocorrência: REG-999'), findsOneWidget);
    expect(find.text('Acompanhante: Pai'), findsOneWidget);

    // Valida seção de sinais vitais
    expect(find.text('Sinais Vitais'), findsOneWidget);
    expect(find.text('Pressão (PA)'), findsOneWidget);
    expect(find.text('Freq. Cardíaca (FC)'), findsOneWidget);
    expect(find.text('Saturação O2 (SpO2)'), findsOneWidget);
    expect(find.text('Freq. Resp. (FR)'), findsOneWidget);
    expect(find.text('Glicemia (HGT)'), findsOneWidget);
    expect(find.text('Temperatura'), findsOneWidget);
    expect(find.text('Glasgow (3-15)'), findsOneWidget);

    // Valida campos de queixa e conduta
    expect(find.text('Queixa Principal / Hipótese Diagnóstica'), findsOneWidget);
    expect(find.text('Conduta e Procedimentos Realizados'), findsOneWidget);

    // Valida botão finalizar
    expect(find.text('Finalizar Atendimento e Imprimir'), findsOneWidget);
  });
}
