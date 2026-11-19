import 'package:flutter/foundation.dart';
import '../core/api/api_client.dart';
import '../models/dashboard_metrics_model.dart';

class DashboardProvider extends ChangeNotifier {
  DashboardMetricsModel _metrics = DashboardMetricsModel.mockDefault();
  Map<String, dynamic>? _paradasViaturas;
  bool _isLoading = false;
  String? _error;

  DashboardMetricsModel get metrics => _metrics;
  Map<String, dynamic>? get paradasViaturas => _paradasViaturas;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> carregarMetricas({
    String? ano,
    String? mes,
    String? dia,
    String? unidade,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final queryParams = <String, dynamic>{};
      if (ano != null && ano.isNotEmpty && !ano.toLowerCase().startsWith('todos')) {
        queryParams['ano'] = ano;
      }
      if (mes != null && mes.isNotEmpty && !mes.toLowerCase().startsWith('todos')) {
        queryParams['mes'] = mes;
      }
      if (dia != null && dia.isNotEmpty && !dia.toLowerCase().startsWith('todos')) {
        queryParams['dia'] = dia;
      }
      if (unidade != null && unidade.isNotEmpty && !unidade.toLowerCase().startsWith('todas')) {
        queryParams['unidade'] = unidade;
      }

      final response = await ApiClient().dio.get(
        '/reports/dashboard',
        queryParameters: queryParams.isEmpty ? null : queryParams,
      );
      if (response.statusCode == 200 && response.data != null) {
        _metrics = DashboardMetricsModel.fromJson(response.data as Map<String, dynamic>);
      }

      try {
        final paradasRes = await ApiClient().dio.get('/reports/paradas-viaturas');
        if (paradasRes.statusCode == 200 && paradasRes.data is Map<String, dynamic>) {
          _paradasViaturas = paradasRes.data as Map<String, dynamic>;
        }
      } catch (e) {
        debugPrint('[DashboardProvider] Aviso ao carregar paradas de viaturas: $e');
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
