import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_routes.dart';
import '../../models/ficha_model.dart';
import '../../providers/ficha_provider.dart';
import '../../services/database_service.dart';
import '../../services/docusign_service.dart';

class AssinaturaPacienteView extends StatefulWidget {
  final FichaAtendimentoModel? fichaParcial;

  const AssinaturaPacienteView({
    super.key,
    this.fichaParcial,
  });

  @override
  State<AssinaturaPacienteView> createState() => _AssinaturaPacienteViewState();
}

class _AssinaturaPacienteViewState extends State<AssinaturaPacienteView> {
  // Pontos desenhados com a caneta no quadro branco
  final List<List<Offset>> _strokes = [];
  List<Offset> _currentStroke = [];
  Color _penColor = const Color(0xFF1A237E); // Azul escuro padrão caneta esferográfica

  // Estado DocuSign
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _telefoneController = TextEditingController();
  final DocuSignService _docuSignService = DocuSignService();
  bool _isDocuSignLoading = false;
  String? _docusignEnvelopeId;
  String? _docusignStatus;

  // Estado de impossibilidade de assinatura
  bool _impossibilitadoAssinar = false;
  final TextEditingController _motivoImpossibilidadeController = TextEditingController();

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final ficha = widget.fichaParcial;
    if (ficha?.telefoneContato != null) {
      _telefoneController.text = ficha!.telefoneContato!;
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _telefoneController.dispose();
    _motivoImpossibilidadeController.dispose();
    super.dispose();
  }

  bool get _temAssinatura => _strokes.isNotEmpty || _currentStroke.isNotEmpty || _docusignEnvelopeId != null || _impossibilitadoAssinar;

  void _limparQuadro() {
    setState(() {
      _strokes.clear();
      _currentStroke.clear();
    });
  }

