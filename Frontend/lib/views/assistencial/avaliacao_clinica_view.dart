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
  final _frequenciaContracoesMinCtrl = TextEditingController();
  final _duracaoContracoesSegCtrl = TextEditingController();
  final _bcfCtrl = TextEditingController();
  final _horaNascimentoCtrl = TextEditingController();
  final _apgar1Ctrl = TextEditingController();
  final _apgar5Ctrl = TextEditingController();
  bool _realizaPreNatal = true;
  bool _possuiCartaoGestante = false;
  bool _gestacaoAltoRisco = false;
  bool _sangramentoVaginal = false;
  String _quantidadeSangramento = 'Leve';
  bool _presencaCoagulos = false;
  bool _perdaLiquido = false;
  String _aspectoLiquido = 'Claro';
  bool _contracoesUterinas = false;
  bool _movimentacaoFetal = true;
  bool _cefaleiaIntensa = false;
  bool _alteracaoVisual = false;
  bool _dorEpigastrica = false;
  bool _edemaSubito = false;
  bool _convulsoes = false;
  bool _periodoExpulsivo = false;
  bool _bcfNaoAvaliado = false;
  bool _decubitoLateralEsquerdo = false;
  bool _partoRealizadoAph = false;
  bool _rnChoroForte = false;
  bool _rnRespiracaoEspontanea = false;
  bool _rnTonusAdequado = false;
  bool _clampeamentoCordao = false;
  String _dequitacaoPlacenta = 'Completa';

  // Idoso (Tópicos 3 e 4)
  String _independenciaPrevia = 'Deambula';
  final _idadeEstimadaIdosoCtrl = TextEditingController();
  final _horarioInicioSintomasAvcCtrl = TextEditingController();
  bool _estadoMentalAlteradoBasal = false;
  bool _confusaoAguda = false;
  bool _demenciaPrevia = false;
  bool _ocorrenciaQueda = false;
  final _mecanismoQuedaCtrl = TextEditingController();
  bool _dorDeformidadeQuadrilMembros = false;
  bool _perdaConscienciaTrauma = false;
  bool _quedasRecorrentes = false;
  bool _usaAnticoagulante = false;
  final _polifarmaciaCtrl = TextEditingController();
  bool _adesaoMedicacao = true;
  bool _desnutricaoDesidratacao = false;
  bool _incontinenciaAguda = false;
  bool _dispneiaDesconforto = false;
  bool _dorToracicaMalEstar = false;
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
      _frequenciaContracoesMinCtrl,
      _duracaoContracoesSegCtrl,
      _bcfCtrl,
      _horaNascimentoCtrl,
      _apgar1Ctrl,
      _apgar5Ctrl,
      _idadeEstimadaIdosoCtrl,
      _horarioInicioSintomasAvcCtrl,
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
          'Cartão da Gestante: ${_possuiCartaoGestante ? "Sim" : "Não"} | '
          'Alto risco: ${_gestacaoAltoRisco ? "Sim" : "Não"} | '
          'Sangramento: ${_sangramentoVaginal ? "Sim ($_quantidadeSangramento, coágulos=${_presencaCoagulos ? "S" : "N"})" : "Não"} | '
          'Bolsa rota: ${_perdaLiquido ? "Sim (aspecto=$_aspectoLiquido)" : "Não"} | '
          'Contrações: ${_contracoesUterinas ? "Sim (freq=${_frequenciaContracoesMinCtrl.text.trim()} min, dur=${_duracaoContracoesSegCtrl.text.trim()} s)" : "Não"} | '
          'Mov. fetal: ${_movimentacaoFetal ? "Presente" : "Ausente"} | '
          'Pré-eclâmpsia(cefaleia=${_cefaleiaIntensa ? "S" : "N"}, visual=${_alteracaoVisual ? "S" : "N"}, epig=${_dorEpigastrica ? "S" : "N"}, edema=${_edemaSubito ? "S" : "N"}, conv=${_convulsoes ? "S" : "N"}) | '
          'Coroamento/Parto iminente: ${_periodoExpulsivo ? "Sim" : "Não"}'
          '${_bcfNaoAvaliado ? " | BCF: Não avaliado/Indisponível" : (_bcfCtrl.text.trim().isNotEmpty ? " | BCF: ${_bcfCtrl.text.trim()} bpm" : "")}'
          ' | Decúbito lateral esq: ${_decubitoLateralEsquerdo ? "Sim" : "Não"}'
          '${_partoRealizadoAph ? " | Parto APH: Sim (hora=${_horaNascimentoCtrl.text.trim()}, choro=${_rnChoroForte ? "S" : "N"}, resp=${_rnRespiracaoEspontanea ? "S" : "N"}, tonus=${_rnTonusAdequado ? "S" : "N"}, Apgar1=${_apgar1Ctrl.text.trim()}, Apgar5=${_apgar5Ctrl.text.trim()}, cordão=${_clampeamentoCordao ? "S" : "N"}, placenta=$_dequitacaoPlacenta)" : ""}';
    }

    if (perfil == 'idoso') {
      return '$prefixoCondicoes[IDOSO] '
          '${_idadeEstimadaIdosoCtrl.text.trim().isNotEmpty ? "Idade estimada: ${_idadeEstimadaIdosoCtrl.text.trim()} anos | " : ""}'
          'Mobilidade prévia: $_independenciaPrevia | '
          'Estado mental alterado vs basal: ${_estadoMentalAlteradoBasal ? "Sim" : "Não"} | '
          'Delirium: ${_confusaoAguda ? "Sim" : "Não"} | '
          'Demência: ${_demenciaPrevia ? "Sim" : "Não"} | '
          'AVC suspeito: ${_avcSuspeito ? "Sim" : "Não"}'
          '${_horarioInicioSintomasAvcCtrl.text.trim().isNotEmpty ? " (início sintomas/última vez bem: ${_horarioInicioSintomasAvcCtrl.text.trim()})" : ""} | '
          'Queda/trauma: ${_ocorrenciaQueda ? "Sim (${_mecanismoQuedaCtrl.text.trim()})" : "Não"} | '
          'Dor/deformidade quadril/membros: ${_dorDeformidadeQuadrilMembros ? "Sim" : "Não"} | '
          'TCE/Perda consc: ${_perdaConscienciaTrauma ? "Sim" : "Não"} | '
          'Quedas rec: ${_quedasRecorrentes ? "Sim" : "Não"} | '
          'Anticoagulante: ${_usaAnticoagulante ? "Sim" : "Não"} | '
          'Adesão: ${_adesaoMedicacao ? "Sim" : "Não"} | '
          'Fragilidade: ${_desnutricaoDesidratacao ? "Sim" : "Não"} | '
          'Incontinência/sepse atípica: ${_incontinenciaAguda ? "Sim" : "Não"} | '
          'Dispneia súbita: ${_dispneiaDesconforto ? "Sim" : "Não"} | '
          'Dor torácica/mal-estar súbito: ${_dorToracicaMalEstar ? "Sim" : "Não"} | '
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

    final idadeEstimada = int.tryParse(_idadeEstimadaIdosoCtrl.text.trim());
    final fichaAtualizada = fichaBase.copyWith(
      pacienteIdade: fichaBase.pacienteIdade ?? idadeEstimada,
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
                      ..._buildSecoesIdoso(ficha)
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
          _buildSwitch(
            'Possui Cartão da Gestante (levado à maternidade)?',
            _possuiCartaoGestante,
            (v) => _possuiCartaoGestante = v,
          ),
          _buildSwitch('Gestação de alto risco?', _gestacaoAltoRisco, (v) => _gestacaoAltoRisco = v),
        ],
      ),
      const SizedBox(height: 16),
      _buildCardSecao(
        titulo: '4. Sinais de Alerta, Pré-eclâmpsia e Parto',
        icone: Icons.warning_amber_rounded,
        children: [
          _buildSwitch('Sangramento vaginal?', _sangramentoVaginal, (v) => _sangramentoVaginal = v),
          if (_sangramentoVaginal) ...[
            const SizedBox(height: 8),
            _buildSeletorOpcoes(
              titulo: 'Quantidade do sangramento',
              opcoes: const ['Leve', 'Moderado', 'Intenso'],
              selecionado: _quantidadeSangramento,
              onSelect: (v) => _quantidadeSangramento = v,
            ),
            _buildSwitch('Presença de coágulos?', _presencaCoagulos, (v) => _presencaCoagulos = v),
          ],
          _buildSwitch('Perda de líquido amniótico (bolsa rota)?', _perdaLiquido, (v) => _perdaLiquido = v),
          if (_perdaLiquido) ...[
            const SizedBox(height: 8),
            _buildSeletorOpcoes(
              titulo: 'Aspecto do líquido amniótico',
              opcoes: const ['Claro', 'Meconial'],
              selecionado: _aspectoLiquido,
              onSelect: (v) => _aspectoLiquido = v,
            ),
            if (_aspectoLiquido == 'Meconial') ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.badgeRed,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.primaryRed),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: AppColors.darkRed, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'ALERTA: Líquido meconial indica sofrimento fetal — priorizar vaga na maternidade.',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.darkRed,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
          _buildSwitch('Contrações uterinas?', _contracoesUterinas, (v) => _contracoesUterinas = v),
          if (_contracoesUterinas) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    _frequenciaContracoesMinCtrl,
                    'Frequência (a cada X min)',
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTextField(
                    _duracaoContracoesSegCtrl,
                    'Duração (segundos)',
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
          ],
          _buildSwitch('Movimentação fetal presente?', _movimentacaoFetal, (v) => _movimentacaoFetal = v),
          const Divider(),
          _buildSwitch('Cefaleia intensa?', _cefaleiaIntensa, (v) => _cefaleiaIntensa = v),
          _buildSwitch('Alteração visual / escotomas?', _alteracaoVisual, (v) => _alteracaoVisual = v),
          _buildSwitch('Dor epigástrica?', _dorEpigastrica, (v) => _dorEpigastrica = v),
          _buildSwitch('Edema súbito em face/mãos?', _edemaSubito, (v) => _edemaSubito = v),
          _buildSwitch('Convulsões (eclâmpsia)?', _convulsoes, (v) => _convulsoes = v),
          const Divider(),
          _buildSwitch(
            'Coroamento / Apresentação fetal visível? (Parto iminente)',
            _periodoExpulsivo,
            (v) => _periodoExpulsivo = v,
          ),
          const SizedBox(height: 8),
          _buildSwitch(
            'BCF não avaliado / indisponível (USB sem Doppler)',
            _bcfNaoAvaliado,
            (v) {
              _bcfNaoAvaliado = v;
              if (v) _bcfCtrl.clear();
            },
          ),
          if (!_bcfNaoAvaliado) ...[
            const SizedBox(height: 8),
            _buildTextField(
              _bcfCtrl,
              'Batimentos Cardiofetais - BCF (bpm)',
              keyboardType: TextInputType.number,
            ),
          ],
          _buildSwitch('Transporte em decúbito lateral esquerdo?', _decubitoLateralEsquerdo, (v) => _decubitoLateralEsquerdo = v),
          const Divider(),
          _buildSwitch(
            'Parto realizado no local / transporte?',
            _partoRealizadoAph,
            (v) => _partoRealizadoAph = v,
          ),
          if (_partoRealizadoAph) ...[
            const SizedBox(height: 8),
            _buildTextField(_horaNascimentoCtrl, 'Hora do nascimento (HH:mm)'),
            const SizedBox(height: 12),
            const Text(
              'Vitalidade do Recém-Nascido (RN)',
              style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
            ),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Choro forte', style: TextStyle(fontSize: 14)),
              value: _rnChoroForte,
              activeColor: AppColors.primaryRed,
              onChanged: (v) => setState(() => _rnChoroForte = v ?? false),
            ),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Respiração espontânea', style: TextStyle(fontSize: 14)),
              value: _rnRespiracaoEspontanea,
              activeColor: AppColors.primaryRed,
              onChanged: (v) => setState(() => _rnRespiracaoEspontanea = v ?? false),
            ),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Tônus adequado', style: TextStyle(fontSize: 14)),
              value: _rnTonusAdequado,
              activeColor: AppColors.primaryRed,
              onChanged: (v) => setState(() => _rnTonusAdequado = v ?? false),
            ),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    _apgar1Ctrl,
                    'Apgar 1º min (0-10)',
                    keyboardType: TextInputType.number,
                    validator: (v) => _validarIntFaixa(v, 0, 10, '0 a 10'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTextField(
                    _apgar5Ctrl,
                    'Apgar 5º min (0-10)',
                    keyboardType: TextInputType.number,
                    validator: (v) => _validarIntFaixa(v, 0, 10, '0 a 10'),
                  ),
                ),
              ],
            ),
            _buildSwitch(
              'Clampeamento do cordão umbilical realizado?',
              _clampeamentoCordao,
              (v) => _clampeamentoCordao = v,
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _dequitacaoPlacenta,
              decoration: InputDecoration(
                labelText: 'Dequitação da placenta',
                filled: true,
                fillColor: AppColors.inputBg,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
              items: const ['Completa', 'Incompleta', 'Não ocorreu no transporte']
                  .map((e) => DropdownMenuItem<String>(value: e, child: Text(e)))
                  .toList(),
              onChanged: (v) => setState(() => _dequitacaoPlacenta = v!),
            ),
          ],
        ],
      ),
    ];
  }

  Widget _buildSeletorOpcoes({
    required String titulo,
    required List<String> opcoes,
    required String selecionado,
    required ValueChanged<String> onSelect,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titulo,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: opcoes.map((opcao) {
            final ativo = selecionado == opcao;
            final alerta = ativo && opcao == 'Meconial';
            return ChoiceChip(
              label: Text(opcao),
              selected: ativo,
              selectedColor: alerta ? AppColors.primaryRed : AppColors.badgeRed,
              labelStyle: TextStyle(
                color: alerta
                    ? Colors.white
                    : (ativo ? AppColors.darkRed : AppColors.textPrimary),
                fontWeight: ativo ? FontWeight.w700 : FontWeight.w500,
              ),
              onSelected: (_) => setState(() => onSelect(opcao)),
            );
          }).toList(),
        ),
      ],
    );
  }

  List<Widget> _buildSecoesIdoso(FichaAtendimentoModel? ficha) {
    final semIdade = ficha?.pacienteIdade == null;
    return [
      if (semIdade) ...[
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.warningBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.warning),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.info_outline, color: AppColors.darkOrange, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Idade não informada na triagem — informe a idade estimada do paciente idoso:',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.darkOrange,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _buildTextField(
                _idadeEstimadaIdosoCtrl,
                'Idade estimada (anos)',
                keyboardType: TextInputType.number,
                validator: (v) => _validarIntFaixa(v, 50, 125, 'Informe idade válida'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
      _buildCardSecao(
        titulo: '3. Funcionalidade, Cognição, AVC e Quedas',
        icone: Icons.elderly,
        children: [
          DropdownButtonFormField<String>(
            initialValue: _independenciaPrevia,
            decoration: InputDecoration(
              labelText: 'Mobilidade / Dependência prévia',
              filled: true,
              fillColor: AppColors.inputBg,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
            items: const ['Deambula', 'Usa dispositivo de auxílio', 'Acamado']
                .map((e) => DropdownMenuItem<String>(value: e, child: Text(e)))
                .toList(),
            onChanged: (v) => setState(() => _independenciaPrevia = v!),
          ),
          _buildSwitch(
            'Estado mental alterado em relação ao basal?',
            _estadoMentalAlteradoBasal,
            (v) => _estadoMentalAlteradoBasal = v,
          ),
          _buildSwitch('Confusão mental aguda (delirium)?', _confusaoAguda, (v) => _confusaoAguda = v),
          _buildSwitch('Demência prévia diagnosticada?', _demenciaPrevia, (v) => _demenciaPrevia = v),
          const Divider(),
          const Text(
            'Protocolo de AVC (Cincinnati) e Janela Terapêutica',
            style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
          ),
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
          if (_avcSuspeito) ...[
            const SizedBox(height: 8),
            _buildTextField(
              _horarioInicioSintomasAvcCtrl,
              'Horário do início dos sintomas / Última vez visto bem (HH:mm)',
            ),
          ],
          const Divider(),
          _buildSwitch('Houve queda / trauma associado?', _ocorrenciaQueda, (v) => _ocorrenciaQueda = v),
          if (_ocorrenciaQueda) ...[
            const SizedBox(height: 8),
            _buildTextField(_mecanismoQuedaCtrl, 'Mecanismo / altura da queda'),
          ],
          _buildSwitch(
            'Dor ou deformidade em quadril / membros?',
            _dorDeformidadeQuadrilMembros,
            (v) => _dorDeformidadeQuadrilMembros = v,
          ),
          _buildSwitch('Perda de consciência / trauma craniano?', _perdaConscienciaTrauma, (v) => _perdaConscienciaTrauma = v),
          _buildSwitch('Quedas recorrentes nos últimos meses?', _quedasRecorrentes, (v) => _quedasRecorrentes = v),
        ],
      ),
      const SizedBox(height: 16),
      _buildCardSecao(
        titulo: '4. Anticoagulação, Cardiopulmonar/Sepse e Apoio',
        icone: Icons.medication_outlined,
        children: [
          _buildSwitch('Uso de anticoagulante / antiagregante?', _usaAnticoagulante, (v) => _usaAnticoagulante = v),
          if (_ocorrenciaQueda && _usaAnticoagulante) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.badgeRed,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.primaryRed),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: AppColors.darkRed, size: 18),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'ALERTA: Queda em uso de anticoagulante — alto risco de hematoma subdural/hemorragia.',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.darkRed),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],
          const SizedBox(height: 8),
          _buildTextField(
            _polifarmaciaCtrl,
            'Polifarmácia (anti-hipertensivos, hipoglicemiantes, psicotrópicos)',
            maxLines: 2,
          ),
          _buildSwitch('Adesão recente à medicação?', _adesaoMedicacao, (v) => _adesaoMedicacao = v),
          const Divider(),
          _buildSwitch(
            'Dispneia / desconforto respiratório súbito?',
            _dispneiaDesconforto,
            (v) => _dispneiaDesconforto = v,
          ),
          _buildSwitch(
            'Dor torácica / mal-estar súbito (ou sudorese)?',
            _dorToracicaMalEstar,
            (v) => _dorToracicaMalEstar = v,
          ),
          _buildSwitch('Perda de peso / desnutrição ou desidratação?', _desnutricaoDesidratacao, (v) => _desnutricaoDesidratacao = v),
          _buildSwitch('Incontinência aguda / suspeita de sepse sem febre?', _incontinenciaAguda, (v) => _incontinenciaAguda = v),
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
