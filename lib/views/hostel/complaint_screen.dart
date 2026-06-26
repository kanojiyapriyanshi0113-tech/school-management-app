// lib/views/hostel/complaint_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/hostel_provider.dart';
import '../../providers/auth_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../models/hostel_model.dart';

class ComplaintScreen extends StatefulWidget {
  const ComplaintScreen({super.key});

  @override
  State<ComplaintScreen> createState() => _ComplaintScreenState();
}

class _ComplaintScreenState extends State<ComplaintScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      final hostel = context.read<HostelProvider>();

      if (auth.isAdmin) {
        // ??? Admin: saari complaints fetch karo
        hostel.fetchComplaints();
      } else {
        // ??? Student: sirf apni complaints fetch karo (latest upar)
        hostel.fetchMyComplaints();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<HostelProvider>();
    final auth = context.watch<AuthProvider>();
    final isAdmin = auth.isAdmin;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),

      // ??? Student ke liye "New Complaint" button
      floatingActionButton: !isAdmin
          ? FloatingActionButton.extended(
              onPressed: () => _showAddComplaintDialog(context, p),
              icon: const Icon(Icons.add),
              label: const Text('New Complaint'),
              backgroundColor: AppTheme.primaryColor,
            )
          : null,

      body: p.complaintsLoading
          ? const Center(child: CircularProgressIndicator())
          : p.complaints.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
                      const SizedBox(height: 12),
                      Text(
                        isAdmin
                            ? 'No complaints received yet'
                            : 'Aapne abhi tak koi complaint submit nahi ki',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 80),
                  itemCount: p.complaints.length,
                  itemBuilder: (context, i) {
                    return _buildComplaintCard(context, p.complaints[i], p, isAdmin);
                  },
                ),
    );
  }

  Widget _buildComplaintCard(
      BuildContext context, ComplaintModel c, HostelProvider p, bool isAdmin) {
    final priorityColors = {
        'low': Colors.blue,
        'medium': Colors.orange,
        'high': Colors.red,
    };
    final statusColors = {
        'pending': Colors.orange,
        'accepted': Colors.green,
        'rejected': Colors.red,
        'assigned': Colors.blue,
        'resolved': Colors.teal,
    };
    final pColor = priorityColors[c.priority] ?? Colors.grey;
    final sColor = statusColors[c.status] ?? Colors.grey;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(c.title,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14)),
                ),
                Row(children: [
                  _badge(c.priority.toUpperCase(), pColor),
                  const SizedBox(width: 6),
                  _badge(c.status.toUpperCase(), sColor),
                ]),
              ],
            ),
            const SizedBox(height: 4),
            Text('Room ${c.roomNumber} • ${c.date}',
                style: const TextStyle(fontSize: 11, color: Colors.grey)),
            const SizedBox(height: 6),
            Text(c.description, style: const TextStyle(fontSize: 12)),
            if (isAdmin && c.studentName.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text('By: ${c.studentName}',
                  style: const TextStyle(fontSize: 11, color: Colors.grey)),
            ],
            if (c.assignedTo != null && c.assignedTo!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text('Assigned to: ${c.assignedTo}',
                  style: const TextStyle(
                      fontSize: 11, color: AppTheme.primaryColor)),
            ],
            if (isAdmin) ...[
              const SizedBox(height: 10),
              const Divider(height: 1),
              const SizedBox(height: 10),
              _buildAdminButtons(context, c, p),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAdminButtons(
      BuildContext context, ComplaintModel c, HostelProvider p) {

    // PENDING ??? Accept / Reject
    if (c.status == 'pending') {
      return Row(children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _confirmAction(
              context: context,
              title: 'Reject Complaint?',
              message: 'Kya aap is complaint ko reject karna chahte hain?',
              confirmText: 'Reject',
              confirmColor: Colors.red,
              onConfirm: () async {
                await p.rejectComplaint(c.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Complaint reject kar di gayi'),
                    backgroundColor: Colors.red,
                  ));
                }
              },
            ),
            icon: const Icon(Icons.close, color: Colors.red, size: 16),
            label: const Text('Reject',
                style: TextStyle(color: Colors.red, fontSize: 12)),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.red),
              padding: const EdgeInsets.symmetric(vertical: 8),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _confirmAction(
              context: context,
              title: 'Accept Complaint?',
              message: 'Kya aap is complaint ko accept karna chahte hain?',
              confirmText: 'Accept',
              confirmColor: Colors.green,
              onConfirm: () async {
                await p.acceptComplaint(c.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Complaint accept kar li gayi!'),
                    backgroundColor: Colors.green,
                  ));
                }
              },
            ),
            icon: const Icon(Icons.check, size: 16),
            label: const Text('Accept', style: TextStyle(fontSize: 12)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(vertical: 8),
            ),
          ),
        ),
      ]);
    }

    // ACCEPTED / ASSIGNED ??? Assign + Resolve
    if (c.status == 'accepted' || c.status == 'assigned') {
      return Row(children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => _showAssignDialog(context, c.id, p),
            style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 8)),
            child: const Text('Assign', style: TextStyle(fontSize: 12)),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ElevatedButton(
            onPressed: () async {
              await p.resolveComplaint(c.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Complaint resolve ho gayi!'),
                  backgroundColor: Colors.teal,
                ));
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              padding: const EdgeInsets.symmetric(vertical: 8),
            ),
            child: const Text('Resolve', style: TextStyle(fontSize: 12)),
          ),
        ),
      ]);
    }

    if (c.status == 'resolved') {
      return _statusChip(Icons.check_circle, 'Resolved', Colors.teal);
    }

    if (c.status == 'rejected') {
      return _statusChip(Icons.cancel, 'Rejected', Colors.red);
    }

    return const SizedBox.shrink();
  }

  void _confirmAction({
    required BuildContext context,
    required String title,
    required String message,
    required String confirmText,
    required Color confirmColor,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              onConfirm();
            },
            style: ElevatedButton.styleFrom(backgroundColor: confirmColor),
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }

  void _showAssignDialog(
      BuildContext context, int complaintId, HostelProvider p) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Assign Complaint'),
        content: TextField(
          controller: ctrl,
          decoration:
              const InputDecoration(labelText: 'Assign to (name/role)'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final val = ctrl.text.trim();
              if (val.isEmpty) return;
              Navigator.pop(ctx);
              await p.assignComplaint(complaintId, val);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Complaint assign kar di gayi!'),
                  backgroundColor: Colors.blue,
                ));
              }
            },
            child: const Text('Assign'),
          ),
        ],
      ),
    );
  }

  void _showAddComplaintDialog(BuildContext context, HostelProvider p) {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final roomCtrl = TextEditingController();
    String priority = 'medium';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setStateDialog) => AlertDialog(
          title: const Text('Submit Complaint'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Title *',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: roomCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Room Number',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Description *',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: priority,
                  decoration: const InputDecoration(
                    labelText: 'Priority',
                    border: OutlineInputBorder(),
                  ),
                  items: ['low', 'medium', 'high']
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (v) => setStateDialog(() => priority = v!),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (titleCtrl.text.trim().isEmpty ||
                    descCtrl.text.trim().isEmpty) {
                  ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(
                    content: Text('Title aur Description required hain'),
                  ));
                  return;
                }
                Navigator.pop(ctx);
                final success = await p.submitComplaint(
                  title: titleCtrl.text.trim(),
                  description: descCtrl.text.trim(),
                  priority: priority,
                  roomNumber: roomCtrl.text.trim(),
                );
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(success
                        ? 'Complaint submit ho gayi!'
                        : 'Error: complaint submit nahi hui'),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ));
                }
              },
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _badge(String text, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6)),
        child: Text(text,
            style: TextStyle(
                fontSize: 9, color: color, fontWeight: FontWeight.bold)),
      );

  Widget _statusChip(IconData icon, String label, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(6)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(color: color, fontSize: 12)),
        ]),
      );
}