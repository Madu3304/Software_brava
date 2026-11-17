import 'package:flutter/material.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../services/auth_service.dart';
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
  bool _isSidebarExpanded = true;

  @override
  void initState() {
    super.initState();
    _selectedMenuIndex = widget.initialScreenIndex;
  }

  void _toggleSidebar() {
    setState(() {
      _isSidebarExpanded = !_isSidebarExpanded;
    });
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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Sidebar Lateral (Figma)
          _buildSidebar(context),

          const VerticalDivider(width: 1, thickness: 1, color: Color(0xFFEEEEEE)),

          // Área da Tela Ativa
          Expanded(
            child: Container(
              color: const Color(0xFFFBFBFB),
              alignment: Alignment.topLeft,
              child: SizedBox(
                width: double.infinity,
                child: _screens[_selectedMenuIndex],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeInOut,
      width: _isSidebarExpanded ? 250 : 76,
      color: Colors.white,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final bool showExpanded =
              _isSidebarExpanded && constraints.maxWidth >= 180;

          return Padding(
            padding: EdgeInsets.symmetric(
              horizontal: showExpanded ? 16.0 : 12.0,
              vertical: 20.0,
            ),
            child: Column(
              crossAxisAlignment: showExpanded
                  ? CrossAxisAlignment.start
                  : CrossAxisAlignment.center,
              children: [
                // Logotipo e Identificação do Sistema (Clique para abrir/fechar menu)
                Tooltip(
                  message: _isSidebarExpanded
                      ? "Clique para fechar o menu lateral"
                      : "Unidades Móveis - Sistema de Gestão (Clique para abrir o menu)",
                  waitDuration: const Duration(milliseconds: 100),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _toggleSidebar,
                      mouseCursor: SystemMouseCursors.click,
                      borderRadius: BorderRadius.circular(10.0),
                      hoverColor: const Color(0xFFFFF0F0),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 6.0,
                          horizontal: 4.0,
                        ),
                        child: Row(
                          mainAxisSize: showExpanded
                              ? MainAxisSize.max
                              : MainAxisSize.min,
                          mainAxisAlignment: showExpanded
                              ? MainAxisAlignment.start
                              : MainAxisAlignment.center,
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
                            if (showExpanded) ...[
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Unidades Móveis",
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF212121),
                                      ),
                                    ),
                                    Text(
                                      "Sistema de Gestão",
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Color(0xFF757575),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                // Menu Principal
                if (showExpanded) ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      "MENU PRINCIPAL",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF9E9E9E),
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ] else ...[
                  const Divider(color: Color(0xFFEEEEEE), height: 12),
                  const SizedBox(height: 8),
                ],

                _buildSidebarItem(
                  index: 0,
                  icon: Icons.grid_view_rounded,
                  title: "Dashboard",
                  showExpanded: showExpanded,
                ),
                const SizedBox(height: 6),
                _buildSidebarItem(
                  index: 1,
                  icon: Icons.person_add_alt_1_outlined,
                  title: "Médicos",
                  showExpanded: showExpanded,
                ),
                const SizedBox(height: 6),
                _buildSidebarItem(
                  index: 2,
                  icon: Icons.healing_outlined,
                  title: "Téc. Enfermagem",
                  showExpanded: showExpanded,
                ),
                const SizedBox(height: 6),
                _buildSidebarItem(
                  index: 3,
                  icon: Icons.favorite_border_rounded,
                  title: "Socorrista",
                  showExpanded: showExpanded,
                ),
                const SizedBox(height: 6),
                _buildSidebarItem(
                  index: 4,
                  icon: Icons.airport_shuttle_outlined,
                  title: "Unidade Básica",
                  showExpanded: showExpanded,
                ),
                const SizedBox(height: 6),

                // Item Ficha Técnica
                Tooltip(
                  message: "Ficha Técnica",
                  waitDuration: Duration.zero,
                  child: InkWell(
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.ficha);
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: showExpanded ? 14 : 0,
                        vertical: 11,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: showExpanded
                            ? MainAxisAlignment.start
                            : MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.description_outlined,
                            size: 20,
                            color: Color(0xFF616161),
                          ),
                          if (showExpanded) ...[
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                "Ficha Técnica",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF424242),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const Icon(
                              Icons.arrow_outward_rounded,
                              size: 14,
                              color: Color(0xFFBDBDBD),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),

                const Spacer(),

                const Divider(color: Color(0xFFEEEEEE)),
                const SizedBox(height: 8),

                // Perfil do Administrador Logado
                if (showExpanded)
                  Row(
                    children: [
                      Tooltip(
                        message: "Admin - Administrador",
                        waitDuration: const Duration(milliseconds: 200),
                        child: Container(
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
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Admin",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF212121),
                              ),
                            ),
                            Text(
                              "Administrador",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11,
                                color: Color(0xFF757575),
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.logout_rounded,
                          size: 18,
                          color: Color(0xFF9E9E9E),
                        ),
                        tooltip: "Encerrar Sessão",
                        onPressed: () async {
                          await AuthService().logout();
                          if (context.mounted) {
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              AppRoutes.login,
                              (r) => false,
                            );
                          }
                        },
                      ),
                    ],
                  )
                else
                  Column(
                    children: [
                      Tooltip(
                        message: "Admin - Administrador",
                        waitDuration: const Duration(milliseconds: 200),
                        child: Container(
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
                      ),
                      const SizedBox(height: 6),
                      IconButton(
                        icon: const Icon(
                          Icons.logout_rounded,
                          size: 18,
                          color: Color(0xFF9E9E9E),
                        ),
                        tooltip: "Encerrar Sessão",
                        onPressed: () async {
                          await AuthService().logout();
                          if (context.mounted) {
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              AppRoutes.login,
                              (r) => false,
                            );
                          }
                        },
                      ),
                    ],
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSidebarItem({
    required int index,
    required IconData icon,
    required String title,
    required bool showExpanded,
  }) {
    final bool isSelected = _selectedMenuIndex == index;

    return Tooltip(
      message: title,
      waitDuration: Duration.zero,
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedMenuIndex = index;
          });
        },
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: showExpanded ? 14 : 0,
            vertical: 11,
          ),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFFFF0F0) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: isSelected
                ? Border.all(color: const Color(0xFFFFCDD2), width: 1.2)
                : null,
          ),
          child: Row(
            mainAxisAlignment: showExpanded
                ? MainAxisAlignment.start
                : MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected
                    ? const Color(0xFFC62828)
                    : const Color(0xFF616161),
              ),
              if (showExpanded) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected
                          ? const Color(0xFFC62828)
                          : const Color(0xFF424242),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
