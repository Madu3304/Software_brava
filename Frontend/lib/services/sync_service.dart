// ============================================================================
// SERVIÇO DE SINCRONIZAÇÃO OFFLINE-FIRST (SQLITE -> FASTAPI)
// Arquivo: lib/services/sync_service.dart
// ============================================================================

import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/ficha_model.dart';

class SyncService {
  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;
  SyncService._internal();

  final List<FichaAtendimentoModel> _filaPendencias = [];
  List<FichaAtendimentoModel> get filaPendencias => List.unmodifiable(_filaPendencias);

  /// Verifica se há conectividade ativa com a internet
  Future<bool> temConexao() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      return connectivityResult != ConnectivityResult.none;
    } catch (_) {
      return true; // Fallback permissivo para ambiente web/testes
    }
  }

  /// Adiciona uma ficha à fila local de sincronização
  void enfileirarFicha(FichaAtendimentoModel ficha) {
    _filaPendencias.removeWhere((item) => item.id == ficha.id);
    _filaPendencias.add(
      ficha.copyWith(statusSincronizacao: StatusSincronizacao.pendente),
    );
  }

  /// Tenta descarregar a fila pendente para o backend FastAPI
  Future<int> sincronizarFichasPendentes() async {
    final online = await temConexao();
    if (!online || _filaPendencias.isEmpty) {
      return 0;
    }

    int sincronizadosComSucesso = 0;
    final List<FichaAtendimentoModel> restantes = [];

    for (final ficha in _filaPendencias) {
      try {
        // Simulação de envio HTTP POST /api/v1/fichas/
        await Future.delayed(const Duration(milliseconds: 100));
        sincronizadosComSucesso++;
      } catch (e) {
        restantes.add(
          ficha.copyWith(statusSincronizacao: StatusSincronizacao.erro),
        );
      }
    }

    _filaPendencias.clear();
    _filaPendencias.addAll(restantes);
    return sincronizadosComSucesso;
  }
}
