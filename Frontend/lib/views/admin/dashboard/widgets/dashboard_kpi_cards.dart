import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../models/dashboard_metrics_model.dart';

class DashboardKpiCards extends StatelessWidget {
  final DashboardMetricsModel metrics;

  const DashboardKpiCards({super.key, required this.metrics});

  String _formatNumber(int value) {
    final s = value.toString();
    if (s.length <= 3) return s;
    final buffer = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(s[i]);
    }
    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 980) {
          return Column(
            children: [
              _buildTotalCard(),
              const SizedBox(height: 14),
              _buildGridUnidades(),
              const SizedBox(height: 14),
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
                  _buildTotalCard(),
                  const SizedBox(height: 14),
                  _buildGridUnidades(),
                ],
              ),
            ),
            const SizedBox(width: 18),
            Expanded(
              flex: 6,
              child: _buildAtendimentosPorMesCard(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTotalCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFF5F5),
            Color(0xFFFFFFFF),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderRed),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 12,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Total de Atendimentos",
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    _formatNumber(metrics.totalAtendimentos),
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.successBg,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.trending_up_rounded,
                          size: 13,
                          color: AppColors.success,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          "+${metrics.taxaCrescimentoMensal}%",
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.success,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.today_rounded,
                    size: 14,
                    color: AppColors.success,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    "${metrics.atendimentosHoje} atendimentos realizados hoje",
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.success,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFE53935), Color(0xFFB71C1C)],
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x33D32F2F),
                  blurRadius: 8,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: const Icon(
              Icons.medical_services_outlined,
              color: Colors.white,
              size: 26,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridUnidades() {
    final unidades = metrics.unidades.entries
        .where((e) => e.key != 'Outras')
        .toList();

    if (unidades.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: const Center(
          child: Text(
            "Nenhuma base com atendimento registrado no período",
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
        ),
      );
    }

    return Column(
      children: [
        for (int i = 0; i < unidades.length; i += 2)
          Padding(
            padding: EdgeInsets.only(bottom: i + 2 < unidades.length ? 12.0 : 0),
            child: Row(
              children: [
                Expanded(
                  child: _buildUnitCard(
                    nome: unidades[i].key,
                    porcentagem: unidades[i].value.porcentagem,
                    total: _formatNumber(unidades[i].value.total),
                    badgeColor: AppColors.badgeRed,
                    accentColor: AppColors.crimson,
                  ),
                ),
                if (i + 1 < unidades.length) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildUnitCard(
                      nome: unidades[i + 1].key,
                      porcentagem: unidades[i + 1].value.porcentagem,
                      total: _formatNumber(unidades[i + 1].value.total),
                      badgeColor: AppColors.warningBg,
                      accentColor: AppColors.darkOrange,
                    ),
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildUnitCard({
    required String nome,
    required double porcentagem,
    required String total,
    required Color badgeColor,
    required Color accentColor,
  }) {
    final double ratio = (porcentagem / 100.0).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: badgeColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(
                        Icons.airport_shuttle_outlined,
                        size: 14,
                        color: accentColor,
                      ),
                    ),
                    const SizedBox(width: 7),
                    Flexible(
                      child: Text(
                        nome,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: badgeColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  "$porcentagem%",
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: accentColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                total,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 6),
              const Text(
                "atendimentos",
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 5,
              backgroundColor: const Color(0xFFF2F4F7),
              valueColor: AlwaysStoppedAnimation<Color>(accentColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAtendimentosPorMesCard() {
    return Container(
      height: 364,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Evolução Mensal de Atendimentos",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    "Volume consolidado das unidades móveis ao longo do ano",
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.badgeRed,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.show_chart_rounded,
                      size: 15,
                      color: AppColors.primaryRed,
                    ),
                    SizedBox(width: 5),
                    Text(
                      "Média: 380/mês",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryRed,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Expanded(
            child: CustomPaint(
              painter: _AtendimentosChartPainter(),
              child: Container(),
            ),
          ),
          const SizedBox(height: 10),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Jan", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.textMuted)),
              Text("Fev", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.textMuted)),
              Text("Mar", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.textMuted)),
              Text("Abr", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.textMuted)),
              Text("Mai", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.textMuted)),
              Text("Jun", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.textMuted)),
              Text("Jul", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.textMuted)),
              Text("Ago", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.textMuted)),
              Text("Set", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.textMuted)),
              Text("Out", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.textMuted)),
              Text("Nov", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.textMuted)),
              Text("Dez", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primaryRed)),
            ],
          ),
        ],
      ),
    );
  }
}

class _AtendimentosChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = const Color(0xFFF0F2F5)
      ..strokeWidth = 1;

    for (int i = 0; i <= 4; i++) {
      final y = size.height * (i / 4);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final points = [
      Offset(0, size.height * 0.76),
      Offset(size.width * 0.09, size.height * 0.65),
      Offset(size.width * 0.18, size.height * 0.68),
      Offset(size.width * 0.27, size.height * 0.50),
      Offset(size.width * 0.36, size.height * 0.44),
      Offset(size.width * 0.45, size.height * 0.38),
      Offset(size.width * 0.54, size.height * 0.34),
      Offset(size.width * 0.63, size.height * 0.43),
      Offset(size.width * 0.72, size.height * 0.28),
      Offset(size.width * 0.81, size.height * 0.24),
      Offset(size.width * 0.90, size.height * 0.27),
      Offset(size.width, size.height * 0.16),
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
          Color(0x28D32F2F),
          Color(0x03D32F2F),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(fillPath, fillPaint);

    final linePaint = Paint()
      ..color = AppColors.primaryRed
      ..strokeWidth = 2.8
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawPath(path, linePaint);

    final dotPaint = Paint()..color = AppColors.primaryRed;
    final dotInnerPaint = Paint()..color = Colors.white;

    for (final p in points) {
      canvas.drawCircle(p, 4.2, dotPaint);
      canvas.drawCircle(p, 2.2, dotInnerPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
