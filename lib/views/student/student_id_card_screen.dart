import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../providers/auth_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/language_provider.dart';

class StudentIdCardScreen extends StatelessWidget {
  const StudentIdCardScreen({super.key});

  Future<void> _downloadIdCard(BuildContext context, String name, String email) async {
    try {
      final pdf = pw.Document();
      pdf.addPage(pw.Page(
        pageFormat: PdfPageFormat.a6.landscape,
        build: (pw.Context ctx) => pw.Container(
          decoration: pw.BoxDecoration(
            gradient: const pw.LinearGradient(
              colors: [PdfColor.fromInt(0xFF1565C0), PdfColor.fromInt(0xFF0D47A1)],
              begin: pw.Alignment.topLeft,
              end: pw.Alignment.bottomRight,
            ),
            borderRadius: pw.BorderRadius.circular(12),
          ),
          padding: const pw.EdgeInsets.all(16),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(children: [
                pw.Expanded(child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                  pw.Text('SCHOOL MANAGEMENT SYSTEM',
                    style: pw.TextStyle(color: PdfColors.white,
                      fontWeight: pw.FontWeight.bold, fontSize: 10)),
                  pw.Text('Affiliated to CBSE • New Delhi',
                    style: const pw.TextStyle(color: PdfColors.white, fontSize: 8)),
                ])),
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.white,
                    borderRadius: pw.BorderRadius.circular(4)),
                  child: pw.Text('2025-26',
                    style: pw.TextStyle(color: PdfColor.fromInt(0xFF1565C0),
                      fontSize: 8, fontWeight: pw.FontWeight.bold))),
              ]),
              pw.Divider(color: PdfColors.white, height: 16),
              pw.Row(children: [
                pw.Container(
                  width: 60, height: 70,
                  decoration: pw.BoxDecoration(
                    color: PdfColor.fromInt(0x4DFFFFFF),
                    borderRadius: pw.BorderRadius.circular(6),
                    border: pw.Border.all(color: PdfColors.white, width: 1.5)),
                  child: pw.Center(child: pw.Text(
                    name.isNotEmpty ? name[0].toUpperCase() : 'R',
                    style: pw.TextStyle(color: PdfColors.white,
                      fontSize: 28, fontWeight: pw.FontWeight.bold))),
                ),
                pw.SizedBox(width: 12),
                pw.Expanded(child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                  pw.Text(name,
                    style: pw.TextStyle(color: PdfColors.white,
                      fontWeight: pw.FontWeight.bold, fontSize: 12)),
                  pw.SizedBox(height: 4),
                  _pdfRow('Class', 'Class 10-A'),
                  _pdfRow('Roll No', 'R001'),
                  _pdfRow('Adm No', 'ADM001'),
                  _pdfRow('DOB', '15 Mar 2009'),
                  _pdfRow('Blood', 'B+'),
                ])),
              ]),
              pw.Divider(color: PdfColors.white, height: 16),
              pw.Row(children: [
                pw.Expanded(child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                  _pdfRow('Father', 'Suresh Kumar'),
                  _pdfRow('Phone', '9876543210'),
                  _pdfRow('Address', '123 MG Road, Delhi'),
                ])),
                pw.Container(
                  width: 55, height: 55,
                  decoration: pw.BoxDecoration(
                    color: PdfColors.white,
                    borderRadius: pw.BorderRadius.circular(4)),
                  child: pw.Center(child: pw.Text('QR',
                    style: pw.TextStyle(color: PdfColor.fromInt(0xFF1565C0),
                      fontWeight: pw.FontWeight.bold))),
                ),
              ]),
              pw.SizedBox(height: 8),
              pw.Center(child: pw.Text('Valid for Academic Year 2025-26 only',
                style: const pw.TextStyle(color: PdfColors.white, fontSize: 8))),
            ],
          ),
        ),
      ));

      await Printing.sharePdf(
        bytes: await pdf.save(),
        filename: 'ID_Card_$name.pdf',
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
      }
    }
  }

  pw.Widget _pdfRow(String label, String value) => pw.Padding(
    padding: const pw.EdgeInsets.symmetric(vertical: 1),
    child: pw.Row(children: [
      pw.Text('$label: ', style: pw.TextStyle(color: PdfColor.fromInt(0xB3FFFFFF), fontSize: 8)),
      pw.Text(value, style: pw.TextStyle(color: PdfColors.white,
        fontSize: 8, fontWeight: pw.FontWeight.bold)),
    ]),
  );

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final name = user?.name ?? 'Rahul Kumar';
    final email = user?.email ?? 'student@school.com';

    return Scaffold(
      appBar: AppBar(
        title: Text(context.watch<LanguageProvider>().t('profile')),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => context.go('/dashboard/student'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: 'Download PDF',
            onPressed: () => _downloadIdCard(context, name, email),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          // ID Card UI
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1565C0), Color(0xFF0D47A1)],
                begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(
                color: Colors.blue.withOpacity(0.3),
                blurRadius: 20, offset: const Offset(0, 8))],
            ),
            padding: const EdgeInsets.all(20),
            child: Column(children: [
              Row(children: [
                const Icon(Icons.school, color: Colors.white, size: 24),
                const SizedBox(width: 8),
                const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('SCHOOL MANAGEMENT SYSTEM',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                  Text('Affiliated to CBSE • New Delhi',
                    style: TextStyle(color: Colors.white70, fontSize: 10)),
                ])),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8)),
                  child: const Text('2025-26',
                    style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold))),
              ]),
              const Divider(color: Colors.white24, height: 24),
              Row(children: [
                Container(
                  width: 80, height: 90,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white30, width: 2)),
                  child: Center(child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : 'R',
                    style: const TextStyle(color: Colors.white,
                      fontSize: 36, fontWeight: FontWeight.bold))),
                ),
                const SizedBox(width: 16),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(name, style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  _idRow('Class', 'Class 10-A'),
                  _idRow('Roll No', 'R001'),
                  _idRow('Adm No', 'ADM001'),
                  _idRow('DOB', '15 Mar 2009'),
                  _idRow('Blood', 'B+'),
                ])),
              ]),
              const Divider(color: Colors.white24, height: 24),
              Row(children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _idRow('Father', 'Suresh Kumar'),
                  _idRow('Phone', '9876543210'),
                  _idRow('Address', '123 MG Road, Delhi'),
                ])),
                Container(
                  width: 70, height: 70,
                  decoration: BoxDecoration(
                    color: Colors.white, borderRadius: BorderRadius.circular(8)),
                  child: const Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(Icons.qr_code, size: 40, color: Color(0xFF1565C0)),
                    Text('Scan', style: TextStyle(fontSize: 9, color: Color(0xFF1565C0))),
                  ]),
                ),
              ]),
              const Divider(color: Colors.white24, height: 20),
              const Text('Valid for Academic Year 2025-26 only',
                style: TextStyle(color: Colors.white70, fontSize: 10)),
            ]),
          ),
          const SizedBox(height: 16),

          // Download Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _downloadIdCard(context, name, email),
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text('Download ID Card as PDF'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            ),
          ),
          const SizedBox(height: 20),

          // Student Details
          Card(child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Student Details',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const Divider(),
              _row('Full Name', name),
              _row('Admission No', 'ADM001'),
              _row('Class & Section', 'Class 10-A'),
              _row('Roll Number', 'R001'),
              _row('Date of Birth', '15 Mar 2009'),
              _row('Gender', 'Male'),
              _row('Blood Group', 'B+'),
              _row('Email', email),
            ]),
          )),
          const SizedBox(height: 12),
          Card(child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Emergency Contact',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const Divider(),
              _row('Father Name', 'Suresh Kumar'),
              _row('Phone', '9876543210'),
              _row('Alt Phone', '9876543211'),
              _row('Blood Group', 'B+'),
            ]),
          )),
        ]),
      ),
    );
  }

  Widget _idRow(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 1),
    child: Row(children: [
      Text('$label: ', style: const TextStyle(color: Colors.white60, fontSize: 10)),
      Expanded(child: Text(value,
        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w500),
        overflow: TextOverflow.ellipsis)),
    ]),
  );

  Widget _row(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(children: [
      SizedBox(width: 130, child: Text(label,
        style: const TextStyle(color: Colors.grey, fontSize: 12))),
      Expanded(child: Text(value,
        style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12))),
    ]),
  );
}
