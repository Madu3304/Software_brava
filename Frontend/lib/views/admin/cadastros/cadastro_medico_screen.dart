// ============================================================================
// ----------------------------------------------------------------------------
// [SEPARAÇÃO DE TELA] - INÍCIO DA TELA: CADASTRO DE MÉDICOS (WEB)
// ----------------------------------------------------------------------------
// ============================================================================

import 'package:flutter/material.dart';
import '../../../models/profissional_model.dart';
import '../../../services/admin_data_service.dart';
import '../../shared/tela_separador_widget.dart';

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

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _dataService,
      builder: (context, _) {
        final medicos = _dataService.medicos;

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 820),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ============================================================
                // SEPARADOR EXPLÍCITO INDICANDO O INÍCIO DESTA TELA
                // ============================================================
                const TelaSeparadorWidget(
                  nomeTela: 'Tela 3: Cadastro de Médicos',
                  modulo: 'ADMINISTRADOR / CORPO CLÍNICO',
                  icone: Icons.person_add_alt_1_outlined,
                ),

                const Text(
                  "Cadastro de Médicos",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E1E1E),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Cadastre novos médicos e gerencie os já existentes",
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF757575),
                  ),
                ),
                const SizedBox(height: 24),

                // Card Formulário
                Container(
                  padding: const EdgeInsets.all(28.0),
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
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFEBEE),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.person_add_outlined,
                                color: Color(0xFFC62828),
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Cadastrar Novo Médico",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1E1E1E),
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  "Preencha os dados abaixo para cadastrar um novo médico",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF757575),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        _buildFieldLabelWithIcon(Icons.person_outline, "Nome Completo"),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _nomeController,
                          decoration: _inputDecoration("Digite o nome completo do médico"),
                          validator: (value) =>
                              (value == null || value.trim().isEmpty)
                                  ? 'Informe o nome completo'
                                  : null,
                        ),
                        const SizedBox(height: 18),

                        _buildFieldLabelWithIcon(Icons.badge_outlined, "Documento (CPF)"),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _cpfController,
                          decoration: _inputDecoration("000.000.000-00"),
                          validator: (value) =>
                              (value == null || value.trim().isEmpty)
                                  ? 'Informe o documento CPF'
                                  : null,
                        ),
                        const SizedBox(height: 18),

                        _buildFieldLabelWithIcon(Icons.domain_outlined, "Unidade Responsável"),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<String>(
                          value: _selectedUnidade,
                          hint: const Text(
                            "Selecione a unidade",
                            style: TextStyle(color: Color(0xFF9E9E9E), fontSize: 13),
                          ),
                          decoration: _inputDecoration(""),
                          icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 20),
                          items: _unidades.map((unidade) {
                            return DropdownMenuItem(
                              value: unidade,
                              child: Text(unidade, style: const TextStyle(fontSize: 13)),
                            );
                          }).toList(),
                          onChanged: (val) => setState(() => _selectedUnidade = val),
                          validator: (value) => value == null ? 'Selecione uma unidade' : null,
                        ),
                        const SizedBox(height: 18),

                        _buildFieldLabelWithIcon(Icons.tag_rounded, "# Matrícula da Unidade"),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _matriculaController,
                          decoration: _inputDecoration("Ex: UN-001"),
                        ),
                        const SizedBox(height: 24),

                        SizedBox(
                          width: double.infinity,
                          height: 44,
                          child: ElevatedButton.icon(
                            onPressed: _cadastrarMedico,
                            icon: const Icon(Icons.person_add_alt_1, size: 18),
                            label: const Text(
                              "Cadastrar Médico",
                              style: TextStyle(
                                fontSize: 14,
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
                const SizedBox(height: 28),

                // Lista de Cadastrados
                Container(
                  padding: const EdgeInsets.all(28.0),
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
                            "Médicos Cadastrados",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E1E1E),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

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
                          separatorBuilder: (_, __) => const Divider(height: 24, color: Color(0xFFF0F0F0)),
                          itemBuilder: (context, index) {
                            final med = medicos[index];
                            return Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        med.nome,
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
                                              med.unidade,
                                              style: const TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                                color: Color(0xFFC62828),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            "•  ${med.crm}  •  ${med.matricula}",
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
                            );
                          },
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFieldLabelWithIcon(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 14, color: const Color(0xFF757575)),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF424242),
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFFBDBDBD), fontSize: 13),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
