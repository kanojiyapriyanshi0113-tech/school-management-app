import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/language_provider.dart';

class TeacherDashboard extends StatelessWidget {
  const TeacherDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Teacher Portal'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => context.go('/dashboard/staff'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Hello, ${user?.name ?? 'Teacher'} ',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const Text('Teacher Portal', style: TextStyle(color: Colors.grey, fontSize: 13)),
          const SizedBox(height: 16),
          Card(child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text("Today's Classes",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 10),
              ...[
                ['8:00 AM', 'Mathematics', 'Class 10-A'],
                ['9:30 AM', 'Mathematics', 'Class 9-B'],
                ['11:00 AM', 'Mathematics', 'Class 10-B'],
                ['2:00 PM', 'Mathematics', 'Class 8-A'],
              ].map((s) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(children: [
                  SizedBox(width: 70, child: Text(s[0],
                    style: const TextStyle(fontSize: 11, color: Colors.grey))),
                  Container(width: 4, height: 36,
                    decoration: BoxDecoration(color: AppTheme.primaryColor,
                      borderRadius: BorderRadius.circular(2))),
                  const SizedBox(width: 10),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(s[1], style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    Text(s[2], style: const TextStyle(fontSize: 11, color: Colors.grey)),
                  ])),
                  ElevatedButton(
                    onPressed: () => context.go('/teacher/attendance'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      textStyle: const TextStyle(fontSize: 11)),
                    child: const Text('Mark'),
                  ),
                ]),
              )),
            ]),
          )),
          const SizedBox(height: 16),
          Row(children: [
            _stat('Classes', '4',   Icons.class_,         Colors.blue),
            const SizedBox(width: 10),
            _stat('Students','120', Icons.people,          Colors.green),
            const SizedBox(width: 10),
            _stat('Pending', '3',   Icons.assignment_late, Colors.orange),
          ]),
          const SizedBox(height: 16),
          Text(context.watch<LanguageProvider>().t('quick_actions'),
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          GridView.count(
            shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 3, crossAxisSpacing: 10, mainAxisSpacing: 10,
            childAspectRatio: 1.1,
            children: [
              _action(context, Icons.how_to_reg, 'Attendance', Colors.blue, '/teacher/attendance'),
              _action(context, Icons.assignment, 'Homework',   Colors.green, '/teacher/homework'),
              _action(context, Icons.grade, 'Marks',      Colors.orange, '/teacher/marks'),
              _action(context, Icons.schedule, 'Timetable',  Colors.purple, '/timetable'),
              _action(context, Icons.announcement,'Notices',    Colors.red, '/notices'),
              _action(context, Icons.bar_chart, 'Reports',    Colors.teal, '/staff/reports'),
            ],
          ),
        ]),
      ),
    );
  }

  Widget _stat(String label, String value, IconData icon, Color color) =>
    Expanded(child: Card(child: Padding(
      padding: const EdgeInsets.all(10),
      child: Column(children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: const TextStyle(fontSize: 9, color: Colors.grey)),
      ]),
    )));

  Widget _action(BuildContext context, IconData icon, String label, Color color, String route) =>
    GestureDetector(
      onTap: () => context.go(route),
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.2))),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 6),
          Text(label, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w600),
            textAlign: TextAlign.center),
        ]),
      ),
    );
}


