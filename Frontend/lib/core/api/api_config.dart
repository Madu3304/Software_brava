// ============================================================================
// CONFIGURAÇÃO CENTRALIZADA DA API REST (FASTAPI)
// Arquivo: lib/core/api/api_config.dart
// ============================================================================

import 'package:flutter/foundation.dart';

class ApiConfig {
  /// URL base configurada via --dart-define=API_URL=http://...
  /// Se não definida, utiliza fallback para emulador Android (10.0.2.2) ou localhost (127.0.0.1)
  static const String _definedUrl = String.fromEnvironment('API_URL');

  static String get baseUrl {
    if (_definedUrl.isNotEmpty) {
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
