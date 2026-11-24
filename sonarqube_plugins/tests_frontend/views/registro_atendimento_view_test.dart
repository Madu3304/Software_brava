import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:software_brava/views/assistencial/registro_atendimento_view.dart';
import 'package:software_brava/views/assistencial/widgets/registro_field_card.dart';

void main() {
  testWidgets('RegistroAtendimentoView exibe todos os campos e apenas o botão Continuar',
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
    expect(find.text('Médico responsável:'), findsOneWidget);
    expect(find.text('Técnico de enfermagem responsável:'), findsOneWidget);
    expect(find.text('Condutor socorrista:'), findsOneWidget);
    expect(find.text('Hora da abertura do chamado'), findsOneWidget);
    expect(find.text('Dados do Paciente'), findsOneWidget);
    expect(find.text('Finalizar Cadastro'), findsNothing);
    expect(find.text('Continuar preenchimento assistencial'), findsNothing);
  });

  group('Cálculo automático do horário de saída (+2 minutos)', () {
    test('adiciona 2 minutos corretamente dentro da mesma hora', () {
      final abertura = DateTime(2026, 11, 17, 10, 15);
      final saida = RegistroAtendimentoView.calcularHorarioSaida(abertura);

      expect(saida, DateTime(2026, 11, 17, 10, 17));
      expect(RegistroAtendimentoView.formatarHorario(saida), '10:17');
    });

    test('atualiza a hora corretamente na virada de hora (14:58 -> 15:00 e 14:59 -> 15:01)', () {
      final abertura58 = DateTime(2026, 11, 17, 14, 58);
      final saida58 = RegistroAtendimentoView.calcularHorarioSaida(abertura58);
      expect(saida58, DateTime(2026, 11, 17, 15, 0));
      expect(RegistroAtendimentoView.formatarHorario(saida58), '15:00');

      final abertura59 = DateTime(2026, 11, 17, 14, 59);
      final saida59 = RegistroAtendimentoView.calcularHorarioSaida(abertura59);
      expect(saida59, DateTime(2026, 11, 17, 15, 1));
      expect(RegistroAtendimentoView.formatarHorario(saida59), '15:01');
    });

    test('atualiza hora e dia corretamente na virada da meia-noite (23:58 -> 00:00 e 23:59 -> 00:01)', () {
      final abertura58 = DateTime(2026, 11, 17, 23, 58);
      final saida58 = RegistroAtendimentoView.calcularHorarioSaida(abertura58);
      expect(saida58, DateTime(2026, 11, 18, 0, 0));
      expect(RegistroAtendimentoView.formatarHorario(saida58), '00:00');

      final abertura59 = DateTime(2026, 11, 17, 23, 59);
      final saida59 = RegistroAtendimentoView.calcularHorarioSaida(abertura59);
      expect(saida59, DateTime(2026, 11, 18, 0, 1));
      expect(RegistroAtendimentoView.formatarHorario(saida59), '00:01');
    });
  });
}
