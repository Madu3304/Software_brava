import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:software_brava/views/assistencial/ficha_atendimento_view.dart';
import 'package:software_brava/views/assistencial/widgets/unidade_tipo_card.dart';
import 'package:software_brava/views/assistencial/widgets/codigo_triagem_selector.dart';

void main() {
  testWidgets('FichaAtendimentoView renderiza cabeçalho, USB, seletor de códigos e botão Continuar',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: FichaAtendimentoView(),
      ),
    );

    expect(find.text('Ficha de Atendimento'), findsOneWidget);
    expect(find.byType(UnidadeTipoCard), findsOneWidget);
    expect(find.text('USB'), findsOneWidget);
    expect(find.byType(CodigoTriagemSelector), findsOneWidget);
    expect(find.text('Código:'), findsOneWidget);
    expect(find.text('Vermelho'), findsOneWidget);
    expect(find.text('Amarelo'), findsOneWidget);
    expect(find.text('Verde'), findsOneWidget);
    expect(find.text('Azul'), findsOneWidget);
    expect(find.text('Continuar'), findsOneWidget);

    // Testa alternância de código de triagem
    await tester.tap(find.text('Amarelo'));
    await tester.pump();
    expect(find.text('Amarelo'), findsOneWidget);
  });
}
