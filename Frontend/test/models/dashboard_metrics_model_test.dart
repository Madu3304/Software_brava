import 'package:flutter_test/flutter_test.dart';
import 'package:software_brava/models/dashboard_metrics_model.dart';

void main() {
  group('DashboardMetricsModel Tests', () {
    test('Mock padrão deve conter valores consistentes com o Figma', () {
      final metrics = DashboardMetricsModel.mockDefault();

      expect(metrics.totalAtendimentos, 4562);
      expect(metrics.taxaCrescimentoMensal, 12.5);
      expect(metrics.unidades.containsKey('Unidade Norte'), isTrue);
      expect(metrics.unidades['Unidade Norte']!.total, 1247);
      expect(metrics.unidades['Unidade Norte']!.porcentagem, 27.3);

      expect(metrics.atendimentosPorNivel['Emergências'], 523);
      expect(metrics.atendimentosPorNivel['Urgências'], 892);
      expect(metrics.atendimentosPorNivel['Rotina'], 432);

      expect(metrics.locaisMaisFrequentes.length, 5);
      expect(metrics.locaisMaisFrequentes.first.bairro, 'Centro');
      expect(metrics.locaisMaisFrequentes.first.total, 387);

      expect(metrics.tempoMedioMinutos, '8:42');
      expect(metrics.taxaIndisponibilidadePercentual, 12.3);
      expect(metrics.horasIndisponibilidade, '287h / 2332h');
    });
  });
}
