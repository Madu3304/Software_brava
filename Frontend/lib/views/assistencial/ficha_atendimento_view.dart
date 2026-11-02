import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_routes.dart';
import '../../providers/ficha_provider.dart';
import '../../services/auth_service.dart';
import 'widgets/samu_app_bar_header.dart';
import 'widgets/unidade_tipo_card.dart';
import 'widgets/codigo_triagem_selector.dart';
import 'widgets/data_atendimento_card.dart';

class FichaAtendimentoView extends StatefulWidget {
  const FichaAtendimentoView({super.key});

  @override
  State<FichaAtendimentoView> createState() => _FichaAtendimentoViewState();
}

class _FichaAtendimentoViewState extends State<FichaAtendimentoView> {
  String _tipoViatura = 'USB';
  String _codigoTriagem = 'Vermelho';
  Set<String> _opcoesUsb = {};
  DateTime _dataAtendimento = DateTime.now();

  void _avancarParaRegistro() {
    context.read<FichaEmAndamentoProvider>().iniciarFicha(
          tipoViatura: _tipoViatura,
          codigoTriagem: _codigoTriagem,
          dataAtendimento: _dataAtendimento,
        );

    Navigator.pushNamed(
      context,
      AppRoutes.registroFicha,
    );
  }

  Future<void> _fazerLogout() async {
    await AuthService().logout();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (r) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      appBar: SamuAppBarHeader(
        title: "Ficha de Atendimento",
        showSamuLogo: false,
        showAmbulanceWatermark: false,
        onLogout: _fazerLogout,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 28.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Card 1: Tipo de Viatura (USB / USA)
                  UnidadeTipoCard(
                    tipoAtual: _tipoViatura,
                    opcoesSelecionadas: _opcoesUsb,
                    onOpcoesChanged: (opcoes) => setState(() => _opcoesUsb = opcoes),
                    onTipoChanged: (novoTipo) => setState(() => _tipoViatura = novoTipo),
                  ),
                  const SizedBox(height: 20),

                  // Card 2: Código de Triagem
                  CodigoTriagemSelector(
                    codigoSelecionado: _codigoTriagem,
                    onCodigoSelected: (novoCodigo) => setState(() => _codigoTriagem = novoCodigo),
                  ),
                  const SizedBox(height: 20),

                  // Card 3: Seletor de Data
                  DataAtendimentoCard(
                    dataInicial: _dataAtendimento,
                    onDateChanged: (novaData) => setState(() => _dataAtendimento = novaData),
                  ),
                  const SizedBox(height: 28),

                  // Botão de Ação: "Continuar"
                  SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _avancarParaRegistro,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.samuOrange,
                        foregroundColor: Colors.white,
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                      child: const Text(
                        "Continuar",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.4,
                        ),
                      ),
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
