import 'package:flutter/material.dart';
import '../../../core/api/api_client.dart';
import '../../../core/constants/app_colors.dart';
import '../../../services/database_service.dart';

class HistoricoFichasScreen extends StatefulWidget {
  const HistoricoFichasScreen({super.key});

  @override
  State<HistoricoFichasScreen> createState() => _HistoricoFichasScreenState();
}

class _HistoricoFichasScreenState extends State<HistoricoFichasScreen> {
  final TextEditingController _searchController = TextEditingController();
  DateTime? _dataFiltro;
  bool _isLoading = false;
  List<Map<String, dynamic>> _fichas = [];

  @override
  void initState() {
    super.initState();
    _carregarFichas();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _carregarFichas() async {
    setState(() => _isLoading = true);
    try {
      final queryParams = <String, dynamic>{'limit': 100};
      if (_dataFiltro != null) {
        final y = _dataFiltro!.year.toString().padLeft(4, '0');
        final m = _dataFiltro!.month.toString().padLeft(2, '0');
        final d = _dataFiltro!.day.toString().padLeft(2, '0');
        queryParams['data'] = '$y-$m-$d';
      }

      final res = await ApiClient().dio.get('/fichas/', queryParameters: queryParams);
      if (res.statusCode == 200 && res.data is List) {
        setState(() {
          _fichas = (res.data as List).cast<Map<String, dynamic>>();
        });
        return;
      }
    } catch (e) {
      debugPrint('[HistoricoFichasScreen] Aviso ao carregar API, usando base local: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }

    // Fallback offline-first para fichas locais
    final locais = await DatabaseService().listarFichas();
    if (!mounted) return;
    setState(() {
      _fichas = locais
          .map((f) => {
                'id_ficha': f.numeroOcorrencia,
                'data_atendimento': f.dataHora.toIso8601String(),
                'logradouro': f.endereco,
                'unidade_parada': f.unidadeParada,
                'motivo_unidade_parada': f.motivoUnidadeParada,
                'status_envio_prefeitura': f.statusSincronizacao.name.toUpperCase(),
                'paciente': {'nome': f.pacienteNome},
              })
          .toList();
    });
  }

  Future<void> _selecionarData() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dataFiltro ?? DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() => _dataFiltro = picked);
      _carregarFichas();
    }
  }

  void _exibirDetalhesSomenteLeitura(Map<String, dynamic> ficha) {
    final paciente = ficha['paciente'] is Map ? ficha['paciente'] as Map : const {};
    final avaliacao = ficha['avaliacao_clinica'] is Map ? ficha['avaliacao_clinica'] as Map : const {};

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Text("Ficha #${ficha['id_ficha'] ?? '-'} (Somente Leitura)"),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Paciente: ${paciente['nome'] ?? 'Não identificado'}"),
              const SizedBox(height: 6),
              Text("Endereço: ${ficha['logradouro'] ?? '-'}"),
              const SizedBox(height: 6),
              Text("Data: ${(ficha['data_atendimento'] ?? ficha['criado_em'] ?? '-').toString()}"),
              const SizedBox(height: 6),
              Text("Status Prefeitura: ${ficha['status_envio_prefeitura'] ?? '-'}"),
              if (ficha['unidade_parada'] == true) ...[
                const SizedBox(height: 6),
                Text(
                  "Unidade Parada: ${ficha['motivo_unidade_parada'] ?? 'Sim'}",
                  style: const TextStyle(color: AppColors.primaryRed, fontWeight: FontWeight.w600),
                ),
              ],
              if (avaliacao.isNotEmpty) ...[
                const Divider(height: 18),
                Text("PA: ${avaliacao['pressao_arterial'] ?? '-'} | FC: ${avaliacao['frequencia_cardiaca'] ?? '-'}"),
                const SizedBox(height: 4),
                Text("Conduta: ${avaliacao['conduta'] ?? '-'}"),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Fechar"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final termo = _searchController.text.trim().toLowerCase();
    final filtradas = _fichas.where((f) {
      if (termo.isEmpty) return true;
      final paciente = f['paciente'] is Map ? (f['paciente']['nome'] ?? '').toString() : '';
      final id = (f['id_ficha'] ?? '').toString();
      final end = (f['logradouro'] ?? '').toString();
      return paciente.toLowerCase().contains(termo) ||
          id.toLowerCase().contains(termo) ||
          end.toLowerCase().contains(termo);
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(32.0, 18.0, 32.0, 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
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
                child: const Icon(Icons.history_edu_outlined, color: Color(0xFFC62828), size: 22),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        "Histórico de Fichas (RN08)",
                        style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800, color: Color(0xFF1E1E1E)),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFEBEE),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          "${filtradas.length} registro(s)",
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFC62828)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  const Text(
                    "Consulta somente leitura de atendimentos registrados (RN07: registros finalizados são imutáveis)",
                    style: TextStyle(fontSize: 12, color: Color(0xFF757575)),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFEEEEEE)),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 18, 24, 14),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          onChanged: (_) => setState(() {}),
                          decoration: InputDecoration(
                            hintText: "Buscar por paciente, nº ficha ou endereço...",
                            prefixIcon: const Icon(Icons.search, size: 18),
                            isDense: true,
                            filled: true,
                            fillColor: const Color(0xFFFAFAFA),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(9),
                              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton.icon(
                        onPressed: _selecionarData,
                        icon: const Icon(Icons.calendar_today_outlined, size: 16),
                        label: Text(
                          _dataFiltro == null
                              ? "Filtrar por Data"
                              : "${_dataFiltro!.day.toString().padLeft(2, '0')}/${_dataFiltro!.month.toString().padLeft(2, '0')}/${_dataFiltro!.year}",
                        ),
                      ),
                      if (_dataFiltro != null) ...[
                        const SizedBox(width: 6),
                        IconButton(
                          tooltip: "Limpar data",
                          onPressed: () {
                            setState(() => _dataFiltro = null);
                            _carregarFichas();
                          },
                          icon: const Icon(Icons.clear, size: 18),
                        ),
                      ],
                    ],
                  ),
                ),
                const Divider(height: 1, color: Color(0xFFF3F4F6)),
                if (_isLoading)
                  const Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(),
                  )
                else if (filtradas.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(32),
                    child: Text("Nenhuma ficha encontrada para os filtros informados."),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filtradas.length,
                    separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFF3F4F6)),
                    itemBuilder: (context, index) {
                      final f = filtradas[index];
                      final paciente = f['paciente'] is Map ? f['paciente'] as Map : const {};
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
                        leading: CircleAvatar(
                          backgroundColor: const Color(0xFFFFECEE),
                          child: Text(
                            "#${f['id_ficha'] ?? '-'}",
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFC62828)),
                          ),
                        ),
                        title: Text(
                          (paciente['nome'] ?? 'Paciente Não Identificado').toString(),
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                        ),
                        subtitle: Text(
                          "${f['logradouro'] ?? '-'} • Status: ${f['status_envio_prefeitura'] ?? 'PENDENTE'}",
                          style: const TextStyle(fontSize: 12),
                        ),
                        trailing: TextButton.icon(
                          onPressed: () => _exibirDetalhesSomenteLeitura(f),
                          icon: const Icon(Icons.visibility_outlined, size: 17),
                          label: const Text("Visualizar"),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

