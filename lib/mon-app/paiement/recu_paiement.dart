import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

Future<Uint8List> buildReceiptPdf({
  required String compagnieName,
  required String depart,
  required String arrivee,
  required String dateLabel,
  required String heureLabel,
  required int travelersCount,
  required String montantLabel,
  required String reference,
  required String validiteLabel,
  required String qrData,
  required List<String> voyageurLines,
}) async {
  final doc = pw.Document();

  doc.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a5,
      build: (context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Converge SAS',
            style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
          ),
          pw.Text(
            'Reçu de paiement',
            style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
          ),
          pw.SizedBox(height: 16),
          pw.Divider(),
          _pdfRow('Compagnie', compagnieName),
          _pdfRow('Départ', depart.isEmpty ? '—' : depart),
          _pdfRow('Arrivée', arrivee.isEmpty ? '—' : arrivee),
          _pdfRow('Date', dateLabel),
          _pdfRow('Heure', heureLabel),
          _pdfRow('Voyageurs', '$travelersCount'),
          // for (final line in voyageurLines) _pdfRow('', line),
          for (final line in voyageurLines)
            _pdfRow(
              line.split(' — code ').first,
              line.contains(' — code ') ? line.split(' — code ').last : '',
            ),
          _pdfRow('Référence', reference),
          pw.Divider(),
          _pdfRow('Prix du transport', montantLabel, bold: true),
          pw.SizedBox(height: 4),
          pw.Text(
            validiteLabel,
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
          ),
          pw.SizedBox(height: 20),
          pw.Center(
            child: pw.BarcodeWidget(
              barcode: pw.Barcode.qrCode(),
              data: qrData,
              width: 120,
              height: 120,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Center(
            child: pw.Text(
              'Scannez pour vérifier ce billet',
              style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
            ),
          ),
        ],
      ),
    ),
  );

  return doc.save();
}

pw.Widget _pdfRow(String label, String value, {bool bold = false}) {
  return pw.Padding(
    padding: const pw.EdgeInsets.symmetric(vertical: 3),
    child: pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          label,
          style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey700),
        ),
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: bold ? 14 : 11,
            fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
          ),
        ),
      ],
    ),
  );
}
