import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/ficha_model.dart';
import '../services/database_service.dart';

class FichaEmAndamentoProvider extends ChangeNotifier {
  FichaAtendimentoModel? _ficha;
  String _perfilAtendimento = 'comum';
  final Set<String> _condicoesIdentificadas = {};

  FichaAtendimentoModel? get ficha => _ficha;
  bool get hasFicha => _ficha != null;
  String get perfilAtendimento => _perfilAtendimento;
  Set<String> get condicoesIdentificadas => Set.unmodifiable(_condicoesIdentificadas);

  void selecionarPerfil(String perfil) {
    _perfilAtendimento = perfil;
    _condicoesIdentificadas.clear();
    notifyListeners();
  }

  void alternarCondicao(String condicao) {
    if (_condicoesIdentificadas.contains(condicao)) {
      _condicoesIdentificadas.remove(condicao);
    } else {
      _condicoesIdentificadas.add(condicao);
    }
    notifyListeners();
  }

  String _tipoOcorrenciaPorPerfil() {
    if (_perfilAtendimento == 'gestante') return 'Obstétrico (Gestante)';
    if (_perfilAtendimento == 'idoso') return 'Geriátrico (Idoso)';
    return 'Atendimento Pré-Hospitalar';
  }

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
      tipoOcorrencia: _tipoOcorrenciaPorPerfil(),
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
