import 'package:flutter_test/flutter_test.dart';
import 'package:software_brava/utils/horario_atendimento.dart';

void main() {
  group('Cálculo do horário de saída', () {
    test('Horário normal', () {
      final resultado = calcularHorarioSaidaPrevista(
        DateTime(2026, 11, 7, 14, 30),
      );

      expect(resultado, '14:32');
    });

    test('Mudança de hora', () {
      final resultado = calcularHorarioSaidaPrevista(
        DateTime(2026, 11, 7, 14, 59),
      );

      expect(resultado, '15:01');
    });

    test('Passagem da meia-noite', () {
      final resultado = calcularHorarioSaidaPrevista(
        DateTime(2026, 11, 7, 23, 59),
      );

      expect(resultado, '00:01');
    });

    test('Minutos terminados em 58', () {
      final resultado = calcularHorarioSaidaPrevista(
        DateTime(2026, 11, 7, 14, 58),
      );

      expect(resultado, '15:00');
    });
  });
}