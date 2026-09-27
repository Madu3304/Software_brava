// ============================================================================
// VIEW ASSISTENCIAL: FICHA DE ATENDIMENTO - ETAPA 1 (FIGMA IMAGEM 1)
// Arquivo: lib/views/assistencial/ficha_atendimento_view.dart
// ============================================================================

import 'package:flutter/material.dart';
import '../../core/constants/app_routes.dart';
import 'widgets/samu_app_bar_header.dart';
import 'widgets/unidade_tipo_card.dart';
import 'widgets/codigo_triagem_selector.dart';
import 'registro_atendimento_view.dart';

class FichaAtendimentoView extends StatefulWidget {
  const FichaAtendimentoView({super.key});

  @override
  State<FichaAtendimentoView> createState() => _FichaAtendimentoViewState();
}

class _FichaAtendimentoViewState extends State<FichaAtendimentoView> {
  String _tipoViatura = 'USB';
  String _codigoTriagem = 'Vermelho';

  void _avancarParaRegistro() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RegistroAtendimentoView(
          tipoViaturaInicial: _tipoViatura,
          codigoTriagemInicial: _codigoTriagem,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FB),
      appBar: SamuAppBarHeader(
        title: "Ficha de Atendimento",
        showSamuLogo: false,
        showAmbulanceWatermark: false,
        onLogout: () => Navigator.pushReplacementNamed(context, AppRoutes.login),
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
                  // Card 1: Botão/Identificador da Viatura (USB) conforme Figma Imagem 1
                  UnidadeTipoCard(
                    tipoAtual: _tipoViatura,
                    onTipoChanged: (novoTipo) {
                      setState(() {
                        _tipoViatura = novoTipo;
                      });
                    },
                  ),
                  const SizedBox(height: 20),

                  // Card 2: Seletor de Código de Triagem (Vermelho, Amarelo, Verde, Azul) conforme Figma Imagem 1
                  CodigoTriagemSelector(
                    codigoSelecionado: _codigoTriagem,
                    onCodigoSelected: (novoCodigo) {
                      setState(() {
                        _codigoTriagem = novoCodigo;
                      });
                    },
                  ),
                  const SizedBox(height: 28),

                  // Botão de Ação: "Continuar" (Laranja idêntico ao Figma Imagem 1)
                  SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _avancarParaRegistro,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF4800), // Laranja vibrante do Figma
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

                  const SizedBox(height: 24),
                  // Link discreto para retornar ao Dashboard ou Login
                  Center(
                    child: TextButton.icon(
                      onPressed: () => Navigator.pushReplacementNamed(context, AppRoutes.dashboard),
                      icon: const Icon(Icons.dashboard_outlined, size: 16, color: Color(0xFF757575)),
                      label: const Text(
                        "Acessar Painel Web Administrativo",
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF757575),
                          fontWeight: FontWeight.w500,
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
