import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/constants/app_colors.dart';
import 'core/constants/app_routes.dart';
import 'models/ficha_model.dart';
import 'models/usuario_model.dart';
import 'providers/dashboard_provider.dart';
import 'providers/ficha_provider.dart';
import 'services/admin_data_service.dart';
import 'services/auth_service.dart';
import 'services/database_service.dart';
import 'services/gps_service.dart';
import 'services/sync_service.dart';
import 'views/auth/login_view.dart';
import 'views/admin/dashboard/dashboard_view.dart';
import 'views/assistencial/ficha_atendimento_view.dart';
import 'views/assistencial/registro_atendimento_view.dart';
import 'views/assistencial/dados_paciente_view.dart';
import 'views/assistencial/avaliacao_clinica_view.dart';
import 'views/assistencial/impressao_sucesso_view.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Restaura sessão segura prévia caso exista
  await AuthService().restaurarSessao();
  runApp(const SoftwareBravaApp());
}

class SoftwareBravaApp extends StatelessWidget {
  const SoftwareBravaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AdminDataService()),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProvider(create: (_) => FichaEmAndamentoProvider()),
        Provider(create: (_) => AuthService()),
        Provider(create: (_) => DatabaseService()),
        Provider(create: (_) => SyncService()),
        Provider(create: (_) => GpsService()),
      ],
      child: MaterialApp(
        title: 'Software Brava - SAMU Joinville',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          primaryColor: AppColors.primaryRed,
          scaffoldBackgroundColor: AppColors.pageBackground,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primaryRed,
            primary: AppColors.primaryRed,
            secondary: AppColors.samuOrange,
            surface: AppColors.surface,
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: AppColors.primaryRed,
            foregroundColor: Colors.white,
            elevation: 0,
          ),
        ),
        initialRoute: AppRoutes.login,
        onGenerateRoute: (RouteSettings settings) {
          final currentUser = AuthService().currentUser;
          final isAuthenticated = AuthService().isAuthenticated;

          // Rota pública de autenticação
          if (settings.name == AppRoutes.login) {
            return MaterialPageRoute(
              settings: settings,
              builder: (_) => const LoginView(),
            );
          }

          if (!isAuthenticated) {
            return MaterialPageRoute(
              settings: const RouteSettings(name: AppRoutes.login),
              builder: (_) => const LoginView(),
            );
          }

          if (settings.name == AppRoutes.dashboard) {
            if (currentUser?.perfil != PerfilUsuario.admin) {
              return MaterialPageRoute(
                settings: const RouteSettings(name: AppRoutes.ficha),
                builder: (_) => const FichaAtendimentoView(),
              );
            }
            return MaterialPageRoute(
              settings: settings,
              builder: (_) => const DashboardView(),
            );
          }

          // Rotas Operacionais Assistenciais (Ficha SAMU)
          if (settings.name == AppRoutes.ficha) {
            return MaterialPageRoute(
              settings: settings,
              builder: (_) => const FichaAtendimentoView(),
            );
          }

          if (settings.name == AppRoutes.registroFicha) {
            return MaterialPageRoute(
              settings: settings,
              builder: (_) => const RegistroAtendimentoView(),
            );
          }

          if (settings.name == AppRoutes.dadosPaciente) {
            final ficha = settings.arguments as FichaAtendimentoModel?;
            return MaterialPageRoute(
              settings: settings,
              builder: (_) => DadosPacienteView(fichaParcial: ficha),
            );
          }

          if (settings.name == AppRoutes.avaliacaoClinica) {
            final ficha = settings.arguments as FichaAtendimentoModel?;
            return MaterialPageRoute(
              settings: settings,
              builder: (_) => AvaliacaoClinicaView(fichaParcial: ficha),
            );
          }

          if (settings.name == AppRoutes.impressaoSucesso) {
            return MaterialPageRoute(
              settings: settings,
              builder: (_) => const ImpressaoSucessoView(),
            );
          }

          // Fallback para qualquer rota não mapeada
          return MaterialPageRoute(
            settings: const RouteSettings(name: AppRoutes.login),
            builder: (_) => const LoginView(),
          );
        },
      ),
    );
  }
}