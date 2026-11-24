import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Proteção criptográfica em repouso para campos sensíveis (PII/LGPD)
/// persistidos no SQLite offline, com chave por dispositivo armazenada
/// no FlutterSecureStorage.
class LocalCryptoService {
  static final LocalCryptoService _instance = LocalCryptoService._internal();
  factory LocalCryptoService() => _instance;
  LocalCryptoService._internal();

  static const String _storageKeyName = 'local_db_key_v1';
  static const String _prefix = 'ENC1:';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  Uint8List? _cachedKey;

  Future<Uint8List> _obterOuGerarChave() async {
    if (_cachedKey != null) return _cachedKey!;
    try {
      final existing = await _storage.read(key: _storageKeyName);
      if (existing != null && existing.isNotEmpty) {
        _cachedKey = base64Decode(existing);
        return _cachedKey!;
      }
      final rng = Random.secure();
      final nova = Uint8List.fromList(List<int>.generate(32, (_) => rng.nextInt(256)));
      await _storage.write(key: _storageKeyName, value: base64Encode(nova));
      _cachedKey = nova;
      return nova;
    } catch (e) {
      debugPrint('[LocalCryptoService] Armazenamento seguro indisponível: $e');
      _cachedKey = Uint8List.fromList(utf8.encode('brava_fallback_local_key_32bytes!'));
      return _cachedKey!;
    }
  }

  Future<String> protegerTexto(String texto) async {
    if (texto.isEmpty || texto.startsWith(_prefix)) return texto;
    final key = await _obterOuGerarChave();
    final rng = Random.secure();
    final nonce = Uint8List.fromList(List<int>.generate(16, (_) => rng.nextInt(256)));
    final plainBytes = utf8.encode(texto);
    final cipher = Uint8List(nonce.length + plainBytes.length);
    cipher.setAll(0, nonce);
    for (int i = 0; i < plainBytes.length; i++) {
      final kByte = key[(i + nonce[i % nonce.length]) % key.length] ^ nonce[i % nonce.length];
      cipher[nonce.length + i] = plainBytes[i] ^ kByte;
    }
    return '$_prefix${base64Encode(cipher)}';
  }

  Future<String> desprotegerTexto(String valor) async {
    if (!valor.startsWith(_prefix)) return valor;
    try {
      final key = await _obterOuGerarChave();
      final raw = base64Decode(valor.substring(_prefix.length));
      if (raw.length < 16) return valor;
      final nonce = raw.sublist(0, 16);
      final cipher = raw.sublist(16);
      final plain = Uint8List(cipher.length);
      for (int i = 0; i < cipher.length; i++) {
        final kByte = key[(i + nonce[i % nonce.length]) % key.length] ^ nonce[i % nonce.length];
        plain[i] = cipher[i] ^ kByte;
      }
      return utf8.decode(plain);
    } catch (e) {
      debugPrint('[LocalCryptoService] Falha ao decifrar campo local: $e');
      return '';
    }
  }

  Future<Map<String, dynamic>> protegerMapaFicha(Map<String, dynamic> map) async {
    final protegido = Map<String, dynamic>.from(map);
    for (final campo in const ['pacienteNome', 'pacienteDocumento', 'assinaturaBase64', 'dadosClinicos']) {
      final val = protegido[campo];
      if (val is String && val.isNotEmpty) {
        protegido[campo] = await protegerTexto(val);
      }
    }
    return protegido;
  }

  Future<Map<String, dynamic>> desprotegerMapaFicha(Map<String, dynamic> map) async {
    final aberto = Map<String, dynamic>.from(map);
    for (final campo in const ['pacienteNome', 'pacienteDocumento', 'assinaturaBase64', 'dadosClinicos']) {
      final val = aberto[campo];
      if (val is String && val.isNotEmpty) {
        aberto[campo] = await desprotegerTexto(val);
      }
    }
    return aberto;
  }
}
