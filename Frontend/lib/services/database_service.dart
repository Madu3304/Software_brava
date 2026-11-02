import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import '../core/database/database_helper.dart';
import '../models/ficha_model.dart';
import '../models/unidade_model.dart';
import '../models/profissional_model.dart';

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

  // Fichas de Atendimento
  Future<int> inserirFicha(FichaAtendimentoModel ficha) async {
    try {
      final db = await _dbHelper.database;
      return await db.insert(
        'fichas',
        ficha.toMap(),
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
    try {
      final db = await _dbHelper.database;
      final maps = await db.query('fichas', orderBy: 'dataHora DESC');
      return maps.map((m) => FichaAtendimentoModel.fromMap(m)).toList();
    } catch (e) {
      debugPrint('[DatabaseService] Erro ao listar fichas: $e');
      return [];
    }
  }

  Future<List<FichaAtendimentoModel>> listarFichasPendentes() async {
    try {
      final db = await _dbHelper.database;
      final maps = await db.query(
        'fichas',
        where: 'statusSincronizacao != ?',
        whereArgs: [StatusSincronizacao.sincronizado.name],
        orderBy: 'dataHora ASC',
      );
      return maps.map((m) => FichaAtendimentoModel.fromMap(m)).toList();
    } catch (e) {
      debugPrint('[DatabaseService] Erro ao listar fichas pendentes: $e');
      return [];
    }
  }

  Future<int> atualizarStatusSincronizacao(String id, StatusSincronizacao status) async {
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
    try {
      final db = await _dbHelper.database;
      final maps = await db.query(
        'fichas',
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );
      if (maps.isNotEmpty) {
        return FichaAtendimentoModel.fromMap(maps.first);
      }
    } catch (e) {
      debugPrint('[DatabaseService] Erro ao buscar ficha $id: $e');
    }
    return null;
  }

  // Unidades Móveis
  Future<int> inserirUnidade(UnidadeMovelModel unidade) async {
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
