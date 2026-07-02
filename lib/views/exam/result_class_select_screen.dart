import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/student_provider.dart';
import '../../providers/language_provider.dart';

class ResultClassSelectScreen extends StatefulWidget {
  const ResultClassSelectScreen({super.key});
  @override
  State<ResultClassSelectScreen> createState() => _ResultClassSelectScreenState();
}

class _ResultClassSelectScreenState extends State<ResultClassSelectScreen> {
  String? _selectedClass;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) =>
      context.read<StudentProvider>().fetchStudents());
  }

  @override
  Widget build(BuildContext context) {
    final sp = context.watch<StudentProvider>();
    final classes = sp.students.map((s) => '${s.className}-${s.section}').toSet().toList()..sort();
    final classStudents = _selectedClass == null ? <StudentModel>[]
      : sp.students.where((s) => '${s.className}-${s.section}' == _selectedClass).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(context.watch<LanguageProvider>().t('results')),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () {
            final r = context.read<AuthProvider>().user?.role;
            context.go(r == 'student' ? '/dashboard/student'
              : r == 'staff' ? '/dashboard/staff'
              : '/dashboard/admin');
          },
        ),
      ),
      body: Column(children: [
        Container(
          width: double.infinity,
          color: Colors.white,
          padding: const EdgeInsets.all(14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Select Class', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 10),
            SizedBox(height: 38,
              child: ListView(scrollDirection: Axis.horizontal, children: classes.map((cls) =>
                GestureDetector(
                  onTap: () => setState(() => _selectedClass = cls),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: _selectedClass == cls ? AppTheme.primaryColor : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(20)),
                    child: Text(cls,
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                        color: _selectedClass == cls ? Colors.white : Colors.grey.shade700)),
                  ),
                )).toList())),
          ]),
        ),
        Expanded(
          child: _selectedClass == null
            ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.class_outlined, size: 64, color: Colors.grey.shade300),
                const SizedBox(height: 12),
                const Text('Select a class to view students', style: TextStyle(color: Colors.grey)),
              ]))
            : classStudents.isEmpty
              ? const Center(child: Text('No students in this class', style: TextStyle(color: Colors.grey)))
              : ListView.builder(
                  padding: const EdgeInsets.all(14),
                  itemCount: classStudents.length,
                  itemBuilder: (context, i) {
                    final s = classStudents[i];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        onTap: () => context.push('/exams/results/student',
                          extra: {'name': s.name, 'roll': s.rollNo, 'className': _selectedClass}),
                        leading: CircleAvatar(
                          backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                          child: Text(s.name.isNotEmpty ? s.name[0].toUpperCase() : '?',
                            style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold))),
                        title: Text(s.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                        subtitle: Text('Roll: ${s.rollNo}', style: const TextStyle(fontSize: 11)),
                        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                      ),
                    );
                  },
                ),
        ),
      ]),
    );
  }
}
