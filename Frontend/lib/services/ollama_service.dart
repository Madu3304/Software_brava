import 'package:flutter/foundation.dart';
import '../core/api/api_client.dart';

class OllamaStatusResult {
  final bool online;
  final String baseUrl;
  final String modeloPadrao;
  final List<String> modelosDisponiveis;

  const OllamaStatusResult({
    required this.online,
    required this.baseUrl,
    required this.modeloPadrao,
    required this.modelosDisponiveis,
  });
}

class OllamaService {
  static final OllamaService _instance = OllamaService._internal();
  factory OllamaService() => _instance;
  OllamaService._internal();

  /// Verifica se o Ollama local está conectado e quais modelos estão disponíveis
  Future<OllamaStatusResult> verificarStatus() async {
    try {
      final res = await ApiClient().dio.get('/ia/status');
      if (res.statusCode == 200 && res.data is Map<String, dynamic>) {
        final data = res.data as Map<String, dynamic>;
        return OllamaStatusResult(
          online: data['online'] == true,
          baseUrl: (data['base_url'] ?? 'http://localhost:11434').toString(),
          modeloPadrao: (data['modelo_padrao'] ?? 'llama3.2:3b').toString(),
          modelosDisponiveis: (data['modelos_disponiveis'] as List? ?? const [])
              .map((e) => e.toString())
              .toList(),
        );
      }
    } catch (e) {
      debugPrint('[OllamaService] Falha ao consultar status do Ollama: $e');
    }
    return const OllamaStatusResult(
      online: false,
      baseUrl: 'http://localhost:11434',
      modeloPadrao: 'llama3.2:3b',
      modelosDisponiveis: [],
    );
  }

  /// Envia mensagem para o modelo Ollama local via Backend (/api/ia/chat)
  Future<String?> enviarMensagem({
    required String mensagem,
    String? contexto,
    String? modelo,
  }) async {
    try {
      final res = await ApiClient().dio.post(
        '/ia/chat',
        data: {
          'mensagem': mensagem,
          if (contexto != null && contexto.isNotEmpty) 'contexto': contexto,
          if (modelo != null && modelo.isNotEmpty) 'modelo': modelo,
        },
      );
      if (res.statusCode == 200 && res.data is Map<String, dynamic>) {
        return res.data['resposta']?.toString();
      }
    } catch (e) {
      debugPrint('[OllamaService] Falha ao gerar resposta no Ollama: $e');
    }
    return null;
  }
}
