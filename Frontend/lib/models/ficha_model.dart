// ============================================================================
// MODELO DE ENTIDADE: FICHA DE ATENDIMENTO PRÉ-HOSPITALAR (APH / SAMU)
// Arquivo: lib/models/ficha_model.dart
// ============================================================================

enum StatusSincronizacao {
  pendente,
  sincronizado,
  erro,
}

enum CodigoTriagem {
  vermelho,
  amarelo,
  verde,
  azul,
}

class FichaAtendimentoModel {
  final String id;
  final String numeroOcorrencia;
  final DateTime dataHora;
  final String pacienteNome;
  final int? pacienteIdade;
  final String? pacienteSexo;
  final String tipoOcorrencia; // Trauma, Clínico, Obstétrico, Psiquiátrico
  final String endereco;
  final double? latitude;
  final double? longitude;
  final String unidadeResponsavel;
  final String? queixaPrincipal;
  final String? condutaMedica;
  final StatusSincronizacao statusSincronizacao;

  // Campos específicos da Ficha SAMU (Triage & Registro)
  final String tipoViatura; // Ex.: USB, USA
  final String codigoTriagem; // Vermelho, Amarelo, Verde, Azul
  final String? base;
  final String? medicoResponsavel;
  final String? tecnicoResponsavel;
  final String? condutorSocorrista;
  final String? horaAberturaChamado;
  final String? horaSaidaBase;

  const FichaAtendimentoModel({
    required this.id,
    required this.numeroOcorrencia,
    required this.dataHora,
    required this.pacienteNome,
    this.pacienteIdade,
    this.pacienteSexo,
    required this.tipoOcorrencia,
    required this.endereco,
    this.latitude,
    this.longitude,
    required this.unidadeResponsavel,
    this.queixaPrincipal,
    this.condutaMedica,
    this.statusSincronizacao = StatusSincronizacao.pendente,
    this.tipoViatura = 'USB',
    this.codigoTriagem = 'Vermelho',
    this.base,
    this.medicoResponsavel,
    this.tecnicoResponsavel,
    this.condutorSocorrista,
    this.horaAberturaChamado,
    this.horaSaidaBase,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'numeroOcorrencia': numeroOcorrencia,
      'dataHora': dataHora.toIso8601String(),
      'pacienteNome': pacienteNome,
      'pacienteIdade': pacienteIdade,
      'pacienteSexo': pacienteSexo,
      'tipoOcorrencia': tipoOcorrencia,
      'endereco': endereco,
      'latitude': latitude,
      'longitude': longitude,
      'unidadeResponsavel': unidadeResponsavel,
      'queixaPrincipal': queixaPrincipal,
      'condutaMedica': condutaMedica,
      'statusSincronizacao': statusSincronizacao.name,
      'tipoViatura': tipoViatura,
      'codigoTriagem': codigoTriagem,
      'base': base,
      'medicoResponsavel': medicoResponsavel,
      'tecnicoResponsavel': tecnicoResponsavel,
      'condutorSocorrista': condutorSocorrista,
      'horaAberturaChamado': horaAberturaChamado,
      'horaSaidaBase': horaSaidaBase,
    };
  }

  factory FichaAtendimentoModel.fromMap(Map<String, dynamic> map) {
    return FichaAtendimentoModel(
      id: map['id']?.toString() ?? '',
      numeroOcorrencia: map['numeroOcorrencia'] ?? '',
      dataHora: map['dataHora'] != null
          ? DateTime.tryParse(map['dataHora']) ?? DateTime.now()
          : DateTime.now(),
      pacienteNome: map['pacienteNome'] ?? '',
      pacienteIdade: map['pacienteIdade'] is int
          ? map['pacienteIdade']
          : int.tryParse(map['pacienteIdade']?.toString() ?? ''),
      pacienteSexo: map['pacienteSexo'],
      tipoOcorrencia: map['tipoOcorrencia'] ?? 'Clínico',
      endereco: map['endereco'] ?? '',
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
      unidadeResponsavel: map['unidadeResponsavel'] ?? '',
      queixaPrincipal: map['queixaPrincipal'],
      condutaMedica: map['condutaMedica'],
      statusSincronizacao: StatusSincronizacao.values.firstWhere(
        (e) => e.name == map['statusSincronizacao'],
        orElse: () => StatusSincronizacao.pendente,
      ),
      tipoViatura: map['tipoViatura'] ?? 'USB',
      codigoTriagem: map['codigoTriagem'] ?? 'Vermelho',
      base: map['base'],
      medicoResponsavel: map['medicoResponsavel'],
      tecnicoResponsavel: map['tecnicoResponsavel'],
      condutorSocorrista: map['condutorSocorrista'],
      horaAberturaChamado: map['horaAberturaChamado'],
      horaSaidaBase: map['horaSaidaBase'],
    );
  }

  Map<String, dynamic> toJson() => toMap();
  factory FichaAtendimentoModel.fromJson(Map<String, dynamic> json) =>
      FichaAtendimentoModel.fromMap(json);

  FichaAtendimentoModel copyWith({
    String? id,
    String? numeroOcorrencia,
    DateTime? dataHora,
    String? pacienteNome,
    int? pacienteIdade,
    String? pacienteSexo,
    String? tipoOcorrencia,
    String? endereco,
    double? latitude,
    double? longitude,
    String? unidadeResponsavel,
    String? queixaPrincipal,
    String? condutaMedica,
    StatusSincronizacao? statusSincronizacao,
    String? tipoViatura,
    String? codigoTriagem,
    String? base,
    String? medicoResponsavel,
    String? tecnicoResponsavel,
    String? condutorSocorrista,
    String? horaAberturaChamado,
    String? horaSaidaBase,
  }) {
    return FichaAtendimentoModel(
      id: id ?? this.id,
      numeroOcorrencia: numeroOcorrencia ?? this.numeroOcorrencia,
      dataHora: dataHora ?? this.dataHora,
      pacienteNome: pacienteNome ?? this.pacienteNome,
      pacienteIdade: pacienteIdade ?? this.pacienteIdade,
      pacienteSexo: pacienteSexo ?? this.pacienteSexo,
      tipoOcorrencia: tipoOcorrencia ?? this.tipoOcorrencia,
      endereco: endereco ?? this.endereco,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      unidadeResponsavel: unidadeResponsavel ?? this.unidadeResponsavel,
      queixaPrincipal: queixaPrincipal ?? this.queixaPrincipal,
      condutaMedica: condutaMedica ?? this.condutaMedica,
      statusSincronizacao: statusSincronizacao ?? this.statusSincronizacao,
      tipoViatura: tipoViatura ?? this.tipoViatura,
      codigoTriagem: codigoTriagem ?? this.codigoTriagem,
      base: base ?? this.base,
      medicoResponsavel: medicoResponsavel ?? this.medicoResponsavel,
      tecnicoResponsavel: tecnicoResponsavel ?? this.tecnicoResponsavel,
      condutorSocorrista: condutorSocorrista ?? this.condutorSocorrista,
      horaAberturaChamado: horaAberturaChamado ?? this.horaAberturaChamado,
      horaSaidaBase: horaSaidaBase ?? this.horaSaidaBase,
    );
  }
}
