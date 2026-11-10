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
            onFiltrar: () => context.read<DashboardProvider>().carregarMetricas(),
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
          const SizedBox(height: 28),
        ],
      ),
    );
  }
}
