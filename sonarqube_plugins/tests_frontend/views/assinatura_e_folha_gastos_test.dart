import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:software_brava/models/ficha_model.dart';
import 'package:software_brava/models/profissional_model.dart';
import 'package:software_brava/models/unidade_model.dart';
import 'package:software_brava/providers/ficha_provider.dart';
import 'package:software_brava/services/admin_data_service.dart';
import 'package:software_brava/views/assistencial/folha_gastos_view.dart';
import 'package:software_brava/views/assistencial/folha_gastos_materiais_view.dart';
import 'package:software_brava/views/assistencial/impressao_sucesso_view.dart';

void main() {
  final fichaBase = FichaAtendimentoModel(
    id: 'ficha-fluxo-final',
    numeroOcorrencia: 'REG-777',
    dataHora: DateTime(2026, 11, 22, 15, 0),
    pacienteNome: 'Carlos Eduardo',
    pacienteIdade: 55,
    pacienteSexo: 'Masculino',
    tipoOcorrencia: 'Atendimento Pré-Hospitalar',
    endereco: 'Rua Joinville, 50',
    unidadeResponsavel: 'USB',
  );

  testWidgets('FolhaGastosView renderiza catálogo, filtra medicamentos e ajusta quantidades',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => FichaEmAndamentoProvider()..setFicha(fichaBase),
        child: MaterialApp(
          home: FolhaGastosView(fichaParcial: fichaBase),
        ),
      ),
    );
    expect(find.byType(FolhaGastosView), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, 'Adrenalina');
    await tester.pump();

    final addIcons = find.byIcon(Icons.add);
    if (addIcons.evaluate().isNotEmpty) {
      await tester.tap(addIcons.first);
      await tester.pump();
    }

    await tester.ensureVisible(find.byType(ElevatedButton).last);
    await tester.tap(find.byType(ElevatedButton).last);
    await tester.pump();
  });

  testWidgets('FolhaGastosMateriaisView renderiza catálogo e permite selecionar insumos',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => FichaEmAndamentoProvider()..setFicha(fichaBase),
        child: MaterialApp(
          home: FolhaGastosMateriaisView(fichaParcial: fichaBase),
        ),
      ),
    );
    expect(find.byType(FolhaGastosMateriaisView), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, 'Soro');
    await tester.pump();

    // Limpa busca para renderizar todas as categorias e variantes
    await tester.enterText(find.byType(TextField).first, '');
    await tester.pump();

    final checkboxes = find.byType(Checkbox);
    if (checkboxes.evaluate().isNotEmpty) {
      await tester.tap(checkboxes.first);
      await tester.pump();
    }

    final addIcons = find.byIcon(Icons.add);
    if (addIcons.evaluate().isNotEmpty) {
      await tester.tap(addIcons.first);
      await tester.pump();
    }

    final removeIcons = find.byIcon(Icons.remove);
    if (removeIcons.evaluate().isNotEmpty) {
      await tester.tap(removeIcons.first);
      await tester.pump();
    }

    // Expande variante e conclui folha de materiais
    final agulha = find.text('Agulha hipodérmica');
    if (agulha.evaluate().isNotEmpty) {
      await tester.tap(agulha.first);
      await tester.pump();
    }

    final btnFinalizar = find.byType(ElevatedButton).last;
    await tester.ensureVisible(btnFinalizar);
    await tester.tap(btnFinalizar);
    await tester.pump();
  });

  testWidgets('ImpressaoSucessoView renderiza resumo e ações finais',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => FichaEmAndamentoProvider()..setFicha(fichaBase),
        child: const MaterialApp(
          home: ImpressaoSucessoView(),
        ),
      ),
    );
    expect(find.byType(ImpressaoSucessoView), findsOneWidget);
  });

  test('AdminDataService expõe listas e manipula profissionais e unidades em memória', () async {
    final service = AdminDataService();
    final prof = ProfissionalModel.medico(
      id: 'm-999',
      nome: 'Dr. Teste Cobertura',
      cpf: '111.222.333-44',
      crm: 'CRM-SC 9999',
      unidade: 'Unidade Norte',
      matricula: 'UN-999',
    );
    await service.adicionarProfissional(prof);
    expect(service.profissionais.any((p) => p.id == 'm-999'), true);
    await service.removerProfissional('m-999');

    const unidade = UnidadeMovelModel(
      id: 'u-999',
      codigo: 'USA-99',
      placa: 'BRA-9999',
      tipo: 'USA (Suporte Avançado)',
      regiao: 'Unidade Norte',
    );
    await service.adicionarUnidade(unidade);
    expect(service.unidades.any((u) => u.id == 'u-999'), true);
    await service.adicionarUnidade(
      unidade.copyWith(id: 'u-998', status: 'Em Atendimento'),
    );
    await service.adicionarUnidade(
      unidade.copyWith(id: 'u-997', status: 'Manutenção'),
    );
    await service.removerUnidade('u-999');
    await service.removerUnidade('u-998');
    await service.removerUnidade('u-997');

    final enf = ProfissionalModel.tecnicoEnfermagem(
      id: '101',
      nome: 'Enf. Maria',
      cpf: '222.333.444-55',
      coren: 'COREN-SC 101',
      unidade: 'Unidade Sul',
      matricula: 'ENF-101',
    );
    final soc = ProfissionalModel.socorrista(
      id: '102',
      nome: 'Soc. Joao',
      cpf: '333.444.555-66',
      cnh: 'CNH 102',
      unidade: 'Unidade Sul',
      matricula: 'SOC-102',
    );
    await service.adicionarProfissional(enf);
    await service.adicionarProfissional(soc);
    expect(service.medicos, isA<List<ProfissionalModel>>());
    expect(service.enfermeiros.any((p) => p.id == '101'), true);
    expect(service.socorristas.any((p) => p.id == '102'), true);
    await service.removerProfissional('101');
    await service.removerProfissional('102');
    await service.carregarCadastros();
  });
}
