import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_routes.dart';
import '../../models/ficha_model.dart';
import '../../providers/ficha_provider.dart';
import '../../services/database_service.dart';
import '../../utils/cpf_validator.dart';
import 'widgets/samu_app_bar_header.dart';

enum PerfilFichaAtendimento { gestante, idoso, comum }

class FichaPersonalizadaView extends StatefulWidget {
  final PerfilFichaAtendimento perfil;
  final FichaAtendimentoModel? fichaParcial;

  const FichaPersonalizadaView({
    super.key,
    required this.perfil,
    this.fichaParcial,
  });

  @override
  State<FichaPersonalizadaView> createState() => _FichaPersonalizadaViewState();
}

class _FichaPersonalizadaViewState extends State<FichaPersonalizadaView> {
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;

  // Dados gerais da ocorrência e paciente
  String _tipoViatura = 'USB';
  String _codigoTriagem = 'Vermelho';
  String _sexo = 'Feminino';
  final _nomeCtrl = TextEditingController();
  final _idadeCtrl = TextEditingController();
  final _cpfCtrl = TextEditingController();
  final _acompanhanteCtrl = TextEditingController();
  final _telefoneCtrl = TextEditingController();
  final _queixaCtrl = TextEditingController();
  final _alergiasCtrl = TextEditingController();
  final _medicamentosCtrl = TextEditingController();
  final _condutaCtrl = TextEditingController();

  // Sinais vitais
  final _paCtrl = TextEditingController();
  final _fcCtrl = TextEditingController();
  final _frCtrl = TextEditingController();
  final _spo2Ctrl = TextEditingController();
  final _glicemiaCtrl = TextEditingController();
  final _tempCtrl = TextEditingController();
  final _glasgowCtrl = TextEditingController();

  // Campos específicos: Gestante
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
  bool _dorAbdominal = false;
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

  // Campos específicos: Idoso
  String _independenciaPrevia = 'Independente';
  bool _riscoQueda = false;
  bool _confusaoAguda = false;
  bool _demenciaPrevia = false;
  bool _ocorrenciaQueda = false;
  final _mecanismoQuedaCtrl = TextEditingController();
  bool _perdaConscienciaTrauma = false;
  bool _quedasRecorrentes = false;
  bool _usaAnticoagulante = false;
  bool _polifarmaciaAtiva = false;
  bool _deficitMobilidade = false;
  final _polifarmaciaCtrl = TextEditingController();
  bool _adesaoMedicacao = true;
  bool _desnutricaoDesidratacao = false;
  bool _incontinenciaAguda = false;
  bool _sintomaAtipicoCardioResp = false;
  bool _moraSozinho = false;
  final _contatoCuidadorCtrl = TextEditingController();
  bool _sinaisVulnerabilidade = false;

  // Campos específicos: Paciente comum
  bool _queixaClinica = false;
  bool _trauma = false;
  bool _dorIntensa = false;
  bool _alergiaConhecida = false;
  bool _semComorbidades = false;
  bool _assimetriaFacial = false;
  bool _quedaBraco = false;
  bool _falaAnormal = false;
  bool _avcSuspeito = false;

  bool get _isGestante => widget.perfil == PerfilFichaAtendimento.gestante;
  bool get _isIdoso => widget.perfil == PerfilFichaAtendimento.idoso;

  @override
  void initState() {
    super.initState();
    _sexo = _isGestante ? 'Feminino' : 'Masculino';
  }

