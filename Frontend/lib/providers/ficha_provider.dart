import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/ficha_model.dart';

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
      statusSincronizacao: StatusSincronizacao.pendente,
    );
    notifyListeners();
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
