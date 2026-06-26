import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/theme/app_theme.dart';

class ReportDetailScreen extends StatelessWidget {
  final String reportType;
  const ReportDetailScreen({super.key, required this.reportType});

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

  // ?? Student Progress ????????
  Widget _studentProgress() => SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _header('Student Progress Report', 'June 2025', Icons.person, Colors.blue),
      const SizedBox(height: 16),
      Row(children: [
        _sumCard('Total Students', '1,248', Colors.blue),
        const SizedBox(width: 10),
        _sumCard('Pass Rate', '94.2%', Colors.green),
        const SizedBox(width: 10),
        _sumCard('Avg Score', '76.4%', Colors.orange),
      ]),
      const SizedBox(height: 16),
      _sectionTitle('Top Performers'),
      ...[
        ['1', 'Priya Singh', 'Class 10-A', '97.4%', 'A+'],
        ['2', 'Sneha Patel', 'Class 10-B', '95.0%', 'A+'],
        ['3', 'Rahul Kumar', 'Class 10-A', '92.8%', 'A+'],
        ['4', 'Anita Gupta', 'Class 9-A', '91.5%', 'A+'],
        ['5', 'Vijay Verma', 'Class 9-B', '89.3%', 'A'],
      ].map((s) => Card(
        margin: const EdgeInsets.only(bottom: 6),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: _rankColor(s[0] as String).withOpacity(0.15),
            child: Text(s[0] as String,
              style: TextStyle(color: _rankColor(s[0] as String), fontWeight: FontWeight.bold))),
          title: Text(s[1] as String, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          subtitle: Text(s[2] as String, style: const TextStyle(fontSize: 11)),
          trailing: Column(mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(s[3] as String, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 13)),
            Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
              child: Text(s[4] as String, style: const TextStyle(fontSize: 10, color: Colors.green, fontWeight: FontWeight.bold))),
          ]),
        ),
      )),
      const SizedBox(height: 16),
      _sectionTitle('Needs Attention'),
      ...[
        ['Ravi Kumar', 'Class 8-B', '45.0%', 'F'],
        ['Mohan Singh', 'Class 7-A', '48.5%', 'F'],
        ['Asha Patel', 'Class 9-B', '52.0%', 'C'],
      ].map((s) => Card(
        color: Colors.red.shade50,
        margin: const EdgeInsets.only(bottom: 6),
        child: ListTile(
          leading: CircleAvatar(backgroundColor: Colors.red.withOpacity(0.1),
            child: Icon(Icons.warning, color: Colors.red, size: 18)),
          title: Text(s[0] as String, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          subtitle: Text(s[1] as String, style: const TextStyle(fontSize: 11)),
          trailing: Text(s[2] as String,
            style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 13)),
        ),
      )),
    ]),
  );

  // ?? Attendance Report ???????
  Widget _attendanceReport() => SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _header('Attendance Report', 'June 2025', Icons.calendar_today, Colors.green),
      const SizedBox(height: 16),
      Row(children: [
        _sumCard('Avg Attendance', '87.3%', Colors.green),
        const SizedBox(width: 10),
        _sumCard('Total Present', '1,088', Colors.blue),
        const SizedBox(width: 10),
        _sumCard('Total Absent', '160', Colors.red),
      ]),
      const SizedBox(height: 16),
      _sectionTitle('Class-wise Summary'),
      Card(child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(Colors.green.withOpacity(0.08)),
          columns: const [
            DataColumn(label: Text('Class',   style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Present', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Absent',  style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Late',    style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('%',       style: TextStyle(fontWeight: FontWeight.bold))),
          ],
          rows: [
            ['Class 9-A', '142', '8', '3', '95%'],
            ['Class 10-A', '138', '10', '5', '92%'],
            ['Class 10-B', '135', '12', '4', '89%'],
            ['Class 9-B', '128', '18', '6', '85%'],
            ['Class 8-A', '118', '22', '8', '78%'],
            ['Class 8-B', '108', '30', '10','72%'],
          ].map((r) => DataRow(cells: r.map((c) => DataCell(Text(c,
            style: TextStyle(fontSize: 12,
              color: c.endsWith('%') ? (int.parse(c.replaceAll('%','')) >= 85 ? Colors.green : Colors.red) : null,
              fontWeight: c.endsWith('%') ? FontWeight.bold : FontWeight.normal)))).toList())).toList(),
        ),
      )),
      const SizedBox(height: 16),
      _sectionTitle('Daily Trend - June 2025'),
      Card(child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(children: [
          ...[
            ['Week 1 (1-7 Jun)', '89%', 0.89],
            ['Week 2 (8-14 Jun)', '85%', 0.85],
            ['Week 3 (15-21 Jun)', '88%', 0.88],
            ['Week 4 (22-28 Jun)', '87%', 0.87],
          ].map((w) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(children: [
              SizedBox(width: 140, child: Text(w[0] as String, style: const TextStyle(fontSize: 12))),
              Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(value: w[2] as double, color: Colors.green,
                  backgroundColor: Colors.green.withOpacity(0.1), minHeight: 12))),
              const SizedBox(width: 8),
              Text(w[1] as String, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 12)),
            ]),
          )),
        ]),
      )),
    ]),
  );

  // ?? Fee Report ????????
  Widget _feeReport() => SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _header('Fee Collection Report', 'June 2025', Icons.payments, const Color(0xFFE65100)),
      const SizedBox(height: 16),
      Row(children: [
        _sumCard('Collected', 'Rs 4.2L', Colors.green),
        const SizedBox(width: 10),
        _sumCard('Pending', 'Rs 1.1L', Colors.orange),
        const SizedBox(width: 10),
        _sumCard('Overdue', 'Rs 0.3L', Colors.red),
      ]),
      const SizedBox(height: 16),
      _sectionTitle('Fee Type Breakdown'),
      ...[
        ['Tuition Fee', 'Rs 2,80,000', 'Rs 45,000',  0.86, Colors.blue],
        ['Hostel Fee', 'Rs 96,000', 'Rs 24,000',   0.80, Colors.purple],
        ['Transport Fee', 'Rs 28,000', 'Rs 8,000',    0.78, Colors.orange],
        ['Library Fee', 'Rs 8,500', 'Rs 1,500',    0.85, Colors.green],
        ['Lab Fee', 'Rs 7,500', 'Rs 2,500',    0.75, Colors.teal],
      ].map((f) => Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(f[0] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              Text('Collected: ${f[1]}', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w600, fontSize: 12)),
            ]),
            const SizedBox(height: 6),
            ClipRRect(borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(value: f[3] as double, color: f[4] as Color,
                backgroundColor: (f[4] as Color).withOpacity(0.1), minHeight: 10)),
            const SizedBox(height: 4),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('${((f[3] as double) * 100).toStringAsFixed(0)}% collected',
                style: TextStyle(fontSize: 11, color: f[4] as Color)),
              Text('Pending: ${f[2]}', style: const TextStyle(fontSize: 11, color: Colors.orange)),
            ]),
          ]),
        ),
      )),
      const SizedBox(height: 16),
      _sectionTitle('Recent Transactions'),
      ...[
        ['Priya Singh', 'Tuition Fee', 'Rs 12,500', '15 Jun 2025', 'paid'],
        ['Rahul Kumar', 'Hostel Fee', 'Rs 8,000', '10 Jun 2025', 'pending'],
        ['Vijay Verma', 'Transport Fee', 'Rs 3,500', '01 Jun 2025', 'overdue'],
        ['Anita Gupta', 'Tuition Fee', 'Rs 12,500', '14 Jun 2025', 'paid'],
      ].map((t) {
        final color = t[4] == 'paid' ? Colors.green : t[4] == 'pending' ? Colors.orange : Colors.red;
        return Card(
          margin: const EdgeInsets.only(bottom: 6),
          child: ListTile(
            leading: CircleAvatar(backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
              child: Text((t[0] as String)[0],
                style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold))),
            title: Text(t[0] as String, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            subtitle: Text('${t[1]} - ${t[3]}', style: const TextStyle(fontSize: 11)),
            trailing: Column(mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text(t[2] as String, style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 13)),
              Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                child: Text((t[4] as String).toUpperCase(),
                  style: TextStyle(fontSize: 9, color: color, fontWeight: FontWeight.bold))),
            ]),
          ),
        );
      }),
    ]),
  );

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