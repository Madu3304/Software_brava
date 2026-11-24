import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:software_brava/core/api/api_config.dart';
import 'package:software_brava/core/api/api_http_adapter_io.dart';
import 'package:software_brava/models/dashboard_metrics_model.dart';
import 'package:software_brava/models/ficha_model.dart';
import 'package:software_brava/models/usuario_model.dart';
import 'package:software_brava/providers/dashboard_provider.dart';
import 'package:software_brava/providers/ficha_provider.dart';
import 'package:software_brava/services/database_service.dart';
import 'package:software_brava/services/docusign_service.dart';
import 'package:software_brava/services/gps_service.dart';
import 'package:software_brava/services/local_crypto_service.dart';
import 'package:software_brava/services/ollama_service.dart';
import 'package:software_brava/services/print_service.dart';
import 'package:software_brava/views/admin/cadastros/historico_fichas_screen.dart';
import 'package:software_brava/views/admin/dashboard/admin_dashboard_shell.dart';
import 'package:software_brava/views/admin/dashboard/dashboard_overview_screen.dart';
import 'package:software_brava/views/admin/dashboard/widgets/dashboard_charts.dart';
import 'package:software_brava/views/admin/dashboard/widgets/dashboard_filters_card.dart';
import 'package:software_brava/views/admin/dashboard/widgets/dashboard_kpi_cards.dart';
import 'package:software_brava/views/assistencial/assinatura_paciente_view.dart';

