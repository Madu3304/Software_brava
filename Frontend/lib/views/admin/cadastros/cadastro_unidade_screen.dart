import 'package:flutter/material.dart';
import '../../../models/unidade_model.dart';
import '../../../services/admin_data_service.dart';

class CadastroUnidadeScreen extends StatefulWidget {
  const CadastroUnidadeScreen({super.key});

  @override
  State<CadastroUnidadeScreen> createState() => _CadastroUnidadeScreenState();
}

class _CadastroUnidadeScreenState extends State<CadastroUnidadeScreen> {
  final AdminDataService _dataService = AdminDataService();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _topSearchController = TextEditingController();

  String _selectedStatusFilter = 'Todos';
  int _currentPage = 1;
  static const int _itemsPerPage = 10;

  final List<String> _tiposDisponiveis = const [
    'USA (Suporte Avançado)',
    'USB (Suporte Básico)',
    'VIR (Veículo Intervenção Rápida)',
  ];

  final List<String> _regioesDisponiveis = const [
    'SAMU Centro',
    'SAMU Norte',
    'SAMU Sul',
    'SAMU Leste',
    'SAMU Oeste',
  ];

  final List<String> _statusDisponiveis = const [
    'Operacional',
    'Em Atendimento',
    'Em Manutenção',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    _topSearchController.dispose();
    super.dispose();
  }

