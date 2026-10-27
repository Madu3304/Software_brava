// ============================================================================
// COMPONENTE DE SEPARAÇÃO VISUAL PARA IDENTIFICAÇÃO DE INÍCIO DE TELA
// Arquivo: lib/views/shared/tela_separador_widget.dart
// ============================================================================

import 'package:flutter/material.dart';

/// Widget de separação nítida inserido no topo de cada tela do dashboard
/// para identificar visualmente onde uma tela começa.
class TelaSeparadorWidget extends StatelessWidget {
  final String nomeTela;
  final String modulo;
  final IconData icone;

  const TelaSeparadorWidget({
    super.key,
    required this.nomeTela,
    this.modulo = 'PAINEL ADMINISTRATIVO (WEB)',
    this.icone = Icons.dashboard_customize_outlined,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 20.0),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF5F5),
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(
          color: const Color(0xFFFFCDD2),
          width: 1.2,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0AD32F2F),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: const Color(0xFFD32F2F),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Icon(
              icone,
              size: 18,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6.0,
                        vertical: 2.0,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFC62828),
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                      child: const Text(
                        "INÍCIO DE TELA",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      modulo,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  nomeTela,
                  style: const TextStyle(
                    color: Color(0xFFB71C1C),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFFFCDD2)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF2E7D32),
                  ),
                ),
                const SizedBox(width: 6),
                const Text(
                  "Visualização Ativa",
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFF424242),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
