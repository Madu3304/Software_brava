import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import '../core/database/database_helper.dart';
import '../models/ficha_model.dart';
import '../models/unidade_model.dart';
import '../models/profissional_model.dart';
import 'local_crypto_service.dart';

class DatabaseServiceException implements Exception {
  final String message;
  final dynamic originalError;

  DatabaseServiceException(this.message, [this.originalError]);

  @override
  String toString() => message;
}

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  final DatabaseHelper _dbHelper = DatabaseHelper();

  // Fallback em memória para execução no navegador (Flutter Web / Docker)
  final Map<String, Map<String, dynamic>> _webFichas = {};
  final Map<String, Map<String, dynamic>> _webUnidades = {};
  final Map<String, Map<String, dynamic>> _webProfissionais = {};

  // Fichas de Atendimento (RN07: fichas sincronizadas/finalizadas são imutáveis)
  Future<int> inserirFicha(FichaAtendimentoModel ficha) async {
    final existente = await buscarFichaPorId(ficha.id);
    if (existente != null &&
        existente.statusSincronizacao == StatusSincronizacao.sincronizado &&
        ficha.statusSincronizacao != StatusSincronizacao.sincronizado) {
      debugPrint('[DatabaseService] RN07: Ficha ${ficha.id} já sincronizada não pode ser alterada.');
      return 0;
    }
    if (kIsWeb) {
      _webFichas[ficha.id] = await LocalCryptoService().protegerMapaFicha(ficha.toMap());
      return 1;
    }
    try {
      final db = await _dbHelper.database;
      final mapaProtegido = await LocalCryptoService().protegerMapaFicha(ficha.toMap());
      return await db.insert(
        'fichas',
        mapaProtegido,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      debugPrint('[DatabaseService] Erro ao inserir ficha: $e');
      throw DatabaseServiceException(
        'Não foi possível salvar a ficha de atendimento localmente. Verifique o armazenamento do dispositivo.',
        e,
      );
    }
  }

  // Retorna todas as fichas gravadas localmente ordenadas por data desc
  Future<List<FichaAtendimentoModel>> listarFichas() async {
    if (kIsWeb) {
      final list = <FichaAtendimentoModel>[];
      for (final m in _webFichas.values) {
        list.add(FichaAtendimentoModel.fromMap(await LocalCryptoService().desprotegerMapaFicha(m)));
      }
      list.sort((a, b) => b.dataHora.compareTo(a.dataHora));
      return list;
    }
    try {
      final db = await _dbHelper.database;
      final maps = await db.query('fichas', orderBy: 'dataHora DESC');
      final list = <FichaAtendimentoModel>[];
      for (final m in maps) {
        list.add(FichaAtendimentoModel.fromMap(await LocalCryptoService().desprotegerMapaFicha(m)));
      }
      return list;
    } catch (e) {
      debugPrint('[DatabaseService] Erro ao listar fichas: $e');
      return [];
    }
  }

  Future<List<FichaAtendimentoModel>> listarFichasPendentes() async {
    if (kIsWeb) {
      final list = <FichaAtendimentoModel>[];
      for (final m in _webFichas.values) {
        final f = FichaAtendimentoModel.fromMap(await LocalCryptoService().desprotegerMapaFicha(m));
        if (f.statusSincronizacao != StatusSincronizacao.sincronizado) {
          list.add(f);
        }
      }
      list.sort((a, b) => a.dataHora.compareTo(b.dataHora));
      return list;
    }
    try {
      final db = await _dbHelper.database;
      final maps = await db.query(
        'fichas',
        where: 'statusSincronizacao != ?',
        whereArgs: [StatusSincronizacao.sincronizado.name],
        orderBy: 'dataHora ASC',
      );
      final list = <FichaAtendimentoModel>[];
      for (final m in maps) {
        list.add(FichaAtendimentoModel.fromMap(await LocalCryptoService().desprotegerMapaFicha(m)));
      }
      return list;
    } catch (e) {
      debugPrint('[DatabaseService] Erro ao listar fichas pendentes: $e');
      return [];
    }
  }

  Future<int> atualizarStatusSincronizacao(String id, StatusSincronizacao status) async {
    if (kIsWeb) {
      final map = _webFichas[id];
      if (map != null) {
        map['statusSincronizacao'] = status.name;
        return 1;
      }
      return 0;
    }
    try {
      final db = await _dbHelper.database;
      return await db.update(
        'fichas',
        {'statusSincronizacao': status.name},
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      debugPrint('[DatabaseService] Erro ao atualizar status da ficha $id: $e');
      return 0;
    }
  }

  /// Busca uma ficha específica pelo seu ID
  Future<FichaAtendimentoModel?> buscarFichaPorId(String id) async {
    if (kIsWeb) {
      final map = _webFichas[id];
      return map != null
          ? FichaAtendimentoModel.fromMap(await LocalCryptoService().desprotegerMapaFicha(map))
          : null;
    }
    try {
      final db = await _dbHelper.database;
      final maps = await db.query(
        'fichas',
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );
      if (maps.isNotEmpty) {
        return FichaAtendimentoModel.fromMap(
          await LocalCryptoService().desprotegerMapaFicha(maps.first),
        );
      }
    } catch (e) {
      debugPrint('[DatabaseService] Erro ao buscar ficha $id: $e');
    }
    return null;
  }

  // Unidades Móveis
  Future<int> inserirUnidade(UnidadeMovelModel unidade) async {
    if (kIsWeb) {
      _webUnidades[unidade.id] = Map<String, dynamic>.from(unidade.toMap());
      return 1;
    }
    try {
      final db = await _dbHelper.database;
      return await db.insert(
        'unidades',
        unidade.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      debugPrint('[DatabaseService] Erro ao inserir unidade: $e');
      throw DatabaseServiceException('Não foi possível gravar a viatura no banco local.', e);
    }
  }

  Future<List<UnidadeMovelModel>> listarUnidades() async {
    if (kIsWeb) {
      final list = _webUnidades.values
          .map((m) => UnidadeMovelModel.fromMap(m))
          .toList();
      list.sort((a, b) => a.codigo.compareTo(b.codigo));
      return list;
    }
    try {
      final db = await _dbHelper.database;
      final maps = await db.query('unidades', orderBy: 'codigo ASC');
      return maps.map((m) => UnidadeMovelModel.fromMap(m)).toList();
    } catch (e) {
      debugPrint('[DatabaseService] Erro ao listar unidades: $e');
      return [];
    }
  }

  // Profissionais
  Future<int> inserirProfissional(ProfissionalModel profissional) async {
    if (kIsWeb) {
      _webProfissionais[profissional.id] = Map<String, dynamic>.from(profissional.toMap());
      return 1;
    }
    try {
      final db = await _dbHelper.database;
      return await db.insert(
        'profissionais',
        profissional.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      debugPrint('[DatabaseService] Erro ao inserir profissional: $e');
      throw DatabaseServiceException('Não foi possível gravar o profissional no banco local.', e);
    }
  }

  Future<List<ProfissionalModel>> listarProfissionais() async {
    if (kIsWeb) {
      final list = _webProfissionais.values
          .map((m) => ProfissionalModel.fromMap(m))
          .toList();
      list.sort((a, b) => a.nome.compareTo(b.nome));
      return list;
    }
    try {
      final db = await _dbHelper.database;
      final maps = await db.query('profissionais', orderBy: 'nome ASC');
      return maps.map((m) => ProfissionalModel.fromMap(m)).toList();
    } catch (e) {
      debugPrint('[DatabaseService] Erro ao listar profissionais: $e');
      return [];
    }
  }
}
