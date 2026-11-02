import 'package:flutter/foundation.dart';
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
      version: 3,
      onCreate: (db, version) async {
        // Tabela de Fichas de Atendimento (Offline-first com sinais vitais estruturados)
        await db.execute('''
          CREATE TABLE fichas (
            id TEXT PRIMARY KEY,
            numeroOcorrencia TEXT,
            dataHora TEXT,
            pacienteNome TEXT,
            pacienteIdade INTEGER,
            pacienteDataNascimento TEXT,
            pacienteSexo TEXT,
            pacienteCpf TEXT,
            acompanhante TEXT,
            grauParentesco TEXT,
            telefoneContato TEXT,
            medicamentosUsoContinuo TEXT,
            alergias TEXT,
            tipoOcorrencia TEXT,
            endereco TEXT,
            latitude REAL,
            longitude REAL,
            unidadeResponsavel TEXT,
            queixaPrincipal TEXT,
            condutaMedica TEXT,
            statusSincronizacao TEXT,
            tipoViatura TEXT,
            codigoTriagem TEXT,
            base TEXT,
            medicoResponsavel TEXT,
            tecnicoResponsavel TEXT,
            condutorSocorrista TEXT,
            horaAberturaChamado TEXT,
            horaSaidaBase TEXT,
            pressaoArterial TEXT,
            frequenciaCardiaca INTEGER,
            frequenciaRespiratoria INTEGER,
            saturacaoO2 INTEGER,
            glicemia INTEGER,
            temperatura REAL,
            escalaGlasgow INTEGER,
            aberturaOcular INTEGER,
            respostaVerbal INTEGER,
            respostaMotora INTEGER,
            avcSuspeito INTEGER,
            assimetriaFacial INTEGER,
            quedaBraco INTEGER,
            falaAnormal INTEGER
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
      onUpgrade: (db, oldVersion, newVersion) async {
        Future<void> executarAlter(String sql) async {
          try {
            await db.execute(sql);
            debugPrint('[DB MIGRATION SUCESSO] $sql');
          } catch (e) {
            debugPrint('[DB MIGRATION AVISO] Falha ao executar "$sql": $e');
          }
        }

        if (oldVersion < 2) {
          await executarAlter('ALTER TABLE fichas ADD COLUMN pacienteDataNascimento TEXT');
          await executarAlter('ALTER TABLE fichas ADD COLUMN pacienteCpf TEXT');
          await executarAlter('ALTER TABLE fichas ADD COLUMN grauParentesco TEXT');
          await executarAlter('ALTER TABLE fichas ADD COLUMN telefoneContato TEXT');
          await executarAlter('ALTER TABLE fichas ADD COLUMN medicamentosUsoContinuo TEXT');
          await executarAlter('ALTER TABLE fichas ADD COLUMN alergias TEXT');
          await executarAlter('ALTER TABLE fichas ADD COLUMN tipoViatura TEXT');
          await executarAlter('ALTER TABLE fichas ADD COLUMN codigoTriagem TEXT');
          await executarAlter('ALTER TABLE fichas ADD COLUMN base TEXT');
          await executarAlter('ALTER TABLE fichas ADD COLUMN medicoResponsavel TEXT');
          await executarAlter('ALTER TABLE fichas ADD COLUMN tecnicoResponsavel TEXT');
          await executarAlter('ALTER TABLE fichas ADD COLUMN condutorSocorrista TEXT');
          await executarAlter('ALTER TABLE fichas ADD COLUMN horaAberturaChamado TEXT');
          await executarAlter('ALTER TABLE fichas ADD COLUMN horaSaidaBase TEXT');
        }

        if (oldVersion < 3) {
          await executarAlter('ALTER TABLE fichas ADD COLUMN pressaoArterial TEXT');
          await executarAlter('ALTER TABLE fichas ADD COLUMN frequenciaCardiaca INTEGER');
          await executarAlter('ALTER TABLE fichas ADD COLUMN frequenciaRespiratoria INTEGER');
          await executarAlter('ALTER TABLE fichas ADD COLUMN saturacaoO2 INTEGER');
          await executarAlter('ALTER TABLE fichas ADD COLUMN glicemia INTEGER');
          await executarAlter('ALTER TABLE fichas ADD COLUMN temperatura REAL');
          await executarAlter('ALTER TABLE fichas ADD COLUMN escalaGlasgow INTEGER');
          await executarAlter('ALTER TABLE fichas ADD COLUMN aberturaOcular INTEGER');
          await executarAlter('ALTER TABLE fichas ADD COLUMN respostaVerbal INTEGER');
          await executarAlter('ALTER TABLE fichas ADD COLUMN respostaMotora INTEGER');
          await executarAlter('ALTER TABLE fichas ADD COLUMN avcSuspeito INTEGER');
          await executarAlter('ALTER TABLE fichas ADD COLUMN assimetriaFacial INTEGER');
          await executarAlter('ALTER TABLE fichas ADD COLUMN quedaBraco INTEGER');
          await executarAlter('ALTER TABLE fichas ADD COLUMN falaAnormal INTEGER');
        }
      },
    );
  }
}
