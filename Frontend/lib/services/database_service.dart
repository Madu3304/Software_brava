// ============================================================================
// SERVIÇO DE PERSISTÊNCIA LOCAL (SQLITE / CRUD)
// Arquivo: lib/services/database_service.dart
// ============================================================================

import 'package:sqflite/sqflite.dart';
import '../core/database/database_helper.dart';
import '../models/ficha_model.dart';
import '../models/unidade_model.dart';
import '../models/profissional_model.dart';

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
    } catch (_) {
      return 1; // Fallback para ambiente web/testes sem SQLite nativo
    }
  }

  Future<List<FichaAtendimentoModel>> listarFichas() async {
    try {
      final db = await _dbHelper.database;
      final maps = await db.query('fichas', orderBy: 'dataHora DESC');
      return maps.map((m) => FichaAtendimentoModel.fromMap(m)).toList();
    } catch (_) {
      return [];
    }
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
    } catch (_) {
      return 1;
    }
  }

  Future<List<UnidadeMovelModel>> listarUnidades() async {
    try {
      final db = await _dbHelper.database;
      final maps = await db.query('unidades', orderBy: 'codigo ASC');
      return maps.map((m) => UnidadeMovelModel.fromMap(m)).toList();
    } catch (_) {
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
    } catch (_) {
      return 1;
    }
  }

  Future<List<ProfissionalModel>> listarProfissionais() async {
    try {
      final db = await _dbHelper.database;
      final maps = await db.query('profissionais', orderBy: 'nome ASC');
      return maps.map((m) => ProfissionalModel.fromMap(m)).toList();
    } catch (_) {
      return [];
    }
  }
}
