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

  const RegistroAtendimentoView({
    super.key,
    this.tipoViaturaInicial = 'USB',
    this.codigoTriagemInicial = 'Vermelho',
  });

  @override
  State<RegistroAtendimentoView> createState() => _RegistroAtendimentoViewState();
}

class _RegistroAtendimentoViewState extends State<RegistroAtendimentoView> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _registroController = TextEditingController();
  final TextEditingController _dataController = TextEditingController();
  final TextEditingController _tecnicoController = TextEditingController();
  final TextEditingController _condutorController = TextEditingController();

  String _baseSelecionada = 'Selecionar Base';
  bool _isSaving = false;

  final List<String> _basesDisponiveis = [
    'Base Central - SAMU Joinville',
    'Base Sul - Itaum',
    'Base Norte - Costa e Silva',
    'Base Leste - Aventureiro',
    'Base Pirabeiraba',
  ];

  @override
  void initState() {
    super.initState();
    // Preenche com a data atual formatada
    final agora = DateTime.now();
    final dia = agora.day.toString().padLeft(2, '0');
    final mes = agora.month.toString().padLeft(2, '0');
    final ano = agora.year;
    _dataController.text = '$dia/$mes/$ano';
  }

  @override
  void dispose() {
    _registroController.dispose();
    _dataController.dispose();
    _tecnicoController.dispose();
    _condutorController.dispose();
    super.dispose();
  }

  Future<void> _selecionarData() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
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
      final dia = picked.day.toString().padLeft(2, '0');
      final mes = picked.month.toString().padLeft(2, '0');
      final ano = picked.year;
      setState(() {
        _dataController.text = '$dia/$mes/$ano';
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
        dataHora: DateTime.now(),
        pacienteNome: 'Paciente Ocorrência ${_registroController.text}',
        tipoOcorrencia: 'Atendimento Pré-Hospitalar',
        endereco: _baseSelecionada,
        unidadeResponsavel: widget.tipoViaturaInicial ?? 'USB',
        tipoViatura: widget.tipoViaturaInicial ?? 'USB',
        codigoTriagem: widget.codigoTriagemInicial ?? 'Vermelho',
        base: _baseSelecionada,
        tecnicoResponsavel: _tecnicoController.text.trim(),
        condutorSocorrista: _condutorController.text.trim(),
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
                    // Card 1: Número de Registro (com ícone vermelho de documento)
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

                    // Card 2: Base (com ícone laranja de banco/servidor e botão de seleção)
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
                            backgroundColor: const Color(0xFFFF7A00), // Laranja vibrante do Figma
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

                    // Card 3: Data (com ícone de calendário vermelho e seletor)
                    RegistroFieldCard(
                      title: "Data",
                      icon: Icons.calendar_today_outlined,
                      iconColor: const Color(0xFFE50914),
                      child: TextFormField(
                        controller: _dataController,
                        readOnly: true,
                        onTap: _selecionarData,
                        style: const TextStyle(fontSize: 14, color: Color(0xFF212121)),
                        decoration: InputDecoration(
                          hintText: "dd/mm/aaaa",
                          hintStyle: const TextStyle(color: Color(0xFF9E9E9E), fontSize: 14),
                          suffixIcon: IconButton(
                            icon: const Icon(
                              Icons.calendar_month_outlined,
                              color: Color(0xFFE50914),
                              size: 22,
                            ),
                            onPressed: _selecionarData,
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
                    ),
                    const SizedBox(height: 16),

                    // Card 4: Técnico de enfermagem responsável (Figma Imagem 2)
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

                    // Card 5: Condutor socorrista (Figma Imagem 2)
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
                    const SizedBox(height: 28),

                    // Botão de Ação: "Finalizar Cadastro" (com ícone de check conforme Imagem 3)
                    SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _salvarRegistro,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFC62828), // Vermelho escuro do Figma Imagem 3
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

                    // Opção alternativa de Continuar (Laranja do Figma Imagem 2)
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
