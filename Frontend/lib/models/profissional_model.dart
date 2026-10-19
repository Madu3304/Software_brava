// ============================================================================
// MODELO DE ENTIDADE: PROFISSIONAIS DE SAÚDE E OPERAÇÃO (SAMU)
// Arquivo: lib/models/profissional_model.dart
// ============================================================================

enum TipoProfissional {
  medico,
  enfermeiro,
  socorrista,
}

class ProfissionalModel {
  final String id;
  final String nome;
  final String cpf;
  final String registroConselho; // CRM, COREN ou CNH
  final TipoProfissional tipo;
  final String unidade;
  final String matricula;

  const ProfissionalModel({
    required this.id,
    required this.nome,
    required this.cpf,
    required this.registroConselho,
    required this.tipo,
    required this.unidade,
    required this.matricula,
  });

  String get crm => registroConselho;
  String get coren => registroConselho;
  String get cnh => registroConselho;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'cpf': cpf,
      'registroConselho': registroConselho,
      'tipo': tipo.name,
      'unidade': unidade,
      'matricula': matricula,
    };
  }

  factory ProfissionalModel.fromMap(Map<String, dynamic> map) {
    return ProfissionalModel(
      id: map['id']?.toString() ?? '',
      nome: map['nome'] ?? '',
      cpf: map['cpf'] ?? '',
      registroConselho: map['registroConselho'] ?? '',
      tipo: TipoProfissional.values.firstWhere(
        (e) => e.name == map['tipo'],
        orElse: () => TipoProfissional.enfermeiro,
      ),
      unidade: map['unidade'] ?? '',
      matricula: map['matricula'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => toMap();
  factory ProfissionalModel.fromJson(Map<String, dynamic> json) =>
      ProfissionalModel.fromMap(json);

  // Fábricas auxiliares especializadas
  factory ProfissionalModel.medico({
    required String id,
    required String nome,
    required String cpf,
    required String crm,
    required String unidade,
    required String matricula,
  }) {
    return ProfissionalModel(
      id: id,
      nome: nome,
      cpf: cpf,
      registroConselho: crm,
      tipo: TipoProfissional.medico,
      unidade: unidade,
      matricula: matricula,
    );
  }

  factory ProfissionalModel.tecnicoEnfermagem({
    required String id,
    required String nome,
    required String cpf,
    required String coren,
    required String unidade,
    required String matricula,
  }) {
    return ProfissionalModel(
      id: id,
      nome: nome,
      cpf: cpf,
      registroConselho: coren,
      tipo: TipoProfissional.enfermeiro,
      unidade: unidade,
      matricula: matricula,
    );
  }

  factory ProfissionalModel.socorrista({
    required String id,
    required String nome,
    required String cpf,
    required String cnh,
    required String unidade,
    required String matricula,
  }) {
    return ProfissionalModel(
      id: id,
      nome: nome,
      cpf: cpf,
      registroConselho: cnh,
      tipo: TipoProfissional.socorrista,
      unidade: unidade,
      matricula: matricula,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProfissionalModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          cpf == other.cpf;

  @override
  int get hashCode => id.hashCode ^ cpf.hashCode;
}
