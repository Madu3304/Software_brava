import 'package:flutter_test/flutter_test.dart';
import 'package:software_brava/models/profissional_model.dart';

void main() {
  group('ProfissionalModel Tests', () {
    test('Fábrica de médico deve configurar tipo e CRM corretamente', () {
      final medico = ProfissionalModel.medico(
        id: 'med-1',
        nome: 'Dr. Roberto Silveira',
        cpf: '111.222.333-44',
        crm: 'CRM-SC 14522',
        unidade: 'Unidade Norte',
        matricula: 'UN-001',
      );

      expect(medico.tipo, TipoProfissional.medico);
      expect(medico.crm, 'CRM-SC 14522');
      expect(medico.registroConselho, 'CRM-SC 14522');
    });

    test('Fábrica de técnico de enfermagem deve configurar tipo e COREN corretamente', () {
      final enfermeiro = ProfissionalModel.tecnicoEnfermagem(
        id: 'enf-1',
        nome: 'Ana Paula Oliveira',
        cpf: '123.456.789-01',
        coren: 'COREN-SP 123456',
        unidade: 'Unidade Norte',
        matricula: 'UN-TE-001',
      );

      expect(enfermeiro.tipo, TipoProfissional.enfermeiro);
      expect(enfermeiro.coren, 'COREN-SP 123456');
    });

    test('Fábrica de socorrista deve configurar tipo e CNH corretamente', () {
      final socorrista = ProfissionalModel.socorrista(
        id: 'soc-1',
        nome: 'Marcos Vinícius Santos',
        cpf: '222.333.444-55',
        cnh: '01234567890 (Cat. D)',
        unidade: 'Unidade Norte',
        matricula: 'UN-SOC-001',
      );

      expect(socorrista.tipo, TipoProfissional.socorrista);
      expect(socorrista.cnh, contains('Cat. D'));
    });

    test('Serialização toMap e fromMap deve preservar os dados', () {
      final original = ProfissionalModel.medico(
        id: 'm1',
        nome: 'Dra. Juliana Mendes',
        cpf: '555.666.777-88',
        crm: 'CRM-SC 18933',
        unidade: 'Unidade Sul',
        matricula: 'US-002',
      );

      final map = original.toMap();
      final restaurado = ProfissionalModel.fromMap(map);

      expect(restaurado.id, original.id);
      expect(restaurado.nome, original.nome);
      expect(restaurado.cpf, original.cpf);
      expect(restaurado.crm, original.crm);
      expect(restaurado, equals(original));
    });
  });
}
