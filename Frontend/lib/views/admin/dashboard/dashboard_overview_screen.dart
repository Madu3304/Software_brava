// ============================================================================
// ----------------------------------------------------------------------------
// [SEPARAÇÃO DE TELA] - INÍCIO DA TELA: DASHBOARD GERAL E MÉTRICAS (WEB)
// ----------------------------------------------------------------------------
// ============================================================================

import 'package:flutter/material.dart';
import '../../shared/tela_separador_widget.dart';

class DashboardOverviewScreen extends StatefulWidget {
  const DashboardOverviewScreen({super.key});

  @override
  State<DashboardOverviewScreen> createState() => _DashboardOverviewScreenState();
}

class _DashboardOverviewScreenState extends State<DashboardOverviewScreen> {
  String _selectedAno = '2026';
  String _selectedMes = 'Todos os Meses';
  String _selectedDia = 'Todos os Dias';
  String _selectedUnidade = 'Todas as Unidades';

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ==================================================================
          // SEPARADOR EXPLÍCITO INDICANDO O INÍCIO DESTA TELA
          // ==================================================================
          const TelaSeparadorWidget(
            nomeTela: 'Tela 1: Dashboard Geral de Atendimentos e Indicadores',
            modulo: 'ADMINISTRADOR / MONITORAMENTO EM TEMPO REAL',
            icone: Icons.dashboard_outlined,
          ),

