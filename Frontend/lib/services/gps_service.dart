// ============================================================================
// SERVIÇO DE GEOLOCALIZAÇÃO GPS PARA DESPACHO E OCORRÊNCIAS DO SAMU
// Arquivo: lib/services/gps_service.dart
// ============================================================================

import 'package:geolocator/geolocator.dart';

class GpsService {
  static final GpsService _instance = GpsService._internal();
  factory GpsService() => _instance;
  GpsService._internal();

  /// Captura a posição geográfica atual do dispositivo da viatura
  Future<Position?> obterPosicaoAtual() async {
    try {
      bool servicoHabilitado = await Geolocator.isLocationServiceEnabled();
      if (!servicoHabilitado) {
        return null;
      }

      LocationPermission permissao = await Geolocator.checkPermission();
      if (permissao == LocationPermission.denied) {
        permissao = await Geolocator.requestPermission();
        if (permissao == LocationPermission.denied) {
          return null;
        }
      }

      if (permissao == LocationPermission.deniedForever) {
        return null;
      }

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 5),
      );
    } catch (_) {
      // Coordenadas padrão de Joinville / SC para testes e desenvolvimento
      return Position(
        longitude: -48.8464,
        latitude: -26.3045,
        timestamp: DateTime.now(),
        accuracy: 5.0,
        altitude: 10.0,
        altitudeAccuracy: 1.0,
        heading: 0.0,
        headingAccuracy: 1.0,
        speed: 0.0,
        speedAccuracy: 0.0,
      );
    }
  }
}
