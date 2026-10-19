// ============================================================================
// VIEW ASSISTENCIAL: CONFIRMAÇÃO DE IMPRESSÃO DA FICHA TÉCNICA
// Arquivo: lib/views/assistencial/impressao_sucesso_view.dart
// ============================================================================

import 'package:flutter/material.dart';

class ImpressaoSucessoView extends StatelessWidget {
  final String numeroOcorrencia;

  const ImpressaoSucessoView({
    super.key,
    this.numeroOcorrencia = '192-JOINVILLE',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text(
          "Comprovante de Impressão",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        backgroundColor: const Color(0xFFC62828),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 480),
          margin: const EdgeInsets.all(24.0),
          padding: const EdgeInsets.all(32.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFEEEEEE)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0A000000),
                blurRadius: 16,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 68,
                height: 68,
                decoration: const BoxDecoration(
                  color: Color(0xFFE8F5E9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_outline_rounded,
                  color: Color(0xFF2E7D32),
                  size: 40,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                "Ficha Impressa com Sucesso!",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E1E1E),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Ocorrência nº $numeroOcorrencia enviada para a impressora térmica.",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF757575),
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pushReplacementNamed(context, '/ficha'),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text("Voltar para Ficha de Atendimento"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC62828),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
