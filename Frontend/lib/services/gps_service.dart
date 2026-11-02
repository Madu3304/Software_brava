import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

class EnderecoGpsResult {
  final String logradouro;
  final String bairro;
  final String cidade;
  final String estado;
  final double? latitude;
  final double? longitude;

  const EnderecoGpsResult({
    required this.logradouro,
    required this.bairro,
    required this.cidade,
    required this.estado,
    this.latitude,
    this.longitude,
  });
}

class GpsService {
  static final GpsService _instance = GpsService._internal();
  factory GpsService() => _instance;
  GpsService._internal();

  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 4),
      receiveTimeout: const Duration(seconds: 4),
    ),
  );

  Future<Position?> obterPosicaoAtual() async {
    try {
      final bool servicoHabilitado = await Geolocator.isLocationServiceEnabled();
      if (!servicoHabilitado) {
        debugPrint('[GpsService] Serviço de localização GPS desativado.');
        return null;
      }

      LocationPermission permissao = await Geolocator.checkPermission();
      if (permissao == LocationPermission.denied) {
        permissao = await Geolocator.requestPermission();
        if (permissao == LocationPermission.denied) {
          debugPrint('[GpsService] Permissão de localização negada pelo usuário.');
          return null;
        }
      }

      if (permissao == LocationPermission.deniedForever) {
        debugPrint('[GpsService] Permissão de localização permanentemente negada.');
        return null;
      }

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 5),
      );
    } catch (e) {
      debugPrint('[GpsService] Falha ao obter posição GPS: $e');
      return null;
    }
  }

  Future<EnderecoGpsResult?> buscarEnderecoPorCep(String cep) async {
    final cleanCep = cep.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanCep.length != 8) {
      return null;
    }

    try {
      final response = await _dio.get('https://viacep.com.br/ws/$cleanCep/json/');

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data is Map && data['erro'] != true) {
          final pos = await obterPosicaoAtual();
          return EnderecoGpsResult(
            logradouro: data['logradouro']?.toString() ?? '',
            bairro: data['bairro']?.toString() ?? '',
            cidade: data['localidade']?.toString() ?? '',
            estado: data['uf']?.toString() ?? '',
            latitude: pos?.latitude,
            longitude: pos?.longitude,
          );
        }
      }
    } catch (e) {
      debugPrint('[GpsService] Falha ao consultar CEP $cleanCep via Dio: $e');
    }
    return null;
  }
}
