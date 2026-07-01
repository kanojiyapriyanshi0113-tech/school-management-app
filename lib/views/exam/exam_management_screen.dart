import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/attendance_provider.dart' show AttendanceProvider; // baseUrl
import '../../providers/language_provider.dart';

// ─── Model ───────────────────────────────────────────────────────────────────

class Exam {
  final int id;
  String name;
  String type;       // "Unit Test", "Mid Term", etc.
  String academicYear;
  String status;     // "draft" | "published"
  DateTime? startDate;
  DateTime? endDate;

  Exam({
    required this.id,
    required this.name,
    required this.type,
    required this.academicYear,
    required this.status,
    this.startDate,
    this.endDate,
  });

  factory Exam.fromJson(Map<String, dynamic> j) => Exam(
        id: j['id'] as int,
        name: (j['name'] as String?) ?? '',
        type: (j['type'] as String?) ?? '',
        academicYear: (j['academic_year'] as String?) ?? '',
        status: (j['status'] as String?) ?? 'draft',
        startDate: j['start_date'] != null
            ? DateTime.tryParse(j['start_date'] as String)
            : null,
        endDate: j['end_date'] != null
            ? DateTime.tryParse(j['end_date'] as String)
            : null,
      );

  bool get isDraft => status == 'draft';
  bool get isPublished => status == 'published';
}

// ─── Screen ───────────────────────────────────────────────────────────────────

class ExamManagementScreen extends StatefulWidget {
  const ExamManagementScreen({super.key});

  @override
  State<ExamManagementScreen> createState() => _ExamManagementScreenState();
}

