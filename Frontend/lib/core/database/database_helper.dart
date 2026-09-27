// ============================================================================
// CONFIGURAÇÃO DO BANCO DE DADOS LOCAL (SQLITE)
// Arquivo: lib/core/database/database_helper.dart
// ============================================================================

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'software_brava_samu.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // Tabela de Fichas de Atendimento (Offline-first)
        await db.execute('''
          CREATE TABLE fichas (
            id TEXT PRIMARY KEY,
            numeroOcorrencia TEXT,
            dataHora TEXT,
            pacienteNome TEXT,
            pacienteIdade INTEGER,
            pacienteSexo TEXT,
            tipoOcorrencia TEXT,
            endereco TEXT,
            latitude REAL,
            longitude REAL,
            unidadeResponsavel TEXT,
            queixaPrincipal TEXT,
            condutaMedica TEXT,
            statusSincronizacao TEXT
          )
        ''');

        // Tabela de Unidades Móveis
        await db.execute('''
          CREATE TABLE unidades (
            id TEXT PRIMARY KEY,
            codigo TEXT,
            placa TEXT,
            tipo TEXT,
            regiao TEXT,
            status TEXT
          )
        ''');

        // Tabela de Profissionais
        await db.execute('''
          CREATE TABLE profissionais (
            id TEXT PRIMARY KEY,
            nome TEXT,
            cpf TEXT,
            registroConselho TEXT,
            tipo TEXT,
            unidade TEXT,
            matricula TEXT
          )
        ''');
      },
    );
  }
}
