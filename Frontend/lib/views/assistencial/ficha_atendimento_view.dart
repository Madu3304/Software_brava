import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_routes.dart';
import '../../providers/ficha_provider.dart';
import '../../services/auth_service.dart';
import 'widgets/samu_app_bar_header.dart';
import 'widgets/perfil_ficha_header_card.dart';
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
  bool _unidadeParada = false;
  final TextEditingController _motivoParadaController = TextEditingController();

  @override
  void dispose() {
    _motivoParadaController.dispose();
    super.dispose();
  }

  void _avancarParaRegistro() {
    if (_unidadeParada && _motivoParadaController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Informe o motivo da parada da unidade móvel (RF11)."),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    context.read<FichaEmAndamentoProvider>().iniciarFicha(
          tipoViatura: _tipoViatura,
          codigoTriagem: _codigoTriagem,
          dataAtendimento: _dataAtendimento,
          unidadeParada: _unidadeParada,
          motivoUnidadeParada: _unidadeParada ? _motivoParadaController.text.trim() : null,
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
                  // Quadro do perfil escolhido (Gestante / Idoso / Paciente comum)
                  const PerfilFichaHeaderCard(),
                  const SizedBox(height: 20),

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
                  const SizedBox(height: 20),

                  // Card 4: Unidade Parada (RF11)
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14.0),
                      border: Border.all(
                        color: _unidadeParada ? AppColors.warning : AppColors.borderLight,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Unidade Parada?",
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    "Informe caso a viatura esteja impossibilitada de operar",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Switch(
                              value: _unidadeParada,
                              activeColor: AppColors.crimson,
                              onChanged: (val) => setState(() => _unidadeParada = val),
                            ),
                          ],
                        ),
                        if (_unidadeParada) ...[
                          const SizedBox(height: 12),
                          TextField(
                            controller: _motivoParadaController,
                            maxLines: 2,
                            decoration: InputDecoration(
                              hintText: "Descreva o motivo da parada (ex: manutenção mecânica, falta de equipe...)",
                              hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF9E9E9E)),
                              filled: true,
                              fillColor: const Color(0xFFFAFAFA),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: const BorderSide(color: AppColors.borderLight),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
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
