import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_routes.dart';
import '../../models/ficha_model.dart';
import '../../providers/ficha_provider.dart';
import '../../services/database_service.dart';
import '../../services/sync_service.dart';

class MedicamentoItem {
  final String id;
  final String nome;
  final String categoria; // 'AMPOLAS', 'CONTROLADOS', 'COMPRIMIDOS'

  const MedicamentoItem({
    required this.id,
    required this.nome,
    required this.categoria,
  });
}

class FolhaGastosView extends StatefulWidget {
  final FichaAtendimentoModel? fichaParcial;

  const FolhaGastosView({
    super.key,
    this.fichaParcial,
  });

  @override
  State<FolhaGastosView> createState() => _FolhaGastosViewState();
}

class _FolhaGastosViewState extends State<FolhaGastosView> {
  final TextEditingController _searchController = TextEditingController();
  String _filtroTexto = '';
  bool _isSaving = false;

  // Mapa de quantidades por medicamento: nome -> quantidade
  final Map<String, int> _quantidades = {};

  // Catálogo completo conforme imagens fornecidas
  static const List<MedicamentoItem> _catalogo = [
    // --- MEDICAMENTOS · AMPOLAS ---
    MedicamentoItem(id: 'amp_1', nome: 'Água Destilada Estéril e Apirogênica 10 ml', categoria: 'AMPOLAS'),
    MedicamentoItem(id: 'amp_2', nome: 'Dimenidrinato + Piridoxina + Glicose + Frutose 10 ml', categoria: 'AMPOLAS'),
    MedicamentoItem(id: 'amp_3', nome: 'Dimenidrinato + Piridoxina 10 ml', categoria: 'AMPOLAS'),
    MedicamentoItem(id: 'amp_4', nome: 'Dipirona Sódica 500 mg/ml · 2 ml', categoria: 'AMPOLAS'),
    MedicamentoItem(id: 'amp_5', nome: 'Epinefrina 1 mg/ml · 1 ml', categoria: 'AMPOLAS'),
    MedicamentoItem(id: 'amp_6', nome: 'Escopolamina + Dipirona · 5 ml', categoria: 'AMPOLAS'),
    MedicamentoItem(id: 'amp_7', nome: 'Escopolamina 20 mg/ml · 1 ml', categoria: 'AMPOLAS'),
    MedicamentoItem(id: 'amp_8', nome: 'Furosemida 10 mg/ml · 2 ml', categoria: 'AMPOLAS'),
    MedicamentoItem(id: 'amp_9', nome: 'Glicose 50% injetável · 10 ml', categoria: 'AMPOLAS'),
    MedicamentoItem(id: 'amp_10', nome: 'Hidrocortisona 100 mg injetável', categoria: 'AMPOLAS'),
    MedicamentoItem(id: 'amp_11', nome: 'Hidrocortisona 500 mg injetável', categoria: 'AMPOLAS'),
    MedicamentoItem(id: 'amp_12', nome: 'Metoclopramida 5 mg/ml · 2 ml', categoria: 'AMPOLAS'),
    MedicamentoItem(id: 'amp_13', nome: 'Prometazina 25 mg/ml · 2 ml', categoria: 'AMPOLAS'),
    MedicamentoItem(id: 'amp_14', nome: 'Ranitidina 25 mg/ml · 2 ml', categoria: 'AMPOLAS'),
    MedicamentoItem(id: 'amp_15', nome: 'Tenoxicam 20 mg injetável', categoria: 'AMPOLAS'),
    MedicamentoItem(id: 'amp_16', nome: 'Terbutalina 0,5 mg/ml · 1 ml', categoria: 'AMPOLAS'),

    // --- MEDICAMENTOS · CONTROLADOS ---
    MedicamentoItem(id: 'ctrl_1', nome: 'Diazepam 5 mg/ml · 2 ml', categoria: 'CONTROLADOS'),
    MedicamentoItem(id: 'ctrl_2', nome: 'Haloperidol 5 mg/ml · 1 ml', categoria: 'CONTROLADOS'),
    MedicamentoItem(id: 'ctrl_3', nome: 'Morfina 10 mg/ml · 1 ml', categoria: 'CONTROLADOS'),
    MedicamentoItem(id: 'ctrl_4', nome: 'Tramadol 50 mg/ml · 2 ml', categoria: 'CONTROLADOS'),

    // --- COMPRIMIDOS E GOTAS ---
    MedicamentoItem(id: 'comp_1', nome: 'Ácido Acetilsalicílico 100 mg', categoria: 'COMPRIMIDOS'),
    MedicamentoItem(id: 'comp_2', nome: 'Captopril 25 mg', categoria: 'COMPRIMIDOS'),
    MedicamentoItem(id: 'comp_3', nome: 'Isossorbida 5 mg sublingual', categoria: 'COMPRIMIDOS'),
    MedicamentoItem(id: 'comp_4', nome: 'Fenoterol 5,0 mg/ml gotas · 20 ml', categoria: 'COMPRIMIDOS'),
    MedicamentoItem(id: 'comp_5', nome: 'Ipratrópio 0,25 mg/ml · 20 ml', categoria: 'COMPRIMIDOS'),
    MedicamentoItem(id: 'comp_6', nome: 'Paracetamol 200 mg/ml gotas · 15 ml', categoria: 'COMPRIMIDOS'),
    MedicamentoItem(id: 'comp_7', nome: 'Lidocaína 2% geleia · 30 g', categoria: 'COMPRIMIDOS'),
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

  void _toggleMedicamento(String nome) {
    setState(() {
      final atual = _quantidades[nome] ?? 0;
      if (atual > 0) {
        _quantidades[nome] = 0;
      } else {
        _quantidades[nome] = 1;
      }
    });
  }

  void _incrementar(String nome) {
    setState(() {
      _quantidades[nome] = (_quantidades[nome] ?? 0) + 1;
    });
  }

  void _decrementar(String nome) {
    setState(() {
      final atual = _quantidades[nome] ?? 0;
      if (atual > 1) {
        _quantidades[nome] = atual - 1;
      } else {
        _quantidades[nome] = 0;
      }
    });
  }

  Future<void> _avancarParaMateriais() async {
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

    // Constrói resumo dos medicamentos administrados
    final marcados = _quantidades.entries.where((e) => e.value > 0).toList();
    String resumoMedicamentos = '';
    if (marcados.isNotEmpty) {
      resumoMedicamentos = marcados
          .map((e) => "${e.key} (Qtd: ${e.value})")
          .join('; ');
    }

    // Preserva a conduta médica anexando os medicamentos gastos se houver
    String condutaAtualizada = fichaBase.condutaMedica ?? '';
    if (resumoMedicamentos.isNotEmpty) {
      condutaAtualizada = condutaAtualizada.isEmpty
          ? "Medicamentos: $resumoMedicamentos"
          : "$condutaAtualizada | Medicamentos: $resumoMedicamentos";
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
        AppRoutes.folhaGastosMateriais,
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

  @override
  Widget build(BuildContext context) {
    // Filtro de medicamentos
    final ampolas = _catalogo
        .where((m) => m.categoria == 'AMPOLAS' && (_filtroTexto.isEmpty || m.nome.toLowerCase().contains(_filtroTexto)))
        .toList();
    final controlados = _catalogo
        .where((m) => m.categoria == 'CONTROLADOS' && (_filtroTexto.isEmpty || m.nome.toLowerCase().contains(_filtroTexto)))
        .toList();
    final comprimidos = _catalogo
        .where((m) => m.categoria == 'COMPRIMIDOS' && (_filtroTexto.isEmpty || m.nome.toLowerCase().contains(_filtroTexto)))
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFFBF8F5), // Tom claro de fundo
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            // ==========================================
            // CABEÇALHO PADRÃO "FOLHA DE GASTOS"
            // ==========================================
            _buildHeader(context),

            // Linha decorativa de progresso na base do cabeçalho
            _buildProgressLine(),

            // ==========================================
            // CORPO COM BUSCA, AVISO E SEÇÕES DE ITENS
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

                        // Aviso de instruções
                        _buildInstructionBanner(),
                        const SizedBox(height: 20),

                        // Seção: MEDICAMENTOS · AMPOLAS
                        if (ampolas.isNotEmpty) ...[
                          _buildSectionHeader("MEDICAMENTOS · AMPOLAS"),
                          const SizedBox(height: 10),
                          _buildGroupCard(ampolas),
                          const SizedBox(height: 24),
                        ],

                        // Seção: MEDICAMENTOS · CONTROLADOS
                        if (controlados.isNotEmpty) ...[
                          _buildSectionHeader("MEDICAMENTOS · CONTROLADOS"),
                          const SizedBox(height: 10),
                          _buildGroupCard(controlados),
                          const SizedBox(height: 24),
                        ],

                        // Seção: COMPRIMIDOS E GOTAS
                        if (comprimidos.isNotEmpty) ...[
                          _buildSectionHeader("COMPRIMIDOS E GOTAS"),
                          const SizedBox(height: 10),
                          _buildGroupCard(comprimidos),
                          const SizedBox(height: 28),
                        ],

                        // Botão Avançar para Materiais e Insumos
                        SizedBox(
                          height: 52,
                          child: ElevatedButton(
                            onPressed: _isSaving ? null : _avancarParaMateriais,
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
                                        "Continuar para Materiais e Insumos",
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
                              "Voltar à Avaliação Clínica",
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
        color: Color(0xFF8B1D1D), // Vermelho escuro / vinho característico
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
                  "Medicamentos",
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
          // Pill badge com contador de itens marcados
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
            flex: 6,
            child: Container(color: const Color(0xFFFFFFFF)),
          ),
          Expanded(
            flex: 4,
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
          hintText: "Buscar medicamento...",
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

  Widget _buildGroupCard(List<MedicamentoItem> itens) {
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
            _buildMedicamentoRow(itens[i]),
            if (i < itens.length - 1)
              const Divider(height: 1, thickness: 1, color: Color(0xFFF0F0F0)),
          ],
        ],
      ),
    );
  }

  Widget _buildMedicamentoRow(MedicamentoItem item) {
    final quantidade = _quantidades[item.nome] ?? 0;
    final isSelected = quantidade > 0;

    return InkWell(
      onTap: () => _toggleMedicamento(item.nome),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            // Círculo de seleção
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

            // Nome e apresentação do medicamento
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

            // Controles de quantidade (+ e -)
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

