import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_routes.dart';
import '../../models/ficha_model.dart';
import '../../providers/ficha_provider.dart';
import '../../services/database_service.dart';
import '../../services/gps_service.dart';
import 'widgets/samu_app_bar_header.dart';

class DadosPacienteView extends StatefulWidget {
  final FichaAtendimentoModel? fichaParcial;

  const DadosPacienteView({
    super.key,
    this.fichaParcial,
  });

  @override
  State<DadosPacienteView> createState() => _DadosPacienteViewState();
}

class _DadosPacienteViewState extends State<DadosPacienteView> {
  final _formKey = GlobalKey<FormState>();

  // Controladores: Dados do Paciente
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _idadeController = TextEditingController();
  final TextEditingController _dataNascimentoController = TextEditingController();
  final TextEditingController _documentoController = TextEditingController();
  final TextEditingController _acompanhanteController = TextEditingController();
  final TextEditingController _grauParentescoController = TextEditingController();
  final TextEditingController _telefoneController = TextEditingController();
  final TextEditingController _medicamentosController = TextEditingController();
  final TextEditingController _alergiasController = TextEditingController();
  String _sexoSelecionado = 'Masculino';

  // Controladores: Endereço e GPS
  final TextEditingController _cepController = TextEditingController();
  final TextEditingController _ruaController = TextEditingController();
  final TextEditingController _numeroController = TextEditingController();
  final TextEditingController _bairroController = TextEditingController();
  final TextEditingController _complementoController = TextEditingController();
  final TextEditingController _cidadeController = TextEditingController(text: 'Joinville - SC');

