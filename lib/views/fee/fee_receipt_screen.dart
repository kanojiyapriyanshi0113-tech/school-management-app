import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../core/theme/app_theme.dart';
import '../../providers/fee_provider.dart';
import '../../providers/language_provider.dart';

class FeeReceiptScreen extends StatefulWidget {
  final int feeId;
  const FeeReceiptScreen({super.key, required this.feeId});
  @override
  State<FeeReceiptScreen> createState() => _FeeReceiptScreenState();
}

class _FeeReceiptScreenState extends State<FeeReceiptScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final p = context.read<FeeProvider>();
      if (p.fees.isEmpty) p.fetchFees();
    });
  }

  FeeModel? _findFee(FeeProvider p) {
    try {
      return p.fees.firstWhere((f) => f.id == widget.feeId);
    } catch (_) {
      return null;
    }
  }

  String _today() {
    final d = DateTime.now();
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${d.day} ${months[d.month-1]} ${d.year}';
  }

  String _amountInWords(double amount) {
    // Simple amount-in-words for typical fee ranges
    final intAmt = amount.toInt();
    if (intAmt == 0) return 'Zero Rupees Only';
    final ones = ['', 'One', 'Two', 'Three', 'Four', 'Five', 'Six', 'Seven', 'Eight', 'Nine'];
    final tens = ['', '', 'Twenty', 'Thirty', 'Forty', 'Fifty', 'Sixty', 'Seventy', 'Eighty', 'Ninety'];
    final teens = ['Ten', 'Eleven', 'Twelve', 'Thirteen', 'Fourteen', 'Fifteen',
      'Sixteen', 'Seventeen', 'Eighteen', 'Nineteen'];

    String twoDigits(int n) {
      if (n == 0) return '';
      if (n < 10) return ones[n];
      if (n < 20) return teens[n - 10];
      return '${tens[n ~/ 10]} ${ones[n % 10]}'.trim();
    }

    String threeDigits(int n) {
      if (n >= 100) {
        final h = n ~/ 100;
        final rest = n % 100;
        return '${ones[h]} Hundred${rest > 0 ? ' ${twoDigits(rest)}' : ''}';
      }
      return twoDigits(n);
    }

    if (intAmt < 1000) return '${threeDigits(intAmt)} Rupees Only'.trim();
    if (intAmt < 100000) {
      final thousands = intAmt ~/ 1000;
      final rest = intAmt % 1000;
      return '${threeDigits(thousands)} Thousand${rest > 0 ? ' ${threeDigits(rest)}' : ''} Rupees Only'.trim();
    }
    final lakhs = intAmt ~/ 100000;
    final rest = intAmt % 100000;
    final thousands = rest ~/ 1000;
    final remainder = rest % 1000;
    return '${threeDigits(lakhs)} Lakh'
      '${thousands > 0 ? ' ${threeDigits(thousands)} Thousand' : ''}'
      '${remainder > 0 ? ' ${threeDigits(remainder)}' : ''} Rupees Only'.trim();
  }

  // --- PDF Generator ---
  Future<Uint8List> _generatePdf(FeeModel fee) async {
    final pdf = pw.Document();
    final receiptNo = 'REC${fee.id.toString().padLeft(4, '0')}';

    pdf.addPage(pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            pw.Container(
              color: PdfColor.fromHex('#1565C0'),
              padding: const pw.EdgeInsets.all(20),
              child: pw.Column(
                children: [
                  pw.Text('SCHOOL MANAGEMENT SYSTEM',
                      style: pw.TextStyle(color: PdfColors.white,
                          fontWeight: pw.FontWeight.bold, fontSize: 16)),
                  pw.SizedBox(height: 4),
                  pw.Text('Fee Receipt',
                      style: const pw.TextStyle(color: PdfColors.white, fontSize: 12)),
                  pw.SizedBox(height: 8),
                  pw.Text('Receipt #$receiptNo',
                      style: pw.TextStyle(color: PdfColors.white,
                          fontWeight: pw.FontWeight.bold, fontSize: 13)),
                ],
              ),
            ),
            pw.Container(
              color: fee.status == 'paid'
                ? PdfColor.fromHex('#E8F5E9') : PdfColor.fromHex('#FFF3E0'),
              padding: const pw.EdgeInsets.symmetric(vertical: 10),
              child: pw.Center(
                child: pw.Text(
                  fee.status == 'paid' ? '✓ PAYMENT CONFIRMED' : '⚠ PAYMENT PENDING',
                  style: pw.TextStyle(
                      color: fee.status == 'paid'
                        ? PdfColor.fromHex('#2E7D32') : PdfColor.fromHex('#E65100'),
                      fontWeight: pw.FontWeight.bold, fontSize: 13)),
              ),
            ),
            pw.SizedBox(height: 16),
            pw.Padding(
              padding: const pw.EdgeInsets.symmetric(horizontal: 20),
              child: pw.Column(
                children: [
                  _pdfRow('Receipt No', receiptNo),
                  _pdfRow('Date', _today()),
                  _pdfRow('Student Name', fee.studentName),
                  pw.Divider(),
                  _pdfRow('Fee Type', fee.feeType),
                  _pdfRow('Due Date', fee.dueDate.isNotEmpty ? fee.dueDate : 'N/A'),
                  pw.Divider(),
                  _pdfRow('Fee Amount', 'Rs. ${fee.amount.toStringAsFixed(0)}'),
                  pw.Divider(),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(fee.status == 'paid' ? 'Total Paid' : 'Amount Due',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)),
                      pw.Text('Rs. ${fee.amount.toStringAsFixed(0)}',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold,
                              fontSize: 15, color: PdfColor.fromHex('#1565C0'))),
                    ],
                  ),
                  pw.SizedBox(height: 16),
                  pw.Container(
                    width: double.infinity,
                    padding: const pw.EdgeInsets.all(10),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.grey300),
                      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6))),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('Amount in Words:',
                            style: const pw.TextStyle(color: PdfColors.grey, fontSize: 10)),
                        pw.SizedBox(height: 4),
                        pw.Text(_amountInWords(fee.amount),
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11)),
                      ],
                    ),
                  ),
                  pw.SizedBox(height: 30),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
                    children: [
                      pw.Column(children: [
                        pw.Container(width: 100, height: 1, color: PdfColors.grey),
                        pw.SizedBox(height: 4),
                        pw.Text('Parent Signature',
                            style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey)),
                      ]),
                      pw.Column(children: [
                        pw.Container(width: 100, height: 1, color: PdfColors.grey),
                        pw.SizedBox(height: 4),
                        pw.Text('Accountant',
                            style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey)),
                      ]),
                    ],
                  ),
                  pw.SizedBox(height: 20),
                  pw.Center(
                    child: pw.Text(
                      'This is a computer generated receipt. No signature required.',
                      style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey)),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    ));
    return Uint8List.fromList(await pdf.save());
  }

  pw.Widget _pdfRow(String label, String value) => pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 6),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(label, style: const pw.TextStyle(color: PdfColors.grey, fontSize: 11)),
            pw.Text(value, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11)),
          ],
        ),
      );

  Future<void> _downloadPdf(BuildContext context, FeeModel fee) async {
    try {
      final bytes = await _generatePdf(fee);
      final receiptNo = 'REC${fee.id.toString().padLeft(4, '0')}';
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/FeeReceipt_$receiptNo.pdf');
      await file.writeAsBytes(bytes, flush: true);

      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'application/pdf')],
        subject: 'Fee Receipt - $receiptNo',
        text: 'Tap Save / Download to keep this PDF.',
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Download failed: $e'), backgroundColor: Colors.red));
      }
    }
  }

  Future<void> _sharePdf(BuildContext context, FeeModel fee) async {
    try {
      final bytes = await _generatePdf(fee);
      final receiptNo = 'REC${fee.id.toString().padLeft(4, '0')}';
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/FeeReceipt_$receiptNo.pdf');
      await file.writeAsBytes(bytes);

      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'application/pdf')],
        subject: 'Fee Receipt - $receiptNo',
        text: 'Please find the fee receipt attached.',
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Share failed: $e'), backgroundColor: Colors.red));
      }
    }
  }

  Future<void> _printPdf(BuildContext context, FeeModel fee) async {
    try {
      final bytes = await _generatePdf(fee);
      await Printing.layoutPdf(onLayout: (_) async => bytes);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Print failed: $e'), backgroundColor: Colors.red));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<FeeProvider>();
    final fee = _findFee(p);

    if (p.isLoading && fee == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (fee == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(context.watch<LanguageProvider>().t('fee_receipt')),
          leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new),
            onPressed: () => context.go('/fees'))),
        body: const Center(child: Text('Receipt not found')),
      );
    }

    final receiptNo = 'REC${fee.id.toString().padLeft(4, '0')}';

    return Scaffold(
      appBar: AppBar(
        title: Text(context.watch<LanguageProvider>().t('fee_receipt')),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => context.go('/fees')),
        actions: [
          IconButton(icon: const Icon(Icons.download), tooltip: 'Download PDF',
            onPressed: () => _downloadPdf(context, fee)),
          IconButton(icon: const Icon(Icons.share), tooltip: 'Share',
            onPressed: () => _sharePdf(context, fee)),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 10)]),
            child: Column(children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16), topRight: Radius.circular(16))),
                child: Column(children: [
                  const Icon(Icons.school, color: Colors.white, size: 36),
                  const SizedBox(height: 8),
                  const Text('SCHOOL MANAGEMENT SYSTEM',
                      style: TextStyle(color: Colors.white,
                          fontWeight: FontWeight.bold, fontSize: 14)),
                  const Text('Fee Receipt',
                      style: TextStyle(color: Colors.white70, fontSize: 12)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8)),
                    child: Text('Receipt #$receiptNo',
                        style: const TextStyle(color: Colors.white,
                            fontWeight: FontWeight.bold, fontSize: 12))),
                ]),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10),
                color: fee.status == 'paid'
                  ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(fee.status == 'paid' ? Icons.check_circle : Icons.access_time,
                      color: fee.status == 'paid' ? Colors.green : Colors.orange, size: 18),
                    const SizedBox(width: 8),
                    Text(fee.status == 'paid' ? 'PAYMENT CONFIRMED' : 'PAYMENT PENDING',
                        style: TextStyle(
                          color: fee.status == 'paid' ? Colors.green : Colors.orange,
                          fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(children: [
                  _row('Receipt No', receiptNo),
                  _row('Date', _today()),
                  _row('Student Name', fee.studentName),
                  const Divider(height: 24),
                  _row('Fee Type', fee.feeType),
                  _row('Due Date', fee.dueDate.isNotEmpty ? fee.dueDate : 'N/A'),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(fee.status == 'paid' ? 'Total Paid' : 'Amount Due',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text('Rs. ${fee.amount.toStringAsFixed(0)}',
                          style: TextStyle(fontWeight: FontWeight.bold,
                              fontSize: 18, color: AppTheme.primaryColor)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade200)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Amount in Words:',
                            style: TextStyle(fontSize: 11, color: Colors.grey)),
                        const SizedBox(height: 4),
                        Text(_amountInWords(fee.amount),
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                      ],
                    ),
                  ),
                ]),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(16), bottomRight: Radius.circular(16))),
                child: Column(children: [
                  const Text('This is a computer generated receipt.',
                      style: TextStyle(fontSize: 11, color: Colors.grey)),
                  const Text('No signature required.',
                      style: TextStyle(fontSize: 11, color: Colors.grey)),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(children: [
                        Container(width: 80, height: 1, color: Colors.grey),
                        const SizedBox(height: 4),
                        const Text('Parent Signature',
                            style: TextStyle(fontSize: 10, color: Colors.grey)),
                      ]),
                      Column(children: [
                        Container(width: 80, height: 1, color: Colors.grey),
                        const SizedBox(height: 4),
                        const Text('Accountant',
                            style: TextStyle(fontSize: 10, color: Colors.grey)),
                      ]),
                    ],
                  ),
                ]),
              ),
            ]),
          ),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: OutlinedButton.icon(
              onPressed: () => _printPdf(context, fee),
              icon: const Icon(Icons.print), label: const Text('Print'))),
            const SizedBox(width: 10),
            Expanded(child: ElevatedButton.icon(
              onPressed: () => _sharePdf(context, fee),
              icon: const Icon(Icons.share), label: const Text('Share'))),
          ]),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _downloadPdf(context, fee),
              icon: const Icon(Icons.download),
              label: Text(context.watch<LanguageProvider>().t('download_pdf')),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.green,
                side: const BorderSide(color: Colors.green)),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _row(String label, String value) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
            Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          ],
        ),
      );
}
