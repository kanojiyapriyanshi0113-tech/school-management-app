import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/student_provider.dart';

// Keeps track of which students have submitted which homework.
// Key: "homeworkTitle|studentId"
class HomeworkSubmissionStore {
  HomeworkSubmissionStore._();
  static final Set<String> submitted = {};

  static bool isSubmitted(String title, int studentId) =>
      submitted.contains('$title|$studentId');

  static void toggle(String title, int studentId) {
    final key = '$title|$studentId';
    if (submitted.contains(key)) {
      submitted.remove(key);
    } else {
      submitted.add(key);
    }
  }
}

class HomeworkSubmissionScreen extends StatefulWidget {
  final String title;
  final String className; // e.g. "Class 10-A"
  final String due;
  const HomeworkSubmissionScreen({
    super.key,
    required this.title,
    required this.className,
    required this.due,
  });

  @override
  State<HomeworkSubmissionScreen> createState() => _HomeworkSubmissionScreenState();
}

class _HomeworkSubmissionScreenState extends State<HomeworkSubmissionScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) =>
      context.read<StudentProvider>().fetchStudents());
  }

  @override
  Widget build(BuildContext context) {
    final sp = context.watch<StudentProvider>();

    // "Class 10-A" -> className "Class 10", section "A"
    final parts = widget.className.split('-');
    final section = parts.length > 1 ? parts.last : '';
    final clsName = parts.length > 1
      ? parts.sublist(0, parts.length - 1).join('-')
      : widget.className;

    final students = sp.students.where((s) =>
      s.className == clsName && (section.isEmpty || s.section == section)).toList();

    final submittedCount = students.where((s) =>
      HomeworkSubmissionStore.isSubmitted(widget.title, s.id)).length;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title, style: const TextStyle(fontSize: 15)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(children: [
        Container(
          width: double.infinity,
          color: Colors.white,
          padding: const EdgeInsets.all(14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('${widget.className} • Due: ${widget.due}',
              style: const TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: students.isEmpty ? 0 : submittedCount / students.length,
                  color: Colors.green,
                  backgroundColor: Colors.green.withOpacity(0.1),
                  minHeight: 8))),
              const SizedBox(width: 10),
              Text('$submittedCount/${students.length} submitted',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.green)),
            ]),
          ]),
        ),
        Expanded(child: sp.isLoading
          ? const Center(child: CircularProgressIndicator())
          : students.isEmpty
            ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.people_outline, size: 64, color: Colors.grey.shade300),
                const SizedBox(height: 12),
                Text('No students found in ${widget.className}',
                  style: const TextStyle(color: Colors.grey)),
              ]))
            : ListView.builder(
                padding: const EdgeInsets.all(14),
                itemCount: students.length,
                itemBuilder: (context, i) {
                  final s = students[i];
                  final isDone = HomeworkSubmissionStore.isSubmitted(widget.title, s.id);
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                        child: Text(s.name.isNotEmpty ? s.name[0].toUpperCase() : '?',
                          style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold))),
                      title: Text(s.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                      subtitle: Text('Roll: ${s.rollNo}', style: const TextStyle(fontSize: 11)),
                      trailing: ElevatedButton.icon(
                        onPressed: () {
                          setState(() => HomeworkSubmissionStore.toggle(widget.title, s.id));
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(isDone
                              ? '${s.name} marked as pending'
                              : '${s.name} marked as submitted!'),
                            backgroundColor: isDone ? Colors.orange : Colors.green));
                        },
                        icon: Icon(isDone ? Icons.check_circle : Icons.check, size: 16),
                        label: Text(isDone ? 'Submitted' : 'Mark as Submitted',
                          style: const TextStyle(fontSize: 11)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDone ? Colors.green : AppTheme.primaryColor,
                        ),
                      ),
                    ),
                  );
                },
              )),
      ]),
    );
  }
}