  void _showAdicionarUnidadeModal() {
    final formKey = GlobalKey<FormState>();
    final codigoCtrl = TextEditingController();
    final placaCtrl = TextEditingController();

    String selectedTipo = _tiposDisponiveis.first;
    String selectedRegiao = _regioesDisponiveis.first;
    String selectedStatus = 'Operacional';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return Dialog(
              backgroundColor: Colors.white,
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 540),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: SingleChildScrollView(
                    child: Form(
                      key: formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 38,
                                    height: 38,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFFEBEE),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(
                                      Icons.airport_shuttle_outlined,
                                      color: Color(0xFFC62828),
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  const Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Adicionar Unidade Móvel",
                                        style: TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF1E1E1E),
                                        ),
                                      ),
                                      SizedBox(height: 2),
                                      Text(
                                        "Cadastre uma nova ambulância ou viatura",
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF757575),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              IconButton(
                                icon: const Icon(Icons.close, size: 20, color: Color(0xFF9E9E9E)),
                                onPressed: () => Navigator.of(ctx).pop(),
                                splashRadius: 20,
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          const Divider(height: 1, color: Color(0xFFF0F0F0)),
                          const SizedBox(height: 18),

                          Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildInputLabel("Código / Prefixo *"),
                                    const SizedBox(height: 6),
                                    TextFormField(
                                      controller: codigoCtrl,
                                      style: const TextStyle(fontSize: 13),
                                      textCapitalization: TextCapitalization.characters,
                                      decoration: _modalInputDecoration(
                                        hint: "Ex: USA-01",
                                        icon: Icons.tag,
                                      ),
                                      validator: (v) =>
                                          (v == null || v.trim().isEmpty) ? "Informe o prefixo" : null,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                flex: 2,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildInputLabel("Placa do Veículo *"),
                                    const SizedBox(height: 6),
                                    TextFormField(
                                      controller: placaCtrl,
                                      style: const TextStyle(fontSize: 13),
                                      textCapitalization: TextCapitalization.characters,
                                      decoration: _modalInputDecoration(
                                        hint: "Ex: BRA-1921",
                                        icon: Icons.directions_car_outlined,
                                      ),
                                      validator: (v) =>
                                          (v == null || v.trim().isEmpty) ? "Informe a placa" : null,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),

                          _buildInputLabel("Tipo de Suporte *"),
                          const SizedBox(height: 6),
                          DropdownButtonFormField<String>(
                            value: selectedTipo,
                            isDense: true,
                            style: const TextStyle(fontSize: 13, color: Color(0xFF1E1E1E)),
                            decoration: _modalInputDecoration(
                              hint: "",
                              icon: Icons.emergency_outlined,
                            ),
                            items: _tiposDisponiveis.map((t) {
                              return DropdownMenuItem(value: t, child: Text(t));
                            }).toList(),
                            onChanged: (v) {
                              if (v != null) {
                                setDialogState(() => selectedTipo = v);
                              }
                            },
                          ),
                          const SizedBox(height: 14),

                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildInputLabel("Base / Região"),
                                    const SizedBox(height: 6),
                                    DropdownButtonFormField<String>(
                                      value: selectedRegiao,
                                      isDense: true,
                                      style: const TextStyle(fontSize: 13, color: Color(0xFF1E1E1E)),
                                      decoration: _modalInputDecoration(
                                        hint: "",
                                        icon: Icons.location_on_outlined,
                                      ),
                                      items: _regioesDisponiveis.map((r) {
                                        return DropdownMenuItem(value: r, child: Text(r));
                                      }).toList(),
                                      onChanged: (v) {
                                        if (v != null) {
                                          setDialogState(() => selectedRegiao = v);
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildInputLabel("Status Inicial"),
                                    const SizedBox(height: 6),
                                    DropdownButtonFormField<String>(
                                      value: selectedStatus,
                                      isDense: true,
                                      style: const TextStyle(fontSize: 13, color: Color(0xFF1E1E1E)),
                                      decoration: _modalInputDecoration(
                                        hint: "",
                                        icon: Icons.timelapse_outlined,
                                      ),
                                      items: _statusDisponiveis.map((s) {
                                        return DropdownMenuItem(value: s, child: Text(s));
                                      }).toList(),
                                      onChanged: (v) {
                                        if (v != null) {
                                          setDialogState(() => selectedStatus = v);
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              OutlinedButton(
                                onPressed: () => Navigator.of(ctx).pop(),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Color(0xFFE0E0E0)),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 18,
                                    vertical: 12,
                                  ),
                                ),
                                child: const Text(
                                  "Cancelar",
                                  style: TextStyle(
                                    color: Color(0xFF616161),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              ElevatedButton.icon(
                                onPressed: () {
                                  if (formKey.currentState!.validate()) {
                                    final nova = UnidadeMovelModel(
                                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                                      codigo: codigoCtrl.text.trim().toUpperCase(),
                                      placa: placaCtrl.text.trim().toUpperCase(),
                                      tipo: selectedTipo,
                                      regiao: selectedRegiao,
                                      status: selectedStatus,
                                    );

                                    _dataService.adicionarUnidade(nova);
                                    Navigator.of(ctx).pop();

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text("Unidade móvel cadastrada com sucesso!"),
                                        backgroundColor: Color(0xFF2E7D32),
                                      ),
                                    );
                                  }
                                },
                                icon: const Icon(Icons.check, size: 16),
                                label: const Text(
                                  "Salvar Unidade",
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
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _confirmarExclusao(UnidadeMovelModel unidade) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.0)),
        title: const Text(
          "Confirmar Exclusão",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        content: Text(
          "Deseja remover a unidade \"${unidade.codigo} (${unidade.placa})\" da base?",
          style: const TextStyle(fontSize: 13, color: Color(0xFF616161)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancelar", style: TextStyle(color: Color(0xFF757575))),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _dataService.removerUnidade(unidade.id);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Unidade móvel excluída com sucesso."),
                  backgroundColor: Color(0xFFC62828),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC62828),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
            ),
            child: const Text("Excluir"),
          ),
        ],
      ),
    );
  }

  Widget _buildInputLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: Color(0xFF424242),
      ),
    );
  }

  InputDecoration _modalInputDecoration({required String hint, required IconData icon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFFBDBDBD), fontSize: 12),
      prefixIcon: Icon(icon, size: 16, color: const Color(0xFF757575)),
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      filled: true,
      fillColor: const Color(0xFFFAFAFA),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8.0)),
        borderSide: BorderSide(color: Color(0xFFC62828), width: 1.5),
      ),
    );
  }

  Widget _buildTopBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 250,
          height: 38,
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: TextField(
            controller: _topSearchController,
            style: const TextStyle(fontSize: 12),
            decoration: const InputDecoration(
              hintText: "Buscar no sistema...",
              hintStyle: TextStyle(color: Color(0xFF9CA3AF), fontSize: 12),
              prefixIcon: Icon(Icons.search, size: 16, color: Color(0xFF9CA3AF)),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 10),
            ),
          ),
        ),
        const SizedBox(width: 14),

        Stack(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.0),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: const Icon(
                Icons.notifications_none_outlined,
                size: 20,
                color: Color(0xFF4B5563),
              ),
            ),
            Positioned(
              top: 8,
              right: 9,
              child: Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: Color(0xFFDC2626),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 14),

        Container(
          width: 38,
          height: 38,
          decoration: const BoxDecoration(
            color: Color(0xFFC62828),
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Text(
              "AD",
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(int total) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFFFFEBEE),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.airport_shuttle_outlined,
            color: Color(0xFFC62828),
            size: 22,
          ),
        ),
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Cadastro de Unidades Móveis",
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1E1E1E),
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEBEE),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "$total ativa(s)",
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFC62828),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 3),
            const Text(
              "Cadastre ambulâncias (USA/USB) e gerencie a prontidão da frota",
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF757575),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAddButton() {
    return ElevatedButton.icon(
      onPressed: _showAdicionarUnidadeModal,
      icon: const Icon(Icons.add, size: 18, color: Colors.white),
      label: const Text(
        "Adicionar unidade",
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          letterSpacing: 0.2,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFDC2626),
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      ),
    );
  }

  Widget _buildStatsCard(int total, int emOperacao, int disponibilidade) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 18.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: const Color(0xFFEEEEEE)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 620;

          if (isNarrow) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFEBEE),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.airport_shuttle_outlined,
                        color: Color(0xFFC62828),
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    _buildStatColumn("Total cadastrado", "$total"),
                    const SizedBox(width: 20),
                    _buildStatColumn("Em operação", "$emOperacao"),
                    const SizedBox(width: 20),
                    _buildStatColumn("Disponibilidade", "$disponibilidade%"),
                  ],
                ),
                const SizedBox(height: 12),
                _buildSyncIndicator(),
              ],
            );
          }

          return Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEBEE),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.airport_shuttle_outlined,
                  color: Color(0xFFC62828),
                  size: 22,
                ),
              ),
              const SizedBox(width: 18),
              _buildStatColumn("Total cadastrado", "$total"),
              const SizedBox(width: 40),
              Container(height: 36, width: 1, color: const Color(0xFFF3F4F6)),
              const SizedBox(width: 40),
              _buildStatColumn("Em operação", "$emOperacao"),
              const SizedBox(width: 40),
              Container(height: 36, width: 1, color: const Color(0xFFF3F4F6)),
              const SizedBox(width: 40),
              _buildStatColumn("Disponibilidade", "$disponibilidade%"),
              const Spacer(),
              _buildSyncIndicator(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF6B7280),
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Color(0xFF111827),
          ),
        ),
      ],
    );
  }

  Widget _buildSyncIndicator() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: const BoxDecoration(
            color: Color(0xFF10B981),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Dados atualizados",
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Color(0xFF047857),
              ),
            ),
            SizedBox(height: 1),
            Text(
              "há poucos segundos",
              style: TextStyle(
                fontSize: 10,
                color: Color(0xFF9CA3AF),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildUnidadesCard(List<UnidadeMovelModel> lista) {
    final termo = _searchController.text.trim().toLowerCase();
    final filtradosPorBusca = lista.where((u) {
      if (termo.isEmpty) return true;
      final matchCodigo = u.codigo.toLowerCase().contains(termo);
      final matchPlaca = u.placa.toLowerCase().contains(termo);
      final matchTipo = u.tipo.toLowerCase().contains(termo);
      final matchRegiao = u.regiao.toLowerCase().contains(termo);
      return matchCodigo || matchPlaca || matchTipo || matchRegiao;
    }).toList();

    final filtrados = filtradosPorBusca.where((u) {
      if (_selectedStatusFilter == 'Todos') return true;
      return u.status.toLowerCase() == _selectedStatusFilter.toLowerCase();
    }).toList();

    final totalRegistros = filtrados.length;
    final startIndex = (_currentPage - 1) * _itemsPerPage;
    final endIndex = (startIndex + _itemsPerPage > totalRegistros)
        ? totalRegistros
        : startIndex + _itemsPerPage;

    final paginados = (startIndex < totalRegistros)
        ? filtrados.sublist(startIndex, endIndex)
        : <UnidadeMovelModel>[];

    final maxPage = (totalRegistros / _itemsPerPage).ceil().clamp(1, 9999);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: const Color(0xFFEEEEEE)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Frota de Unidades",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      "$totalRegistros registros encontrados",
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Container(
                      width: 240,
                      height: 38,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFAFAFA),
                        borderRadius: BorderRadius.circular(9.0),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: TextField(
                        controller: _searchController,
                        style: const TextStyle(fontSize: 12),
                        decoration: const InputDecoration(
                          hintText: "Buscar por prefixo, placa...",
                          hintStyle: TextStyle(color: Color(0xFF9CA3AF), fontSize: 12),
                          prefixIcon: Icon(Icons.search, size: 16, color: Color(0xFF9CA3AF)),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 9),
                        ),
                        onChanged: (_) => setState(() => _currentPage = 1),
                      ),
                    ),
                    const SizedBox(width: 10),

                    PopupMenuButton<String>(
                      initialValue: _selectedStatusFilter,
                      tooltip: "Filtrar por status",
                      onSelected: (val) {
                        setState(() {
                          _selectedStatusFilter = val;
                          _currentPage = 1;
                        });
                      },
                      itemBuilder: (ctx) => [
                        const PopupMenuItem(value: 'Todos', child: Text("Todos os status")),
                        const PopupMenuItem(value: 'Operacional', child: Text("Operacional")),
                        const PopupMenuItem(value: 'Em Atendimento', child: Text("Em Atendimento")),
                        const PopupMenuItem(value: 'Em Manutenção', child: Text("Em Manutenção")),
                      ],
                      child: Container(
                        height: 38,
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: _selectedStatusFilter != 'Todos'
                              ? const Color(0xFFFFEBEE)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(9.0),
                          border: Border.all(
                            color: _selectedStatusFilter != 'Todos'
                                ? const Color(0xFFC62828)
                                : const Color(0xFFE5E7EB),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.tune_rounded,
                              size: 15,
                              color: _selectedStatusFilter != 'Todos'
                                  ? const Color(0xFFC62828)
                                  : const Color(0xFF374151),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _selectedStatusFilter == 'Todos'
                                  ? "Filtros"
                                  : _selectedStatusFilter,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: _selectedStatusFilter != 'Todos'
                                    ? const Color(0xFFC62828)
                                    : const Color(0xFF374151),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF3F4F6)),

          LayoutBuilder(
            builder: (context, constraints) {
              const headerStyle = TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                color: Color(0xFF9CA3AF),
                letterSpacing: 0.8,
              );

              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: constraints.maxWidth.clamp(680, 2000)),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        child: Row(
                          children: const [
                            Expanded(flex: 3, child: Text("UNIDADE / PREFIXO", style: headerStyle)),
                            Expanded(flex: 2, child: Text("PLACA", style: headerStyle)),
                            Expanded(flex: 2, child: Text("BASE / REGIÃO", style: headerStyle)),
                            Expanded(flex: 2, child: Text("STATUS", style: headerStyle)),
                            SizedBox(width: 44),
                          ],
                        ),
                      ),
                      const Divider(height: 1, color: Color(0xFFF3F4F6)),

                      if (paginados.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 40.0),
                          child: Center(
                            child: Text(
                              "Nenhuma unidade móvel encontrada.",
                              style: TextStyle(fontSize: 13, color: Color(0xFF9CA3AF)),
                            ),
                          ),
                        )
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: paginados.length,
                          separatorBuilder: (_, __) =>
                              const Divider(height: 1, color: Color(0xFFF9FAFB)),
                          itemBuilder: (context, index) {
                            final unidade = paginados[index];

                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 14,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 36,
                                          height: 36,
                                          decoration: const BoxDecoration(
                                            color: Color(0xFFFFECEE),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Center(
                                            child: Icon(
                                              Icons.airport_shuttle,
                                              size: 18,
                                              color: Color(0xFFC62828),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                unidade.codigo,
                                                style: const TextStyle(
                                                  fontSize: 13.5,
                                                  fontWeight: FontWeight.w700,
                                                  color: Color(0xFF111827),
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                unidade.tipo,
                                                style: const TextStyle(
                                                  fontSize: 11.5,
                                                  color: Color(0xFF6B7280),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      unidade.placa,
                                      style: const TextStyle(
                                        fontSize: 12.5,
                                        color: Color(0xFF4B5563),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),

                                  Expanded(
                                    flex: 2,
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.location_on_outlined,
                                          size: 15,
                                          color: Color(0xFF9CA3AF),
                                        ),
                                        const SizedBox(width: 6),
                                        Flexible(
                                          child: Text(
                                            unidade.regiao,
                                            style: const TextStyle(
                                              fontSize: 12.5,
                                              color: Color(0xFF4B5563),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  Expanded(
                                    flex: 2,
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: _buildStatusPill(unidade.status),
                                    ),
                                  ),

                                  SizedBox(
                                    width: 44,
                                    child: IconButton(
                                      icon: const Icon(
                                        Icons.delete_outline,
                                        size: 18,
                                        color: Color(0xFF9CA3AF),
                                      ),
                                      tooltip: "Remover unidade",
                                      splashRadius: 18,
                                      hoverColor: const Color(0xFFFFEBEE),
                                      onPressed: () => _confirmarExclusao(unidade),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
          const Divider(height: 1, color: Color(0xFFF3F4F6)),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Mostrando ${paginados.length} de $totalRegistros registros",
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: Color(0xFF6B7280),
                  ),
                ),
                Row(
                  children: [
                    TextButton(
                      onPressed: _currentPage > 1
                          ? () => setState(() => _currentPage--)
                          : null,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      ),
                      child: Text(
                        "Anterior",
                        style: TextStyle(
                          fontSize: 12,
                          color: _currentPage > 1
                              ? const Color(0xFF4B5563)
                              : const Color(0xFFD1D5DB),
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        color: const Color(0xFFDC2626),
                        borderRadius: BorderRadius.circular(6.0),
                      ),
                      child: Center(
                        child: Text(
                          "$_currentPage",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    TextButton(
                      onPressed: _currentPage < maxPage
                          ? () => setState(() => _currentPage++)
                          : null,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      ),
                      child: Text(
                        "Próxima",
                        style: TextStyle(
                          fontSize: 12,
                          color: _currentPage < maxPage
                              ? const Color(0xFF4B5563)
                              : const Color(0xFFD1D5DB),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusPill(String status) {
    Color bg;
    Color text;

    switch (status.trim().toLowerCase()) {
      case 'operacional':
        bg = const Color(0xFFD1FAE5);
        text = const Color(0xFF047857);
        break;
      case 'em atendimento':
        bg = const Color(0xFFDBEAFE);
        text = const Color(0xFF1E40AF);
        break;
      case 'em manutenção':
      case 'em manutencao':
      default:
        bg = const Color(0xFFFEF3C7);
        text = const Color(0xFFB45309);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: text,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _dataService,
      builder: (context, _) {
        final lista = _dataService.unidades;
        final total = lista.length;

        final emOperacao = lista.where((u) {
          final s = u.status.toLowerCase();
          return s == 'operacional' || s == 'em atendimento';
        }).length;

        final disponibilidade = total == 0 ? 0 : ((emOperacao / total) * 100).round();

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(32.0, 18.0, 32.0, 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Topo da tela: Cabeçalho à esquerda e itens de busca/perfil à direita
              LayoutBuilder(
                builder: (context, constraints) {
                  final isCompact = constraints.maxWidth < 950;
                  if (isCompact) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(total),
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.centerRight,
                          child: _buildTopBar(),
                        ),
                      ],
                    );
                  }

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _buildHeader(total),
                      _buildTopBar(),
                    ],
                  );
                },
              ),
              const SizedBox(height: 16),

              // 2. Botão de ação alinhado à direita
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _buildAddButton(),
                ],
              ),
              const SizedBox(height: 16),

              _buildStatsCard(total, emOperacao, disponibilidade),
              const SizedBox(height: 20),

              _buildUnidadesCard(lista),
            ],
          ),
        );
      },
    );
  }
}
