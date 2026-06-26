import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/student_provider.dart';
import '../../core/theme/app_theme.dart';

class StudentDetailScreen extends StatefulWidget {
  final int studentId;
  const StudentDetailScreen({super.key, required this.studentId});
  @override
  State<StudentDetailScreen> createState() => _StudentDetailScreenState();
}

class _StudentDetailScreenState extends State<StudentDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StudentProvider>().fetchStudents().then((_) {
        context.read<StudentProvider>().selectStudent(widget.studentId);
      });
    });
  }

  @override
  void dispose() { _tabController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final student = context.watch<StudentProvider>().selectedStudent;
    if (student == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => context.go('/students'),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.edit), onPressed: () => context.go('/students/${student.id}/edit')),
        ],
      ),
      body: Column(children: [
        Container(
          color: AppTheme.primaryColor,
          padding: const EdgeInsets.fromLTRB(20,16,20,24),
          child: Row(children: [
            CircleAvatar(radius: 36, backgroundColor: Colors.white.withOpacity(0.2),
              child: Text(student.name[0], style: const TextStyle(fontSize: 28, color: Colors.white, fontWeight: FontWeight.bold))),
            const SizedBox(width: 16),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(student.name, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              Text('${student.className}-${student.section} - Roll: ${student.rollNo}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
              Text('Adm: ${student.admissionNo}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
              const SizedBox(height: 6),
              Row(children: [
                _badge(student.status == 'active' ? 'ACTIVE' : 'INACTIVE', student.status == 'active' ? Colors.green : Colors.red),
                const SizedBox(width: 6),
                _badge(student.bloodGroup, Colors.red.shade700),
                const SizedBox(width: 6),
                _badge(student.gender, Colors.blue),
              ]),
            ])),
          ]),
        ),
        TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppTheme.primaryColor,
          tabs: const [
            Tab(text: 'Personal'), Tab(text: 'Academic'), Tab(text: 'Attendance'),
            Tab(text: 'Fees'), Tab(text: 'Health'), Tab(text: 'Transport'),
          ],
        ),
        Expanded(child: TabBarView(controller: _tabController, children: [
          _personalTab(student),
          _academicTab(),
          _attendanceTab(),
          _feesTab(),
          _healthTab(student),
          _transportTab(student),
        ])),
      ]),
    );
  }

  Widget _personalTab(StudentModel s) => SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Column(children: [
      _infoCard('Personal Details', [
        _row('Date of Birth', s.dob),
        _row('Gender', s.gender),
        _row('Blood Group', s.bloodGroup),
        _row('Phone', s.phone),
        _row('Email', s.email),
        _row('Address', s.address),
        _row('Admission Date', s.admissionDate),
      ]),
      const SizedBox(height: 12),
      _infoCard('Parent / Guardian', [
        _row('Father Name', s.fatherName),
        _row('Mother Name', s.motherName),
        _row('Parent Phone', s.parentPhone),
        _row('Parent Email', s.parentEmail),
        _row('Occupation', s.parentOccupation),
        _row('Emergency Contact', s.emergencyContact),
      ]),
    ]),
  );

  Widget _academicTab() => SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Column(children: [
      Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Mid-Term Results 2025', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 4),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('Total: 418/500', style: TextStyle(color: Colors.grey, fontSize: 12)),
          Text('83.6% - Grade A', style: TextStyle(color: Colors.green.shade700, fontWeight: FontWeight.bold, fontSize: 12)),
        ]),
        const Divider(),
        ...[ ['Mathematics','92','100','A+'], ['Science','85','100','A'], ['English','78','100','B+'],
             ['Hindi','88','100','A'], ['Social Science','75','100','B+'] ].map((r) =>
          Padding(padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(children: [
              Expanded(child: Text(r[0], style: const TextStyle(fontSize: 13))),
              Text('${r[1]}/${r[2]}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
              const SizedBox(width: 12),
              Container(width: 36, padding: const EdgeInsets.symmetric(vertical: 2),
                decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                child: Text(r[3], textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.green))),
            ])),
        ),
      ]))),
      const SizedBox(height: 12),
      Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Subjects Enrolled', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 10),
        Wrap(spacing: 8, runSpacing: 8, children: ['Mathematics','Science','English','Hindi','Social Science','Computer']
          .map((s) => Chip(label: Text(s, style: const TextStyle(fontSize: 12)),
            backgroundColor: AppTheme.primaryColor.withOpacity(0.1))).toList()),
      ]))),
    ]),
  );

  Widget _attendanceTab() => SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Column(children: [
      Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('This Month Summary', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 12),
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          _attStat('Present','20',Colors.green), _attStat('Absent','2',Colors.red),
          _attStat('Late','1',Colors.orange), _attStat('Total','23',Colors.blue),
        ]),
        const SizedBox(height: 12),
        ClipRRect(borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(value: 20/23, backgroundColor: Colors.red.withOpacity(0.2),
            color: Colors.green, minHeight: 10)),
        const SizedBox(height: 4),
        const Text('Attendance: 86.9%', style: TextStyle(fontSize: 12, color: Colors.grey)),
      ]))),
      const SizedBox(height: 12),
      Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Recent Attendance', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 10),
        ...[['16 Jun','present'],['15 Jun','present'],['14 Jun','absent'],['13 Jun','present'],['12 Jun','late']].map((a) {
          final color = a[1]=='present' ? Colors.green : a[1]=='absent' ? Colors.red : Colors.orange;
          return ListTile(dense: true,
            leading: Icon(a[1]=='present' ? Icons.check_circle : a[1]=='absent' ? Icons.cancel : Icons.access_time, color: color),
            title: Text(a[0], style: const TextStyle(fontSize: 13)),
            trailing: Text(a[1].toUpperCase(), style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 11)));
        }),
      ]))),
    ]),
  );

  Widget _feesTab() => SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Column(children: [
      Card(child: Padding(padding: const EdgeInsets.all(16),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          _feeSum('Total','₹18,000',Colors.blue), _feeSum('Paid','₹14,500',Colors.green), _feeSum('Pending','₹1,500',Colors.red),
        ]))),
      const SizedBox(height: 12),
      ...[['Tuition Fee','₹12,500','paid','15 Jun'],['Transport Fee','₹1,500','pending','15 Jun'],['Exam Fee','₹1,000','paid','01 Jun']].map((f) =>
        Card(margin: const EdgeInsets.only(bottom: 8), child: ListTile(
          title: Text(f[0], style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          subtitle: Text('Due: ${f[3]}', style: const TextStyle(fontSize: 11)),
          trailing: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(f[1], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: f[2]=='paid' ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8)),
              child: Text(f[2].toUpperCase(), style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold,
                color: f[2]=='paid' ? Colors.green : Colors.red))),
          ]),
        ))),
    ]),
  );

  Widget _healthTab(StudentModel s) => SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Column(children: [
      _infoCard('Health Information', [
        _row('Blood Group', s.bloodGroup),
        _row('Medical Conditions', s.medicalInfo.isEmpty ? 'None' : s.medicalInfo),
        _row('Allergies', 'None'), _row('Height', '165 cm'), _row('Weight', '55 kg'),
      ]),
      const SizedBox(height: 12),
      _infoCard('Vaccination', [
        _row('Hepatitis B','Completed'), _row('MMR','Completed'),
        _row('Polio','Completed'), _row('Covid-19','Completed'),
      ]),
    ]),
  );

  Widget _transportTab(StudentModel s) => SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: _infoCard('Transport Details', [
      _row('Transport', s.transport),
      _row('Bus Route', s.busRoute.isEmpty ? 'N/A' : s.busRoute),
      _row('Vehicle No', 'DL 01 AB 1234'),
      _row('Driver', 'Suresh Kumar'),
      _row('Driver Phone', '9876543210'),
      _row('Pickup Time', '7:30 AM'),
      _row('Drop Time', '2:30 PM'),
    ]),
  );

  Widget _infoCard(String title, List<Widget> rows) => Card(
    child: Padding(padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const Divider(), ...rows,
      ])));

  Widget _row(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(children: [
      SizedBox(width: 140, child: Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12))),
      Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12))),
    ]));

  Widget _badge(String text, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10)),
    child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)));

  Widget _attStat(String label, String val, Color color) => Column(children: [
    Text(val, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
    Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey))]);

  Widget _feeSum(String label, String val, Color color) => Column(children: [
    Text(val, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
    Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey))]);
}