          // Título e Subtítulo da Página
          const Text(
            "Dashboard",
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E1E1E),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            "Acompanhe os resultados das unidades móveis de atendimento",
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF757575),
            ),
          ),
          const SizedBox(height: 20),

          // Card de Filtros
          _buildFiltersCard(),
          const SizedBox(height: 24),

          // Visão Geral: Indicadores Principais + Gráfico Mensal
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 1100) {
                return Column(
                  children: [
                    _buildTotalAtendimentosCard(),
                    const SizedBox(height: 16),
                    _buildGridUnidades(),
                    const SizedBox(height: 16),
                    _buildAtendimentosPorMesCard(),
                  ],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 5,
                    child: Column(
                      children: [
                        _buildTotalAtendimentosCard(),
                        const SizedBox(height: 16),
                        _buildGridUnidades(),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    flex: 6,
                    child: _buildAtendimentosPorMesCard(),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 32),

          // ==================================================================
          // SEÇÃO: MÉTRICAS DETALHADAS (IMAGEM 3)
          // ==================================================================
          const Text(
            "Métricas Detalhadas",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E1E1E),
            ),
          ),
          const SizedBox(height: 16),

          // Linha 1 de métricas detalhadas (3 cards)
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 1000) {
                return Column(
                  children: [
                    _buildAtendimentosRealizadosCard(),
                    const SizedBox(height: 16),
                    _buildFaixaEtariaCard(),
                    const SizedBox(height: 16),
                    _buildLocaisMaiorOcorrenciaCard(),
                  ],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _buildAtendimentosRealizadosCard()),
                  const SizedBox(width: 16),
                  Expanded(child: _buildFaixaEtariaCard()),
                  const SizedBox(width: 16),
                  Expanded(child: _buildLocaisMaiorOcorrenciaCard()),
                ],
              );
            },
          ),
          const SizedBox(height: 16),

          // Linha 2 de métricas detalhadas (2 cards)
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 1000) {
                return Column(
                  children: [
                    _buildTempoMedioRespostaCard(),
                    const SizedBox(height: 16),
                    _buildIndisponibilidadeAmbulanciasCard(),
                  ],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _buildTempoMedioRespostaCard()),
                  const SizedBox(width: 16),
                  Expanded(child: _buildIndisponibilidadeAmbulanciasCard()),
                ],
              );
            },
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // Card de Filtros
  Widget _buildFiltersCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8E8E8)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.tune_rounded, size: 16, color: Color(0xFFD32F2F)),
              SizedBox(width: 8),
              Text(
                "Filtros",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF333333),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildFilterDropdown(
                label: "Ano",
                icon: Icons.calendar_today_outlined,
                value: _selectedAno,
                items: const ['2026', '2025', '2024'],
                onChanged: (val) => setState(() => _selectedAno = val!),
              ),
              _buildFilterDropdown(
                label: "Mês",
                icon: Icons.calendar_month_outlined,
                value: _selectedMes,
                items: const ['Todos os Meses', 'Janeiro', 'Fevereiro', 'Março', 'Abril'],
                onChanged: (val) => setState(() => _selectedMes = val!),
              ),
              _buildFilterDropdown(
                label: "Dia",
                icon: Icons.date_range_outlined,
                value: _selectedDia,
                items: const ['Todos os Dias', '01 a 10', '11 a 20', '21 a 31'],
                onChanged: (val) => setState(() => _selectedDia = val!),
              ),
              _buildFilterDropdown(
                label: "Unidade",
                icon: Icons.local_hospital_outlined,
                value: _selectedUnidade,
                items: const ['Todas as Unidades', 'Unidade Norte', 'Unidade Sul', 'Unidade Leste', 'Unidade Oeste'],
                onChanged: (val) => setState(() => _selectedUnidade = val!),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown({
    required String label,
    required IconData icon,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      width: 170,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: Color(0xFF757575)),
          style: const TextStyle(fontSize: 13, color: Color(0xFF333333), fontWeight: FontWeight.w500),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Row(
                children: [
                  Icon(icon, size: 14, color: const Color(0xFF9E9E9E)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      item,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildTotalAtendimentosCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7F7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFEBEE)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                "Total de Atendimentos",
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF757575),
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8),
              Text(
                "4.562",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E1E1E),
                ),
              ),
              SizedBox(height: 6),
              Row(
                children: [
                  Icon(Icons.trending_up, size: 16, color: Color(0xFF2E7D32)),
                  SizedBox(width: 4),
                  Text(
                    "+12.5% este mês",
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF2E7D32),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFEBEE),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.people_outline_rounded,
              color: Color(0xFFD32F2F),
              size: 28,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridUnidades() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildUnitCard(
                nome: "Unidade Norte",
                porcentagem: "27.3%",
                total: "1.247",
                badgeColor: const Color(0xFFFFEBEE),
                textColor: const Color(0xFFC62828),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _buildUnitCard(
                nome: "Unidade Sul",
                porcentagem: "21.5%",
                total: "983",
                badgeColor: const Color(0xFFFFF3E0),
                textColor: const Color(0xFFE65100),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _buildUnitCard(
                nome: "Unidade Leste",
                porcentagem: "31.9%",
                total: "1.456",
                badgeColor: const Color(0xFFFFEBEE),
                textColor: const Color(0xFFC62828),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _buildUnitCard(
                nome: "Unidade Oeste",
                porcentagem: "19.2%",
                total: "876",
                badgeColor: const Color(0xFFFFF3E0),
                textColor: const Color(0xFFE65100),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildUnitCard({
    required String nome,
    required String porcentagem,
    required String total,
    required Color badgeColor,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8E8E8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.airport_shuttle_outlined, size: 16, color: textColor),
                  const SizedBox(width: 6),
                  Text(
                    nome,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF333333),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: badgeColor,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  porcentagem,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            total,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E1E1E),
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            "atendimentos realizados",
            style: TextStyle(
              fontSize: 11,
              color: Color(0xFF9E9E9E),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAtendimentosPorMesCard() {
    return Container(
      height: 335,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8E8E8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Atendimentos por Mês",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E1E1E),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            "Evolução mensal dos atendimentos das unidades móveis",
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF757575),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: CustomPaint(
              painter: _AtendimentosChartPainter(),
              child: Container(),
            ),
          ),
          const SizedBox(height: 8),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Jan", style: TextStyle(fontSize: 10, color: Color(0xFF9E9E9E))),
              Text("Fev", style: TextStyle(fontSize: 10, color: Color(0xFF9E9E9E))),
              Text("Mar", style: TextStyle(fontSize: 10, color: Color(0xFF9E9E9E))),
              Text("Abr", style: TextStyle(fontSize: 10, color: Color(0xFF9E9E9E))),
              Text("Mai", style: TextStyle(fontSize: 10, color: Color(0xFF9E9E9E))),
              Text("Jun", style: TextStyle(fontSize: 10, color: Color(0xFF9E9E9E))),
              Text("Jul", style: TextStyle(fontSize: 10, color: Color(0xFF9E9E9E))),
              Text("Ago", style: TextStyle(fontSize: 10, color: Color(0xFF9E9E9E))),
              Text("Set", style: TextStyle(fontSize: 10, color: Color(0xFF9E9E9E))),
              Text("Out", style: TextStyle(fontSize: 10, color: Color(0xFF9E9E9E))),
              Text("Nov", style: TextStyle(fontSize: 10, color: Color(0xFF9E9E9E))),
              Text("Dez", style: TextStyle(fontSize: 10, color: Color(0xFF9E9E9E))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAtendimentosRealizadosCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8E8E8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.insights, size: 16, color: Color(0xFFD32F2F)),
              SizedBox(width: 8),
              Text(
                "Atendimentos Realizados",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF424242),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                "1.847",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E1E1E),
                ),
              ),
              SizedBox(width: 8),
              Text(
                "+12.5%",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E7D32),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildMetricRow("Emergências", "523", const Color(0xFFD32F2F)),
          const SizedBox(height: 8),
          _buildMetricRow("Urgências", "892", const Color(0xFFF57C00)),
          const SizedBox(height: 8),
          _buildMetricRow("Rotina", "432", const Color(0xFF2E7D32)),
        ],
      ),
    );
  }

  Widget _buildMetricRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Color(0xFF616161)),
        ),
        Text(
          value,
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }

  Widget _buildFaixaEtariaCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8E8E8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.family_restroom, size: 16, color: Color(0xFFD32F2F)),
              SizedBox(width: 8),
              Text(
                "Faixa Etária dos Pacientes",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF424242),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildAgeBar("0-12 anos", 0.133, "13.3%"),
          const SizedBox(height: 8),
          _buildAgeBar("13-25 anos", 0.189, "18.9%"),
          const SizedBox(height: 8),
          _buildAgeBar("26-40 anos", 0.285, "28.5%"),
          const SizedBox(height: 8),
          _buildAgeBar("41-60 anos", 0.247, "24.7%"),
          const SizedBox(height: 8),
          _buildAgeBar("60+ anos", 0.185, "18.5%"),
        ],
      ),
    );
  }

  Widget _buildAgeBar(String label, double ratio, String percent) {
    return Row(
      children: [
        SizedBox(
          width: 70,
          child: Text(
            label,
            style: const TextStyle(fontSize: 11, color: Color(0xFF616161)),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 8,
              backgroundColor: const Color(0xFFF0F0F0),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFE65100)),
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 40,
          child: Text(
            percent,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF424242),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLocaisMaiorOcorrenciaCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8E8E8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.location_on_outlined, size: 16, color: Color(0xFFD32F2F)),
              SizedBox(width: 8),
              Text(
                "Locais com Maior Ocorrência",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF424242),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildLocationRow("1", "Centro", "387 (21%)"),
          const SizedBox(height: 8),
          _buildLocationRow("2", "Zona Norte", "342 (18.5%)"),
          const SizedBox(height: 8),
          _buildLocationRow("3", "Zona Sul", "298 (16.1%)"),
          const SizedBox(height: 8),
          _buildLocationRow("4", "Zona Leste", "456 (24.7%)"),
          const SizedBox(height: 8),
          _buildLocationRow("5", "Zona Oeste", "364 (19.7%)"),
        ],
      ),
    );
  }

  Widget _buildLocationRow(String pos, String local, String ocorrencias) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFFD32F2F),
          ),
          child: Center(
            child: Text(
              pos,
              style: const TextStyle(
                fontSize: 10,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            local,
            style: const TextStyle(fontSize: 12, color: Color(0xFF424242)),
          ),
        ),
        Text(
          ocorrencias,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF616161),
          ),
        ),
      ],
    );
  }

  Widget _buildTempoMedioRespostaCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8E8E8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.schedule, size: 16, color: Color(0xFFD32F2F)),
              SizedBox(width: 8),
              Text(
                "Tempo Médio de Resposta",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF424242),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                "8:42",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E1E1E),
                ),
              ),
              SizedBox(width: 8),
              Text(
                "-5.2%",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E7D32),
                ),
              ),
            ],
          ),
          const Text(
            "minutos em média",
            style: TextStyle(fontSize: 11, color: Color(0xFF9E9E9E)),
          ),
          const Divider(height: 24, color: Color(0xFFEEEEEE)),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Mais rápida", style: TextStyle(fontSize: 11, color: Color(0xFF9E9E9E))),
                  SizedBox(height: 2),
                  Text("6:15", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E))),
                  Text("Unidade Norte", style: TextStyle(fontSize: 10, color: Color(0xFF757575))),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text("Mais lenta", style: TextStyle(fontSize: 11, color: Color(0xFF9E9E9E))),
                  SizedBox(height: 2),
                  Text("11:30", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E))),
                  Text("Unidade Oeste", style: TextStyle(fontSize: 10, color: Color(0xFF757575))),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIndisponibilidadeAmbulanciasCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8E8E8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.warning_amber_rounded, size: 16, color: Color(0xFFD32F2F)),
              SizedBox(width: 8),
              Text(
                "Indisponibilidade das Ambulâncias",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF424242),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "12.3%",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E1E1E),
                ),
              ),
              Text(
                "287h / 2332h",
                style: TextStyle(fontSize: 11, color: Color(0xFF757575)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Container(
              height: 8,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF4CAF50),
                    Color(0xFFFF9800),
                    Color(0xFFF44336),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildUnitIndisponibilidade("Norte", "8.5%", const Color(0xFF2E7D32)),
              _buildUnitIndisponibilidade("Sul", "15.2%", const Color(0xFFD32F2F)),
              _buildUnitIndisponibilidade("Leste", "10.8%", const Color(0xFFF57C00)),
              _buildUnitIndisponibilidade("Oeste", "14.7%", const Color(0xFFD32F2F)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUnitIndisponibilidade(String unit, String percent, Color color) {
    return Column(
      children: [
        Text(unit, style: const TextStyle(fontSize: 11, color: Color(0xFF757575))),
        const SizedBox(height: 2),
        Text(
          percent,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }
}

class _AtendimentosChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = const Color(0xFFF0F0F0)
      ..strokeWidth = 1;

    for (int i = 0; i <= 4; i++) {
      final y = size.height * (i / 4);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final points = [
      Offset(0, size.height * 0.75),
      Offset(size.width * 0.09, size.height * 0.65),
      Offset(size.width * 0.18, size.height * 0.70),
      Offset(size.width * 0.27, size.height * 0.50),
      Offset(size.width * 0.36, size.height * 0.45),
      Offset(size.width * 0.45, size.height * 0.40),
      Offset(size.width * 0.54, size.height * 0.35),
      Offset(size.width * 0.63, size.height * 0.45),
      Offset(size.width * 0.72, size.height * 0.30),
      Offset(size.width * 0.81, size.height * 0.25),
      Offset(size.width * 0.90, size.height * 0.30),
      Offset(size.width, size.height * 0.20),
    ];

    final path = Path();
    path.moveTo(points[0].dx, points[0].dy);
    for (int i = 0; i < points.length - 1; i++) {
      final p0 = points[i];
      final p1 = points[i + 1];
      final cx = (p0.dx + p1.dx) / 2;
      path.cubicTo(cx, p0.dy, cx, p1.dy, p1.dx, p1.dy);
    }

    final fillPath = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    final fillPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0x20D32F2F),
          Color(0x00FFFFFF),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(fillPath, fillPaint);

    final linePaint = Paint()
      ..color = const Color(0xFFD32F2F)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    canvas.drawPath(path, linePaint);

    final dotPaint = Paint()..color = const Color(0xFFD32F2F);
    final dotInnerPaint = Paint()..color = Colors.white;

    for (final p in points) {
      canvas.drawCircle(p, 3.5, dotPaint);
      canvas.drawCircle(p, 2, dotInnerPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
