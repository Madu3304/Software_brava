// ============================================================================
// VIEW ASSISTENCIAL: AVALIAÇÃO CLÍNICA, SINAIS VITAIS E CONDUTA
// Arquivo: lib/views/assistencial/avaliacao_clinica_view.dart
// ============================================================================

import 'package:flutter/material.dart';
import '../../models/ficha_model.dart';
import '../../services/database_service.dart';
import '../../services/sync_service.dart';
import 'widgets/samu_app_bar_header.dart';
import 'widgets/registro_field_card.dart';

class AvaliacaoClinicaView extends StatefulWidget {
  final FichaAtendimentoModel? fichaParcial;

  const AvaliacaoClinicaView({
    super.key,
    this.fichaParcial,
  });

  @override
  State<AvaliacaoClinicaView> createState() => _AvaliacaoClinicaViewState();
}

class _AvaliacaoClinicaViewState extends State<AvaliacaoClinicaView> {
  final _formKey = GlobalKey<FormState>();

  // Controladores: Sinais Vitais
  final TextEditingController _paController = TextEditingController(text: '120/80');
  final TextEditingController _fcController = TextEditingController(text: '78');
  final TextEditingController _frController = TextEditingController(text: '16');
  final TextEditingController _spo2Controller = TextEditingController(text: '98');
  final TextEditingController _glicemiaController = TextEditingController(text: '96');
  final TextEditingController _temperaturaController = TextEditingController(text: '36.5');
  final TextEditingController _glasgowController = TextEditingController(text: '15');

  // Controladores: Queixa e Conduta
  final TextEditingController _queixaController = TextEditingController();
  final TextEditingController _condutaController = TextEditingController();

  bool _isSaving = false;

  @override
  void dispose() {
    _paController.dispose();
    _fcController.dispose();
    _frController.dispose();
    _spo2Controller.dispose();
    _glicemiaController.dispose();
    _temperaturaController.dispose();
    _glasgowController.dispose();
    _queixaController.dispose();
    _condutaController.dispose();
    super.dispose();
  }

