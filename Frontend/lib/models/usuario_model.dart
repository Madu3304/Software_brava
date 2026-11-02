
enum PerfilUsuario {
  admin,
  atendimento,
  medico,
  socorrista,
  enfermeiro;

  static PerfilUsuario fromString(String? val) {
    if (val == null) return PerfilUsuario.atendimento;
    final upper = val.toUpperCase().trim();
    if (upper == 'ADMINISTRADOR' || upper == 'ADMIN') {
      return PerfilUsuario.admin;
    }
    if (upper == 'MEDICO') {
      return PerfilUsuario.medico;
    }
    if (upper == 'ENFERMEIRO') {
      return PerfilUsuario.enfermeiro;
    }
    if (upper == 'TECNICO' || upper == 'CONDUTOR' || upper == 'SOCORRISTA') {
      return PerfilUsuario.socorrista;
    }
    return PerfilUsuario.atendimento;
  }
}

class UsuarioModel {
  final String id;
  final String nome;
  final String login;
  final PerfilUsuario perfil;
  final String? token;
  final String? redirecionamento; // 'WEB' ou 'MOBILE'

  const UsuarioModel({
    required this.id,
    required this.nome,
    required this.login,
    required this.perfil,
    this.token,
    this.redirecionamento,
  });

  bool get isAdmin => perfil == PerfilUsuario.admin;
  bool get isAtendimento =>
      perfil == PerfilUsuario.atendimento ||
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
      'redirecionamento': redirecionamento,
    };
  }

  factory UsuarioModel.fromMap(Map<String, dynamic> map) {
    return UsuarioModel(
      id: (map['id_usuario'] ?? map['id'])?.toString() ?? '',
      nome: map['nome'] ?? '',
      login: map['login'] ?? '',
      perfil: PerfilUsuario.fromString(map['perfil']),
      token: map['access_token'] ?? map['token'],
      redirecionamento: map['redirecionamento'],
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
