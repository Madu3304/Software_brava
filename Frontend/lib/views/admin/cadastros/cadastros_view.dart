// ============================================================================
// VIEW ADMINISTRATIVA - CADASTROS
// Arquivo: lib/views/admin/cadastros_view.dart
// ============================================================================

import 'package:flutter/material.dart';
import '../dashboard/admin_dashboard_shell.dart';

class CadastrosView extends StatelessWidget {
  final int initialScreenIndex;
  const CadastrosView({super.key, this.initialScreenIndex = 1});

  @override
  Widget build(BuildContext context) {
    return AdminDashboardShell(initialScreenIndex: initialScreenIndex);
  }
}
