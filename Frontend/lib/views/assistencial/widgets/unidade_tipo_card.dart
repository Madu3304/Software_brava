// botão de seleção de unidade tipo USB

import 'package:flutter/material.dart';

class UnidadeTipoCard extends StatefulWidget {
  final String tipoAtual;
  final ValueChanged<String>? onTipoChanged;

  static const List<String> opcoesUsb = [
    'USB 1',
    'USB 2',
    'USB 3',
    'USB 4',
  ];

  const UnidadeTipoCard({
    super.key,
    this.tipoAtual = 'USB',
    this.onTipoChanged,
  });

  @override
  State<UnidadeTipoCard> createState() => _UnidadeTipoCardState();
}

class _UnidadeTipoCardState extends State<UnidadeTipoCard> {
  bool _expandido = false;

  void _alternarOpcoes() {
    setState(() {
      _expandido = !_expandido;
    });
  }

  void _selecionarOpcao(String opcao) {
    setState(() {
      _expandido = false;
    });
    widget.onTipoChanged?.call(opcao);git 
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
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12.0),
              onTap: _alternarOpcoes,
              child: Container(
                height: 52,
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                decoration: BoxDecoration(
                  color: const Color(0xFFE50914), // Vermelho vivo idêntico ao Figma
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
                    Expanded(
                      child: Text(
                        widget.tipoAtual,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    Icon(
                      _expandido
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_expandido) ...[
            const SizedBox(height: 12),
            ...UnidadeTipoCard.opcoesUsb.map((opcao) {
              final bool selecionado = widget.tipoAtual == opcao;
              return Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10.0),
                    onTap: () => _selecionarOpcao(opcao),
                    child: Container(
                      height: 46,
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      decoration: BoxDecoration(
                        color: selecionado
                            ? const Color(0xFFFFEBEE)
                            : const Color(0xFFFAFAFA),
                        borderRadius: BorderRadius.circular(10.0),
                        border: Border.all(
                          color: selecionado
                              ? const Color(0xFFE50914)
                              : const Color(0xFFEEEEEE),
                          width: selecionado ? 1.5 : 1.0,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.electric_bolt_rounded,
                            size: 18,
                            color: selecionado
                                ? const Color(0xFFE50914)
                                : const Color(0xFF757575),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              opcao,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: selecionado
                                    ? FontWeight.w700
                                    : FontWeight.w600,
                                color: selecionado
                                    ? const Color(0xFFE50914)
                                    : const Color(0xFF2C3437),
                              ),
                            ),
                          ),
                          if (selecionado)
                            const Icon(
                              Icons.check_circle_rounded,
                              color: Color(0xFFE50914),
                              size: 20,
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ],
        ],
      ),
    );
  }
}
