import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class MarksEntryScreen extends StatefulWidget {
  final int examId;
  const MarksEntryScreen({super.key, this.examId = 0});
  @override
  State<MarksEntryScreen> createState() => _MarksEntryScreenState();
}

class _MarksEntryScreenState extends State<MarksEntryScreen> {
  final List<Map<String, dynamic>> _students = [
    {'name': 'Rahul Kumar', 'roll': 'R001', 'marks': TextEditingController()},
    {'name': 'Priya Singh', 'roll': 'R002', 'marks': TextEditingController()},
    {'name': 'Amit Sharma', 'roll': 'R003', 'marks': TextEditingController()},
    {'name': 'Sneha Patel', 'roll': 'R004', 'marks': TextEditingController()},
    {'name': 'Vijay Verma', 'roll': 'R005', 'marks': TextEditingController()},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white), onPressed: () => context.go((() { final role = context.read<AuthProvider>().user?.role; return role == 'staff' ? '/dashboard/staff' : role == 'student' ? '/dashboard/student' : role == 'parent' ? '/dashboard/parent' : '/dashboard/admin'; })())),title: const Text('Marks Entry')),
      body: Column(children: [
        Container(
          color: Colors.white, padding: const EdgeInsets.all(14),
          child: Row(children: [
            Expanded(child: DropdownButtonFormField<String>(
              value: 'Mid-Term Exam',
              decoration: const InputDecoration(labelText: 'Exam', contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8)),
              items: ['Mid-Term Exam','Unit Test 1','Annual Exam']
                .map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (_) {},
            )),
            const SizedBox(width: 10),
            Expanded(child: DropdownButtonFormField<String>(
              value: 'Mathematics',
              decoration: const InputDecoration(labelText: 'Subject', contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8)),
              items: ['Mathematics','Science','English','Hindi','Social Science']
                .map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
              onChanged: (_) {},
            )),
          ]),
        ),
        const Divider(height: 1),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(children: const [
            Expanded(flex: 3, child: Text('Student', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey))),
            Expanded(flex: 2, child: Text('Marks (out of 100)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey), textAlign: TextAlign.center)),
          ]),
        ),
        const Divider(height: 1),
        Expanded(child: ListView.builder(
          itemCount: _students.length,
          itemBuilder: (context, i) {
            final s = _students[i];
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey.shade100))),
              child: Row(children: [
                Expanded(flex: 3, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(s['name'], style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  Text(s['roll'], style: const TextStyle(fontSize: 10, color: Colors.grey)),
                ])),
                Expanded(flex: 2, child: TextFormField(
                  controller: s['marks'],
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    hintText: '0-100',
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                )),
              ]),
            );
          },
        )),
        SafeArea(child: Padding(
          padding: const EdgeInsets.all(14),
          child: SizedBox(width: double.infinity, child: ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Marks saved!'), backgroundColor: Colors.green));
            },
            child: const Text('Save Marks'),
          )),
        )),
      ]),
    );
  }
}