class _ExamManagementScreenState extends State<ExamManagementScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  List<Exam> _exams = [];
  bool _loading = true;

  // Mock exams for dev — backend connect hone tak
  static final List<Exam> _mockExams = [
    Exam(
      id: 1,
      name: 'Mid Term',
      type: 'Unit Test',
      academicYear: '2025-26',
      status: 'draft',
      startDate: DateTime(2026, 6, 22),
      endDate: DateTime(2026, 6, 30),
    ),
    Exam(
      id: 2,
      name: 'Unit Test 1',
      type: 'Unit Test',
      academicYear: '2025-26',
      status: 'draft',
    ),
    Exam(
      id: 3,
      name: 'Annual Exam',
      type: 'Annual',
      academicYear: '2025-26',
      status: 'published',
      startDate: DateTime(2026, 3, 1),
      endDate: DateTime(2026, 3, 15),
    ),
    Exam(
      id: 4,
      name: 'Half Yearly',
      type: 'Half Yearly',
      academicYear: '2025-26',
      status: 'published',
      startDate: DateTime(2025, 9, 10),
      endDate: DateTime(2025, 9, 20),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    _fetchExams();
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  Future<void> _fetchExams() async {
    setState(() => _loading = true);
    try {
      final res = await http
          .get(Uri.parse('${AttendanceProvider.baseUrl}/exams'))
          .timeout(const Duration(seconds: 8));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final list = (data['data'] as List<dynamic>?) ?? [];
        _exams = list.map((e) => Exam.fromJson(e as Map<String, dynamic>)).toList();
      } else {
        _exams = _mockExams;
      }
    } catch (_) {
      _exams = _mockExams;
    }
    if (mounted) setState(() => _loading = false);
  }

  List<Exam> get _drafts => _exams.where((e) => e.isDraft).toList();
  List<Exam> get _published => _exams.where((e) => e.isPublished).toList();

  // Publish a draft exam
  Future<void> _publish(Exam exam) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Exam Publish Karen?'),
        content: Text(
            '"${exam.name}" ko publish karne ke baad students aur parents ko dikhai dega.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Publish')),
        ],
      ),
    );
    if (confirm != true) return;

    try {
      final res = await http
          .put(
            Uri.parse('${AttendanceProvider.baseUrl}/exams/${exam.id}'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'status': 'published'}),
          )
          .timeout(const Duration(seconds: 8));
      if (res.statusCode == 200 || res.statusCode == 201) {
        setState(() => exam.status = 'published');
        _showSnack('Exam published!', Colors.green);
        return;
      }
    } catch (_) {}
    // Dev fallback
    setState(() => exam.status = 'published');
    _showSnack('Exam published!', Colors.green);
  }

  // Cancel/delete a draft exam
  Future<void> _cancelDraft(Exam exam) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Draft Cancel Karen?'),
        content: Text('"${exam.name}" hamesha ke liye delete ho jayega.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Nahi')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Haan, Delete Karo'),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    try {
      await http
          .delete(Uri.parse('${AttendanceProvider.baseUrl}/exams/${exam.id}'))
          .timeout(const Duration(seconds: 8));
    } catch (_) {}
    setState(() => _exams.removeWhere((e) => e.id == exam.id));
    _showSnack('Draft delete ho gaya', Colors.orange);
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg), backgroundColor: color));
  }

  String _backRoute() {
    final role = context.read<AuthProvider>().user?.role;
    return role == 'staff' ? '/dashboard/staff' : '/dashboard/admin';
  }

  @override
  Widget build(BuildContext context) {
    final drafts = _drafts;
    final published = _published;

    // Stats across all exams
    final completed = _exams.where((e) => e.isPublished).length;
    final total = _exams.length;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => context.go(_backRoute()),
        ),
        title: Text(context.watch<LanguageProvider>().t('exam_management')),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: _showCreateExamDialog,
            tooltip: 'Create Exam',
          ),
        ],
        bottom: TabBar(
          controller: _tabs,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          tabs: [
            Tab(text: 'Draft (${drafts.length})'),
            Tab(text: 'Published (${published.length})'),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchExams,
              child: Column(
                children: [
                  // ── Stats cards ─────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Row(
                      children: [
                        _StatCard('Completed', '$completed',
                            Icons.check_circle_outline, Colors.green),
                        const SizedBox(width: 10),
                        _StatCard('Total Exams', '$total',
                            Icons.quiz_outlined, Colors.purple),
                        const SizedBox(width: 10),
                        _StatCard('Drafts', '${drafts.length}',
                            Icons.edit_note, Colors.orange),
                      ],
                    ),
                  ),

                  // ── Quick actions ────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        _ActionBtn(
                            'Enter Marks', Icons.edit,
                            Colors.orange.shade50,
                            Colors.orange, () => context.go('/exams/marks')),
                        const SizedBox(width: 10),
                        _ActionBtn(
                            'Results', Icons.bar_chart,
                            Colors.green.shade50,
                            Colors.green, () => context.go('/exams/results')),
                        const SizedBox(width: 10),
                        _ActionBtn(
                            'Schedule', Icons.schedule,
                            Colors.purple.shade50,
                            Colors.purple,
                            () => context.go('/exams/schedule')),
                      ],
                    ),
                  ),

                  // ── Tab content ──────────────────────────────────────
                  Expanded(
                    child: TabBarView(
                      controller: _tabs,
                      children: [
                        // DRAFT tab
                        drafts.isEmpty
                            ? _emptyState(
                                'Koi draft exam nahi hai',
                                Icons.edit_note,
                                Colors.orange)
                            : ListView.builder(
                                padding: const EdgeInsets.fromLTRB(
                                    16, 8, 16, 16),
                                itemCount: drafts.length,
                                itemBuilder: (_, i) => _DraftCard(
                                  exam: drafts[i],
                                  onPublish: () => _publish(drafts[i]),
                                  onCancel: () => _cancelDraft(drafts[i]),
                                ),
                              ),

                        // PUBLISHED tab
                        published.isEmpty
                            ? _emptyState(
                                'Koi published exam nahi hai',
                                Icons.published_with_changes,
                                Colors.green)
                            : ListView.builder(
                                padding: const EdgeInsets.fromLTRB(
                                    16, 8, 16, 16),
                                itemCount: published.length,
                                itemBuilder: (_, i) =>
                                    _PublishedCard(exam: published[i]),
                              ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _emptyState(String msg, IconData icon, Color color) =>
      Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: color.withOpacity(0.4)),
            const SizedBox(height: 8),
            Text(msg,
                style: TextStyle(color: Colors.grey.shade500, fontSize: 14)),
          ],
        ),
      );

  // Create exam bottom-sheet dialog
  void _showCreateExamDialog() {
    final nameCtrl = TextEditingController();
    final typeCtrl = TextEditingController(text: 'Unit Test');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('New Exam',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                    labelText: 'Exam Name', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(
                controller: typeCtrl,
                decoration: const InputDecoration(
                    labelText: 'Type (Unit Test / Mid Term etc.)',
                    border: OutlineInputBorder())),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  Navigator.pop(ctx);
                  await _createExam(nameCtrl.text.trim(),
                      typeCtrl.text.trim());
                },
                child: const Text('Create as Draft'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createExam(String name, String type) async {
    if (name.isEmpty) return;
    final payload = {
      'name': name,
      'type': type,
      'academic_year': '2025-26',
      'status': 'draft',
    };
    try {
      final res = await http
          .post(
            Uri.parse('${AttendanceProvider.baseUrl}/exams'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 8));
      if (res.statusCode == 201) {
        await _fetchExams();
        _showSnack('Exam created!', Colors.green);
        return;
      }
    } catch (_) {}
    // Dev fallback
    setState(() {
      _exams.add(Exam(
        id: DateTime.now().millisecondsSinceEpoch,
        name: name,
        type: type,
        academicYear: '2025-26',
        status: 'draft',
      ));
    });
    _showSnack('Exam created (draft)', Colors.green);
  }
}

// ─── Draft Card ───────────────────────────────────────────────────────────────

class _DraftCard extends StatelessWidget {
  final Exam exam;
  final VoidCallback onPublish;
  final VoidCallback onCancel;

  const _DraftCard(
      {required this.exam, required this.onPublish, required this.onCancel});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(exam.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15)),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text('DRAFT',
                      style: TextStyle(
                          fontSize: 11,
                          color: Colors.orange,
                          fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text('${exam.type}  •  ${exam.academicYear}',
                style:
                    const TextStyle(fontSize: 12, color: Colors.grey)),
            if (exam.startDate != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.calendar_month_outlined,
                      size: 13, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    '${DateFormat("d MMM yyyy").format(exam.startDate!)}  –  ${exam.endDate != null ? DateFormat("d MMM yyyy").format(exam.endDate!) : "—"}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onCancel,
                    icon: const Icon(Icons.cancel_outlined,
                        size: 16, color: Colors.red),
                    label: const Text('Cancel',
                        style: TextStyle(color: Colors.red)),
                    style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onPublish,
                    icon: const Icon(Icons.publish, size: 16),
                    label: Text(context.watch<LanguageProvider>().t('publish')),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Published Card ───────────────────────────────────────────────────────────

class _PublishedCard extends StatelessWidget {
  final Exam exam;
  const _PublishedCard({required this.exam});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.check_circle,
                    size: 16, color: Colors.green),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(exam.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15)),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text('PUBLISHED',
                      style: TextStyle(
                          fontSize: 11,
                          color: Colors.green,
                          fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text('${exam.type}  •  ${exam.academicYear}',
                style:
                    const TextStyle(fontSize: 12, color: Colors.grey)),
            if (exam.startDate != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.calendar_month_outlined,
                      size: 13, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    '${DateFormat("d MMM yyyy").format(exam.startDate!)}  –  ${exam.endDate != null ? DateFormat("d MMM yyyy").format(exam.endDate!) : "—"}',
                    style:
                        const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 10),
            // Action buttons for published exams
            Row(
              children: [
                _SmallBtn(
                    'Enter Marks', Icons.edit, Colors.orange,
                    () => context.go('/exams/marks?exam_id=${exam.id}')),
                const SizedBox(width: 8),
                _SmallBtn(
                    'Results', Icons.bar_chart, Colors.blue,
                    () => context.go('/exams/results?exam_id=${exam.id}')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Small helpers ────────────────────────────────────────────────────────────

class _SmallBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _SmallBtn(this.label, this.icon, this.color, this.onTap);

  @override
  Widget build(BuildContext context) => TextButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 14, color: color),
        label:
            Text(label, style: TextStyle(fontSize: 12, color: color)),
        style: TextButton.styleFrom(
          backgroundColor: color.withOpacity(0.08),
          padding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        ),
      );
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard(this.label, this.value, this.icon, this.color);

  @override
  Widget build(BuildContext context) => Expanded(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Icon(icon, color: color, size: 22),
                const SizedBox(height: 4),
                Text(value,
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: color)),
                Text(label,
                    style: const TextStyle(
                        fontSize: 10, color: Colors.grey),
                    textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
      );
}

class _ActionBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color bg;
  final Color fg;
  final VoidCallback onTap;

  const _ActionBtn(this.label, this.icon, this.bg, this.fg, this.onTap);

  @override
  Widget build(BuildContext context) => Expanded(
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                Icon(icon, color: fg, size: 20),
                const SizedBox(height: 4),
                Text(label,
                    style: TextStyle(
                        fontSize: 11,
                        color: fg,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ),
      );
}