// ============================================================================
// SERVIÇO DE IMPRESSÃO TÉRMICA E GERAÇÃO DE PDF
// Arquivo: lib/services/print_service.dart
// ============================================================================

import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/ficha_model.dart';

class PrintService {
  static final PrintService _instance = PrintService._internal();
  factory PrintService() => _instance;
  PrintService._internal();

  /// Gera os bytes do documento PDF formatado para ficha técnica do SAMU
  Future<Uint8List> gerarPdfFicha(FichaAtendimentoModel ficha) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll80, // Padrão bobina térmica 80mm
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Text(
                  "SAMU 192 - JOINVILLE",
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14),
                ),
              ),
              pw.Center(
                child: pw.Text("FICHA DE ATENDIMENTO APH"),
              ),
              pw.Divider(),
              pw.Text("Ocorrência: ${ficha.numeroOcorrencia}"),
              pw.Text("Data/Hora: ${ficha.dataHora.toString().substring(0, 16)}"),
              pw.Text("Viatura: ${ficha.unidadeResponsavel}"),
              pw.Divider(),
              pw.Text("Paciente: ${ficha.pacienteNome}"),
              if (ficha.pacienteIdade != null)
                pw.Text("Idade: ${ficha.pacienteIdade} anos"),
              pw.Text("Tipo: ${ficha.tipoOcorrencia}"),
              pw.Text("Local: ${ficha.endereco}"),
              if (ficha.queixaPrincipal != null) ...[
                pw.SizedBox(height: 4),
                pw.Text("Queixa: ${ficha.queixaPrincipal}"),
              ],
              pw.Divider(),
              pw.Center(
                child: pw.Text(
                  "*** VIA DA UNIDADE HOSPITALAR ***",
                  style: pw.TextStyle(fontSize: 9),
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  /// Dispara a impressão na impressora conectada (Bluetooth / USB ou diálogo do sistema)
  Future<bool> imprimirFicha(FichaAtendimentoModel ficha) async {
    try {
      final bytes = await gerarPdfFicha(ficha);
      return await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => bytes,
        name: 'Ficha_${ficha.numeroOcorrencia}.pdf',
      );
    } catch (_) {
      return false;
    }
  }
}
