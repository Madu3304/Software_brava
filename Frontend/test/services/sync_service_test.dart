import 'package:flutter_test/flutter_test.dart';
import 'package:software_brava/models/ficha_model.dart';
import 'package:software_brava/services/sync_service.dart';

void main() {
  group('SyncService Offline-First Tests', () {
    late SyncService syncService;

    setUp(() {
      syncService = SyncService();
    });

    test('Deve enfileirar ficha com status pendente', () {
      final ficha = FichaAtendimentoModel(
        id: 'f-001',
        numeroOcorrencia: 'OC-192-2026',
        dataHora: DateTime.now(),
        pacienteNome: 'João Silva',
        tipoOcorrencia: 'Trauma',
        endereco: 'Rua das Palmeiras, 100 - Joinville',
        unidadeResponsavel: 'USA-01',
      );

      syncService.enfileirarFicha(ficha);

      expect(syncService.filaPendencias.length, 1);
      expect(syncService.filaPendencias.first.id, 'f-001');
      expect(
        syncService.filaPendencias.first.statusSincronizacao,
        StatusSincronizacao.pendente,
      );
    });

    test('Enfileirar ficha com mesmo ID deve atualizar sem duplicar registro', () {
      final ficha1 = FichaAtendimentoModel(
        id: 'f-002',
        numeroOcorrencia: 'OC-002',
        dataHora: DateTime.now(),
        pacienteNome: 'Maria Santos',
        tipoOcorrencia: 'Clínico',
        endereco: 'Centro, Joinville',
        unidadeResponsavel: 'USB-02',
      );

      final fichaAtualizada = ficha1.copyWith(
        queixaPrincipal: 'Dor torácica intensa',
      );

      syncService.enfileirarFicha(ficha1);
      syncService.enfileirarFicha(fichaAtualizada);

      final encontradas = syncService.filaPendencias
          .where((f) => f.id == 'f-002')
          .toList();

      expect(encontradas.length, 1);
      expect(encontradas.first.queixaPrincipal, 'Dor torácica intensa');
    });
  });
}
