// ============================================================================
// WIDGET COMPONENTE: SELETOR DE VIATURA USB COM OPÇÕES EXPANSÍVEIS (FIGMA SAMU)
// Arquivo: lib/views/assistencial/widgets/unidade_tipo_card.dart
// ============================================================================

import 'package:flutter/material.dart';

class UnidadeTipoCard extends StatefulWidget {
  final String tipoAtual;
  final ValueChanged<String>? onTipoChanged;
  final Set<String>? opcoesSelecionadas;
  final ValueChanged<Set<String>>? onOpcoesChanged;

  const UnidadeTipoCard({
    super.key,
    this.tipoAtual = 'USB',
    this.onTipoChanged,
    this.opcoesSelecionadas,
    this.onOpcoesChanged,
  });

  @override
  State<UnidadeTipoCard> createState() => _UnidadeTipoCardState();
}

class _UnidadeTipoCardState extends State<UnidadeTipoCard> {
  bool _isExpanded = false;
  late Set<String> _opcoesMarcadas;

  final List<String> _listaOpcoes = const [
    'Opção 1',
    'Opção 2',
    'Opção 3',
    'Opção 4',
  ];

  @override
  void initState() {
    super.initState();
    _opcoesMarcadas = widget.opcoesSelecionadas != null
        ? Set<String>.from(widget.opcoesSelecionadas!)
        : <String>{};
  }

  void _toggleOpcao(String opcao) {
    setState(() {
      if (_opcoesMarcadas.contains(opcao)) {
        _opcoesMarcadas.remove(opcao);
      } else {
        _opcoesMarcadas.add(opcao);
      }
    });

    if (widget.onOpcoesChanged != null) {
      widget.onOpcoesChanged!(_opcoesMarcadas);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: const Color(0xFFF0F0F0), width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Botão principal USB (Vermelho idêntico ao Figma)
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12.0),
              onTap: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
              child: Container(
                height: 52,
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                decoration: BoxDecoration(
                  color: const Color(0xFFE50914), // Vermelho vivo do Figma
                  borderRadius: BorderRadius.circular(12.0),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x2EE50914),
                      blurRadius: 8,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.electric_bolt_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                    const SizedBox(width: 14),
                    Text(
                      widget.tipoAtual,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                    if (_opcoesMarcadas.isNotEmpty) ...[
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          "${_opcoesMarcadas.length} marcada${_opcoesMarcadas.length > 1 ? 's' : ''}",
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                    const Spacer(),
                    AnimatedRotation(
                      turns: _isExpanded ? 0.5 : 0.0,
                      duration: const Duration(milliseconds: 200),
                      child: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Seção expansível com as 4 opções para serem marcadas
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 240),
            crossFadeState: _isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Selecione as opções da USB:",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF616161),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ..._listaOpcoes.map((opcao) {
                    final bool isChecked = _opcoesMarcadas.contains(opcao);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: InkWell(
                        onTap: () => _toggleOpcao(opcao),
                        borderRadius: BorderRadius.circular(10.0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14.0,
                            vertical: 10.0,
                          ),
                          decoration: BoxDecoration(
                            color: isChecked
                                ? const Color(0xFFFFF0F1)
                                : const Color(0xFFF9FAFB),
                            borderRadius: BorderRadius.circular(10.0),
                            border: Border.all(
                              color: isChecked
                                  ? const Color(0xFFE50914)
                                  : const Color(0xFFE0E0E0),
                              width: isChecked ? 1.5 : 1.0,
                            ),
                          ),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 22,
                                height: 22,
                                child: Checkbox(
                                  value: isChecked,
                                  onChanged: (_) => _toggleOpcao(opcao),
                                  activeColor: const Color(0xFFE50914),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                opcao,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: isChecked
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  color: isChecked
                                      ? const Color(0xFFB71C1C)
                                      : const Color(0xFF212121),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
