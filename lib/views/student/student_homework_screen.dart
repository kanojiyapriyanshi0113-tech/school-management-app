import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';

class StudentHomeworkScreen extends StatefulWidget {
  const StudentHomeworkScreen({super.key});
  @override
  State<StudentHomeworkScreen> createState() => _StudentHomeworkScreenState();
}

class _StudentHomeworkScreenState extends State<StudentHomeworkScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final _homework = [
    {'subject': 'Mathematics', 'title': 'Ch.5 Assignment', 'due': '20 Jun 2025', 'teacher': 'Mr. Ravi Sharma', 'status': 'pending', 'desc': 'Complete exercises 5.1 to 5.5 from NCERT textbook.'},
    {'subject': 'English', 'title': 'Essay Writing', 'due': '22 Jun 2025', 'teacher': 'Mrs. Priya', 'status': 'pending', 'desc': 'Write a 500-word essay on "My Dream School".'},
    {'subject': 'Science', 'title': 'Lab Report', 'due': '25 Jun 2025', 'teacher': 'Mr. Kumar', 'status': 'pending', 'desc': 'Write the lab report for the photosynthesis experiment.'},
    {'subject': 'Hindi', 'title': 'Nibandh Lekhan', 'due': '15 Jun 2025', 'teacher': 'Mrs. Gupta', 'status': 'submitted', 'desc': 'Apne priye neta par nibandh likhiye.'},
    {'subject': 'Mathematics', 'title': 'Ch.4 Practice', 'due': '10 Jun 2025', 'teacher': 'Mr. Ravi Sharma', 'status': 'submitted', 'desc': 'Complete all practice problems from chapter 4.'},
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
    final pending   = _homework.where((h) => h['status'] == 'pending').toList();
    final submitted = _homework.where((h) => h['status'] == 'submitted').toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Homework'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => context.go('/dashboard/student'),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            Tab(text: 'Pending (${pending.length})'),
            Tab(text: 'Submitted (${submitted.length})'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _list(pending, true),
          _list(submitted, false),
        ],
      ),
    );
  }

  Widget _list(List items, bool isPending) {
    if (items.isEmpty) return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.assignment_turned_in, size: 64, color: Colors.grey.shade300),
        const SizedBox(height: 12),
        Text(isPending ? 'No pending homework!' : 'No submitted homework',
          style: const TextStyle(color: Colors.grey)),
      ]),
    );

    return ListView.builder(
      padding: const EdgeInsets.all(14),
      itemCount: items.length,
      itemBuilder: (context, i) {
        final h = items[i];
        final color = isPending ? Colors.orange : Colors.green;
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(width: 44, height: 44,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10)),
                  child: Icon(Icons.assignment, color: color)),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(h['title'] as String,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  Text(h['subject'] as String,
                    style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w500)),
                ])),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                  child: Text((h['status'] as String).toUpperCase(),
                    style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.bold))),
              ]),
              const Divider(height: 14),
              Text(h['desc'] as String, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 8),
              Row(children: [
                const Icon(Icons.person, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(h['teacher'] as String, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                const Spacer(),
                const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text('Due: ${h['due']}',
                  style: TextStyle(fontSize: 11, color: isPending ? Colors.red : Colors.grey,
                    fontWeight: isPending ? FontWeight.w600 : FontWeight.normal)),
              ]),
            ]),
          ),
        );
      },
    );
  }
}


