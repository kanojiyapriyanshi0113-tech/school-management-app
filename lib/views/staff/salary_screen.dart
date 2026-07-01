import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/staff_provider.dart';
import '../../providers/auth_provider.dart';
import '../../core/theme/app_theme.dart';

class SalaryScreen extends StatefulWidget {
  const SalaryScreen({super.key});
  @override
  State<SalaryScreen> createState() => _SalaryScreenState();
}

class _SalaryScreenState extends State<SalaryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StaffProvider>().fetchStaff();
    });
  }

  @override
  void dispose() { _tabController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final role = context.watch<AuthProvider>().user?.role;
    final isAdmin = role == 'admin';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Salary & Payroll'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () {
            final r = context.read<AuthProvider>().user?.role;
            context.go(r == 'staff' ? '/dashboard/staff' : '/dashboard/admin');
          },
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [Tab(text: 'Salary List'), Tab(text: 'Salary Slip')],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_salaryList(isAdmin), _salarySlip()],
      ),
    );
  }

  Widget _salaryList(bool isAdmin) {
    final salaries = context.watch<StaffProvider>().salaries;
    final totalPaid = salaries.where((s) => s.status == 'paid').fold(0.0, (sum, s) => sum + s.netSalary);
    final totalPending = salaries.where((s) => s.status == 'pending').fold(0.0, (sum, s) => sum + s.netSalary);

    return Column(children: [
      // Summary
      Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          _sumCard('Total Paid', '₹${totalPaid.toStringAsFixed(0)}', Colors.green),
          _sumCard('Pending', '₹${totalPending.toStringAsFixed(0)}', Colors.orange),
          _sumCard('Staff', '${salaries.length}', Colors.blue),
        ]),
      ),
      const Divider(height: 1),
      Expanded(child: ListView.builder(
        padding: const EdgeInsets.all(14),
        itemCount: salaries.length,
        itemBuilder: (context, i) {
          final sal = salaries[i];
          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text(sal.staffName,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: sal.status == 'paid'
                        ? Colors.green.withOpacity(0.1)
                        : Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(sal.status.toUpperCase(),
                      style: TextStyle(
                        color: sal.status == 'paid' ? Colors.green : Colors.orange,
                        fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ]),
                const SizedBox(height: 4),
                Text(sal.month, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 8),
                Row(children: [
                  Expanded(child: _salRow('Basic', '₹${sal.basicSalary.toStringAsFixed(0)}')),
                  Expanded(child: _salRow('HRA', '₹${sal.hra.toStringAsFixed(0)}')),
                  Expanded(child: _salRow('TA', '₹${sal.ta.toStringAsFixed(0)}')),
                ]),
                const Divider(),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('Gross: "₹${sal.grossSalary.toStringAsFixed(0)}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  Text('Deduction: "₹${sal.totalDeduction.toStringAsFixed(0)}',
                    style: const TextStyle(fontSize: 12, color: Colors.red)),
                  Text('Net: "₹${sal.netSalary.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor)),
                ]),
                // Mark as Paid ? sirf Admin dekh sakta hai
                if (isAdmin && sal.status == 'pending') ...[
                  const SizedBox(height: 10),
                  SizedBox(width: double.infinity, child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 8)),
                    child: const Text('Mark as Paid', style: TextStyle(fontSize: 12)),
                  )),
                ],
              ]),
            ),
          );
        },
      )),
    ]);
  }

  Widget _salarySlip() => SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Card(child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Center(child: Column(children: [
          const Icon(Icons.school, size: 40, color: AppTheme.primaryColor),
          const Text('School Management System',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const Text('Salary Slip - June 2025',
            style: TextStyle(color: Colors.grey, fontSize: 13)),
          const Divider(),
        ])),
        const SizedBox(height: 10),
        _slipRow('Employee Name', 'Dr. Rajesh Kumar'),
        _slipRow('Employee ID', 'EMP001'),
        _slipRow('Designation', 'Principal'),
        _slipRow('Department', 'Administration'),
        _slipRow('Month', 'June 2025'),
        const Divider(),
        const Text('Earnings', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
        const SizedBox(height: 8),
        _slipRow('Basic Salary', 'Rs \10,000'),
        _slipRow('HRA (25%)', 'Rs \10,000'),
        _slipRow('Transport Allowance', 'Rs \1,000'),
        _slipRow('Other Allowance', 'Rs \1,000'),
        _slipRow('Gross Salary', 'Rs \1,10,000', bold: true),
        const Divider(),
        const Text('Deductions', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
        const SizedBox(height: 8),
        _slipRow('PF (12%)', 'Rs \1,600'),
        _slipRow('Income Tax', 'Rs \1,000'),
        _slipRow('Total Deductions', 'Rs \17,600', bold: true, color: Colors.red),
        const Divider(),
        _slipRow('Net Salary', 'Rs \12,400', bold: true, color: AppTheme.primaryColor),
        const SizedBox(height: 20),
        SizedBox(width: double.infinity, child: ElevatedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.download),
          label: const Text('Download Salary Slip'),
        )),
      ]),
    )),
  );

  Widget _sumCard(String label, String value, Color color) => Column(children: [
    Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
    Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
  ]);

  Widget _salRow(String label, String value) => Column(children: [
    Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
    Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
  ]);

  Widget _slipRow(String label, String value, {bool bold = false, Color? color}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(children: [
      Expanded(child: Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey))),
      Text(value, style: TextStyle(fontSize: 12,
        fontWeight: bold ? FontWeight.bold : FontWeight.normal,
        color: color ?? Colors.black87)),
    ]),
  );
}

