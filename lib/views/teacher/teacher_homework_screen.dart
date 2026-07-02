import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';

class TeacherHomeworkScreen extends StatefulWidget {
  const TeacherHomeworkScreen({super.key});
  @override
  State<TeacherHomeworkScreen> createState() => _TeacherHomeworkScreenState();
}

class _TeacherHomeworkScreenState extends State<TeacherHomeworkScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final _homeworks = [
    {'title': 'Math Assignment Ch.5', 'class': 'Class 10-A', 'due': '20 Jun 2025', 'submitted': 22, 'total': 28, 'status': 'active'},
    {'title': 'Algebra Problems', 'class': 'Class 9-B', 'due': '18 Jun 2025', 'submitted': 18, 'total': 25, 'status': 'active'},
    {'title': 'Geometry Worksheet', 'class': 'Class 10-B', 'due': '15 Jun 2025', 'submitted': 20, 'total': 22, 'status': 'completed'},
    {'title': 'Trigonometry Practice','class': 'Class 8-A', 'due': '22 Jun 2025', 'submitted': 5, 'total': 30, 'status': 'active'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() { _tabController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Homework'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => context.go('/dashboard/staff'),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [Tab(text: 'All Homework'), Tab(text: 'Create New')],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_homeworkList(), _createHomework()],
      ),
    );
  }

  Widget _homeworkList() => ListView.builder(
    padding: const EdgeInsets.all(14),
    itemCount: _homeworks.length,
    itemBuilder: (context, i) {
      final h = _homeworks[i];
      final pct = (h['submitted'] as int) / (h['total'] as int);
      final color = h['status'] == 'completed' ? Colors.green : Colors.blue;
      return Card(
        margin: const EdgeInsets.only(bottom: 10),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => context.push('/teacher/homework/submissions',
            extra: {'title': h['title'], 'class': h['class'], 'due': h['due']}),
          child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Expanded(child: Text(h['title'] as String,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: Text((h['status'] as String).toUpperCase(),
                  style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.bold))),
            ]),
            const SizedBox(height: 6),
            Text('${h['class']} - Due: ${h['due']}',
              style: const TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 10),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('${h['submitted']}/${h['total']} submitted',
                style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w500)),
              Text('${(pct * 100).toStringAsFixed(0)}%',
                style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.bold)),
            ]),
            const SizedBox(height: 4),
            ClipRRect(borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(value: pct, color: color,
                backgroundColor: color.withOpacity(0.1), minHeight: 8)),
            const SizedBox(height: 8),
            Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              Text('Tap to mark submissions', style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right, size: 16, color: Colors.grey),
            ]),
          ]),
        )),
      );
    },
  );

  Widget _createHomework() {
    final _title = TextEditingController();
    final _desc = TextEditingController();
    String cls = 'Class 1';

    return StatefulBuilder(builder: (context, setS) =>
      SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Create New Homework',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          TextField(controller: _title,
            decoration: const InputDecoration(labelText: 'Homework Title *', prefixIcon: Icon(Icons.assignment))),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: cls,
            decoration: const InputDecoration(labelText: 'Class', prefixIcon: Icon(Icons.class_)),
            items: ['Nursery','LKG','UKG','Class 1','Class 2','Class 3','Class 4','Class 5','Class 6','Class 7','Class 8','Class 9','Class 10','Class 11','Class 12']
              .map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
            onChanged: (v) => setS(() => cls = v!),
          ),
          const SizedBox(height: 12),
          TextFormField(
            readOnly: true,
            decoration: const InputDecoration(labelText: 'Due Date', prefixIcon: Icon(Icons.calendar_today)),
            onTap: () async {
              await showDatePicker(context: context,
                initialDate: DateTime.now().add(const Duration(days: 3)),
                firstDate: DateTime.now(), lastDate: DateTime(2026));
            },
          ),
          const SizedBox(height: 12),
          TextField(controller: _desc, maxLines: 4,
            decoration: const InputDecoration(labelText: 'Description / Instructions',
              prefixIcon: Icon(Icons.description), alignLabelWithHint: true)),
          const SizedBox(height: 24),
          SizedBox(width: double.infinity, child: ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Homework assigned!'), backgroundColor: Colors.green));
              _title.clear(); _desc.clear();
            },
            icon: const Icon(Icons.send),
            label: const Text('Assign Homework'),
          )),
        ]),
      ),
    );
  }
}





