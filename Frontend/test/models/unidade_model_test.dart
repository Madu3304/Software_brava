import 'package:flutter_test/flutter_test.dart';
import 'package:software_brava/models/unidade_model.dart';

void main() {
  group('UnidadeMovelModel Tests', () {
    test('Deve instanciar corretamente uma unidade móvel com valores padrão', () {
      const unidade = UnidadeMovelModel(
        id: 'u1',
        codigo: 'USA-01',
        placa: 'BRA-1921',
        tipo: 'USA (Suporte Avançado)',
        regiao: 'Unidade Norte',
      );

      expect(unidade.id, 'u1');
      expect(unidade.codigo, 'USA-01');
      expect(unidade.status, 'Operacional');
      expect(unidade.tipo, 'USA (Suporte Avançado)');
    });

    test('Deve converter para Map e reconstruir via fromMap mantendo integridade', () {
      const original = UnidadeMovelModel(
        id: 'u2',
        codigo: 'USB-02',
        placa: 'BRA-1922',
        tipo: 'USB (Suporte Básico)',
        regiao: 'Unidade Sul',
        status: 'Em Manutenção',
      );

      final map = original.toMap();
      final reconstruida = UnidadeMovelModel.fromMap(map);

      expect(reconstruida.id, original.id);
      expect(reconstruida.codigo, original.codigo);
      expect(reconstruida.placa, original.placa);
      expect(reconstruida.status, 'Em Manutenção');
      expect(reconstruida, equals(original));
    });

    test('copyWith deve atualizar apenas os campos informados', () {
      const original = UnidadeMovelModel(
        id: 'u3',
        codigo: 'USB-03',
        placa: 'BRA-1923',
        tipo: 'USB',
        regiao: 'Leste',
      );

      final atualizada = original.copyWith(status: 'Em Atendimento');

      expect(atualizada.id, original.id);
      expect(atualizada.codigo, original.codigo);
      expect(atualizada.status, 'Em Atendimento');
    });
  });
}
