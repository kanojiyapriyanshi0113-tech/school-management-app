// lib/views/hostel/hostel_reports_screen.dart
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class HostelReportsScreen extends StatelessWidget {
  const HostelReportsScreen({super.key});

  static const _reports = [
    {'title': 'Occupancy Report', 'sub': 'Room and bed occupancy summary', 'icon': Icons.apartment, 'color': 0xFF1565C0},
    {'title': 'Student Allocation', 'sub': 'List of students with room details', 'icon': Icons.people, 'color': 0xFF2E7D32},
    {'title': 'Fee Collection Report', 'sub': 'Monthly fee payment summary', 'icon': Icons.payments, 'color': 0xFFE65100},
    {'title': 'Pending Fees Report', 'sub': 'Students with due fees', 'icon': Icons.warning, 'color': 0xFFC62828},
    {'title': 'Complaint Report', 'sub': 'All complaints and status', 'icon': Icons.report, 'color': 0xFF6A1B9A},
    {'title': 'Maintenance Report', 'sub': 'Room maintenance history', 'icon': Icons.build, 'color': 0xFF00838F},
    {'title': 'Attendance Report', 'sub': 'Monthly hostel attendance', 'icon': Icons.calendar_today, 'color': 0xFF0288D1},
    {'title': 'Visitor Log Report', 'sub': 'All visitor entries and exits', 'icon': Icons.people_outline, 'color': 0xFFF57F17},
    {'title': 'Deposit Report', 'sub': 'Security deposits collected', 'icon': Icons.account_balance,'color': 0xFF455A64},
    {'title': 'Vacancy Report', 'sub': 'Available rooms and beds', 'icon': Icons.meeting_room, 'color': 0xFF7B1FA2},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          // Quick stats
          Card(child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('June 2025 Summary', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 12),
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                _qs('Occupancy', '82%',    Colors.blue),
                _qs('Fee Collected', 'Rs \15K', Colors.green),
                _qs('Complaints', '3',     Colors.orange),
                _qs('Vacancies', '12',     Colors.purple),
              ]),
            ]),
          )),
          const SizedBox(height: 16),
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
                    child: Icon(r['icon'] as IconData, color: color)),
                  title: Text(r['title'] as String, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  subtitle: Text(r['sub'] as String, style: const TextStyle(fontSize: 11)),
                  trailing: IconButton(
                    icon: Icon(Icons.visibility, color: color, size: 22),
                    onPressed: () => _showDetail(context, r['title'] as String,
                      r['sub'] as String, color)),
                ),
              );
            },
          ),
        ]),
      ),
    );
  }

  void _showDetail(BuildContext ctx, String title, String sub, Color color) {
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        expand: false,
        builder: (_, sc) => Column(children: [
          Container(
            margin: const EdgeInsets.only(top: 10),
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(children: [
              Container(width: 40, height: 40,
                decoration: BoxDecoration(color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10)),
                child: Icon(Icons.assessment, color: color)),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text(sub, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ])),
            ])),
          const Divider(height: 1),
          Expanded(child: ListView(
            controller: sc,
            padding: const EdgeInsets.all(16),
            children: [
              _detailCard('Summary', [
                ['Total Records', '24'],
                ['This Month', '18'],
                ['Last Month', '22'],
                ['Pending Actions', '3'],
              ], color),
              const SizedBox(height: 12),
              _detailCard('Details', [
                ['Generated Date', 'July 2025'],
                ['Period', 'June 2025'],
                ['Status', 'Active'],
                ['Last Updated', 'Today'],
              ], color),
            ],
          )),
        ]),
      ));
  }

  Widget _detailCard(String heading, List<List<String>> rows, Color color) =>
    Card(child: Padding(
      padding: const EdgeInsets.all(14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(heading, style: TextStyle(fontWeight: FontWeight.bold,
          fontSize: 13, color: color)),
        const Divider(height: 16),
        ...rows.map((r) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(r[0], style: const TextStyle(color: Colors.grey, fontSize: 12)),
              Text(r[1], style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
            ]))),
      ])));

  Widget _qs(String label, String val, Color color) => Column(children: [
    Text(val, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: color)),
    Text(label, style: const TextStyle(fontSize: 9, color: Colors.grey), textAlign: TextAlign.center),
  ]);
}