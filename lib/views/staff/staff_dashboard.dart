import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/staff_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/language_provider.dart';

class StaffDashboard extends StatefulWidget {
  const StaffDashboard({super.key});
  @override
  State<StaffDashboard> createState() => _StaffDashboardState();
}

class _StaffDashboardState extends State<StaffDashboard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StaffProvider>().fetchStaff();
    });
  }

  // Add Staff NAHI hai ? sirf Admin ke paas
  static const _navItems = [
    {'icon': Icons.dashboard, 'label': 'Dashboard', 'route': '/staff/dashboard'},
    {'icon': Icons.school, 'label': 'Teacher Portal', 'route': '/teacher/dashboard'},
    {'icon': Icons.people, 'label': 'Staff List', 'route': '/staff/list'},
    {'icon': Icons.calendar_today, 'label': 'Attendance', 'route': '/staff/attendance'},
    {'icon': Icons.beach_access, 'label': 'Leave', 'route': '/staff/leave'},
    {'icon': Icons.payments, 'label': 'Salary', 'route': '/staff/salary'},
    {'icon': Icons.schedule, 'label': 'Timetable', 'route': '/staff/timetable'},
    {'icon': Icons.bar_chart, 'label': 'Reports', 'route': '/staff/reports'},
    {'icon': Icons.local_library, 'label': 'Library', 'route': '/library'},
  ];

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final staff = context.watch<StaffProvider>();
    final wide = MediaQuery.of(context).size.width > 700;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.watch<LanguageProvider>().t('staff')),
        actions: [
          Stack(children: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              onPressed: () {},
            ),
            if (staff.pendingLeaves.isNotEmpty)
              Positioned(right: 8, top: 8, child: Container(
                width: 16, height: 16,
                decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                child: Center(child: Text('${staff.pendingLeaves.length}',
                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold))),
              )),
          ]),
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
      drawer: wide ? null : _drawer(context),
      body: wide
        ? Row(children: [_sideNav(context), Expanded(child: _body(context, staff))])
        : _body(context, staff),
    );
  }

  Widget _sideNav(BuildContext context) => Container(
    width: 200, color: const Color(0xFF0D47A1),
    child: Column(children: [
      const SizedBox(height: 20),
      const CircleAvatar(radius: 28, backgroundColor: Colors.white24,
        child: Icon(Icons.people, color: Colors.white, size: 28)),
      const SizedBox(height: 6),
      const Text('Staff Portal',
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

  Widget _drawer(BuildContext context) => Drawer(
    child: Column(children: [
      DrawerHeader(
        decoration: const BoxDecoration(color: AppTheme.primaryColor),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end, children: [
          const CircleAvatar(backgroundColor: Colors.white24,
            child: Icon(Icons.people, color: Colors.white)),
          const SizedBox(height: 8),
          const Text('Staff Management',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ]),
      ),
      Expanded(child: ListView(children: _navItems.map((item) => ListTile(
        leading: Icon(item['icon'] as IconData, color: AppTheme.primaryColor),
        title: Text(item['label'] as String),
        onTap: () { Navigator.pop(context); context.go(item['route'] as String); },
      )).toList())),
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

  Widget _body(BuildContext context, StaffProvider staff) {
    if (staff.isLoading) return const Center(child: CircularProgressIndicator());
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Staff Overview',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        const Text('Today\'s summary',
          style: TextStyle(color: Colors.grey, fontSize: 13)),
        const SizedBox(height: 16),

        // Stats
        GridView.count(
          shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1.6,
          children: [
            _statCard('Total Staff', '${staff.totalStaff}',    Icons.people,      const Color(0xFF1565C0)),
            _statCard('Present Today', '${staff.presentToday}',  Icons.check_circle, const Color(0xFF2E7D32)),
            _statCard('Absent Today', '${staff.absentToday}',   Icons.cancel,       const Color(0xFFC62828)),
            _statCard('New Joinings', '${staff.newJoinings}',   Icons.person_add,   const Color(0xFFE65100)),
          ],
        ),
        const SizedBox(height: 20),

        // Pending leaves
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('Pending Leave Requests',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
          TextButton(onPressed: () => context.go('/staff/leave'), child: const Text('View All')),
        ]),
        const SizedBox(height: 8),
        if (staff.pendingLeaves.isEmpty)
          const Card(child: Padding(padding: EdgeInsets.all(16),
            child: Center(child: Text('No pending leave requests',
              style: TextStyle(color: Colors.grey)))))
        else
          ...staff.pendingLeaves.take(3).map((leave) => Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.orange.withOpacity(0.1),
                child: const Icon(Icons.beach_access, color: Colors.orange)),
              title: Text(leave.staffName,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              subtitle: Text(
        '${leave.leaveType} • ${leave.fromDate} (${leave.days} day${leave.days > 1 ? 's' : ''})',
                style: const TextStyle(fontSize: 11)),
              trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                IconButton(
                  icon: const Icon(Icons.check_circle, color: Colors.green, size: 28),
                  onPressed: () => staff.approveLeave(leave.id),
                ),
                IconButton(
                  icon: const Icon(Icons.cancel, color: Colors.red, size: 28),
                  onPressed: () => staff.rejectLeave(leave.id),
                ),
              ]),
            ),
          )),
        const SizedBox(height: 20),

        // Quick Actions ? Add Staff NAHI hai
        Text(context.watch<LanguageProvider>().t('quick_actions'),
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
        const SizedBox(height: 10),
        Row(children: [
          _quickAction(context, Icons.calendar_today, 'Attendance', const Color(0xFF2E7D32), '/staff/attendance'),
          const SizedBox(width: 10),
          _quickAction(context, Icons.payments, 'Salary',     const Color(0xFFE65100), '/staff/salary'),
          const SizedBox(width: 10),
          _quickAction(context, Icons.bar_chart, 'Reports',    const Color(0xFF6A1B9A), '/staff/reports'),
        ]),
        const SizedBox(height: 20),

        // Department summary
        const Text('Department Summary',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
        const SizedBox(height: 10),
        Card(child: Column(children: [
          _deptRow('Science',        2, Colors.blue),
          _deptRow('Mathematics',    2, Colors.green),
          _deptRow('Administration', 2, Colors.orange),
          _deptRow('Accounts',       1, Colors.purple),
          _deptRow('Library',        1, Colors.teal),
          _deptRow('Transport',      1, Colors.red),
        ])),
      ]),
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) => Card(
    child: Padding(padding: const EdgeInsets.all(14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Container(padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: color, size: 20)),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
          Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        ]),
      ]),
    ),
  );

  Widget _quickAction(BuildContext context, IconData icon, String label, Color color, String route) =>
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
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w600),
            textAlign: TextAlign.center),
        ]),
      ),
    ));

  Widget _deptRow(String dept, int count, Color color) => ListTile(
    dense: true,
    leading: Container(width: 10, height: 10,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
    title: Text(dept, style: const TextStyle(fontSize: 13)),
    trailing: Text('$count staff',
      style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
  );
}





