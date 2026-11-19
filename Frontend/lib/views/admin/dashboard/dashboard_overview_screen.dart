import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../providers/dashboard_provider.dart';
import 'widgets/dashboard_filters_card.dart';
import 'widgets/dashboard_kpi_cards.dart';
import 'widgets/dashboard_charts.dart';

class DashboardOverviewScreen extends StatefulWidget {
  const DashboardOverviewScreen({super.key});

  @override
  State<DashboardOverviewScreen> createState() => _DashboardOverviewScreenState();
}

class _DashboardOverviewScreenState extends State<DashboardOverviewScreen> {
  String _selectedAno = '2026';
  String _selectedMes = 'Todos os Meses';
  String _selectedDia = 'Todos os Dias';
  String _selectedUnidade = 'Todas as Unidades';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _filtrarMetricas();
      }
    });
  }

  void _filtrarMetricas() {
    context.read<DashboardProvider>().carregarMetricas(
          ano: _selectedAno,
          mes: _selectedMes,
          dia: _selectedDia,
          unidade: _selectedUnidade,
        );
  }

  @override
  Widget build(BuildContext context) {
    final dashboardProvider = context.watch<DashboardProvider>();
    final metrics = dashboardProvider.metrics;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 22.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: AppColors.badgeRed,
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: const Icon(
                      Icons.analytics_outlined,
                      color: AppColors.primaryRed,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Dashboard Operacional",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        "Acompanhe os indicadores e resultados das unidades móveis de atendimento",
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (dashboardProvider.isLoading)
                const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: AppColors.primaryRed,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 18),

          // Card de Filtros
          DashboardFiltersCard(
            selectedAno: _selectedAno,
            selectedMes: _selectedMes,
            selectedDia: _selectedDia,
            selectedUnidade: _selectedUnidade,
            onAnoChanged: (val) => setState(() => _selectedAno = val ?? _selectedAno),
            onMesChanged: (val) => setState(() => _selectedMes = val ?? _selectedMes),
            onDiaChanged: (val) => setState(() => _selectedDia = val ?? _selectedDia),
            onUnidadeChanged: (val) => setState(() => _selectedUnidade = val ?? _selectedUnidade),
            onFiltrar: _filtrarMetricas,
            onExportar: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Relatório gerencial exportado com sucesso."),
                  backgroundColor: AppColors.success,
                ),
              );
            },
          ),
          const SizedBox(height: 20),

          // KPIs Principais + Gráfico de Evolução Mensal lado a lado
          DashboardKpiCards(metrics: metrics),
          const SizedBox(height: 28),

          Row(
            children: [
              Container(
                width: 4,
                height: 18,
                decoration: BoxDecoration(
                  color: AppColors.primaryRed,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                "Métricas Detalhadas",
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Gráficos e Distribuição
          DashboardCharts(metrics: metrics),
          const SizedBox(height: 24),

          // Monitoramento de Paradas de Viaturas (RF12)
          _buildParadasViaturasCard(dashboardProvider.paradasViaturas),
          const SizedBox(height: 28),
        ],
      ),
    );
  }

  Widget _buildParadasViaturasCard(Map<String, dynamic>? paradas) {
    final totalParadas = (paradas?['total_paradas'] as num?)?.toInt() ?? 0;
    final unidades = (paradas?['unidades'] as List?) ?? const [];
    final historico = (paradas?['historico_fichas_com_parada'] as List?) ?? const [];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.report_problem_outlined, color: AppColors.primaryRed, size: 20),
                  SizedBox(width: 8),
                  Text(
                    "Monitoramento de Paradas de Viaturas",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: totalParadas > 0 ? AppColors.badgeRed : AppColors.successBg,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  "$totalParadas viatura(s) parada(s)",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: totalParadas > 0 ? AppColors.primaryRed : AppColors.success,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (unidades.isEmpty && historico.isEmpty)
            const Text(
              "Nenhuma parada técnica ou indisponibilidade registrada no momento.",
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            )
          else ...[
            ...unidades.map((u) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(
                    "• ${u['base_unidade'] ?? 'Unidade'} (${u['placa'] ?? '-'}): ${u['motivo'] ?? 'Sem motivo informado'}",
                    style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
                  ),
                )),
            ...historico.take(5).map((h) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    "• Ficha #${h['id_ficha']}: ${h['motivo'] ?? 'Parada registrada em ocorrência'}",
                    style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                  ),
                )),
          ],
        ],
      ),
    );
  }
}
