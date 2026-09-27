// ============================================================================
// MODELO DE ENTIDADE: UNIDADE MÓVEL (AMBULÂNCIA / VIATURA SAMU)
// Arquivo: lib/models/unidade_model.dart
// ============================================================================

class UnidadeMovelModel {
  final String id;
  final String codigo;
  final String placa;
  final String tipo; // USA - Suporte Avançado / USB - Suporte Básico / VIR
  final String regiao; // Unidade Norte, Sul, Leste, Oeste
  final String status; // Operacional, Em Atendimento, Em Manutenção

  const UnidadeMovelModel({
    required this.id,
    required this.codigo,
    required this.placa,
    required this.tipo,
    required this.regiao,
    this.status = 'Operacional',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'codigo': codigo,
      'placa': placa,
      'tipo': tipo,
      'regiao': regiao,
      'status': status,
    };
  }

  factory UnidadeMovelModel.fromMap(Map<String, dynamic> map) {
    return UnidadeMovelModel(
      id: map['id']?.toString() ?? '',
      codigo: map['codigo'] ?? '',
      placa: map['placa'] ?? '',
      tipo: map['tipo'] ?? 'USB (Suporte Básico)',
      regiao: map['regiao'] ?? 'Unidade Norte',
      status: map['status'] ?? 'Operacional',
    );
  }

  Map<String, dynamic> toJson() => toMap();
  factory UnidadeMovelModel.fromJson(Map<String, dynamic> json) =>
      UnidadeMovelModel.fromMap(json);

  UnidadeMovelModel copyWith({
    String? id,
    String? codigo,
    String? placa,
    String? tipo,
    String? regiao,
    String? status,
  }) {
    return UnidadeMovelModel(
      id: id ?? this.id,
      codigo: codigo ?? this.codigo,
      placa: placa ?? this.placa,
      tipo: tipo ?? this.tipo,
      regiao: regiao ?? this.regiao,
      status: status ?? this.status,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UnidadeMovelModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          codigo == other.codigo;

  @override
  int get hashCode => id.hashCode ^ codigo.hashCode;
}
