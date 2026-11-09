import 'package:flutter/material.dart';
import '../../../models/unidade_model.dart';
import '../../../services/admin_data_service.dart';

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
          padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 22.0),
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 680),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                              Icons.airport_shuttle_outlined,
                              color: Color(0xFFC62828),
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Unidades Móveis (Frota)",
                                style: TextStyle(
                                  fontSize: 21,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF1E1E1E),
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                "Cadastre e monitore as viaturas e ambulâncias disponíveis no SAMU Joinville",
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
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          "${unidades.length} na frota",
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2E7D32),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

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
                                  Icons.local_shipping_outlined,
                                  color: Color(0xFFC62828),
                                  size: 17,
                                ),
                              ),
                              const SizedBox(width: 10),
                              const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Nova Unidade Móvel / Viatura",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1E1E1E),
                                    ),
                                  ),
                                  Text(
                                    "Defina o prefixo operacional, placa, suporte e base de atuação",
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
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildFieldLabel("Código / Prefixo"),
                                    const SizedBox(height: 5),
                                    TextFormField(
                                      controller: _codigoController,
                                      style: const TextStyle(fontSize: 13),
                                      decoration: _inputDecoration("Ex: USA-03, USB-05"),
                                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Informe o código' : null,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildFieldLabel("Placa do Veículo"),
                                    const SizedBox(height: 5),
                                    TextFormField(
                                      controller: _placaController,
                                      style: const TextStyle(fontSize: 13),
                                      decoration: _inputDecoration("BRA-1925"),
                                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Informe a placa' : null,
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
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildFieldLabel("Tipo de Suporte"),
                                    const SizedBox(height: 5),
                                    DropdownButtonFormField<String>(
                                      initialValue: _tipoSelecionado,
                                      isDense: true,
                                      style: const TextStyle(fontSize: 13, color: Color(0xFF212121)),
                                      decoration: _inputDecoration(""),
                                      icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18),
                                      items: _tipos.map((t) {
                                        return DropdownMenuItem(value: t, child: Text(t, style: const TextStyle(fontSize: 13)));
                                      }).toList(),
                                      onChanged: (v) => setState(() => _tipoSelecionado = v!),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildFieldLabel("Região Base"),
                                    const SizedBox(height: 5),
                                    DropdownButtonFormField<String>(
                                      initialValue: _regiaoSelecionada,
                                      isDense: true,
                                      style: const TextStyle(fontSize: 13, color: Color(0xFF212121)),
                                      decoration: _inputDecoration(""),
                                      icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18),
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
                          const SizedBox(height: 18),

                          SizedBox(
                            width: double.infinity,
                            height: 38,
                            child: ElevatedButton.icon(
                              onPressed: _cadastrarUnidade,
                              icon: const Icon(Icons.add_circle_outline_rounded, size: 16),
                              label: const Text(
                                "Cadastrar Unidade Móvel",
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

                  // Lista de Unidades
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
                                Icon(Icons.airport_shuttle, color: Color(0xFFC62828), size: 19),
                                SizedBox(width: 8),
                                Text(
                                  "Unidades Móveis Cadastradas",
                                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E)),
                                ),
                              ],
                            ),
                            Text(
                              "${unidades.length} viatura(s)",
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF9E9E9E),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

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
                            separatorBuilder: (_, __) => const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final uni = unidades[index];
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
                                      child: const Center(
                                        child: Icon(
                                          Icons.airport_shuttle_rounded,
                                          size: 20,
                                          color: Color(0xFFC62828),
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
                                              Text(
                                                uni.codigo,
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFF212121),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFFE8F5E9),
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                                child: Text(
                                                  uni.status,
                                                  style: const TextStyle(
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
                                                  uni.regiao,
                                                  style: const TextStyle(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.w600,
                                                    color: Color(0xFFC62828),
                                                  ),
                                                ),
                                              ),
                                              Text(
                                                "${uni.tipo}  •  Placa: ${uni.placa}",
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
                                      tooltip: "Excluir cadastro",
                                      onPressed: () {
                                        _dataService.removerUnidade(uni.id);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text("${uni.codigo} removida."),
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

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF424242)),
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
