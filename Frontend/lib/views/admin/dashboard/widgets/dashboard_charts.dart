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
            if (constraints.maxWidth < 980) {
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
            if (constraints.maxWidth < 980) {
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

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AppColors.borderLight),
      boxShadow: const [
        BoxShadow(
          color: Color(0x06000000),
          blurRadius: 10,
          offset: Offset(0, 2),
        ),
      ],
    );
  }

  Widget _buildCardHeader(IconData icon, String title, {Color? iconColor, Color? bgColor}) {
    final c = iconColor ?? AppColors.primaryRed;
    final bg = bgColor ?? AppColors.badgeRed;
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(7),
          ),
          child: Icon(icon, size: 15, color: c),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAtendimentosRealizadosCard() {
    final niveis = metrics.atendimentosPorNivel;
    final int emergencias = niveis['Emergências'] ?? 0;
    final int urgencias = niveis['Urgências'] ?? 0;
    final int rotina = niveis['Rotina'] ?? 0;
    final int sumNiveis = (emergencias + urgencias + rotina) > 0
        ? (emergencias + urgencias + rotina)
        : 1;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCardHeader(Icons.insights_rounded, "Classificação de Atendimentos"),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                metrics.totalAtendimentos.toString(),
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.successBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  "+8.5%",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.success,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildMetricRow(
            "Emergências (Código Vermelho)",
            emergencias.toString(),
            emergencias / sumNiveis,
            AppColors.primaryRed,
          ),
          const SizedBox(height: 10),
          _buildMetricRow(
            "Urgências (Código Amarelo)",
            urgencias.toString(),
            urgencias / sumNiveis,
            AppColors.warning,
          ),
          const SizedBox(height: 10),
          _buildMetricRow(
            "Rotina (Código Verde)",
            rotina.toString(),
            rotina / sumNiveis,
            AppColors.success,
          ),
        ],
      ),
    );
  }

  Widget _buildMetricRow(String label, String value, double ratio, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                ),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: ratio.clamp(0.0, 1.0),
            minHeight: 5,
            backgroundColor: const Color(0xFFF2F4F7),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  Widget _buildFaixaEtariaCard() {
    final faixas = metrics.distribuicaoFaixaEtaria;
    final total = metrics.totalAtendimentos > 0 ? metrics.totalAtendimentos : 1;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCardHeader(Icons.family_restroom_rounded, "Faixa Etária dos Pacientes"),
          const SizedBox(height: 16),
          if (faixas.isEmpty)
            const Text(
              "Nenhum registro de faixa etária no período.",
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            )
          else
            ...faixas.entries.map((e) {
              final ratio = (e.value / total).clamp(0.0, 1.0);
              final pct = (ratio * 100).toStringAsFixed(1);
              final label = e.key.contains('anos') ? e.key : '${e.key} anos';
              return Padding(
                padding: const EdgeInsets.only(bottom: 11.0),
                child: _buildAgeBar(label, ratio, "$pct%"),
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
          width: 78,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 8,
              backgroundColor: const Color(0xFFF2F4F7),
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.darkOrange),
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 46,
          child: Text(
            percent,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
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
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCardHeader(Icons.location_on_outlined, "Bairros com Maior Ocorrência"),
          const SizedBox(height: 16),
          if (locais.isEmpty)
            const Text(
              "Sem ocorrências registradas no período.",
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            )
          else
            ...locais.map(
              (l) => Padding(
                padding: const EdgeInsets.only(bottom: 9.0),
                child: _buildLocationRow(
                  l.posicao.toString(),
                  l.bairro,
                  l.total,
                  l.porcentagem,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLocationRow(String pos, String local, int total, double pct) {
    return Row(
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            color: pos == "1" ? AppColors.primaryRed : AppColors.badgeRed,
          ),
          child: Center(
            child: Text(
              pos,
              style: TextStyle(
                fontSize: 11,
                color: pos == "1" ? Colors.white : AppColors.primaryRed,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            local,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F6F8),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            "$total ($pct%)",
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTempoMedioRespostaCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCardHeader(Icons.schedule_rounded, "Tempo Médio de Resposta"),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                metrics.tempoMedioFormatado,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.successBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  "Dentro da meta SAMU",
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.success,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            "tempo médio de deslocamento até o local da ocorrência",
            style: TextStyle(fontSize: 11, color: AppColors.textMuted),
          ),
          const Divider(height: 24, color: AppColors.borderLight),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Central de Regulação",
                    style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                  ),
                  SizedBox(height: 2),
                  Text(
                    "SAMU 192 Joinville",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    "Status da Frota",
                    style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "${metrics.totalUnidadesAtivas} viaturas operacionais",
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.success,
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

  Widget _buildIndisponibilidadeAmbulanciasCard() {
    final total = metrics.totalUnidadesAtivas + metrics.totalUnidadesParadas;
    final pctParadas = metrics.taxaIndisponibilidadePercentual;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCardHeader(
            Icons.warning_amber_rounded,
            "Indisponibilidade de Ambulâncias",
            iconColor: AppColors.darkOrange,
            bgColor: AppColors.warningBg,
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                "${pctParadas.toStringAsFixed(1)}%",
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                "${metrics.totalUnidadesParadas} parada(s) de $total viaturas",
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: Container(
              height: 7,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF4CAF50),
                    Color(0xFFFF9800),
                    Color(0xFFF44336),
                  ],
                ),
              ),
            ),
          ),
          const Divider(height: 24, color: AppColors.borderLight),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Viaturas Ativas",
                    style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "${metrics.totalUnidadesAtivas} unidades",
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    "Em Manutenção / Paradas",
                    style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "${metrics.totalUnidadesParadas} unidades",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: metrics.totalUnidadesParadas > 0
                          ? AppColors.error
                          : AppColors.success,
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
