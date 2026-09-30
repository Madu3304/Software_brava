// ============================================================================
// VIEW ASSISTENCIAL: REGISTRO DA OCORRÊNCIA / FICHA TÉCNICA (FIGMA IMAGENS 2 & 3)
// Arquivo: lib/views/assistencial/registro_atendimento_view.dart
// ============================================================================

import 'package:flutter/material.dart';
import '../../models/ficha_model.dart';
import '../../services/database_service.dart';
import 'widgets/samu_app_bar_header.dart';
import 'widgets/registro_field_card.dart';

class RegistroAtendimentoView extends StatefulWidget {
  final String? tipoViaturaInicial;
  final String? codigoTriagemInicial;
  final DateTime? dataAtendimentoInicial;

  const RegistroAtendimentoView({
    super.key,
    this.tipoViaturaInicial = 'USB',
    this.codigoTriagemInicial = 'Vermelho',
    this.dataAtendimentoInicial,
  });

  @override
  State<RegistroAtendimentoView> createState() => _RegistroAtendimentoViewState();
}

class _RegistroAtendimentoViewState extends State<RegistroAtendimentoView> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _registroController = TextEditingController();
  final TextEditingController _medicoController = TextEditingController();
  final TextEditingController _tecnicoController = TextEditingController();
  final TextEditingController _condutorController = TextEditingController();
  final TextEditingController _horaAberturaController = TextEditingController();
  final TextEditingController _horaSaidaController = TextEditingController();

  String _baseSelecionada = 'Selecionar Base';
  bool _isSaving = false;

  final List<String> _basesDisponiveis = [
    'Base Central - SAMU Joinville',
    'Base Sul - Itaum',
    'Base Norte - Costa e Silva',
    'Base Leste - Aventureiro',
    'Base Pirabeiraba',
  ];

  final List<String> _medicosDisponiveis = [
    'Dr. Carlos Eduardo - CRM 12345/SC',
    'Dra. Ana Paula Martins - CRM 23456/SC',
    'Dr. Marcos Vinicius - CRM 34567/SC',
    'Dra. Beatriz Santos - CRM 45678/SC',
    'Dr. Roberto Silva - CRM 56789/SC',
    'Dra. Juliana Mendes - CRM 67890/SC',
  ];

  @override
  void initState() {
    super.initState();
    // Preenche com horário atual formatado para abertura e saída
    final agora = DateTime.now();
    final hora = agora.hour.toString().padLeft(2, '0');
    final minuto = agora.minute.toString().padLeft(2, '0');
    _horaAberturaController.text = '$hora:$minuto';

    final minutoSaida = ((agora.minute + 2) % 60).toString().padLeft(2, '0');
    _horaSaidaController.text = '$hora:$minutoSaida';
  }

  @override
  void dispose() {
    _registroController.dispose();
    _medicoController.dispose();
    _tecnicoController.dispose();
    _condutorController.dispose();
    _horaAberturaController.dispose();
    _horaSaidaController.dispose();
    super.dispose();
  }

  Future<void> _selecionarHora(TextEditingController controller) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFE50914),
              onPrimary: Colors.white,
              onSurface: Color(0xFF212121),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final h = picked.hour.toString().padLeft(2, '0');
      final m = picked.minute.toString().padLeft(2, '0');
      setState(() {
        controller.text = '$h:$m';
      });
    }
  }

  void _abrirModalSelecaoBase() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                child: Text(
                  "Selecione a Base Operacional",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3437),
                  ),
                ),
              ),
              const Divider(),
              ..._basesDisponiveis.map((base) {
                final bool isSelected = _baseSelecionada == base;
                return ListTile(
                  leading: Icon(
                    Icons.location_on_rounded,
                    color: isSelected ? const Color(0xFFE50914) : Colors.grey,
                  ),
                  title: Text(
                    base,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? const Color(0xFFE50914) : Colors.black87,
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle_rounded, color: Color(0xFFE50914))
                      : null,
                  onTap: () {
                    setState(() {
                      _baseSelecionada = base;
                    });
                    Navigator.pop(ctx);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  void _mostrarMensagemEstrela() {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.star_rounded, color: Color(0xFFFFD54F), size: 22),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                "Hora da saída da unidade móvel da base",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFFC62828),
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Future<void> _salvarRegistro() async {
    if (_formKey.currentState!.validate()) {
      if (_baseSelecionada == 'Selecionar Base') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Por favor, selecione a Base Operacional."),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      setState(() => _isSaving = true);

      final novaFicha = FichaAtendimentoModel(
        id: 'fch_${DateTime.now().millisecondsSinceEpoch}',
        numeroOcorrencia: _registroController.text.trim(),
        dataHora: widget.dataAtendimentoInicial ?? DateTime.now(),
        pacienteNome: 'Paciente Ocorrência ${_registroController.text}',
        tipoOcorrencia: 'Atendimento Pré-Hospitalar',
        endereco: _baseSelecionada,
        unidadeResponsavel: widget.tipoViaturaInicial ?? 'USB',
        tipoViatura: widget.tipoViaturaInicial ?? 'USB',
        codigoTriagem: widget.codigoTriagemInicial ?? 'Vermelho',
        base: _baseSelecionada,
        medicoResponsavel: _medicoController.text.trim(),
        tecnicoResponsavel: _tecnicoController.text.trim(),
        condutorSocorrista: _condutorController.text.trim(),
        horaAberturaChamado: _horaAberturaController.text.trim(),
        horaSaidaBase: _horaSaidaController.text.trim(),
      );

      // Persiste no SQLite local
      await DatabaseService().inserirFicha(novaFicha);

      if (!mounted) return;
      setState(() => _isSaving = false);

      // Redireciona para o comprovante de impressão / sucesso
      Navigator.pushReplacementNamed(
        context,
        '/impressao-sucesso',
        arguments: _registroController.text.trim(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FB),
      appBar: SamuAppBarHeader(
        title: "Registro",
        showSamuLogo: true,
        showAmbulanceWatermark: true,
        onBack: () => Navigator.pop(context),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Card 1: Número de Registro
                    RegistroFieldCard(
                      title: "Número de Registro",
                      icon: Icons.description_outlined,
                      iconColor: const Color(0xFFE50914),
                      child: TextFormField(
                        controller: _registroController,
                        style: const TextStyle(fontSize: 14, color: Color(0xFF212121)),
                        decoration: InputDecoration(
                          hintText: "Digite o número de registro",
                          hintStyle: const TextStyle(color: Color(0xFF9E9E9E), fontSize: 14),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: const BorderSide(color: Color(0xFFFFCDD2), width: 1.2),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: const BorderSide(color: Color(0xFFE50914), width: 1.8),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: const BorderSide(color: Colors.red),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Informe o número de registro da ocorrência';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Card 2: Base (com botão laranja de seleção)
                    RegistroFieldCard(
                      title: "Base",
                      icon: Icons.storage_rounded,
                      iconColor: const Color(0xFFFF6D00),
                      child: SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _abrirModalSelecaoBase,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF7A00),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _baseSelecionada,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const Icon(
                                Icons.keyboard_arrow_down_rounded,
                                color: Colors.white,
                                size: 24,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Card 3: Médico responsável (Substitui o antigo campo de data, com busca e seleção de médicos)
                    RegistroFieldCard(
                      title: "Médico responsável:",
                      icon: Icons.medical_services_outlined,
                      iconColor: const Color(0xFFE50914),
                      child: Autocomplete<String>(
                        initialValue: TextEditingValue(text: _medicoController.text),
                        optionsBuilder: (TextEditingValue textEditingValue) {
                          if (textEditingValue.text.isEmpty) {
                            return _medicosDisponiveis;
                          }
                          return _medicosDisponiveis.where((String medico) {
                            return medico.toLowerCase().contains(
                                  textEditingValue.text.toLowerCase(),
                                );
                          });
                        },
                        onSelected: (String selecao) {
                          _medicoController.text = selecao;
                        },
                        fieldViewBuilder: (context, fieldTextEditingController, focusNode, onFieldSubmitted) {
                          // Mantém sincronizado com o controller da tela
                          fieldTextEditingController.addListener(() {
                            _medicoController.text = fieldTextEditingController.text;
                          });

                          return TextFormField(
                            controller: fieldTextEditingController,
                            focusNode: focusNode,
                            style: const TextStyle(fontSize: 14, color: Color(0xFF212121)),
                            decoration: InputDecoration(
                              hintText: "Buscar médico responsável",
                              hintStyle: const TextStyle(color: Color(0xFF9E9E9E), fontSize: 14),
                              prefixIcon: const Icon(
                                Icons.search_rounded,
                                color: Color(0xFFE50914),
                                size: 20,
                              ),
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
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Card 4: Técnico de enfermagem responsável
                    RegistroFieldCard(
                      title: "Técnico de enfermagem responsável:",
                      child: TextFormField(
                        controller: _tecnicoController,
                        style: const TextStyle(fontSize: 14, color: Color(0xFF212121)),
                        decoration: InputDecoration(
                          hintText: "Buscar técnico de enfermagem",
                          hintStyle: const TextStyle(color: Color(0xFF9E9E9E), fontSize: 14),
                          prefixIcon: const Icon(
                            Icons.search_rounded,
                            color: Color(0xFF9E9E9E),
                            size: 20,
                          ),
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

                    // Card 5: Condutor socorrista
                    RegistroFieldCard(
                      title: "Condutor socorrista:",
                      child: TextFormField(
                        controller: _condutorController,
                        style: const TextStyle(fontSize: 14, color: Color(0xFF212121)),
                        decoration: InputDecoration(
                          hintText: "Buscar condutor socorrista",
                          hintStyle: const TextStyle(color: Color(0xFF9E9E9E), fontSize: 14),
                          prefixIcon: const Icon(
                            Icons.search_rounded,
                            color: Color(0xFF9E9E9E),
                            size: 20,
                          ),
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

                    // Card 6: Hora da abertura do chamado
                    RegistroFieldCard(
                      title: "Hora da abertura do chamado",
                      icon: Icons.access_time_rounded,
                      iconColor: const Color(0xFFE50914),
                      child: TextFormField(
                        controller: _horaAberturaController,
                        style: const TextStyle(fontSize: 14, color: Color(0xFF212121)),
                        decoration: InputDecoration(
                          hintText: "hh:mm",
                          hintStyle: const TextStyle(color: Color(0xFF9E9E9E), fontSize: 14),
                          suffixIcon: IconButton(
                            icon: const Icon(
                              Icons.schedule_rounded,
                              color: Color(0xFFE50914),
                              size: 22,
                            ),
                            tooltip: "Selecionar Horário",
                            onPressed: () => _selecionarHora(_horaAberturaController),
                          ),
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

                    // Card 7: Hora da saída da unidade da base (com estrela interativa)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 18.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16.0),
                        border: Border.all(color: const Color(0xFFF0F0F0), width: 1.2),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x0A000000),
                            blurRadius: 14,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.departure_board_rounded,
                                size: 20,
                                color: Color(0xFFE50914),
                              ),
                              const SizedBox(width: 8),
                              const Expanded(
                                child: Text(
                                  "Hora da saída da unidade da base",
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF2C3437),
                                    letterSpacing: -0.2,
                                  ),
                                ),
                              ),
                              // Estrela que ao clicar em cima mostra a mensagem solicitada
                              Tooltip(
                                message: "Clique para ver a descrição",
                                child: InkWell(
                                  onTap: _mostrarMensagemEstrela,
                                  borderRadius: BorderRadius.circular(20),
                                  child: const Padding(
                                    padding: EdgeInsets.all(4.0),
                                    child: Icon(
                                      Icons.star_rounded,
                                      color: Color(0xFFFFB300), // Dourado
                                      size: 26,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _horaSaidaController,
                            style: const TextStyle(fontSize: 14, color: Color(0xFF212121)),
                            decoration: InputDecoration(
                              hintText: "hh:mm",
                              hintStyle: const TextStyle(color: Color(0xFF9E9E9E), fontSize: 14),
                              suffixIcon: IconButton(
                                icon: const Icon(
                                  Icons.schedule_rounded,
                                  color: Color(0xFFE50914),
                                  size: 22,
                                ),
                                tooltip: "Selecionar Horário",
                                onPressed: () => _selecionarHora(_horaSaidaController),
                              ),
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
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Botão de Ação: "Finalizar Cadastro"
                    SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _salvarRegistro,
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
                                  Icon(Icons.check_circle_outline_rounded, color: Colors.white, size: 22),
                                  SizedBox(width: 10),
                                  Text(
                                    "Finalizar Cadastro",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Opção alternativa de Continuar
                    SizedBox(
                      height: 48,
                      child: TextButton(
                        onPressed: _isSaving ? null : _salvarRegistro,
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFFFF5722),
                        ),
                        child: const Text(
                          "Continuar preenchimento assistencial",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
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
