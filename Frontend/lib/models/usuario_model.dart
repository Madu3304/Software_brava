// ============================================================================
// MODELO DE ENTIDADE: USUÁRIO E CONTROLE DE ACESSO (RBAC)
// Arquivo: lib/models/usuario_model.dart
// ============================================================================

enum PerfilUsuario {
  admin,
  atendimento,
  medico,
  socorrista,
  enfermeiro,
}

class UsuarioModel {
  final String id;
  final String nome;
  final String login;
  final PerfilUsuario perfil;
  final String? token;

  const UsuarioModel({
    required this.id,
    required this.nome,
    required this.login,
    required this.perfil,
    this.token,
  });

  bool get isAdmin => perfil == PerfilUsuario.admin;
  bool get isAtendimento => perfil == PerfilUsuario.atendimento ||
      perfil == PerfilUsuario.medico ||
      perfil == PerfilUsuario.socorrista ||
      perfil == PerfilUsuario.enfermeiro;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'login': login,
      'perfil': perfil.name,
      'token': token,
    };
  }

  factory UsuarioModel.fromMap(Map<String, dynamic> map) {
    return UsuarioModel(
      id: map['id']?.toString() ?? '',
      nome: map['nome'] ?? '',
      login: map['login'] ?? '',
      perfil: PerfilUsuario.values.firstWhere(
        (e) => e.name == map['perfil'],
        orElse: () => PerfilUsuario.atendimento,
      ),
      token: map['token'],
    );
  }

  Map<String, dynamic> toJson() => toMap();
  factory UsuarioModel.fromJson(Map<String, dynamic> json) => UsuarioModel.fromMap(json);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UsuarioModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          login == other.login;

  @override
  int get hashCode => id.hashCode ^ login.hashCode;
}
