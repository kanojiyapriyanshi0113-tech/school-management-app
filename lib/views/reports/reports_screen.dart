import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import '../../providers/auth_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/language_provider.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});
  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() { _tabController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.watch<LanguageProvider>().t('reports_analytics')),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () {
            final r = context.read<AuthProvider>().user?.role;
            context.go(r == 'staff' ? '/dashboard/staff' : '/dashboard/admin');
          },
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            Tab(text: context.watch<LanguageProvider>().t('overview')),
            Tab(text: context.watch<LanguageProvider>().t('attendance')),
            Tab(text: context.watch<LanguageProvider>().t('academic')),
            Tab(text: 'Finance'),
            Tab(text: context.watch<LanguageProvider>().t('all_reports')),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _overviewTab(),
          _attendanceTab(),
          _academicTab(),
          _financeTab(),
          _allReportsTab(),
        ],
      ),
    );
  }

  // ?? Overview Tab ??????
  Widget _overviewTab() => SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Month selector
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        const Text('School Overview', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8)),
          child: const Row(children: [
            Icon(Icons.calendar_today, size: 14, color: AppTheme.primaryColor),
            SizedBox(width: 6),
            Text('June 2025', style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.w600, fontSize: 12)),
          ])),
      ]),
      const SizedBox(height: 16),

      // KPI Cards
      GridView.count(
        shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10,
        childAspectRatio: 1.4,
        children: [
          _kpi('Total Students', '1,248', '+12 this month', Icons.people, Colors.blue, true),
          _kpi('Total Staff', '86', '+2 this month', Icons.person, Colors.green, true),
          _kpi('Attendance Rate', '87.3%', '-1.2% vs last month', Icons.check_circle, Colors.orange, false),
          _kpi('Fee Collection', 'Rs 4.2L', '+Rs 0.8L vs last', Icons.payments, Colors.purple, true),
          _kpi('Pending Fees', 'Rs 1.1L', '-Rs 0.3L vs last', Icons.warning, Colors.red, false),
          _kpi('Pass Rate', '94.2%', '+2.1% vs last exam', Icons.grade, Colors.teal, true),
        ],
      ),
      const SizedBox(height: 20),

      // Attendance bar chart (manual)
      const Text('Monthly Attendance Trend', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
      const SizedBox(height: 12),
      Card(child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            _legend('Present', Colors.green),
            const SizedBox(width: 12),
            _legend('Absent', Colors.red),
          ]),
          const SizedBox(height: 12),
          SizedBox(height: 160, child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ['Jan', 0.88, 0.12],
              ['Feb', 0.85, 0.15],
              ['Mar', 0.90, 0.10],
              ['Apr', 0.87, 0.13],
              ['May', 0.83, 0.17],
              ['Jun', 0.87, 0.13],
            ].map((m) => _bar(m[0] as String, m[1] as double, m[2] as double)).toList(),
          )),
        ]),
      )),
      const SizedBox(height: 16),

      // Fee collection bar chart
      const Text('Fee Collection (Monthly)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
      const SizedBox(height: 12),
      Card(child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          SizedBox(height: 160, child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ['Jan', 0.75],
              ['Feb', 0.60],
              ['Mar', 0.90],
              ['Apr', 0.80],
              ['May', 0.70],
              ['Jun', 0.85],
            ].map((m) => _singleBar(m[0] as String, m[1] as double, Colors.blue)).toList(),
          )),
          const SizedBox(height: 8),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Total Collected: Rs 24.5L', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.green)),
            const Text('Target: Rs 30L', style: TextStyle(fontSize: 12, color: Colors.grey)),
          ]),
          const SizedBox(height: 6),
          ClipRRect(borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(value: 0.817, color: Colors.green,
              backgroundColor: Colors.grey.shade200, minHeight: 10)),
          const SizedBox(height: 4),
          const Text('81.7% of annual target achieved', style: TextStyle(fontSize: 11, color: Colors.grey)),
        ]),
      )),
    ]),
  );

  // ?? Attendance Tab ??????????
  Widget _attendanceTab() => SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Summary cards
      Row(children: [
        _miniStat('Avg Attendance', '87.3%', Colors.green),
        const SizedBox(width: 10),
        _miniStat('Best Class', 'Class 9-A 95%', Colors.blue),
        const SizedBox(width: 10),
        _miniStat('Needs Attention','Class 8-B 72%', Colors.red),
      ]),
      const SizedBox(height: 16),

      // Class-wise attendance
      const Text('Class-wise Attendance', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
      const SizedBox(height: 10),
      ...[
        ['Class 9-A',  0.95, '95%', Colors.green],
        ['Class 10-A', 0.92, '92%', Colors.green],
        ['Class 10-B', 0.89, '89%', Colors.green],
        ['Class 9-B',  0.85, '85%', Colors.orange],
        ['Class 11-A', 0.82, '82%', Colors.orange],
        ['Class 8-A',  0.78, '78%', Colors.orange],
        ['Class 8-B',  0.72, '72%', Colors.red],
        ['Class 7-A',  0.88, '88%', Colors.green],
      ].map((c) => Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(children: [
            SizedBox(width: 80, child: Text(c[0] as String,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
            Expanded(child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: c[1] as double, color: c[3] as Color,
                backgroundColor: (c[3] as Color).withOpacity(0.1), minHeight: 12))),
            const SizedBox(width: 10),
            SizedBox(width: 40, child: Text(c[2] as String,
              style: TextStyle(fontWeight: FontWeight.bold, color: c[3] as Color, fontSize: 13))),
          ]),
        ),
      )),
      const SizedBox(height: 16),

      // Staff attendance
      const Text('Staff Attendance', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
      const SizedBox(height: 10),
      Card(child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          _attendStat('Present Today', '78', Colors.green),
          _attendStat('Absent Today', '5',  Colors.red),
          _attendStat('On Leave', '3',      Colors.orange),
          _attendStat('Total Staff', '86',  Colors.blue),
        ]),
      )),
      const SizedBox(height: 16),

      // Export buttons
      SizedBox(width: double.infinity, child: OutlinedButton.icon(
        onPressed: () => _exportPdf(context, 'Attendance Report'),
        icon: const Icon(Icons.picture_as_pdf),
        label: Text(context.watch<LanguageProvider>().t('export_pdf')),
      )),
    ]),
  );

  // ?? Academic Tab ??????
  Widget _academicTab() => SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Exam results summary
      Row(children: [
        _miniStat('Class Avg', '76.4%',  Colors.blue),
        const SizedBox(width: 10),
        _miniStat('Pass Rate', '94.2%',  Colors.green),
        const SizedBox(width: 10),
        _miniStat('Toppers', '12 A+',  Colors.purple),
      ]),
      const SizedBox(height: 16),

      // Subject-wise performance
      const Text('Subject-wise Performance', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
      const SizedBox(height: 10),
      ...[
        ['Mathematics',    0.84, '84%', Colors.blue],
        ['Science',        0.79, '79%', Colors.green],
        ['English',        0.82, '82%', Colors.purple],
        ['Hindi',          0.88, '88%', Colors.orange],
        ['Social Science', 0.76, '76%', Colors.teal],
        ['Computer',       0.91, '91%', Colors.indigo],
      ].map((s) => Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(children: [
            SizedBox(width: 110, child: Text(s[0] as String,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12))),
            Expanded(child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: s[1] as double, color: s[3] as Color,
                backgroundColor: (s[3] as Color).withOpacity(0.1), minHeight: 12))),
            const SizedBox(width: 10),
            SizedBox(width: 40, child: Text(s[2] as String,
              style: TextStyle(fontWeight: FontWeight.bold, color: s[3] as Color, fontSize: 13))),
          ]),
        ),
      )),
      const SizedBox(height: 16),

      // Grade distribution
      const Text('Grade Distribution', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
      const SizedBox(height: 10),
      Card(child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(children: [
          ...[
            ['A+ (90-100)', 0.12, '12%', Colors.green],
            ['A  (80-89)',  0.28, '28%', Colors.lightGreen],
            ['B+ (70-79)',  0.31, '31%', Colors.blue],
            ['B  (60-69)',  0.18, '18%', Colors.orange],
            ['C  (50-59)',  0.08, '8%',  Colors.amber],
            ['F  (<50)',    0.03, '3%',  Colors.red],
          ].map((g) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(children: [
              SizedBox(width: 90, child: Text(g[0] as String, style: const TextStyle(fontSize: 12))),
              Expanded(child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(value: g[1] as double, color: g[3] as Color,
                  backgroundColor: (g[3] as Color).withOpacity(0.1), minHeight: 10))),
              const SizedBox(width: 8),
              SizedBox(width: 32, child: Text(g[2] as String,
                style: TextStyle(fontSize: 11, color: g[3] as Color, fontWeight: FontWeight.bold))),
            ]),
          )),
        ]),
      )),
    ]),
  );

  // ?? Finance Tab ???????
  Widget _financeTab() => SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        _miniStat('Collected', 'Rs 4.2L', Colors.green),
        const SizedBox(width: 10),
        _miniStat('Pending', 'Rs 1.1L', Colors.orange),
        const SizedBox(width: 10),
        _miniStat('Overdue', 'Rs 0.3L', Colors.red),
      ]),
      const SizedBox(height: 16),

      const Text('Fee Collection by Type', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
      const SizedBox(height: 10),
      ...[
        ['Tuition Fee', 'Rs 2,80,000', 'Rs 45,000',  Colors.blue],
        ['Hostel Fee', 'Rs 96,000', 'Rs 24,000',  Colors.purple],
        ['Transport Fee', 'Rs 28,000', 'Rs 8,000',   Colors.orange],
        ['Library Fee', 'Rs 8,500', 'Rs 1,500',   Colors.green],
        ['Lab Fee', 'Rs 7,500', 'Rs 2,500',   Colors.teal],
      ].map((f) => Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(children: [
            Container(width: 10, height: 10,
              decoration: BoxDecoration(color: f[3] as Color, shape: BoxShape.circle)),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(f[0] as String, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              Text('Collected: ${f[1]}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
            ])),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text(f[1] as String, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 13)),
              Text('Pending: ${f[2]}', style: const TextStyle(fontSize: 10, color: Colors.orange)),
            ]),
          ]),
        ),
      )),
      const SizedBox(height: 16),

      // Defaulters list
      const Text('Top Defaulters', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
      const SizedBox(height: 10),
      ...[
        ['Vijay Verma', 'Class 9-A', 'Rs 8,500', '45 days'],
        ['Amit Sharma', 'Class 8-B', 'Rs 12,000', '30 days'],
        ['Riya Patel', 'Class 10-A', 'Rs 6,500', '20 days'],
      ].map((d) => Card(
        color: Colors.red.shade50,
        margin: const EdgeInsets.only(bottom: 8),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.red.withOpacity(0.1),
            child: Text((d[0] as String)[0],
              style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold))),
          title: Text(d[0] as String, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          subtitle: Text(d[1] as String, style: const TextStyle(fontSize: 11)),
          trailing: Column(mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(d[2] as String, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 13)),
            Text('${d[3]} overdue', style: const TextStyle(fontSize: 10, color: Colors.grey)),
          ]),
        ),
      )),
    ]),
  );

  // ?? All Reports Tab ?????????
  Widget _allReportsTab() {
    final reports = [
      {'title': 'Student Progress Report', 'sub': 'Individual student performance', 'icon': Icons.person, 'color': 0xFF1565C0},
      {'title': 'Attendance Report', 'sub': 'Daily/Monthly attendance summary', 'icon': Icons.calendar_today, 'color': 0xFF2E7D32},
      {'title': 'Fee Collection Report', 'sub': 'Fee collected and pending', 'icon': Icons.payments, 'color': 0xFFE65100},
      {'title': 'Academic Performance', 'sub': 'Class and subject-wise results', 'icon': Icons.grade, 'color': 0xFF6A1B9A},
      {'title': 'Teacher Workload', 'sub': 'Classes assigned per teacher', 'icon': Icons.person_pin, 'color': 0xFF00838F},
      {'title': 'Hostel Occupancy', 'sub': 'Room and bed occupancy report', 'icon': Icons.hotel, 'color': 0xFF0288D1},
      {'title': 'Transport Utilization', 'sub': 'Bus routes and student count', 'icon': Icons.directions_bus, 'color': 0xFFF57F17},
      {'title': 'Library Usage', 'sub': 'Books issued and returned', 'icon': Icons.library_books, 'color': 0xFF455A64},
      {'title': 'Admission Report', 'sub': 'Applications and approvals', 'icon': Icons.how_to_reg, 'color': 0xFF7B1FA2},
      {'title': 'Staff Payroll Report', 'sub': 'Salary and deductions summary', 'icon': Icons.account_balance, 'color': 0xFFC62828},
      {'title': 'Exam Schedule Report', 'sub': 'Upcoming and completed exams', 'icon': Icons.quiz, 'color': 0xFF1B5E20},
      {'title': 'Leave Management Report', 'sub': 'Staff and student leave records', 'icon': Icons.event_busy, 'color': 0xFF4E342E},
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        // Search
        TextField(
          decoration: InputDecoration(
            hintText: 'Search reports...',
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
          itemCount: reports.length,
          itemBuilder: (context, i) {
            final r = reports[i];
            final color = Color(r['color'] as int);
            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                leading: Container(width: 44, height: 44,
                  decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                  child: Icon(r['icon'] as IconData, color: color)),
                title: Text(r['title'] as String,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                subtitle: Text(r['sub'] as String, style: const TextStyle(fontSize: 11)),
                trailing: IconButton(
                  icon: Icon(Icons.visibility, color: color, size: 22),
                  onPressed: () => context.go("/reports/" + Uri.encodeComponent(r["title"] as String))
                ),
              ),
            );
          },
        ),
      ]),
    );
  }

  Future<void> _exportPdf(BuildContext context, String title) async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Row(children: [
          SizedBox(width:18,height:18,child: CircularProgressIndicator(color:Colors.white,strokeWidth:2)),
          SizedBox(width:10), Text('Generating PDF...')]),
          backgroundColor: Colors.blue, duration: Duration(seconds: 2)));

      final pdf = pw.Document();
      pdf.addPage(pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context ctx) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Container(
              padding: const pw.EdgeInsets.all(16),
              decoration: const pw.BoxDecoration(color: PdfColor.fromInt(0xFF1565C0)),
              child: pw.Row(children: [
                pw.Expanded(child: pw.Text(title,
                  style: pw.TextStyle(color: PdfColors.white,
                    fontSize: 18, fontWeight: pw.FontWeight.bold))),
                pw.Text('Generated: ' + DateTime.now().day.toString() + '/' + DateTime.now().month.toString() + '/' + DateTime.now().year.toString(),
                  style: const pw.TextStyle(color: PdfColors.white, fontSize: 10)),
              ])),
            pw.SizedBox(height: 20),
            pw.Text('School Management System',
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 4),
            pw.Text('Academic Year: 2025-26',
              style: const pw.TextStyle(color: PdfColors.grey, fontSize: 11)),
            pw.SizedBox(height: 20),
            pw.Divider(),
            pw.SizedBox(height: 12),
            pw.Text('Report Summary',
              style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),
            pw.Table(border: pw.TableBorder.all(color: PdfColors.grey300),
              children: [
                pw.TableRow(decoration: const pw.BoxDecoration(color: PdfColor.fromInt(0xFFE3F2FD)),
                  children: ['Parameter', 'Value'].map((h) => pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text(h, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11)))).toList()),
                pw.TableRow(children: ['Total Students', '1,248'].map((v) => pw.Padding(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Text(v, style: const pw.TextStyle(fontSize: 10)))).toList()),
                pw.TableRow(children: ['Pass Rate', '94.2%'].map((v) => pw.Padding(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Text(v, style: const pw.TextStyle(fontSize: 10)))).toList()),
                pw.TableRow(children: ['Avg Score', '76.4%'].map((v) => pw.Padding(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Text(v, style: const pw.TextStyle(fontSize: 10)))).toList()),
                pw.TableRow(children: ['Attendance', '87.3%'].map((v) => pw.Padding(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Text(v, style: const pw.TextStyle(fontSize: 10)))).toList()),
              ]),
            pw.SizedBox(height: 20),
            pw.Center(child: pw.Text('--- End of Report ---',
              style: const pw.TextStyle(color: PdfColors.grey, fontSize: 10))),
          ]),
      ));

      final pdfBytes = await pdf.save();
      await Printing.sharePdf(
        bytes: pdfBytes,
        filename: title.replaceAll(' ', '_') + '.pdf',
      );
    } catch (e) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('PDF Error: ' + e.toString()), backgroundColor: Colors.red));
    }
  }

  void _showExportSnack(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Use Export PDF or Export Excel buttons'),
        backgroundColor: Colors.blue));
  }

  Widget _kpi(String label, String value, String change, IconData icon, Color color, bool isPositive) =>
    Card(child: Padding(
      padding: const EdgeInsets.all(12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Icon(icon, color: color, size: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: isPositive ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(isPositive ? Icons.trending_up : Icons.trending_down,
                size: 12, color: isPositive ? Colors.green : Colors.red),
            ])),
        ]),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
          Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
          Text(change, style: TextStyle(fontSize: 9,
            color: isPositive ? Colors.green : Colors.red)),
        ]),
      ]),
    ));

  Widget _miniStat(String label, String value, Color color) => Expanded(
    child: Card(child: Padding(
      padding: const EdgeInsets.all(10),
      child: Column(children: [
        Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: const TextStyle(fontSize: 9, color: Colors.grey), textAlign: TextAlign.center),
      ]),
    )));

  Widget _attendStat(String label, String val, Color color) => Column(children: [
    Text(val, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
    Text(label, style: const TextStyle(fontSize: 9, color: Colors.grey), textAlign: TextAlign.center),
  ]);

  Widget _bar(String label, double present, double absent) => Column(
    mainAxisAlignment: MainAxisAlignment.end, children: [
    Stack(alignment: Alignment.bottomCenter, children: [
      Container(width: 30, height: 120 * present,
        decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(4))),
      Container(width: 30, height: 120 * absent,
        decoration: BoxDecoration(color: Colors.red.withOpacity(0.5), borderRadius: BorderRadius.circular(4))),
    ]),
    const SizedBox(height: 4),
    Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
  ]);

  Widget _singleBar(String label, double value, Color color) => Column(
    mainAxisAlignment: MainAxisAlignment.end, children: [
    Container(width: 30, height: 130 * value,
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4))),
    const SizedBox(height: 4),
    Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
  ]);

  Widget _legend(String label, Color color) => Row(children: [
    Container(width: 12, height: 12, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
    const SizedBox(width: 4),
    Text(label, style: const TextStyle(fontSize: 11)),
  ]);
}