  Future<void> _finalizarAtendimento() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSaving = true);

      final condutaCompleta = [
        "Sinais Vitais: PA: ${_paController.text.trim()} mmHg | FC: ${_fcController.text.trim()} bpm | FR: ${_frController.text.trim()} rpm | SpO2: ${_spo2Controller.text.trim()}% | HGT: ${_glicemiaController.text.trim()} mg/dL | Temp: ${_temperaturaController.text.trim()}°C | Glasgow: ${_glasgowController.text.trim()}",
        if (_condutaController.text.trim().isNotEmpty)
          "Conduta: ${_condutaController.text.trim()}"
      ].join('\n');

      final fichaFinal = (widget.fichaParcial ??
              FichaAtendimentoModel(
                id: 'fch_${DateTime.now().millisecondsSinceEpoch}',
                numeroOcorrencia:
                    'REG-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
                dataHora: DateTime.now(),
                pacienteNome: 'Paciente',
                tipoOcorrencia: 'Atendimento Pré-Hospitalar',
                endereco: 'Joinville - SC',
                unidadeResponsavel: 'USB',
              ))
          .copyWith(
        queixaPrincipal: _queixaController.text.trim().isNotEmpty
            ? _queixaController.text.trim()
            : 'Atendimento APH de emergência',
        condutaMedica: condutaCompleta,
      );

      // Persiste no SQLite local
      await DatabaseService().inserirFicha(fichaFinal);

      // Enfileira e sincroniza com o backend FastAPI (offline-first)
      SyncService().enfileirarFicha(fichaFinal);
      SyncService().sincronizarFichasPendentes();

      if (!mounted) return;
      setState(() => _isSaving = false);

      Navigator.pushReplacementNamed(
        context,
        '/impressao-sucesso',
        arguments: fichaFinal.numeroOcorrencia,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final pacienteNome = widget.fichaParcial?.pacienteNome ?? 'Não informado';
    final pacienteIdade = widget.fichaParcial?.pacienteIdade != null
        ? '${widget.fichaParcial!.pacienteIdade} anos'
        : 'Idade não inf.';
    final pacienteSexo = widget.fichaParcial?.pacienteSexo ?? '-';
    final acompanhante = widget.fichaParcial?.acompanhante ?? 'Desconhecido';
    final ocorrencia = widget.fichaParcial?.numeroOcorrencia ?? '-';

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FB),
      appBar: SamuAppBarHeader(
        title: "Avaliação Clínica",
        showSamuLogo: true,
        showAmbulanceWatermark: true,
        onBack: () => Navigator.pop(context),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Card Resumo do Paciente & Acompanhante
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFEBEE),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.person_rounded,
                                    color: Color(0xFFC62828), size: 20),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      pacienteNome,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF212121),
                                      ),
                                    ),
                                    Text(
                                      "Ocorrência: $ocorrencia | $pacienteIdade | $pacienteSexo",
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF757575),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 20, color: Color(0xFFEEEEEE)),
                          Row(
                            children: [
                              const Icon(Icons.people_outline_rounded,
                                  size: 16, color: Color(0xFFC62828)),
                              const SizedBox(width: 6),
                              Text(
                                "Acompanhante: $acompanhante",
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF424242),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ========================================================
                    // SEÇÃO: SINAIS VITAIS
                    // ========================================================
                    const Row(
                      children: [
                        Icon(Icons.monitor_heart_rounded,
                            color: Color(0xFFC62828), size: 22),
                        SizedBox(width: 8),
                        Text(
                          "Sinais Vitais",
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF212121),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Grid de Sinais Vitais: PA e FC
                    Row(
                      children: [
                        Expanded(
                          child: RegistroFieldCard(
                            title: "Pressão (PA)",
                            child: TextFormField(
                              controller: _paController,
                              style: const TextStyle(fontSize: 14),
                              decoration: _inputDecoration("120/80 mmHg"),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: RegistroFieldCard(
                            title: "Freq. Cardíaca (FC)",
                            child: TextFormField(
                              controller: _fcController,
                              keyboardType: TextInputType.number,
                              style: const TextStyle(fontSize: 14),
                              decoration: _inputDecoration("78 bpm"),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // SpO2 e FR
                    Row(
                      children: [
                        Expanded(
                          child: RegistroFieldCard(
                            title: "Saturação O2 (SpO2)",
                            child: TextFormField(
                              controller: _spo2Controller,
                              keyboardType: TextInputType.number,
                              style: const TextStyle(fontSize: 14),
                              decoration: _inputDecoration("98 %"),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: RegistroFieldCard(
                            title: "Freq. Resp. (FR)",
                            child: TextFormField(
                              controller: _frController,
                              keyboardType: TextInputType.number,
                              style: const TextStyle(fontSize: 14),
                              decoration: _inputDecoration("16 rpm"),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Glicemia, Temperatura e Glasgow
                    Row(
                      children: [
                        Expanded(
                          child: RegistroFieldCard(
                            title: "Glicemia (HGT)",
                            child: TextFormField(
                              controller: _glicemiaController,
                              keyboardType: TextInputType.number,
                              style: const TextStyle(fontSize: 14),
                              decoration: _inputDecoration("96 mg/dL"),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: RegistroFieldCard(
                            title: "Temperatura",
                            child: TextFormField(
                              controller: _temperaturaController,
                              keyboardType: TextInputType.number,
                              style: const TextStyle(fontSize: 14),
                              decoration: _inputDecoration("36.5 °C"),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: RegistroFieldCard(
                            title: "Glasgow (3-15)",
                            child: TextFormField(
                              controller: _glasgowController,
                              keyboardType: TextInputType.number,
                              style: const TextStyle(fontSize: 14),
                              decoration: _inputDecoration("15"),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // ========================================================
                    // SEÇÃO: QUEIXA E CONDUTA
                    // ========================================================
                    RegistroFieldCard(
                      title: "Queixa Principal / Hipótese Diagnóstica",
                      icon: Icons.assignment_outlined,
                      iconColor: const Color(0xFFC62828),
                      child: TextFormField(
                        controller: _queixaController,
                        maxLines: 3,
                        style: const TextStyle(fontSize: 14),
                        decoration: InputDecoration(
                          hintText: "Descreva os sintomas, queixa ou histórico recente...",
                          hintStyle: const TextStyle(color: Color(0xFF9E9E9E), fontSize: 13),
                          contentPadding: const EdgeInsets.all(14),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide:
                                const BorderSide(color: Color(0xFFE0E0E0), width: 1.2),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide:
                                const BorderSide(color: Color(0xFFC62828), width: 1.8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    RegistroFieldCard(
                      title: "Conduta e Procedimentos Realizados",
                      icon: Icons.medical_services_outlined,
                      iconColor: const Color(0xFFC62828),
                      child: TextFormField(
                        controller: _condutaController,
                        maxLines: 3,
                        style: const TextStyle(fontSize: 14),
                        decoration: InputDecoration(
                          hintText:
                              "Medicações, imobilização, oxigenoterapia, destino hospitalar...",
                          hintStyle: const TextStyle(color: Color(0xFF9E9E9E), fontSize: 13),
                          contentPadding: const EdgeInsets.all(14),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide:
                                const BorderSide(color: Color(0xFFE0E0E0), width: 1.2),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide:
                                const BorderSide(color: Color(0xFFC62828), width: 1.8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Botão Finalizar e Imprimir
                    SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _finalizarAtendimento,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFC62828),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          elevation: 2,
                        ),
                        child: _isSaving
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2),
                              )
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.check_circle_outline_rounded,
                                      color: Colors.white, size: 22),
                                  SizedBox(width: 8),
                                  Flexible(
                                    child: Text(
                                      "Finalizar Atendimento e Imprimir",
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        letterSpacing: 0.3,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Opção de Voltar
                    Center(
                      child: TextButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back,
                            size: 16, color: Color(0xFF757575)),
                        label: const Text(
                          "Voltar aos Dados do Paciente",
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF757575),
                            fontWeight: FontWeight.w600,
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
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF9E9E9E), fontSize: 13),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 1.2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: const BorderSide(color: Color(0xFFC62828), width: 1.8),
      ),
    );
  }
}
