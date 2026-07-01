import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/student_provider.dart';
import '../../providers/fee_provider.dart';

class ReportDetailScreen extends StatefulWidget {
  final String reportType;
  const ReportDetailScreen({super.key, required this.reportType});
  @override
  State<ReportDetailScreen> createState() => _ReportDetailScreenState();
}

class _ReportDetailScreenState extends State<ReportDetailScreen> {
  // For Student Progress Report
  String? _selectedClass;
  StudentModel? _selectedStudent;

  // For Attendance Report
  String? _attSelectedClass;
  String? _attSelectedStudent;

  // For Fee Report
  String? _feeSelectedClass;
  String? _feeSelectedStudent;

  String get reportType => widget.reportType;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StudentProvider>().fetchStudents();
      context.read<FeeProvider>().fetchFees();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(reportType),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => context.go('/reports'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: 'Download PDF',
            onPressed: () => _downloadPdf(context)),
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: 'Share',
            onPressed: () => _shareReport(context)),
        ],
      ),
      body: _buildReport(context),
    );
  }

  Future<void> _downloadPdf(BuildContext context) async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(children: [
            SizedBox(width:18,height:18,
              child: CircularProgressIndicator(color:Colors.white,strokeWidth:2)),
            SizedBox(width:10), Text('Generating PDF...')]),
          backgroundColor: Colors.blue, duration: Duration(seconds: 2)));

      final pdf = pw.Document();
      pdf.addPage(pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context ctx) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(16),
              decoration: const pw.BoxDecoration(color: PdfColor.fromInt(0xFF1565C0)),
              child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                pw.Text(reportType,
                  style: pw.TextStyle(color: PdfColors.white,
                    fontSize: 20, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 4),
                pw.Text('School Management System • Academic Year 2025-26',
                  style: const pw.TextStyle(color: PdfColors.white, fontSize: 11)),
              ])),
            pw.SizedBox(height: 24),
            pw.Text('Report Details',
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
            pw.Divider(),
            pw.SizedBox(height: 12),
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey300),
              children: [
                _pdfHeaderRow(['Parameter', 'Value', 'Status']),
                _pdfDataRow(['Total Students', '1,248', 'Active']),
                _pdfDataRow(['Pass Rate', '94.2%', 'Good']),
                _pdfDataRow(['Avg Score', '76.4%', 'Average']),
                _pdfDataRow(['Attendance', '87.3%', 'Good']),
                _pdfDataRow(['Fee Collected', 'Rs 4.2L', 'On Track']),
                _pdfDataRow(['Pending Fees', 'Rs 1.1L', 'Action Needed']),
              ]),
            pw.SizedBox(height: 24),
            pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
              pw.Text('Generated on: ' + DateTime.now().day.toString() + '/' + DateTime.now().month.toString() + '/' + DateTime.now().year.toString(),
                style: const pw.TextStyle(color: PdfColors.grey, fontSize: 9)),
              pw.Text('Confidential - School Use Only',
                style: const pw.TextStyle(color: PdfColors.grey, fontSize: 9)),
            ]),
          ]),
      ));

      await Printing.sharePdf(
        bytes: await pdf.save(),
        filename: reportType.replaceAll(' ', '_') + '.pdf',
      );
    } catch (e) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ' + e.toString()), backgroundColor: Colors.red));
    }
  }

  pw.TableRow _pdfHeaderRow(List<String> cells) => pw.TableRow(
    decoration: const pw.BoxDecoration(color: PdfColor.fromInt(0xFFE3F2FD)),
    children: cells.map((h) => pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(h, style: pw.TextStyle(
        fontWeight: pw.FontWeight.bold, fontSize: 10)))).toList());

  pw.TableRow _pdfDataRow(List<String> cells) => pw.TableRow(
    children: cells.map((v) => pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(v, style: const pw.TextStyle(fontSize: 10)))).toList());

  Future<void> _shareReport(BuildContext context) async {
    try {
      final dateStr = DateTime.now().day.toString() + '/' + DateTime.now().month.toString() + '/' + DateTime.now().year.toString();
      final shareText = reportType + '\n\nSchool Management System\nAcademic Year: 2025-26\n\nTotal Students: 1,248 | Pass Rate: 94.2% | Avg Score: 76.4%\nAttendance: 87.3% | Fee Collected: Rs 4.2L\n\nGenerated on ' + dateStr;
      await SharePlus.instance.share(ShareParams(
        text: shareText,
        subject: reportType,
      ));
    } catch (e) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Share failed: ' + e.toString()), backgroundColor: Colors.red));
    }
  }

  Widget _buildReport(BuildContext context) {
    switch (reportType) {
      case 'Student Progress Report': return _studentProgress();
      case 'Attendance Report':       return _attendanceReport();
      case 'Fee Collection Report':   return _feeReport();
      case 'Academic Performance':    return _academicReport();
      case 'Teacher Workload':        return _teacherWorkload();
      case 'Hostel Occupancy':        return _hostelOccupancy();
      case 'Transport Utilization':   return _transportReport();
      case 'Library Usage':           return _libraryReport();
      case 'Admission Report':        return _admissionReport();
      case 'Staff Payroll Report':    return _payrollReport();
      case 'Exam Schedule Report':    return _examReport();
      case 'Leave Management Report': return _leaveReport();
      default:                        return _defaultReport();
    }
  }

  // Student Progress Report - Class + Student selector
  Widget _studentProgress() {
    final sp = context.watch<StudentProvider>();
    final students = sp.students;
    
    // Get unique classes
    final classes = students.map((s) => '${s.className}-${s.section}').toSet().toList()..sort();
    
    // Filter students by selected class
    final classStudents = _selectedClass == null ? students
      : students.where((s) => '${s.className}-${s.section}' == _selectedClass).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _header('Student Progress Report', 'June 2025', Icons.person, Colors.blue),
        const SizedBox(height: 16),
        Row(children: [
          _sumCard('Total Students', students.length.toString(), Colors.blue),
          const SizedBox(width: 10),
          _sumCard('Pass Rate', '94.2%', Colors.green),
          const SizedBox(width: 10),
          _sumCard('Avg Score', '76.4%', Colors.orange),
        ]),
        const SizedBox(height: 16),

        // Class selector
        _sectionTitle('Select Class'),
        const SizedBox(height: 8),
        SizedBox(height: 38,
          child: ListView(scrollDirection: Axis.horizontal, children: [
            GestureDetector(
              onTap: () => setState(() { _selectedClass = null; _selectedStudent = null; }),
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: _selectedClass == null ? AppTheme.primaryColor : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(20)),
                child: Text('All Classes',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                    color: _selectedClass == null ? Colors.white : Colors.grey.shade700)),
              ),
            ),
            ...classes.map((cls) => GestureDetector(
              onTap: () => setState(() { _selectedClass = cls; _selectedStudent = null; }),
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: _selectedClass == cls ? AppTheme.primaryColor : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(20)),
                child: Text(cls,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                    color: _selectedClass == cls ? Colors.white : Colors.grey.shade700)),
              ),
            )),
          ])),
        const SizedBox(height: 16),

        // Student detail view
        if (_selectedStudent != null) ...[
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.primaryColor.withOpacity(0.2))),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                CircleAvatar(
                  backgroundColor: AppTheme.primaryColor.withOpacity(0.15),
                  child: Text(_selectedStudent!.name.isNotEmpty ? _selectedStudent!.name[0] : '?',
                    style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold))),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(_selectedStudent!.name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  Text('${_selectedStudent!.className}-${_selectedStudent!.section} | Roll: ${_selectedStudent!.rollNo}',
                    style: const TextStyle(color: Colors.grey, fontSize: 11)),
                ])),
                IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: () => setState(() => _selectedStudent = null)),
              ]),
              const Divider(height: 16),
              Row(children: [
                Expanded(child: _miniStat('Score', '83.6%', Colors.green)),
                Expanded(child: _miniStat('Grade', 'A', Colors.blue)),
                Expanded(child: _miniStat('Rank', '#3', Colors.orange)),
                Expanded(child: _miniStat('Attendance', '89%', Colors.teal)),
              ]),
              const SizedBox(height: 12),
              const Text('Subject Performance',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 8),
              ...[['Mathematics','92','100'],['Science','85','100'],
                  ['English','78','100'],['Hindi','88','100'],['Social Science','75','100']].map((sub) =>
                Padding(padding: const EdgeInsets.only(bottom: 6),
                  child: Row(children: [
                    SizedBox(width: 120, child: Text(sub[0], style: const TextStyle(fontSize: 12))),
                    Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: int.parse(sub[1]) / int.parse(sub[2]),
                        color: Colors.green, backgroundColor: Colors.green.withOpacity(0.1),
                        minHeight: 8))),
                    const SizedBox(width: 8),
                    Text('${sub[1]}/${sub[2]}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                  ]))),
              const SizedBox(height: 8),
              SizedBox(width: double.infinity, child: ElevatedButton.icon(
                onPressed: () => context.go('/students/${_selectedStudent!.id}'),
                icon: const Icon(Icons.person, size: 16),
                label: const Text('View Full Profile'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white),
              )),
            ]),
          ),
          const SizedBox(height: 16),
        ],

        // Students list
        _sectionTitle(
          _selectedClass != null ? 'Students in $_selectedClass' : 'All Students'),
        const SizedBox(height: 8),
        if (sp.isLoading)
          const Center(child: CircularProgressIndicator())
        else if (classStudents.isEmpty)
          const Center(child: Padding(
            padding: EdgeInsets.all(20),
            child: Text('No students found', style: TextStyle(color: Colors.grey))))
        else
          ...classStudents.map((s) {
            final isSelected = _selectedStudent?.id == s.id;
            return Card(
              margin: const EdgeInsets.only(bottom: 6),
              color: isSelected ? AppTheme.primaryColor.withOpacity(0.05) : null,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(
                  color: isSelected ? AppTheme.primaryColor : Colors.transparent,
                  width: isSelected ? 2 : 0)),
              child: ListTile(
                onTap: () => setState(() =>
                  _selectedStudent = isSelected ? null : s),
                leading: CircleAvatar(
                  backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                  child: Text(s.name.isNotEmpty ? s.name[0].toUpperCase() : '?',
                    style: const TextStyle(color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold))),
                title: Text(s.name,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                subtitle: Text(
                  '${s.className}-${s.section} | Roll: ${s.rollNo} | Adm: ${s.admissionNo}',
                  style: const TextStyle(fontSize: 11)),
                trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8)),
                    child: const Text('83.6% A',
                      style: TextStyle(fontSize: 11, color: Colors.green,
                        fontWeight: FontWeight.bold))),
                  const SizedBox(width: 4),
                  const Icon(Icons.chevron_right, color: Colors.grey, size: 18),
                ]),
              ),
            );
          }),
      ]),
    );
  }


  // Attendance Report - Class + Student selector
  Widget _attendanceReport() {
    final sp = context.watch<StudentProvider>();
    final students = sp.students;
    final classes = students.map((s) => '${s.className}-${s.section}').toSet().toList()..sort();
    final classStudents = _attSelectedClass == null ? students
      : students.where((s) => '${s.className}-${s.section}' == _attSelectedClass).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _header('Attendance Report', 'June 2025', Icons.calendar_today, Colors.green),
        const SizedBox(height: 16),
        Row(children: [
          _sumCard('Avg', '87.3%', Colors.green),
          const SizedBox(width: 10),
          _sumCard('Present', '1,088', Colors.blue),
          const SizedBox(width: 10),
          _sumCard('Absent', '160', Colors.red),
        ]),
        const SizedBox(height: 16),

        // Class selector
        _sectionTitle('Select Class'),
        const SizedBox(height: 8),
        SizedBox(height: 38,
          child: ListView(scrollDirection: Axis.horizontal, children: [
            GestureDetector(
              onTap: () => setState(() { _attSelectedClass = null; _attSelectedStudent = null; }),
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: _attSelectedClass == null ? Colors.green : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(20)),
                child: Text('All Classes',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                    color: _attSelectedClass == null ? Colors.white : Colors.grey.shade700)),
              ),
            ),
            ...classes.map((cls) => GestureDetector(
              onTap: () => setState(() { _attSelectedClass = cls; _attSelectedStudent = null; }),
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: _attSelectedClass == cls ? Colors.green : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(20)),
                child: Text(cls,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                    color: _attSelectedClass == cls ? Colors.white : Colors.grey.shade700)),
              ),
            )),
          ])),
        const SizedBox(height: 16),

        // Class summary card
        _sectionTitle('Class-wise Summary'),
        Card(child: Padding(padding: const EdgeInsets.all(12), child: Column(
          children: [
            ...([
              ['Class 9-A',  '142','8', '3', '95%', 0.95],
              ['Class 10-A', '138','10','5', '92%', 0.92],
              ['Class 10-B', '135','12','4', '89%', 0.89],
              ['Class 9-B',  '128','18','6', '85%', 0.85],
              ['Class 8-A',  '118','22','8', '78%', 0.78],
              ['Class 8-B',  '108','30','10','72%', 0.72],
            ].where((r) => _attSelectedClass == null || r[0] == _attSelectedClass).map((r) {
              final pct = int.parse((r[4] as String).replaceAll('%',''));
              final color = pct >= 90 ? Colors.green : pct >= 80 ? Colors.orange : Colors.red;
              return Padding(padding: const EdgeInsets.only(bottom: 10),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text(r[0] as String, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                    Text(r[4] as String, style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 12)),
                  ]),
                  const SizedBox(height: 4),
                  ClipRRect(borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(value: r[5] as double, color: color,
                      backgroundColor: color.withOpacity(0.1), minHeight: 8)),
                  const SizedBox(height: 3),
                  Text('Present: ${r[1]} | Absent: ${r[2]} | Late: ${r[3]}',
                    style: const TextStyle(fontSize: 10, color: Colors.grey)),
                ]));
            })).toList(),
          ]))),
        const SizedBox(height: 16),

        // Student-wise attendance
        _sectionTitle(_attSelectedClass != null
          ? 'Student Attendance - $_attSelectedClass'
          : 'All Students Attendance'),
        const SizedBox(height: 8),
        if (classStudents.isEmpty)
          const Center(child: Padding(padding: EdgeInsets.all(16),
            child: Text('No students found', style: TextStyle(color: Colors.grey))))
        else
          ...classStudents.map((s) {
            final attPct = 87; // real data se aayega
            final color = attPct >= 90 ? Colors.green : attPct >= 80 ? Colors.orange : Colors.red;
            return Card(
              margin: const EdgeInsets.only(bottom: 6),
              child: Padding(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: Column(children: [
                  Row(children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: color.withOpacity(0.1),
                      child: Text(s.name.isNotEmpty ? s.name[0].toUpperCase() : '?',
                        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13))),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(s.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                      Text('${s.className}-${s.section} | Roll: ${s.rollNo}',
                        style: const TextStyle(fontSize: 10, color: Colors.grey)),
                    ])),
                    Text('$attPct%', style: TextStyle(fontWeight: FontWeight.bold,
                      color: color, fontSize: 14)),
                  ]),
                  const SizedBox(height: 8),
                  ClipRRect(borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(value: attPct / 100, color: color,
                      backgroundColor: color.withOpacity(0.1), minHeight: 6)),
                  const SizedBox(height: 4),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                    _attBadge('Present', '42', Colors.green),
                    _attBadge('Absent', '3', Colors.red),
                    _attBadge('Late', '2', Colors.orange),
                    _attBadge('Total', '47', Colors.blue),
                  ]),
                ]),
              ));
          }),
      ]),
    );
  }

  Widget _attBadge(String label, String val, Color color) =>
    Column(children: [
      Text(val, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: color)),
      Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
    ]);


  // Fee Report - Class + Student selector with fee breakdown
  Widget _feeReport() {
    final sp = context.watch<StudentProvider>();
    final fp = context.watch<FeeProvider>();
    final students = sp.students;
    final classes = students.map((s) => '${s.className}-${s.section}').toSet().toList()..sort();
    final classStudents = _feeSelectedClass == null ? students
      : students.where((s) => '${s.className}-${s.section}' == _feeSelectedClass).toList();

    // Total fee stats from real FeeProvider
    final totalCollected = fp.fees.where((f) => f.status == 'paid').fold(0.0, (s, f) => s + f.amount);
    final totalPending = fp.fees.where((f) => f.status == 'pending').fold(0.0, (s, f) => s + f.amount);
    final totalOverdue = fp.fees.where((f) => f.status == 'overdue').fold(0.0, (s, f) => s + f.amount);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _header('Fee Collection Report', 'June 2025', Icons.payments, const Color(0xFFE65100)),
        const SizedBox(height: 16),
        Row(children: [
          _sumCard('Collected', 'Rs ${(totalCollected/1000).toStringAsFixed(1)}K', Colors.green),
          const SizedBox(width: 10),
          _sumCard('Pending', 'Rs ${(totalPending/1000).toStringAsFixed(1)}K', Colors.orange),
          const SizedBox(width: 10),
          _sumCard('Overdue', 'Rs ${(totalOverdue/1000).toStringAsFixed(1)}K', Colors.red),
        ]),
        const SizedBox(height: 16),

        // Class selector
        _sectionTitle('Select Class'),
        const SizedBox(height: 8),
        SizedBox(height: 38,
          child: ListView(scrollDirection: Axis.horizontal, children: [
            GestureDetector(
              onTap: () => setState(() { _feeSelectedClass = null; _feeSelectedStudent = null; }),
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: _feeSelectedClass == null ? const Color(0xFFE65100) : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(20)),
                child: Text('All Classes',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                    color: _feeSelectedClass == null ? Colors.white : Colors.grey.shade700)),
              ),
            ),
            ...classes.map((cls) => GestureDetector(
              onTap: () => setState(() { _feeSelectedClass = cls; _feeSelectedStudent = null; }),
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: _feeSelectedClass == cls ? const Color(0xFFE65100) : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(20)),
                child: Text(cls,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                    color: _feeSelectedClass == cls ? Colors.white : Colors.grey.shade700)),
              ),
            )),
          ])),
        const SizedBox(height: 16),

        // Fee type breakdown
        _sectionTitle('Fee Type Breakdown'),
        ...([
          ['Tuition Fee',   Colors.blue],
          ['Hostel Fee',    Colors.purple],
          ['Transport Fee', Colors.orange],
          ['Exam Fee',      Colors.teal],
          ['Library Fee',   Colors.green],
        ].map((ft) {
          final feesOfType = fp.fees.where((f) => f.feeType == ft[0]);
          final collected = feesOfType.where((f) => f.status == 'paid').fold(0.0, (s, f) => s + f.amount);
          final pending = feesOfType.where((f) => f.status != 'paid').fold(0.0, (s, f) => s + f.amount);
          final total = collected + pending;
          final ratio = total > 0 ? collected / total : 0.0;
          final color = ft[1] as Color;
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: Padding(padding: const EdgeInsets.all(12),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Row(children: [
                    Container(width: 10, height: 10,
                      decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                    const SizedBox(width: 8),
                    Text(ft[0] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  ]),
                  Text('Rs ${collected.toStringAsFixed(0)}',
                    style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12)),
                ]),
                const SizedBox(height: 6),
                ClipRRect(borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(value: ratio as double, color: color,
                    backgroundColor: color.withOpacity(0.1), minHeight: 10)),
                const SizedBox(height: 4),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('${(ratio * 100).toStringAsFixed(0)}% collected',
                    style: TextStyle(fontSize: 11, color: color)),
                  Text('Pending: Rs ${pending.toStringAsFixed(0)}',
                    style: const TextStyle(fontSize: 11, color: Colors.orange)),
                ]),
              ])));
        })).toList(),
        const SizedBox(height: 16),

        // Student-wise fee breakdown
        _sectionTitle(_feeSelectedClass != null
          ? 'Student Fees - $_feeSelectedClass'
          : 'All Student Fees'),
        const SizedBox(height: 8),
        if (classStudents.isEmpty)
          const Center(child: Padding(padding: EdgeInsets.all(16),
            child: Text('No students found', style: TextStyle(color: Colors.grey))))
        else
          ...classStudents.map((s) {
            final sFees = fp.fees.where((f) => f.studentId == s.id).toList();
            final sPaid = sFees.where((f) => f.status == 'paid').fold(0.0, (sum, f) => sum + f.amount);
            final sPending = sFees.where((f) => f.status != 'paid').fold(0.0, (sum, f) => sum + f.amount);
            final sTotal = sPaid + sPending;
            final isExpanded = _feeSelectedStudent == s.admissionNo;

            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: Column(children: [
                ListTile(
                  onTap: () => setState(() =>
                    _feeSelectedStudent = isExpanded ? null : s.admissionNo),
                  leading: CircleAvatar(
                    backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                    child: Text(s.name.isNotEmpty ? s.name[0].toUpperCase() : '?',
                      style: const TextStyle(color: AppTheme.primaryColor,
                        fontWeight: FontWeight.bold))),
                  title: Text(s.name,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  subtitle: Text('${s.className}-${s.section} | ${s.admissionNo}',
                    style: const TextStyle(fontSize: 11)),
                  trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                    Column(mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end, children: [
                      Text('Rs ${sPaid.toStringAsFixed(0)}',
                        style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12)),
                      if (sPending > 0)
                        Text('Pending: Rs ${sPending.toStringAsFixed(0)}',
                          style: const TextStyle(color: Colors.red, fontSize: 10)),
                    ]),
                    Icon(isExpanded ? Icons.expand_less : Icons.expand_more, color: Colors.grey),
                  ]),
                ),
                if (isExpanded) Padding(
                  padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                  child: Column(children: [
                    const Divider(height: 8),
                    if (sFees.isEmpty)
                      const Text('No fee records', style: TextStyle(color: Colors.grey, fontSize: 12))
                    else
                      ...sFees.map((f) {
                        final fc = f.status == 'paid' ? Colors.green
                          : f.status == 'overdue' ? Colors.red : Colors.orange;
                        return Padding(padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(children: [
                            Expanded(child: Text(f.feeType,
                              style: const TextStyle(fontSize: 12))),
                            Text('Rs ${f.amount.toStringAsFixed(0)}',
                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: fc.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8)),
                              child: Text(f.status.toUpperCase(),
                                style: TextStyle(fontSize: 9, color: fc, fontWeight: FontWeight.bold))),
                          ]));
                      }),
                    const SizedBox(height: 8),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      const Text('Total:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      Text('Rs ${sTotal.toStringAsFixed(0)}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    ]),
                    if (sPending > 0) Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      const Text('Pending:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.red)),
                      Text('Rs ${sPending.toStringAsFixed(0)}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.red)),
                    ]),
                  ]),
                ),
              ]));
          }),
      ]),
    );
  }

  // ?? Academic Report ?????????
  Widget _academicReport() => SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _header('Academic Performance', 'Mid-Term 2025', Icons.grade, const Color(0xFF6A1B9A)),
      const SizedBox(height: 16),
      Row(children: [
        _sumCard('Class Avg', '76.4%', Colors.blue),
        const SizedBox(width: 10),
        _sumCard('Pass Rate', '94.2%', Colors.green),
        const SizedBox(width: 10),
        _sumCard('A+ Students', '12', Colors.purple),
      ]),
      const SizedBox(height: 16),
      _sectionTitle('Subject-wise Average'),
      ...[
        ['Mathematics', '84%', 0.84, Colors.blue],
        ['Science', '79%', 0.79, Colors.green],
        ['English', '82%', 0.82, Colors.purple],
        ['Hindi', '88%', 0.88, Colors.orange],
        ['Social Science', '76%', 0.76, Colors.teal],
        ['Computer', '91%', 0.91, Colors.indigo],
      ].map((s) => Card(
        margin: const EdgeInsets.only(bottom: 6),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(children: [
            SizedBox(width: 110, child: Text(s[0] as String,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12))),
            Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(value: s[2] as double, color: s[3] as Color,
                backgroundColor: (s[3] as Color).withOpacity(0.1), minHeight: 12))),
            const SizedBox(width: 10),
            Text(s[1] as String, style: TextStyle(fontWeight: FontWeight.bold, color: s[3] as Color, fontSize: 13)),
          ]),
        ),
      )),
    ]),
  );

  // ?? Teacher Workload ????????
  Widget _teacherWorkload() => SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _header('Teacher Workload Report', 'June 2025', Icons.person_pin, const Color(0xFF00838F)),
      const SizedBox(height: 16),
      _sectionTitle('Teacher-wise Classes'),
      ...[
        ['Mr. Ravi Sharma', 'Mathematics', '8 classes', '32 periods/week'],
        ['Mrs. Priya', 'English', '6 classes', '24 periods/week'],
        ['Mr. Kumar', 'Science', '7 classes', '28 periods/week'],
        ['Mrs. Gupta', 'Hindi', '6 classes', '24 periods/week'],
        ['Mr. Singh', 'Social Sc.', '5 classes', '20 periods/week'],
        ['Mr. Tech', 'Computer', '4 classes', '16 periods/week'],
      ].map((t) => Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: ListTile(
          leading: CircleAvatar(backgroundColor: const Color(0xFF00838F).withOpacity(0.1),
            child: Text((t[0] as String).split(' ').last[0],
              style: const TextStyle(color: Color(0xFF00838F), fontWeight: FontWeight.bold))),
          title: Text(t[0] as String, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          subtitle: Text('Subject: ${t[1]}', style: const TextStyle(fontSize: 11)),
          trailing: Column(mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(t[2] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            Text(t[3] as String, style: const TextStyle(fontSize: 10, color: Colors.grey)),
          ]),
        ),
      )),
    ]),
  );

  // ?? Hostel Occupancy ????????
  Widget _hostelOccupancy() => SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _header('Hostel Occupancy Report', 'June 2025', Icons.hotel, const Color(0xFF0288D1)),
      const SizedBox(height: 16),
      Row(children: [
        _sumCard('Total Rooms', '75',  Colors.blue),
        const SizedBox(width: 10),
        _sumCard('Occupied', '59',     Colors.orange),
        const SizedBox(width: 10),
        _sumCard('Vacant', '16',       Colors.green),
      ]),
      const SizedBox(height: 16),
      _sectionTitle('Hostel-wise Occupancy'),
      ...[
        ['Boys Hostel A',       30, 24, Colors.blue],
        ['Girls Hostel B',      25, 20, Colors.pink],
        ['Senior Boys Hostel',  20, 15, Colors.indigo],
      ].map((h) {
        final pct = (h[2] as int) / (h[1] as int);
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text(h[0] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Text('${h[2]}/${h[1]} rooms', style: TextStyle(color: h[3] as Color, fontWeight: FontWeight.bold)),
              ]),
              const SizedBox(height: 8),
              ClipRRect(borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(value: pct, color: h[3] as Color,
                  backgroundColor: (h[3] as Color).withOpacity(0.1), minHeight: 12)),
              const SizedBox(height: 4),
              Text('${(pct * 100).toStringAsFixed(0)}% occupied',
                style: TextStyle(fontSize: 11, color: h[3] as Color)),
            ]),
          ),
        );
      }),
    ]),
  );

  // ?? Transport Report ????????
  Widget _transportReport() => SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _header('Transport Utilization', 'June 2025', Icons.directions_bus, const Color(0xFFF57F17)),
      const SizedBox(height: 16),
      Row(children: [
        _sumCard('Vehicles', '3',    Colors.blue),
        const SizedBox(width: 10),
        _sumCard('Routes', '2',      Colors.orange),
        const SizedBox(width: 10),
        _sumCard('Students', '3',    Colors.green),
      ]),
      const SizedBox(height: 16),
      _sectionTitle('Vehicle Utilization'),
      ...[
        ['DL 01 AB 1234', 'Bus',     40, 28, 'Route 1 - North', Colors.blue],
        ['DL 02 CD 5678', 'Mini Bus',20, 15, 'Route 2 - South', Colors.green],
        ['DL 03 EF 9012', 'Van',     10, 0, 'Maintenance',     Colors.red],
      ].map((v) {
        final pct = (v[1] as String) == 'Maintenance' ? 0.0 : (v[3] as int) / (v[2] as int);
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text(v[0] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Text('${v[4]}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ]),
              const SizedBox(height: 6),
              Text('${v[3]}/${v[2]} seats occupied',
                style: TextStyle(fontSize: 12, color: v[5] as Color)),
              const SizedBox(height: 6),
              ClipRRect(borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(value: pct, color: v[5] as Color,
                  backgroundColor: (v[5] as Color).withOpacity(0.1), minHeight: 10)),
            ]),
          ),
        );
      }),
    ]),
  );

  // ?? Library Report ??????????
  Widget _libraryReport() => SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _header('Library Usage Report', 'June 2025', Icons.library_books, const Color(0xFF455A64)),
      const SizedBox(height: 16),
      Row(children: [
        _sumCard('Total Books', '460', Colors.blue),
        const SizedBox(width: 10),
        _sumCard('Issued', '120',      Colors.orange),
        const SizedBox(width: 10),
        _sumCard('Overdue', '4',       Colors.red),
      ]),
      const SizedBox(height: 16),
      _sectionTitle('Most Issued Books'),
      ...[
        ['Mathematics NCERT Class 10', 'NCERT', '3/10 issued'],
        ['Wings of Fire', 'A.P.J. Abdul Kalam','2/5 issued'],
        ['Science NCERT Class 10', 'NCERT', '5/10 issued'],
        ['English Literature', 'NCERT', '8/8 issued'],
        ['The Alchemist', 'Paulo Coelho', '2/4 issued'],
      ].map((b) => Card(
        margin: const EdgeInsets.only(bottom: 6),
        child: ListTile(
          leading: Container(width: 40, height: 40,
            decoration: BoxDecoration(color: const Color(0xFF455A64).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.menu_book, color: Color(0xFF455A64), size: 20)),
          title: Text(b[0] as String, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          subtitle: Text(b[1] as String, style: const TextStyle(fontSize: 11)),
          trailing: Text(b[2] as String, style: const TextStyle(fontSize: 12, color: Colors.orange, fontWeight: FontWeight.w500)),
        ),
      )),
    ]),
  );

  // ?? Admission Report ????????
  Widget _admissionReport() => SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _header('Admission Report', '2025-26', Icons.how_to_reg, const Color(0xFF7B1FA2)),
      const SizedBox(height: 16),
      Row(children: [
        _sumCard('Applications', '45', Colors.blue),
        const SizedBox(width: 10),
        _sumCard('Approved', '32',     Colors.green),
        const SizedBox(width: 10),
        _sumCard('Pending', '8',       Colors.orange),
      ]),
      const SizedBox(height: 16),
      _sectionTitle('Class-wise Applications'),
      ...[
        ['Nursery',   8, 6],
        ['LKG',       6, 5],
        ['UKG',       5, 4],
        ['Class 1',   7, 6],
        ['Class 6',   5, 4],
        ['Class 9',   8, 5],
        ['Class 11',  6, 2],
      ].map((c) => Card(
        margin: const EdgeInsets.only(bottom: 6),
        child: ListTile(
          title: Text(c[0] as String, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          subtitle: Text('${c[1]} applied - ${c[2]} approved', style: const TextStyle(fontSize: 11)),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: Text('${c[2]}/${c[1]}',
              style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold))),
        ),
      )),
    ]),
  );

  // ?? Payroll Report ??????????
  Widget _payrollReport() => SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _header('Staff Payroll Report', 'June 2025', Icons.account_balance, const Color(0xFFC62828)),
      const SizedBox(height: 16),
      Row(children: [
        _sumCard('Total Staff', '86',        Colors.blue),
        const SizedBox(width: 10),
        _sumCard('Paid', 'Rs 25.1L',         Colors.green),
        const SizedBox(width: 10),
        _sumCard('Pending', 'Rs 2.3L',       Colors.orange),
      ]),
      const SizedBox(height: 16),
      _sectionTitle('Payroll Summary'),
      ...[
        ['Dr. Rajesh Kumar', 'Principal', 'Rs 92,400', 'paid'],
        ['Priya Sharma', 'Sr. Teacher', 'Rs 58,500', 'paid'],
        ['Amit Verma', 'Teacher', 'Rs 53,350', 'pending'],
        ['Sunita Patel', 'Teacher', 'Rs 47,200', 'pending'],
        ['Ravi Singh', 'Lab Assistant', 'Rs 38,500', 'paid'],
      ].map((s) {
        final color = s[3] == 'paid' ? Colors.green : Colors.orange;
        return Card(
          margin: const EdgeInsets.only(bottom: 6),
          child: ListTile(
            leading: CircleAvatar(backgroundColor: const Color(0xFFC62828).withOpacity(0.1),
              child: Text((s[0] as String).split(' ').last[0],
                style: const TextStyle(color: Color(0xFFC62828), fontWeight: FontWeight.bold))),
            title: Text(s[0] as String, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            subtitle: Text(s[1] as String, style: const TextStyle(fontSize: 11)),
            trailing: Column(mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text(s[2] as String, style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 13)),
              Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                child: Text((s[3] as String).toUpperCase(),
                  style: TextStyle(fontSize: 9, color: color, fontWeight: FontWeight.bold))),
            ]),
          ),
        );
      }),
    ]),
  );

  // ?? Exam Report ???????
  Widget _examReport() => SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _header('Exam Schedule Report', '2025', Icons.quiz, const Color(0xFF1B5E20)),
      const SizedBox(height: 16),
      _sectionTitle('Upcoming Exams'),
      ...[
        ['Mid-Term Exam', 'Mathematics', 'Class 10', '20 Jun 2025', 'upcoming'],
        ['Mid-Term Exam', 'Science', 'Class 10', '21 Jun 2025', 'upcoming'],
        ['Mid-Term Exam', 'English', 'Class 10', '22 Jun 2025', 'upcoming'],
        ['Unit Test 2', 'All Subjects', 'Class 9', '25 Jun 2025', 'upcoming'],
      ].map((e) => Card(
        margin: const EdgeInsets.only(bottom: 6),
        child: ListTile(
          leading: Container(width: 40, height: 40,
            decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.quiz, color: Colors.blue, size: 20)),
          title: Text(e[0] as String, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          subtitle: Text('${e[1]} - ${e[2]}', style: const TextStyle(fontSize: 11)),
          trailing: Text(e[3] as String, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        ),
      )),
    ]),
  );

  // ?? Leave Report ??????
  Widget _leaveReport() => SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _header('Leave Management Report', 'June 2025', Icons.event_busy, const Color(0xFF4E342E)),
      const SizedBox(height: 16),
      Row(children: [
        _sumCard('Applied', '15',   Colors.blue),
        const SizedBox(width: 10),
        _sumCard('Approved', '10', Colors.green),
        const SizedBox(width: 10),
        _sumCard('Pending', '5',   Colors.orange),
      ]),
      const SizedBox(height: 16),
      _sectionTitle('Recent Leave Requests'),
      ...[
        ['Priya Sharma', 'Sick Leave', '18-19 Jun', 'approved'],
        ['Amit Verma', 'Casual Leave', '22 Jun', 'approved'],
        ['Ravi Singh', 'Medical', '25 Jun', 'pending'],
        ['Meena Gupta', 'Emergency', '20 Jun', 'pending'],
      ].map((l) {
        final color = l[3] == 'approved' ? Colors.green : Colors.orange;
        return Card(
          margin: const EdgeInsets.only(bottom: 6),
          child: ListTile(
            leading: Icon(l[3] == 'approved' ? Icons.check_circle : Icons.pending, color: color),
            title: Text(l[0] as String, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            subtitle: Text('${l[1]} - ${l[2]}', style: const TextStyle(fontSize: 11)),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
              child: Text((l[3] as String).toUpperCase(),
                style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.bold))),
          ),
        );
      }),
    ]),
  );

  // ?? Default ???????????
  Widget _defaultReport() => Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Icon(Icons.bar_chart, size: 64, color: Colors.grey),
      const SizedBox(height: 12),
      Text(reportType, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      const Text('Report details coming soon', style: TextStyle(color: Colors.grey)),
    ]),
  );

  // ?? Helper Widgets ??????????
  Widget _header(String title, String period, IconData icon, Color color) => Card(
    color: color.withOpacity(0.05),
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Row(children: [
        Container(width: 50, height: 50,
          decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: color, size: 28)),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: color)),
          const SizedBox(height: 2),
          Text('Period: $period', style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 4),
          Row(children: [
            Icon(Icons.circle, size: 8, color: color),
            const SizedBox(width: 4),
            Text('Live Data', style: TextStyle(fontSize: 11, color: color)),
          ]),
        ])),
      ]),
    ),
  );

  Widget _sumCard(String label, String value, Color color) => Expanded(
    child: Card(child: Padding(
      padding: const EdgeInsets.all(10),
      child: Column(children: [
        Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey), textAlign: TextAlign.center),
      ]),
    )));

  Widget _miniStat(String label, String val, Color color) => Column(
    children: [
      Text(val, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: color)),
      Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
    ]);

  Widget _sectionTitle(String title) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(children: [
      Container(width: 4, height: 18,
        decoration: BoxDecoration(color: AppTheme.primaryColor, borderRadius: BorderRadius.circular(2))),
      const SizedBox(width: 8),
      Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
    ]),
  );

  Color _rankColor(String rank) {
    switch (rank) {
      case '1': return Colors.amber;
      case '2': return Colors.grey;
      case '3': return Colors.brown;
      default:  return Colors.blue;
    }
  }
}