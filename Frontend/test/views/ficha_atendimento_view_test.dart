import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:software_brava/views/assistencial/ficha_atendimento_view.dart';
import 'package:software_brava/views/assistencial/widgets/unidade_tipo_card.dart';
import 'package:software_brava/views/assistencial/widgets/codigo_triagem_selector.dart';
import 'package:software_brava/views/assistencial/widgets/data_atendimento_card.dart';

void main() {
  testWidgets('FichaAtendimentoView renderiza cabeçalho, USB, seletor de códigos, data e botão Continuar',
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

    // Valida o Card de Data com opções de Dia, Mês e Ano
    expect(find.byType(DataAtendimentoCard), findsOneWidget);
    expect(find.text('Data do Atendimento:'), findsOneWidget);
    expect(find.text('Dia'), findsOneWidget);
    expect(find.text('Mês'), findsOneWidget);
    expect(find.text('Ano'), findsOneWidget);

    expect(find.text('Continuar'), findsOneWidget);

    // Testa clique no botão USB para expandir as 4 opções
    await tester.tap(find.text('USB'));
    await tester.pumpAndSettle();

    expect(find.text('Opção 1'), findsOneWidget);
    expect(find.text('Opção 2'), findsOneWidget);
    expect(find.text('Opção 3'), findsOneWidget);
    expect(find.text('Opção 4'), findsOneWidget);

    // Marca a Opção 1
    await tester.tap(find.text('Opção 1'));
    await tester.pumpAndSettle();
    expect(find.text('Opção 1'), findsOneWidget);

    // Testa alternância de código de triagem
    await tester.tap(find.text('Amarelo'));
    await tester.pumpAndSettle();
    expect(find.text('Amarelo'), findsOneWidget);
  });
}
