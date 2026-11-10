import 'package:flutter/foundation.dart';
import '../core/api/api_client.dart';
import '../models/profissional_model.dart';
import '../models/unidade_model.dart';

class AdminDataService extends ChangeNotifier {
  static final AdminDataService _instance = AdminDataService._internal();
  factory AdminDataService() => _instance;

  AdminDataService._internal() {
    carregarCadastros();
  }

  final List<ProfissionalModel> _profissionais = [];
  final List<UnidadeMovelModel> _unidades = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<ProfissionalModel> get profissionais => List.unmodifiable(_profissionais);
  List<UnidadeMovelModel> get unidades => List.unmodifiable(_unidades);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<ProfissionalModel> get medicos =>
      _profissionais.where((p) => p.tipo == TipoProfissional.medico).toList();

  List<ProfissionalModel> get enfermeiros =>
      _profissionais.where((p) => p.tipo == TipoProfissional.enfermeiro).toList();

  List<ProfissionalModel> get socorristas =>
      _profissionais.where((p) => p.tipo == TipoProfissional.socorrista).toList();

  Future<void> carregarCadastros() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final dio = ApiClient().dio;

      // 1. Carrega Médicos
      try {
        final resMedicos = await dio.get('/cadastros/medicos');
        if (resMedicos.statusCode == 200 && resMedicos.data is List) {
          final List<ProfissionalModel> medicosCarregados = (resMedicos.data as List)
              .map((item) => ProfissionalModel.fromMap(
                    item as Map<String, dynamic>,
                    tipoExplicit: TipoProfissional.medico,
                  ))
              .toList();
          _profissionais.removeWhere((p) => p.tipo == TipoProfissional.medico);
          _profissionais.addAll(medicosCarregados);
        }
      } catch (e) {
        debugPrint('[AdminDataService] Aviso ao carregar médicos: $e');
      }

      // 2. Carrega Técnicos / Enfermagem
      try {
        final resTecnicos = await dio.get('/cadastros/tecnicos');
        if (resTecnicos.statusCode == 200 && resTecnicos.data is List) {
          final List<ProfissionalModel> tecnicosCarregados = (resTecnicos.data as List)
              .map((item) => ProfissionalModel.fromMap(
                    item as Map<String, dynamic>,
                    tipoExplicit: TipoProfissional.enfermeiro,
                  ))
              .toList();
          _profissionais.removeWhere((p) => p.tipo == TipoProfissional.enfermeiro);
          _profissionais.addAll(tecnicosCarregados);
        }
      } catch (e) {
        debugPrint('[AdminDataService] Aviso ao carregar técnicos: $e');
      }

      // 3. Carrega Condutores / Socorristas
      try {
        final resCondutores = await dio.get('/cadastros/condutores');
        if (resCondutores.statusCode == 200 && resCondutores.data is List) {
          final List<ProfissionalModel> condutoresCarregados = (resCondutores.data as List)
              .map((item) => ProfissionalModel.fromMap(
                    item as Map<String, dynamic>,
                    tipoExplicit: TipoProfissional.socorrista,
                  ))
              .toList();
          _profissionais.removeWhere((p) => p.tipo == TipoProfissional.socorrista);
          _profissionais.addAll(condutoresCarregados);
        }
      } catch (e) {
        debugPrint('[AdminDataService] Aviso ao carregar condutores: $e');
      }

      // 4. Carrega Unidades Móveis
      try {
        final resUnidades = await dio.get('/cadastros/unidades');
        if (resUnidades.statusCode == 200 && resUnidades.data is List) {
          _unidades.clear();
          final List<UnidadeMovelModel> unidadesCarregadas = (resUnidades.data as List)
              .map((item) => UnidadeMovelModel.fromMap(item as Map<String, dynamic>))
              .toList();
          _unidades.addAll(unidadesCarregadas);
        }
      } catch (e) {
        debugPrint('[AdminDataService] Aviso ao carregar unidades: $e');
      }

