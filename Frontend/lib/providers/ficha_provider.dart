import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/ficha_model.dart';
import '../services/database_service.dart';

class FichaEmAndamentoProvider extends ChangeNotifier {
  FichaAtendimentoModel? _ficha;

  FichaAtendimentoModel? get ficha => _ficha;
  bool get hasFicha => _ficha != null;

  void iniciarFicha({
    String tipoViatura = 'USB',
    String codigoTriagem = 'Vermelho',
    DateTime? dataAtendimento,
    String? base,
    String? numeroOcorrencia,
    String? medicoResponsavel,
    String? tecnicoResponsavel,
    String? condutorSocorrista,
    String? horaAbertura,
    String? horaSaida,
    bool unidadeParada = false,
    String? motivoUnidadeParada,
  }) {
    final now = dataAtendimento ?? DateTime.now();
    final ocorrencia = (numeroOcorrencia != null && numeroOcorrencia.trim().isNotEmpty)
        ? numeroOcorrencia.trim()
        : 'REG-${now.millisecondsSinceEpoch.toString().substring(7)}';

    _ficha = FichaAtendimentoModel(
      id: const Uuid().v4(), 
      numeroOcorrencia: ocorrencia,
      dataHora: now,
      pacienteNome: '',
      tipoOcorrencia: 'Atendimento Pré-Hospitalar',
      endereco: base ?? '',
      unidadeResponsavel: tipoViatura,
      tipoViatura: tipoViatura,
      codigoTriagem: codigoTriagem,
      base: base,
      medicoResponsavel: medicoResponsavel,
      tecnicoResponsavel: tecnicoResponsavel,
      condutorSocorrista: condutorSocorrista,
      horaAberturaChamado: horaAbertura,
      horaSaidaBase: horaSaida,
      unidadeParada: unidadeParada,
      motivoUnidadeParada: motivoUnidadeParada,
      statusSincronizacao: StatusSincronizacao.pendente,
    );
    notifyListeners();
  }

  /// Auto-salvamento em caso de interrupção por emergência crítica (RF04 / FA02)
  Future<void> salvarRascunhoAutomatico() async {
    if (_ficha == null) return;
    try {
      await DatabaseService().inserirFicha(_ficha!);
    } catch (e) {
      debugPrint('[FichaEmAndamentoProvider] Aviso ao auto-salvar rascunho: $e');
    }
  }

  void setFicha(FichaAtendimentoModel ficha) {
    _ficha = ficha;
    notifyListeners();
  }

  void atualizarCampos(FichaAtendimentoModel Function(FichaAtendimentoModel atual) updater) {
    if (_ficha != null) {
      _ficha = updater(_ficha!);
      notifyListeners();
    }
  }

  void limpar() {
    _ficha = null;
    notifyListeners();
  }
}
