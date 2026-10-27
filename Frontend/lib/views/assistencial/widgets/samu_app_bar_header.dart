// ============================================================================
// WIDGET COMPONENTE: CABEÇALHO PADRÃO SAMU 192 (BANNER VERMELHO COM IDENTIDADE)
// Arquivo: lib/views/assistencial/widgets/samu_app_bar_header.dart
// ============================================================================

import 'package:flutter/material.dart';

class SamuAppBarHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showSamuLogo;
  final bool showAmbulanceWatermark;
  final VoidCallback? onBack;
  final VoidCallback? onLogout;

  const SamuAppBarHeader({
    super.key,
    required this.title,
    this.showSamuLogo = false,
    this.showAmbulanceWatermark = false,
    this.onBack,
    this.onLogout,
  });

  @override
  Size get preferredSize => const Size.fromHeight(70.0);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: preferredSize.height + MediaQuery.of(context).padding.top,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top,
        left: 16.0,
        right: 16.0,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFFE50914), // Vermelho vibrante padrão SAMU
        boxShadow: [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Marca d'água de ambulância no canto direito (conforme Figma)
          if (showAmbulanceWatermark)
            Positioned(
              right: 8,
              child: Opacity(
                opacity: 0.18,
                child: Icon(
                  Icons.airport_shuttle_rounded,
                  size: 48,
                  color: Colors.white,
                ),
              ),
            ),

          // Lado Esquerdo: Brasão / Logo SAMU 192 ou Botão Voltar
          Positioned(
            left: 0,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (onBack != null)
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                    onPressed: onBack,
                    tooltip: 'Voltar',
                  )
                else if (Navigator.canPop(context))
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                    onPressed: () => Navigator.pop(context),
                    tooltip: 'Voltar',
                  ),
                if (showSamuLogo) ...[
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFE65100), width: 1.5),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.emergency_rounded,
                        color: Color(0xFFC62828),
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "SAMU",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          height: 1.0,
                        ),
                      ),
                      Text(
                        "192",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          height: 1.0,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          // Centro: Título em destaque
          Center(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.3,
              ),
            ),
          ),

          // Lado Direito: Ação de Logout ou Saída
          if (onLogout != null)
            Positioned(
              right: 0,
              child: IconButton(
                icon: const Icon(Icons.logout, color: Colors.white),
                tooltip: 'Sair para o Login',
                onPressed: onLogout,
              ),
            ),
        ],
      ),
    );
  }
}
