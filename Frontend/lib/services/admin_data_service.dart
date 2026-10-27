// ============================================================================
// SERVIÇO DE GERENCIAMENTO DE DADOS E ESTADO DO PAINEL ADMINISTRATIVO
// Arquivo: lib/services/admin_data_service.dart
// ============================================================================

import 'package:flutter/foundation.dart';
import '../models/profissional_model.dart';
import '../models/unidade_model.dart';

class AdminDataService extends ChangeNotifier {
  static final AdminDataService _instance = AdminDataService._internal();
  factory AdminDataService() => _instance;

  AdminDataService._internal() {
    _initMockData();
  }

  final List<ProfissionalModel> _profissionais = [];
  final List<UnidadeMovelModel> _unidades = [];

  List<ProfissionalModel> get profissionais => List.unmodifiable(_profissionais);
  List<UnidadeMovelModel> get unidades => List.unmodifiable(_unidades);

  List<ProfissionalModel> get medicos =>
      _profissionais.where((p) => p.tipo == TipoProfissional.medico).toList();

  List<ProfissionalModel> get enfermeiros =>
      _profissionais.where((p) => p.tipo == TipoProfissional.enfermeiro).toList();

  List<ProfissionalModel> get socorristas =>
      _profissionais.where((p) => p.tipo == TipoProfissional.socorrista).toList();

  void _initMockData() {
    _profissionais.addAll([
      ProfissionalModel.tecnicoEnfermagem(
        id: '1',
        nome: 'Ana Paula Oliveira',
        cpf: '123.456.789-01',
        coren: 'COREN-SP 123456',
        unidade: 'Unidade Norte',
        matricula: 'UN-TE-001',
      ),
      ProfissionalModel.tecnicoEnfermagem(
        id: '2',
        nome: 'Carlos Eduardo Lima',
        cpf: '987.654.321-02',
        coren: 'COREN-SP 654321',
        unidade: 'Unidade Leste',
        matricula: 'UL-TE-002',
      ),
      ProfissionalModel.medico(
        id: '3',
        nome: 'Dr. Roberto Silveira',
        cpf: '111.222.333-44',
        crm: 'CRM-SC 14522',
        unidade: 'Unidade Norte',
        matricula: 'UN-001',
      ),
      ProfissionalModel.medico(
        id: '4',
        nome: 'Dra. Juliana Mendes',
        cpf: '555.666.777-88',
        crm: 'CRM-SC 18933',
        unidade: 'Unidade Sul',
        matricula: 'US-002',
      ),
      ProfissionalModel.socorrista(
        id: '5',
        nome: 'Marcos Vinícius Santos',
        cpf: '222.333.444-55',
        cnh: '01234567890 (Cat. D)',
        unidade: 'Unidade Norte',
        matricula: 'UN-SOC-001',
      ),
      ProfissionalModel.socorrista(
        id: '6',
        nome: 'Fernanda Rocha',
        cpf: '333.444.555-66',
        cnh: '98765432100 (Cat. D)',
        unidade: 'Unidade Leste',
        matricula: 'UL-SOC-002',
      ),
    ]);

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
      const UnidadeMovelModel(
        id: '3',
        codigo: 'USB-03',
        placa: 'BRA-1923',
        tipo: 'USB (Suporte Básico)',
        regiao: 'Unidade Leste',
        status: 'Operacional',
      ),
      const UnidadeMovelModel(
        id: '4',
        codigo: 'USA-02',
        placa: 'BRA-1924',
        tipo: 'USA (Suporte Avançado)',
        regiao: 'Unidade Oeste',
        status: 'Operacional',
      ),
    ]);
  }

  // Operações de Cadastro
  void adicionarProfissional(ProfissionalModel profissional) {
    _profissionais.add(profissional);
    notifyListeners();
  }

  void removerProfissional(String id) {
    _profissionais.removeWhere((p) => p.id == id);
    notifyListeners();
  }

  void adicionarUnidade(UnidadeMovelModel unidade) {
    _unidades.add(unidade);
    notifyListeners();
  }

  void removerUnidade(String id) {
    _unidades.removeWhere((u) => u.id == id);
    notifyListeners();
  }
}
