// ============================================================================
// WIDGET COMPONENTE: SELETOR DE DATA COM OPÇÕES DE DIA, MÊS E ANO (SAMU)
// Arquivo: lib/views/assistencial/widgets/data_atendimento_card.dart
// ============================================================================

import 'package:flutter/material.dart';

class DataAtendimentoCard extends StatefulWidget {
  final DateTime dataInicial;
  final ValueChanged<DateTime> onDateChanged;

  const DataAtendimentoCard({
    super.key,
    required this.dataInicial,
    required this.onDateChanged,
  });

  @override
  State<DataAtendimentoCard> createState() => _DataAtendimentoCardState();
}

class _DataAtendimentoCardState extends State<DataAtendimentoCard> {
  late int _dia;
  late int _mes;
  late int _ano;

  final List<String> _meses = const [
    '01 - Jan',
    '02 - Fev',
    '03 - Mar',
    '04 - Abr',
    '05 - Mai',
    '06 - Jun',
    '07 - Jul',
    '08 - Ago',
    '09 - Set',
    '10 - Out',
    '11 - Nov',
    '12 - Dez',
  ];

  final List<int> _anos = [2024, 2025, 2026, 2027, 2028, 2029, 2030];

  @override
  void initState() {
    super.initState();
    _dia = widget.dataInicial.day;
    _mes = widget.dataInicial.month;
    _ano = widget.dataInicial.year;
  }

  int _diasNoMes(int ano, int mes) {
    return DateTime(ano, mes + 1, 0).day;
  }

  void _atualizarData({int? dia, int? mes, int? ano}) {
    final novoAno = ano ?? _ano;
    final novoMes = mes ?? _mes;
    final maxDias = _diasNoMes(novoAno, novoMes);
    int novoDia = dia ?? _dia;

    if (novoDia > maxDias) {
      novoDia = maxDias;
    }

    setState(() {
      _dia = novoDia;
      _mes = novoMes;
      _ano = novoAno;
    });

    final novaData = DateTime(_ano, _mes, _dia);
    widget.onDateChanged(novaData);
  }

  Future<void> _abrirCalendario() async {
    final DateTime? selecionada = await showDatePicker(
      context: context,
      initialDate: DateTime(_ano, _mes, _dia),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFE50914),
              onPrimary: Colors.white,
              onSurface: Color(0xFF212121),
            ),
          ),
          child: child!,
        );
      },
    );

    if (selecionada != null) {
      _atualizarData(
        dia: selecionada.day,
        mes: selecionada.month,
        ano: selecionada.year,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final int totalDias = _diasNoMes(_ano, _mes);
    final List<int> listaDias = List.generate(totalDias, (i) => i + 1);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cabeçalho do Card com Ícone e Ação rápida de Calendário
          Row(
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                color: Color(0xFFE50914),
                size: 20,
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  "Data do Atendimento:",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2C3437),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.calendar_month_rounded,
                  color: Color(0xFFE50914),
                  size: 22,
                ),
                tooltip: "Abrir Calendário",
                onPressed: _abrirCalendario,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Seletores: Opção de Dia, Mês e Ano
          Row(
            children: [
              // Seletor: Dia
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Dia",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF616161),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      height: 48,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFE0E0E0)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          value: _dia,
                          isExpanded: true,
                          icon: const Icon(Icons.arrow_drop_down, color: Color(0xFFE50914)),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF212121),
                          ),
                          items: listaDias.map((d) {
                            return DropdownMenuItem<int>(
                              value: d,
                              child: Text(d.toString().padLeft(2, '0')),
                            );
                          }).toList(),
                          onChanged: (novoDia) {
                            if (novoDia != null) {
                              _atualizarData(dia: novoDia);
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),

              // Seletor: Mês
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Mês",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF616161),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      height: 48,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFE0E0E0)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          value: _mes,
                          isExpanded: true,
                          icon: const Icon(Icons.arrow_drop_down, color: Color(0xFFE50914)),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF212121),
                          ),
                          items: List.generate(12, (index) {
                            return DropdownMenuItem<int>(
                              value: index + 1,
                              child: Text(_meses[index]),
                            );
                          }),
                          onChanged: (novoMes) {
                            if (novoMes != null) {
                              _atualizarData(mes: novoMes);
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),

              // Seletor: Ano
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Ano",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF616161),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      height: 48,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFE0E0E0)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          value: _ano,
                          isExpanded: true,
                          icon: const Icon(Icons.arrow_drop_down, color: Color(0xFFE50914)),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF212121),
                          ),
                          items: _anos.map((a) {
                            return DropdownMenuItem<int>(
                              value: a,
                              child: Text(a.toString()),
                            );
                          }).toList(),
                          onChanged: (novoAno) {
                            if (novoAno != null) {
                              _atualizarData(ano: novoAno);
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
