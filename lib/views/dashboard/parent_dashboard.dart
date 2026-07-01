import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/parent_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/language_provider.dart';

class ParentDashboard extends StatefulWidget {
  const ParentDashboard({super.key});
  @override
  State<ParentDashboard> createState() => _ParentDashboardState();
}

class _ParentDashboardState extends State<ParentDashboard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ParentProvider>().fetchMyChildren();
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final p = context.watch<ParentProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(context.watch<LanguageProvider>().t('parent_dashboard')),
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
              onTap: () => _showProfile(context, user, p),
              child: CircleAvatar(
                backgroundColor: Colors.white24,
                child: Text(user?.name.substring(0, 1) ?? 'P',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
            ),
          ),
        ],
      ),
      drawer: _drawer(context, user, p),
      body: p.isLoading
        ? const Center(child: CircularProgressIndicator())
        : RefreshIndicator(
            onRefresh: () => p.fetchMyChildren(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                // Greeting
                Text('Hello, ${user?.name ?? 'Parent'} 👋',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const Text('Parent Portal', style: TextStyle(color: Colors.grey, fontSize: 13)),
                const SizedBox(height: 16),

                // ── Children Section ──
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text(context.watch<LanguageProvider>().t('my_children'), style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12)),
                    child: Text('${p.totalChildren} enrolled',
                      style: const TextStyle(fontSize: 12, color: AppTheme.primaryColor,
                        fontWeight: FontWeight.bold))),
                ]),
                const SizedBox(height: 10),

                // Class-wise grouped children
                if (p.classGroups.isEmpty)
                  const Center(child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Text('No children enrolled', style: TextStyle(color: Colors.grey))))
                else
                  ...p.classGroups.map((group) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Class header badge
                      Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppTheme.primaryColor.withOpacity(0.25))),
                        child: Row(children: [
                          const Icon(Icons.class_, size: 14, color: AppTheme.primaryColor),
                          const SizedBox(width: 6),
                          Text(group.label,
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold,
                              color: AppTheme.primaryColor)),
                          const SizedBox(width: 8),
                          Text('(${group.children.length} student${group.children.length > 1 ? 's' : ''})',
                            style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                        ]),
                      ),
                      // Children cards in this class
                      ...group.children.map((child) => _childCard(child, p)),
                      const SizedBox(height: 8),
                    ],
                  )),

                // ── Selected Child Stats ──
                if (p.selectedChild != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.blue.shade100)),
                    child: Row(children: [
                      const Icon(Icons.person_pin, color: Colors.blue, size: 18),
                      const SizedBox(width: 8),
                      Text('Viewing: ${p.selectedChild!.name}',
                        style: const TextStyle(fontSize: 12, color: Colors.blue,
                          fontWeight: FontWeight.w500)),
                      const Spacer(),
                      Text(p.selectedChild!.classWithSection,
                        style: const TextStyle(fontSize: 11, color: Colors.blue)),
                    ]),
                  ),
                  const SizedBox(height: 12),

                  // Stats row
                  Row(children: [
                    Expanded(child: _statCard('Attendance', '89%', '42/47 days', 0.89, Colors.green)),
                    const SizedBox(width: 10),
                    Expanded(child: _statCard('Academic', '83.6%', 'Grade A', 0.836, Colors.blue)),
                  ]),
                  const SizedBox(height: 16),
                ],

                // Quick Access
                const Text('Quick Access', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                const SizedBox(height: 10),
                GridView.count(
                  shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 3, crossAxisSpacing: 10, mainAxisSpacing: 10,
                  childAspectRatio: 1.1,
                  children: [
                    _qaCard(context, Icons.payment,       'Fee Status',  const Color(0xFFE65100), '/fees'),
                    _qaCard(context, Icons.quiz,           'Results',    const Color(0xFF6A1B9A), '/exams/results'),
                    _qaCard(context, Icons.announcement,   'Notices',    const Color(0xFF1565C0), '/notices'),
                    _qaCard(context, Icons.schedule,       'Timetable',  const Color(0xFF00838F), '/timetable'),
                    _qaCard(context, Icons.directions_bus, 'Transport',  const Color(0xFF0277BD), '/transport'),
                    _qaCard(context, Icons.assignment,     'Homework',   const Color(0xFFF57F17), '/parent/homework'),
                    _qaCard(context, Icons.chat,           'Message',    const Color(0xFF2E7D32), '/parent/message'),
                  ],
                ),
                const SizedBox(height: 16),

                // Fee Status
                const Text('Fee Status', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Card(child: Column(children: [
                  _feeRow('Tuition Fee',   'Rs 12,500', 'paid',    '15 May 2025'),
                  _feeRow('Hostel Fee',    'Rs 8,000',  'pending', '10 Jun 2025'),
                  _feeRow('Transport Fee', 'Rs 3,500',  'overdue', '01 Jun 2025'),
                ])),
                const SizedBox(height: 16),

                // Notices
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  const Text('Recent Notices', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                  TextButton(onPressed: () => context.go('/notices'), child: const Text('View All')),
                ]),
                ...[
                  ['Annual Sports Day', '16 Jun', 'Sports Day on 20 July 2025'],
                  ['Exam Schedule',     '15 Jun', 'Mid-term exams from 20 June'],
                  ['Fee Reminder',      '14 Jun', 'Last date for fee: 30 June'],
                ].map((n) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: Container(width: 40, height: 40,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10)),
                      child: const Icon(Icons.announcement, color: AppTheme.primaryColor, size: 20)),
                    title: Text(n[0], style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    subtitle: Text(n[2], style: const TextStyle(fontSize: 11)),
                    trailing: Text(n[1], style: const TextStyle(fontSize: 11, color: Colors.grey)),
                  ),
                )),
                const SizedBox(height: 16),

                // Homework
                if (p.selectedChild != null) ...[
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text("${p.selectedChild!.name.split(' ')[0]}'s Homework",
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                    TextButton(onPressed: () => context.go('/parent/homework'),
                      child: const Text('View All')),
                  ]),
                  ...[
                    ['Math Assignment', 'Due: 20 Jun', 'pending'],
                    ['English Essay',   'Due: 22 Jun', 'pending'],
                    ['Science Project', 'Submitted',   'submitted'],
                  ].map((h) {
                    final color = h[2] == 'submitted' ? Colors.green : Colors.orange;
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: Icon(Icons.assignment, color: color),
                        title: Text(h[0], style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                        subtitle: Text(h[1], style: TextStyle(fontSize: 11, color: color)),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(color: color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8)),
                          child: Text(h[2].toUpperCase(),
                            style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.bold))),
                      ),
                    );
                  }),
                ],
              ]),
            ),
          ),
    );
  }

  // ── Child Card ──
  Widget _childCard(ChildModel child, ParentProvider p) {
    final isSelected = p.selectedChild?.id == child.id;
    final attColor = Colors.green; // real me API se milega

    return GestureDetector(
      onTap: () => p.selectChild(child),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor.withOpacity(0.04) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : Colors.grey.shade200,
            width: isSelected ? 2 : 1),
          boxShadow: isSelected ? [BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.12),
            blurRadius: 8, offset: const Offset(0, 2))] : [],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(children: [
            // Avatar
            CircleAvatar(
              radius: 24,
              backgroundColor: (isSelected ? AppTheme.primaryColor : Colors.grey.shade400)
                .withOpacity(0.15),
              child: Text(child.initial,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,
                  color: isSelected ? AppTheme.primaryColor : Colors.grey.shade600))),
            const SizedBox(width: 12),
            // Info
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(child: Text(child.name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  overflow: TextOverflow.ellipsis)),
                if (isSelected) Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(10)),
                  child: const Text('Viewing',
                    style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold))),
              ]),
              const SizedBox(height: 2),
              Text('${child.classWithSection}  •  Roll: ${child.rollNo}',
                style: const TextStyle(color: Colors.grey, fontSize: 11)),
              Text(child.admissionNo,
                style: const TextStyle(color: Colors.grey, fontSize: 11)),
            ])),
            // Status badge
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8)),
                child: const Text('Active',
                  style: TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.bold))),
            ]),
          ]),
        ),
      ),
    );
  }

  Widget _statCard(String label, String value, String sub, double progress, Color color) =>
    Card(child: Padding(
      padding: const EdgeInsets.all(12),
      child: Column(children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        const SizedBox(height: 8),
        Text(value, style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: color)),
        Text(sub, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        const SizedBox(height: 6),
        ClipRRect(borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(value: progress,
            color: color, backgroundColor: color.withOpacity(0.1), minHeight: 6)),
      ]),
    ));

  void _showNotifications(BuildContext context) {
    showModalBottomSheet(context: context, isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.5, maxChildSize: 0.9, minChildSize: 0.4, expand: false,
        builder: (_, sc) => Column(children: [
          Container(margin: const EdgeInsets.only(top: 10), width: 40, height: 4,
            decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
          const Padding(padding: EdgeInsets.all(16),
            child: Row(children: [
              Icon(Icons.notifications, color: Colors.blue),
              SizedBox(width: 8),
              Text('Notifications', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ])),
          const Divider(height: 1),
          Expanded(child: ListView(controller: sc, children: [
            _notifTile(Icons.payment,      'Fee Due',      'Hostel fee due on 10 June',          '1 hr ago',  Colors.orange),
            _notifTile(Icons.quiz,         'Exam Result',  'Rahul scored 83.6% in unit test',    '2 hrs ago', Colors.purple),
            _notifTile(Icons.campaign,     'Notice',       'Annual Sports Day on 20 July',       '5 hrs ago', Colors.blue),
            _notifTile(Icons.check_circle, 'Attendance',   'Priya present today',                '1 day ago', Colors.green),
          ])),
        ])));
  }

  Widget _notifTile(IconData icon, String title, String sub, String time, Color color) =>
    ListTile(
      leading: CircleAvatar(backgroundColor: color.withOpacity(0.1),
        child: Icon(icon, color: color, size: 20)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
      subtitle: Text(sub, style: const TextStyle(fontSize: 11)),
      trailing: Text(time, style: const TextStyle(fontSize: 10, color: Colors.grey)),
    );

  void _showProfile(BuildContext context, dynamic user, ParentProvider p) {
    showModalBottomSheet(context: context, isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 40, height: 4,
            decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 20),
          CircleAvatar(radius: 40,
            backgroundColor: AppTheme.primaryColor.withOpacity(0.15),
            child: Text(user?.name?.substring(0,1) ?? 'P',
              style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor))),
          const SizedBox(height: 12),
          Text(user?.name ?? 'Parent',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Text(user?.email ?? '',
            style: const TextStyle(color: Colors.grey, fontSize: 13)),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(20)),
            child: Text('${p.totalChildren} Children Enrolled',
              style: TextStyle(color: Colors.green.shade700, fontWeight: FontWeight.bold, fontSize: 12))),
          const SizedBox(height: 20),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pop(context);
              context.read<AuthProvider>().logout();
              context.go('/login');
            }),
          const SizedBox(height: 12),
        ]),
      ));
  }

  Widget _drawer(BuildContext context, dynamic user, ParentProvider p) => Drawer(
    child: Column(children: [
      DrawerHeader(
        decoration: const BoxDecoration(color: AppTheme.primaryColor),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end, children: [
          const CircleAvatar(backgroundColor: Colors.white24,
            child: Icon(Icons.family_restroom, color: Colors.white)),
          const SizedBox(height: 8),
          Text(user?.name ?? 'Parent',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          Text('${p.totalChildren} children enrolled',
            style: const TextStyle(color: Colors.white70, fontSize: 11)),
        ]),
      ),
      _dItem(context, Icons.people,        'My Children',     '/dashboard/parent'),
      _dItem(context, Icons.payment,       'Fee Status',      '/fees'),
      _dItem(context, Icons.quiz,          'Results',         '/exams/results'),
      _dItem(context, Icons.announcement,  'Notices',         '/notices'),
      _dItem(context, Icons.schedule,      'Timetable',       '/timetable'),
      _dItem(context, Icons.assignment,    'Homework',        '/parent/homework'),
      _dItem(context, Icons.chat,          'Message Teacher', '/parent/message'),
    _dItem(context, Icons.language, 'Language / भाषा', '/settings'),
      const Divider(),
      ListTile(
        leading: const Icon(Icons.logout, color: Colors.red),
        title: const Text('Logout', style: TextStyle(color: Colors.red)),
        onTap: () async {
          await context.read<AuthProvider>().logout();
          if (context.mounted) context.go('/login');
        }),
    ]),
  );

  Widget _dItem(BuildContext context, IconData icon, String label, String route) =>
    ListTile(
      leading: Icon(icon, color: AppTheme.primaryColor),
      title: Text(label),
      onTap: () { Navigator.pop(context); context.go(route); },
    );

  Widget _qaCard(BuildContext context, IconData icon, String label, Color color, String route) =>
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

  Widget _feeRow(String label, String amount, String status, String date) {
    final colors = {'paid': Colors.green, 'pending': Colors.orange, 'overdue': Colors.red};
    final color = colors[status] ?? Colors.grey;
    return ListTile(dense: true,
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
      subtitle: Text(date, style: const TextStyle(fontSize: 11)),
      trailing: Column(mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end, children: [
        Text(amount, style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 13)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
          decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
          child: Text(status.toUpperCase(),
            style: TextStyle(fontSize: 9, color: color, fontWeight: FontWeight.bold))),
      ]),
    );
  }
}