  bool _isBuscandoCep = false;
  bool _isSaving = false;
  double? _latitude;
  double? _longitude;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _carregarDadosIniciais();
    });
  }

  void _carregarDadosIniciais() {
    FichaAtendimentoModel? providerFicha;
    try {
      providerFicha = Provider.of<FichaEmAndamentoProvider>(context, listen: false).ficha;
    } catch (_) {
      providerFicha = null;
    }

    final FichaAtendimentoModel? f = widget.fichaParcial ??
        ModalRoute.of(context)?.settings.arguments as FichaAtendimentoModel? ??
        providerFicha;

    if (f != null) {
      if (f.pacienteNome.isNotEmpty && !f.pacienteNome.startsWith('Paciente Ocorrência')) {
        _nomeController.text = f.pacienteNome;
      }
      if (f.pacienteIdade != null) {
        _idadeController.text = f.pacienteIdade.toString();
      }
      if (f.pacienteDataNascimento != null) {
        _dataNascimentoController.text = f.pacienteDataNascimento!;
      }
      if (f.pacienteSexo != null && (f.pacienteSexo == 'Masculino' || f.pacienteSexo == 'Feminino')) {
        _sexoSelecionado = f.pacienteSexo!;
      }
      if (f.pacienteCpf != null) {
        _documentoController.text = f.pacienteCpf!;
      }
      if (f.acompanhante != null) {
        _acompanhanteController.text = f.acompanhante!;
      }
      if (f.grauParentesco != null) {
        _grauParentescoController.text = f.grauParentesco!;
      }
      if (f.telefoneContato != null) {
        _telefoneController.text = f.telefoneContato!;
      }
      if (f.medicamentosUsoContinuo != null) {
        _medicamentosController.text = f.medicamentosUsoContinuo!;
      }
      if (f.alergias != null) {
        _alergiasController.text = f.alergias!;
      }
      if (f.latitude != null) _latitude = f.latitude;
      if (f.longitude != null) _longitude = f.longitude;
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _idadeController.dispose();
    _dataNascimentoController.dispose();
    _documentoController.dispose();
    _acompanhanteController.dispose();
    _grauParentescoController.dispose();
    _telefoneController.dispose();
    _medicamentosController.dispose();
    _alergiasController.dispose();
    _cepController.dispose();
    _ruaController.dispose();
    _numeroController.dispose();
    _bairroController.dispose();
    _complementoController.dispose();
    _cidadeController.dispose();
    super.dispose();
  }

  Future<void> _buscarEnderecoPorCep(String cep) async {
    final cleanCep = cep.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanCep.length < 8) return;

    setState(() => _isBuscandoCep = true);

    final resultado = await GpsService().buscarEnderecoPorCep(cleanCep);

    if (!mounted) return;
    setState(() => _isBuscandoCep = false);

    if (resultado != null) {
      setState(() {
        if (resultado.logradouro.isNotEmpty) _ruaController.text = resultado.logradouro;
        if (resultado.bairro.isNotEmpty) _bairroController.text = resultado.bairro;
        if (resultado.cidade.isNotEmpty) _cidadeController.text = '${resultado.cidade} - ${resultado.estado}';
        _latitude = resultado.latitude;
        _longitude = resultado.longitude;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Endereço localizado: ${resultado.logradouro}, ${resultado.bairro}"),
          backgroundColor: AppColors.success,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Não foi possível obter a localização, preencha manualmente"),
          backgroundColor: AppColors.warning,
          duration: Duration(seconds: 4),
        ),
      );
    }
  }

  Future<void> _obterGpsAtual() async {
    setState(() => _isBuscandoCep = true);
    final pos = await GpsService().obterPosicaoAtual();
    if (!mounted) return;
    setState(() => _isBuscandoCep = false);

    if (pos != null) {
      setState(() {
        _latitude = pos.latitude;
        _longitude = pos.longitude;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Coordenadas GPS capturadas: Lat ${_latitude?.toStringAsFixed(4)}, Long ${_longitude?.toStringAsFixed(4)}"),
          backgroundColor: AppColors.success,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Não foi possível obter a localização, preencha manualmente"),
          backgroundColor: AppColors.warning,
          duration: Duration(seconds: 4),
        ),
      );
    }
  }

  Future<void> _avancarParaAvaliacaoClinica() async {
    FichaEmAndamentoProvider? provider;
    try {
      provider = Provider.of<FichaEmAndamentoProvider>(context, listen: false);
    } catch (_) {
      provider = null;
    }

    final FichaAtendimentoModel? fichaBase = widget.fichaParcial ??
        ModalRoute.of(context)?.settings.arguments as FichaAtendimentoModel? ??
        provider?.ficha;

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

    final nomeFinal = _nomeController.text.trim().isEmpty
        ? 'Paciente Não Identificado'
        : _nomeController.text.trim();

    final enderecoFormatado = [
      if (_ruaController.text.trim().isNotEmpty) _ruaController.text.trim(),
      if (_numeroController.text.trim().isNotEmpty) _numeroController.text.trim(),
      if (_bairroController.text.trim().isNotEmpty) _bairroController.text.trim(),
      if (_cidadeController.text.trim().isNotEmpty) _cidadeController.text.trim(),
      if (_cepController.text.trim().isNotEmpty) "CEP: ${_cepController.text.trim()}",
    ].join(', ');

    final fichaAtualizada = fichaBase.copyWith(
      pacienteNome: nomeFinal,
      pacienteIdade: int.tryParse(_idadeController.text.trim()),
      pacienteDataNascimento: _dataNascimentoController.text.trim().isNotEmpty
          ? _dataNascimentoController.text.trim()
          : null,
      pacienteSexo: _sexoSelecionado,
      pacienteCpf: _documentoController.text.trim().isNotEmpty
          ? _documentoController.text.trim()
          : null,
      acompanhante: _acompanhanteController.text.trim().isNotEmpty
          ? _acompanhanteController.text.trim()
          : null,
      grauParentesco: _grauParentescoController.text.trim().isNotEmpty
          ? _grauParentescoController.text.trim()
          : null,
      telefoneContato: _telefoneController.text.trim().isNotEmpty
          ? _telefoneController.text.trim()
          : null,
      medicamentosUsoContinuo: _medicamentosController.text.trim().isNotEmpty
          ? _medicamentosController.text.trim()
          : null,
      alergias: _alergiasController.text.trim().isNotEmpty
          ? _alergiasController.text.trim()
          : null,
      endereco: enderecoFormatado.isNotEmpty ? enderecoFormatado : fichaBase.endereco,
      latitude: _latitude,
      longitude: _longitude,
    );

    try {
      await DatabaseService().inserirFicha(fichaAtualizada);
      if (!mounted) return;
      provider?.setFicha(fichaAtualizada);

      setState(() => _isSaving = false);

      Navigator.pushNamed(
        context,
        AppRoutes.avaliacaoClinica,
        arguments: fichaAtualizada,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Erro ao gravar dados do paciente localmente. Tente novamente."),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      appBar: SamuAppBarHeader(
        title: "Dados do Paciente",
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
                    _buildIdentificacaoCard(),
                    const SizedBox(height: 20),
                    _buildLocalizacaoCard(),
                    const SizedBox(height: 20),
                    _buildHistoricoCard(),
                    const SizedBox(height: 28),

                    // Botão Continuar
                    SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _avancarParaAvaliacaoClinica,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.crimson,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
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
                                  Text(
                                    "Continuar",
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.3),
                                  ),
                                  SizedBox(width: 8),
                                  Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: TextButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back, size: 16, color: AppColors.textSecondary),
                        label: const Text("Voltar ao Registro", style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
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

  Widget _buildIdentificacaoCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.person_outline_rounded, color: AppColors.crimson, size: 20),
              SizedBox(width: 8),
              Text("Identificação do Paciente", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _nomeController,
            decoration: _inputDecoration("Nome do Paciente", icon: Icons.badge_outlined),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextFormField(
                  controller: _idadeController,
                  keyboardType: TextInputType.number,
                  decoration: _inputDecoration("Idade"),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 3,
                child: TextFormField(
                  controller: _dataNascimentoController,
                  decoration: _inputDecoration("Data de Nascimento", icon: Icons.calendar_today_outlined),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: DropdownButtonFormField<String>(
                  initialValue: _sexoSelecionado,
                  isExpanded: true,
                  decoration: _inputDecoration("Sexo"),
                  items: const [
                    DropdownMenuItem(value: 'Masculino', child: Text('Masculino')),
                    DropdownMenuItem(value: 'Feminino', child: Text('Feminino')),
                  ],
                  onChanged: (val) => setState(() => _sexoSelecionado = val ?? 'Masculino'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 3,
                child: TextFormField(
                  controller: _documentoController,
                  keyboardType: TextInputType.number,
                  decoration: _inputDecoration("CPF do paciente", icon: Icons.credit_card_outlined),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLocalizacaoCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.location_on_outlined, color: AppColors.crimson, size: 20),
                  SizedBox(width: 8),
                  Text("Endereço", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                ],
              ),
              IconButton(
                onPressed: _isBuscandoCep ? null : _obterGpsAtual,
                icon: const Icon(Icons.my_location_rounded, color: AppColors.crimson),
                tooltip: "Obter Coordenadas GPS",
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _cepController,
                  keyboardType: TextInputType.number,
                  decoration: _inputDecoration(
                    "CEP",
                    hintText: "Digite o CEP (ex: 89201-000)",
                    icon: Icons.search_rounded,
                  ),
                  onChanged: (val) {
                    if (val.length == 8) _buscarEnderecoPorCep(val);
                  },
                ),
              ),
              const SizedBox(width: 8),
              if (_isBuscandoCep)
                const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.crimson)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                flex: 4,
                child: TextFormField(
                  controller: _ruaController,
                  decoration: _inputDecoration("Rua"),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: TextFormField(
                  controller: _numeroController,
                  decoration: _inputDecoration("Número"),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _bairroController,
                  decoration: _inputDecoration("Bairro"),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  controller: _complementoController,
                  decoration: _inputDecoration("Complemento"),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHistoricoCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.history_edu_outlined, color: AppColors.crimson, size: 20),
              SizedBox(width: 8),
              Text("Histórico & Acompanhante", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _acompanhanteController,
            decoration: _inputDecoration("Acompanhante", icon: Icons.people_outline_rounded),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _grauParentescoController,
            decoration: _inputDecoration("Grau de parentesco"),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _telefoneController,
            keyboardType: TextInputType.phone,
            decoration: _inputDecoration("Telefone de Contato", icon: Icons.phone_outlined),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _medicamentosController,
            maxLines: 2,
            decoration: _inputDecoration("Medicamentos de uso continuo"),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _alergiasController,
            maxLines: 2,
            decoration: _inputDecoration("Alergias"),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String label, {String? hintText, IconData? icon}) {
    return InputDecoration(
      labelText: label,
      hintText: hintText,
      labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
      hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
      prefixIcon: icon != null ? Icon(icon, size: 18, color: AppColors.textMuted) : null,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
