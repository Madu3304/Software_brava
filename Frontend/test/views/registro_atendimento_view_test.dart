import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:software_brava/views/assistencial/registro_atendimento_view.dart';
import 'package:software_brava/views/assistencial/widgets/registro_field_card.dart';

void main() {
  testWidgets('RegistroAtendimentoView exibe campos atualizados com médico, horários e asterisco interativo',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: RegistroAtendimentoView(),
      ),
    );

    expect(find.text('Registro'), findsOneWidget);
    expect(find.byType(RegistroFieldCard), findsNWidgets(6));
    expect(find.text('Número de Registro'), findsOneWidget);
    expect(find.text('Base'), findsOneWidget);
    expect(find.text('Selecionar Base'), findsOneWidget);

    // Valida que o campo Data foi removido desta tela
    expect(find.text('Data'), findsNothing);

    // Valida o novo campo de Médico responsável
    expect(find.text('Médico responsável:'), findsOneWidget);
    expect(find.text('Técnico de enfermagem responsável:'), findsOneWidget);
    expect(find.text('Condutor socorrista:'), findsOneWidget);

    // Valida os dois novos campos de horário
    expect(find.text('Hora da abertura do chamado'), findsOneWidget);

    // Valida o campo com asterisco ao lado da palavra base
    final campoSaidaFinder = find.textContaining('Hora da saída da unidade da base');
    expect(campoSaidaFinder, findsOneWidget);

    // Testa clique no asterisco/texto garantindo scroll para visualização
    await tester.ensureVisible(campoSaidaFinder);
    await tester.pumpAndSettle();
    await tester.tap(campoSaidaFinder);
    await tester.pump();

    // Valida exibição da mensagem ao clicar no asterisco
    expect(find.text('Hora da saída da unidade móvel da base'), findsOneWidget);

    expect(find.text('Dados do Paciente'), findsOneWidget);
    expect(find.text('Finalizar Cadastro'), findsNothing);
  });
}
