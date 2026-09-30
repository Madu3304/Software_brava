import 'package:flutter/material.dart';
import 'views/auth/login_view.dart';
import 'views/admin/dashboard/dashboard_view.dart';
import 'views/assistencial/ficha_atendimento_view.dart';
import 'views/assistencial/registro_atendimento_view.dart';
import 'views/assistencial/impressao_sucesso_view.dart';
import 'core/constants/app_routes.dart';

void main() {
  runApp(const SoftwareBravaApp());
}

class SoftwareBravaApp extends StatelessWidget {
  const SoftwareBravaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Software Brava - SAMU Joinville',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: const Color(0xFFD32F2F),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFD32F2F)),
      ),
      initialRoute: AppRoutes.login,
      routes: {
        AppRoutes.login: (context) => const LoginView(),
        AppRoutes.dashboard: (context) => const DashboardView(),
        AppRoutes.ficha: (context) => const FichaAtendimentoView(),
        AppRoutes.registroFicha: (context) => const RegistroAtendimentoView(),
        AppRoutes.impressaoSucesso: (context) => const ImpressaoSucessoView(),
      },
    );
  }
}