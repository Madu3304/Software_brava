import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../core/api/api_client.dart';
import '../models/ficha_model.dart';
import 'auth_service.dart';
import 'database_service.dart';

class SyncService {
  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;

  final DatabaseService _databaseService = DatabaseService();
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;
  bool _isSyncing = false;

  final List<FichaAtendimentoModel> _filaPendencias = [];
  List<FichaAtendimentoModel> get filaPendencias => List.unmodifiable(_filaPendencias);

  SyncService._internal() {
    _iniciarMonitoramentoConectividade();
  }

  /// Monitora restauração de conexão para sincronização automática com backoff (F2)
  void _iniciarMonitoramentoConectividade() {
    try {
      _connectivitySubscription = Connectivity().onConnectivityChanged.listen((result) {
        if (result != ConnectivityResult.none) {
          debugPrint('[SyncService] Conectividade restabelecida ($result). Iniciando sincronização...');
          sincronizarComBackoff();
        }
      });
    } catch (e) {
      debugPrint('[SyncService] Monitoramento de conectividade em segundo plano não inicializado: $e');
    }
  }

  /// Adiciona uma ficha à fila pendente local
  void enfileirarFicha(FichaAtendimentoModel ficha) {
    _filaPendencias.removeWhere((item) => item.id == ficha.id);
    _filaPendencias.add(
      ficha.copyWith(statusSincronizacao: StatusSincronizacao.pendente),
    );
  }

  /// Libera recursos e cancela listeners
  void dispose() {
    _connectivitySubscription?.cancel();
  }

  /// Verifica se há conectividade ativa de rede
  Future<bool> temConexao() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      return connectivityResult != ConnectivityResult.none;
    } catch (_) {
      return false;
    }
  }

  Future<int> sincronizarComBackoff({int maxTentativas = 3}) async {
    int tentativa = 0;
    int atrasoSegundos = 2;

    while (tentativa < maxTentativas) {
      try {
        final total = await sincronizarFichasPendentes();
        return total;
      } catch (e) {
        tentativa++;
        debugPrint('[SyncService] Falha na sincronização (tentativa $tentativa/$maxTentativas): $e');
        if (tentativa < maxTentativas) {
          await Future.delayed(Duration(seconds: atrasoSegundos));
          atrasoSegundos *= 2;
        }
      }
    }
    return 0;
  }

  Future<int> sincronizarFichasPendentes() async {
    if (_isSyncing) {
      debugPrint('[SyncService] Sincronização já em execução. Aguardando...');
      return 0;
    }

    final online = await temConexao();
    if (!online) {
      debugPrint('[SyncService] Dispositivo sem conexão de rede.');
      return 0;
    }

    List<FichaAtendimentoModel> pendentes = await _databaseService.listarFichasPendentes();
    if (pendentes.isEmpty && _filaPendencias.isNotEmpty) {
      pendentes = List.from(_filaPendencias);
    }

    if (pendentes.isEmpty) {
      debugPrint('[SyncService] Nenhuma ficha pendente de sincronização.');
      return 0;
    }

    _isSyncing = true;
    try {
      final currentUser = AuthService().currentUser;
      final int? idResponsavel = int.tryParse(currentUser?.id ?? '');

      final payload = {
        'fichas': pendentes.map((f) {
          return f.toBackendSyncJson(
            idResponsavel: idResponsavel ?? 1,
          );
        }).toList(),
      };

      final response = await ApiClient().dio.post(
        '/sync/lote',
        data: payload,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data as Map<String, dynamic>;

        final List<dynamic> sucessosUuids = data['sucessos_uuids'] is List
            ? data['sucessos_uuids'] as List<dynamic>
            : const [];
        final List<dynamic> duplicadosUuids = data['duplicados_uuids'] is List
            ? data['duplicados_uuids'] as List<dynamic>
            : const [];
        final List<dynamic> erros = data['erros'] is List
            ? data['erros'] as List<dynamic>
            : const [];

        int totalAtualizados = 0;

        for (final id in [...sucessosUuids, ...duplicadosUuids]) {
          final uuid = id.toString();
          await _databaseService.atualizarStatusSincronizacao(
            uuid,
            StatusSincronizacao.sincronizado,
          );
          _filaPendencias.removeWhere((f) => f.id == uuid);
          totalAtualizados++;
        }

        for (final erroItem in erros) {
          String? erroId;
          if (erroItem is Map && erroItem['uuid_offline'] != null) {
            erroId = erroItem['uuid_offline'].toString();
          } else if (erroItem is String) {
            final match = RegExp(r'Erro no item ([^:]+):').firstMatch(erroItem);
            if (match != null) {
              erroId = match.group(1)?.trim();
            }
          }
          if (erroId != null && erroId.isNotEmpty) {
            await _databaseService.atualizarStatusSincronizacao(
              erroId,
              StatusSincronizacao.erro,
            );
          }
        }

        debugPrint('[SyncService] Sincronização concluída: $totalAtualizados sincronizados, ${erros.length} com erro.');
        return totalAtualizados;
      } else {
        throw Exception('Status code inesperado retornado pelo servidor: ${response.statusCode}');
      }
    } on DioException catch (e) {
      debugPrint('[SyncService] Erro de rede ao sincronizar: ${e.message}');
      rethrow;
    } finally {
      _isSyncing = false;
    }
  }
}
