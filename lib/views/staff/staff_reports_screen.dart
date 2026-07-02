import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class StaffReportsScreen extends StatelessWidget {
  const StaffReportsScreen({super.key});

  static const _reports = [
    {'title': 'Staff Attendance Report', 'subtitle': 'Monthly attendance summary', 'icon': Icons.calendar_today, 'color': 0xFF1565C0,
      'detail': '48 staff members tracked in June 2025.\n\nAverage attendance: 89%\nFully present: 41 staff\nPartial / on leave: 7 staff\n\nDepartments with lowest attendance: Transport, Housekeeping.'},
    {'title': 'Salary Report', 'subtitle': 'Monthly payroll details', 'icon': Icons.payments, 'color': 0xFF2E7D32,
      'detail': 'Total salary paid in June 2025: Rs 18.5L\n\nTeaching staff: Rs 12.8L\nNon-teaching staff: Rs 5.7L\n\nPending disbursements: 3 staff (processed by 5th of next month).'},
    {'title': 'Leave Report', 'subtitle': 'Leave taken and balance', 'icon': Icons.beach_access, 'color': 0xFFE65100,
      'detail': '23 leaves taken across staff in June 2025.\n\nSick leave: 11\nCasual leave: 9\nOther: 3\n\nAverage leave balance remaining: 8.4 days per staff member.'},
    {'title': 'Department Report', 'subtitle': 'Department-wise staff count', 'icon': Icons.category, 'color': 0xFF6A1B9A,
      'detail': 'Teaching: 28 staff\nAdministration: 8 staff\nTransport: 6 staff\nHousekeeping: 4 staff\nLibrary: 2 staff\n\nTotal: 48 staff'},
    {'title': 'New Joinings Report', 'subtitle': 'Staff joined this year', 'icon': Icons.person_add, 'color': 0xFF00838F,
      'detail': '6 new staff joined in 2025.\n\n4 Teachers, 1 Lab Assistant, 1 Administrative staff.\n\nMost recent joining: 15 Jun 2025.'},
    {'title': 'Performance Report', 'subtitle': 'Staff performance reviews', 'icon': Icons.star, 'color': 0xFFF57F17,
      'detail': 'Annual performance reviews completed for 42 of 48 staff.\n\nExcellent: 15\nGood: 21\nNeeds Improvement: 6\n\nRemaining 6 reviews scheduled for next cycle.'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white), onPressed: () => context.go((() { final role = context.read<AuthProvider>().user?.role; return role == 'staff' ? '/dashboard/staff' : role == 'student' ? '/dashboard/student' : role == 'parent' ? '/dashboard/parent' : '/dashboard/admin'; })())),title: const Text('Staff Reports')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Quick stats
          Card(child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('June 2025 Summary', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 12),
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                _quickStat('Total Staff', '48', Colors.blue),
                _quickStat('Avg Attendance', '89%', Colors.green),
                _quickStat('Salary Paid', '??Rs \18.5L', Colors.orange),
                _quickStat('Leaves', '23', Colors.purple),
              ]),
            ]),
          )),
          const SizedBox(height: 16),
          const Text('Generate Reports', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _reports.length,
            itemBuilder: (context, i) {
              final r = _reports[i];
              final color = Color(r['color'] as int);
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                    child: Icon(r['icon'] as IconData, color: color),
                  ),
                  title: Text(r['title'] as String, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  subtitle: Text(r['subtitle'] as String, style: const TextStyle(fontSize: 11)),
                  trailing: IconButton(
                    icon: Icon(Icons.visibility, color: color, size: 20),
                    tooltip: 'View details',
                    onPressed: () => _showReportDetail(context, r, color)),
                ),
              );
            },
          ),
        ]),
      ),
    );
  }

  void _showReportDetail(BuildContext context, Map<String, dynamic> r, Color color) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(children: [
          Container(width: 40, height: 40,
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(r['icon'] as IconData, color: color)),
          const SizedBox(width: 12),
          Expanded(child: Text(r['title'] as String,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold))),
        ]),
        content: SingleChildScrollView(
          child: Text(r['detail'] as String? ?? 'No details available.',
            style: const TextStyle(fontSize: 13, height: 1.5))),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
        ],
      ),
    );
  }

  Widget _quickStat(String label, String value, Color color) => Column(children: [
    Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
    Text(label, style: const TextStyle(fontSize: 9, color: Colors.grey), textAlign: TextAlign.center),
  ]);
}








