import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_routes.dart';
import '../../models/ficha_model.dart';
import '../../providers/ficha_provider.dart';
import '../../services/database_service.dart';
import 'widgets/samu_app_bar_header.dart';

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

  // Tópico 2: Sinais Vitais e Histórico
  final _paController = TextEditingController();
  final _fcController = TextEditingController();
  final _frController = TextEditingController();
  final _spo2Controller = TextEditingController();
  final _glicemiaController = TextEditingController();
  final _temperaturaController = TextEditingController();
  final _glasgowController = TextEditingController();
  final _queixaController = TextEditingController();
  final _alergiasController = TextEditingController();
  final _medicamentosController = TextEditingController();
  final _condutaController = TextEditingController();

  // Gestante (Tópicos 3 e 4)
  final _idadeGestacionalCtrl = TextEditingController();
  final _dumCtrl = TextEditingController();
  final _dppCtrl = TextEditingController();
  final _gpaCtrl = TextEditingController();
  final _unidadePreNatalCtrl = TextEditingController();
  final _tipoSanguineoCtrl = TextEditingController();
  final _frequenciaContracoesCtrl = TextEditingController();
  final _bcfCtrl = TextEditingController();
  bool _realizaPreNatal = true;
  bool _gestacaoAltoRisco = false;
  bool _sangramentoVaginal = false;
  bool _perdaLiquido = false;
  bool _contracoesUterinas = false;
  bool _movimentacaoFetal = true;
  bool _cefaleiaIntensa = false;
  bool _alteracaoVisual = false;
  bool _dorEpigastrica = false;
  bool _edemaSubito = false;
  bool _convulsoes = false;
  bool _periodoExpulsivo = false;
  bool _decubitoLateralEsquerdo = false;

  // Idoso (Tópicos 3 e 4)
  String _independenciaPrevia = 'Independente';
  bool _confusaoAguda = false;
  bool _demenciaPrevia = false;
  bool _ocorrenciaQueda = false;
  final _mecanismoQuedaCtrl = TextEditingController();
  bool _perdaConscienciaTrauma = false;
  bool _quedasRecorrentes = false;
  bool _usaAnticoagulante = false;
  final _polifarmaciaCtrl = TextEditingController();
  bool _adesaoMedicacao = true;
  bool _desnutricaoDesidratacao = false;
  bool _incontinenciaAguda = false;
  bool _sintomaAtipicoCardioResp = false;
  bool _moraSozinho = false;
  final _contatoCuidadorCtrl = TextEditingController();
  bool _sinaisVulnerabilidade = false;

  // Paciente comum (Protocolo AVC)
  bool _avcSuspeito = false;
  bool _assimetriaFacial = false;
  bool _quedaBraco = false;
  bool _falaAnormal = false;

  bool _isSaving = false;
  bool _inicializado = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_inicializado) return;
    _inicializado = true;

    final ficha = _obterFichaAtual();
    if (ficha?.alergias != null && _alergiasController.text.isEmpty) {
      _alergiasController.text = ficha!.alergias!;
    }
    if (ficha?.medicamentosUsoContinuo != null && _medicamentosController.text.isEmpty) {
      _medicamentosController.text = ficha!.medicamentosUsoContinuo!;
    }

    final condicoes = _obterCondicoesProvider();
    if (condicoes.contains('Sangramento vaginal')) _sangramentoVaginal = true;
    if (condicoes.contains('Perda de líquido')) _perdaLiquido = true;
    if (condicoes.contains('Contrações')) _contracoesUterinas = true;
    if (condicoes.contains('Movimentos fetais presentes')) _movimentacaoFetal = true;
    if (condicoes.contains('Risco de queda')) _ocorrenciaQueda = true;
    if (condicoes.contains('Alteração de consciência')) _confusaoAguda = true;
    if (condicoes.contains('Uso de anticoagulante')) _usaAnticoagulante = true;
  }

  @override
  void dispose() {
    for (final c in [
      _paController,
      _fcController,
      _frController,
      _spo2Controller,
      _glicemiaController,
      _temperaturaController,
      _glasgowController,
      _queixaController,
      _alergiasController,
      _medicamentosController,
      _condutaController,
      _idadeGestacionalCtrl,
      _dumCtrl,
      _dppCtrl,
      _gpaCtrl,
      _unidadePreNatalCtrl,
      _tipoSanguineoCtrl,
      _frequenciaContracoesCtrl,
      _bcfCtrl,
      _mecanismoQuedaCtrl,
      _polifarmaciaCtrl,
      _contatoCuidadorCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  FichaAtendimentoModel? _obterFichaAtual() {
    FichaAtendimentoModel? providerFicha;
    try {
      providerFicha = Provider.of<FichaEmAndamentoProvider>(context, listen: false).ficha;
    } catch (_) {
      providerFicha = null;
    }
    return widget.fichaParcial ??
        ModalRoute.of(context)?.settings.arguments as FichaAtendimentoModel? ??
        providerFicha;
  }

  String _obterPerfil(FichaAtendimentoModel? ficha) {
    try {
      return Provider.of<FichaEmAndamentoProvider>(context, listen: false).perfilAtendimento;
    } catch (_) {
      final tipo = (ficha?.tipoOcorrencia ?? '').toLowerCase();
      if (tipo.contains('gestante') || tipo.contains('obst')) return 'gestante';
      if (tipo.contains('idoso') || tipo.contains('geri')) return 'idoso';
      return 'comum';
    }
  }

  Set<String> _obterCondicoesProvider() {
    try {
      return Provider.of<FichaEmAndamentoProvider>(context, listen: false)
          .condicoesIdentificadas;
    } catch (_) {
      return const {};
    }
  }

  String? _validarPA(String? val) {
    if (val == null || val.trim().isEmpty) return null;
    final match = RegExp(r'^(\d{2,3})/(\d{2,3})$').firstMatch(val.trim());
    if (match == null) return 'Ex: 120/80';
    final s = int.tryParse(match.group(1)!) ?? 0;
    final d = int.tryParse(match.group(2)!) ?? 0;
    if (s < 40 || s > 260 || d < 20 || d > 160) return 'Faixa inválida';
    return null;
  }

  String? _validarIntFaixa(String? val, int min, int max, String msg) {
    if (val == null || val.trim().isEmpty) return null;
    final n = int.tryParse(val.trim());
    if (n == null || n < min || n > max) return msg;
    return null;
  }

  String? _validarTemperatura(String? val) {
    if (val == null || val.trim().isEmpty) return null;
    final n = double.tryParse(val.trim().replaceAll(',', '.'));
    if (n == null || n < 30.0 || n > 45.0) return '30.0 - 45.0 °C';
    return null;
  }

  String _montarResumoPerfil(String perfil) {
    final condicoes = _obterCondicoesProvider();
    final prefixoCondicoes =
        condicoes.isNotEmpty ? 'Condições: ${condicoes.join(", ")} | ' : '';

    if (perfil == 'gestante') {
      return '$prefixoCondicoes[GESTANTE] '
          '${_idadeGestacionalCtrl.text.trim().isNotEmpty ? "IG: ${_idadeGestacionalCtrl.text.trim()} sem | " : ""}'
          '${_gpaCtrl.text.trim().isNotEmpty ? "G/P/A: ${_gpaCtrl.text.trim()} | " : ""}'
          '${_dumCtrl.text.trim().isNotEmpty ? "DUM: ${_dumCtrl.text.trim()} | " : ""}'
          '${_dppCtrl.text.trim().isNotEmpty ? "DPP: ${_dppCtrl.text.trim()} | " : ""}'
          'Pré-natal: ${_realizaPreNatal ? "Sim" : "Não"} | '
          'Alto risco: ${_gestacaoAltoRisco ? "Sim" : "Não"} | '
          'Sangramento: ${_sangramentoVaginal ? "Sim" : "Não"} | '
          'Bolsa rota: ${_perdaLiquido ? "Sim" : "Não"} | '
          'Contrações: ${_contracoesUterinas ? "Sim" : "Não"} | '
          'Mov. fetal: ${_movimentacaoFetal ? "Presente" : "Ausente"} | '
          'Pré-eclâmpsia(cefaleia=${_cefaleiaIntensa ? "S" : "N"}, visual=${_alteracaoVisual ? "S" : "N"}, epig=${_dorEpigastrica ? "S" : "N"}, edema=${_edemaSubito ? "S" : "N"}, conv=${_convulsoes ? "S" : "N"}) | '
          'Expulsivo: ${_periodoExpulsivo ? "Sim" : "Não"}'
          '${_bcfCtrl.text.trim().isNotEmpty ? " | BCF: ${_bcfCtrl.text.trim()} bpm" : ""}'
          ' | Decúbito lateral esq: ${_decubitoLateralEsquerdo ? "Sim" : "Não"}';
    }

    if (perfil == 'idoso') {
      return '$prefixoCondicoes[IDOSO] '
          'Independência: $_independenciaPrevia | '
          'Delirium: ${_confusaoAguda ? "Sim" : "Não"} | '
          'Demência: ${_demenciaPrevia ? "Sim" : "Não"} | '
          'Queda: ${_ocorrenciaQueda ? "Sim (${_mecanismoQuedaCtrl.text.trim()})" : "Não"} | '
          'TCE/Perda consc: ${_perdaConscienciaTrauma ? "Sim" : "Não"} | '
          'Quedas rec: ${_quedasRecorrentes ? "Sim" : "Não"} | '
          'Anticoagulante: ${_usaAnticoagulante ? "Sim" : "Não"} | '
          'Adesão: ${_adesaoMedicacao ? "Sim" : "Não"} | '
          'Fragilidade: ${_desnutricaoDesidratacao ? "Sim" : "Não"} | '
          'Incontinência: ${_incontinenciaAguda ? "Sim" : "Não"} | '
          'Atípico: ${_sintomaAtipicoCardioResp ? "Sim" : "Não"} | '
          'Mora sozinho: ${_moraSozinho ? "Sim" : "Não"} | '
          'Vulnerabilidade: ${_sinaisVulnerabilidade ? "Sim" : "Não"}';
    }

    return '$prefixoCondicoes[PACIENTE COMUM] AVC suspeito: ${_avcSuspeito ? "Sim" : "Não"}';
  }

  Future<void> _avancarParaAssinatura() async {
    if (!_formKey.currentState!.validate()) return;

    final fichaBase = _obterFichaAtual();
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
    final perfil = _obterPerfil(fichaBase);
    final resumo = _montarResumoPerfil(perfil);
    final obsAnterior = (fichaBase.observacoes ?? '').trim();
    final obsFinal = obsAnterior.isNotEmpty ? '$obsAnterior | $resumo' : resumo;

    final fichaAtualizada = fichaBase.copyWith(
      pressaoArterial: _paController.text.trim().isNotEmpty ? _paController.text.trim() : null,
      frequenciaCardiaca: int.tryParse(_fcController.text.trim()),
      frequenciaRespiratoria: int.tryParse(_frController.text.trim()),
      saturacaoO2: int.tryParse(_spo2Controller.text.trim()),
      glicemia: int.tryParse(_glicemiaController.text.trim()),
      temperatura: double.tryParse(_temperaturaController.text.trim().replaceAll(',', '.')),
      escalaGlasgow: int.tryParse(_glasgowController.text.trim()),
      alergias: _alergiasController.text.trim().isNotEmpty
          ? _alergiasController.text.trim()
          : fichaBase.alergias,
      medicamentosUsoContinuo: _medicamentosController.text.trim().isNotEmpty
          ? _medicamentosController.text.trim()
          : fichaBase.medicamentosUsoContinuo,
      observacoes: obsFinal,
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
      await DatabaseService().inserirFicha(fichaAtualizada);

      if (!mounted) return;
      try {
        context.read<FichaEmAndamentoProvider>().setFicha(fichaAtualizada);
      } catch (_) {}

      setState(() => _isSaving = false);

      Navigator.pushNamed(
        context,
        AppRoutes.assinaturaPaciente,
        arguments: fichaAtualizada,
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Não foi possível salvar o atendimento localmente."),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ficha = _obterFichaAtual();
    final perfil = _obterPerfil(ficha);

    final pacienteNome =
        (ficha?.pacienteNome.isNotEmpty == true) ? ficha!.pacienteNome : 'Paciente em Atendimento';
    final pacienteIdade =
        ficha?.pacienteIdade != null ? '${ficha!.pacienteIdade} anos' : 'Idade não informada';
    final pacienteSexo = ficha?.pacienteSexo ?? '-';
    final acompanhante =
        (ficha?.acompanhante?.isNotEmpty == true) ? ficha!.acompanhante! : 'Sem acompanhante';
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
              constraints: const BoxConstraints(maxWidth: 680),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Card Resumo do Paciente
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.borderLight),
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
                          const SizedBox(height: 8),
                          Text(
                            "Acompanhante: $acompanhante",
                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Tópico 2: Sinais Vitais e Histórico
                    _buildCardSecao(
                      titulo: '2. Sinais Vitais e Histórico',
                      icone: Icons.monitor_heart_outlined,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _buildTextField(
                                _paController,
                                'PA (ex: 120/80)',
                                validator: _validarPA,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildTextField(
                                _fcController,
                                'FC (bpm)',
                                keyboardType: TextInputType.number,
                                validator: (v) => _validarIntFaixa(v, 20, 300, '20-300 bpm'),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildTextField(
                                _frController,
                                'FR (rpm)',
                                keyboardType: TextInputType.number,
                                validator: (v) => _validarIntFaixa(v, 5, 60, '5-60 rpm'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _buildTextField(
                                _spo2Controller,
                                'SpO₂ (%)',
                                keyboardType: TextInputType.number,
                                validator: (v) => _validarIntFaixa(v, 50, 100, '50-100%'),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildTextField(
                                _glicemiaController,
                                'Glicemia (mg/dL)',
                                keyboardType: TextInputType.number,
                                validator: (v) => _validarIntFaixa(v, 20, 800, '20-800 mg/dL'),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildTextField(
                                _temperaturaController,
                                'Temp (°C)',
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                validator: _validarTemperatura,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildTextField(
                                _glasgowController,
                                'Glasgow',
                                keyboardType: TextInputType.number,
                                validator: (v) => _validarIntFaixa(v, 3, 15, '3 a 15'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildTextField(_queixaController, 'Queixa principal', maxLines: 2),
                        const SizedBox(height: 12),
                        _buildTextField(_alergiasController, 'Alergias'),
                        const SizedBox(height: 12),
                        _buildTextField(_medicamentosController, 'Medicamentos em uso contínuo'),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Tópicos 3 e 4 personalizados conforme perfil escolhido
                    if (perfil == 'gestante')
                      ..._buildSecoesGestante()
                    else if (perfil == 'idoso')
                      ..._buildSecoesIdoso()
                    else
                      ..._buildSecoesComum(),
                    const SizedBox(height: 16),

                    // Conduta Clínica
                    _buildCardSecao(
                      titulo: 'Conduta Clínica',
                      icone: Icons.assignment_outlined,
                      children: [
                        _buildTextField(
                          _condutaController,
                          'Conduta e procedimentos realizados',
                          maxLines: 3,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    SizedBox(
                      height: 54,
                      child: ElevatedButton.icon(
                        onPressed: _isSaving ? null : _avancarParaAssinatura,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryRed,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        icon: _isSaving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Icon(Icons.draw_outlined),
                        label: Text(
                          _isSaving ? 'Salvando...' : 'Ir para Assinatura →',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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

  List<Widget> _buildSecoesGestante() {
    return [
      _buildCardSecao(
        titulo: '3. Dados Obstétricos e Pré-Natal',
        icone: Icons.pregnant_woman,
        children: [
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  _idadeGestacionalCtrl,
                  'Idade gestacional (semanas)',
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(child: _buildTextField(_gpaCtrl, 'G / P / A (ex: G2P1A0)')),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildTextField(_dumCtrl, 'DUM (dd/mm/aaaa)')),
              const SizedBox(width: 12),
              Expanded(child: _buildTextField(_dppCtrl, 'DPP (dd/mm/aaaa)')),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildTextField(_tipoSanguineoCtrl, 'Tipo sanguíneo / Rh')),
              const SizedBox(width: 12),
              Expanded(child: _buildTextField(_unidadePreNatalCtrl, 'Unidade pré-natal')),
            ],
          ),
          _buildSwitch('Realiza pré-natal?', _realizaPreNatal, (v) => _realizaPreNatal = v),
          _buildSwitch('Gestação de alto risco?', _gestacaoAltoRisco, (v) => _gestacaoAltoRisco = v),
        ],
      ),
      const SizedBox(height: 16),
      _buildCardSecao(
        titulo: '4. Sinais de Alerta, Pré-eclâmpsia e Parto',
        icone: Icons.warning_amber_rounded,
        children: [
          _buildSwitch('Sangramento vaginal?', _sangramentoVaginal, (v) => _sangramentoVaginal = v),
          _buildSwitch('Perda de líquido amniótico (bolsa rota)?', _perdaLiquido, (v) => _perdaLiquido = v),
          _buildSwitch('Contrações uterinas?', _contracoesUterinas, (v) => _contracoesUterinas = v),
          if (_contracoesUterinas) ...[
            const SizedBox(height: 8),
            _buildTextField(_frequenciaContracoesCtrl, 'Frequência / duração das contrações'),
          ],
          _buildSwitch('Movimentação fetal presente?', _movimentacaoFetal, (v) => _movimentacaoFetal = v),
          const Divider(),
          _buildSwitch('Cefaleia intensa?', _cefaleiaIntensa, (v) => _cefaleiaIntensa = v),
          _buildSwitch('Alteração visual / escotomas?', _alteracaoVisual, (v) => _alteracaoVisual = v),
          _buildSwitch('Dor epigástrica?', _dorEpigastrica, (v) => _dorEpigastrica = v),
          _buildSwitch('Edema súbito em face/mãos?', _edemaSubito, (v) => _edemaSubito = v),
          _buildSwitch('Convulsões (eclâmpsia)?', _convulsoes, (v) => _convulsoes = v),
          const Divider(),
          _buildSwitch('Dilatação / período expulsivo visível?', _periodoExpulsivo, (v) => _periodoExpulsivo = v),
          const SizedBox(height: 8),
          _buildTextField(_bcfCtrl, 'Batimentos Cardiofetais - BCF (bpm)', keyboardType: TextInputType.number),
          _buildSwitch('Transporte em decúbito lateral esquerdo?', _decubitoLateralEsquerdo, (v) => _decubitoLateralEsquerdo = v),
        ],
      ),
    ];
  }

  List<Widget> _buildSecoesIdoso() {
    return [
      _buildCardSecao(
        titulo: '3. Funcionalidade, Cognição e Quedas',
        icone: Icons.elderly,
        children: [
          DropdownButtonFormField<String>(
            initialValue: _independenciaPrevia,
            decoration: InputDecoration(
              labelText: 'Nível de independência prévia',
              filled: true,
              fillColor: AppColors.inputBg,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
            items: const ['Independente', 'Deambula com auxílio', 'Acamado']
                .map((e) => DropdownMenuItem<String>(value: e, child: Text(e)))
                .toList(),
            onChanged: (v) => setState(() => _independenciaPrevia = v!),
          ),
          _buildSwitch('Confusão mental aguda (delirium)?', _confusaoAguda, (v) => _confusaoAguda = v),
          _buildSwitch('Demência prévia diagnosticada?', _demenciaPrevia, (v) => _demenciaPrevia = v),
          const Divider(),
          _buildSwitch('Ocorrência de queda?', _ocorrenciaQueda, (v) => _ocorrenciaQueda = v),
          if (_ocorrenciaQueda) ...[
            const SizedBox(height: 8),
            _buildTextField(_mecanismoQuedaCtrl, 'Mecanismo / altura da queda'),
          ],
          _buildSwitch('Perda de consciência / trauma craniano?', _perdaConscienciaTrauma, (v) => _perdaConscienciaTrauma = v),
          _buildSwitch('Quedas recorrentes nos últimos meses?', _quedasRecorrentes, (v) => _quedasRecorrentes = v),
        ],
      ),
      const SizedBox(height: 16),
      _buildCardSecao(
        titulo: '4. Polifarmácia, Fragilidade e Rede de Apoio',
        icone: Icons.medication_outlined,
        children: [
          _buildSwitch('Usa anticoagulantes ou antiagregantes?', _usaAnticoagulante, (v) => _usaAnticoagulante = v),
          const SizedBox(height: 8),
          _buildTextField(
            _polifarmaciaCtrl,
            'Polifarmácia (anti-hipertensivos, hipoglicemiantes, psicotrópicos)',
            maxLines: 2,
          ),
          _buildSwitch('Adesão recente à medicação?', _adesaoMedicacao, (v) => _adesaoMedicacao = v),
          const Divider(),
          _buildSwitch('Perda de peso / desnutrição ou desidratação?', _desnutricaoDesidratacao, (v) => _desnutricaoDesidratacao = v),
          _buildSwitch('Incontinência urinária/fecal aguda?', _incontinenciaAguda, (v) => _incontinenciaAguda = v),
          _buildSwitch('Dor torácica atípica ou dispneia silenciosa?', _sintomaAtipicoCardioResp, (v) => _sintomaAtipicoCardioResp = v),
          const Divider(),
          _buildSwitch('Mora sozinho?', _moraSozinho, (v) => _moraSozinho = v),
          const SizedBox(height: 8),
          _buildTextField(_contatoCuidadorCtrl, 'Nome e contato do cuidador / responsável legal'),
          _buildSwitch('Sinais de vulnerabilidade, negligência ou maus-tratos?', _sinaisVulnerabilidade, (v) => _sinaisVulnerabilidade = v),
        ],
      ),
    ];
  }

  List<Widget> _buildSecoesComum() {
    return [
      _buildCardSecao(
        titulo: '3. Protocolo de AVC (Cincinnati)',
        icone: Icons.health_and_safety_outlined,
        children: [
          _buildSwitch('Assimetria facial?', _assimetriaFacial, (v) {
            _assimetriaFacial = v;
            _avcSuspeito = _assimetriaFacial || _quedaBraco || _falaAnormal;
          }),
          _buildSwitch('Queda de braço (fraqueza unilateral)?', _quedaBraco, (v) {
            _quedaBraco = v;
            _avcSuspeito = _assimetriaFacial || _quedaBraco || _falaAnormal;
          }),
          _buildSwitch('Fala anormal / disartria?', _falaAnormal, (v) {
            _falaAnormal = v;
            _avcSuspeito = _assimetriaFacial || _quedaBraco || _falaAnormal;
          }),
          _buildSwitch('Suspeita de AVC?', _avcSuspeito, (v) => _avcSuspeito = v),
        ],
      ),
    ];
  }

  Widget _buildCardSecao({
    required String titulo,
    required IconData icone,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(icone, color: AppColors.primaryRed, size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  titulo,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: AppColors.inputBg,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
    );
  }

  Widget _buildSwitch(String label, bool value, ValueChanged<bool> setter) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label, style: const TextStyle(fontSize: 14)),
      value: value,
      activeThumbColor: AppColors.primaryRed,
      onChanged: (v) => setState(() => setter(v)),
    );
  }
}
