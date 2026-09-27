// ============================================================================
// MODELO DE DADOS: MÉTRICAS CONSOLIDADAS DO DASHBOARD (FIGMA)
// Arquivo: lib/models/dashboard_metrics_model.dart
// ============================================================================

class DashboardMetricsModel {
  final int totalAtendimentos;
  final double taxaCrescimentoMensal;
  final Map<String, UnidadeMetrica> unidades;
  final Map<String, int> atendimentosPorNivel; // Emergências, Urgências, Rotina
  final Map<String, double> faixasEtarias;
  final List<LocalOcorrencia> locaisMaisFrequentes;
  final String tempoMedioMinutos;
  final double taxaIndisponibilidadePercentual;
  final String horasIndisponibilidade; // ex: "287h / 2332h"

  const DashboardMetricsModel({
    required this.totalAtendimentos,
    required this.taxaCrescimentoMensal,
    required this.unidades,
    required this.atendimentosPorNivel,
    required this.faixasEtarias,
    required this.locaisMaisFrequentes,
    required this.tempoMedioMinutos,
    required this.taxaIndisponibilidadePercentual,
    required this.horasIndisponibilidade,
  });

  factory DashboardMetricsModel.mockDefault() {
    return const DashboardMetricsModel(
      totalAtendimentos: 4562,
      taxaCrescimentoMensal: 12.5,
      unidades: {
        'Unidade Norte': UnidadeMetrica(total: 1247, porcentagem: 27.3),
        'Unidade Sul': UnidadeMetrica(total: 983, porcentagem: 21.5),
        'Unidade Leste': UnidadeMetrica(total: 1456, porcentagem: 31.9),
        'Unidade Oeste': UnidadeMetrica(total: 876, porcentagem: 19.2),
      },
      atendimentosPorNivel: {
        'Emergências': 523,
        'Urgências': 892,
        'Rotina': 432,
      },
      faixasEtarias: {
        '0-12 anos': 13.3,
        '13-25 anos': 18.9,
        '26-40 anos': 28.5,
        '41-60 anos': 24.7,
        '60+ anos': 18.5,
      },
      locaisMaisFrequentes: [
        LocalOcorrencia(posicao: 1, bairro: 'Centro', total: 387, porcentagem: 21.0),
        LocalOcorrencia(posicao: 2, bairro: 'Zona Norte', total: 342, porcentagem: 18.5),
        LocalOcorrencia(posicao: 3, bairro: 'Zona Sul', total: 298, porcentagem: 16.1),
        LocalOcorrencia(posicao: 4, bairro: 'Zona Leste', total: 456, porcentagem: 24.7),
        LocalOcorrencia(posicao: 5, bairro: 'Zona Oeste', total: 364, porcentagem: 19.7),
      ],
      tempoMedioMinutos: '8:42',
      taxaIndisponibilidadePercentual: 12.3,
      horasIndisponibilidade: '287h / 2332h',
    );
  }
}

class UnidadeMetrica {
  final int total;
  final double porcentagem;

  const UnidadeMetrica({required this.total, required this.porcentagem});
}

class LocalOcorrencia {
  final int posicao;
  final String bairro;
  final int total;
  final double porcentagem;

  const LocalOcorrencia({
    required this.posicao,
    required this.bairro,
    required this.total,
    required this.porcentagem,
  });
}
