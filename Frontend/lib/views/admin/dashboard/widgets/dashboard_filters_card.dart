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
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 12,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.badgeRed,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(
                      Icons.tune_rounded,
                      size: 15,
                      color: AppColors.primaryRed,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "Filtros de Período e Unidade",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.successBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.circle, size: 7, color: AppColors.success),
                    SizedBox(width: 6),
                    Text(
                      "Dados sincronizados",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _buildDropdown(
                width: 125,
                icon: Icons.calendar_today_outlined,
                value: selectedAno,
                items: const ['2026', '2025', '2024'],
                onChanged: onAnoChanged,
              ),
              _buildDropdown(
                width: 165,
                icon: Icons.calendar_month_outlined,
                value: selectedMes,
                items: const [
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
                width: 155,
                icon: Icons.today_outlined,
                value: selectedDia,
                items: const ['Todos os Dias', 'Hoje', 'Ontem', 'Últimos 7 dias'],
                onChanged: onDiaChanged,
              ),
              _buildDropdown(
                width: 175,
                icon: Icons.airport_shuttle_outlined,
                value: selectedUnidade,
                items: const [
                  'Todas as Unidades',
                  'Unidade Norte',
                  'Unidade Sul',
                  'Unidade Leste',
                  'Unidade Oeste',
                ],
                onChanged: onUnidadeChanged,
              ),
              SizedBox(
                height: 36,
                child: ElevatedButton.icon(
                  onPressed: onFiltrar,
                  icon: const Icon(Icons.refresh_rounded, size: 16),
                  label: const Text(
                    "Atualizar",
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryRed,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 36,
                child: OutlinedButton.icon(
                  onPressed: onExportar,
                  icon: const Icon(Icons.download_rounded, size: 15),
                  label: const Text(
                    "Exportar",
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textPrimary,
                    side: const BorderSide(color: AppColors.borderNeutral),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required double width,
    required IconData icon,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      width: width,
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.inputBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderNeutral),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          isDense: true,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 18,
            color: AppColors.textSecondary,
          ),
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
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
