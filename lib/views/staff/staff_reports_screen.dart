import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class StaffReportsScreen extends StatelessWidget {
  const StaffReportsScreen({super.key});

  static const _reports = [
    {'title': 'Staff Attendance Report', 'subtitle': 'Monthly attendance summary', 'icon': Icons.calendar_today, 'color': 0xFF1565C0},
    {'title': 'Salary Report', 'subtitle': 'Monthly payroll details', 'icon': Icons.payments, 'color': 0xFF2E7D32},
    {'title': 'Leave Report', 'subtitle': 'Leave taken and balance', 'icon': Icons.beach_access, 'color': 0xFFE65100},
    {'title': 'Department Report', 'subtitle': 'Department-wise staff count', 'icon': Icons.category, 'color': 0xFF6A1B9A},
    {'title': 'New Joinings Report', 'subtitle': 'Staff joined this year', 'icon': Icons.person_add, 'color': 0xFF00838F},
    {'title': 'Performance Report', 'subtitle': 'Staff performance reviews', 'icon': Icons.star, 'color': 0xFFF57F17},
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
                _quickStat('Salary Paid', '₹18.5L', Colors.orange),
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
                  trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                    IconButton(icon: Icon(Icons.visibility, color: color, size: 20), onPressed: () {}),
                    IconButton(icon: const Icon(Icons.download, color: Colors.grey, size: 20), onPressed: () {}),
                  ]),
                ),
              );
            },
          ),
        ]),
      ),
    );
  }

  Widget _quickStat(String label, String value, Color color) => Column(children: [
    Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
    Text(label, style: const TextStyle(fontSize: 9, color: Colors.grey), textAlign: TextAlign.center),
  ]);
}








