import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/language_provider.dart';

class ResultScreen extends StatelessWidget {
  // When provided, only this student's result is shown (class/student select flow).
  final String? studentName;
  final String? studentRoll;
  final String? className;

  const ResultScreen({super.key, this.studentName, this.studentRoll, this.className});

  static const _results = [
    {'name': 'Priya Singh', 'roll': 'R002', 'total': 487, 'max': 500, 'percent': '97.4%', 'grade': 'A+', 'color': 0xFF2E7D32},
    {'name': 'Sneha Patel', 'roll': 'R004', 'total': 465, 'max': 500, 'percent': '93.0%', 'grade': 'A+', 'color': 0xFF1565C0},
    {'name': 'Rahul Kumar', 'roll': 'R001', 'total': 432, 'max': 500, 'percent': '86.4%', 'grade': 'A', 'color': 0xFF0288D1},
    {'name': 'Anita Gupta', 'roll': 'R006', 'total': 410, 'max': 500, 'percent': '82.0%', 'grade': 'A', 'color': 0xFF00838F},
    {'name': 'Vijay Verma', 'roll': 'R005', 'total': 375, 'max': 500, 'percent': '75.0%', 'grade': 'B+', 'color': 0xFFE65100},
    {'name': 'Amit Sharma', 'roll': 'R003', 'total': 340, 'max': 500, 'percent': '68.0%', 'grade': 'B', 'color': 0xFF9E9E9E},
  ];

  @override
  Widget build(BuildContext context) {
    // Single-student mode: filter to just the selected student's result.
    final isSingleStudent = studentRoll != null;
    final filteredResults = isSingleStudent
      ? _results.where((r) => r['roll'] == studentRoll).toList()
      : _results;

    return Scaffold(
      appBar: AppBar(
        title: Text(isSingleStudent
          ? (studentName ?? context.watch<LanguageProvider>().t('results'))
          : context.watch<LanguageProvider>().t('results')),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () {
            if (isSingleStudent) { context.pop(); return; }
            final r = context.read<AuthProvider>().user?.role;
            context.go(r == 'student' ? '/dashboard/student'
              : r == 'staff' ? '/dashboard/staff'
              : '/dashboard/admin');
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Header
          Text(isSingleStudent
              ? 'Mid-Term Exam 2025 - ${className ?? ''}'
              : 'Mid-Term Exam 2025 - Class 10-A',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const Text('Total Marks: 500',
            style: TextStyle(color: Colors.grey, fontSize: 13)),
          const SizedBox(height: 16),

          if (!isSingleStudent) ...[
            // Summary cards (only shown in full class view)
            Row(children: [
              _sumCard('84.8%', 'Class Avg', Colors.blue),
              const SizedBox(width: 10),
              _sumCard('97.4%', 'Highest', Colors.green),
              const SizedBox(width: 10),
              _sumCard('100%', 'Pass Rate', Colors.teal),
            ]),
            const SizedBox(height: 16),
          ],

          if (isSingleStudent && filteredResults.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Center(child: Column(children: [
                Icon(Icons.assignment_late_outlined, size: 56, color: Colors.grey.shade300),
                const SizedBox(height: 12),
                Text('No exam result published yet for ${studentName ?? 'this student'}',
                  style: const TextStyle(color: Colors.grey), textAlign: TextAlign.center),
              ])),
            ),

          // Results list
          ...filteredResults.asMap().entries.map((entry) {
            final i = entry.key;
            final r = entry.value;
            final color = Color(r['color'] as int);
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(children: [
                  // Rank badge
                  Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.15),
                      shape: BoxShape.circle),
                    child: Center(child: Text('${i + 1}',
                      style: TextStyle(fontWeight: FontWeight.bold,
                        color: color, fontSize: 14)))),
                  const SizedBox(width: 12),
                  // Name and roll
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(r['name'] as String,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    Text('${r['roll']}  Total: ${r['total']}/${r['max']}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ])),
                  // Percent and grade
                  Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    Text(r['percent'] as String,
                      style: TextStyle(fontWeight: FontWeight.bold,
                        color: color, fontSize: 15)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6)),
                      child: Text(r['grade'] as String,
                        style: TextStyle(fontSize: 11, color: color,
                          fontWeight: FontWeight.bold))),
                  ]),
                ]),
              ),
            );
          }),
        ]),
      ),
    );
  }

  Widget _sumCard(String value, String label, Color color) => Expanded(
    child: Card(child: Padding(
      padding: const EdgeInsets.all(12),
      child: Column(children: [
        Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ]),
    )),
  );
}

