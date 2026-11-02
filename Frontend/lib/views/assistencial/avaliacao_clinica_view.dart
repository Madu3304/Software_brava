import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_routes.dart';
import '../../models/ficha_model.dart';
import '../../providers/ficha_provider.dart';
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
  final TextEditingController _paController = TextEditingController();
  final TextEditingController _fcController = TextEditingController();
  final TextEditingController _frController = TextEditingController();
  final TextEditingController _spo2Controller = TextEditingController();
  final TextEditingController _glicemiaController = TextEditingController();
  final TextEditingController _temperaturaController = TextEditingController();
  final TextEditingController _glasgowController = TextEditingController();

  bool _avcSuspeito = false;
  bool _assimetriaFacial = false;
  bool _quedaBraco = false;
  bool _falaAnormal = false;

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

  String? _validarPA(String? val) {
    if (val == null || val.trim().isEmpty) return null;
    final regex = RegExp(r'^(\d{2,3})/(\d{2,3})$');
    final match = regex.firstMatch(val.trim());
    if (match == null) return 'Ex: 120/80';
    final sistolica = int.tryParse(match.group(1)!) ?? 0;
    final diastolica = int.tryParse(match.group(2)!) ?? 0;
    if (sistolica < 40 || sistolica > 260 || diastolica < 20 || diastolica > 160) {
      return 'Fora da faixa (50-250 / 30-150)';
    }
    return null;
  }

  String? _validarFC(String? val) {
    if (val == null || val.trim().isEmpty) return null;
    final n = int.tryParse(val.trim());
    if (n == null || n < 20 || n > 300) return 'Faixa: 20-300 bpm';
    return null;
  }

  String? _validarFR(String? val) {
    if (val == null || val.trim().isEmpty) return null;
    final n = int.tryParse(val.trim());
    if (n == null || n < 5 || n > 60) return 'Faixa: 5-60 rpm';
    return null;
  }

  String? _validarSpO2(String? val) {
    if (val == null || val.trim().isEmpty) return null;
    final n = int.tryParse(val.trim());
    if (n == null || n < 50 || n > 100) return 'Faixa: 50-100%';
    return null;
  }

  String? _validarGlicemia(String? val) {
    if (val == null || val.trim().isEmpty) return null;
    final n = int.tryParse(val.trim());
    if (n == null || n < 20 || n > 800) return 'Faixa: 20-800 mg/dL';
    return null;
  }

  String? _validarTemperatura(String? val) {
    if (val == null || val.trim().isEmpty) return null;
    final n = double.tryParse(val.trim().replaceAll(',', '.'));
    if (n == null || n < 30.0 || n > 45.0) return 'Faixa: 30.0 - 45.0 °C';
    return null;
  }

  String? _validarGlasgow(String? val) {
    if (val == null || val.trim().isEmpty) return null;
    final n = int.tryParse(val.trim());
    if (n == null || n < 3 || n > 15) return 'Escala: 3 a 15';
    return null;
  }

  Future<void> _finalizarAtendimento() async {
    if (!_formKey.currentState!.validate()) return;

    FichaAtendimentoModel? fichaBase = widget.fichaParcial ??
        ModalRoute.of(context)?.settings.arguments as FichaAtendimentoModel? ??
        context.read<FichaEmAndamentoProvider>().ficha;

    if (fichaBase == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Nenhuma ocorrência em andamento. Inicie o atendimento pela Ficha."),
          backgroundColor: AppColors.error,
        ),
      );
      Navigator.pushReplacementNamed(context, AppRoutes.ficha);
      return;
    }

    setState(() => _isSaving = true);

    final fichaFinal = fichaBase.copyWith(
      pressaoArterial: _paController.text.trim().isNotEmpty ? _paController.text.trim() : null,
      frequenciaCardiaca: int.tryParse(_fcController.text.trim()),
      frequenciaRespiratoria: int.tryParse(_frController.text.trim()),
      saturacaoO2: int.tryParse(_spo2Controller.text.trim()),
      glicemia: int.tryParse(_glicemiaController.text.trim()),
      temperatura: double.tryParse(_temperaturaController.text.trim().replaceAll(',', '.')),
      escalaGlasgow: int.tryParse(_glasgowController.text.trim()),
      avcSuspeito: _avcSuspeito,
      assimetriaFacial: _assimetriaFacial,
      quedaBraco: _quedaBraco,
      falaAnormal: _falaAnormal,
      queixaPrincipal: _queixaController.text.trim().isNotEmpty
          ? _queixaController.text.trim()
          : 'Atendimento APH de emergência',
      condutaMedica: _condutaController.text.trim().isNotEmpty
          ? _condutaController.text.trim()
          : 'Protocolo de suporte pré-hospitalar realizado conforme regulação.',
    );

    try {
      await DatabaseService().inserirFicha(fichaFinal);

      if (!mounted) return;
      context.read<FichaEmAndamentoProvider>().setFicha(fichaFinal);

      SyncService().sincronizarFichasPendentes();

      setState(() => _isSaving = false);

      Navigator.pushReplacementNamed(
        context,
        AppRoutes.impressaoSucesso,
        arguments: fichaFinal.numeroOcorrencia,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Não foi possível salvar o atendimento localmente. Verifique o espaço do dispositivo e tente novamente."),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final FichaAtendimentoModel? ficha = widget.fichaParcial ??
        ModalRoute.of(context)?.settings.arguments as FichaAtendimentoModel? ??
        context.watch<FichaEmAndamentoProvider>().ficha;

    final pacienteNome = (ficha?.pacienteNome.isNotEmpty == true) ? ficha!.pacienteNome : 'Paciente em Atendimento';
    final pacienteIdade = ficha?.pacienteIdade != null ? '${ficha!.pacienteIdade} anos' : 'Idade não informada';
    final pacienteSexo = ficha?.pacienteSexo ?? '-';
    final acompanhante = (ficha?.acompanhante?.isNotEmpty == true) ? ficha!.acompanhante! : 'Sem acompanhante';
    final ocorrencia = ficha?.numeroOcorrencia ?? '-';

    return Scaffold(
      backgroundColor: AppColors.pageBackground,
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
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.borderLight),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x0A000000),
                            blurRadius: 8,
                            offset: Offset(0, 3),
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
                                  color: AppColors.badgeRed,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.person_rounded, color: AppColors.crimson, size: 20),
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
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    Text(
                                      "Ocorrência: $ocorrencia | $pacienteIdade | $pacienteSexo",
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 20, color: AppColors.borderLight),
                          Row(
                            children: [
                              const Icon(Icons.people_outline_rounded, size: 16, color: AppColors.crimson),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  "Acompanhante: $acompanhante",
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textDark,
                                  ),
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
                        Icon(Icons.monitor_heart_rounded, color: AppColors.crimson, size: 22),
                        SizedBox(width: 8),
                        Text(
                          "Sinais Vitais",
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
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
                              validator: _validarPA,
                              style: const TextStyle(fontSize: 14),
                              decoration: _inputDecoration("Ex: 120/80 mmHg"),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: RegistroFieldCard(
                            title: "Freq. Cardíaca (FC)",
                            child: TextFormField(
                              controller: _fcController,
                              validator: _validarFC,
                              keyboardType: TextInputType.number,
                              style: const TextStyle(fontSize: 14),
                              decoration: _inputDecoration("Ex: 78 bpm"),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: RegistroFieldCard(
                            title: "Saturação O2 (SpO2)",
                            child: TextFormField(
                              controller: _spo2Controller,
                              validator: _validarSpO2,
                              keyboardType: TextInputType.number,
                              style: const TextStyle(fontSize: 14),
                              decoration: _inputDecoration("Ex: 98 %"),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: RegistroFieldCard(
                            title: "Freq. Resp. (FR)",
                            child: TextFormField(
                              controller: _frController,
                              validator: _validarFR,
                              keyboardType: TextInputType.number,
                              style: const TextStyle(fontSize: 14),
                              decoration: _inputDecoration("Ex: 16 rpm"),
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
                              validator: _validarGlicemia,
                              keyboardType: TextInputType.number,
                              style: const TextStyle(fontSize: 14),
                              decoration: _inputDecoration("Ex: 96 mg/dL"),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: RegistroFieldCard(
                            title: "Temperatura",
                            child: TextFormField(
                              controller: _temperaturaController,
                              validator: _validarTemperatura,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              style: const TextStyle(fontSize: 14),
                              decoration: _inputDecoration("Ex: 36.5 °C"),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: RegistroFieldCard(
                            title: "Glasgow (3-15)",
                            child: TextFormField(
                              controller: _glasgowController,
                              validator: _validarGlasgow,
                              keyboardType: TextInputType.number,
                              style: const TextStyle(fontSize: 14),
                              decoration: _inputDecoration("Ex: 15"),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.borderLight),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.psychology_outlined, color: AppColors.crimson, size: 20),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  "Escala de Cincinnati (Suspeita de AVC)",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          CheckboxListTile(
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            title: const Text("Assimetria Facial (Sorriso caído)", style: TextStyle(fontSize: 13)),
                            value: _assimetriaFacial,
                            activeColor: AppColors.crimson,
                            onChanged: (val) {
                              setState(() {
                                _assimetriaFacial = val ?? false;
                                _avcSuspeito = _assimetriaFacial || _quedaBraco || _falaAnormal;
                              });
                            },
                          ),
                          CheckboxListTile(
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            title: const Text("Queda de Braço (Fraqueza unilateral)", style: TextStyle(fontSize: 13)),
                            value: _quedaBraco,
                            activeColor: AppColors.crimson,
                            onChanged: (val) {
                              setState(() {
                                _quedaBraco = val ?? false;
                                _avcSuspeito = _assimetriaFacial || _quedaBraco || _falaAnormal;
                              });
                            },
                          ),
                          CheckboxListTile(
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            title: const Text("Fala Anormal ou Dificuldade de Dicção", style: TextStyle(fontSize: 13)),
                            value: _falaAnormal,
                            activeColor: AppColors.crimson,
                            onChanged: (val) {
                              setState(() {
                                _falaAnormal = val ?? false;
                                _avcSuspeito = _assimetriaFacial || _quedaBraco || _falaAnormal;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    RegistroFieldCard(
                      title: "Queixa Principal / Hipótese Diagnóstica",
                      icon: Icons.assignment_outlined,
                      iconColor: AppColors.crimson,
                      child: TextFormField(
                        controller: _queixaController,
                        maxLines: 3,
                        style: const TextStyle(fontSize: 14),
                        decoration: InputDecoration(
                          hintText: "Descreva os sintomas, queixa ou histórico recente...",
                          hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                          contentPadding: const EdgeInsets.all(14),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: const BorderSide(color: AppColors.borderNeutral, width: 1.2),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: const BorderSide(color: AppColors.crimson, width: 1.8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    RegistroFieldCard(
                      title: "Conduta e Procedimentos Realizados",
                      icon: Icons.medical_services_outlined,
                      iconColor: AppColors.crimson,
                      child: TextFormField(
                        controller: _condutaController,
                        maxLines: 3,
                        style: const TextStyle(fontSize: 14),
                        decoration: InputDecoration(
                          hintText: "Medicações administradas, imobilização, oxigenoterapia, destino hospitalar...",
                          hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                          contentPadding: const EdgeInsets.all(14),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: const BorderSide(color: AppColors.borderNeutral, width: 1.2),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: const BorderSide(color: AppColors.crimson, width: 1.8),
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
                          backgroundColor: AppColors.crimson,
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
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.check_circle_outline_rounded, color: Colors.white, size: 22),
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
                        icon: const Icon(Icons.arrow_back, size: 16, color: AppColors.textSecondary),
                        label: const Text(
                          "Voltar aos Dados do Paciente",
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
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
      hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: const BorderSide(color: AppColors.borderNeutral, width: 1.2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: const BorderSide(color: AppColors.crimson, width: 1.8),
      ),
    );
  }
}
