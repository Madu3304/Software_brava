// ============================================================================
// ----------------------------------------------------------------------------
// [SEPARAÇÃO DE TELA] - INÍCIO DA TELA: CADASTRO DE SOCORRISTAS (WEB)
// ----------------------------------------------------------------------------
// ============================================================================

import 'package:flutter/material.dart';
import '../../../models/profissional_model.dart';
import '../../../services/admin_data_service.dart';
import '../../shared/tela_separador_widget.dart';

class CadastroSocorristaScreen extends StatefulWidget {
  const CadastroSocorristaScreen({super.key});

  @override
  State<CadastroSocorristaScreen> createState() => _CadastroSocorristaScreenState();
}

class _CadastroSocorristaScreenState extends State<CadastroSocorristaScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _cpfController = TextEditingController();
  final TextEditingController _cnhController = TextEditingController();
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
    _cnhController.dispose();
    _matriculaController.dispose();
    super.dispose();
  }

  void _cadastrarSocorrista() {
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

      final novoSocorrista = ProfissionalModel.socorrista(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        nome: _nomeController.text.trim(),
        cpf: _cpfController.text.trim(),
        cnh: _cnhController.text.trim().isEmpty ? 'Cat. D' : _cnhController.text.trim(),
        unidade: _selectedUnidade!,
        matricula: _matriculaController.text.trim().isEmpty
            ? 'UN-SOC-${DateTime.now().millisecondsSinceEpoch % 1000}'
            : _matriculaController.text.trim(),
      );

      _dataService.adicionarProfissional(novoSocorrista);

      _nomeController.clear();
      _cpfController.clear();
      _cnhController.clear();
      _matriculaController.clear();
      setState(() {
        _selectedUnidade = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Socorrista / Condutor cadastrado com sucesso!"),
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
        final socorristas = _dataService.socorristas;

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
                  nomeTela: 'Tela 4: Cadastro de Socorristas e Condutores',
                  modulo: 'ADMINISTRADOR / CONDUTORES E SOCORRISTAS',
                  icone: Icons.favorite_border_rounded,
                ),

                const Text(
                  "Cadastro de Socorristas",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E1E1E),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Cadastre novos socorristas condutores e gerencie a escala operacional",
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF757575),
                  ),
                ),
                const SizedBox(height: 24),

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
                        const Row(
                          children: [
                            Icon(
                              Icons.volunteer_activism_outlined,
                              color: Color(0xFFC62828),
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(
                              "Novo Socorrista / Condutor",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E1E1E),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        _buildFieldLabel("Nome Completo"),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _nomeController,
                          decoration: _inputDecoration("Digite o nome completo do socorrista"),
                          validator: (v) => (v == null || v.trim().isEmpty) ? 'Informe o nome' : null,
                        ),
                        const SizedBox(height: 18),

                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildFieldLabel("CPF"),
                                  const SizedBox(height: 6),
                                  TextFormField(
                                    controller: _cpfController,
                                    decoration: _inputDecoration("000.000.000-00"),
                                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Informe o CPF' : null,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildFieldLabel("CNH (Categoria D / E)"),
                                  const SizedBox(height: 6),
                                  TextFormField(
                                    controller: _cnhController,
                                    decoration: _inputDecoration("00000000000 (Cat. D)"),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),

                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildFieldLabel("Unidade Responsável"),
                                  const SizedBox(height: 6),
                                  DropdownButtonFormField<String>(
                                    value: _selectedUnidade,
                                    hint: const Text(
                                      "Selecione a unidade",
                                      style: TextStyle(color: Color(0xFF9E9E9E), fontSize: 13),
                                    ),
                                    decoration: _inputDecoration(""),
                                    icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 20),
                                    items: _unidades.map((u) {
                                      return DropdownMenuItem(value: u, child: Text(u, style: const TextStyle(fontSize: 13)));
                                    }).toList(),
                                    onChanged: (v) => setState(() => _selectedUnidade = v),
                                    validator: (v) => v == null ? 'Selecione a unidade' : null,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildFieldLabel("Matrícula da Unidade"),
                                  const SizedBox(height: 6),
                                  TextFormField(
                                    controller: _matriculaController,
                                    decoration: _inputDecoration("XX-SOC-000"),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        SizedBox(
                          width: double.infinity,
                          height: 44,
                          child: ElevatedButton(
                            onPressed: _cadastrarSocorrista,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFC62828),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                            child: const Text(
                              "Cadastrar Socorrista",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                // Lista de Socorristas Cadastrados
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
                          Icon(Icons.people_outline, color: Color(0xFFC62828), size: 20),
                          SizedBox(width: 8),
                          Text(
                            "Socorristas Cadastrados",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      if (socorristas.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20.0),
                          child: Center(
                            child: Text(
                              "Nenhum socorrista cadastrado.",
                              style: TextStyle(color: Color(0xFF9E9E9E), fontSize: 13),
                            ),
                          ),
                        )
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: socorristas.length,
                          separatorBuilder: (_, __) => const Divider(height: 24, color: Color(0xFFF0F0F0)),
                          itemBuilder: (context, index) {
                            final soc = socorristas[index];
                            return Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        soc.nome,
                                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF212121)),
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
                                              soc.unidade,
                                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFFC62828)),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            "•  CNH: ${soc.cnh}  •  ${soc.matricula}",
                                            style: const TextStyle(fontSize: 12, color: Color(0xFF757575)),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, size: 20, color: Color(0xFF9E9E9E)),
                                  tooltip: "Excluir cadastro",
                                  onPressed: () {
                                    _dataService.removerProfissional(soc.id);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text("${soc.nome} removido."), backgroundColor: const Color(0xFFC62828)),
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

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF424242)),
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
