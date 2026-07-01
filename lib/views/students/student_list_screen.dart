import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/student_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/language_provider.dart';

class StudentListScreen extends StatefulWidget {
  const StudentListScreen({super.key});
  @override
  State<StudentListScreen> createState() => _StudentListScreenState();
}

class _StudentListScreenState extends State<StudentListScreen> {
  final _search = TextEditingController();
  int _selectedClassIndex = 0;

  // ? FIXED: Full class list from Nursery to Class 12
  final List<String> _classes = [
        'All',
        'Nursery',
        'LKG',
        'UKG',
        'Class 1',
        'Class 2',
        'Class 3',
        'Class 4',
        'Class 5',
        'Class 6',
        'Class 7',
        'Class 8',
        'Class 9',
        'Class 10',
        'Class 11',
        'Class 12',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StudentProvider>().fetchStudents();
    });
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<StudentProvider>();
    return Scaffold(
      appBar: AppBar(
        title: Text(context.watch<LanguageProvider>().t('students')),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => context.go((() {
            final role = context.read<AuthProvider>().user?.role;
            return role == 'staff'
                ? '/dashboard/staff'
                : role == 'student'
                    ? '/dashboard/student'
                    : role == 'parent'
                        ? '/dashboard/parent'
                        : '/dashboard/admin';
          })()),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                shape: const RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(16))),
                builder: (ctx) => Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Filter & Sort',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      const Text('Status',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: ['All', 'active', 'inactive']
                            .map((s) => ActionChip(
                                label: Text(s),
                                onPressed: () {
                                  p.setStatusFilter(s);
                                  Navigator.pop(ctx);
                                }))
                            .toList(),
                      ),
                      const SizedBox(height: 12),
                      const Text('Sort By',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      Wrap(spacing: 8, children: [
                        ActionChip(
                            label: const Text('Name'),
                            onPressed: () {
                              p.setSortBy('name');
                              Navigator.pop(ctx);
                            }),
                        ActionChip(
                            label: const Text('Roll No'),
                            onPressed: () {
                              p.setSortBy('roll');
                              Navigator.pop(ctx);
                            }),
                      ]),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/students/add'),
        icon: const Icon(Icons.person_add),
        label: Text(context.watch<LanguageProvider>().t('add_student')),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: Column(children: [
        // Stats row
        Container(
          color: AppTheme.primaryColor.withOpacity(0.05),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(children: [
            _chip('Total', '${p.totalStudents}', Colors.blue),
            const SizedBox(width: 14),
            _chip('Active', '${p.activeStudents}', Colors.green),
            const SizedBox(width: 14),
            _chip('Inactive', '${p.totalStudents - p.activeStudents}',
                Colors.red),
          ]),
        ),

        // Search bar
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 6),
          child: TextField(
            controller: _search,
            onChanged: p.setSearchQuery,
            decoration: InputDecoration(
              hintText: 'Search name, admission no...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _search.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _search.clear();
                        p.setSearchQuery('');
                      })
                  : null,
            ),
          ),
        ),

        // ? FIXED: Class filter chips with proper selected state tracking
        SizedBox(
          height: 42,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            itemCount: _classes.length,
            itemBuilder: (context, i) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(_classes[i],
                    style: const TextStyle(fontSize: 12)),
                // ? FIXED: uses _selectedClassIndex, not hardcoded i == 0
                selected: _selectedClassIndex == i,
                onSelected: (_) {
                  setState(() => _selectedClassIndex = i);
                  // ? Pass 'All' directly ? provider handles it
                  p.setClassFilter(_classes[i]);
                },
                selectedColor: AppTheme.primaryColor.withOpacity(0.15),
                checkmarkColor: AppTheme.primaryColor,
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),

        // Student list
        p.loadStatus == LoadStatus.loading
            ? const Expanded(
                child: Center(child: CircularProgressIndicator()))
            : p.students.isEmpty
                ? const Expanded(
                    child: Center(
                        child: Text('No students found',
                            style: TextStyle(color: Colors.grey))))
                : Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(14, 0, 14, 100),
                      itemCount: p.students.length,
                      itemBuilder: (context, i) {
                        final s = p.students[i];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            onTap: () => context.go('/students/${s.id}'),
                            leading: CircleAvatar(
                              radius: 22,
                              backgroundColor:
                                  AppTheme.primaryColor.withOpacity(0.1),
                              child: Text(s.name.isNotEmpty ? s.name[0].toUpperCase() : '?',
                                  style: const TextStyle(
                                      color: AppTheme.primaryColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16)),
                            ),
                            title: Text(s.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13)),
                            subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // ? FIXED: Shows "Class 10-A ? Roll: 123"
                                  // ? FIXED: \u2022 avoids bullet encoding issues
                                  Text(
        '${s.className}${s.section.isNotEmpty ? "-${s.section}" : ""}'
        ' \u2022 Roll: ${s.rollNo}',
                                      style: const TextStyle(fontSize: 11)),
                                  Text(
        '${s.admissionNo} \u2022 ${s.parentPhone}',
                                      style: const TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey)),
                                ]),
                            isThreeLine: true,
                            trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: s.status == 'active'
                                          ? Colors.green.withOpacity(0.1)
                                          : Colors.red.withOpacity(0.1),
                                      borderRadius:
                                          BorderRadius.circular(10),
                                    ),
                                    child: Text(s.status.toUpperCase(),
                                        style: TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                            color: s.status == 'active'
                                                ? Colors.green
                                                : Colors.red)),
                                  ),
                                  PopupMenuButton(
                                    itemBuilder: (_) => [
                                      const PopupMenuItem(
                                          value: 'edit',
                                          child: Text('Edit')),
                                      const PopupMenuItem(
                                          value: 'delete',
                                          child: Text('Delete',
                                              style: TextStyle(
                                                  color: Colors.red))),
                                    ],
                                    onSelected: (val) {
                                      if (val == 'edit')
                                        context.go(
 '/students/${s.id}/edit');
                                      if (val == 'delete')
                                        p.deleteStudent(s.id);
                                    },
                                  ),
                                ]),
                          ),
                        );
                      },
                    ),
                  ),
      ]),
    );
  }

  Widget _chip(String label, String val, Color color) =>
      Row(children: [
        Container(
            width: 8,
            height: 8,
            decoration:
                BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text('$label: ',
            style: const TextStyle(fontSize: 11, color: Colors.grey)),
        Text(val,
            style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: color)),
      ]);
}

