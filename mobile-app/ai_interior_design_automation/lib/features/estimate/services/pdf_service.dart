import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import '../models/estimate_model.dart';

class PdfService {
  final _currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
  final _dateFormat = DateFormat('dd MMM yyyy');

  /// Generate PDF for estimate
  Future<File> generateEstimatePdf(EstimateModel estimate) async {
    final designImage = estimate.designImageUrl != null 
        ? await networkImage(estimate.designImageUrl!) 
        : null;

    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          _buildHeader(estimate),
          pw.SizedBox(height: 20),
          _buildProjectInfo(estimate),
          pw.SizedBox(height: 20),
          if (designImage != null)
             pw.Container(
               margin: const pw.EdgeInsets.only(bottom: 20),
               child: pw.Column(
                 crossAxisAlignment: pw.CrossAxisAlignment.start,
                 children: [
                   pw.Text('AI Design Concept', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14, color: PdfColors.blue900)),
                   pw.SizedBox(height: 8),
                   pw.ClipRRect(
                     horizontalRadius: 8,
                     verticalRadius: 8,
                     child: pw.Container(
                       height: 250,
                       width: double.infinity,
                       color: PdfColors.grey100,
                       child: pw.Image(designImage, fit: pw.BoxFit.cover),
                     ),
                   ),
                 ],
               ),
             ),
          _buildItemsTable(estimate),
          pw.SizedBox(height: 20),
          _buildTotals(estimate),
          pw.SizedBox(height: 20),
          _buildExplanation(estimate),
          pw.SizedBox(height: 30),
          _buildFooter(),
        ],
      ),
    );

    // Save to file
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/estimate_${estimate.id}.pdf');
    await file.writeAsBytes(await pdf.save());

    return file;
  }

  pw.Widget _buildHeader(EstimateModel estimate) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColors.blue900,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'BUDGET ESTIMATE',
            style: pw.TextStyle(
              color: PdfColors.white,
              fontSize: 24,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            'AI Interior Design Automation',
            style: const pw.TextStyle(
              color: PdfColors.white,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildProjectInfo(EstimateModel estimate) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Project Name',
                    style: pw.TextStyle(
                      fontSize: 10,
                      color: PdfColors.grey700,
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    estimate.projectName,
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text(
                    'Estimate ID',
                    style: pw.TextStyle(
                      fontSize: 10,
                      color: PdfColors.grey700,
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    '#${estimate.id.substring(0, 8).toUpperCase()}',
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 12),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              _buildInfoItem('Date', _dateFormat.format(estimate.createdAt)),
              _buildInfoItem('Version', 'v${estimate.version}'),
              _buildInfoItem('Status', estimate.status.name.toUpperCase()),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _buildInfoItem(String label, String value) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(
            fontSize: 10,
            color: PdfColors.grey700,
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 12,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
      ],
    );
  }

  pw.Widget _buildItemsTable(EstimateModel estimate) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300),
      columnWidths: {
        0: const pw.FlexColumnWidth(3),
        1: const pw.FlexColumnWidth(1),
        2: const pw.FlexColumnWidth(1),
        3: const pw.FlexColumnWidth(1.5),
        4: const pw.FlexColumnWidth(1.5),
      },
      children: [
        // Header
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey200),
          children: [
            _buildTableHeader('Description'),
            _buildTableHeader('Qty'),
            _buildTableHeader('Unit'),
            _buildTableHeader('Rate'),
            _buildTableHeader('Amount'),
          ],
        ),
        // Items grouped by category
        ...estimate.items.map((item) {
          return pw.TableRow(
            children: [
              _buildTableCell(item.description, isDescription: true),
              _buildTableCell(item.quantity.toStringAsFixed(0)),
              _buildTableCell(item.unit),
              _buildTableCell(_currencyFormat.format(item.rate)),
              _buildTableCell(_currencyFormat.format(item.amount)),
            ],
          );
        }),
      ],
    );
  }

  pw.Widget _buildTableHeader(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontWeight: pw.FontWeight.bold,
          fontSize: 10,
        ),
      ),
    );
  }

  pw.Widget _buildTableCell(String text, {bool isDescription = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: isDescription ? 10 : 9,
          fontWeight: isDescription ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }

  pw.Widget _buildTotals(EstimateModel estimate) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        children: [
          _buildTotalRow('Subtotal', estimate.subtotal),
          pw.SizedBox(height: 8),
          _buildTotalRow('Tax (18% GST)', estimate.tax),
          pw.Divider(thickness: 2),
          pw.SizedBox(height: 8),
          _buildTotalRow(
            'TOTAL ESTIMATE',
            estimate.total,
            isBold: true,
            fontSize: 16,
          ),
        ],
      ),
    );
  }

  pw.Widget _buildTotalRow(String label, double amount, {bool isBold = false, double fontSize = 12}) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(
            fontSize: fontSize,
            fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
          ),
        ),
        pw.Text(
          _currencyFormat.format(amount),
          style: pw.TextStyle(
            fontSize: fontSize,
            fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
          ),
        ),
      ],
    );
  }

  pw.Widget _buildExplanation(EstimateModel estimate) {
    if (estimate.explanation == null) return pw.SizedBox();

    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.blue200),
        borderRadius: pw.BorderRadius.circular(8),
        color: PdfColors.blue50,
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Notes & Explanation',
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue900,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            estimate.explanation!,
            style: const pw.TextStyle(
              fontSize: 9,
              lineSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildFooter() {
    return pw.Column(
      children: [
        pw.Divider(),
        pw.SizedBox(height: 8),
        pw.Text(
          'This is a computer-generated estimate and does not require a signature.',
          style: pw.TextStyle(
            fontSize: 8,
            color: PdfColors.grey600,
            fontStyle: pw.FontStyle.italic,
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          'Prices are indicative and subject to change based on final material selection.',
          style: pw.TextStyle(
            fontSize: 8,
            color: PdfColors.grey600,
          ),
        ),
      ],
    );
  }

  /// Print or share PDF
  Future<void> printPdf(EstimateModel estimate) async {
    dynamic designImage;
    if (estimate.designImageUrl != null) {
      try {
        designImage = await networkImage(estimate.designImageUrl!);
      } catch (e) {
        print("Error loading PDF image: $e");
        designImage = null;
      }
    }

    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          _buildHeader(estimate),
          pw.SizedBox(height: 20),
          _buildProjectInfo(estimate),
          pw.SizedBox(height: 20),
          if (designImage != null)
             pw.Container(
               margin: const pw.EdgeInsets.only(bottom: 20),
               child: pw.Column(
                 crossAxisAlignment: pw.CrossAxisAlignment.start,
                 children: [
                   pw.Text('AI Design Concept', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14, color: PdfColors.blue900)),
                   pw.SizedBox(height: 8),
                   pw.ClipRRect(
                     horizontalRadius: 8,
                     verticalRadius: 8,
                     child: pw.Container(
                       height: 250,
                       width: double.infinity,
                       color: PdfColors.grey100,
                       child: pw.Image(designImage, fit: pw.BoxFit.cover),
                     ),
                   ),
                 ],
               ),
             ),
          _buildItemsTable(estimate),
          pw.SizedBox(height: 20),
          _buildTotals(estimate),
          pw.SizedBox(height: 20),
          _buildExplanation(estimate),
          pw.SizedBox(height: 30),
          _buildFooter(),
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
    );
  }
}
