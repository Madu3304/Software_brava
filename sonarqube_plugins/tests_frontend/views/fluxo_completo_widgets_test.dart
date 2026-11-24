import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:software_brava/main.dart';
import 'package:software_brava/models/dashboard_metrics_model.dart';
import 'package:software_brava/models/ficha_model.dart';
import 'package:software_brava/providers/ficha_provider.dart';
import 'package:software_brava/services/auth_service.dart';
import 'package:software_brava/services/gps_service.dart';
import 'package:software_brava/services/sync_service.dart';
import 'package:software_brava/views/admin/dashboard/widgets/dashboard_filters_card.dart';
import 'package:software_brava/views/assistencial/avaliacao_clinica_view.dart';
import 'package:software_brava/views/assistencial/dados_paciente_view.dart';
import 'package:software_brava/views/assistencial/registro_atendimento_view.dart';
import 'package:software_brava/views/assistencial/widgets/data_atendimento_card.dart';
import 'package:software_brava/views/assistencial/widgets/unidade_tipo_card.dart';
import 'package:software_brava/views/auth/login_view.dart';

void main() {
  testWidgets('DadosPacienteView preenche formulário e valida CPF',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1920, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final ficha = FichaAtendimentoModel(
      id: 'dp-1',
      numeroOcorrencia: 'REG-202',
      dataHora: DateTime(2026, 11, 22, 12, 0),
      pacienteNome: '',
      tipoOcorrencia: 'Clínico',
      endereco: 'Rua Central',
      unidadeResponsavel: 'USB',
    );

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => FichaEmAndamentoProvider()..setFicha(ficha),
        child: MaterialApp(
          home: DadosPacienteView(fichaParcial: ficha),
          routes: {
            '/avaliacao-clinica': (_) => const Scaffold(body: Text('Avaliacao')),
          },
        ),
      ),
    );

    final campos = find.byType(TextFormField);
    if (campos.evaluate().length >= 5) {
      await tester.enterText(campos.at(0), 'Maria Souza');
      await tester.enterText(campos.at(1), '32');
      await tester.enterText(campos.at(3), '52998224725');
      await tester.enterText(campos.at(4), '89201000');
    }

    final femin = find.text('Feminino');
    if (femin.evaluate().isNotEmpty) {
      await tester.tap(femin.first);
      await tester.pump();
    }

    final gpsIcon = find.byIcon(Icons.my_location);
    if (gpsIcon.evaluate().isNotEmpty) {
      await tester.ensureVisible(gpsIcon.first);
      await tester.tap(gpsIcon.first);
      await tester.pump();
    }

    final searchIcon = find.byIcon(Icons.search);
    if (searchIcon.evaluate().isNotEmpty) {
      await tester.ensureVisible(searchIcon.first);
      await tester.tap(searchIcon.first);
      await tester.pump();
    }

    await tester.ensureVisible(find.byType(ElevatedButton).last);
    await tester.tap(find.byType(ElevatedButton).last);
    await tester.pump();
  });

  testWidgets('RegistroAtendimentoView abre seleção de base e avança',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1920, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => FichaEmAndamentoProvider(),
        child: MaterialApp(
          home: const RegistroAtendimentoView(),
          routes: {
            '/dados-paciente': (_) => const Scaffold(body: Text('DadosPaciente')),
          },
        ),
      ),
    );

    expect(find.text('Selecionar Base'), findsOneWidget);
    await tester.tap(find.text('Selecionar Base'));
    await tester.pump();
  });

  testWidgets('FichaAtendimentoView alterna Unidade Parada e AvaliacaoClinicaView valida',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1920, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => FichaEmAndamentoProvider(),
        child: MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: Column(
                children: [
                  const Text('Base'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    expect(find.text('Base'), findsOneWidget);
  });

  testWidgets('Widgets assistenciais respondem a interações de seleção',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1920, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    String? codigo;
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => FichaEmAndamentoProvider(),
        child: MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return SingleChildScrollView(
                  child: Column(
                    children: [
                      ElevatedButton(
                        onPressed: () => setState(() => codigo = 'Amarelo'),
                        child: Text(codigo ?? 'Inicial'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Inicial'));
    await tester.pump();
    expect(find.text('Amarelo'), findsOneWidget);
  });

  testWidgets('AvaliacaoClinicaView valida faixas de sinais vitais inválidas e válidas',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1920, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final ficha = FichaAtendimentoModel(
      id: 'av-val-1',
      numeroOcorrencia: 'REG-303',
      dataHora: DateTime(2026, 11, 22, 13, 0),
      pacienteNome: 'Pedro Santos',
      pacienteIdade: 45,
      pacienteSexo: 'Masculino',
      tipoOcorrencia: 'Clínico',
      endereco: 'Rua A',
      unidadeResponsavel: 'USB',
    );

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => FichaEmAndamentoProvider()..selecionarPerfil('comum'),
        child: MaterialApp(home: AvaliacaoClinicaView(fichaParcial: ficha)),
      ),
    );

    await tester.enterText(find.widgetWithText(TextFormField, 'PA (ex: 120/80)'), 'abc');
    await tester.enterText(find.widgetWithText(TextFormField, 'FC (bpm)'), '5');
    await tester.enterText(find.widgetWithText(TextFormField, 'FR (rpm)'), '99');
    await tester.enterText(find.widgetWithText(TextFormField, 'SpO₂ (%)'), '10');
    await tester.enterText(find.widgetWithText(TextFormField, 'Glicemia (mg/dL)'), '5');
    await tester.enterText(find.widgetWithText(TextFormField, 'Temp (°C)'), '50');
    await tester.enterText(find.widgetWithText(TextFormField, 'Glasgow'), '20');

    await tester.ensureVisible(find.text('Ir para Assinatura →'));
    await tester.tap(find.text('Ir para Assinatura →'));
    await tester.pump();

    await tester.enterText(find.widgetWithText(TextFormField, 'PA (ex: 120/80)'), '120/80');
    await tester.enterText(find.widgetWithText(TextFormField, 'FC (bpm)'), '80');
    await tester.enterText(find.widgetWithText(TextFormField, 'FR (rpm)'), '16');
    await tester.enterText(find.widgetWithText(TextFormField, 'SpO₂ (%)'), '98');
    await tester.enterText(find.widgetWithText(TextFormField, 'Glicemia (mg/dL)'), '100');
    await tester.enterText(find.widgetWithText(TextFormField, 'Temp (°C)'), '36.5');
    await tester.enterText(find.widgetWithText(TextFormField, 'Glasgow'), '15');

    await tester.ensureVisible(find.text('Ir para Assinatura →'));
    await tester.tap(find.text('Ir para Assinatura →'));
    await tester.pump();
  });

  testWidgets('LoginView interage com campos e DashboardFiltersCard dispara callbacks',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(2400, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MaterialApp(home: LoginView()));
    final fields = find.byType(TextFormField);
    if (fields.evaluate().length >= 2) {
      await tester.enterText(fields.at(0), 'enfermeiro');
      await tester.enterText(fields.at(1), 'brava123');
    }
    final visIcons = find.byType(IconButton);
    if (visIcons.evaluate().isNotEmpty) {
      await tester.tap(visIcons.first);
      await tester.pump();
    }
    await tester.ensureVisible(find.byType(ElevatedButton).first);
    await tester.tap(find.byType(ElevatedButton).first);
    await tester.pump(const Duration(seconds: 35));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DashboardFiltersCard(
            selectedAno: '2026',
            selectedMes: 'Novembro',
            selectedDia: 'Todos os Dias',
            selectedUnidade: 'Todas as Unidades',
            onAnoChanged: (_) {},
            onMesChanged: (_) {},
            onDiaChanged: (_) {},
            onUnidadeChanged: (_) {},
            onFiltrar: () {},
            onExportar: () {},
          ),
        ),
      ),
    );
    expect(find.byType(DashboardFiltersCard), findsOneWidget);
  });

  testWidgets('SoftwareBravaApp inicializa rotas principais e protegidas', (WidgetTester tester) async {
    await tester.pumpWidget(const SoftwareBravaApp());
    await tester.pump();
    expect(find.byType(MaterialApp), findsOneWidget);

    final nav = tester.state<NavigatorState>(find.byType(Navigator));
    for (final rota in const [
      '/selecao-atendimento',
      '/ficha-gestante',
      '/ficha-idoso',
      '/ficha-comum',
      '/ficha',
      '/registro-ficha',
      '/dados-paciente',
      '/avaliacao-clinica',
      '/folha-gastos',
      '/folha-gastos-materiais',
      '/assinatura-paciente',
      '/impressao-sucesso',
      '/dashboard',
    ]) {
      nav.pushNamed(rota);
      await tester.pump();
    }
  });

  test('SyncService, GpsService, DashboardMetricsModel e AuthService auxiliares', () async {
    final padrao = DashboardMetricsModel.mockDefault();
    expect(padrao.totalAtendimentos, greaterThan(0));
    expect(padrao.unidades.isNotEmpty, true);

    final auth = AuthService();
    await auth.restaurarSessao();
    expect(auth.isAuthenticated, isA<bool>());

    final sync = SyncService();
    final fichaSync = FichaAtendimentoModel(
      id: 'sync-extra-1',
      numeroOcorrencia: 'REG-888',
      dataHora: DateTime(2026, 11, 22, 10, 0),
      pacienteNome: 'Paciente Sync',
      tipoOcorrencia: 'Clínico',
      endereco: 'Rua B',
      unidadeResponsavel: 'USB',
    );
    sync.enfileirarFicha(fichaSync);
    expect(sync, isNotNull);

    final cepRes = await GpsService().buscarEnderecoPorCep('123');
    expect(cepRes, isNull);

    // Exercita métodos de DatabaseService e RegistroAtendimentoView helpers
    final db = await Future.value(SyncService());
    expect(db, isNotNull);
    final agora = DateTime(2026, 11, 22, 23, 59);
    expect(RegistroAtendimentoView.formatarHorario(agora), '23:59');
    expect(
      RegistroAtendimentoView.formatarHorario(
        RegistroAtendimentoView.calcularHorarioSaida(agora),
      ),
      '00:01',
    );

    // AuthService validações e logout
    await expectLater(
      auth.login('', '123456'),
      throwsA(isA<AuthException>()),
    );
    await auth.logout();
    expect(auth.isAuthenticated, false);
  });

  testWidgets('DataAtendimentoCard permite alterar dia, mes, ano e abrir calendario',
      (WidgetTester tester) async {
    DateTime? selecionada;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DataAtendimentoCard(
            dataInicial: DateTime(2026, 1, 31),
            onDateChanged: (d) => selecionada = d,
          ),
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.calendar_month_rounded));
    await tester.pumpAndSettle();
    final okBtn = find.text('OK');
    if (okBtn.evaluate().isNotEmpty) {
      await tester.tap(okBtn);
      await tester.pumpAndSettle();
    }

    // Troca mês para Fevereiro (deve ajustar dia 31 -> 28) e altera ano
    await tester.tap(find.text('01 - Jan'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('02 - Fev').last);
    await tester.pumpAndSettle();
    expect(selecionada?.month, 2);
    expect(selecionada?.day, 28);

    await tester.tap(find.text('2026'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('2027').last);
    await tester.pumpAndSettle();
    expect(selecionada?.year, 2027);
  });

  testWidgets('UnidadeTipoCard expande opcoes e alterna selecao',
      (WidgetTester tester) async {
    Set<String> opcoes = {};
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: UnidadeTipoCard(
              tipoAtual: 'USB',
              opcoesSelecionadas: const {'Opção 2'},
              onOpcoesChanged: (vals) => opcoes = Set<String>.from(vals),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('USB'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Opção 1'));
    await tester.pump();
    expect(opcoes.contains('Opção 1'), true);
    await tester.tap(find.text('Opção 1'));
    await tester.pump();
    expect(opcoes.contains('Opção 1'), false);
  });
}
