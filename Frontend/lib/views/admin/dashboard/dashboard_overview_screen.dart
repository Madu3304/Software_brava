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
      padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Dashboard",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Acompanhe os resultados das unidades móveis de atendimento",
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              if (dashboardProvider.isLoading)
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.primaryRed),
                ),
            ],
          ),
          const SizedBox(height: 20),

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
          const SizedBox(height: 24),

          // KPIs Principais
          DashboardKpiCards(metrics: metrics),
          const SizedBox(height: 32),

          const Text(
            "Métricas Detalhadas",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),

          // Gráficos e Distribuição
          DashboardCharts(metrics: metrics),
        ],
      ),
    );
  }
}
