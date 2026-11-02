import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class DashboardFiltersCard extends StatelessWidget {
  final String selectedAno;
  final String selectedMes;
  final String selectedDia;
  final String selectedUnidade;
  final ValueChanged<String?> onAnoChanged;
  final ValueChanged<String?> onMesChanged;
  final ValueChanged<String?> onDiaChanged;
  final ValueChanged<String?> onUnidadeChanged;
  final VoidCallback onFiltrar;
  final VoidCallback onExportar;

  const DashboardFiltersCard({
    super.key,
    required this.selectedAno,
    required this.selectedMes,
    required this.selectedDia,
    required this.selectedUnidade,
    required this.onAnoChanged,
    required this.onMesChanged,
    required this.onDiaChanged,
    required this.onUnidadeChanged,
    required this.onFiltrar,
    required this.onExportar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.tune_rounded, size: 18, color: AppColors.primaryRed),
              SizedBox(width: 8),
              Text(
                "Filtros de Período e Unidade",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _buildDropdown(
                icon: Icons.calendar_today_outlined,
                value: selectedAno,
                items: ['2026', '2025', '2024'],
                onChanged: onAnoChanged,
              ),
              _buildDropdown(
                icon: Icons.calendar_month_outlined,
                value: selectedMes,
                items: [
                  'Todos os Meses',
                  'Janeiro',
                  'Fevereiro',
                  'Março',
                  'Abril',
                  'Maio',
                  'Junho',
                  'Julho',
                  'Agosto',
                  'Setembro',
                  'Outubro',
                  'Novembro',
                  'Dezembro',
                ],
                onChanged: onMesChanged,
              ),
              _buildDropdown(
                icon: Icons.today_outlined,
                value: selectedDia,
                items: ['Todos os Dias', 'Hoje', 'Ontem', 'Últimos 7 dias'],
                onChanged: onDiaChanged,
              ),
              _buildDropdown(
                icon: Icons.airport_shuttle_outlined,
                value: selectedUnidade,
                items: [
                  'Todas as Unidades',
                  'Unidade Norte',
                  'Unidade Sul',
                  'Unidade Leste',
                  'Unidade Oeste',
                ],
                onChanged: onUnidadeChanged,
              ),
              ElevatedButton.icon(
                onPressed: onFiltrar,
                icon: const Icon(Icons.search, size: 16),
                label: const Text("Atualizar"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryRed,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              OutlinedButton.icon(
                onPressed: onExportar,
                icon: const Icon(Icons.download_rounded, size: 16),
                label: const Text("Exportar"),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textPrimary,
                  side: const BorderSide(color: AppColors.borderNeutral),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required IconData icon,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      width: 170,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.inputBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderNeutral),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: AppColors.textSecondary),
          style: const TextStyle(fontSize: 13, color: AppColors.textPrimary, fontWeight: FontWeight.w500),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Row(
                children: [
                  Icon(icon, size: 14, color: AppColors.textMuted),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(item, overflow: TextOverflow.ellipsis),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
