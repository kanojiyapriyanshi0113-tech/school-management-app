import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/language_provider.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  static const _stats = [
    {'label': 'total_students', 'value': '1,248', 'icon': Icons.people, 'color': Color(0xFF1565C0)},
    {'label': 'total_staff', 'value': '86', 'icon': Icons.person, 'color': Color(0xFF2E7D32)},
    {'label': 'present_today', 'value': '1,104', 'icon': Icons.check_circle, 'color': Color(0xFF00838F)},
    {'label': 'fee_collected', 'value': 'Rs 4.2L','icon': Icons.payment, 'color': Color(0xFFE65100)},
    {'label': 'exams_scheduled','value': '12', 'icon': Icons.quiz, 'color': Color(0xFF6A1B9A)},
    {'label': 'pending_fees', 'value': 'Rs 1.1L','icon': Icons.warning_amber, 'color': Color(0xFFC62828)},
  ];

  static const _navItems = [
    {'icon': Icons.dashboard, 'label': 'Dashboard', 'route': '/dashboard/admin'},
    {'icon': Icons.class_, 'label': 'Classes', 'route': '/classes'},
    {'icon': Icons.how_to_reg, 'label': 'Admissions', 'route': '/admission'},
    {'icon': Icons.people, 'label': 'Students', 'route': '/students'},
    {'icon': Icons.person, 'label': 'Staff', 'route': '/staff/list'},
    {'icon': Icons.calendar_today, 'label': 'Attendance', 'route': '/attendance'},
    {'icon': Icons.payment, 'label': 'Fees', 'route': '/fees'},
    {'icon': Icons.quiz, 'label': 'Exams', 'route': '/exams'},
    {'icon': Icons.schedule, 'label': 'Timetable', 'route': '/timetable'},
    {'icon': Icons.announcement, 'label': 'Notices', 'route': '/notices'},
    {'icon': Icons.library_books, 'label': 'Library', 'route': '/library'},
    {'icon': Icons.directions_bus, 'label': 'Transport', 'route': '/transport'},
    {'icon': Icons.hotel, 'label': 'Hostel', 'route': '/hostel'},
    {'icon': Icons.bar_chart, 'label': 'Reports', 'route': '/reports'},
  ];

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final wide = MediaQuery.of(context).size.width > 700;

    return Scaffold(
      appBar: AppBar(
        title: Text('School Management System'),
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            tooltip: 'Language',
            onPressed: () => context.go('/settings')),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => _showNotifications(context)),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () => _showProfile(context, user),
              child: CircleAvatar(
                backgroundColor: Colors.white24,
                child: Text(user?.name.substring(0, 1) ?? 'A',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ],
      ),
      drawer: wide ? null : _drawer(context),
      body: wide
        ? Row(children: [_sideNav(context), Expanded(child: _body(context, user))])
        : _body(context, user),
    );
  }

  Widget _sideNav(BuildContext context) => Container(
    width: 200, color: const Color(0xFF0D47A1),
    child: Column(children: [
      const SizedBox(height: 20),
      const CircleAvatar(radius: 28, backgroundColor: Colors.white24,
        child: Icon(Icons.school, color: Colors.white, size: 28)),
      const SizedBox(height: 6),
      const Text('SMS Admin',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
      const SizedBox(height: 16),
      Expanded(child: ListView(children: _navItems.map((item) => ListTile(
        dense: true,
        leading: Icon(item['icon'] as IconData, color: Colors.white70, size: 18),
        title: Text(item['label'] as String,
          style: const TextStyle(color: Colors.white70, fontSize: 12)),
        onTap: () => context.go(item['route'] as String),
      )).toList())),
      ListTile(
        dense: true,
        leading: const Icon(Icons.logout, color: Colors.white60, size: 18),
        title: Text(context.watch<LanguageProvider>().t('logout'), style: TextStyle(color: Colors.white70, fontSize: 12)),
        onTap: () async {
          await context.read<AuthProvider>().logout();
          if (context.mounted) context.go('/login');
        },
      ),
      const SizedBox(height: 12),
    ]),
  );

  void _showNotifications(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        expand: false,
        builder: (_, sc) => Column(children: [
          Container(margin: const EdgeInsets.only(top: 10),
            width: 40, height: 4,
            decoration: BoxDecoration(color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2))),
          const Padding(
            padding: EdgeInsets.all(16),
            child: Row(children: [
              Icon(Icons.notifications, color: Colors.blue),
              SizedBox(width: 8),
              Text('Notifications', style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold)),
            ])),
          const Divider(height: 1),
          Expanded(child: ListView(controller: sc, children: [
            _notifTile(Icons.person_add, 'New Admission',
              'Rahul Kumar admitted to Class 10-A', '10 min ago', Colors.blue),
            _notifTile(Icons.payment, 'Fee Received',
              'Fee of Rs 12,500 received from Priya Singh', '25 min ago', Colors.green),
            _notifTile(Icons.check_circle, 'Attendance Marked',
              'Attendance marked for Class 9-B', '1 hr ago', Colors.teal),
            _notifTile(Icons.campaign, 'Notice Posted',
              'Annual Sports Day on 20 July', '2 hrs ago', Colors.orange),
            _notifTile(Icons.warning, 'Fee Overdue',
              '3 students have overdue fees', '3 hrs ago', Colors.red),
            _notifTile(Icons.event, 'Exam Scheduled',
              'Mid-term exams scheduled for July 22', '5 hrs ago', Colors.purple),
            _notifTile(Icons.library_books, 'Library Alert',
              '5 books overdue for return', '1 day ago', Colors.brown),
          ])),
        ]),
      ),
    );
  }

  Widget _notifTile(IconData icon, String title, String sub, String time, Color color) =>
    ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withOpacity(0.1),
        child: Icon(icon, color: color, size: 20)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
      subtitle: Text(sub, style: const TextStyle(fontSize: 11)),
      trailing: Text(time, style: const TextStyle(fontSize: 10, color: Colors.grey)),
    );

  void _showProfile(BuildContext context, dynamic user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 40, height: 4,
            decoration: BoxDecoration(color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 20),
          CircleAvatar(radius: 40,
            backgroundColor: AppTheme.primaryColor.withOpacity(0.15),
            child: Text(user?.name?.substring(0,1) ?? 'A',
              style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor))),
          const SizedBox(height: 12),
          Text(user?.name ?? 'Admin',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Text(user?.email ?? 'admin@school.com',
            style: const TextStyle(color: Colors.grey, fontSize: 13)),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(20)),
            child: const Text('Administrator',
              style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 12))),
          const SizedBox(height: 20),
          const Divider(),
          ListTile(leading: const Icon(Icons.logout, color: Colors.red),
            title: Text(context.watch<LanguageProvider>().t('logout'), style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pop(context);
              context.read<AuthProvider>().logout();
              context.go('/login');
            }),
          const SizedBox(height: 12),
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
            child: Icon(Icons.school, color: Colors.white)),
          const SizedBox(height: 8),
          const Text('School Management',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          Text('admin@school.com',
            style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12)),
        ]),
      ),
      Expanded(child: ListView(children: _navItems.map((item) => ListTile(
        leading: Icon(item['icon'] as IconData, color: AppTheme.primaryColor),
        title: Text(item['label'] as String),
        onTap: () { Navigator.pop(context); context.go(item['route'] as String); },
      )).toList())),
      ListTile(
        leading: const Icon(Icons.language, color: AppTheme.primaryColor),
        title: const Text('Language / भाषा / मराठी'),
        onTap: () { Navigator.pop(context); context.go('/settings'); }),
      const Divider(),
      ListTile(
        leading: const Icon(Icons.logout, color: Colors.red),
        title: Text(context.watch<LanguageProvider>().t('logout'), style: TextStyle(color: Colors.red)),
        onTap: () async {
          await context.read<AuthProvider>().logout();
          if (context.mounted) context.go('/login');
        },
      ),
    ]),
  );

  Widget _body(BuildContext context, UserModel? user) {
    final hour = DateTime.now().hour;
    final greeting = hour < 12 ? 'Good Morning' : hour < 17 ? 'Good Afternoon' : 'Good Evening';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('$greeting, ${user?.name ?? 'Admin'} ',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const Text("Here's what's happening today",
          style: TextStyle(color: Colors.grey, fontSize: 13)),
        const SizedBox(height: 20),
        Text('Overview', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
        const SizedBox(height: 10),
        GridView.builder(
          shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 200, mainAxisExtent: 110,
            crossAxisSpacing: 10, mainAxisSpacing: 10),
          itemCount: _stats.length,
          itemBuilder: (context, i) {
            final s = _stats[i];
            final color = s['color'] as Color;
            return Card(child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Container(padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8)),
                  child: Icon(s['icon'] as IconData, color: color, size: 18)),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(s['value'] as String,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
                  Text(context.watch<LanguageProvider>().t(s['label'] as String),
                    style: const TextStyle(fontSize: 10, color: Colors.grey)),
                ]),
              ]),
            ));
          },
        ),
        const SizedBox(height: 20),
        Text('Quick Actions', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
        const SizedBox(height: 10),
        Row(children: [
          _qa(context, Icons.person_add, 'Add Student',  AppTheme.primaryColor, '/students/add'),
          const SizedBox(width: 10),
          _qa(context, Icons.how_to_reg, 'Admissions',   const Color(0xFF00838F), '/admission'),
          const SizedBox(width: 10),
          _qa(context, Icons.class_, 'Classes',      const Color(0xFF6A1B9A), '/classes'),
          const SizedBox(width: 10),
          _qa(context, Icons.payment, 'Collect Fee',  const Color(0xFFE65100), '/fees/create'),
        ]),
        const SizedBox(height: 20),
        Text('Recent Activity', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
        const SizedBox(height: 10),
        Card(child: Column(children: [
          _act(Icons.person_add, 'New student Rahul Kumar admitted to Class 10-A', '10 min ago'),
          _act(Icons.payment, 'Fee received from Priya Singh - Rs 12,500', '25 min ago'),
          _act(Icons.check_circle,'Attendance marked for Class 9-B', '1 hour ago'),
          _act(Icons.announcement,'Notice: Annual Sports Day on 20 July', '2 hours ago'),
        ])),
      ]),
    );
  }

  Widget _qa(BuildContext context, IconData icon, String label, Color color, String route) =>
    Expanded(child: GestureDetector(
      onTap: () => context.go(route),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w600),
            textAlign: TextAlign.center),
        ]),
      ),
    ));

  Widget _act(IconData icon, String text, String time) => ListTile(
    dense: true,
    leading: CircleAvatar(radius: 16,
      backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
      child: Icon(icon, color: AppTheme.primaryColor, size: 16)),
    title: Text(text, style: const TextStyle(fontSize: 12)),
    subtitle: Text(time, style: const TextStyle(fontSize: 10, color: Colors.grey)),
  );
}



