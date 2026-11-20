import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../core/api/api_client.dart';

/// Resultado de uma tentativa de criação de envelope DocuSign.
///
/// [sucesso] indica se o backend confirmou a criação real do envelope.
/// Quando [sucesso] é false o [status] vale 'offline_pendente' e a UI deve
/// informar ao operador que o envio ficou pendente — sem simular conclusão.
class DocuSignEnvelopeResult {
  final bool sucesso;
  final String envelopeId;
  final String status;
  final String signingUrl;
  final String mensagem;

  const DocuSignEnvelopeResult({
    required this.sucesso,
    required this.envelopeId,
    required this.status,
    required this.signingUrl,
    required this.mensagem,
  });
}

class DocuSignService {
  /// Cria um envelope de assinatura eletrônica via backend.
  ///
  /// **Comportamento de falha:**
  /// Se o backend não estiver disponível ou retornar erro, o método retorna
  /// [sucesso: false, status: 'offline_pendente'] — nunca simula "completed".
  /// A camada de UI é responsável por exibir o estado pendente claramente ao
  /// operador, sem induzir a crença de que há um envelope jurídico válido.
  Future<DocuSignEnvelopeResult> criarEnvelope({
    required String numeroOcorrencia,
    required String pacienteNome,
    String? pacienteCpf,
    String? email,
    String? telefone,
    String? condutaResumo,
  }) async {
    try {
      final response = await ApiClient().dio.post(
        '/docusign/envelopes',
        data: {
          'numero_ocorrencia': numeroOcorrencia,
          'paciente_nome': pacienteNome,
          'paciente_cpf': pacienteCpf,
          'email_destinatario': email,
          'telefone_destinatario': telefone,
          'conduta_resumo': condutaResumo,
        },
        options: Options(
          sendTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 5),
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data as Map<String, dynamic>;
        return DocuSignEnvelopeResult(
          sucesso: true,
          envelopeId: data['envelope_id']?.toString() ?? '',
          status: data['status']?.toString() ?? 'sent',
          signingUrl: data['signing_url']?.toString() ?? '',
          mensagem: data['mensagem']?.toString() ?? 'Envelope DocuSign criado com sucesso.',
        );
      }

      // Resposta inesperada do backend (ex.: 4xx/5xx fora do catch)
      debugPrint('[DocuSignService] Resposta inesperada: ${response.statusCode}');
    } on DioException catch (e) {
      debugPrint('[DocuSignService] Falha de rede ao criar envelope: ${e.message}');
    } catch (e) {
      debugPrint('[DocuSignService] Erro inesperado: $e');
    }

    // Falha real — retorna estado pendente claro, sem simular sucesso.
    // A UI deve exibir mensagem orientando o operador a reenviar quando
    // a conexão for restabelecida.
    return const DocuSignEnvelopeResult(
      sucesso: false,
      envelopeId: '',
      status: 'offline_pendente',
      signingUrl: '',
      mensagem:
          'Não foi possível conectar ao serviço de assinatura. '
          'O envio do termo ficou pendente e será retransmitido quando a '
          'conexão for restabelecida.',
    );
  }
}