  Future<void> _conectarDocuSign(FichaAtendimentoModel ficha) async {
    setState(() => _isDocuSignLoading = true);

    final resultado = await _docuSignService.criarEnvelope(
      numeroOcorrencia: ficha.numeroOcorrencia,
      pacienteNome: ficha.pacienteNome,
      pacienteCpf: ficha.pacienteCpf,
      email: _emailController.text.trim().isNotEmpty ? _emailController.text.trim() : null,
      telefone: _telefoneController.text.trim().isNotEmpty ? _telefoneController.text.trim() : null,
      condutaResumo: ficha.condutaMedica,
    );

    setState(() {
      _isDocuSignLoading = false;
      _docusignEnvelopeId = resultado.envelopeId;
      _docusignStatus = resultado.status;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Envelope DocuSign #${resultado.envelopeId} vinculado com sucesso!",
          ),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  Future<void> _finalizarAtendimentoEImprimir() async {
    FichaAtendimentoModel? fichaBase = widget.fichaParcial ??
        ModalRoute.of(context)?.settings.arguments as FichaAtendimentoModel? ??
        context.read<FichaEmAndamentoProvider>().ficha;

    if (fichaBase == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Nenhuma ocorrência em andamento. Inicie o atendimento pela Ficha."),
          backgroundColor: AppColors.error,
        ),
      );
      Navigator.pushReplacementNamed(context, AppRoutes.ficha);
      return;
    }

    if (!_temAssinatura) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Por favor, colete a assinatura do paciente, conecte ao DocuSign ou justifique a impossibilidade."),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    String condutaAtualizada = fichaBase.condutaMedica ?? '';
    if (_docusignEnvelopeId != null) {
      condutaAtualizada += " | DocuSign: Envelope ${_docusignEnvelopeId!} (${_docusignStatus ?? 'autenticado'})";
    } else if (_impossibilitadoAssinar) {
      final motivo = _motivoImpossibilidadeController.text.trim().isNotEmpty
          ? _motivoImpossibilidadeController.text.trim()
          : "Paciente impossibilitado de assinar no local";
      condutaAtualizada += " | Assinatura: Dispensada ($motivo)";
    } else {
      condutaAtualizada += " | Assinatura: Coletada na tela com caneta digital";
    }

    final fichaFinal = fichaBase.copyWith(
      condutaMedica: condutaAtualizada,
    );

    try {
      await DatabaseService().inserirFicha(fichaFinal);

      if (!mounted) return;
      context.read<FichaEmAndamentoProvider>().setFicha(fichaFinal);

      setState(() => _isSaving = false);

      Navigator.pushNamed(
        context,
        AppRoutes.folhaGastos,
        arguments: fichaFinal,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Não foi possível salvar o atendimento localmente. Verifique o espaço e tente novamente."),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    FichaAtendimentoModel? ficha = widget.fichaParcial ??
        ModalRoute.of(context)?.settings.arguments as FichaAtendimentoModel? ??
        context.read<FichaEmAndamentoProvider>().ficha;

    final nomeExibido = ficha?.pacienteNome ?? 'Paciente em Atendimento';
    final ocorrenciaExibida = ficha?.numeroOcorrencia ?? 'SAMU-192';

    return Scaffold(
      backgroundColor: const Color(0xFFFBF8F5),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            // ==========================================
            // CABEÇALHO PADRÃO "ASSINATURA DO PACIENTE"
            // ==========================================
            _buildHeader(context),

            // Linha decorativa de progresso (conclusão total)
            _buildProgressLine(),

            // ==========================================
            // CONTEÚDO PRINCIPAL
            // ==========================================
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 620),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Card Resumo do Paciente
                        _buildPacienteResumoCard(nomeExibido, ocorrenciaExibida, ficha),
                        const SizedBox(height: 16),

                        // Opção de impossibilidade de assinatura
                        _buildImpossibilitadoCheckbox(),
                        const SizedBox(height: 16),

                        if (!_impossibilitadoAssinar) ...[
                          // Quadro Branco para Assinatura com Caneta
                          _buildQuadroBrancoCaneta(),
                          const SizedBox(height: 20),

                          // Card Conexão DocuSign
                          if (ficha != null) _buildDocuSignCard(ficha),
                          const SizedBox(height: 28),
                        ],

                        // Botão Continuar para Folha de Gastos
                        SizedBox(
                          height: 52,
                          child: ElevatedButton(
                            onPressed: _isSaving ? null : _finalizarAtendimentoEImprimir,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.crimson,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              elevation: 2,
                            ),
                            child: _isSaving
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                  )
                                : const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "Continuar para Folha de Gastos",
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
                                    ],
                                  ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Opção de Voltar
                        Center(
                          child: TextButton.icon(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.arrow_back, size: 16, color: AppColors.textSecondary),
                            label: const Text(
                              "Voltar à Avaliação Clínica",
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 14,
        bottom: 16,
        left: 16,
        right: 16,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF8B1D1D),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
            onPressed: () => Navigator.pop(context),
            tooltip: "Voltar",
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text(
                  "TERMO DE ATENDIMENTO",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                    color: Color(0xFFFFD5B8),
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  "Assinatura do Paciente",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _temAssinatura ? const Color(0xFF1E7E34) : const Color(0xFF6B1414),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _temAssinatura ? const Color(0xFF38B000) : const Color(0xFF9E3C3C),
                width: 1.2,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _temAssinatura ? Icons.check_circle_rounded : Icons.pending_outlined,
                  size: 14,
                  color: Colors.white,
                ),
                const SizedBox(width: 4),
                Text(
                  _temAssinatura ? "Pronto" : "Pendente",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressLine() {
    return Container(
      height: 3,
      color: const Color(0xFFE65100), // Conclusão do fluxo assistencial
    );
  }

  Widget _buildPacienteResumoCard(String nome, String ocorrencia, FichaAtendimentoModel? ficha) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE6E6E6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.description_outlined, color: Color(0xFF8B1D1D), size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  "Termo de Consentimento & Ciência Pré-Hospitalar",
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C2C2C),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "Declaro estar ciente dos procedimentos, medicações e condutas assistenciais prestadas pela equipe do SAMU Joinville na ocorrência $ocorrencia.",
            style: const TextStyle(fontSize: 12, color: Color(0xFF666666)),
          ),
          const Divider(height: 18, color: Color(0xFFEEEEEE)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Paciente: $nome",
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF333333)),
              ),
              if (ficha?.pacienteCpf != null)
                Text(
                  "CPF: ${ficha!.pacienteCpf}",
                  style: const TextStyle(fontSize: 12, color: Color(0xFF666666)),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildImpossibilitadoCheckbox() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: _impossibilitadoAssinar ? const Color(0xFFFFF3CD) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _impossibilitadoAssinar ? const Color(0xFFFFEEBA) : const Color(0xFFE6E6E6),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Checkbox(
                value: _impossibilitadoAssinar,
                activeColor: const Color(0xFF8B1D1D),
                onChanged: (val) {
                  setState(() {
                    _impossibilitadoAssinar = val ?? false;
                  });
                },
              ),
              const Expanded(
                child: Text(
                  "Paciente impossibilitado de assinar fisicamente (inconsciente, trauma em MMSS ou sem acompanhante)",
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF333333)),
                ),
              ),
            ],
          ),
          if (_impossibilitadoAssinar) ...[
            const SizedBox(height: 8),
            TextFormField(
              controller: _motivoImpossibilidadeController,
              decoration: const InputDecoration(
                labelText: "Motivo da impossibilidade",
                hintText: "Ex.: Paciente rebaixado / Glasgow 8 / Ausência de acompanhante",
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuadroBrancoCaneta() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFD6C8C8), width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Barra de Ferramentas da Caneta
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: const BoxDecoration(
              color: Color(0xFFFBFBFB),
              borderRadius: BorderRadius.vertical(top: Radius.circular(13)),
              border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE))),
            ),
            child: Row(
              children: [
                const Icon(Icons.draw_outlined, size: 20, color: Color(0xFF8B1D1D)),
                const SizedBox(width: 8),
                const Text(
                  "Quadro de Assinatura com Caneta",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF333333)),
                ),
                const Spacer(),

                // Seletor de cores de caneta (Preto / Azul)
                InkWell(
                  onTap: () => setState(() => _penColor = const Color(0xFF1A237E)),
                  child: Container(
                    width: 22,
                    height: 22,
                    margin: const EdgeInsets.only(right: 6),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF1A237E),
                      border: Border.all(
                        color: _penColor == const Color(0xFF1A237E) ? const Color(0xFF8B1D1D) : Colors.transparent,
                        width: 2,
                      ),
                    ),
                  ),
                ),
                InkWell(
                  onTap: () => setState(() => _penColor = Colors.black),
                  child: Container(
                    width: 22,
                    height: 22,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black,
                      border: Border.all(
                        color: _penColor == Colors.black ? const Color(0xFF8B1D1D) : Colors.transparent,
                        width: 2,
                      ),
                    ),
                  ),
                ),

                // Botão Limpar Traço
                TextButton.icon(
                  onPressed: _limparQuadro,
                  icon: const Icon(Icons.refresh_rounded, size: 16, color: Color(0xFF8B1D1D)),
                  label: const Text(
                    "Limpar",
                    style: TextStyle(color: Color(0xFF8B1D1D), fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                ),
              ],
            ),
          ),

          // Área Branca de Desenho Interativa (Caneta / Touch / Mouse)
          SizedBox(
            height: 200,
            child: Stack(
              children: [
                // Linha de assinatura de fundo
                Positioned(
                  bottom: 36,
                  left: 24,
                  right: 24,
                  child: Row(
                    children: const [
                      Text("X", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFBDBDBD))),
                      SizedBox(width: 8),
                      Expanded(
                        child: Divider(color: Color(0xFFBDBDBD), thickness: 1.2),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 12,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Text(
                      "Assine com caneta touch, stylus ou dedo no quadro acima",
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                    ),
                  ),
                ),

                // Detector de gestos para desenhar traços
                GestureDetector(
                  onPanStart: (details) {
                    setState(() {
                      final box = context.findRenderObject() as RenderBox?;
                      final localPos = details.localPosition;
                      _currentStroke = [localPos];
                    });
                  },
                  onPanUpdate: (details) {
                    setState(() {
                      _currentStroke.add(details.localPosition);
                    });
                  },
                  onPanEnd: (details) {
                    setState(() {
                      if (_currentStroke.isNotEmpty) {
                        _strokes.add(List.from(_currentStroke));
                        _currentStroke.clear();
                      }
                    });
                  },
                  child: CustomPaint(
                    size: const Size(double.infinity, 200),
                    painter: SignaturePainter(
                      strokes: _strokes,
                      currentStroke: _currentStroke,
                      strokeColor: _penColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocuSignCard(FichaAtendimentoModel ficha) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _docusignEnvelopeId != null ? const Color(0xFF1E7E34) : const Color(0xFFD0D7DE),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF003D7A),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  "DocuSign",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  "Conexão DocuSign eSignature REST API",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF2C2C2C)),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _docusignEnvelopeId != null ? const Color(0xFFE6F4EA) : const Color(0xFFF1F3F4),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _docusignEnvelopeId != null ? "Conectado" : "Pronto",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: _docusignEnvelopeId != null ? const Color(0xFF137333) : const Color(0xFF5F6368),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            "Envie uma cópia certificada do termo para assinatura remota via DocuSign (validade jurídica ICP-Brasil).",
            style: TextStyle(fontSize: 12, color: Color(0xFF666666)),
          ),
          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: "E-mail do signatário (opcional)",
                    hintText: "paciente@exemplo.com",
                    prefixIcon: Icon(Icons.email_outlined, size: 18),
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: _isDocuSignLoading ? null : () => _conectarDocuSign(ficha),
                icon: _isDocuSignLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.send_rounded, size: 16),
                label: const Text("Vincular DocuSign"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF003D7A),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),

          if (_docusignEnvelopeId != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFA5D6A7)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.verified_rounded, color: Color(0xFF2E7D32), size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Envelope DocuSign ${_docusignEnvelopeId!} autenticado e integrado à ficha.",
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF1B5E20)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Pintor customizado para desenhar o traço da caneta de forma suave
class SignaturePainter extends CustomPainter {
  final List<List<Offset>> strokes;
  final List<Offset> currentStroke;
  final Color strokeColor;

  SignaturePainter({
    required this.strokes,
    required this.currentStroke,
    required this.strokeColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = strokeColor
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;

    // Desenha traços finalizados
    for (final stroke in strokes) {
      if (stroke.isEmpty) continue;
      if (stroke.length == 1) {
        canvas.drawCircle(stroke.first, 2.0, paint..style = PaintingStyle.fill);
        paint.style = PaintingStyle.stroke;
      } else {
        final path = Path();
        path.moveTo(stroke.first.dx, stroke.first.dy);
        for (int i = 1; i < stroke.length; i++) {
          path.lineTo(stroke[i].dx, stroke[i].dy);
        }
        canvas.drawPath(path, paint);
      }
    }

    // Desenha o traço atual em andamento
    if (currentStroke.isNotEmpty) {
      if (currentStroke.length == 1) {
        canvas.drawCircle(currentStroke.first, 2.0, paint..style = PaintingStyle.fill);
      } else {
        final path = Path();
        path.moveTo(currentStroke.first.dx, currentStroke.first.dy);
        for (int i = 1; i < currentStroke.length; i++) {
          path.lineTo(currentStroke[i].dx, currentStroke[i].dy);
        }
        canvas.drawPath(path, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant SignaturePainter oldDelegate) => true;
}

