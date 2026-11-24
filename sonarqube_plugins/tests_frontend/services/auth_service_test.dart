import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:software_brava/core/api/api_client.dart';
import 'package:software_brava/models/usuario_model.dart';
import 'package:software_brava/services/auth_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AuthService RBAC & API Tests', () {
    late AuthService authService;
    late Interceptor mockAuthInterceptor;

    setUp(() {
      authService = AuthService();

      mockAuthInterceptor = QueuedInterceptorsWrapper(
        onRequest: (options, handler) {
          if (options.path.contains('/auth/login')) {
            final data = options.data as Map<String, dynamic>? ?? {};
            final login = data['login'] as String? ?? '';
            final senha = data['senha'] as String? ?? '';

            if (login == 'invalido') {
              return handler.reject(
                DioException(
                  requestOptions: options,
                  response: Response(
                    requestOptions: options,
                    statusCode: 401,
                    data: {'detail': 'Credenciais inválidas. Verifique seu login e senha.'},
                  ),
                ),
              );
            }

            if (login.contains('adm') || senha.contains('adm')) {
              return handler.resolve(
                Response(
                  requestOptions: options,
                  statusCode: 200,
                  data: {
                    'access_token': 'mock_token_admin',
                    'token_type': 'bearer',
                    'usuario': {
                      'id': 'usr_admin',
                      'nome': 'Administrador Geral',
                      'login': login,
                      'perfil': 'administrador',
                    },
                    'redirecionamento': '/admin/dashboard',
                  },
                ),
              );
            } else {
              return handler.resolve(
                Response(
                  requestOptions: options,
                  statusCode: 200,
                  data: {
                    'access_token': 'mock_token_atendimento',
                    'token_type': 'bearer',
                    'usuario': {
                      'id': 'usr_atendimento',
                      'nome': 'Socorrista Bravo',
                      'login': login,
                      'perfil': 'atendimento',
                    },
                    'redirecionamento': '/ficha',
                  },
                ),
              );
            }
          }
          return handler.next(options);
        },
      );

      ApiClient().dio.interceptors.insert(0, mockAuthInterceptor);
    });

    tearDown(() async {
      ApiClient().dio.interceptors.remove(mockAuthInterceptor);
      await authService.logout();
    });

    test('Login com credenciais contendo adm deve atribuir PerfilUsuario.admin', () async {
      final usuario = await authService.login('admin', '123456');

      expect(usuario.perfil, PerfilUsuario.admin);
      expect(usuario.isAdmin, isTrue);
      expect(usuario.isAtendimento, isFalse);
      expect(authService.currentUser, equals(usuario));
      expect(authService.isAuthenticated, isTrue);
    });

    test('Login com senha adm deve atribuir perfil de administrador', () async {
      final usuario = await authService.login('coordenador', 'senha_adm_2026');

      expect(usuario.perfil, PerfilUsuario.admin);
      expect(usuario.isAdmin, isTrue);
    });

    test('Login com credenciais operacionais deve atribuir PerfilUsuario.atendimento', () async {
      final usuario = await authService.login('atendimento', 'socorro192');

      expect(usuario.perfil, PerfilUsuario.atendimento);
      expect(usuario.isAdmin, isFalse);
      expect(usuario.isAtendimento, isTrue);
    });

    test('Tentativa de login com campos vazios deve lançar ArgumentError', () async {
      expect(
        () => authService.login('', ''),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('Login com credenciais inválidas (401) deve lançar AuthException amigável', () async {
      expect(
        () => authService.login('invalido', 'errada'),
        throwsA(isA<AuthException>()),
      );
    });

    test('Logout deve limpar o usuário autenticado', () async {
      await authService.login('admin', 'adm123');
      expect(authService.isAuthenticated, isTrue);

      await authService.logout();
      expect(authService.isAuthenticated, isFalse);
      expect(authService.currentUser, isNull);
    });
  });
}
