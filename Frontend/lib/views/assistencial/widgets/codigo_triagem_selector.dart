// ============================================================================
// WIDGET COMPONENTE: SELETOR DE CÓDIGO DE TRIAGEM POR COR (FIGMA SAMU)
// Arquivo: lib/views/assistencial/widgets/codigo_triagem_selector.dart
// ============================================================================

import 'package:flutter/material.dart';

class CodigoTriagemSelector extends StatelessWidget {
  final String codigoSelecionado;
  final ValueChanged<String> onCodigoSelected;

  const CodigoTriagemSelector({
    super.key,
    required this.codigoSelecionado,
    required this.onCodigoSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 22.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: const Color(0xFFF0F0F0), width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Código:",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2C3437),
            ),
          ),
          const SizedBox(height: 16),
          // Grade 2x2 de botões de cor de atendimento
          Row(
            children: [
              Expanded(
                child: _buildColorButton(
                  label: "Vermelho",
                  color: const Color(0xFFFF2636),
                  isSelected: codigoSelecionado.toLowerCase() == 'vermelho',
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _buildColorButton(
                  label: "Amarelo",
                  color: const Color(0xFFFFB800),
                  isSelected: codigoSelecionado.toLowerCase() == 'amarelo',
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _buildColorButton(
                  label: "Verde",
                  color: const Color(0xFF00C853),
                  isSelected: codigoSelecionado.toLowerCase() == 'verde',
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _buildColorButton(
                  label: "Azul",
                  color: const Color(0xFF2979FF),
                  isSelected: codigoSelecionado.toLowerCase() == 'azul',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildColorButton({
    required String label,
    required Color color,
    required bool isSelected,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      height: 52,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12.0),
        border: isSelected
            ? Border.all(color: Colors.white, width: 2.5)
            : null,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(isSelected ? 0.45 : 0.25),
            blurRadius: isSelected ? 10 : 4,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12.0),
          onTap: () => onCodigoSelected(label),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isSelected) ...[
                  const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
                  const SizedBox(width: 6),
                ],
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
