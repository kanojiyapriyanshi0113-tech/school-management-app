import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/transport_provider.dart';
import '../../providers/student_provider.dart';
import '../../core/theme/app_theme.dart';

class TransportFeeScreen extends StatefulWidget {
  const TransportFeeScreen({super.key});
  @override
  State<TransportFeeScreen> createState() => _TransportFeeScreenState();
}

class _TransportFeeScreenState extends State<TransportFeeScreen> {
  String? _selectedClass;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TransportProvider>().fetchFees();
      context.read<StudentProvider>().fetchStudents();
    });
  }

  @override
  Widget build(BuildContext context) {
    final tp = context.watch<TransportProvider>();
    final sp = context.watch<StudentProvider>();

    // Students who have transport assigned
    final transportStudents = sp.students.where((s) =>
      s.transport.isNotEmpty || s.busRoute.isNotEmpty).toList();

    // Get class list from transport students
    final classes = transportStudents
      .map((s) => '${s.className}-${s.section}')
      .toSet().toList()..sort();

    // Filter by selected class
    final filtered = _selectedClass == null
      ? transportStudents
      : transportStudents.where((s) =>
          '${s.className}-${s.section}' == _selectedClass).toList();

    // Stats from fees
    final fees = tp.fees;
    final collected = fees.where((f) => f.status == 'paid').fold(0.0, (s, f) => s + f.amount);
    final pending = fees.where((f) => f.status == 'pending').fold(0.0, (s, f) => s + f.amount);

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      body: Column(children: [
        // Summary
        Container(
          color: Colors.white,
          padding: const EdgeInsets.all(14),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            _stat('Total Students', '${transportStudents.length}', Colors.blue),
            _stat('Collected', 'Rs ${collected.toStringAsFixed(0)}', Colors.green),
            _stat('Pending', 'Rs ${pending.toStringAsFixed(0)}', Colors.orange),
          ])),
        const SizedBox(height: 8),

        // Class filter
        if (classes.isNotEmpty)
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: SizedBox(
              height: 36,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _classBadge('All Classes', null),
                  ...classes.map((c) => _classBadge(c, c)),
                ],
              ),
            ),
          ),
        const SizedBox(height: 8),

        Expanded(
          child: tp.isLoading || sp.isLoading
            ? const Center(child: CircularProgressIndicator())
            : transportStudents.isEmpty
              ? Center(child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.directions_bus, size: 64, color: Colors.grey.shade300),
                    const SizedBox(height: 12),
                    const Text('No students assigned to transport',
                      style: TextStyle(color: Colors.grey)),
                    const SizedBox(height: 8),
                    const Text('Assign transport to students from Students tab',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                      textAlign: TextAlign.center),
                  ]))
              : RefreshIndicator(
                  onRefresh: () async {
                    await context.read<TransportProvider>().fetchFees();
                    await context.read<StudentProvider>().fetchStudents();
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(14),
                    itemCount: filtered.length,
                    itemBuilder: (ctx, i) {
                      final student = filtered[i];
                      // Find fees for this student
                      final studentFees = fees.where((f) => f.studentId == student.id).toList();
                      final paid = studentFees.where((f) => f.status == 'paid').fold(0.0, (s, f) => s + f.amount);
                      final pendingAmt = studentFees.where((f) => f.status != 'paid').fold(0.0, (s, f) => s + f.amount);

                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Row(children: [
                            // Avatar
                            CircleAvatar(
                              backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                              child: Text(
                                student.name.isNotEmpty ? student.name[0].toUpperCase() : '?',
                                style: const TextStyle(color: AppTheme.primaryColor,
                                  fontWeight: FontWeight.bold))),
                            const SizedBox(width: 12),
                            // Info
                            Expanded(child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(student.name,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                Text('${student.className}-${student.section} • Roll: ${student.rollNo}',
                                  style: const TextStyle(color: Colors.grey, fontSize: 11)),
                                if (student.busRoute.isNotEmpty)
                                  Text('Route: ${student.busRoute}',
                                    style: const TextStyle(color: Colors.blue, fontSize: 11)),
                                const SizedBox(height: 6),
                                Row(children: [
                                  _feeBadge('Paid: Rs ${paid.toStringAsFixed(0)}', Colors.green),
                                  const SizedBox(width: 8),
                                  if (pendingAmt > 0)
                                    _feeBadge('Due: Rs ${pendingAmt.toStringAsFixed(0)}', Colors.orange),
                                ]),
                              ])),
                            // Status
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: (pendingAmt == 0 && studentFees.isNotEmpty)
                                      ? Colors.green.withOpacity(0.1)
                                      : Colors.orange.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8)),
                                  child: Text(
                                    (pendingAmt == 0 && studentFees.isNotEmpty) ? 'PAID' : 'PENDING',
                                    style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold,
                                      color: (pendingAmt == 0 && studentFees.isNotEmpty)
                                        ? Colors.green : Colors.orange))),
                                const SizedBox(height: 4),
                                Text('${studentFees.length} record${studentFees.length != 1 ? 's' : ''}',
                                  style: const TextStyle(fontSize: 10, color: Colors.grey)),
                              ]),
                          ]),
                        ),
                      );
                    },
                  ),
                )),
      ]),
    );
  }

  Widget _classBadge(String label, String? cls) => GestureDetector(
    onTap: () => setState(() => _selectedClass = cls),
    child: Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: _selectedClass == cls ? AppTheme.primaryColor : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20)),
      child: Text(label,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
          color: _selectedClass == cls ? Colors.white : Colors.grey.shade700))));

  Widget _stat(String label, String val, Color color) => Column(children: [
    Text(val, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
    Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
  ]);

  Widget _feeBadge(String text, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
    child: Text(text, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w600)));
}