// ============================================================================
// SERVIÇO DE AUTENTICAÇÃO E CONTROLE DE ACESSO BASEADO EM FUNÇÃO (RBAC)
// Arquivo: lib/services/auth_service.dart
// ============================================================================

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/usuario_model.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  UsuarioModel? _currentUser;
  UsuarioModel? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;

  /// Realiza login aplicando a regra de negócio do SAMU 192:
  /// - Senha ou usuário contendo 'adm' -> Perfil Admin (Acesso ao Dashboard Web)
  /// - Senha ou usuário com 'atendimento' (ou credencial assistencial) -> Perfil Atendimento (Ficha APH)
  Future<UsuarioModel> login(String login, String senha) async {
    final cleanLogin = login.trim().toLowerCase();
    final cleanSenha = senha.trim().toLowerCase();

    if (cleanLogin.isEmpty || cleanSenha.isEmpty) {
      throw ArgumentError('Login e senha são obrigatórios.');
    }

    // Simula delay de rede / autenticação segura
    await Future.delayed(const Duration(milliseconds: 300));

    final bool isAdmin = cleanLogin.contains('adm') || cleanSenha.contains('adm');
    final perfil = isAdmin ? PerfilUsuario.admin : PerfilUsuario.atendimento;
    final token = 'jwt_token_${DateTime.now().millisecondsSinceEpoch}_${perfil.name}';

    final usuario = UsuarioModel(
      id: isAdmin ? 'usr_adm_01' : 'usr_atend_02',
      nome: isAdmin ? 'Administrador SAMU' : 'Equipe de Atendimento',
      login: login.trim(),
      perfil: perfil,
      token: token,
    );

    _currentUser = usuario;

    try {
      await _storage.write(key: 'auth_token', value: token);
      await _storage.write(key: 'user_perfil', value: perfil.name);
    } catch (_) {
      // Fallback seguro em ambientes Web / testes sem suporte a storage nativo
    }

    return usuario;
  }

  /// Encerra a sessão do usuário
  Future<void> logout() async {
    _currentUser = null;
    try {
      await _storage.delete(key: 'auth_token');
      await _storage.delete(key: 'user_perfil');
    } catch (_) {}
  }
}
