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
    expect(find.text('USB 1'), findsNothing);
    expect(find.text('USB 2'), findsNothing);
    expect(find.text('USB 3'), findsNothing);
    expect(find.text('USB 4'), findsNothing);
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

  testWidgets('Clicar no botão USB exibe as 4 opções (USB 1 a USB 4) sem trocar para USA e permite selecionar',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: FichaAtendimentoView(),
      ),
    );

    // Clica no botão USB
    await tester.tap(find.text('USB'));
    await tester.pump();

    // Não deve trocar para USA; deve continuar exibindo USB e mostrar as 4 opções
    expect(find.text('USA'), findsNothing);
    expect(find.text('USB'), findsOneWidget);
    expect(find.text('USB 1'), findsOneWidget);
    expect(find.text('USB 2'), findsOneWidget);
    expect(find.text('USB 3'), findsOneWidget);
    expect(find.text('USB 4'), findsOneWidget);

    // Seleciona uma das opções (ex: USB 2)
    await tester.tap(find.text('USB 2'));
    await tester.pump();

    // As opções fecham e a unidade selecionada passa a ser exibida no botão
    expect(find.text('USB 2'), findsOneWidget);
    expect(find.text('USB 1'), findsNothing);
    expect(find.text('USB 3'), findsNothing);
    expect(find.text('USB 4'), findsNothing);
  });
}
