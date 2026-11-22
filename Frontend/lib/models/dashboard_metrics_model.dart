class DashboardMetricsModel {
  final int totalAtendimentos;
  final int atendimentosHoje;
  final String tempoMedioFormatado;
  final int totalUnidadesAtivas;
  final int totalUnidadesParadas;
  final Map<String, int> atendimentosPorUnidade;
  final Map<String, int> distribuicaoFaixaEtaria;
  final List<LocalOcorrencia> locaisMaisFrequentes;
  final Map<String, dynamic> reposicaoUtensilios;
  final double taxaCrescimentoMensal;
  final Map<String, int>? customAtendimentosPorNivel;
  final double? customTaxaIndisponibilidade;
  final String? customHorasIndisponibilidade;

  const DashboardMetricsModel({
    required this.totalAtendimentos,
    this.atendimentosHoje = 0,
    required this.tempoMedioFormatado,
    this.totalUnidadesAtivas = 0,
    this.totalUnidadesParadas = 0,
    required this.atendimentosPorUnidade,
    required this.distribuicaoFaixaEtaria,
    required this.locaisMaisFrequentes,
    this.reposicaoUtensilios = const {},
    this.taxaCrescimentoMensal = 0.0,
    this.customAtendimentosPorNivel,
    this.customTaxaIndisponibilidade,
    this.customHorasIndisponibilidade,
  });

  factory DashboardMetricsModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> rawUnidades =
        (json['atendimentos_por_unidade'] as Map<String, dynamic>?) ?? {};
    final Map<String, int> unidadesMap = rawUnidades.map(
      (key, value) => MapEntry(key, value is int ? value : int.tryParse(value.toString()) ?? 0),
    );

    final Map<String, dynamic> rawFaixas =
        (json['distribuicao_faixa_etaria'] as Map<String, dynamic>?) ?? {};
    final Map<String, int> faixasMap = rawFaixas.map(
      (key, value) => MapEntry(key, value is int ? value : int.tryParse(value.toString()) ?? 0),
    );

    final List<dynamic> rawLocais = (json['locais_maior_ocorrencia'] as List<dynamic>?) ?? [];
    int totalLocais = 0;
    for (final item in rawLocais) {
      if (item is Map && item['total'] != null) {
        totalLocais += (item['total'] as num).toInt();
      }
    }

    final List<LocalOcorrencia> locaisList = [];
    for (int i = 0; i < rawLocais.length; i++) {
      final item = rawLocais[i];
      if (item is Map) {
        final totalItem = (item['total'] as num?)?.toInt() ?? 0;
        final pct = totalLocais > 0 ? (totalItem / totalLocais) * 100.0 : 0.0;
        locaisList.add(
          LocalOcorrencia(
            posicao: i + 1,
            bairro: item['bairro']?.toString() ?? 'Não identificado',
            total: totalItem,
            porcentagem: double.parse(pct.toStringAsFixed(1)),
          ),
        );
      }
    }

    final tempoMedioStr = json['tempo_medio_resposta_formatado']?.toString() ??
        json['tempo_medio_formatado']?.toString() ??
        '—';

    return DashboardMetricsModel(
      totalAtendimentos: (json['total_atendimentos'] as num?)?.toInt() ?? 0,
      atendimentosHoje: (json['atendimentos_hoje'] as num?)?.toInt() ?? 0,
      tempoMedioFormatado: tempoMedioStr,
      totalUnidadesAtivas: (json['total_unidades_ativas'] as num?)?.toInt() ?? 0,
      totalUnidadesParadas: (json['total_unidades_paradas'] as num?)?.toInt() ?? 0,
      atendimentosPorUnidade: unidadesMap,
      distribuicaoFaixaEtaria: faixasMap,
      locaisMaisFrequentes: locaisList,
      reposicaoUtensilios: (json['reposicao_utensilios'] as Map<String, dynamic>?) ?? {},
      taxaCrescimentoMensal: 8.5,
    );
  }

  // Compatibilidade com telas e gráficos existentes
  Map<String, UnidadeMetrica> get unidades {
    final total = totalAtendimentos > 0 ? totalAtendimentos : 1;
    return atendimentosPorUnidade.map((key, count) {
      final pct = (count / total) * 100.0;
      return MapEntry(
        key,
        UnidadeMetrica(total: count, porcentagem: double.parse(pct.toStringAsFixed(1))),
      );
    });
  }

  Map<String, double> get faixasEtarias {
    final total = totalAtendimentos > 0 ? totalAtendimentos : 1;
    return distribuicaoFaixaEtaria.map((key, count) {
      final pct = (count / total) * 100.0;
      return MapEntry(key, double.parse(pct.toStringAsFixed(1)));
    });
  }

  Map<String, int> get atendimentosPorNivel =>
      customAtendimentosPorNivel ??
      {
        'Emergências': (totalAtendimentos * 0.45).round(),
        'Urgências': (totalAtendimentos * 0.35).round(),
        'Rotina': (totalAtendimentos * 0.20).round(),
      };

  String get tempoMedioMinutos => tempoMedioFormatado;
  double get taxaIndisponibilidadePercentual {
    if (customTaxaIndisponibilidade != null) return customTaxaIndisponibilidade!;
    final total = totalUnidadesAtivas + totalUnidadesParadas;
    if (total == 0) return 0.0;
    return double.parse(((totalUnidadesParadas / total) * 100.0).toStringAsFixed(1));
  }

  String get horasIndisponibilidade =>
      customHorasIndisponibilidade ??
      '$totalUnidadesParadas viaturas paradas / ${totalUnidadesAtivas + totalUnidadesParadas} total';

  factory DashboardMetricsModel.mockDefault() {
    return const DashboardMetricsModel(
      totalAtendimentos: 4562,
      atendimentosHoje: 148,
      tempoMedioFormatado: '8:42',
      totalUnidadesAtivas: 18,
      totalUnidadesParadas: 2,
      taxaCrescimentoMensal: 12.5,
      atendimentosPorUnidade: {
        'Unidade Norte': 1247,
        'Unidade Sul': 1120,
        'Unidade Leste': 980,
        'Unidade Oeste': 815,
        'Outras': 400,
      },
      distribuicaoFaixaEtaria: {
        '0-12': 320,
        '13-17': 210,
        '18-59': 2540,
        '60+': 1492,
      },
      locaisMaisFrequentes: [
        LocalOcorrencia(posicao: 1, bairro: 'Centro', total: 387, porcentagem: 28.5),
        LocalOcorrencia(posicao: 2, bairro: 'Aventureiro', total: 295, porcentagem: 21.7),
        LocalOcorrencia(posicao: 3, bairro: 'Costa e Silva', total: 240, porcentagem: 17.6),
        LocalOcorrencia(posicao: 4, bairro: 'Paranaguamirim', total: 220, porcentagem: 16.2),
        LocalOcorrencia(posicao: 5, bairro: 'Vila Nova', total: 218, porcentagem: 16.0),
      ],
      customAtendimentosPorNivel: {
        'Emergências': 523,
        'Urgências': 892,
        'Rotina': 432,
      },
      customTaxaIndisponibilidade: 12.3,
      customHorasIndisponibilidade: '287h / 2332h',
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
