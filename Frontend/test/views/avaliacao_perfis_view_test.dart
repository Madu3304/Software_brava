import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:software_brava/models/ficha_model.dart';
import 'package:software_brava/providers/ficha_provider.dart';
import 'package:software_brava/views/assistencial/avaliacao_clinica_view.dart';

void main() {
  FichaAtendimentoModel criarFicha({String tipo = 'Atendimento Pré-Hospitalar', int? idade = 30}) {
    return FichaAtendimentoModel(
      id: 'ficha-perfil-1',
      numeroOcorrencia: 'REG-500',
      dataHora: DateTime(2026, 11, 22, 14, 0),
      pacienteNome: 'Paciente Teste',
      pacienteIdade: idade,
      pacienteSexo: 'Feminino',
      tipoOcorrencia: tipo,
      endereco: 'Rua Teste, 10',
      unidadeResponsavel: 'USB',
    );
  }

  testWidgets('AvaliacaoClinicaView perfil Gestante exibe campos obstétricos e aberturas condicionais',
      (WidgetTester tester) async {
    final provider = FichaEmAndamentoProvider()..selecionarPerfil('gestante');

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: MaterialApp(
          home: AvaliacaoClinicaView(fichaParcial: criarFicha(tipo: 'Obstétrico')),
        ),
      ),
    );

    expect(find.text('3. Dados Obstétricos e Pré-Natal'), findsOneWidget);
    expect(find.text('Possui Cartão da Gestante (levado à maternidade)?'), findsOneWidget);
    expect(find.text('4. Sinais de Alerta, Pré-eclâmpsia e Parto'), findsOneWidget);
    expect(find.text('Coroamento / Apresentação fetal visível? (Parto iminente)'), findsOneWidget);

    await tester.ensureVisible(find.text('Sangramento vaginal?'));
    await tester.tap(find.text('Sangramento vaginal?'));
    await tester.pump();
    expect(find.text('Quantidade do sangramento'), findsOneWidget);

    await tester.ensureVisible(find.text('Perda de líquido amniótico (bolsa rota)?'));
    await tester.tap(find.text('Perda de líquido amniótico (bolsa rota)?'));
    await tester.pump();
    expect(find.text('Aspecto do líquido amniótico'), findsOneWidget);

    await tester.ensureVisible(find.text('Meconial'));
    await tester.tap(find.text('Meconial'));
    await tester.pump();
    expect(find.textContaining('Líquido meconial indica sofrimento fetal'), findsOneWidget);

    await tester.ensureVisible(find.text('Contrações uterinas?'));
    await tester.tap(find.text('Contrações uterinas?'));
    await tester.pump();
    expect(find.text('Frequência (a cada X min)'), findsOneWidget);
    expect(find.text('Duração (segundos)'), findsOneWidget);

    await tester.ensureVisible(find.text('Parto realizado no local / transporte?'));
    await tester.tap(find.text('Parto realizado no local / transporte?'));
    await tester.pump();
    expect(find.text('Vitalidade do Recém-Nascido (RN)'), findsOneWidget);
    expect(find.text('Dequitação da placenta'), findsOneWidget);

    await tester.ensureVisible(find.text('Ir para Assinatura →'));
    await tester.tap(find.text('Ir para Assinatura →'));
    await tester.pump();
  });

  testWidgets('AvaliacaoClinicaView perfil Idoso exibe idade estimada, Cincinnati com janela e queda+anticoagulante',
      (WidgetTester tester) async {
    final provider = FichaEmAndamentoProvider()..selecionarPerfil('idoso');

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: MaterialApp(
          home: AvaliacaoClinicaView(fichaParcial: criarFicha(tipo: 'Geriátrico', idade: null)),
        ),
      ),
    );

    expect(find.text('Idade estimada (anos)'), findsOneWidget);
    expect(find.text('3. Funcionalidade, Cognição, AVC e Quedas'), findsOneWidget);
    expect(find.text('Estado mental alterado em relação ao basal?'), findsOneWidget);

    await tester.ensureVisible(find.text('Assimetria facial?'));
    await tester.tap(find.text('Assimetria facial?'));
    await tester.pump();
    expect(
      find.text('Horário do início dos sintomas / Última vez visto bem (HH:mm)'),
      findsOneWidget,
    );

    await tester.ensureVisible(find.text('Houve queda / trauma associado?'));
    await tester.tap(find.text('Houve queda / trauma associado?'));
    await tester.pump();

    await tester.ensureVisible(find.text('Uso de anticoagulante / antiagregante?'));
    await tester.tap(find.text('Uso de anticoagulante / antiagregante?'));
    await tester.pump();
    expect(find.textContaining('hematoma subdural'), findsOneWidget);

    await tester.ensureVisible(find.text('Ir para Assinatura →'));
    await tester.tap(find.text('Ir para Assinatura →'));
    await tester.pump();
  });

  testWidgets('AvaliacaoClinicaView perfil Paciente comum exibe protocolo Cincinnati e conduta',
      (WidgetTester tester) async {
    final provider = FichaEmAndamentoProvider()..selecionarPerfil('comum');

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: MaterialApp(
          home: AvaliacaoClinicaView(fichaParcial: criarFicha(tipo: 'Clínico')),
        ),
      ),
    );

    expect(find.text('3. Protocolo de AVC (Cincinnati)'), findsOneWidget);
    await tester.ensureVisible(find.text('Assimetria facial?'));
    await tester.tap(find.text('Assimetria facial?'));
    await tester.pump();

    await tester.ensureVisible(find.text('Queda de braço (fraqueza unilateral)?'));
    await tester.tap(find.text('Queda de braço (fraqueza unilateral)?'));
    await tester.pump();

    await tester.ensureVisible(find.text('Fala anormal / disartria?'));
    await tester.tap(find.text('Fala anormal / disartria?'));
    await tester.pump();

    await tester.ensureVisible(find.text('Ir para Assinatura →'));
    await tester.tap(find.text('Ir para Assinatura →'));
    await tester.pump();
  });
}
