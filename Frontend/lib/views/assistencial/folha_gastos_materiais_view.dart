import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_routes.dart';
import '../../models/ficha_model.dart';
import '../../providers/ficha_provider.dart';
import '../../services/database_service.dart';
import '../../services/sync_service.dart';

class MaterialInsumoItem {
  final String id;
  final String nome;
  final String categoria; // 'INFUSAO', 'SONDAGEM', 'DIVERSOS'
  final List<String> variantes;

  const MaterialInsumoItem({
    required this.id,
    required this.nome,
    required this.categoria,
    this.variantes = const [],
  });

  bool get hasVariantes => variantes.isNotEmpty;
}

class FolhaGastosMateriaisView extends StatefulWidget {
  final FichaAtendimentoModel? fichaParcial;

  const FolhaGastosMateriaisView({
    super.key,
    this.fichaParcial,
  });

  @override
  State<FolhaGastosMateriaisView> createState() => _FolhaGastosMateriaisViewState();
}

class _FolhaGastosMateriaisViewState extends State<FolhaGastosMateriaisView> {
  final TextEditingController _searchController = TextEditingController();
  String _filtroTexto = '';
  bool _isSaving = false;

  // Mapa de quantidades: chave (nome ou 'nome - variante') -> quantidade
  final Map<String, int> _quantidades = {};

