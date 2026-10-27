// ============================================================================
// VIEW ASSISTENCIAL: DADOS DO PACIENTE E LOCALIZAÇÃO COM GPS / CEP
// Arquivo: lib/views/assistencial/dados_paciente_view.dart
// ============================================================================

import 'package:flutter/material.dart';
import '../../models/ficha_model.dart';
import '../../services/database_service.dart';
import '../../services/gps_service.dart';
import 'widgets/samu_app_bar_header.dart';
import 'widgets/registro_field_card.dart';
import 'avaliacao_clinica_view.dart';

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
  final TextEditingController _grauParentescoController = TextEditingController();
  final TextEditingController _telefoneController = TextEditingController();
  final TextEditingController _medicamentosController = TextEditingController();
  final TextEditingController _alergiasController = TextEditingController();
  String _sexoSelecionado = 'Masculino';
  String _acompanhanteSelecionado = 'Desconhecido';

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
    if (widget.fichaParcial != null) {
      final f = widget.fichaParcial!;
      if (f.pacienteNome.isNotEmpty && f.pacienteNome != 'Paciente Não Identificado') {
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
        _acompanhanteSelecionado = f.acompanhante!;
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
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _idadeController.dispose();
    _dataNascimentoController.dispose();
    _documentoController.dispose();
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

  /// Busca automática de endereço pelo CEP conectado ao GPS do Google
  Future<void> _buscarEnderecoPorCep(String cep) async {
    final cleanCep = cep.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanCep.length < 8) return;

    setState(() => _isBuscandoCep = true);

    final resultado = await GpsService().buscarEnderecoPorCep(cleanCep);

    if (!mounted) return;
    setState(() => _isBuscandoCep = false);

    if (resultado != null) {
      setState(() {
        if (resultado.logradouro.isNotEmpty) {
          _ruaController.text = resultado.logradouro;
        }
        if (resultado.bairro.isNotEmpty) {
          _bairroController.text = resultado.bairro;
        }
        _cidadeController.text = '${resultado.cidade} - ${resultado.estado}';
        _latitude = resultado.latitude;
        _longitude = resultado.longitude;
      });

      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  "Endereço e GPS localizados: ${resultado.logradouro}, ${resultado.bairro}",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF2E7D32),
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  /// Captura as coordenadas atuais do GPS da viatura
  Future<void> _obterGpsAtual() async {
    setState(() => _isBuscandoCep = true);
    final pos = await GpsService().obterPosicaoAtual();
    if (!mounted) return;
    setState(() {
      _isBuscandoCep = false;
      if (pos != null) {
        _latitude = pos.latitude;
        _longitude = pos.longitude;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Coordenadas GPS capturadas: Lat ${_latitude?.toStringAsFixed(4)}, Long ${_longitude?.toStringAsFixed(4)}",
        ),
        backgroundColor: const Color(0xFFC62828),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _avancarParaAvaliacaoClinica() async {
    setState(() => _isSaving = true);

    final nomeFinal = _nomeController.text.trim().isEmpty
        ? 'Paciente Não Identificado'
        : _nomeController.text.trim();

    final enderecoFormatado =
        "${_ruaController.text.trim()}, ${_numeroController.text.trim()} - ${_bairroController.text.trim()}, ${_cidadeController.text.trim()} (CEP: ${_cepController.text.trim()}) ${_complementoController.text.isNotEmpty ? 'Comp: ${_complementoController.text.trim()}' : ''}";

    final fichaAtualizada = (widget.fichaParcial ??
            FichaAtendimentoModel(
              id: 'fch_${DateTime.now().millisecondsSinceEpoch}',
              numeroOcorrencia:
                  'REG-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
              dataHora: DateTime.now(),
              pacienteNome: nomeFinal,
              tipoOcorrencia: 'Atendimento Pré-Hospitalar',
              endereco: enderecoFormatado.isEmpty ? 'Joinville - SC' : enderecoFormatado,
              unidadeResponsavel: 'USB',
            ))
        .copyWith(
      pacienteNome: nomeFinal,
      pacienteIdade: int.tryParse(_idadeController.text.trim()),
      pacienteDataNascimento: _dataNascimentoController.text.trim().isNotEmpty
          ? _dataNascimentoController.text.trim()
          : null,
      pacienteSexo: _sexoSelecionado,
      pacienteCpf: _documentoController.text.trim().isNotEmpty
          ? _documentoController.text.trim()
          : null,
      acompanhante: _acompanhanteSelecionado,
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
      endereco: enderecoFormatado.isEmpty ? 'Joinville - SC' : enderecoFormatado,
      latitude: _latitude,
      longitude: _longitude,
    );

    await DatabaseService().inserirFicha(fichaAtualizada);

    if (!mounted) return;
    setState(() => _isSaving = false);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AvaliacaoClinicaView(
          fichaParcial: fichaAtualizada,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FB),
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
              constraints: const BoxConstraints(maxWidth: 500),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    RegistroFieldCard(
                      title: "Nome do Paciente",
                      icon: Icons.person_outline_rounded,
                      iconColor: const Color(0xFFE50914),
                      child: TextFormField(
                        controller: _nomeController,
                        style: const TextStyle(fontSize: 14, color: Color(0xFF212121)),
                        decoration: InputDecoration(
                          hintText: "Digite o nome completo do paciente",
                          hintStyle: const TextStyle(color: Color(0xFF9E9E9E), fontSize: 14),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 1.2),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: const BorderSide(color: Color(0xFFE50914), width: 1.8),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Informe o nome do paciente';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        // Idade
                        Expanded(
                          flex: 1,
                          child: RegistroFieldCard(
                            title: "Idade",
                            icon: Icons.cake_outlined,
                            iconColor: const Color(0xFFE50914),
                            child: TextFormField(
                              controller: _idadeController,
                              keyboardType: TextInputType.number,
                              style: const TextStyle(fontSize: 14, color: Color(0xFF212121)),
                              decoration: InputDecoration(
                                hintText: "Ex: 38",
                                hintStyle: const TextStyle(color: Color(0xFF9E9E9E), fontSize: 14),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 1.2),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide: const BorderSide(color: Color(0xFFE50914), width: 1.8),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Data de Nascimento
                        Expanded(
                          flex: 1,
                          child: RegistroFieldCard(
                            title: "Data de Nascimento",
                            icon: Icons.calendar_today_outlined,
                            iconColor: const Color(0xFFE50914),
                            child: TextFormField(
                              controller: _dataNascimentoController,
                              keyboardType: TextInputType.datetime,
                              style: const TextStyle(fontSize: 14, color: Color(0xFF212121)),
                              decoration: InputDecoration(
                                hintText: "DD/MM/AAAA",
                                hintStyle: const TextStyle(color: Color(0xFF9E9E9E), fontSize: 14),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 1.2),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide: const BorderSide(color: Color(0xFFE50914), width: 1.8),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Sexo
                    RegistroFieldCard(
                      title: "Sexo",
                      icon: Icons.wc_rounded,
                      iconColor: const Color(0xFFE50914),
                      child: Container(
                        height: 48,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFE0E0E0), width: 1.2),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _sexoSelecionado,
                            isExpanded: true,
                            items: const [
                              DropdownMenuItem(value: 'Masculino', child: Text('Masculino')),
                              DropdownMenuItem(value: 'Feminino', child: Text('Feminino')),
                            ],
                            onChanged: (val) {
                              if (val != null) {
                                setState(() => _sexoSelecionado = val);
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Documento CPF
                    RegistroFieldCard(
                      title: "CPF do paciente",
                      icon: Icons.badge_outlined,
                      iconColor: const Color(0xFFE50914),
                      child: TextFormField(
                        controller: _documentoController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(fontSize: 14, color: Color(0xFF212121)),
                        decoration: InputDecoration(
                          hintText: "Digite o CPF do paciente",
                          hintStyle: const TextStyle(color: Color(0xFF9E9E9E), fontSize: 14),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 1.2),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: const BorderSide(color: Color(0xFFE50914), width: 1.8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Acompanhante
                    RegistroFieldCard(
                      title: "Acompanhante",
                      icon: Icons.people_outline_rounded,
                      iconColor: const Color(0xFFE50914),
                      child: Container(
                        height: 48,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFE0E0E0), width: 1.2),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _acompanhanteSelecionado,
                            isExpanded: true,
                            icon: const Icon(Icons.arrow_drop_down, color: Color(0xFFE50914)),
                            items: const [
                              DropdownMenuItem(value: 'Pai', child: Text('Pai')),
                              DropdownMenuItem(value: 'Mãe', child: Text('Mãe')),
                              DropdownMenuItem(value: 'Irmão', child: Text('Irmão')),
                              DropdownMenuItem(value: 'Tia/Tio', child: Text('Tia/Tio')),
                              DropdownMenuItem(value: 'Cônjuge', child: Text('Cônjuge')),
                              DropdownMenuItem(value: 'Filho(a)', child: Text('Filho(a)')),
                              DropdownMenuItem(value: 'Conhecido', child: Text('Conhecido')),
                              DropdownMenuItem(value: 'Desconhecido', child: Text('Desconhecido')),
                            ],
                            onChanged: (val) {
                              if (val != null) {
                                setState(() => _acompanhanteSelecionado = val);
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Grau de parentesco
                    RegistroFieldCard(
                      title: "Grau de parentesco",
                      icon: Icons.family_restroom_rounded,
                      iconColor: const Color(0xFFE50914),
                      child: TextFormField(
                        controller: _grauParentescoController,
                        style: const TextStyle(fontSize: 14, color: Color(0xFF212121)),
                        decoration: InputDecoration(
                          hintText: "Ex: Filho(a), Cônjuge, Mãe, Pai",
                          hintStyle: const TextStyle(color: Color(0xFF9E9E9E), fontSize: 14),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 1.2),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: const BorderSide(color: Color(0xFFE50914), width: 1.8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Telefone de Contato
                    RegistroFieldCard(
                      title: "Telefone de Contato",
                      icon: Icons.phone_outlined,
                      iconColor: const Color(0xFFE50914),
                      child: TextFormField(
                        controller: _telefoneController,
                        keyboardType: TextInputType.phone,
                        style: const TextStyle(fontSize: 14, color: Color(0xFF212121)),
                        decoration: InputDecoration(
                          hintText: "Ex: (47) 99999-9999",
                          hintStyle: const TextStyle(color: Color(0xFF9E9E9E), fontSize: 14),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 1.2),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: const BorderSide(color: Color(0xFFE50914), width: 1.8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Medicamentos de uso continuo
                    RegistroFieldCard(
                      title: "Medicamentos de uso continuo",
                      icon: Icons.medication_outlined,
                      iconColor: const Color(0xFFE50914),
                      child: TextFormField(
                        controller: _medicamentosController,
                        maxLines: 2,
                        style: const TextStyle(fontSize: 14, color: Color(0xFF212121)),
                        decoration: InputDecoration(
                          hintText: "Ex: Losartana, Insulina, Metformina...",
                          hintStyle: const TextStyle(color: Color(0xFF9E9E9E), fontSize: 14),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 1.2),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: const BorderSide(color: Color(0xFFE50914), width: 1.8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Alergias
                    RegistroFieldCard(
                      title: "Alergias",
                      icon: Icons.warning_amber_rounded,
                      iconColor: const Color(0xFFE50914),
                      child: TextFormField(
                        controller: _alergiasController,
                        maxLines: 2,
                        style: const TextStyle(fontSize: 14, color: Color(0xFF212121)),
                        decoration: InputDecoration(
                          hintText: "Ex: Dipirona, Penicilina ou Nega alergias conhecidas",
                          hintStyle: const TextStyle(color: Color(0xFF9E9E9E), fontSize: 14),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 1.2),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: const BorderSide(color: Color(0xFFE50914), width: 1.8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ========================================================
                    // SEÇÃO 2: LOCALIZAÇÃO E ENDEREÇO (COM GPS E CEP NO MEIO)
                    // ========================================================
                    Container(
                      padding: const EdgeInsets.all(20.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16.0),
                        border: Border.all(color: const Color(0xFFF0F0F0), width: 1.2),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x0A000000),
                            blurRadius: 16,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Topo Esquerdo: Título "Endereço"
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Row(
                                children: [
                                  Icon(
                                    Icons.location_on_rounded,
                                    color: Color(0xFFE50914),
                                    size: 22,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    "Endereço",
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF2C3437),
                                      letterSpacing: -0.3,
                                    ),
                                  ),
                                ],
                              ),
                              // Botão rápido para capturar GPS
                              TextButton.icon(
                                onPressed: _obterGpsAtual,
                                icon: const Icon(Icons.my_location_rounded, size: 16, color: Color(0xFFE50914)),
                                label: const Text(
                                  "GPS Atual",
                                  style: TextStyle(fontSize: 12, color: Color(0xFFE50914), fontWeight: FontWeight.bold),
                                ),
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // No meio: Campo com nome CEP (conecta com GPS e traz dados automáticos)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Text(
                                    "CEP",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF2C3437),
                                    ),
                                  ),
                                  SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      "(Preenche automaticamente via GPS / Google)",
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Color(0xFF757575),
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _cepController,
                                keyboardType: TextInputType.number,
                                onChanged: (value) {
                                  if (value.replaceAll(RegExp(r'[^0-9]'), '').length == 8) {
                                    _buscarEnderecoPorCep(value);
                                  }
                                },
                                style: const TextStyle(fontSize: 14, color: Color(0xFF212121), fontWeight: FontWeight.w600),
                                decoration: InputDecoration(
                                  hintText: "Digite o CEP (ex: 89201-000)",
                                  hintStyle: const TextStyle(color: Color(0xFF9E9E9E), fontSize: 14, fontWeight: FontWeight.normal),
                                  prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFFE50914), size: 22),
                                  suffixIcon: _isBuscandoCep
                                      ? const Padding(
                                          padding: EdgeInsets.all(12.0),
                                          child: SizedBox(
                                            width: 18,
                                            height: 18,
                                            child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFE50914)),
                                          ),
                                        )
                                      : IconButton(
                                          icon: const Icon(Icons.travel_explore_rounded, color: Color(0xFFE50914)),
                                          tooltip: "Buscar endereço e coordenadas GPS",
                                          onPressed: () => _buscarEnderecoPorCep(_cepController.text),
                                        ),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: const BorderSide(color: Color(0xFFFFCDD2), width: 1.2),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: const BorderSide(color: Color(0xFFE50914), width: 1.8),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Campo: Rua
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Rua",
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF424242),
                                ),
                              ),
                              const SizedBox(height: 6),
                              TextFormField(
                                controller: _ruaController,
                                style: const TextStyle(fontSize: 14, color: Color(0xFF212121)),
                                decoration: InputDecoration(
                                  hintText: "Nome da rua / avenida",
                                  hintStyle: const TextStyle(color: Color(0xFF9E9E9E), fontSize: 14),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 1.2),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: const BorderSide(color: Color(0xFFE50914), width: 1.8),
                                  ),
                                ),
                                validator: (val) {
                                  if (val == null || val.trim().isEmpty) {
                                    return 'Informe a rua do atendimento';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),

                          // Linha: Número e Bairro
                          Row(
                            children: [
                              // Número
                              Expanded(
                                flex: 2,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Número",
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF424242),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    TextFormField(
                                      controller: _numeroController,
                                      style: const TextStyle(fontSize: 14, color: Color(0xFF212121)),
                                      decoration: InputDecoration(
                                        hintText: "Nº",
                                        hintStyle: const TextStyle(color: Color(0xFF9E9E9E), fontSize: 14),
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(10.0),
                                          borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 1.2),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(10.0),
                                          borderSide: const BorderSide(color: Color(0xFFE50914), width: 1.8),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Bairro
                              Expanded(
                                flex: 3,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Bairro",
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF424242),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    TextFormField(
                                      controller: _bairroController,
                                      style: const TextStyle(fontSize: 14, color: Color(0xFF212121)),
                                      decoration: InputDecoration(
                                        hintText: "Nome do bairro",
                                        hintStyle: const TextStyle(color: Color(0xFF9E9E9E), fontSize: 14),
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(10.0),
                                          borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 1.2),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(10.0),
                                          borderSide: const BorderSide(color: Color(0xFFE50914), width: 1.8),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),

                          // Campo: Complemento
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Complemento",
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF424242),
                                ),
                              ),
                              const SizedBox(height: 6),
                              TextFormField(
                                controller: _complementoController,
                                style: const TextStyle(fontSize: 14, color: Color(0xFF212121)),
                                decoration: InputDecoration(
                                  hintText: "Apartamento, bloco, casa, ponto de referência",
                                  hintStyle: const TextStyle(color: Color(0xFF9E9E9E), fontSize: 14),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 1.2),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: const BorderSide(color: Color(0xFFE50914), width: 1.8),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),

                          // Cidade e Estado (informativo)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Cidade / UF",
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF424242),
                                ),
                              ),
                              const SizedBox(height: 6),
                              TextFormField(
                                controller: _cidadeController,
                                style: const TextStyle(fontSize: 14, color: Color(0xFF212121)),
                                decoration: InputDecoration(
                                  hintText: "Joinville - SC",
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 1.2),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: const BorderSide(color: Color(0xFFE50914), width: 1.8),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Botão de Ação: "Continuar"
                    SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _avancarParaAvaliacaoClinica,
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
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Continuar",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Opção de Voltar
                    Center(
                      child: TextButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back, size: 16, color: Color(0xFF757575)),
                        label: const Text(
                          "Voltar ao Registro",
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
}
