// lib/views/hostel/student_hostel_screen.dart
// CHANGES:
//   1. "Add Complaint" FAB added for students
//   2. _showAddComplaintDialog() -> real API call via HostelProvider.submitComplaint()

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/hostel_provider.dart';
import '../../providers/auth_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../models/hostel_model.dart';
import '../../services/api_service.dart';

class StudentHostelScreen extends StatelessWidget {
  const StudentHostelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<HostelProvider>();
    final role = context.read<AuthProvider>().user?.role;
    final isAdmin = role == 'admin' || role == 'staff';
    final isStudent = role == 'student';

    return Scaffold(
      // ADD COMPLAINT FAB - sirf student ke liye dikhega
      floatingActionButton: isStudent
          ? FloatingActionButton.extended(
              onPressed: () => _showAddComplaintDialog(context),
              icon: const Icon(Icons.report_problem_outlined),
              label: const Text('Add Complaint'),
              backgroundColor: AppTheme.primaryColor,
            )
          : null,
      body: p.isLoading
          ? const Center(child: CircularProgressIndicator())
          : p.students.isEmpty
              ? Center(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                      Icon(Icons.hotel,
                          size: 64, color: Colors.grey.shade300),
                      const SizedBox(height: 12),
                      const Text('No hostel students found',
                          style: TextStyle(color: Colors.grey)),
                      if (isAdmin) ...[
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: () =>
                              context.go('/hostel/admission'),
                          icon: const Icon(Icons.add),
                          label: const Text('Allocate Room'),
                        ),
                      ],
                    ]))
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 100),
                  itemCount: p.students.length,
                  itemBuilder: (context, i) {
                    final s = p.students[i];
                    final statusColors = {
        'paid': Colors.green,
        'pending': Colors.orange,
        'overdue': Colors.red,
                    };
                    final color =
                        statusColors[s.feeStatus] ?? Colors.grey;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Header
                              Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(children: [
                                      CircleAvatar(
                                          backgroundColor: AppTheme
                                              .primaryColor
                                              .withOpacity(0.1),
                                          child: Text(
                                              s.studentName.isNotEmpty
                                                  ? s.studentName[0]
                                                      .toUpperCase()
                                                  : 'S',
                                              style: const TextStyle(
                                                  color:
                                                      AppTheme.primaryColor,
                                                  fontWeight:
                                                      FontWeight.bold))),
                                      const SizedBox(width: 10),
                                      Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(s.studentName,
                                                style: const TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold,
                                                    fontSize: 14)),
                                            Text(
        '${s.admissionNo} • ${s.className}-${s.section}',
                                                style: const TextStyle(
                                                    fontSize: 11,
                                                    color: Colors.grey)),
                                          ]),
                                    ]),
                                    Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                            color:
                                                color.withOpacity(0.1),
                                            borderRadius:
                                                BorderRadius.circular(8)),
                                        child: Text(
                                            s.feeStatus.toUpperCase(),
                                            style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: color))),
                                  ]),
                              const Divider(height: 14),

                              // Details
                              Row(children: [
                                Expanded(
                                    child: _info('Hostel', s.hostelName)),
                                Expanded(
                                    child: _info('Room', s.roomNumber)),
                                Expanded(child: _info('Bed', s.bedNumber)),
                              ]),
                              const SizedBox(height: 8),
                              Row(children: [
                                Expanded(
                                    child:
                                        _info('Joining', s.joiningDate)),
                                Expanded(
                                    child: _info(
 'Leaving', s.expectedLeaving)),
                                Expanded(
                                    child: _info('Fee',
 'Rs ${s.monthlyFee.toStringAsFixed(0)}/mo')),
                              ]),

                              // Admin action buttons
                              if (isAdmin && s.status == 'active') ...[
                                const SizedBox(height: 12),
                                Row(children: [
                                  Expanded(
                                      child: OutlinedButton.icon(
                                    onPressed: () => _showTransferDialog(
                                        context, s, p),
                                    icon: const Icon(Icons.swap_horiz,
                                        size: 16),
                                    label: const Text('Transfer',
                                        style: TextStyle(fontSize: 12)),
                                  )),
                                  const SizedBox(width: 8),
                                  Expanded(
                                      child: ElevatedButton.icon(
                                    onPressed: () => _showCheckoutDialog(
                                        context, s, p),
                                    icon: const Icon(Icons.logout,
                                        size: 16),
                                    label: const Text('Checkout',
                                        style: TextStyle(fontSize: 12)),
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red),
                                  )),
                                ]),
                              ],

                              if (s.status == 'checked_out')
                                Container(
                                    margin: const EdgeInsets.only(top: 8),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                        color:
                                            Colors.grey.withOpacity(0.1),
                                        borderRadius:
                                            BorderRadius.circular(8)),
                                    child: const Text('CHECKED OUT',
                                        style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.grey,
                                            fontWeight:
                                                FontWeight.bold))),
                            ]),
                      ),
                    );
                  },
                ),
    );
  }

  // ----------------------------------------------------------------
  // ADD COMPLAINT DIALOG (student use karega)
  // ----------------------------------------------------------------
  void _showAddComplaintDialog(BuildContext context) {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    String priority = 'medium';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: const Row(children: [
            Icon(Icons.report_problem_outlined, color: Colors.orange),
            SizedBox(width: 8),
            Text('Add Complaint'),
          ]),
          content: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              TextField(
                controller: titleCtrl,
                decoration:
                    const InputDecoration(labelText: 'Title *'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: descCtrl,
                maxLines: 3,
                decoration:
                    const InputDecoration(labelText: 'Description *'),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: priority,
                decoration:
                    const InputDecoration(labelText: 'Priority'),
                items: ['low', 'medium', 'high']
                    .map((p) => DropdownMenuItem(
                        value: p,
                        child: Text(p.toUpperCase())))
                    .toList(),
                onChanged: (v) => setS(() => priority = v!),
              ),
            ]),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                if (titleCtrl.text.trim().isEmpty ||
                    descCtrl.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Title aur Description required hai'),
                        backgroundColor: Colors.red),
                  );
                  return;
                }
                Navigator.pop(ctx);

                // Real API call
                final p = context.read<HostelProvider>();
                final success = await p.submitComplaint(
                  title: titleCtrl.text.trim(),
                  description: descCtrl.text.trim(),
                  priority: priority,
                );

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(success
                          ? 'Complaint submitted successfully!'
                          : 'Failed to submit complaint'),
                      backgroundColor:
                          success ? Colors.green : Colors.red,
                    ),
                  );
                }
              },
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }

  // ----------------------------------------------------------------
  // TRANSFER DIALOG (unchanged)
  // ----------------------------------------------------------------
  void _showTransferDialog(
      BuildContext context, HostelStudentModel s, HostelProvider p) {
    int? newHostelId;
    int? newRoomId;
    String newBed = 'B1';
    List<Map<String, dynamic>> availableRooms = [];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: const Row(children: [
            Icon(Icons.swap_horiz, color: Colors.blue),
            SizedBox(width: 8),
            Text('Transfer Room'),
          ]),
          content: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8)),
                child: Row(children: [
                  const Icon(Icons.person, color: Colors.blue, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        Text(s.studentName,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13)),
                        Text(
        'Current: ${s.hostelName} • Room ${s.roomNumber} • ${s.bedNumber}',
                            style: const TextStyle(
                                fontSize: 11, color: Colors.grey)),
                      ])),
                ]),
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(
                    labelText: 'Transfer to Hostel *',
                    prefixIcon: Icon(Icons.apartment)),
                isExpanded: true,
                items: p.hostels
                    .map((h) => DropdownMenuItem<int>(
                        value: h.id,
                        child: Text(
        '${h.name} (${h.type.toUpperCase()})',
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 13))))
                    .toList(),
                onChanged: (v) async {
                  setS(() {
                    newHostelId = v;
                    availableRooms = [];
                    newRoomId = null;
                  });
                  try {
                    final res = await apiService.get('/hostel/rooms');
                    final all = List<Map<String, dynamic>>.from(
                        res['data'] ?? []);
                    setS(() {
                      availableRooms = all
                          .where((r) =>
                              r['hostel_id'] == v &&
                              r['status'] == 'available')
                          .toList();
                    });
                  } catch (e) {}
                },
              ),
              const SizedBox(height: 12),
              availableRooms.isEmpty
                  ? Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border:
                              Border.all(color: Colors.grey.shade200)),
                      child: const Text(
        'Select a hostel to see available rooms',
                          style: TextStyle(
                              color: Colors.grey, fontSize: 12)))
                  : DropdownButtonFormField<int>(
                      decoration: const InputDecoration(
                          labelText: 'Select Room *',
                          prefixIcon:
                              Icon(Icons.door_front_door)),
                      isExpanded: true,
                      items: availableRooms
                          .map((r) => DropdownMenuItem<int>(
                              value: r['id'] as int,
                              child: Text(
        'Room ${r['room_number']} • ${r['room_type']} ? Rs ${r['monthly_rent']}/mo',
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      fontSize: 12))))
                          .toList(),
                      onChanged: (v) => setS(() => newRoomId = v),
                    ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: newBed,
                decoration:
                    const InputDecoration(labelText: 'Bed Number *'),
                items: ['B1', 'B2', 'B3', 'B4']
                    .map((b) =>
                        DropdownMenuItem(value: b, child: Text(b)))
                    .toList(),
                onChanged: (v) => setS(() => newBed = v!),
              ),
            ]),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel')),
            ElevatedButton.icon(
              onPressed: newRoomId == null
                  ? null
                  : () async {
                      Navigator.pop(ctx);
                      try {
                        await apiService.put(
 '/hostel/students/${s.id}/transfer', {
        'hostel_id': newHostelId,
        'room_id': newRoomId,
        'bed_number': newBed,
                        });
                        await p.fetchAll();
                        if (context.mounted)
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
 'Room transferred successfully!'),
                                  backgroundColor: Colors.green));
                      } catch (e) {
                        if (context.mounted)
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content:
                                      Text('Transfer failed: $e'),
                                  backgroundColor: Colors.red));
                      }
                    },
              icon: const Icon(Icons.swap_horiz, size: 16),
              label: const Text('Transfer'),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue),
            ),
          ],
        ),
      ),
    );
  }

  // ----------------------------------------------------------------
  // CHECKOUT DIALOG (unchanged)
  // ----------------------------------------------------------------
  void _showCheckoutDialog(
      BuildContext context, HostelStudentModel s, HostelProvider p) {
    final remarksCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(children: [
          Icon(Icons.logout, color: Colors.red),
          SizedBox(width: 8),
          Text('Checkout Student'),
        ]),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
                border:
                    Border.all(color: Colors.red.withOpacity(0.2))),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(s.studentName,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14)),
                  Text(
        '${s.hostelName} • Room ${s.roomNumber} • ${s.bedNumber}',
                      style: const TextStyle(
                          fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 4),
                  const Text(
        'Are you sure you want to checkout this student?',
                      style: TextStyle(
                          fontSize: 12, color: Colors.red)),
                ]),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: remarksCtrl,
            maxLines: 2,
            decoration: const InputDecoration(
                labelText: 'Reason / Remarks',
                prefixIcon: Icon(Icons.note)),
          ),
        ]),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          ElevatedButton.icon(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await apiService.put(
        '/hostel/students/${s.id}/checkout',
                    {'remarks': remarksCtrl.text});
                await p.fetchAll();
                if (context.mounted)
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content:
                              Text('Student checked out successfully!'),
                          backgroundColor: Colors.green));
              } catch (e) {
                if (context.mounted)
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Checkout failed: $e'),
                      backgroundColor: Colors.red));
              }
            },
            icon: const Icon(Icons.logout, size: 16),
            label: const Text('Confirm Checkout'),
            style:
                ElevatedButton.styleFrom(backgroundColor: Colors.red),
          ),
        ],
      ),
    );
  }

  Widget _info(String label, String value) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label,
            style:
                const TextStyle(fontSize: 10, color: Colors.grey)),
        Text(value,
            style: const TextStyle(
                fontSize: 11, fontWeight: FontWeight.w500),
            overflow: TextOverflow.ellipsis),
      ]);
}