      if (_profissionais.isEmpty && _unidades.isEmpty) {
        _carregarPadroesIniciaisSC();
      }
    } catch (e) {
      _errorMessage = 'Falha ao sincronizar cadastros com o servidor.';
      debugPrint('[AdminDataService] Erro geral ao carregar cadastros: $e');
      if (_profissionais.isEmpty && _unidades.isEmpty) {
        _carregarPadroesIniciaisSC();
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _carregarPadroesIniciaisSC() {
    _profissionais.clear();
    _profissionais.addAll([
      ProfissionalModel.tecnicoEnfermagem(
        id: '1',
        nome: 'Ana Paula Oliveira',
        cpf: '123.456.789-01',
        coren: 'COREN-SC 123456',
        unidade: 'Unidade Norte',
        matricula: 'UN-TE-001',
      ),
      ProfissionalModel.medico(
        id: '101',
        nome: 'Dr. Roberto Silva',
        cpf: '111.222.333-44',
        crm: 'CRM-SC 12345',
        unidade: 'SAMU Centro',
        matricula: 'UN-001',
        cargo: 'Médico regulador',
        status: 'Em plantão',
      ),
      ProfissionalModel.medico(
        id: '102',
        nome: 'Dra. Juliana Mendes',
        cpf: '555.666.777-88',
        crm: 'CRM-SC 23456',
        unidade: 'SAMU Norte',
        matricula: 'UN-002',
        cargo: 'Médica intervencionista',
        status: 'Disponível',
      ),
      ProfissionalModel.medico(
        id: '103',
        nome: 'Dr. André Costa',
        cpf: '999.888.777-66',
        crm: 'CRM-SC 18821',
        unidade: 'SAMU Sul',
        matricula: 'UN-003',
        cargo: 'Médico regulador',
        status: 'Folga',
      ),
      ProfissionalModel.socorrista(
        id: '3',
        nome: 'Marcos Vinícius Santos',
        cpf: '222.333.444-55',
        cnh: '01234567890 (Cat. D)',
        unidade: 'Unidade Norte',
        matricula: 'UN-SOC-001',
      ),
    ]);

    _unidades.clear();
    _unidades.addAll([
      const UnidadeMovelModel(
        id: '1',
        codigo: 'USA-01',
        placa: 'BRA-1921',
        tipo: 'USA (Suporte Avançado)',
        regiao: 'Unidade Norte',
        status: 'Operacional',
      ),
      const UnidadeMovelModel(
        id: '2',
        codigo: 'USB-02',
        placa: 'BRA-1922',
        tipo: 'USB (Suporte Básico)',
        regiao: 'Unidade Sul',
        status: 'Operacional',
      ),
    ]);
  }

  Future<void> adicionarProfissional(ProfissionalModel profissional) async {
    _profissionais.add(profissional);
    notifyListeners();

    try {
      final dio = ApiClient().dio;
      if (profissional.tipo == TipoProfissional.medico) {
        await dio.post(
          '/cadastros/medicos',
          data: {
            'nome': profissional.nome,
            'codigo_medico': profissional.registroConselho,
          },
        );
      } else if (profissional.tipo == TipoProfissional.enfermeiro) {
        await dio.post(
          '/cadastros/tecnicos',
          data: {
            'nome': profissional.nome,
            'codigo_tecnico': profissional.registroConselho,
          },
        );
      } else if (profissional.tipo == TipoProfissional.socorrista) {
        await dio.post(
          '/cadastros/condutores',
          data: {
            'nome': profissional.nome,
            'codigo_condutor': profissional.registroConselho,
          },
        );
      }
    } catch (e) {
      debugPrint('[AdminDataService] Aviso: erro ao persistir profissional na API: $e');
    }
  }

  Future<void> removerProfissional(String id) async {
    final prof = _profissionais.firstWhere((p) => p.id == id, orElse: () => _profissionais.first);
    final tipo = prof.tipo;
    _profissionais.removeWhere((p) => p.id == id);
    notifyListeners();

    try {
      final dio = ApiClient().dio;
      final intId = int.tryParse(id);
      if (intId != null) {
        if (tipo == TipoProfissional.medico) {
          await dio.delete('/cadastros/medicos/$intId');
        } else if (tipo == TipoProfissional.enfermeiro) {
          await dio.delete('/cadastros/tecnicos/$intId');
        } else if (tipo == TipoProfissional.socorrista) {
          await dio.delete('/cadastros/condutores/$intId');
        }
      }
    } catch (e) {
      debugPrint('[AdminDataService] Aviso: erro ao deletar profissional na API: $e');
    }
  }

  Future<void> adicionarUnidade(UnidadeMovelModel unidade) async {
    _unidades.add(unidade);
    notifyListeners();

    try {
      final dio = ApiClient().dio;
      await dio.post(
        '/cadastros/unidades',
        data: {
          'placa': unidade.placa,
          'base_unidade': unidade.regiao,
          'status': unidade.status.toUpperCase(),
        },
      );
    } catch (e) {
      debugPrint('[AdminDataService] Aviso: erro ao persistir unidade na API: $e');
    }
  }

  Future<void> removerUnidade(String id) async {
    _unidades.removeWhere((u) => u.id == id);
    notifyListeners();

    try {
      final dio = ApiClient().dio;
      final intId = int.tryParse(id);
      if (intId != null) {
        await dio.delete('/cadastros/unidades/$intId');
      }
    } catch (e) {
      debugPrint('[AdminDataService] Aviso: erro ao deletar unidade na API: $e');
    }
  }
}
