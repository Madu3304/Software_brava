import 'package:flutter_test/flutter_test.dart';
import 'package:software_brava/models/usuario_model.dart';
import 'package:software_brava/services/auth_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AuthService RBAC Tests', () {
    late AuthService authService;

    setUp(() {
      authService = AuthService();
    });

    tearDown(() async {
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

    test('Logout deve limpar o usuário autenticado', () async {
      await authService.login('admin', 'adm123');
      expect(authService.isAuthenticated, isTrue);

      await authService.logout();
      expect(authService.isAuthenticated, isFalse);
      expect(authService.currentUser, isNull);
    });
  });
}
