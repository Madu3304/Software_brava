// ============================================================================
// WIDGET COMPONENTE: SELETOR DE TIPO DE VIATURA / USB (FIGMA SAMU)
// Arquivo: lib/views/assistencial/widgets/unidade_tipo_card.dart
// ============================================================================

import 'package:flutter/material.dart';

class UnidadeTipoCard extends StatelessWidget {
  final String tipoAtual;
  final ValueChanged<String>? onTipoChanged;

  const UnidadeTipoCard({
    super.key,
    this.tipoAtual = 'USB',
    this.onTipoChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12.0),
          onTap: () {
            // Alterna ou seleciona viatura (USB ou USA)
            if (onTipoChanged != null) {
              onTipoChanged!(tipoAtual == 'USB' ? 'USA' : 'USB');
            }
          },
          child: Container(
            height: 52,
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            decoration: BoxDecoration(
              color: const Color(0xFFE50914), // Vermelho vivo idêntico ao Figma
              borderRadius: BorderRadius.circular(12.0),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x2EE50914),
                  blurRadius: 8,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Icon(
                  Icons.electric_bolt_rounded,
                  color: Colors.white,
                  size: 22,
                ),
                const SizedBox(width: 14),
                Text(
                  tipoAtual,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 0.5,
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
