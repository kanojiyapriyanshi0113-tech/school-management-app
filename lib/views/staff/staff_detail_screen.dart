import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../core/theme/app_theme.dart';

class StaffDetailScreen extends StatelessWidget {
  final int staffId;
  const StaffDetailScreen({super.key, required this.staffId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white), onPressed: () => context.go((() { final role = context.read<AuthProvider>().user?.role; return role == 'staff' ? '/dashboard/staff' : role == 'student' ? '/dashboard/student' : role == 'parent' ? '/dashboard/parent' : '/dashboard/admin'; })())),
        title: const Text('Staff Profile'),
        actions: [
          IconButton(icon: const Icon(Icons.edit), onPressed: () => context.go('/staff/$staffId/edit')),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(children: [
          // Header
          Container(
            width: double.infinity,
            color: AppTheme.primaryColor,
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
            child: Column(children: [
              CircleAvatar(radius: 40, backgroundColor: Colors.white.withOpacity(0.2),
                child: const Text('R', style: TextStyle(fontSize: 32, color: Colors.white, fontWeight: FontWeight.bold))),
              const SizedBox(height: 12),
              const Text('Dr. Rajesh Kumar', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              const Text('Principal ??? Administration', style: TextStyle(color: Colors.white70, fontSize: 13)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(12)),
                child: const Text('ACTIVE', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
              ),
            ]),
          ),

          // Tabs
          DefaultTabController(
            length: 5,
            child: Column(children: [
              const TabBar(
                isScrollable: true,
                labelColor: AppTheme.primaryColor,
                unselectedLabelColor: Colors.grey,
                indicatorColor: AppTheme.primaryColor,
                tabs: [
                  Tab(text: 'Personal'),
                  Tab(text: 'Professional'),
                  Tab(text: 'Attendance'),
                  Tab(text: 'Salary'),
                  Tab(text: 'Documents'),
                ],
              ),
              SizedBox(
                height: 450,
                child: TabBarView(children: [
                  _personalInfo(),
                  _professionalInfo(),
                  _attendanceInfo(),
                  _salaryInfo(),
                  _documentsInfo(),
                ]),
              ),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _personalInfo() => SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Column(children: [
      _infoCard('Personal Details', [
        _row('Employee ID', 'EMP001'),
        _row('Date of Birth', '15 Mar 1970'),
        _row('Gender', 'Male'),
        _row('Phone', '+91 9876543210'),
        _row('Email', 'principal@school.com'),
        _row('Address', '123 MG Road, Delhi'),
      ]),
    ]),
  );

  Widget _professionalInfo() => SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Column(children: [
      _infoCard('Professional Details', [
        _row('Designation', 'Principal'),
        _row('Department', 'Administration'),
        _row('Joining Date', '01 Jan 2010'),
        _row('Qualification', 'PhD Education'),
        _row('Experience', '20 years'),
        _row('Role', 'Principal'),
      ]),
    ]),
  );

  Widget _attendanceInfo() => SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Column(children: [
      _infoCard('This Month Attendance', [
        _row('Working Days', '22'),
        _row('Present', '20'),
        _row('Absent', '1'),
        _row('Half Day', '1'),
        _row('Leave Taken', '1'),
        _row('Attendance %', '90.9%'),
      ]),
      const SizedBox(height: 12),
      Card(child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Leave Balance', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _leaveBalance('Casual Leave', 8, 12),
          _leaveBalance('Sick Leave', 5, 10),
          _leaveBalance('Earned Leave', 15, 30),
        ]),
      )),
    ]),
  );

  Widget _salaryInfo() => SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Column(children: [
      _infoCard('June 2025 Salary', [
        _row('Basic Salary', '₹10,000'),
        _row('HRA', '₹10,000'),
        _row('TA', '₹1,000'),
        _row('Other Allowance', '₹1,000'),
        _row('Gross Salary', '₹1,10,000'),
        _row('PF Deduction', '₹1,600'),
        _row('Tax', '₹1,000'),
        _row('Net Salary', '₹12,400'),
      ]),
    ]),
  );

  Widget _documentsInfo() => SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Column(children: [
      _docItem('Appointment Letter', 'PDF', '01 Jan 2010'),
      _docItem('Aadhaar Card', 'PDF', '15 Mar 2015'),
      _docItem('PAN Card', 'PDF', '15 Mar 2015'),
      _docItem('PhD Certificate', 'PDF', '01 Jun 2005'),
      _docItem('Employee ID Card', 'Image', '01 Jan 2010'),
    ]),
  );

  Widget _infoCard(String title, List<Widget> rows) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const Divider(),
        ...rows,
      ]),
    ),
  );

  Widget _row(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(children: [
      SizedBox(width: 130, child: Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12))),
      Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12))),
    ]),
  );

  Widget _leaveBalance(String type, int used, int total) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(type, style: const TextStyle(fontSize: 12)),
        Text('$used/$total used', style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ]),
      const SizedBox(height: 4),
      LinearProgressIndicator(
        value: used / total,
        backgroundColor: Colors.grey.shade200,
        color: AppTheme.primaryColor,
      ),
    ]),
  );

  Widget _docItem(String name, String type, String date) => Card(
    margin: const EdgeInsets.only(bottom: 8),
    child: ListTile(
      leading: Icon(type == 'PDF' ? Icons.picture_as_pdf : Icons.image,
        color: type == 'PDF' ? Colors.red : Colors.blue),
      title: Text(name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
      subtitle: Text('$type ??? Uploaded: $date', style: const TextStyle(fontSize: 11)),
      trailing: Row(mainAxisSize: MainAxisSize.min, children: [
        IconButton(icon: const Icon(Icons.visibility, size: 20, color: AppTheme.primaryColor), onPressed: () {}),
        IconButton(icon: const Icon(Icons.download, size: 20, color: Colors.grey), onPressed: () {}),
      ]),
    ),
  );
}







