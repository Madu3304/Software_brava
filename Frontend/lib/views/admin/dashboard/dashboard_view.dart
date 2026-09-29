// ============================================================================
// VIEW ADMINISTRATIVA - DASHBOARD (ROTA: /dashboard)
// Arquivo: lib/views/admin/dashboard_view.dart
// ============================================================================

import 'package:flutter/material.dart';
import 'admin_dashboard_shell.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return const AdminDashboardShell(initialScreenIndex: 0);
  }
}
