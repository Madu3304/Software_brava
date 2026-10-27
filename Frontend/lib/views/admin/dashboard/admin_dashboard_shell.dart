// ============================================================================
// ----------------------------------------------------------------------------
// [LAYOUT MESTRE] - SHELL DO DASHBOARD ADMINISTRATIVO (FLUTTER WEB)
// Arquivo: lib/models/dashboard/admin_dashboard_shell.dart
// ============================================================================

import 'package:flutter/material.dart';
import 'dashboard_overview_screen.dart';
import '../cadastros/cadastro_medico_screen.dart';
import '../cadastros/cadastro_enfermagem_screen.dart';
import '../cadastros/cadastro_socorrista_screen.dart';
import '../cadastros/cadastro_unidade_screen.dart';

class AdminDashboardShell extends StatefulWidget {
  final int initialScreenIndex;
  const AdminDashboardShell({super.key, this.initialScreenIndex = 0});

  @override
  State<AdminDashboardShell> createState() => _AdminDashboardShellState();
}

class _AdminDashboardShellState extends State<AdminDashboardShell> {
  late int _selectedMenuIndex;

  @override
  void initState() {
    super.initState();
    _selectedMenuIndex = widget.initialScreenIndex;
  }

  // Telas do Menu Principal
  final List<Widget> _screens = const [
    DashboardOverviewScreen(), // 0: Dashboard
    CadastroMedicoScreen(), // 1: Cadastrar Médico
    CadastroEnfermagemScreen(), // 2: Cadastrar Téc. Enfermagem
    CadastroSocorristaScreen(), // 3: Cadastrar Socorrista
    CadastroUnidadeScreen(), // 4: Cadastrar Unidade
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: Row(
        children: [
          // Sidebar Lateral (Figma)
          _buildSidebar(context),

          const VerticalDivider(width: 1, thickness: 1, color: Color(0xFFEEEEEE)),

          // Área da Tela Ativa
          Expanded(
            child: Container(
              color: const Color(0xFFFBFBFB),
              child: _screens[_selectedMenuIndex],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar(BuildContext context) {
    return Container(
      width: 250,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logotipo e Identificação do Sistema
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFFC62828),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: const Center(
                  child: Icon(
                    Icons.airport_shuttle,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Unidades Móveis",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF212121),
                    ),
                  ),
                  Text(
                    "Sistema de Gestão",
                    style: TextStyle(
                      fontSize: 11,
                      color: Color(0xFF757575),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 28),

          // Menu Principal
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              "MENU PRINCIPAL",
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Color(0xFF9E9E9E),
                letterSpacing: 0.8,
              ),
            ),
          ),
          const SizedBox(height: 12),

          _buildSidebarItem(
            index: 0,
            icon: Icons.grid_view_rounded,
            title: "Dashboard",
          ),
          const SizedBox(height: 6),
          _buildSidebarItem(
            index: 1,
            icon: Icons.person_add_alt_1_outlined,
            title: "Cadastrar Médico",
          ),
          const SizedBox(height: 6),
          _buildSidebarItem(
            index: 2,
            icon: Icons.healing_outlined,
            title: "Cadastrar Téc. Enfermagem",
          ),
          const SizedBox(height: 6),
          _buildSidebarItem(
            index: 3,
            icon: Icons.favorite_border_rounded,
            title: "Cadastrar Socorrista",
          ),
          const SizedBox(height: 6),
          _buildSidebarItem(
            index: 4,
            icon: Icons.airport_shuttle_outlined,
            title: "Cadastrar Unidade",
          ),
          const SizedBox(height: 6),

          // Item Ficha Técnica
          InkWell(
            onTap: () {
              Navigator.pushNamed(context, '/ficha');
            },
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.description_outlined,
                    size: 20,
                    color: Color(0xFF616161),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Ficha Técnica",
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF424242),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_outward_rounded,
                    size: 14,
                    color: Color(0xFFBDBDBD),
                  ),
                ],
              ),
            ),
          ),

          const Spacer(),

          const Divider(color: Color(0xFFEEEEEE)),
          const SizedBox(height: 8),

          // Perfil do Administrador Logado
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFC62828),
                ),
                child: const Center(
                  child: Text(
                    "AD",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Admin",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF212121),
                      ),
                    ),
                    Text(
                      "Administrador",
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF757575),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.logout_rounded, size: 18, color: Color(0xFF9E9E9E)),
                tooltip: "Encerrar Sessão",
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/');
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarItem({
    required int index,
    required IconData icon,
    required String title,
  }) {
    final bool isSelected = _selectedMenuIndex == index;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedMenuIndex = index;
        });
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFF0F0) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: isSelected
              ? Border.all(color: const Color(0xFFFFCDD2), width: 1.2)
              : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? const Color(0xFFC62828) : const Color(0xFF616161),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? const Color(0xFFC62828) : const Color(0xFF424242),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