  static const List<MaterialInsumoItem> _catalogoMateriais = [
    // --- INFUSÃO ---
    MaterialInsumoItem(
      id: 'inf_1',
      nome: 'Adaptador de frasco de soro',
      categoria: 'INFUSAO',
    ),
    MaterialInsumoItem(
      id: 'inf_2',
      nome: 'Agulha hipodérmica',
      categoria: 'INFUSAO',
      variantes: ['13 x 4,5', '20 x 5,5', '25 x 7', '30 x 8', '40 x 12'],
    ),
    MaterialInsumoItem(
      id: 'inf_3',
      nome: 'Cateter periférico',
      categoria: 'INFUSAO',
      variantes: ['nº 14', 'nº 16', 'nº 18', 'nº 20', 'nº 22', 'nº 24'],
    ),
    MaterialInsumoItem(
      id: 'inf_4',
      nome: 'Conexão duas vias descartável',
      categoria: 'INFUSAO',
    ),
    MaterialInsumoItem(
      id: 'inf_5',
      nome: 'Dispositivo intravenoso',
      categoria: 'INFUSAO',
      variantes: ['nº 21', 'nº 23', 'nº 25'],
    ),
    MaterialInsumoItem(
      id: 'inf_6',
      nome: 'Equipo macrogotas',
      categoria: 'INFUSAO',
    ),
    MaterialInsumoItem(
      id: 'inf_7',
      nome: 'Ringer com lactato · 500 ml',
      categoria: 'INFUSAO',
    ),
    MaterialInsumoItem(
      id: 'inf_8',
      nome: 'Seringa descartável',
      categoria: 'INFUSAO',
      variantes: ['3 ml', '5 ml', '10 ml', '20 ml'],
    ),
    MaterialInsumoItem(
      id: 'inf_9',
      nome: 'Solução Cloreto de Sódio 0,9%',
      categoria: 'INFUSAO',
      variantes: ['100 ml', '250 ml', '500 ml'],
    ),
    MaterialInsumoItem(
      id: 'inf_10',
      nome: 'Solução Glicosada 5% · 250 ml',
      categoria: 'INFUSAO',
    ),

    // --- SONDAGEM, ASPIRAÇÃO E TRAUMA ---
    MaterialInsumoItem(
      id: 'sond_1',
      nome: 'Sonda de aspiração traqueal',
      categoria: 'SONDAGEM',
      variantes: ['nº 06', 'nº 14', 'nº 18'],
    ),
    MaterialInsumoItem(
      id: 'sond_2',
      nome: 'Sonda nasogástrica',
      categoria: 'SONDAGEM',
      variantes: ['nº 08', 'nº 14', 'nº 20'],
    ),
    MaterialInsumoItem(
      id: 'sond_3',
      nome: 'Atadura crepom',
      categoria: 'SONDAGEM',
      variantes: ['06 cm', '10 cm', '15 cm', '20 cm', '30 cm'],
    ),
    MaterialInsumoItem(
      id: 'sond_4',
      nome: 'Manta de alumínio',
      categoria: 'SONDAGEM',
    ),
    MaterialInsumoItem(
      id: 'sond_5',
      nome: 'Tala de papelão',
      categoria: 'SONDAGEM',
      variantes: ['P', 'M', 'G'],
    ),

    // --- MATERIAIS DIVERSOS ---
    MaterialInsumoItem(
      id: 'div_1',
      nome: 'Abaixador de língua',
      categoria: 'DIVERSOS',
    ),
    MaterialInsumoItem(
      id: 'div_2',
      nome: 'Água mineral · copo 200 ml',
      categoria: 'DIVERSOS',
    ),
    MaterialInsumoItem(
      id: 'div_3',
      nome: 'Água oxigenada',
      categoria: 'DIVERSOS',
    ),
    MaterialInsumoItem(
      id: 'div_4',
      nome: 'Álcool 70%',
      categoria: 'DIVERSOS',
    ),
    MaterialInsumoItem(
      id: 'div_5',
      nome: 'Aparelho de barbear',
      categoria: 'DIVERSOS',
    ),
    MaterialInsumoItem(
      id: 'div_6',
      nome: 'Avental descartável',
      categoria: 'DIVERSOS',
    ),
    MaterialInsumoItem(
      id: 'div_7',
      nome: 'Bateria para glicosímetro',
      categoria: 'DIVERSOS',
    ),
    MaterialInsumoItem(
      id: 'div_8',
      nome: 'Bloco de fichas de ocorrência',
      categoria: 'DIVERSOS',
    ),
    MaterialInsumoItem(
      id: 'div_9',
      nome: 'Cateter para oxigênio nasal tipo óculos',
      categoria: 'DIVERSOS',
    ),
    MaterialInsumoItem(
      id: 'div_10',
      nome: 'Clorexidina',
      categoria: 'DIVERSOS',
      variantes: ['Alcoólica 0,5%', 'Aquosa 2%', 'Degermante 2%'],
    ),
    MaterialInsumoItem(
      id: 'div_11',
      nome: 'Coletor de perfurocortante',
      categoria: 'DIVERSOS',
    ),
    MaterialInsumoItem(
      id: 'div_12',
      nome: 'Copo descartável · 50 ml',
      categoria: 'DIVERSOS',
    ),
    MaterialInsumoItem(
      id: 'div_13',
      nome: 'Detergente enzimático',
      categoria: 'DIVERSOS',
    ),
    MaterialInsumoItem(
      id: 'div_14',
      nome: 'Eletrodo para DEA',
      categoria: 'DIVERSOS',
    ),
    MaterialInsumoItem(
      id: 'div_15',
      nome: 'Esparadrapo comum',
      categoria: 'DIVERSOS',
    ),
    MaterialInsumoItem(
      id: 'div_16',
      nome: 'Esponja dupla face',
      categoria: 'DIVERSOS',
    ),
    MaterialInsumoItem(
      id: 'div_17',
      nome: 'Fita hipoalérgica',
      categoria: 'DIVERSOS',
      variantes: ['Pequena', 'Grande'],
    ),
    MaterialInsumoItem(
      id: 'div_18',
      nome: 'Fralda descartável',
      categoria: 'DIVERSOS',
      variantes: ['Infantil', 'Pequena', 'Grande', 'Adulto'],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _filtroTexto = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  int get _totalMarcados => _quantidades.values.where((q) => q > 0).length;

  int _qtdTotalDoItem(MaterialInsumoItem item) {
    if (!item.hasVariantes) {
      return _quantidades[item.nome] ?? 0;
    }
    int total = 0;
    for (final v in item.variantes) {
      total += _quantidades["${item.nome} - $v"] ?? 0;
    }
    return total;
  }

  void _toggleItem(String key) {
    setState(() {
      final atual = _quantidades[key] ?? 0;
      if (atual > 0) {
        _quantidades[key] = 0;
      } else {
        _quantidades[key] = 1;
      }
    });
  }

  void _incrementar(String key) {
    setState(() {
      _quantidades[key] = (_quantidades[key] ?? 0) + 1;
    });
  }

  void _decrementar(String key) {
    setState(() {
      final atual = _quantidades[key] ?? 0;
      if (atual > 1) {
        _quantidades[key] = atual - 1;
      } else {
        _quantidades[key] = 0;
      }
    });
  }

  Future<void> _avancarParaAssinatura() async {
    FichaAtendimentoModel? fichaBase = widget.fichaParcial ??
        ModalRoute.of(context)?.settings.arguments as FichaAtendimentoModel? ??
        context.read<FichaEmAndamentoProvider>().ficha;

    if (fichaBase == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Nenhuma ocorrência em andamento. Inicie o atendimento pela Ficha."),
          backgroundColor: AppColors.error,
        ),
      );
      Navigator.pushReplacementNamed(context, AppRoutes.ficha);
      return;
    }

    setState(() => _isSaving = true);

    // Constrói resumo dos materiais utilizados
    final marcados = _quantidades.entries.where((e) => e.value > 0).toList();
    String resumoMateriais = '';
    if (marcados.isNotEmpty) {
      resumoMateriais = marcados
          .map((e) => "${e.key} (Qtd: ${e.value})")
          .join('; ');
    }

    String condutaAtualizada = fichaBase.condutaMedica ?? '';
    if (resumoMateriais.isNotEmpty) {
      condutaAtualizada = condutaAtualizada.isEmpty
          ? "Materiais Gastos: $resumoMateriais"
          : "$condutaAtualizada | Materiais Gastos: $resumoMateriais";
    }

    final fichaAtualizada = fichaBase.copyWith(
      condutaMedica: condutaAtualizada,
    );

    try {
      await DatabaseService().inserirFicha(fichaAtualizada);

      if (!mounted) return;
      context.read<FichaEmAndamentoProvider>().setFicha(fichaAtualizada);

      setState(() => _isSaving = false);

      Navigator.pushNamed(
        context,
        AppRoutes.assinaturaPaciente,
        arguments: fichaAtualizada,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Não foi possível salvar os dados localmente. Tente novamente."),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  bool _matchesFilter(MaterialInsumoItem item) {
    if (_filtroTexto.isEmpty) return true;
    if (item.nome.toLowerCase().contains(_filtroTexto)) return true;
    for (final v in item.variantes) {
      if (v.toLowerCase().contains(_filtroTexto)) return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final infusoes = _catalogoMateriais
        .where((m) => m.categoria == 'INFUSAO' && _matchesFilter(m))
        .toList();
    final sondagens = _catalogoMateriais
        .where((m) => m.categoria == 'SONDAGEM' && _matchesFilter(m))
        .toList();
    final diversos = _catalogoMateriais
        .where((m) => m.categoria == 'DIVERSOS' && _matchesFilter(m))
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFFBF8F5),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            // ==========================================
            // CABEÇALHO PADRÃO "FOLHA DE GASTOS"
            // ==========================================
            _buildHeader(context),

            // Linha decorativa de progresso
            _buildProgressLine(),

            // ==========================================
            // CORPO COM BUSCA, AVISO E ITENS
            // ==========================================
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 620),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Campo de Busca
                        _buildSearchBar(),
                        const SizedBox(height: 12),

                        // Banner de Instruções
                        _buildInstructionBanner(),
                        const SizedBox(height: 20),

                        // Seção: INFUSÃO
                        if (infusoes.isNotEmpty) ...[
                          _buildSectionHeader("INFUSÃO"),
                          const SizedBox(height: 10),
                          _buildGroupCard(infusoes),
                          const SizedBox(height: 24),
                        ],

                        // Seção: SONDAGEM, ASPIRAÇÃO E TRAUMA
                        if (sondagens.isNotEmpty) ...[
                          _buildSectionHeader("SONDAGEM, ASPIRAÇÃO E TRAUMA"),
                          const SizedBox(height: 10),
                          _buildGroupCard(sondagens),
                          const SizedBox(height: 24),
                        ],

                        // Seção: MATERIAIS DIVERSOS
                        if (diversos.isNotEmpty) ...[
                          _buildSectionHeader("MATERIAIS DIVERSOS"),
                          const SizedBox(height: 10),
                          _buildGroupCard(diversos),
                          const SizedBox(height: 28),
                        ],

                        // Botão Avançar para Assinatura do Paciente
                        SizedBox(
                          height: 52,
                          child: ElevatedButton(
                            onPressed: _isSaving ? null : _avancarParaAssinatura,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.crimson,
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
                                        "Continuar para Assinatura do Paciente",
                                        style: TextStyle(
                                          fontSize: 15,
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
                            icon: const Icon(Icons.arrow_back, size: 16, color: AppColors.textSecondary),
                            label: const Text(
                              "Voltar aos Medicamentos",
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 14,
        bottom: 16,
        left: 16,
        right: 16,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF8B1D1D),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
            onPressed: () => Navigator.pop(context),
            tooltip: "Voltar",
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text(
                  "FOLHA DE GASTOS",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                    color: Color(0xFFFFD5B8),
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  "Materiais e Insumos",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF6B1414),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF9E3C3C), width: 1.2),
            ),
            child: Text(
              "$_totalMarcados marcados",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressLine() {
    return SizedBox(
      height: 3,
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Container(color: const Color(0xFFFFFFFF)),
          ),
          Expanded(
            flex: 8,
            child: Container(color: const Color(0xFFE65100)),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0), width: 1.2),
      ),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
        decoration: const InputDecoration(
          hintText: "Buscar material ou insumo...",
          hintStyle: TextStyle(color: Color(0xFF9E9E9E), fontSize: 14),
          prefixIcon: Icon(Icons.search, color: Color(0xFF757575), size: 20),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildInstructionBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9F2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFD9B3), width: 1.2),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(Icons.all_inbox_outlined, color: Color(0xFFE65100), size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text.rich(
              TextSpan(
                text: "Toque no item para marcar. Use ",
                style: const TextStyle(fontSize: 13, color: Color(0xFF5D4037)),
                children: const [
                  TextSpan(text: "+", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2C2C2C))),
                  TextSpan(text: " e "),
                  TextSpan(text: "−", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2C2C2C))),
                  TextSpan(text: " para informar a quantidade utilizada."),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
            color: Color(0xFF8B1D1D),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            height: 1,
            color: const Color(0xFFE2CCCC),
          ),
        ),
      ],
    );
  }

  Widget _buildGroupCard(List<MaterialInsumoItem> itens) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE6E6E6)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x05000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          for (int i = 0; i < itens.length; i++) ...[
            if (itens[i].hasVariantes)
              _buildItemComVariantesRow(itens[i])
            else
              _buildItemSimplesRow(itens[i]),
            if (i < itens.length - 1)
              const Divider(height: 1, thickness: 1, color: Color(0xFFF0F0F0)),
          ],
        ],
      ),
    );
  }

  Widget _buildItemSimplesRow(MaterialInsumoItem item) {
    final quantidade = _quantidades[item.nome] ?? 0;
    final isSelected = quantidade > 0;

    return InkWell(
      onTap: () => _toggleItem(item.nome),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? const Color(0xFF8B1D1D) : Colors.transparent,
                border: Border.all(
                  color: isSelected ? const Color(0xFF8B1D1D) : const Color(0xFFD6C8C8),
                  width: 1.8,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 15, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                item.nome,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected ? const Color(0xFF8B1D1D) : const Color(0xFF2C2C2C),
                ),
              ),
            ),
            if (isSelected)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildStepperButton(
                    icon: Icons.remove,
                    onTap: () => _decrementar(item.nome),
                  ),
                  Container(
                    constraints: const BoxConstraints(minWidth: 28),
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      "$quantidade",
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF8B1D1D),
                      ),
                    ),
                  ),
                  _buildStepperButton(
                    icon: Icons.add,
                    onTap: () => _incrementar(item.nome),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemComVariantesRow(MaterialInsumoItem item) {
    final totalQtd = _qtdTotalDoItem(item);
    final isAnySelected = totalQtd > 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isAnySelected ? const Color(0xFF8B1D1D) : Colors.transparent,
                  border: Border.all(
                    color: isAnySelected ? const Color(0xFF8B1D1D) : const Color(0xFFD6C8C8),
                    width: 1.8,
                  ),
                ),
                child: isAnySelected
                    ? const Icon(Icons.check, size: 15, color: Colors.white)
                    : null,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Row(
                  children: [
                    Text(
                      item.nome,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isAnySelected ? FontWeight.w600 : FontWeight.w500,
                        color: isAnySelected ? const Color(0xFF8B1D1D) : const Color(0xFF2C2C2C),
                      ),
                    ),
                    if (isAnySelected) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFBEBEB),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          "Total: $totalQtd",
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF8B1D1D),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Múltipla Escolha: Botões/Chips para cada variante de tamanho/número
          Padding(
            padding: const EdgeInsets.only(left: 38.0),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: item.variantes.map((v) {
                final key = "${item.nome} - $v";
                final qtd = _quantidades[key] ?? 0;
                final isSelected = qtd > 0;

                return InkWell(
                  onTap: () => _toggleItem(key),
                  borderRadius: BorderRadius.circular(8),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFFFBEBEB) : const Color(0xFFF7F7F7),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected ? const Color(0xFF8B1D1D) : const Color(0xFFD6C8C8),
                        width: isSelected ? 1.5 : 1.0,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          v,
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: isSelected ? const Color(0xFF8B1D1D) : const Color(0xFF424242),
                          ),
                        ),
                        if (isSelected) ...[
                          const SizedBox(width: 8),
                          InkWell(
                            onTap: () => _decrementar(key),
                            child: const Icon(
                              Icons.remove_circle_outline,
                              size: 16,
                              color: Color(0xFF8B1D1D),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            child: Text(
                              "$qtd",
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF8B1D1D),
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () => _incrementar(key),
                            child: const Icon(
                              Icons.add_circle_outline,
                              size: 16,
                              color: Color(0xFF8B1D1D),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepperButton({required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: const Color(0xFFF7F1F1),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: const Color(0xFFE2CCCC)),
        ),
        child: Icon(icon, size: 16, color: const Color(0xFF8B1D1D)),
      ),
    );
  }
}