  @override
  void dispose() {
    for (final c in [
      _nomeCtrl,
      _idadeCtrl,
      _cpfCtrl,
      _acompanhanteCtrl,
      _telefoneCtrl,
      _queixaCtrl,
      _alergiasCtrl,
      _medicamentosCtrl,
      _condutaCtrl,
      _paCtrl,
      _fcCtrl,
      _frCtrl,
      _spo2Ctrl,
      _glicemiaCtrl,
      _tempCtrl,
      _glasgowCtrl,
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

  String _montarResumoEspecifico() {
    if (_isGestante) {
      return [
        '[FICHA GESTANTE]',
        if (_idadeGestacionalCtrl.text.trim().isNotEmpty)
          'IG: ${_idadeGestacionalCtrl.text.trim()} sem',
        if (_dumCtrl.text.trim().isNotEmpty) 'DUM: ${_dumCtrl.text.trim()}',
        if (_dppCtrl.text.trim().isNotEmpty) 'DPP: ${_dppCtrl.text.trim()}',
        if (_gpaCtrl.text.trim().isNotEmpty) 'G/P/A: ${_gpaCtrl.text.trim()}',
        'Pré-natal: ${_realizaPreNatal ? "Sim" : "Não"}'
            '${_unidadePreNatalCtrl.text.trim().isNotEmpty ? " (${_unidadePreNatalCtrl.text.trim()})" : ""}',
        if (_tipoSanguineoCtrl.text.trim().isNotEmpty)
          'Tipo Sang/Rh: ${_tipoSanguineoCtrl.text.trim()}',
        'Alto risco: ${_gestacaoAltoRisco ? "Sim" : "Não"}',
        'Dor abdominal: ${_dorAbdominal ? "Sim" : "Não"}',
        'Sangramento vaginal: ${_sangramentoVaginal ? "Sim" : "Não"}',
        'Bolsa rota: ${_perdaLiquido ? "Sim" : "Não"}',
        'Contrações: ${_contracoesUterinas ? "Sim (${_frequenciaContracoesCtrl.text.trim()})" : "Não"}',
        'Mov. fetal: ${_movimentacaoFetal ? "Presente" : "Ausente"}',
        'Sinais pré-eclâmpsia: cefaleia=${_cefaleiaIntensa ? "S" : "N"}, '
            'visual=${_alteracaoVisual ? "S" : "N"}, '
            'epigástrica=${_dorEpigastrica ? "S" : "N"}, '
            'edema=${_edemaSubito ? "S" : "N"}, '
            'convulsão=${_convulsoes ? "S" : "N"}',
        'Período expulsivo: ${_periodoExpulsivo ? "Sim" : "Não"}',
        if (_bcfCtrl.text.trim().isNotEmpty) 'BCF: ${_bcfCtrl.text.trim()} bpm',
        'Decúbito lateral esquerdo: ${_decubitoLateralEsquerdo ? "Sim" : "Não"}',
      ].join(' | ');
    }

    if (_isIdoso) {
      return [
        '[FICHA IDOSO]',
        'Independência: $_independenciaPrevia',
        'Risco de queda: ${_riscoQueda ? "Sim" : "Não"}',
        'Delirium agudo: ${_confusaoAguda ? "Sim" : "Não"}',
        'Demência prévia: ${_demenciaPrevia ? "Sim" : "Não"}',
        'Queda: ${_ocorrenciaQueda ? "Sim (${_mecanismoQuedaCtrl.text.trim()})" : "Não"}',
        'Perda consciência/TCE: ${_perdaConscienciaTrauma ? "Sim" : "Não"}',
        'Quedas recorrentes: ${_quedasRecorrentes ? "Sim" : "Não"}',
        'Anticoagulante: ${_usaAnticoagulante ? "Sim" : "Não"}',
        'Polifarmácia ativa: ${_polifarmaciaAtiva ? "Sim" : "Não"}',
        'Déficit de mobilidade: ${_deficitMobilidade ? "Sim" : "Não"}',
        if (_polifarmaciaCtrl.text.trim().isNotEmpty)
          'Polifarmácia: ${_polifarmaciaCtrl.text.trim()}',
        'Adesão medicação: ${_adesaoMedicacao ? "Sim" : "Não"}',
        'Desnutrição/Desidratação: ${_desnutricaoDesidratacao ? "Sim" : "Não"}',
        'Incontinência aguda: ${_incontinenciaAguda ? "Sim" : "Não"}',
        'Dor torácica atípica/dispneia: ${_sintomaAtipicoCardioResp ? "Sim" : "Não"}',
        'Mora sozinho: ${_moraSozinho ? "Sim" : "Não"}',
        if (_contatoCuidadorCtrl.text.trim().isNotEmpty)
          'Cuidador: ${_contatoCuidadorCtrl.text.trim()}',
        'Vulnerabilidade/negligência: ${_sinaisVulnerabilidade ? "Sim" : "Não"}',
      ].join(' | ');
    }

    return [
      '[FICHA PACIENTE COMUM]',
      'Queixa clínica: ${_queixaClinica ? "Sim" : "Não"}',
      'Trauma: ${_trauma ? "Sim" : "Não"}',
      'Dor intensa: ${_dorIntensa ? "Sim" : "Não"}',
      'Alergia conhecida: ${_alergiaConhecida ? "Sim" : "Não"}',
      'Sem comorbidades relatadas: ${_semComorbidades ? "Sim" : "Não"}',
      'AVC suspeito: ${_avcSuspeito ? "Sim" : "Não"}',
    ].join(' | ');
  }

  Future<void> _avancarParaAssinatura() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    final now = DateTime.now();
    final resumoEspecifico = _montarResumoEspecifico();

    final fichaBase = widget.fichaParcial ??
        ModalRoute.of(context)?.settings.arguments as FichaAtendimentoModel? ??
        context.read<FichaEmAndamentoProvider>().ficha;

    final tipoOcorrenciaPadrao = _isGestante
        ? 'Obstétrico (Gestante)'
        : (_isIdoso
            ? 'Geriátrico (Idoso)'
            : (_trauma ? 'Trauma' : 'Atendimento Pré-Hospitalar'));
    final nomePadrao = _isGestante
        ? 'Gestante Não Identificada'
        : (_isIdoso ? 'Idoso Não Identificado' : 'Paciente Não Identificado');
    final queixaPadrao = _isGestante
        ? 'Atendimento Obstétrico'
        : (_isIdoso ? 'Atendimento Geriátrico' : 'Atendimento APH de emergência');

    final ficha = (fichaBase ??
            FichaAtendimentoModel(
              id: const Uuid().v4(),
              numeroOcorrencia: 'REG-${now.millisecondsSinceEpoch.toString().substring(7)}',
              dataHora: now,
              pacienteNome: '',
              tipoOcorrencia: tipoOcorrenciaPadrao,
              endereco: '',
              unidadeResponsavel: _tipoViatura,
              tipoViatura: _tipoViatura,
              codigoTriagem: _codigoTriagem,
              statusSincronizacao: StatusSincronizacao.pendente,
            ))
        .copyWith(
      pacienteNome: _nomeCtrl.text.trim().isNotEmpty
          ? _nomeCtrl.text.trim()
          : nomePadrao,
      pacienteIdade: int.tryParse(_idadeCtrl.text.trim()),
      pacienteSexo: _sexo,
      pacienteCpf: _cpfCtrl.text.trim().isNotEmpty ? _cpfCtrl.text.trim() : null,
      acompanhante: _acompanhanteCtrl.text.trim().isNotEmpty
          ? _acompanhanteCtrl.text.trim()
          : null,
      telefoneContato: _telefoneCtrl.text.trim().isNotEmpty
          ? _telefoneCtrl.text.trim()
          : null,
      medicamentosUsoContinuo: _medicamentosCtrl.text.trim().isNotEmpty
          ? _medicamentosCtrl.text.trim()
          : null,
      alergias: _alergiasCtrl.text.trim().isNotEmpty ? _alergiasCtrl.text.trim() : null,
      observacoes: resumoEspecifico,
      tipoOcorrencia: tipoOcorrenciaPadrao,
      unidadeResponsavel: _tipoViatura,
      tipoViatura: _tipoViatura,
      codigoTriagem: _codigoTriagem,
      pressaoArterial: _paCtrl.text.trim().isNotEmpty ? _paCtrl.text.trim() : null,
      frequenciaCardiaca: int.tryParse(_fcCtrl.text.trim()),
      frequenciaRespiratoria: int.tryParse(_frCtrl.text.trim()),
      saturacaoO2: int.tryParse(_spo2Ctrl.text.trim()),
      glicemia: int.tryParse(_glicemiaCtrl.text.trim()),
      temperatura: double.tryParse(_tempCtrl.text.trim().replaceAll(',', '.')),
      escalaGlasgow: int.tryParse(_glasgowCtrl.text.trim()),
      assimetriaFacial: _assimetriaFacial,
      quedaBraco: _quedaBraco,
      falaAnormal: _falaAnormal,
      avcSuspeito: _avcSuspeito,
      queixaPrincipal: _queixaCtrl.text.trim().isNotEmpty
          ? _queixaCtrl.text.trim()
          : queixaPadrao,
      condutaMedica: _condutaCtrl.text.trim().isNotEmpty
          ? _condutaCtrl.text.trim()
          : resumoEspecifico,
      statusSincronizacao: StatusSincronizacao.pendente,
    );

    try {
      await DatabaseService().inserirFicha(ficha);
      if (!mounted) return;
      context.read<FichaEmAndamentoProvider>().setFicha(ficha);
      setState(() => _isSaving = false);

      Navigator.pushNamed(
        context,
        AppRoutes.assinaturaPaciente,
        arguments: ficha,
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não foi possível salvar a ficha localmente.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final titulo = _isGestante
        ? 'Ficha Personalizada - Gestante'
        : (_isIdoso
            ? 'Ficha Personalizada - Idoso'
            : 'Ficha Personalizada - Paciente Comum');

    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      appBar: SamuAppBarHeader(
        title: titulo,
        onBack: () => Navigator.pop(context),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 680),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildQuadroPerfilInicial(),
                    const SizedBox(height: 16),
                    _buildCardSecao(
                      titulo: '1. Ocorrência e Identificação do Paciente',
                      icone: Icons.person_outline,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _buildDropdown<String>(
                                label: 'Viatura',
                                value: _tipoViatura,
                                items: const ['USB', 'USA'],
                                onChanged: (v) => setState(() => _tipoViatura = v!),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildDropdown<String>(
                                label: 'Triagem',
                                value: _codigoTriagem,
                                items: const ['Vermelho', 'Amarelo', 'Verde', 'Azul'],
                                onChanged: (v) => setState(() => _codigoTriagem = v!),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildTextField(_nomeCtrl, 'Nome completo do paciente'),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _buildTextField(
                                _idadeCtrl,
                                'Idade',
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildDropdown<String>(
                                label: 'Sexo',
                                value: _sexo,
                                items: const ['Feminino', 'Masculino'],
                                onChanged: (v) => setState(() => _sexo = v!),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildTextField(
                          _cpfCtrl,
                          'CPF (opcional)',
                          keyboardType: TextInputType.number,
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) return null;
                            return CpfValidator.validar(val.trim()) ? null : 'CPF inválido';
                          },
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _buildTextField(_acompanhanteCtrl, 'Acompanhante'),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildTextField(
                                _telefoneCtrl,
                                'Telefone contato',
                                keyboardType: TextInputType.phone,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildCardSecao(
                      titulo: '2. Sinais Vitais e Histórico',
                      icone: Icons.monitor_heart_outlined,
                      children: [
                        Row(
                          children: [
                            Expanded(child: _buildTextField(_paCtrl, 'PA (ex: 120/80)')),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildTextField(
                                _fcCtrl,
                                'FC (bpm)',
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildTextField(
                                _frCtrl,
                                'FR (rpm)',
                                keyboardType: TextInputType.number,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _buildTextField(
                                _spo2Ctrl,
                                'SpO₂ (%)',
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildTextField(
                                _glicemiaCtrl,
                                'Glicemia (mg/dL)',
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildTextField(
                                _tempCtrl,
                                'Temp (°C)',
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildTextField(
                                _glasgowCtrl,
                                'Glasgow',
                                keyboardType: TextInputType.number,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildTextField(_queixaCtrl, 'Queixa principal', maxLines: 2),
                        const SizedBox(height: 12),
                        _buildTextField(_alergiasCtrl, 'Alergias'),
                        const SizedBox(height: 12),
                        _buildTextField(_medicamentosCtrl, 'Medicamentos em uso contínuo'),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (_isGestante)
                      ..._buildSecoesGestante()
                    else if (_isIdoso)
                      ..._buildSecoesIdoso()
                    else
                      ..._buildSecoesComum(),
                    const SizedBox(height: 16),
                    _buildCardSecao(
                      titulo: 'Conduta Clínica',
                      icone: Icons.assignment_outlined,
                      children: [
                        _buildTextField(
                          _condutaCtrl,
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
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
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

  Widget _buildQuadroPerfilInicial() {
    final titulo = _isGestante
        ? 'Ficha da gestante'
        : (_isIdoso ? 'Ficha do idoso' : 'Ficha do paciente comum');
    final subtitulo = _isGestante
        ? 'Avaliação obstétrica e materno-fetal'
        : (_isIdoso
            ? 'Avaliação geriátrica e funcional'
            : 'Atendimento clínico ou traumático');
    final icone = _isGestante
        ? Icons.child_care_outlined
        : (_isIdoso ? Icons.health_and_safety_outlined : Icons.person_outline);

    final chips = _isGestante
        ? [
            _buildCondicaoChip(
              'Dor abdominal',
              _dorAbdominal,
              (v) => _dorAbdominal = v,
            ),
            _buildCondicaoChip(
              'Sangramento vaginal',
              _sangramentoVaginal,
              (v) => _sangramentoVaginal = v,
            ),
            _buildCondicaoChip(
              'Perda de líquido',
              _perdaLiquido,
              (v) => _perdaLiquido = v,
            ),
            _buildCondicaoChip(
              'Contrações',
              _contracoesUterinas,
              (v) => _contracoesUterinas = v,
            ),
            _buildCondicaoChip(
              'Movimentos fetais presentes',
              _movimentacaoFetal,
              (v) => _movimentacaoFetal = v,
            ),
          ]
        : (_isIdoso
            ? [
                _buildCondicaoChip(
                  'Risco de queda',
                  _riscoQueda,
                  (v) => _riscoQueda = v,
                ),
                _buildCondicaoChip(
                  'Alteração de consciência',
                  _confusaoAguda,
                  (v) => _confusaoAguda = v,
                ),
                _buildCondicaoChip(
                  'Uso de anticoagulante',
                  _usaAnticoagulante,
                  (v) => _usaAnticoagulante = v,
                ),
                _buildCondicaoChip(
                  'Polifarmácia',
                  _polifarmaciaAtiva,
                  (v) => _polifarmaciaAtiva = v,
                ),
                _buildCondicaoChip(
                  'Déficit de mobilidade',
                  _deficitMobilidade,
                  (v) => _deficitMobilidade = v,
                ),
              ]
            : [
                _buildCondicaoChip(
                  'Queixa clínica',
                  _queixaClinica,
                  (v) => _queixaClinica = v,
                ),
                _buildCondicaoChip(
                  'Trauma',
                  _trauma,
                  (v) => _trauma = v,
                ),
                _buildCondicaoChip(
                  'Dor intensa',
                  _dorIntensa,
                  (v) => _dorIntensa = v,
                ),
                _buildCondicaoChip(
                  'Alergia conhecida',
                  _alergiaConhecida,
                  (v) => _alergiaConhecida = v,
                ),
                _buildCondicaoChip(
                  'Sem comorbidades relatadas',
                  _semComorbidades,
                  (v) => _semComorbidades = v,
                ),
              ]);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFF6D5D5)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: const Color(0xFFFFF1F1),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: AppColors.fieryRed,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icone,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        titulo,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF2B0804),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitulo,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF9E4A43),
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Alterar',
                    style: TextStyle(
                      color: AppColors.darkRed,
                      fontWeight: FontWeight.w700,
                      decoration: TextDecoration.underline,
                      decorationColor: AppColors.darkRed,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Marque as condições identificadas',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: chips,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCondicaoChip(
    String label,
    bool selected,
    ValueChanged<bool> setter,
  ) {
    return InkWell(
      onTap: () => setState(() => setter(!selected)),
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFFFEBEE) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: selected ? AppColors.primaryRed : const Color(0xFFE2E8F0),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? AppColors.darkRed : AppColors.textDark,
          ),
        ),
      ),
    );
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
          _buildDropdown<String>(
            label: 'Nível de independência prévia',
            value: _independenciaPrevia,
            items: const ['Independente', 'Deambula com auxílio', 'Acamado'],
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

  Widget _buildDropdown<T>({
    required String label,
    required T value,
    required List<T> items,
    required ValueChanged<T?> onChanged,
  }) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: AppColors.inputBg,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
      items: items
          .map((e) => DropdownMenuItem<T>(value: e, child: Text(e.toString())))
          .toList(),
      onChanged: onChanged,
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
