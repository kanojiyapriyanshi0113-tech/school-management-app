import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/language_provider.dart';

class StudentProgressScreen extends StatefulWidget {
  const StudentProgressScreen({super.key});
  @override
  State<StudentProgressScreen> createState() => _StudentProgressScreenState();
}

class _StudentProgressScreenState extends State<StudentProgressScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedExam = 'Mid-Term 2025';

  final _exams = ['Unit Test 1', 'Mid-Term 2025', 'Unit Test 2', 'Final 2024'];

  final _subjectMarks = {
        'Unit Test 1': [
      {'subject': 'Mathematics', 'obtained': 85.0, 'max': 100.0, 'grade': 'A'},
      {'subject': 'Science', 'obtained': 78.0, 'max': 100.0, 'grade': 'B+'},
      {'subject': 'English', 'obtained': 82.0, 'max': 100.0, 'grade': 'A'},
      {'subject': 'Hindi', 'obtained': 88.0, 'max': 100.0, 'grade': 'A'},
      {'subject': 'Social Science', 'obtained': 75.0, 'max': 100.0, 'grade': 'B+'},
    ],
        'Mid-Term 2025': [
      {'subject': 'Mathematics', 'obtained': 92.0, 'max': 100.0, 'grade': 'A+'},
      {'subject': 'Science', 'obtained': 85.0, 'max': 100.0, 'grade': 'A'},
      {'subject': 'English', 'obtained': 78.0, 'max': 100.0, 'grade': 'B+'},
      {'subject': 'Hindi', 'obtained': 88.0, 'max': 100.0, 'grade': 'A'},
      {'subject': 'Social Science', 'obtained': 75.0, 'max': 100.0, 'grade': 'B+'},
    ],
        'Unit Test 2': [
      {'subject': 'Mathematics', 'obtained': 88.0, 'max': 100.0, 'grade': 'A'},
      {'subject': 'Science', 'obtained': 90.0, 'max': 100.0, 'grade': 'A+'},
      {'subject': 'English', 'obtained': 80.0, 'max': 100.0, 'grade': 'A'},
      {'subject': 'Hindi', 'obtained': 85.0, 'max': 100.0, 'grade': 'A'},
      {'subject': 'Social Science', 'obtained': 78.0, 'max': 100.0, 'grade': 'B+'},
    ],
        'Final 2024': [
      {'subject': 'Mathematics', 'obtained': 80.0, 'max': 100.0, 'grade': 'A'},
      {'subject': 'Science', 'obtained': 75.0, 'max': 100.0, 'grade': 'B+'},
      {'subject': 'English', 'obtained': 72.0, 'max': 100.0, 'grade': 'B+'},
      {'subject': 'Hindi', 'obtained': 82.0, 'max': 100.0, 'grade': 'A'},
      {'subject': 'Social Science', 'obtained': 70.0, 'max': 100.0, 'grade': 'B'},
    ],
  };

  final _attendanceTrend = [
    {'month': 'Jan', 'pct': 0.92},
    {'month': 'Feb', 'pct': 0.88},
    {'month': 'Mar', 'pct': 0.95},
    {'month': 'Apr', 'pct': 0.87},
    {'month': 'May', 'pct': 0.83},
    {'month': 'Jun', 'pct': 0.89},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() { _tabController.dispose(); super.dispose(); }

  List<Map<String, dynamic>> get _currentMarks => _subjectMarks[_selectedExam] ?? [];

  double get _totalObtained => _currentMarks.fold(0.0, (sum, s) => sum + (s['obtained'] as double));
  double get _totalMax => _currentMarks.fold(0.0, (sum, s) => sum + (s['max'] as double));
  double get _percentage => _totalMax > 0 ? (_totalObtained / _totalMax) * 100 : 0;

  String get _overallGrade {
    if (_percentage >= 90) return 'A+';
    if (_percentage >= 80) return 'A';
    if (_percentage >= 70) return 'B+';
    if (_percentage >= 60) return 'B';
    if (_percentage >= 50) return 'C';
    return 'F';
  }

  Color get _gradeColor {
    if (_percentage >= 80) return Colors.green;
    if (_percentage >= 60) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Progress'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () {
            final r = context.read<AuthProvider>().user?.role;
            context.go(r == 'student' ? '/dashboard/student'
              : r == 'parent' ? '/dashboard/parent'
              : '/students');
          },
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            Tab(text: context.watch<LanguageProvider>().t('academic')),
            Tab(text: context.watch<LanguageProvider>().t('attendance')),
            Tab(text: context.watch<LanguageProvider>().t('overview')),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_academicTab(), _attendanceTab(), _overviewTab()],
      ),
    );
  }

  // ?? Academic Tab ??????
  Widget _academicTab() => SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Column(children: [
      // Exam selector
      DropdownButtonFormField<String>(
        value: _selectedExam,
        decoration: const InputDecoration(labelText: 'Select Exam', prefixIcon: Icon(Icons.quiz)),
        items: _exams.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
        onChanged: (v) => setState(() => _selectedExam = v!),
      ),
      const SizedBox(height: 16),

      // Overall score card
      Card(
        color: _gradeColor.withOpacity(0.05),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            // Circular progress
            SizedBox(width: 80, height: 80, child: Stack(children: [
              CircularProgressIndicator(
                value: _percentage / 100,
                strokeWidth: 8, color: _gradeColor,
                backgroundColor: _gradeColor.withOpacity(0.1)),
              Center(child: Text('${_percentage.toStringAsFixed(0)}%',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: _gradeColor))),
            ])),
            const SizedBox(width: 16),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(_selectedExam, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 4),
              Text('Total: ${_totalObtained.toStringAsFixed(0)}/${_totalMax.toStringAsFixed(0)}',
                style: const TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 6),
              Row(children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: _gradeColor, borderRadius: BorderRadius.circular(12)),
                  child: Text('Grade $_overallGrade',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                const SizedBox(width: 8),
                _rankBadge(),
              ]),
            ])),
          ]),
        ),
      ),
      const SizedBox(height: 16),

      // Subject bars chart
      const Align(alignment: Alignment.centerLeft,
        child: Text('Subject-wise Marks', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
      const SizedBox(height: 12),

      // Bar chart
      Card(child: Padding(
        padding: const EdgeInsets.all(14),
        child: SizedBox(
          height: 200,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: _currentMarks.map((s) {
              final pct = (s['obtained'] as double) / (s['max'] as double);
              final color = _subjectColor(s['subject'] as String);
              return Column(mainAxisAlignment: MainAxisAlignment.end, children: [
                Text('${(s['obtained'] as double).toStringAsFixed(0)}',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color)),
                const SizedBox(height: 4),
                Container(
                  width: 36, height: 160 * pct,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(4), topRight: Radius.circular(4)))),
                const SizedBox(height: 6),
                SizedBox(width: 46, child: Text(
                  (s['subject'] as String).split(' ').first,
                  style: const TextStyle(fontSize: 9, color: Colors.grey),
                  textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis)),
              ]);
            }).toList(),
          ),
        ),
      )),
      const SizedBox(height: 16),

      // Subject detail cards
      const Align(alignment: Alignment.centerLeft,
        child: Text('Subject Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
      const SizedBox(height: 8),
      ..._currentMarks.map((s) {
        final pct = (s['obtained'] as double) / (s['max'] as double);
        final color = _gradeToColor(s['grade'] as String);
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(children: [
              Container(width: 4, height: 50,
                decoration: BoxDecoration(color: _subjectColor(s['subject'] as String),
                  borderRadius: BorderRadius.circular(2))),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(s['subject'] as String,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                const SizedBox(height: 4),
                ClipRRect(borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(value: pct, color: color,
                    backgroundColor: color.withOpacity(0.1), minHeight: 8)),
                const SizedBox(height: 4),
                Text('${(s['obtained'] as double).toStringAsFixed(0)}/${(s['max'] as double).toStringAsFixed(0)} marks',
                  style: const TextStyle(fontSize: 11, color: Colors.grey)),
              ])),
              const SizedBox(width: 12),
              Column(children: [
                Text('${(pct * 100).toStringAsFixed(0)}%',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                  child: Text(s['grade'] as String,
                    style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.bold))),
              ]),
            ]),
          ),
        );
      }),
      const SizedBox(height: 16),

      // Exam comparison chart
      const Align(alignment: Alignment.centerLeft,
        child: Text('Progress Across Exams', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
      const SizedBox(height: 8),
      Card(child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(children: [
          ..._exams.map((exam) {
            final marks = _subjectMarks[exam] ?? [];
            final total = marks.fold(0.0, (sum, s) => sum + (s['obtained'] as double));
            final max = marks.fold(0.0, (sum, s) => sum + (s['max'] as double));
            final pct = max > 0 ? total / max : 0.0;
            final isSelected = exam == _selectedExam;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(children: [
                SizedBox(width: 100, child: Text(exam,
                  style: TextStyle(fontSize: 11,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? AppTheme.primaryColor : Colors.black87))),
                Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: pct,
                    color: isSelected ? AppTheme.primaryColor : Colors.blue.withOpacity(0.5),
                    backgroundColor: Colors.grey.shade100, minHeight: 14))),
                const SizedBox(width: 8),
                Text('${(pct * 100).toStringAsFixed(0)}%',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold,
                    color: isSelected ? AppTheme.primaryColor : Colors.grey)),
              ]),
            );
          }),
        ]),
      )),
    ]),
  );

  // ?? Attendance Tab ??????????
  Widget _attendanceTab() => SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Summary
      Row(children: [
        _attCard('Present', '42', Colors.green),
        const SizedBox(width: 10),
        _attCard('Absent', '3',   Colors.red),
        const SizedBox(width: 10),
        _attCard('Late', '2',     Colors.orange),
        const SizedBox(width: 10),
        _attCard('Total', '47',   Colors.blue),
      ]),
      const SizedBox(height: 16),

      // Overall attendance gauge
      Card(child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          const Text('Overall Attendance', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 16),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            SizedBox(width: 120, height: 120, child: Stack(children: [
              CircularProgressIndicator(
                value: 42/47, strokeWidth: 12,
                color: Colors.green, backgroundColor: Colors.green.withOpacity(0.1)),
              const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text('89.3%', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
                Text('Attendance', style: TextStyle(fontSize: 10, color: Colors.grey)),
              ])),
            ])),
          ]),
          const SizedBox(height: 12),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            _legend('Present 42', Colors.green),
            const SizedBox(width: 16),
            _legend('Absent 3', Colors.red),
            const SizedBox(width: 16),
            _legend('Late 2', Colors.orange),
          ]),
        ]),
      )),
      const SizedBox(height: 16),

      // Monthly trend
      const Text('Monthly Attendance Trend', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      const SizedBox(height: 8),
      Card(child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(children: [
          SizedBox(
            height: 150,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: _attendanceTrend.map((m) {
                final pct = m['pct'] as double;
                final color = pct >= 0.9 ? Colors.green : pct >= 0.75 ? Colors.orange : Colors.red;
                return Column(mainAxisAlignment: MainAxisAlignment.end, children: [
                  Text('${(pct * 100).toStringAsFixed(0)}%',
                    style: TextStyle(fontSize: 9, color: color, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Container(
                    width: 32, height: 120 * pct,
                    decoration: BoxDecoration(color: color,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(4), topRight: Radius.circular(4)))),
                  const SizedBox(height: 4),
                  Text(m['month'] as String, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                ]);
              }).toList(),
            ),
          ),
        ]),
      )),
      const SizedBox(height: 16),

      // Recent attendance
      const Text('Recent Attendance', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      const SizedBox(height: 8),
      ...[
        ['17 Jun 2026', 'present'], ['16 Jun 2026', 'present'],
        ['15 Jun 2026', 'absent'],  ['14 Jun 2026', 'late'],
        ['13 Jun 2026', 'present'], ['12 Jun 2026', 'present'],
      ].map((a) {
        final color = a[1] == 'present' ? Colors.green : a[1] == 'absent' ? Colors.red : Colors.orange;
        final icon  = a[1] == 'present' ? Icons.check_circle : a[1] == 'absent' ? Icons.cancel : Icons.timelapse;
        return Card(
          margin: const EdgeInsets.only(bottom: 6),
          child: ListTile(
            dense: true,
            leading: Icon(icon, color: color),
            title: Text(a[0], style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
              child: Text(a[1].toUpperCase(),
                style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.bold))),
          ),
        );
      }),
    ]),
  );

  // ?? Overview Tab ??????
  Widget _overviewTab() => SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Student info
      Card(child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(children: [
          CircleAvatar(radius: 30,
            backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
            child: const Text('R', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.primaryColor))),
          const SizedBox(width: 14),
          const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Rahul Kumar', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Text('Class 10-A  Roll: R001', style: TextStyle(color: Colors.grey, fontSize: 12)),
            Text('Admission: ADM001', style: TextStyle(color: Colors.grey, fontSize: 12)),
          ])),
        ]),
      )),
      const SizedBox(height: 16),

      // Performance summary
      const Text('Performance Summary', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      const SizedBox(height: 8),
      GridView.count(
        shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10,
        childAspectRatio: 1.5,
        children: [
          _perfCard('Best Subject', 'Mathematics', '92%',  Colors.blue),
          _perfCard('Weak Subject', 'English', '78%',  Colors.orange),
          _perfCard('Attendance', '89.3%', '42/47',Colors.green),
          _perfCard('Class Rank', '3rd', 'Top 10%', Colors.purple),
        ],
      ),
      const SizedBox(height: 16),

      // Strengths and improvements
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(child: Card(
          color: Colors.green.shade50,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Row(children: [
                Icon(Icons.thumb_up, color: Colors.green, size: 18),
                SizedBox(width: 6),
                Text('Strengths', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 13)),
              ]),
              const SizedBox(height: 8),
              ...[
        'Excellent in Math',
        'Regular attendance',
        'Submits homework',
        'Active in class',
              ].map((s) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(children: [
                  const Icon(Icons.check, size: 14, color: Colors.green),
                  const SizedBox(width: 4),
                  Text(s, style: const TextStyle(fontSize: 11)),
                ]),
              )),
            ]),
          ),
        )),
        const SizedBox(width: 10),
        Expanded(child: Card(
          color: Colors.orange.shade50,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Row(children: [
                Icon(Icons.trending_up, color: Colors.orange, size: 18),
                SizedBox(width: 6),
                Text('Improve', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange, fontSize: 13)),
              ]),
              const SizedBox(height: 8),
              ...[
        'English writing',
        'Science practicals',
        'Social Science',
        'Punctuality',
              ].map((s) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(children: [
                  const Icon(Icons.arrow_right, size: 14, color: Colors.orange),
                  const SizedBox(width: 4),
                  Text(s, style: const TextStyle(fontSize: 11)),
                ]),
              )),
            ]),
          ),
        )),
      ]),
    ]),
  );

  // ?? Helpers ???????????
  Widget _rankBadge() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(color: Colors.amber.withOpacity(0.1), borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.amber.withOpacity(0.3))),
    child: const Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(Icons.military_tech, size: 14, color: Colors.amber),
      SizedBox(width: 4),
      Text('Rank 3', style: TextStyle(fontSize: 11, color: Colors.amber, fontWeight: FontWeight.bold)),
    ]),
  );

  Widget _attCard(String label, String value, Color color) => Expanded(
    child: Card(child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(children: [
        Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ]),
    )));

  Widget _perfCard(String label, String value, String sub, Color color) => Card(
    child: Padding(padding: const EdgeInsets.all(12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
        Text(sub, style: TextStyle(fontSize: 11, color: color)),
      ]),
    ));

  Widget _legend(String label, Color color) => Row(children: [
    Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
    const SizedBox(width: 4),
    Text(label, style: const TextStyle(fontSize: 11)),
  ]);

  Color _subjectColor(String subject) {
    final colors = {
        'Mathematics': Colors.blue, 'Science': Colors.green,
        'English': Colors.purple, 'Hindi': Colors.orange,
        'Social Science': Colors.teal, 'Computer': Colors.indigo,
    };
    return colors[subject] ?? Colors.blue;
  }

  Color _gradeToColor(String grade) {
    if (grade == 'A+' || grade == 'A') return Colors.green;
    if (grade == 'B+' || grade == 'B') return Colors.orange;
    return Colors.red;
  }
}