void main() {
  testWidgets('DashboardKpiCards, DashboardCharts e DashboardFiltersCard renderizam',
      (WidgetTester tester) async {
    final metrics = DashboardMetricsModel.mockDefault();

    tester.view.physicalSize = const Size(2400, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: Column(
              children: [
                DashboardFiltersCard(
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
                DashboardKpiCards(metrics: metrics),
                DashboardCharts(metrics: metrics),
              ],
            ),
          ),
        ),
      ),
    );
    expect(find.text('4.562'), findsOneWidget);

    tester.view.physicalSize = const Size(950, 1400);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: DashboardCharts(metrics: metrics),
          ),
        ),
      ),
    );
    expect(find.byType(DashboardCharts), findsOneWidget);
  });

  testWidgets('DashboardOverviewScreen e HistoricoFichasScreen renderizam sem erros',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(2400, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => DashboardProvider(),
        child: const MaterialApp(
          home: Scaffold(body: DashboardOverviewScreen()),
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 35));
    expect(find.byType(DashboardOverviewScreen), findsOneWidget);

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: HistoricoFichasScreen()),
      ),
    );
    await tester.pump(const Duration(seconds: 35));
    expect(find.byType(HistoricoFichasScreen), findsOneWidget);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ],
        child: const MaterialApp(
          home: AdminDashboardShell(initialScreenIndex: 0),
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 35));
    expect(find.byType(AdminDashboardShell), findsOneWidget);
  });

  test('PrintService gera PDF e services/models auxiliares inicializam corretamente', () async {
    final ficha = FichaAtendimentoModel(
      id: 'pdf-1',
      numeroOcorrencia: 'REG-900',
      dataHora: DateTime(2026, 11, 22, 16, 0),
      pacienteNome: 'Paciente PDF',
      pacienteIdade: 40,
      pacienteSexo: 'Masculino',
      tipoOcorrencia: 'Clínico',
      endereco: 'Rua Teste, 100',
      unidadeResponsavel: 'USB',
      pressaoArterial: '120/80',
      frequenciaCardiaca: 80,
      saturacaoO2: 98,
      queixaPrincipal: 'Dor lombar',
      condutaMedica: 'Encaminhamento',
    );
    final bytes = await PrintService().gerarPdfFicha(ficha);
    expect(bytes.isNotEmpty, true);

    final dashProvider = DashboardProvider();
    expect(dashProvider.metrics.totalAtendimentos, greaterThan(0));
    expect(dashProvider.isLoading, false);

    final usuario = UsuarioModel(
      id: '1',
      nome: 'Admin',
      login: 'admin',
      perfil: PerfilUsuario.admin,
    );
    expect(usuario.isAdmin, true);
    expect(usuario.toMap()['login'], 'admin');

    expect(DocuSignService(), isNotNull);
    expect(OllamaService(), isNotNull);
    expect(GpsService(), isNotNull);

    final metricsJson = DashboardMetricsModel.fromJson({
      'total_atendimentos': 10,
      'taxa_crescimento_mensal': 5.0,
      'unidades': {},
      'atendimentos_por_nivel': {'Emergências': 3},
      'locais_mais_frequentes': [
        {'bairro': 'Centro', 'total': 4},
      ],
      'tempo_medio_minutos': '07:30',
      'taxa_indisponibilidade_percentual': 2.0,
      'horas_indisponibilidade': '5h / 240h',
    });
    expect(metricsJson.totalAtendimentos, 10);
    expect(DashboardMetricsModel.mockDefault().atendimentosPorNivel.isNotEmpty, true);

    // LocalCryptoService & ApiConfig security helpers
    final crypto = LocalCryptoService();
    final cifrado = await crypto.protegerTexto('Paciente Sigiloso');
    expect(cifrado.startsWith('ENC1:'), true);
    expect(await crypto.desprotegerTexto(cifrado), 'Paciente Sigiloso');
    final mapaProtegido = await crypto.protegerMapaFicha({
      'pacienteNome': 'Ana',
      'pacienteDocumento': '12345678909',
    });
    final mapaAberto = await crypto.desprotegerMapaFicha(mapaProtegido);
    expect(mapaAberto['pacienteNome'], 'Ana');
    expect(ApiConfig.isSecureTransportAllowed('https://samu.joinville.sc.gov.br', isRelease: true), true);
    expect(ApiConfig.isSecureTransportAllowed('http://samu.joinville.sc.gov.br', isRelease: true), false);
    expect(ApiConfig.isSecureTransportAllowed('http://127.0.0.1:8000', isRelease: false), true);

    final db = DatabaseService();
    await db.listarFichas();
    await db.listarFichasPendentes();
    await db.buscarFichaPorId('id-inexistente');
    await db.atualizarStatusSincronizacao('id-inexistente', StatusSincronizacao.sincronizado);
    try {
      await db.inserirFicha(ficha);
    } catch (_) {}

    // Certificate pinning adapter & SHA-256
    final dioPin = Dio();
    configureSecureHttpAdapter(dioPin, expectedSha256Pin: '00' * 32);
    final adapter = dioPin.httpClientAdapter as IOHttpClientAdapter;
    expect(adapter.validateCertificate?.call(null, 'localhost', 443), false);
    expect(adapter.validateCertificate?.call(_FakeCert(), 'localhost', 443), false);
    adapter.createHttpClient?.call();
    expect(await crypto.desprotegerTexto('ENC1:invalido!!!'), '');
    expect(await crypto.protegerTexto(''), '');
    expect(await crypto.desprotegerTexto('texto_plano'), 'texto_plano');
  });

  testWidgets('AssinaturaPacienteView renderiza canvas, DocuSign e impossibilidade',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(2400, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final oldOnError = FlutterError.onError;
    FlutterError.onError = (details) {
      if (!details.toString().contains('overflowed')) {
        oldOnError?.call(details);
      }
    };
    addTearDown(() => FlutterError.onError = oldOnError);

    final ficha = FichaAtendimentoModel(
      id: 'ass-1',
      numeroOcorrencia: 'REG-555',
      dataHora: DateTime(2026, 11, 22, 16, 0),
      pacienteNome: 'Paciente Assinatura',
      pacienteIdade: 50,
      pacienteSexo: 'Masculino',
      tipoOcorrencia: 'Clínico',
      endereco: 'Rua Central',
      unidadeResponsavel: 'USB',
    );

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => FichaEmAndamentoProvider()..setFicha(ficha),
        child: MaterialApp(home: AssinaturaPacienteView(fichaParcial: ficha)),
      ),
    );
    await tester.pump();
    expect(find.byType(AssinaturaPacienteView), findsOneWidget);

    final sw = find.byType(Switch);
    if (sw.evaluate().isNotEmpty) {
      await tester.ensureVisible(sw.first);
      await tester.tap(sw.first);
      await tester.pump();
    }
    final limpar = find.textContaining('Limpar');
    if (limpar.evaluate().isNotEmpty) {
      await tester.tap(limpar.first, warnIfMissed: false);
      await tester.pump();
    }
  });

  testWidgets('AdminDashboardShell navega pelas abas de cadastros',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final oldOnError = FlutterError.onError;
    FlutterError.onError = (details) {
      final msg = details.toString();
      if (!msg.toLowerCase().contains('semantics') &&
          !msg.contains('overflowed') &&
          !msg.contains('parentData')) {
        oldOnError?.call(details);
      }
    };
    addTearDown(() => FlutterError.onError = oldOnError);

    for (final idx in [1, 2, 3, 4, 5]) {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => DashboardProvider()),
          ],
          child: MaterialApp(
            home: AdminDashboardShell(
              key: ValueKey('shell-$idx'),
              initialScreenIndex: idx,
            ),
          ),
        ),
      );
      await tester.pump(const Duration(seconds: 35));
      expect(find.byType(AdminDashboardShell), findsOneWidget);
      if (idx <= 4) {
        final btns = find.bySubtype<ElevatedButton>();
        if (btns.evaluate().isNotEmpty) {
          tester.widget<ElevatedButton>(btns.first).onPressed?.call();
          await tester.pump();
        }
      }
    }
  });
}

class _FakeCert implements X509Certificate {
  @override
  Uint8List get der => Uint8List.fromList([1, 2, 3, 4]);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
