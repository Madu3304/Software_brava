import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../models/dashboard_metrics_model.dart';

class DashboardKpiCards extends StatelessWidget {
  final DashboardMetricsModel metrics;

  const DashboardKpiCards({super.key, required this.metrics});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildTotalCard(),
        const SizedBox(height: 16),
        _buildGridUnidades(),
      ],
    );
  }

  Widget _buildTotalCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.softRedCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderRed),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Total de Atendimentos",
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                metrics.totalAtendimentos.toString(),
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.today, size: 16, color: AppColors.success),
                  const SizedBox(width: 4),
                  Text(
                    "${metrics.atendimentosHoje} atendimentos hoje",
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.success,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.badgeRed,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.people_outline_rounded,
              color: AppColors.primaryRed,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridUnidades() {
    final unidades = metrics.unidades;
    if (unidades.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: const Center(
          child: Text(
            "Nenhuma base com atendimento registrado no período",
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
        ),
      );
    }

    final entries = unidades.entries.toList();

    return Column(
      children: [
        for (int i = 0; i < entries.length; i += 2)
          Padding(
            padding: EdgeInsets.only(bottom: i + 2 < entries.length ? 14.0 : 0),
            child: Row(
              children: [
                Expanded(
                  child: _buildUnitCard(
                    nome: entries[i].key,
                    porcentagem: "${entries[i].value.porcentagem}%",
                    total: entries[i].value.total.toString(),
                    badgeColor: AppColors.badgeRed,
                    textColor: AppColors.crimson,
                  ),
                ),
                if (i + 1 < entries.length) ...[
                  const SizedBox(width: 14),
                  Expanded(
                    child: _buildUnitCard(
                      nome: entries[i + 1].key,
                      porcentagem: "${entries[i + 1].value.porcentagem}%",
                      total: entries[i + 1].value.total.toString(),
                      badgeColor: AppColors.warningBg,
                      textColor: AppColors.darkOrange,
                    ),
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildUnitCard({
    required String nome,
    required String porcentagem,
    required String total,
    required Color badgeColor,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.airport_shuttle_outlined, size: 16, color: textColor),
                  const SizedBox(width: 6),
                  Text(
                    nome,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: badgeColor,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  porcentagem,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            total,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            "atendimentos",
            style: TextStyle(
              fontSize: 11,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
