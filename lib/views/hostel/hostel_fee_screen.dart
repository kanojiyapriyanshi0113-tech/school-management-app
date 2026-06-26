// lib/views/hostel/hostel_fee_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/hostel_provider.dart';
import '../../core/theme/app_theme.dart';

class HostelFeeScreen extends StatelessWidget {
  const HostelFeeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final students = context.watch<HostelProvider>().students;
    final totalCollected = students.where((s) => s.feeStatus == 'paid').fold(0.0, (sum, s) => sum + s.monthlyFee);
    final totalPending = students.where((s) => s.feeStatus != 'paid').fold(0.0, (sum, s) => sum + s.monthlyFee);

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      body: Column(children: [
        // Summary
        Container(
          color: Colors.white,
          padding: const EdgeInsets.all(16),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            _sum('Collected', '₹${totalCollected.toStringAsFixed(0)}', Colors.green),
            _sum('Pending', '₹${totalPending.toStringAsFixed(0)}',   Colors.orange),
            _sum('Students', '${students.length}',                     Colors.blue),
          ]),
        ),
        const Divider(height: 1),
        Expanded(child: ListView.builder(
          padding: const EdgeInsets.all(14),
          itemCount: students.length,
          itemBuilder: (context, i) {
            final s = students[i];
            final feeColors = {'paid': Colors.green, 'pending': Colors.orange, 'overdue': Colors.red};
            final color = feeColors[s.feeStatus] ?? Colors.grey;
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                  child: Text(s.studentName[0],
                    style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold))),
                title: Text(s.studentName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                subtitle: Text('${s.hostelName} • Room ${s.roomNumber} • Bed ${s.bedNumber}',
                  style: const TextStyle(fontSize: 11)),
                trailing: Column(mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text('₹${s.monthlyFee.toStringAsFixed(0)}',
                    style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 14)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                    child: Text(s.feeStatus.toUpperCase(),
                      style: TextStyle(fontSize: 9, color: color, fontWeight: FontWeight.bold))),
                ]),
              ),
            );
          },
        )),
      ]),
    );
  }

  Widget _sum(String label, String val, Color color) => Column(children: [
    Text(val, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
    Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
  ]);
}