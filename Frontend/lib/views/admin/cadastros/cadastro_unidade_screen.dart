// ============================================================================
// ----------------------------------------------------------------------------
// [SEPARAÇÃO DE TELA] - INÍCIO DA TELA: CADASTRO DE UNIDADES MÓVEIS (WEB)
// ----------------------------------------------------------------------------
// ============================================================================

import 'package:flutter/material.dart';
import '../../../models/unidade_model.dart';
import '../../../services/admin_data_service.dart';
import '../../shared/tela_separador_widget.dart';

class CadastroUnidadeScreen extends StatefulWidget {
  const CadastroUnidadeScreen({super.key});

  @override
  State<CadastroUnidadeScreen> createState() => _CadastroUnidadeScreenState();
}

class _CadastroUnidadeScreenState extends State<CadastroUnidadeScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _codigoController = TextEditingController();
  final TextEditingController _placaController = TextEditingController();

  String _tipoSelecionado = 'USA (Suporte Avançado)';
  final List<String> _tipos = const [
    'USA (Suporte Avançado)',
    'USB (Suporte Básico)',
    'VIR (Veículo Intervenção Rápida)',
  ];

  String _regiaoSelecionada = 'Unidade Norte';
  final List<String> _regioes = const [
    'Unidade Norte',
    'Unidade Sul',
    'Unidade Leste',
    'Unidade Oeste',
  ];

  final AdminDataService _dataService = AdminDataService();

  @override
  void dispose() {
    _codigoController.dispose();
    _placaController.dispose();
    super.dispose();
  }

  void _cadastrarUnidade() {
    if (_formKey.currentState!.validate()) {
      final novaUnidade = UnidadeMovelModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        codigo: _codigoController.text.trim().toUpperCase(),
        placa: _placaController.text.trim().toUpperCase(),
        tipo: _tipoSelecionado,
        regiao: _regiaoSelecionada,
        status: 'Operacional',
      );

      _dataService.adicionarUnidade(novaUnidade);

      _codigoController.clear();
      _placaController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Unidade móvel (ambulância) cadastrada com sucesso!"),
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
        final unidades = _dataService.unidades;

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
                  nomeTela: 'Tela 5: Cadastro de Unidades Móveis (Frota SAMU)',
                  modulo: 'ADMINISTRADOR / GESTÃO DA FROTA',
                  icone: Icons.airport_shuttle_outlined,
                ),

                const Text(
                  "Cadastro de Unidades Móveis",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E1E1E),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Cadastre e monitore as viaturas e ambulâncias disponíveis no SAMU Joinville",
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
                              Icons.local_shipping_outlined,
                              color: Color(0xFFC62828),
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(
                              "Nova Unidade Móvel / Viatura",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E1E1E),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildFieldLabel("Código / Prefixo"),
                                  const SizedBox(height: 6),
                                  TextFormField(
                                    controller: _codigoController,
                                    decoration: _inputDecoration("Ex: USA-03, USB-05"),
                                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Informe o código' : null,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildFieldLabel("Placa do Veículo"),
                                  const SizedBox(height: 6),
                                  TextFormField(
                                    controller: _placaController,
                                    decoration: _inputDecoration("BRA-1925"),
                                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Informe a placa' : null,
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
                                  _buildFieldLabel("Tipo de Suporte"),
                                  const SizedBox(height: 6),
                                  DropdownButtonFormField<String>(
                                    value: _tipoSelecionado,
                                    decoration: _inputDecoration(""),
                                    items: _tipos.map((t) {
                                      return DropdownMenuItem(value: t, child: Text(t, style: const TextStyle(fontSize: 13)));
                                    }).toList(),
                                    onChanged: (v) => setState(() => _tipoSelecionado = v!),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildFieldLabel("Região Base"),
                                  const SizedBox(height: 6),
                                  DropdownButtonFormField<String>(
                                    value: _regiaoSelecionada,
                                    decoration: _inputDecoration(""),
                                    items: _regioes.map((r) {
                                      return DropdownMenuItem(value: r, child: Text(r, style: const TextStyle(fontSize: 13)));
                                    }).toList(),
                                    onChanged: (v) => setState(() => _regiaoSelecionada = v!),
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
                            onPressed: _cadastrarUnidade,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFC62828),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                            child: const Text(
                              "Cadastrar Unidade Móvel",
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

                // Lista de Unidades
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
                          Icon(Icons.airport_shuttle, color: Color(0xFFC62828), size: 20),
                          SizedBox(width: 8),
                          Text(
                            "Unidades Móveis Cadastradas",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      if (unidades.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20.0),
                          child: Center(
                            child: Text(
                              "Nenhuma unidade cadastrada.",
                              style: TextStyle(color: Color(0xFF9E9E9E), fontSize: 13),
                            ),
                          ),
                        )
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: unidades.length,
                          separatorBuilder: (_, __) => const Divider(height: 24, color: Color(0xFFF0F0F0)),
                          itemBuilder: (context, index) {
                            final uni = unidades[index];
                            return Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            uni.codigo,
                                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF212121)),
                                          ),
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFE8F5E9),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              uni.status,
                                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32)),
                                            ),
                                          ),
                                        ],
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
                                              uni.regiao,
                                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFFC62828)),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            "•  ${uni.tipo}  •  Placa: ${uni.placa}",
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
                                    _dataService.removerUnidade(uni.id);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text("${uni.codigo} removida."), backgroundColor: const Color(0xFFC62828)),
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
