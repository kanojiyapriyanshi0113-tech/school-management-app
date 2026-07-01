import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import '../../providers/student_provider.dart';
import '../../providers/fee_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/language_provider.dart';

class StudentDetailScreen extends StatefulWidget {
  final int studentId;
  const StudentDetailScreen({super.key, required this.studentId});
  @override
  State<StudentDetailScreen> createState() => _StudentDetailScreenState();
}

class _StudentDetailScreenState extends State<StudentDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<StudentProvider>().fetchStudents();
      context.read<StudentProvider>().selectStudent(widget.studentId);
      context.read<FeeProvider>().fetchFees();
    });
  }

  @override
  void dispose() { _tabController.dispose(); super.dispose(); }

  String _initial(String name) =>
    name.isNotEmpty ? name[0].toUpperCase() : '?';

  // PDF download
  Future<void> _downloadStudentPdf(BuildContext context, StudentModel s) async {
    try {
      final pdf = pw.Document();
      pdf.addPage(pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context ctx) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Container(
              width: double.infinity,
              color: PdfColor.fromHex('#1565C0'),
              padding: const pw.EdgeInsets.all(16),
              child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                pw.Text('SCHOOL MANAGEMENT SYSTEM',
                  style: pw.TextStyle(color: PdfColors.white,
                    fontWeight: pw.FontWeight.bold, fontSize: 14)),
                pw.SizedBox(height: 4),
                pw.Text('Student Profile',
                  style: const pw.TextStyle(color: PdfColors.white, fontSize: 11)),
              ])),
            pw.SizedBox(height: 16),
            pw.Text(s.name,
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 18)),
            pw.Text(s.className + '-' + s.section + ' | Roll: ' + s.rollNo,
              style: const pw.TextStyle(color: PdfColors.grey, fontSize: 12)),
            pw.SizedBox(height: 12),
            pw.Divider(),
            pw.Text('Personal Details',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 13)),
            pw.SizedBox(height: 8),
            _pdfRow('Admission No', s.admissionNo),
            _pdfRow('Date of Birth', s.dob),
            _pdfRow('Gender', s.gender),
            _pdfRow('Blood Group', s.bloodGroup),
            _pdfRow('Phone', s.phone),
            _pdfRow('Email', s.email),
            _pdfRow('Address', s.address),
            pw.Divider(),
            pw.Text('Parent / Guardian',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 13)),
            pw.SizedBox(height: 8),
            _pdfRow('Father Name', s.fatherName),
            _pdfRow('Mother Name', s.motherName),
            _pdfRow('Parent Phone', s.parentPhone),
            _pdfRow('Emergency Contact', s.emergencyContact),
            pw.Divider(),
            pw.Text('Academic Details',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 13)),
            pw.SizedBox(height: 8),
            _pdfRow('Class', s.className + '-' + s.section),
            _pdfRow('Roll Number', s.rollNo),
            _pdfRow('Admission Date', s.admissionDate),
            _pdfRow('Status', s.status.toUpperCase()),
          ]),
      ));

      final bytes = Uint8List.fromList(await pdf.save());
      final dir = await getTemporaryDirectory();
      final fname = 'Student_${s.name.replaceAll(' ', '_')}.pdf';
      final file = File('${dir.path}/$fname');
      await file.writeAsBytes(bytes);

      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'application/pdf')],
        subject: 'Student Profile - ${s.name}',
        text: 'Student profile document attached.',
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Download failed: $e'), backgroundColor: Colors.red));
      }
    }
  }

  pw.Widget _pdfRow(String label, String value) => pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 5),
    child: pw.Row(children: [
      pw.SizedBox(width: 140,
        child: pw.Text(label, style: const pw.TextStyle(color: PdfColors.grey, fontSize: 10))),
      pw.Expanded(child: pw.Text(value.isNotEmpty ? value : '-',
        style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10))),
    ]));

  @override
  Widget build(BuildContext context) {
    final student = context.watch<StudentProvider>().selectedStudent;
    final feeProvider = context.watch<FeeProvider>();

    if (student == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Filter fees for this student
    final studentFees = feeProvider.fees
      .where((f) => f.studentId == student.id).toList();

    final totalFee = studentFees.fold(0.0, (s, f) => s + f.amount);
    final paidFee = studentFees
      .where((f) => f.status == 'paid').fold(0.0, (s, f) => s + f.amount);
    final pendingFee = totalFee - paidFee;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.watch<LanguageProvider>().t('student_profile')),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => context.go('/students')),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: 'Download Profile',
            onPressed: () => _downloadStudentPdf(context, student)),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => context.go('/students/${student.id}/edit')),
        ],
      ),
      body: Column(children: [
        // Header card
        Container(
          color: AppTheme.primaryColor,
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Row(children: [
            CircleAvatar(
              radius: 36,
              backgroundColor: Colors.white.withOpacity(0.2),
              child: Text(_initial(student.name),
                style: const TextStyle(fontSize: 28, color: Colors.white,
                  fontWeight: FontWeight.bold))),
            const SizedBox(width: 16),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(student.name.isNotEmpty ? student.name : 'Unknown Student',
                style: const TextStyle(color: Colors.white,
                  fontSize: 16, fontWeight: FontWeight.bold)),
              Text('${student.className}-${student.section} • Roll: ${student.rollNo}',
                style: const TextStyle(color: Colors.white70, fontSize: 12)),
              Text('Adm: ${student.admissionNo}',
                style: const TextStyle(color: Colors.white70, fontSize: 12)),
              const SizedBox(height: 6),
              Row(children: [
                _badge(student.status == 'active' ? 'ACTIVE' : 'INACTIVE',
                  student.status == 'active' ? Colors.green : Colors.red),
                if (student.bloodGroup.isNotEmpty) ...[
                  const SizedBox(width: 6),
                  _badge(student.bloodGroup, Colors.red.shade700),
                ],
                if (student.gender.isNotEmpty) ...[
                  const SizedBox(width: 6),
                  _badge(student.gender, Colors.blue),
                ],
              ]),
            ])),
          ]),
        ),

        TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppTheme.primaryColor,
          tabs: [
            Tab(text: context.watch<LanguageProvider>().t('personal')), Tab(text: context.watch<LanguageProvider>().t('academic')), Tab(text: context.watch<LanguageProvider>().t('attendance')),
            Tab(text: 'Fees'), Tab(text: context.watch<LanguageProvider>().t('health')), Tab(text: context.watch<LanguageProvider>().t('transport')),
          ],
        ),

        Expanded(child: TabBarView(controller: _tabController, children: [
          _personalTab(student),
          _academicTab(),
          _attendanceTab(),
          _feesTab(context, studentFees, totalFee, paidFee, pendingFee),
          _healthTab(student),
          _transportTab(student),
        ])),
      ]),
    );
  }

  Widget _personalTab(StudentModel s) => SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Column(children: [
      _infoCard('Personal Details', [
        _row('Date of Birth', s.dob.isNotEmpty ? s.dob : '-'),
        _row('Gender', s.gender.isNotEmpty ? s.gender : '-'),
        _row('Blood Group', s.bloodGroup.isNotEmpty ? s.bloodGroup : '-'),
        _row('Phone', s.phone.isNotEmpty ? s.phone : '-'),
        _row('Email', s.email.isNotEmpty ? s.email : '-'),
        _row('Address', s.address.isNotEmpty ? s.address : '-'),
        _row('Admission Date', s.admissionDate.isNotEmpty ? s.admissionDate : '-'),
      ]),
      const SizedBox(height: 12),
      _infoCard('Parent / Guardian', [
        _row('Father Name', s.fatherName.isNotEmpty ? s.fatherName : '-'),
        _row('Mother Name', s.motherName.isNotEmpty ? s.motherName : '-'),
        _row('Parent Phone', s.parentPhone.isNotEmpty ? s.parentPhone : '-'),
        _row('Parent Email', s.parentEmail.isNotEmpty ? s.parentEmail : '-'),
        _row('Occupation', s.parentOccupation.isNotEmpty ? s.parentOccupation : '-'),
        _row('Emergency Contact', s.emergencyContact.isNotEmpty ? s.emergencyContact : '-'),
      ]),
    ]));

  Widget _academicTab() => SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Column(children: [
      Card(child: Padding(padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Mid-Term Results 2025',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 4),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Total: 418/500',
              style: TextStyle(color: Colors.grey, fontSize: 12)),
            Text('83.6% - Grade A',
              style: TextStyle(color: Colors.green.shade700,
                fontWeight: FontWeight.bold, fontSize: 12)),
          ]),
          const Divider(),
          ...[['Mathematics','92','100','A+'], ['Science','85','100','A'],
              ['English','78','100','B+'], ['Hindi','88','100','A'],
              ['Social Science','75','100','B+']].map((r) =>
            Padding(padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(children: [
                Expanded(child: Text(r[0],
                  style: const TextStyle(fontSize: 13))),
                Text('${r[1]}/${r[2]}',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                const SizedBox(width: 12),
                Container(width: 36,
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6)),
                  child: Text(r[3], textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 11,
                      fontWeight: FontWeight.bold, color: Colors.green))),
              ]))),
        ]))),
    ]));

  Widget _attendanceTab() => SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Column(children: [
      Card(child: Padding(padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('This Month Summary',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 12),
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            _attStat('Present', '20', Colors.green),
            _attStat('Absent', '2', Colors.red),
            _attStat('Late', '1', Colors.orange),
            _attStat('Total', '23', Colors.blue),
          ]),
          const SizedBox(height: 12),
          ClipRRect(borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(value: 20/23,
              backgroundColor: Colors.red.withOpacity(0.2),
              color: Colors.green, minHeight: 10)),
          const SizedBox(height: 4),
          const Text('Attendance: 86.9%',
            style: TextStyle(fontSize: 12, color: Colors.grey)),
        ]))),
      const SizedBox(height: 12),
      Card(child: Padding(padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Recent Attendance',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 10),
          ...[['16 Jun','present'],['15 Jun','present'],['14 Jun','absent'],
              ['13 Jun','present'],['12 Jun','late']].map((a) {
            final color = a[1]=='present' ? Colors.green
              : a[1]=='absent' ? Colors.red : Colors.orange;
            return ListTile(dense: true,
              leading: Icon(
                a[1]=='present' ? Icons.check_circle
                : a[1]=='absent' ? Icons.cancel : Icons.access_time,
                color: color),
              title: Text(a[0], style: const TextStyle(fontSize: 13)),
              trailing: Text(a[1].toUpperCase(),
                style: TextStyle(color: color,
                  fontWeight: FontWeight.bold, fontSize: 11)));
          }),
        ]))),
    ]));

  Widget _feesTab(BuildContext context, List studentFees,
      double totalFee, double paidFee, double pendingFee) =>
    SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        // Summary
        Card(child: Padding(padding: const EdgeInsets.all(16),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            _feeSum('Total', 'Rs ${totalFee.toStringAsFixed(0)}', Colors.blue),
            _feeSum('Paid', 'Rs ${paidFee.toStringAsFixed(0)}', Colors.green),
            _feeSum('Pending', 'Rs ${pendingFee.toStringAsFixed(0)}',
              pendingFee > 0 ? Colors.red : Colors.grey),
          ]))),
        const SizedBox(height: 12),

        if (studentFees.isEmpty)
          const Card(child: Padding(
            padding: EdgeInsets.all(20),
            child: Center(child: Text('No fee records found',
              style: TextStyle(color: Colors.grey)))))
        else
          ...studentFees.map((f) {
            final color = f.status == 'paid' ? Colors.green
              : f.status == 'overdue' ? Colors.red : Colors.orange;
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                title: Text(f.feeType,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                subtitle: Text('Due: ${f.dueDate.isNotEmpty ? f.dueDate : "N/A"}',
                  style: const TextStyle(fontSize: 11)),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Rs ${f.amount.toStringAsFixed(0)}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8)),
                      child: Text(f.status.toUpperCase(),
                        style: TextStyle(fontSize: 9,
                          fontWeight: FontWeight.bold, color: color))),
                  ]),
                onTap: () => context.go('/fees/receipt/${f.id}'),
              ));
          }),

        if (studentFees.isNotEmpty) ...[
          const SizedBox(height: 8),
          SizedBox(width: double.infinity, child: OutlinedButton.icon(
            onPressed: () => context.go('/fees'),
            icon: const Icon(Icons.receipt_long),
            label: const Text('View All Receipts'),
          )),
        ],
      ]));

  Widget _healthTab(StudentModel s) => SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Column(children: [
      _infoCard('Health Information', [
        _row('Blood Group', s.bloodGroup.isNotEmpty ? s.bloodGroup : '-'),
        _row('Medical Conditions',
          s.medicalInfo.isNotEmpty ? s.medicalInfo : 'None'),
        _row('Allergies', 'None'),
        _row('Height', '-'),
        _row('Weight', '-'),
      ]),
      const SizedBox(height: 12),
      _infoCard('Vaccination', [
        _row('Hepatitis B', 'Completed'),
        _row('MMR', 'Completed'),
        _row('Polio', 'Completed'),
        _row('Covid-19', 'Completed'),
      ]),
    ]));

  Widget _transportTab(StudentModel s) => SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: _infoCard('Transport Details', [
      _row('Transport', s.transport.isNotEmpty ? s.transport : '-'),
      _row('Bus Route', s.busRoute.isNotEmpty ? s.busRoute : 'N/A'),
    ]));

  Widget _infoCard(String title, List<Widget> rows) => Card(
    child: Padding(padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const Divider(), ...rows,
      ])));

  Widget _row(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(children: [
      SizedBox(width: 140, child: Text(label,
        style: const TextStyle(color: Colors.grey, fontSize: 12))),
      Expanded(child: Text(value,
        style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12))),
    ]));

  Widget _badge(String text, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10)),
    child: Text(text, style: const TextStyle(
      color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)));

  Widget _attStat(String label, String val, Color color) => Column(children: [
    Text(val, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
    Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey))]);

  Widget _feeSum(String label, String val, Color color) => Column(children: [
    Text(val, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: color)),
    Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey))]);
}
