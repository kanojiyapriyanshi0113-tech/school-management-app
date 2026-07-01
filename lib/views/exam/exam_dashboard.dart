import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/exam_provider.dart';
import '../../providers/auth_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/language_provider.dart';

class ExamDashboard extends StatefulWidget {
  const ExamDashboard({super.key});
  @override
  State<ExamDashboard> createState() => _ExamDashboardState();
}

class _ExamDashboardState extends State<ExamDashboard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) =>
      context.read<ExamProvider>().fetchExams());
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ExamProvider>();
    final role = context.read<AuthProvider>().user?.role;
    final isAdmin = role == 'admin' || role == 'staff';

    return Scaffold(
      appBar: AppBar(
        title: Text(context.watch<LanguageProvider>().t('exam_management')),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => context.go(
            role == 'student' ? '/dashboard/student'
            : role == 'parent' ? '/dashboard/parent'
            : '/dashboard/admin')),
        actions: isAdmin ? [
          IconButton(icon: const Icon(Icons.add_circle_outline),
            onPressed: () => context.go('/exams/create'),
            tooltip: 'Create Exam'),
        ] : null,
      ),
      body: RefreshIndicator(
        onRefresh: () => context.read<ExamProvider>().fetchExams(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

            // Summary Cards
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.5,
              children: [
                _summaryCard('Upcoming', '${p.upcomingExams}', Icons.calendar_today, Colors.blue),
                _summaryCard('Ongoing', '${p.ongoingExams}', Icons.play_circle, Colors.orange),
                _summaryCard('Completed', '${p.completedExams}', Icons.check_circle, Colors.green),
                _summaryCard('Total Exams', '${p.exams.length}', Icons.quiz, Colors.purple),
                _summaryCard('Pass %', '${p.passPercentage}%', Icons.trending_up, Colors.teal),
                _summaryCard('Avg Score', '${p.avgScore}%', Icons.analytics, Colors.indigo),
              ],
            ),
            const SizedBox(height: 20),

            // Quick Actions
            if (isAdmin) ...[
              _sectionHeader('Quick Actions'),
              const SizedBox(height: 10),
              Row(children: [
                Expanded(child: _actionBtn('Create Exam', Icons.add_circle,
                  Colors.blue, () => context.go('/exams/create'))),
                const SizedBox(width: 10),
                Expanded(child: _actionBtn('Enter Marks', Icons.edit_note,
                  Colors.orange, () => context.go('/exams/marks'))),
              ]),
              const SizedBox(height: 10),
              Row(children: [
                Expanded(child: _actionBtn('Results', Icons.bar_chart,
                  Colors.green, () => context.go('/exams/results'))),
                const SizedBox(width: 10),
                Expanded(child: _actionBtn('Schedule', Icons.schedule,
                  Colors.purple, () => context.go('/exams/list'))),
              ]),
              const SizedBox(height: 20),
            ],

            // Exam List
            _sectionHeader('All Exams'),
            const SizedBox(height: 10),
            p.isLoading
              ? const Center(child: CircularProgressIndicator())
              : p.exams.isEmpty
                ? Container(
                    padding: const EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12)),
                    child: Column(children: [
                      Icon(Icons.quiz, size: 48, color: Colors.grey.shade300),
                      const SizedBox(height: 8),
                      const Text('No exams yet',
                        style: TextStyle(color: Colors.grey)),
                      if (isAdmin) ...[
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: () => context.go('/exams/create'),
                          icon: const Icon(Icons.add),
                          label: const Text('Create First Exam')),
                      ],
                    ]))
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: p.exams.length,
                    itemBuilder: (ctx, i) => _examCard(ctx, p.exams[i], isAdmin)),
          ]),
        ),
      ),
    );
  }

  Widget _examCard(BuildContext context, ExamModel exam, bool isAdmin) {
    final statusColors = {
        'draft': Colors.grey,
        'published': Colors.blue,
        'ongoing': Colors.orange,
        'completed': Colors.green,
    };
    final color = statusColors[exam.status] ?? Colors.blue;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(exam.name,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(height: 2),
              Text('${exam.examType} • ${exam.className}',
                style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ])),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8)),
                child: Text(exam.status.toUpperCase(),
                  style: TextStyle(fontSize: 10, color: color,
                    fontWeight: FontWeight.bold))),
              const SizedBox(height: 4),
              Text(exam.academicYear,
                style: const TextStyle(fontSize: 10, color: Colors.grey)),
            ]),
          ]),
          const Divider(height: 14),
          Row(children: [
            const Icon(Icons.calendar_today, size: 12, color: Colors.grey),
            const SizedBox(width: 4),
            Text('${exam.startDate} - ${exam.endDate}',
              style: const TextStyle(fontSize: 11, color: Colors.grey)),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            if (exam.status == 'draft') ...[
              Expanded(child: OutlinedButton.icon(
                onPressed: () async {
                  final ok = await context.read<ExamProvider>().updateExamStatus(
                    exam.id, 'cancelled');
                  if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(ok ? 'Exam cancelled!' : 'Failed'),
                      backgroundColor: ok ? Colors.orange : Colors.red));
                },
                icon: const Icon(Icons.cancel, size: 14),
                label: const Text('Cancel', style: TextStyle(fontSize: 12)),
                style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
              )),
              const SizedBox(width: 8),
              Expanded(child: ElevatedButton.icon(
                onPressed: () async {
                  final ok = await context.read<ExamProvider>().updateExamStatus(
                    exam.id, 'published');
                  if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(ok ? 'Exam published!' : 'Failed'),
                      backgroundColor: ok ? Colors.green : Colors.red));
                },
                icon: const Icon(Icons.publish, size: 14),
                label: const Text('Publish', style: TextStyle(fontSize: 12)),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              )),
            ] else if (exam.status != 'cancelled') ...[
              Expanded(child: OutlinedButton.icon(
                onPressed: () => context.go('/exams/results'),
                icon: const Icon(Icons.bar_chart, size: 14),
                label: const Text('Results', style: TextStyle(fontSize: 12)),
              )),
              if (isAdmin) ...[
                const SizedBox(width: 8),
                Expanded(child: ElevatedButton.icon(
                  onPressed: () => context.go('/exams/marks'),
                  icon: const Icon(Icons.edit, size: 14),
                  label: const Text('Marks', style: TextStyle(fontSize: 12)),
                )),
              ],
            ],
          ]),
        ]),
      ),
    );
  }

  Widget _summaryCard(String label, String value, IconData icon, Color color) =>
    Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2))),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 6),
        Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold,
          color: color)),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey),
          textAlign: TextAlign.center),
      ]),
    );

  Widget _actionBtn(String label, IconData icon, Color color, VoidCallback onTap) =>
    InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.2))),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600,
            fontSize: 13)),
        ]),
      ),
    );

  Widget _sectionHeader(String title) => Row(children: [
    Container(width: 4, height: 18,
      decoration: BoxDecoration(
        color: AppTheme.primaryColor, borderRadius: BorderRadius.circular(2))),
    const SizedBox(width: 8),
    Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
  ]);
}


