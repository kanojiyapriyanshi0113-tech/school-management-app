import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'package:provider/provider.dart';
import '../../providers/staff_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/language_provider.dart';

class StaffListScreen extends StatefulWidget {
  const StaffListScreen({super.key});
  @override
  State<StaffListScreen> createState() => _StaffListScreenState();
}

class _StaffListScreenState extends State<StaffListScreen> {
  final _search = TextEditingController();

  final List<String> _departments = [
 'All', 'Science', 'Mathematics', 'English', 'Administration',
 'Accounts', 'Library', 'Transport'
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StaffProvider>().fetchStaff();
    });
  }

  @override
  void dispose() { _search.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<StaffProvider>();
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white), onPressed: () => context.go((() { final role = context.read<AuthProvider>().user?.role; return role == 'staff' ? '/dashboard/staff' : role == 'student' ? '/dashboard/student' : role == 'parent' ? '/dashboard/parent' : '/dashboard/admin'; })())),title: Text(context.watch<LanguageProvider>().t('staff'))),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/staff/add'),
        icon: const Icon(Icons.person_add),
        label: const Text('Add Staff'),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: Column(children: [
        // Stats bar
        Container(
          color: AppTheme.primaryColor.withOpacity(0.05),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(children: [
            _chip('Total', '${p.totalStaff}', Colors.blue),
            const SizedBox(width: 16),
            _chip('Active', '${p.activeStaff}', Colors.green),
            const SizedBox(width: 16),
            _chip('Inactive', '${p.totalStaff - p.activeStaff}', Colors.red),
          ]),
        ),
        // Search
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 6),
          child: TextField(
            controller: _search,
            onChanged: p.setSearchQuery,
            decoration: InputDecoration(
              hintText: 'Search by name, ID, designation...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _search.text.isNotEmpty
                ? IconButton(icon: const Icon(Icons.clear), onPressed: () { _search.clear(); p.setSearchQuery(''); })
                : null,
            ),
          ),
        ),
        // Dept filter
        SizedBox(
          height: 42,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            itemCount: _departments.length,
            itemBuilder: (context, i) {
              final dept = _departments[i];
              final selected = dept == 'All'; // track in provider ideally
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(dept, style: const TextStyle(fontSize: 12)),
                  selected: selected,
                  onSelected: (_) => p.setDeptFilter(dept),
                  selectedColor: AppTheme.primaryColor.withOpacity(0.15),
                  checkmarkColor: AppTheme.primaryColor,
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 6),
        // List
        p.isLoading
          ? const Expanded(child: Center(child: CircularProgressIndicator()))
          : Expanded(
              child: p.staffList.isEmpty
                ? const Center(child: Text('No staff found', style: TextStyle(color: Colors.grey)))
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(14, 0, 14, 100),
                    itemCount: p.staffList.length,
                    itemBuilder: (context, i) => _StaffCard(
                      staff: p.staffList[i],
                      onTap: () => context.go('/staff/${p.staffList[i].id}'),
                      onDelete: () async {
                        final ok = await showDialog<bool>(context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Delete Staff'),
                            content: Text('Delete ${p.staffList[i].name}?'),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                onPressed: () => Navigator.pop(ctx, true),
                                child: const Text('Delete'),
                              ),
                            ],
                          ),
                        );
                        if (ok == true) p.deleteStaff(p.staffList[i].id);
                      },
                    ),
                  ),
            ),
      ]),
    );
  }

  Widget _chip(String label, String val, Color color) => Row(children: [
    Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
    const SizedBox(width: 4),
    Text('$label: ', style: const TextStyle(fontSize: 11, color: Colors.grey)),
    Text(val, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color)),
  ]);
}

class _StaffCard extends StatelessWidget {
  final StaffModel staff;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _StaffCard({required this.staff, required this.onTap, required this.onDelete});

  Color get _roleColor {
    switch (staff.role) {
      case 'principal': return const Color(0xFF6A1B9A);
      case 'accountant': return const Color(0xFFE65100);
      case 'librarian': return const Color(0xFF00838F);
      case 'transport': return const Color(0xFF1565C0);
      default: return AppTheme.primaryColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          radius: 22,
          backgroundColor: _roleColor.withOpacity(0.1),
          child: Text(staff.name[0],
            style: TextStyle(color: _roleColor, fontWeight: FontWeight.bold, fontSize: 16)),
        ),
        title: Text(staff.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('${staff.designation} • ${staff.department}', style: const TextStyle(fontSize: 11)),
          Text('${staff.employeeId} • ${staff.phone}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
        ]),
        isThreeLine: true,
        trailing: Row(mainAxisSize: MainAxisSize.min, children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: staff.status == 'active' ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(staff.status.toUpperCase(),
              style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold,
                color: staff.status == 'active' ? Colors.green : Colors.red)),
          ),
          PopupMenuButton(
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'edit', child: Text('Edit')),
              const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: Colors.red))),
            ],
            onSelected: (val) {
              if (val == 'edit') context.go('/staff/${staff.id}/edit');
              if (val == 'delete') onDelete();
            },
          ),
        ]),
      ),
    );
  }
}








