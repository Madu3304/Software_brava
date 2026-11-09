import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../core/api/api_client.dart';
import '../models/usuario_model.dart';

class AuthException extends ArgumentError {
  final int? statusCode;
  final String? codigo;

  AuthException(super.message, {this.statusCode, this.codigo});

  @override
  String toString() => message;
}

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  UsuarioModel? _currentUser;
  UsuarioModel? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;

  // Tenta restaurar sessão prévia a partir do storage seguro
  Future<UsuarioModel?> restaurarSessao() async {
    try {
      final token = await _storage.read(key: 'auth_token');
      final perfilStr = await _storage.read(key: 'user_perfil');
      final nome = await _storage.read(key: 'user_nome') ?? 'Usuário SAMU';
      final login = await _storage.read(key: 'user_login') ?? '';
      final id = await _storage.read(key: 'user_id') ?? '';
      final redirect = await _storage.read(key: 'user_redirect');

      if (token != null && token.isNotEmpty && perfilStr != null) {
        _currentUser = UsuarioModel(
          id: id,
          nome: nome,
          login: login,
          perfil: PerfilUsuario.fromString(perfilStr),
          token: token,
          redirecionamento: redirect,
        );
        return _currentUser;
      }
    } catch (e) {
      debugPrint('Erro ao restaurar sessão: $e');
    }
    return null;
  }

  // Realiza login através do endpoint POST /api/auth/login do FastAPI
  Future<UsuarioModel> login(String login, String senha) async {
    final cleanLogin = login.trim();
    final cleanSenha = senha.trim();

    if (cleanLogin.isEmpty || cleanSenha.isEmpty) {
      throw AuthException('Por favor, informe seu usuário e senha.');
    }

    try {
      final response = await ApiClient().dio.post(
        '/auth/login',
        data: {
          'login': cleanLogin,
          'senha': cleanSenha,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        final usuario = UsuarioModel.fromMap(data);

        _currentUser = usuario;

        try {
          if (usuario.token != null) {
            await _storage.write(key: 'auth_token', value: usuario.token!);
          }
          await _storage.write(key: 'user_perfil', value: usuario.perfil.name);
          await _storage.write(key: 'user_nome', value: usuario.nome);
          await _storage.write(key: 'user_login', value: usuario.login);
          await _storage.write(key: 'user_id', value: usuario.id);
          if (usuario.redirecionamento != null) {
            await _storage.write(key: 'user_redirect', value: usuario.redirecionamento!);
          }
        } catch (e) {
          debugPrint('Aviso: Armazenamento seguro indisponível: $e');
        }

        return usuario;
      } else {
        throw AuthException('Não foi possível autenticar. Verifique suas credenciais.');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        final data = e.response?.data;
        if (data is Map && data['detail'] is Map) {
          final detail = data['detail'] as Map;
          final codigo = detail['codigo']?.toString();
          final mensagem = detail['mensagem']?.toString() ??
              'É necessário trocar a senha antes do primeiro acesso.';
          throw AuthException(mensagem, statusCode: 403, codigo: codigo);
        }
        final detailStr = data is Map && data['detail'] != null
            ? data['detail'].toString()
            : 'Acesso negado.';
        throw AuthException(detailStr, statusCode: 403);
      } else if (e.response?.statusCode == 401) {
        final detail = e.response?.data is Map
            ? (e.response?.data['detail'] ?? 'Credenciais inválidas. Verifique seu login e senha.')
            : 'Credenciais inválidas. Verifique seu login e senha.';
        throw AuthException(detail.toString(), statusCode: 401);
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        throw AuthException(
          'Servidor indisponível no momento. Verifique sua conexão com a rede SAMU.',
          statusCode: e.response?.statusCode,
        );
      }
      throw AuthException(
        'Falha na comunicação com o servidor de autenticação. Tente novamente.',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('Erro inesperado durante a autenticação.');
    }
  }

  // Realiza troca de senha obrigatória (POST /api/auth/trocar-senha)
  Future<void> trocarSenha(String login, String senhaAtual, String novaSenha) async {
    try {
      await ApiClient().dio.post(
        '/auth/trocar-senha',
        data: {
          'login': login.trim(),
          'senha_atual': senhaAtual.trim(),
          'nova_senha': novaSenha.trim(),
        },
      );
    } on DioException catch (e) {
      final data = e.response?.data;
      final detail = data is Map && data['detail'] != null
          ? data['detail'].toString()
          : 'Não foi possível alterar a senha. Verifique os dados informados.';
      throw AuthException(detail, statusCode: e.response?.statusCode);
    }
  }

  // Encerra a sessão do usuário de forma segura
  Future<void> logout() async {
    _currentUser = null;
    try {
      await _storage.delete(key: 'auth_token');
      await _storage.delete(key: 'user_perfil');
      await _storage.delete(key: 'user_nome');
      await _storage.delete(key: 'user_login');
      await _storage.delete(key: 'user_id');
      await _storage.delete(key: 'user_redirect');
    } catch (e) {
      debugPrint('Erro ao limpar storage durante logout: $e');
    }
  }
}
