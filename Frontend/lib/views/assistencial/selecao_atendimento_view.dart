import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_routes.dart';
import '../../models/ficha_model.dart';
import '../../providers/ficha_provider.dart';
import '../../services/auth_service.dart';
import 'widgets/samu_app_bar_header.dart';

class SelecaoAtendimentoView extends StatelessWidget {
  final FichaAtendimentoModel? fichaParcial;

  const SelecaoAtendimentoView({
    super.key,
    this.fichaParcial,
  });

  Future<void> _fazerLogout(BuildContext context) async {
    await AuthService().logout();
    if (!context.mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (r) => false);
  }

  void _abrirFicha(BuildContext context, String perfil) {
    context.read<FichaEmAndamentoProvider>().selecionarPerfil(perfil);
    Navigator.pushNamed(context, AppRoutes.ficha);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF6F2),
      appBar: SamuAppBarHeader(
        title: 'Escolha da Ficha',
        showSamuLogo: false,
        showAmbulanceWatermark: false,
        onLogout: () => _fazerLogout(context),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'ESCOLHA DA FICHA',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.4,
                      color: AppColors.darkRed,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Qual é o perfil do paciente?',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF3A0A04),
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 28),
                  _PerfilAtendimentoButton(
                    titulo: 'Gestante',
                    subtitulo: 'Atendimento obstétrico e avaliação materno-fetal',
                    icone: Icons.child_care_outlined,
                    corIcone: const Color(0xFFB4430B),
                    corFundoIcone: const Color(0xFFFDEBD6),
                    onTap: () => _abrirFicha(context, 'gestante'),
                  ),
                  const SizedBox(height: 16),
                  _PerfilAtendimentoButton(
                    titulo: 'Idoso',
                    subtitulo: 'Avaliação geriátrica, mobilidade e medicação contínua',
                    icone: Icons.accessible,
                    corIcone: const Color(0xFF8A5A00),
                    corFundoIcone: const Color(0xFFFDF0C7),
                    onTap: () => _abrirFicha(context, 'idoso'),
                  ),
                  const SizedBox(height: 16),
                  _PerfilAtendimentoButton(
                    titulo: 'Paciente comum',
                    subtitulo: 'Ficha padrão para ocorrências clínicas e traumáticas',
                    icone: Icons.person_outline,
                    corIcone: AppColors.crimson,
                    corFundoIcone: const Color(0xFFFDE4E4),
                    onTap: () => _abrirFicha(context, 'comum'),
                  ),
                  const SizedBox(height: 28),
                  const Text(
                    'A opção poderá ser alterada antes da finalização da ficha.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12.5,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PerfilAtendimentoButton extends StatelessWidget {
  final String titulo;
  final String subtitulo;
  final IconData icone;
  final Color corIcone;
  final Color corFundoIcone;
  final VoidCallback onTap;

  const _PerfilAtendimentoButton({
    required this.titulo,
    required this.subtitulo,
    required this.icone,
    required this.corIcone,
    required this.corFundoIcone,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFECE6E0)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0A000000),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: corFundoIcone,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icone, color: corIcone, size: 26),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF3A0A04),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitulo,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: Color(0xFFFDF0F0),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_forward,
                  size: 18,
                  color: AppColors.darkRed,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
