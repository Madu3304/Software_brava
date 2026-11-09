// ============================================================================
// ----------------------------------------------------------------------------
// [SEPARAÇÃO DE TELA] - INÍCIO DA TELA: CADASTRO DE TÉCNICOS DE ENFERMAGEM (WEB)
// ----------------------------------------------------------------------------
// ============================================================================

import 'package:flutter/material.dart';
import '../../../models/profissional_model.dart';
import '../../../services/admin_data_service.dart';

class CadastroEnfermagemScreen extends StatefulWidget {
  const CadastroEnfermagemScreen({super.key});

  @override
  State<CadastroEnfermagemScreen> createState() => _CadastroEnfermagemScreenState();
}

class _CadastroEnfermagemScreenState extends State<CadastroEnfermagemScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _cpfController = TextEditingController();
  final TextEditingController _corenController = TextEditingController();
  final TextEditingController _matriculaController = TextEditingController();

  String? _selectedUnidade;
  final List<String> _unidades = const [
    'Unidade Norte',
    'Unidade Sul',
    'Unidade Leste',
    'Unidade Oeste',
  ];

  final AdminDataService _dataService = AdminDataService();

  @override
  void dispose() {
    _nomeController.dispose();
    _cpfController.dispose();
    _corenController.dispose();
    _matriculaController.dispose();
    super.dispose();
  }

  void _cadastrarTecnico() {
    if (_formKey.currentState!.validate()) {
      if (_selectedUnidade == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Selecione a unidade responsável"),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final novoTecnico = ProfissionalModel.tecnicoEnfermagem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        nome: _nomeController.text.trim(),
        cpf: _cpfController.text.trim(),
        coren: _corenController.text.trim(),
        unidade: _selectedUnidade!,
        matricula: _matriculaController.text.trim().isEmpty
            ? 'XX-TE-${DateTime.now().millisecondsSinceEpoch % 1000}'
            : _matriculaController.text.trim(),
      );

      _dataService.adicionarProfissional(novoTecnico);

      _nomeController.clear();
      _cpfController.clear();
      _corenController.clear();
      _matriculaController.clear();
      setState(() {
        _selectedUnidade = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Técnico de enfermagem cadastrado com sucesso!"),
          backgroundColor: Color(0xFF2E7D32),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _dataService,
      builder: (context, _) {
        final tecnicos = _dataService.enfermeiros;

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 20.0),
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Cadastro de Técnicos de Enfermagem",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E1E1E),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Cadastre novos técnicos de enfermagem e gerencie os já existentes",
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF757575),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Card Formulário
                  Container(
                    padding: const EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14.0),
                      border: Border.all(color: const Color(0xFFEEEEEE)),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x06000000),
                          blurRadius: 10,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(
                                Icons.healing_outlined,
                                color: Color(0xFFC62828),
                                size: 18,
                              ),
                              SizedBox(width: 8),
                              Text(
                                "Novo Técnico de Enfermagem",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1E1E1E),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          _buildFieldLabel("Nome Completo"),
                          const SizedBox(height: 4),
                          TextFormField(
                            controller: _nomeController,
                            style: const TextStyle(fontSize: 13),
                            decoration: _inputDecoration("Digite o nome completo"),
                            validator: (value) =>
                                (value == null || value.trim().isEmpty)
                                    ? 'Informe o nome completo'
                                    : null,
                          ),
                          const SizedBox(height: 12),

                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildFieldLabel("CPF"),
                                    const SizedBox(height: 4),
                                    TextFormField(
                                      controller: _cpfController,
                                      style: const TextStyle(fontSize: 13),
                                      decoration: _inputDecoration("000.000.000-00"),
                                      validator: (value) =>
                                          (value == null || value.trim().isEmpty)
                                              ? 'Informe o CPF'
                                              : null,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildFieldLabel("COREN"),
                                    const SizedBox(height: 4),
                                    TextFormField(
                                      controller: _corenController,
                                      style: const TextStyle(fontSize: 13),
                                      decoration: _inputDecoration("COREN-XX 000000"),
                                      validator: (value) =>
                                          (value == null || value.trim().isEmpty)
                                              ? 'Informe o COREN'
                                              : null,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildFieldLabel("Unidade Responsável"),
                                    const SizedBox(height: 4),
                                    DropdownButtonFormField<String>(
                                      initialValue: _selectedUnidade,
                                      isDense: true,
                                      style: const TextStyle(fontSize: 13, color: Color(0xFF212121)),
                                      hint: const Text(
                                        "Selecione a unidade",
                                        style: TextStyle(color: Color(0xFF9E9E9E), fontSize: 12),
                                      ),
                                      decoration: _inputDecoration(""),
                                      icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18),
                                      items: _unidades.map((unidade) {
                                        return DropdownMenuItem(
                                          value: unidade,
                                          child: Text(unidade, style: const TextStyle(fontSize: 13)),
                                        );
                                      }).toList(),
                                      onChanged: (val) => setState(() => _selectedUnidade = val),
                                      validator: (value) => value == null ? 'Selecione uma unidade' : null,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildFieldLabel("Matrícula da Unidade"),
                                    const SizedBox(height: 4),
                                    TextFormField(
                                      controller: _matriculaController,
                                      style: const TextStyle(fontSize: 13),
                                      decoration: _inputDecoration("XX-TE-000"),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),

                          SizedBox(
                            width: double.infinity,
                            height: 38,
                            child: ElevatedButton(
                              onPressed: _cadastrarTecnico,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFC62828),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ),
                              child: const Text(
                                "Cadastrar Técnico de Enfermagem",
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),

                  // Lista de Cadastrados
                  Container(
                    padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.0),
                    border: Border.all(color: const Color(0xFFEEEEEE)),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x06000000),
                        blurRadius: 10,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.people_outline,
                            color: Color(0xFFC62828),
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text(
                            "Técnicos de Enfermagem Cadastrados",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E1E1E),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      if (tecnicos.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20.0),
                          child: Center(
                            child: Text(
                              "Nenhum técnico de enfermagem cadastrado.",
                              style: TextStyle(color: Color(0xFF9E9E9E), fontSize: 13),
                            ),
                          ),
                        )
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: tecnicos.length,
                          separatorBuilder: (_, __) => const Divider(height: 24, color: Color(0xFFF0F0F0)),
                          itemBuilder: (context, index) {
                            final tec = tecnicos[index];
                            return Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        tec.nome,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF212121),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Wrap(
                                        crossAxisAlignment: WrapCrossAlignment.center,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFFFEBEE),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              tec.unidade,
                                              style: const TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                                color: Color(0xFFC62828),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            "•  ${tec.coren}  •  ${tec.matricula}",
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Color(0xFF757575),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    size: 20,
                                    color: Color(0xFF9E9E9E),
                                  ),
                                  tooltip: "Excluir cadastro",
                                  onPressed: () {
                                    _dataService.removerProfissional(tec.id);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text("${tec.nome} removido."),
                                        backgroundColor: const Color(0xFFC62828),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            );
                          },
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
        );
      },
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: Color(0xFF424242),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      isDense: true,
      visualDensity: VisualDensity.compact,
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFFBDBDBD), fontSize: 12),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      filled: true,
      fillColor: const Color(0xFFFAFAFA),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(color: Color(0xFFE8E8E8)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(color: Color(0xFFC62828), width: 1.2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(color: Colors.red, width: 1.2),
      ),
    );
  }
}
