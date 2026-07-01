import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/language_provider.dart';

class AttendanceScreen extends StatelessWidget {
  const AttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final data = [
      {'class': 'Class 10-A', 'present': 38, 'absent': 4, 'total': 42},
      {'class': 'Class 10-B', 'present': 35, 'absent': 7, 'total': 42},
      {'class': 'Class 9-A', 'present': 40, 'absent': 2, 'total': 42},
      {'class': 'Class 9-B', 'present': 36, 'absent': 6, 'total': 42},
      {'class': 'Class 8-A', 'present': 39, 'absent': 3, 'total': 42},
    ];

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white), onPressed: () => context.go((() { final role = context.read<AuthProvider>().user?.role; return role == 'staff' ? '/dashboard/staff' : role == 'student' ? '/dashboard/student' : role == 'parent' ? '/dashboard/parent' : '/dashboard/admin'; })())),title: Text(context.watch<LanguageProvider>().t('attendance'))),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/attendance/mark'),
        icon: const Icon(Icons.edit),
        label: Text(context.watch<LanguageProvider>().t('mark_attendance')),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(children: [
            _summary('Total Classes', '5', Colors.blue),
            const SizedBox(width: 10),
            _summary('Avg Present', '94%', Colors.green),
            const SizedBox(width: 10),
            _summary('Avg Absent', '6%', Colors.red),
          ]),
          const SizedBox(height: 20),
          const Text('Today\'s Class-wise Report', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          ...data.map((d) {
            final pct = ((d['present'] as int) / (d['total'] as int) * 100).round();
            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text(d['class'] as String, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    Text('$pct%', style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 14,
                      color: pct >= 90 ? Colors.green : pct >= 75 ? Colors.orange : Colors.red)),
                  ]),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: (d['present'] as int) / (d['total'] as int),
                    backgroundColor: Colors.red.withOpacity(0.2),
                    color: pct >= 90 ? Colors.green : Colors.orange,
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(3),
                  ),
                  const SizedBox(height: 6),
                  Row(children: [
                    Text('Present: ${d['present']}', style: const TextStyle(fontSize: 12, color: Colors.green)),
                    const SizedBox(width: 16),
                    Text('Absent: ${d['absent']}', style: const TextStyle(fontSize: 12, color: Colors.red)),
                    const SizedBox(width: 16),
                    Text('Total: ${d['total']}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ]),
                ]),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _summary(String label, String value, Color color) => Expanded(
    child: Card(child: Padding(
      padding: const EdgeInsets.all(12),
      child: Column(children: [
        Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey), textAlign: TextAlign.center),
      ]),
    )),
  );
}







