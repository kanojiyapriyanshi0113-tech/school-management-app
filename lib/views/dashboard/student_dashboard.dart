import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/language_provider.dart';

class StudentDashboard extends StatelessWidget {
  const StudentDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.watch<LanguageProvider>().t('student_dashboard')),
        actions: [
          IconButton(icon: const Icon(Icons.notifications_outlined), onPressed: () {}),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: CircleAvatar(
              backgroundColor: Colors.white24,
              child: Text(user?.name.substring(0, 1) ?? 'S',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
      drawer: _drawer(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Greeting
          Text('Hello, ${user?.name ?? 'Student'} 👋',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const Text('Student Portal', style: TextStyle(color: Colors.grey, fontSize: 13)),
          const SizedBox(height: 16),

          // Attendance card
          Card(child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text('My Attendance',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8)),
                  child: const Text('89.3%',
                    style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12))),
              ]),
              const SizedBox(height: 12),
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                _stat('42', 'Present', Colors.green),
                _stat('3', 'Absent',  Colors.red),
                _stat('2', 'Late',    Colors.orange),
                _stat('47', 'Total',   Colors.blue),
              ]),
              const SizedBox(height: 8),
              ClipRRect(borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(value: 42/47,
                  color: Colors.green, backgroundColor: Colors.red.withOpacity(0.1), minHeight: 8)),
            ]),
          )),
          const SizedBox(height: 12),

          // Quick Access
          Text(context.watch<LanguageProvider>().t('quick_actions'),
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          GridView.count(
            shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 3, crossAxisSpacing: 10, mainAxisSpacing: 10,
            childAspectRatio: 1.1,
            children: [
              _card(context, Icons.quiz, 'My Results',   const Color(0xFF6A1B9A), '/exams/results'),
              _card(context, Icons.payment, 'My Fees',      const Color(0xFFE65100), '/fees'),
              _card(context, Icons.schedule, 'Timetable',    const Color(0xFF00838F), '/timetable'),
              _card(context, Icons.announcement, 'Notices',      const Color(0xFF1565C0), '/notices'),
              _card(context, Icons.library_books, 'Library',      const Color(0xFF2E7D32), '/library'),
              _card(context, Icons.directions_bus, 'Transport',    const Color(0xFF0288D1), '/transport'),
              _card(context, Icons.hotel, 'My Hostel',    const Color(0xFF4527A0), '/student/hostel'),
              _card(context, Icons.assignment, 'Homework',     const Color(0xFFF57F17), '/student/homework'),
              _card(context, Icons.badge, 'My ID Card',   const Color(0xFF00695C), '/student/idcard'),
              _card(context, Icons.bar_chart, 'My Progress',  const Color(0xFF1565C0), '/student/progress'),
            ],
          ),
          const SizedBox(height: 16),

          // Pending Homework
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Pending Homework',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            TextButton(onPressed: () => context.go('/student/homework'),
              child: const Text('View All')),
          ]),
          ...[
            ['Math Assignment Ch.5', 'Due: 20 Jun 2025', Colors.red],
            ['English Essay', 'Due: 22 Jun 2025', Colors.orange],
            ['Science Project', 'Due: 25 Jun 2025', Colors.green],
          ].map((h) => Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: Container(width: 40, height: 40,
                decoration: BoxDecoration(
                  color: (h[2] as Color).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10)),
                child: Icon(Icons.assignment, color: h[2] as Color)),
              title: Text(h[0] as String,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              subtitle: Text(h[1] as String,
                style: TextStyle(fontSize: 11, color: h[2] as Color)),
              trailing: const Icon(Icons.chevron_right, color: Colors.grey),
            ),
          )),
          const SizedBox(height: 16),

          // Upcoming Exams
          const Text('Upcoming Exams',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Card(child: Column(children: [
            _examItem('Mathematics', 'Mid-Term Exam', '20 Jun 2025', Colors.blue),
            _examItem('Science', 'Mid-Term Exam', '21 Jun 2025', Colors.green),
            _examItem('English', 'Mid-Term Exam', '22 Jun 2025', Colors.orange),
          ])),
          const SizedBox(height: 16),

          // Leave Application
          Card(child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(children: [
              Container(width: 44, height: 44,
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.event_busy, color: Colors.purple)),
              const SizedBox(width: 12),
              const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Leave Application', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Text('Apply for leave from school', style: TextStyle(fontSize: 12, color: Colors.grey)),
              ])),
              ElevatedButton(
                onPressed: () => context.go('/student/leave'),
                child: const Text('Apply'),
              ),
            ]),
          )),
        ]),
      ),
    );
  }

  Widget _drawer(BuildContext context) => Drawer(
    child: Column(children: [
      DrawerHeader(
        decoration: const BoxDecoration(color: AppTheme.primaryColor),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end, children: [
          const CircleAvatar(backgroundColor: Colors.white24,
            child: Icon(Icons.person, color: Colors.white)),
          const SizedBox(height: 8),
          const Text('Student Portal',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          const Text('Class 10-A ??? Roll: R001',
            style: TextStyle(color: Colors.white70, fontSize: 12)),
        ]),
      ),
      _dItem(context, Icons.quiz, 'My Results', '/exams/results'),
      _dItem(context, Icons.payment, 'My Fees', '/fees'),
      _dItem(context, Icons.schedule, 'Timetable', '/timetable'),
      _dItem(context, Icons.announcement, 'Notices', '/notices'),
      _dItem(context, Icons.library_books, 'Library', '/library'),
      _dItem(context, Icons.assignment, 'Homework', '/student/homework'),
      _dItem(context, Icons.hotel, 'My Hostel', '/student/hostel'),
      _dItem(context, Icons.badge, 'ID Card', '/student/idcard'),
      _dItem(context, Icons.event_busy, 'Leave', '/student/leave'),
      _dItem(context, Icons.language, 'Language / भाषा', '/settings'),
      const Divider(),
      ListTile(
        leading: const Icon(Icons.logout, color: Colors.red),
        title: const Text('Logout', style: TextStyle(color: Colors.red)),
        onTap: () async {
          await context.read<AuthProvider>().logout();
          if (context.mounted) context.go('/login');
        },
      ),
    ]),
  );

  Widget _dItem(BuildContext context, IconData icon, String label, String route) =>
    ListTile(
      leading: Icon(icon, color: AppTheme.primaryColor),
      title: Text(label),
      onTap: () { Navigator.pop(context); context.go(route); },
    );

  Widget _card(BuildContext context, IconData icon, String label, Color color, String route) =>
    GestureDetector(
      onTap: () => context.go(route),
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.2))),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, color: color, size: 26),
          const SizedBox(height: 6),
          Text(label, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w600),
            textAlign: TextAlign.center),
        ]),
      ),
    );

  Widget _stat(String value, String label, Color color) => Column(children: [
    Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
    Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
  ]);

  Widget _examItem(String subject, String exam, String date, Color color) => ListTile(
    dense: true,
    leading: CircleAvatar(radius: 16,
      backgroundColor: color.withOpacity(0.1),
      child: Icon(Icons.quiz, size: 16, color: color)),
    title: Text(subject, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
    subtitle: Text(exam, style: const TextStyle(fontSize: 11)),
    trailing: Text(date, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w500)),
  );
}