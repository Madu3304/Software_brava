import 'package:flutter/material.dart';
import '../../../models/profissional_model.dart';
import '../../../services/admin_data_service.dart';

class CadastroMedicoScreen extends StatefulWidget {
  const CadastroMedicoScreen({super.key});

  @override
  State<CadastroMedicoScreen> createState() => _CadastroMedicoScreenState();
}

class _CadastroMedicoScreenState extends State<CadastroMedicoScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _cpfController = TextEditingController();
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
    _matriculaController.dispose();
    super.dispose();
  }

  void _cadastrarMedico() {
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

      final novoMedico = ProfissionalModel.medico(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        nome: _nomeController.text.trim(),
        cpf: _cpfController.text.trim(),
        crm: 'CRM-SC ${(10000 + (DateTime.now().millisecondsSinceEpoch % 89999))}',
        unidade: _selectedUnidade!,
        matricula: _matriculaController.text.trim().isEmpty
            ? 'UN-${DateTime.now().millisecondsSinceEpoch % 1000}'
            : _matriculaController.text.trim(),
      );

      _dataService.adicionarProfissional(novoMedico);

      _nomeController.clear();
      _cpfController.clear();
      _matriculaController.clear();
      setState(() {
        _selectedUnidade = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Médico cadastrado com sucesso!"),
          backgroundColor: Color(0xFF2E7D32),
        ),
      );
    }
  }

  String _iniciais(String nome) {
    final parts = nome
        .replaceAll(RegExp(r'Dr\.?\s*|Dra\.?\s*', caseSensitive: false), '')
        .trim()
        .split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return 'MD';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _dataService,
      builder: (context, _) {
        final medicos = _dataService.medicos;

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 22.0),
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 680),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Cabeçalho da Página
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFEBEE),
                              borderRadius: BorderRadius.circular(11),
                            ),
                            child: const Icon(
                              Icons.medical_information_outlined,
                              color: Color(0xFFC62828),
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Cadastro de Médicos",
                                style: TextStyle(
                                  fontSize: 21,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF1E1E1E),
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                "Cadastre novos médicos reguladores/intervencionistas e gerencie a equipe",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF757575),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFEBEE),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          "${medicos.length} ativo(s)",
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFC62828),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // Card Formulário
                  Container(
                    padding: const EdgeInsets.all(22.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14.0),
                      border: Border.all(color: const Color(0xFFEEEEEE)),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x08000000),
                          blurRadius: 12,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(7),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFEBEE),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.person_add_outlined,
                                  color: Color(0xFFC62828),
                                  size: 17,
                                ),
                              ),
                              const SizedBox(width: 10),
                              const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Cadastrar Novo Médico",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1E1E1E),
                                    ),
                                  ),
                                  Text(
                                    "Preencha os campos abaixo para habilitar o profissional",
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFF757575),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const Divider(height: 24, color: Color(0xFFF2F2F2)),

                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 3,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildFieldLabelWithIcon(Icons.person_outline, "Nome Completo"),
                                    const SizedBox(height: 5),
                                    TextFormField(
                                      controller: _nomeController,
                                      style: const TextStyle(fontSize: 13),
                                      decoration: _inputDecoration("Ex: Dr. Carlos Alberto"),
                                      validator: (value) =>
                                          (value == null || value.trim().isEmpty)
                                              ? 'Informe o nome completo'
                                              : null,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                flex: 2,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildFieldLabelWithIcon(Icons.badge_outlined, "Documento (CPF)"),
                                    const SizedBox(height: 5),
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
                            ],
                          ),
                          const SizedBox(height: 14),

                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 3,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildFieldLabelWithIcon(Icons.domain_outlined, "Unidade Responsável"),
                                    const SizedBox(height: 5),
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
                              const SizedBox(width: 14),
                              Expanded(
                                flex: 2,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildFieldLabelWithIcon(Icons.tag_rounded, "Matrícula da Unidade"),
                                    const SizedBox(height: 5),
                                    TextFormField(
                                      controller: _matriculaController,
                                      style: const TextStyle(fontSize: 13),
                                      decoration: _inputDecoration("Ex: UN-001"),
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
                            child: ElevatedButton.icon(
                              onPressed: _cadastrarMedico,
                              icon: const Icon(Icons.person_add_alt_1, size: 16),
                              label: const Text(
                                "Cadastrar Médico",
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFC62828),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Lista de Cadastrados
                  Container(
                    padding: const EdgeInsets.all(22.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14.0),
                      border: Border.all(color: const Color(0xFFEEEEEE)),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x08000000),
                          blurRadius: 12,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Row(
                              children: [
                                Icon(
                                  Icons.people_outline,
                                  color: Color(0xFFC62828),
                                  size: 19,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  "Médicos Cadastrados",
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1E1E1E),
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              "${medicos.length} registro(s)",
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF9E9E9E),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        if (medicos.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 20.0),
                            child: Center(
                              child: Text(
                                "Nenhum médico cadastrado.",
                                style: TextStyle(color: Color(0xFF9E9E9E), fontSize: 13),
                              ),
                            ),
                          )
                        else
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: medicos.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final med = medicos[index];
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFAFAFA),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: const Color(0xFFEEEEEE)),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 38,
                                      height: 38,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFFEBEE),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Center(
                                        child: Text(
                                          _iniciais(med.nome),
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFFC62828),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Flexible(
                                                child: Text(
                                                  med.nome,
                                                  style: const TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w700,
                                                    color: Color(0xFF212121),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFFE8F5E9),
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                                child: const Text(
                                                  "Ativo",
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                    color: Color(0xFF2E7D32),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Wrap(
                                            crossAxisAlignment: WrapCrossAlignment.center,
                                            spacing: 8,
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFFFFEBEE),
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                                child: Text(
                                                  med.unidade,
                                                  style: const TextStyle(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.w600,
                                                    color: Color(0xFFC62828),
                                                  ),
                                                ),
                                              ),
                                              Text(
                                                "${med.crm}  •  Matrícula: ${med.matricula}",
                                                style: const TextStyle(
                                                  fontSize: 11,
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
                                        Icons.delete_outline_rounded,
                                        size: 19,
                                        color: Color(0xFF9E9E9E),
                                      ),
                                      tooltip: "Excluir médico",
                                      onPressed: () {
                                        _dataService.removerProfissional(med.id);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text("${med.nome} removido."),
                                            backgroundColor: const Color(0xFFC62828),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
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

  Widget _buildFieldLabelWithIcon(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 13, color: const Color(0xFF757575)),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF424242),
          ),
        ),
      ],
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
