import 'package:flutter_test/flutter_test.dart';
import 'package:software_brava/models/ficha_model.dart';
import 'package:software_brava/providers/ficha_provider.dart';
import 'package:software_brava/utils/cpf_validator.dart';

void main() {
  group('FichaAtendimentoModel Tests', () {
    test('toMap, fromMap, toBackendPayload e copyWith preservam dados clínicos', () {
      final agora = DateTime(2026, 11, 22, 10, 30);
      final ficha = FichaAtendimentoModel(
        id: 'uuid-123',
        numeroOcorrencia: 'REG-123',
        dataHora: agora,
        pacienteNome: 'Maria Silva',
        pacienteIdade: 30,
        pacienteDataNascimento: '1996-05-10',
        pacienteSexo: 'Feminino',
        pacienteCpf: '52998224725',
        acompanhante: 'João Silva',
        grauParentesco: 'Cônjuge',
        telefoneContato: '47999990000',
        medicamentosUsoContinuo: 'Metildopa',
        alergias: 'Dipirona',
        observacoes: 'Gestante 38 semanas',
        tipoOcorrencia: 'Obstétrico',
        endereco: 'Rua Central, 100',
        latitude: -26.3044,
        longitude: -48.8487,
        unidadeResponsavel: 'USB-01',
        queixaPrincipal: 'Contrações',
        condutaMedica: 'Encaminhamento',
        statusSincronizacao: StatusSincronizacao.pendente,
        tipoViatura: 'USB',
        codigoTriagem: 'Vermelho',
        base: 'Base Central',
        medicoResponsavel: 'Dr. Roberto',
        tecnicoResponsavel: 'Ana Paula',
        condutorSocorrista: 'Marcos',
        horaAberturaChamado: '10:25',
        horaSaidaBase: '10:27',
        pressaoArterial: '120/80',
        frequenciaCardiaca: 85,
        frequenciaRespiratoria: 18,
        saturacaoO2: 98,
        glicemia: 95,
        temperatura: 36.5,
        escalaGlasgow: 15,
        aberturaOcular: 4,
        respostaVerbal: 5,
        respostaMotora: 6,
        avcSuspeito: false,
        assimetriaFacial: false,
        quedaBraco: false,
        falaAnormal: false,
        unidadeParada: false,
        pendenciaLocalizacao: false,
      );

      final map = ficha.toMap();
      final reconstruida = FichaAtendimentoModel.fromMap(map);
      expect(reconstruida.id, 'uuid-123');
      expect(reconstruida.pacienteNome, 'Maria Silva');
      expect(reconstruida.pressaoArterial, '120/80');
      expect(reconstruida.escalaGlasgow, 15);

      final atualizada = reconstruida.copyWith(
        statusSincronizacao: StatusSincronizacao.sincronizado,
        queixaPrincipal: 'Parto iminente',
      );
      expect(atualizada.statusSincronizacao, StatusSincronizacao.sincronizado);
      expect(atualizada.queixaPrincipal, 'Parto iminente');
      expect(atualizada.pacienteNome, 'Maria Silva');

      final backendPayload = atualizada.toBackendSyncJson(idUnidade: 1);
      expect(backendPayload['uuid_offline'], 'uuid-123');
      expect(backendPayload['id_unidade'], 1);
      expect(backendPayload['paciente']['nome'], 'Maria Silva');
      expect(backendPayload['avaliacao_clinica']['escala_glasgow'], 15);
    });
  });

  group('FichaEmAndamentoProvider Tests', () {
    test('selecionarPerfil, alternarCondicao, iniciarFicha e atualizarCampos', () {
      final provider = FichaEmAndamentoProvider();
      expect(provider.perfilAtendimento, 'comum');
      expect(provider.hasFicha, false);

      provider.selecionarPerfil('gestante');
      expect(provider.perfilAtendimento, 'gestante');

      provider.alternarCondicao('Dor abdominal');
      expect(provider.condicoesIdentificadas.contains('Dor abdominal'), true);
      provider.alternarCondicao('Dor abdominal');
      expect(provider.condicoesIdentificadas.contains('Dor abdominal'), false);

      provider.iniciarFicha(tipoViatura: 'USA', codigoTriagem: 'Amarelo');
      expect(provider.hasFicha, true);
      expect(provider.ficha!.tipoOcorrencia, 'Obstétrico (Gestante)');
      expect(provider.ficha!.codigoTriagem, 'Amarelo');

      provider.atualizarCampos((f) => f.copyWith(pacienteNome: 'Ana'));
      expect(provider.ficha!.pacienteNome, 'Ana');

      provider.limpar();
      expect(provider.hasFicha, false);
    });
  });

  group('CpfValidator Tests', () {
    test('valida e formata CPF corretamente', () {
      expect(CpfValidator.validar('52998224725'), true);
      expect(CpfValidator.validar('11111111111'), false);
      expect(CpfValidator.validar('123'), false);
      expect(CpfValidator.formatar('52998224725'), '529.982.247-25');
    });
  });
}
