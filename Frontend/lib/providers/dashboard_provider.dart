import 'package:flutter/foundation.dart';
import '../core/api/api_client.dart';
import '../models/dashboard_metrics_model.dart';

class DashboardProvider extends ChangeNotifier {
  DashboardMetricsModel _metrics = DashboardMetricsModel.mockDefault();
  bool _isLoading = false;
  String? _error;

  DashboardMetricsModel get metrics => _metrics;
  bool get isLoading => _isLoading;
  String? get error => _error;

  DashboardProvider() {
    carregarMetricas();
  }

  Future<void> carregarMetricas() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiClient().dio.get('/reports/dashboard');
      if (response.statusCode == 200 && response.data != null) {
        _metrics = DashboardMetricsModel.fromJson(response.data as Map<String, dynamic>);
      }
    } catch (e) {
      _error = 'Não foi possível atualizar as métricas do servidor em tempo real.';
      debugPrint('[DashboardProvider] Falha ao carregar métricas: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
