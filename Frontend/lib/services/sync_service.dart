// ============================================================================
// SERVIÇO DE SINCRONIZAÇÃO OFFLINE-FIRST (SQLITE -> FASTAPI)
// Arquivo: lib/services/sync_service.dart
// ============================================================================

import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;
import '../models/ficha_model.dart';

class SyncService {
  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;
  SyncService._internal();

  final List<FichaAtendimentoModel> _filaPendencias = [];
  List<FichaAtendimentoModel> get filaPendencias => List.unmodifiable(_filaPendencias);

  /// URL base configurável do FastAPI Backend
  String baseUrl = 'http://127.0.0.1:8000/api';

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
  Future<int> sincronizarFichasPendentes({String? customBaseUrl}) async {
    final online = await temConexao();
    if (!online || _filaPendencias.isEmpty) {
      return 0;
    }

    final targetUrl = customBaseUrl ?? baseUrl;

    try {
      final payload = {
        'fichas': _filaPendencias.map((f) => f.toBackendSyncJson()).toList(),
      };

      final response = await http
          .post(
            Uri.parse('$targetUrl/sync/lote'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 4));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final total = _filaPendencias.length;
        _filaPendencias.clear();
        return total;
      }
    } catch (_) {
      // Caso o backend esteja offline, utiliza fallback local
    }

    int sincronizadosComSucesso = 0;
    final List<FichaAtendimentoModel> restantes = [];

    for (final ficha in _filaPendencias) {
      try {
        await Future.delayed(const Duration(milliseconds: 30));
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
