import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/language_provider.dart';

class TeacherAttendanceScreen extends StatefulWidget {
  const TeacherAttendanceScreen({super.key});
  @override
  State<TeacherAttendanceScreen> createState() => _TeacherAttendanceScreenState();
}

class _TeacherAttendanceScreenState extends State<TeacherAttendanceScreen> {
  String _selectedClass = 'Class 1';
  DateTime _date = DateTime.now();
  bool _saving = false;

  final List<Map<String, dynamic>> _students = [
    {'name': 'Rahul Kumar', 'roll': 'R001', 'status': 'present'},
    {'name': 'Priya Singh', 'roll': 'R002', 'status': 'present'},
    {'name': 'Amit Sharma', 'roll': 'R003', 'status': 'absent'},
    {'name': 'Sneha Patel', 'roll': 'R004', 'status': 'present'},
    {'name': 'Vijay Verma', 'roll': 'R005', 'status': 'late'},
    {'name': 'Anita Gupta', 'roll': 'R006', 'status': 'present'},
    {'name': 'Ravi Kumar', 'roll': 'R007', 'status': 'present'},
    {'name': 'Meena Singh', 'roll': 'R008', 'status': 'present'},
  ];

  int get _present => _students.where((s) => s['status'] == 'present').length;
  int get _absent  => _students.where((s) => s['status'] == 'absent').length;
  int get _late    => _students.where((s) => s['status'] == 'late').length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.watch<LanguageProvider>().t('mark_attendance')),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => context.go('/dashboard/staff'),
        ),
      ),
      body: Column(children: [
        // Controls
        Container(color: Colors.white, padding: const EdgeInsets.all(14),
          child: Column(children: [
            Row(children: [
              Expanded(child: DropdownButtonFormField<String>(
                value: _selectedClass,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
                items: ['Nursery','LKG','UKG','Class 1','Class 2','Class 3','Class 4','Class 5','Class 6','Class 7','Class 8','Class 9','Class 10','Class 11','Class 12']
                  .map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontSize: 13)))).toList(),
                onChanged: (v) => setState(() => _selectedClass = v!),
              )),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () async {
                  final d = await showDatePicker(context: context,
                    initialDate: _date, firstDate: DateTime(2024), lastDate: DateTime.now());
                  if (d != null) setState(() => _date = d);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)),
                  child: Row(children: [
                    const Icon(Icons.calendar_today, size: 16, color: AppTheme.primaryColor),
                    const SizedBox(width: 6),
                    Text('${_date.day}/${_date.month}/${_date.year}', style: const TextStyle(fontSize: 12)),
                  ])),
              ),
            ]),
            const SizedBox(height: 12),
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              _sum('Present', _present, Colors.green),
              _sum('Absent', _absent, Colors.red),
              _sum('Late', _late, Colors.orange),
              _sum('Total', _students.length, Colors.blue),
            ]),
          ])),
        const Divider(height: 1),

        // Mark all buttons
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Row(children: [
            const Text('Mark All:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            const SizedBox(width: 8),
            _markAllBtn('Present', Colors.green, 'present'),
            const SizedBox(width: 6),
            _markAllBtn('Absent', Colors.red, 'absent'),
          ]),
        ),

        // Students list
        Expanded(child: ListView.builder(
          itemCount: _students.length,
          itemBuilder: (context, i) {
            final s = _students[i];
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey.shade100))),
              child: Row(children: [
                CircleAvatar(radius: 16, backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                  child: Text(s['name'][0], style: const TextStyle(color: AppTheme.primaryColor, fontSize: 12, fontWeight: FontWeight.bold))),
                const SizedBox(width: 10),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(s['name'], style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  Text('Roll: ${s['roll']}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                ])),
                Row(children: [
                  _btn('P', 'present', Colors.green, s, i),
                  const SizedBox(width: 4),
                  _btn('A', 'absent', Colors.red, s, i),
                  const SizedBox(width: 4),
                  _btn('L', 'late', Colors.orange, s, i),
                ]),
              ]),
            );
          },
        )),

        // Save button
        SafeArea(child: Padding(
          padding: const EdgeInsets.all(14),
          child: SizedBox(width: double.infinity, child: ElevatedButton.icon(
            onPressed: _saving ? null : () async {
              setState(() => _saving = true);
              await Future.delayed(const Duration(seconds: 1));
              setState(() => _saving = false);
              if (mounted) ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Attendance saved successfully!'), backgroundColor: Colors.green));
            },
            icon: _saving
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Icon(Icons.save),
            label: Text(_saving ? 'Saving...' : 'Save Attendance'),
          )),
        )),
      ]),
    );
  }

  Widget _sum(String label, int count, Color color) => Column(children: [
    Text('$count', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
    Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
  ]);

  Widget _btn(String label, String val, Color color, Map s, int i) {
    final sel = s['status'] == val;
    return GestureDetector(
      onTap: () => setState(() => _students[i]['status'] = val),
      child: Container(
        width: 30, height: 30,
        decoration: BoxDecoration(
          color: sel ? color : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: sel ? color : Colors.grey.shade300)),
        child: Center(child: Text(label,
          style: TextStyle(color: sel ? Colors.white : Colors.grey, fontWeight: FontWeight.bold, fontSize: 11))),
      ),
    );
  }

  Widget _markAllBtn(String label, Color color, String status) => GestureDetector(
    onTap: () => setState(() {
      for (var s in _students) s['status'] = status;
    }),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3))),
      child: Text(label, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
    ),
  );
}




