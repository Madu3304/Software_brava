// ============================================================================
// CONFIGURAÇÃO CENTRALIZADA DA API REST (FASTAPI)
// Arquivo: lib/core/api/api_config.dart
// ============================================================================

import 'package:flutter/foundation.dart';

class ApiConfig {
  /// URL base configurada via --dart-define=API_URL=https://...
  /// Se não definida, utiliza fallback para emulador Android (10.0.2.2) ou localhost (127.0.0.1)
  static const String _definedUrl = String.fromEnvironment('API_URL');

  /// Fingerprint SHA-256 (hex) do certificado TLS esperado para Certificate Pinning
  /// Configurado via --dart-define=API_CERT_SHA256=<64-hex-chars>
  static const String certSha256Pin = String.fromEnvironment('API_CERT_SHA256');

  static bool isSecureTransportAllowed(String url, {bool? isRelease}) {
    final release = isRelease ?? kReleaseMode;
    final uri = Uri.tryParse(url);
    if (uri == null || !uri.hasScheme) return false;
    if (uri.scheme.toLowerCase() == 'https') return true;
    if (!release) {
      final host = uri.host.toLowerCase();
      return host == 'localhost' || host == '127.0.0.1' || host == '10.0.2.2';
    }
    return false;
  }

  static String get baseUrl {
    if (_definedUrl.isNotEmpty) {
      if (_definedUrl.toUpperCase() == 'SAME_ORIGIN') {
        if (kIsWeb) {
          return Uri.base.origin;
        }
        return 'http://127.0.0.1:8000';
      }
      return _definedUrl.endsWith('/')
          ? _definedUrl.substring(0, _definedUrl.length - 1)
          : _definedUrl;
    }

    // Fallback inteligente para ambiente de desenvolvimento local
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8000';
    }
    return 'http://127.0.0.1:8000';
  }

  static String get apiBaseUrl => '$baseUrl/api';
}
