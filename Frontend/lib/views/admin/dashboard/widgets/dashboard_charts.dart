import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../models/dashboard_metrics_model.dart';

class DashboardCharts extends StatelessWidget {
  final DashboardMetricsModel metrics;

  const DashboardCharts({super.key, required this.metrics});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 1000) {
              return Column(
                children: [
                  _buildAtendimentosRealizadosCard(),
                  const SizedBox(height: 16),
                  _buildFaixaEtariaCard(),
                  const SizedBox(height: 16),
                  _buildLocaisMaiorOcorrenciaCard(),
                ],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildAtendimentosRealizadosCard()),
                const SizedBox(width: 16),
                Expanded(child: _buildFaixaEtariaCard()),
                const SizedBox(width: 16),
                Expanded(child: _buildLocaisMaiorOcorrenciaCard()),
              ],
            );
          },
        ),
        const SizedBox(height: 16),

        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 1000) {
              return Column(
                children: [
                  _buildTempoMedioRespostaCard(),
                  const SizedBox(height: 16),
                  _buildIndisponibilidadeAmbulanciasCard(),
                ],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildTempoMedioRespostaCard()),
                const SizedBox(width: 16),
                Expanded(child: _buildIndisponibilidadeAmbulanciasCard()),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildAtendimentosRealizadosCard() {
    final niveis = metrics.atendimentosPorNivel;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.insights, size: 16, color: AppColors.primaryRed),
              SizedBox(width: 8),
              Text(
                "Atendimentos Realizados",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                metrics.totalAtendimentos.toString(),
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                "+8.5%",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.success,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildMetricRow("Emergências", niveis['Emergências']?.toString() ?? '0', AppColors.primaryRed),
          const SizedBox(height: 8),
          _buildMetricRow("Urgências", niveis['Urgências']?.toString() ?? '0', AppColors.warning),
          const SizedBox(height: 8),
          _buildMetricRow("Rotina", niveis['Rotina']?.toString() ?? '0', AppColors.success),
        ],
      ),
    );
  }

  Widget _buildMetricRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        Text(
          value,
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }

  Widget _buildFaixaEtariaCard() {
    final faixas = metrics.distribuicaoFaixaEtaria;
    final total = metrics.totalAtendimentos > 0 ? metrics.totalAtendimentos : 1;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.family_restroom, size: 16, color: AppColors.primaryRed),
              SizedBox(width: 8),
              Text(
                "Faixa Etária dos Pacientes",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (faixas.isEmpty)
            const Text("Nenhum registro de faixa etária no período.",
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary))
          else
            ...faixas.entries.map((e) {
              final ratio = (e.value / total).clamp(0.0, 1.0);
              final pct = (ratio * 100).toStringAsFixed(1);
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: _buildAgeBar(e.key.split(' ').first, ratio, "$pct%"),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildAgeBar(String label, double ratio, String percent) {
    return Row(
      children: [
        SizedBox(
          width: 75,
          child: Text(
            label,
            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 8,
              backgroundColor: AppColors.borderLight,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.darkOrange),
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 44,
          child: Text(
            percent,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLocaisMaiorOcorrenciaCard() {
    final locais = metrics.locaisMaisFrequentes;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.location_on_outlined, size: 16, color: AppColors.primaryRed),
              SizedBox(width: 8),
              Text(
                "Locais com Maior Ocorrência",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (locais.isEmpty)
            const Text("Sem ocorrências registradas no período.",
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary))
          else
            ...locais.map(
              (l) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: _buildLocationRow(
                  l.posicao.toString(),
                  l.bairro,
                  "${l.total} (${l.porcentagem}%)",
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLocationRow(String pos, String local, String ocorrencias) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primaryRed,
          ),
          child: Center(
            child: Text(
              pos,
              style: const TextStyle(
                fontSize: 10,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            local,
            style: const TextStyle(fontSize: 12, color: AppColors.textDark),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Text(
          ocorrencias,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildTempoMedioRespostaCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.schedule, size: 16, color: AppColors.primaryRed),
              SizedBox(width: 8),
              Text(
                "Tempo Médio de Resposta",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                metrics.tempoMedioFormatado,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const Text(
            "tempo médio de deslocamento até o local",
            style: TextStyle(fontSize: 11, color: AppColors.textMuted),
          ),
          const Divider(height: 24, color: AppColors.borderLight),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Ativas na Rede", style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                  SizedBox(height: 2),
                  Text("Joinville Central", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text("Status da Frota", style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                  const SizedBox(height: 2),
                  Text(
                    "${metrics.totalUnidadesAtivas} operacionais",
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.success),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIndisponibilidadeAmbulanciasCard() {
    final total = metrics.totalUnidadesAtivas + metrics.totalUnidadesParadas;
    final pctParadas = total > 0 ? (metrics.totalUnidadesParadas / total) * 100 : 0.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.warning_amber_rounded, size: 16, color: AppColors.samuOrange),
              SizedBox(width: 8),
              Text(
                "Indisponibilidade de Ambulâncias",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                "${pctParadas.toStringAsFixed(1)}%",
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          Text(
            "${metrics.totalUnidadesParadas} viatura(s) parada(s) de $total viaturas cadastradas",
            style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
          ),
          const Divider(height: 24, color: AppColors.borderLight),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Viaturas Ativas", style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                  const SizedBox(height: 2),
                  Text(
                    "${metrics.totalUnidadesAtivas} unidades",
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.success),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text("Viaturas Paradas", style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                  const SizedBox(height: 2),
                  Text(
                    "${metrics.totalUnidadesParadas} unidades",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: metrics.totalUnidadesParadas > 0 ? AppColors.error : AppColors.success,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
