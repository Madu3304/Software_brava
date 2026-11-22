import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:software_brava/providers/ficha_provider.dart';
import 'package:software_brava/views/assistencial/selecao_atendimento_view.dart';
import 'package:software_brava/views/assistencial/ficha_personalizada_view.dart';

void main() {
  testWidgets('SelecaoAtendimentoView exibe 3 perfis e atualiza provider ao tocar',
      (WidgetTester tester) async {
    final provider = FichaEmAndamentoProvider();
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: MaterialApp(
          home: const SelecaoAtendimentoView(),
          routes: {
            '/ficha': (_) => const Scaffold(body: Text('Tela Ficha')),
          },
        ),
      ),
    );

    expect(find.text('Qual é o perfil do paciente?'), findsOneWidget);
    expect(find.text('Gestante'), findsOneWidget);
    expect(find.text('Idoso'), findsOneWidget);
    expect(find.text('Paciente comum'), findsOneWidget);

    await tester.tap(find.text('Gestante'));
    await tester.pumpAndSettle();
    expect(provider.perfilAtendimento, 'gestante');
    expect(find.text('Tela Ficha'), findsOneWidget);
  });

  testWidgets('FichaPersonalizadaView renderiza todos os 3 perfis e permite marcar chips',
      (WidgetTester tester) async {
    for (final perfil in PerfilFichaAtendimento.values) {
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => FichaEmAndamentoProvider(),
          child: MaterialApp(
            home: FichaPersonalizadaView(perfil: perfil),
          ),
        ),
      );
      expect(find.text('1. Ocorrência e Identificação do Paciente'), findsOneWidget);
      expect(find.text('2. Sinais Vitais e Histórico'), findsOneWidget);
      expect(find.text('Ir para Assinatura →'), findsOneWidget);
    }

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => FichaEmAndamentoProvider(),
        child: const MaterialApp(
          home: FichaPersonalizadaView(perfil: PerfilFichaAtendimento.gestante),
        ),
      ),
    );
    await tester.tap(find.text('Dor abdominal'));
    await tester.pump();
    expect(find.text('3. Dados Obstétricos e Pré-Natal'), findsOneWidget);

    await tester.ensureVisible(find.text('Ir para Assinatura →'));
    await tester.tap(find.text('Ir para Assinatura →'));
    await tester.pump();

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => FichaEmAndamentoProvider(),
        child: const MaterialApp(
          home: FichaPersonalizadaView(perfil: PerfilFichaAtendimento.idoso),
        ),
      ),
    );
    await tester.tap(find.text('Risco de queda'));
    await tester.pump();
    await tester.ensureVisible(find.text('Ocorrência de queda?'));
    await tester.tap(find.text('Ocorrência de queda?'));
    await tester.pump();
    await tester.ensureVisible(find.text('Ir para Assinatura →'));
    await tester.tap(find.text('Ir para Assinatura →'));
    await tester.pump();

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => FichaEmAndamentoProvider(),
        child: const MaterialApp(
          home: FichaPersonalizadaView(perfil: PerfilFichaAtendimento.comum),
        ),
      ),
    );
    await tester.tap(find.text('Trauma'));
    await tester.pump();
    await tester.ensureVisible(find.text('Assimetria facial?'));
    await tester.tap(find.text('Assimetria facial?'));
    await tester.pump();
    await tester.ensureVisible(find.text('Ir para Assinatura →'));
    await tester.tap(find.text('Ir para Assinatura →'));
    await tester.pump();
  });
}
