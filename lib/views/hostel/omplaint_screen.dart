// lib/views/hostel/complaint_screen.dart
// FIXES:
//   1. Role-based view: Admin = all complaints + Accept/Reject/Assign/Resolve
//                       Student = sirf apni complaints, latest UPAR (desc order)
//   2. Student complaint submit ke baad list turant refresh hoti hai
//   3. Admin ke paas Accept / Reject buttons hain

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/hostel_provider.dart';
import '../../core/theme/app_theme.dart';

class ComplaintScreen extends StatefulWidget {
  const ComplaintScreen({super.key});

  @override
  State<ComplaintScreen> createState() => _ComplaintScreenState();
}

class _ComplaintScreenState extends State<ComplaintScreen> {
  // ? FIX: role track karo taaki screen alag dikhaye
  // Ye value aap AuthProvider ya SharedPreferences se lena
  // Abhi hostel_provider se pass ho raha hai
  bool get _isAdmin => context.read<HostelProvider>().isAdmin;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // ? FIX: role ke hisaab se alag fetch
      final p = context.read<HostelProvider>();
      if (p.isAdmin) {
        p.fetchComplaints();       // Admin: saari complaints
      } else {
        p.fetchMyComplaints();     // Student: sirf apni complaints
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<HostelProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),

      // ? FIX: Student ke liye FAB ? complaint submit karne ka button
      floatingActionButton: !_isAdmin
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
                      const Icon(Icons.inbox_outlined,
                          size: 64, color: Colors.grey),
                      const SizedBox(height: 12),
                      Text(
                        _isAdmin
                            ? 'No complaints received yet'
                            : 'You have not submitted any complaints yet',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 80),
                  // ? FIX: complaints already DESC order mein hain (backend se)
                  // Latest upar dikhega automatically
                  itemCount: p.complaints.length,
                  itemBuilder: (context, i) {
                    final c = p.complaints[i];
                    return _buildComplaintCard(context, c, p);
                  },
                ),
    );
  }

  // ???????????
  // Complaint Card
  // ???????????
  Widget _buildComplaintCard(
      BuildContext context, dynamic c, HostelProvider p) {
    final priorityColors = {
        'low': Colors.blue,
        'medium': Colors.orange,
        'high': Colors.red,
    };
    final statusColors = {
        'pending': Colors.orange,
        'accepted': Colors.green,   // ? NEW status
        'rejected': Colors.red,     // ? NEW status
        'assigned': Colors.blue,
        'resolved': Colors.green,
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
            // Title + Badges row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    c.title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ),
                Row(children: [
                  _badge(c.priority.toUpperCase(), pColor),
                  const SizedBox(width: 6),
                  _badge(c.status.toUpperCase(), sColor),
                ]),
              ],
            ),
            const SizedBox(height: 4),

            // Room + Date
            Text(
        'Room ${c.roomNumber} ? ${c.date}',
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
            const SizedBox(height: 6),

            // Description
            Text(c.description,
                style: const TextStyle(fontSize: 12)),

            // Assigned to (agar hai)
            if (c.assignedTo != null && c.assignedTo!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
        'Assigned to: ${c.assignedTo}',
                style: const TextStyle(
                    fontSize: 11, color: AppTheme.primaryColor),
              ),
            ],

            // ? FIX: Admin ke liye buttons
            if (_isAdmin) ...[
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

  // ???????????
  // Admin Action Buttons
  // ???????????
  Widget _buildAdminButtons(
      BuildContext context, dynamic c, HostelProvider p) {
    // Agar already resolved hai to kuch nahi dikhao
    if (c.status == 'resolved') {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          borderRadius: BorderRadius.circular(6),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 14),
            SizedBox(width: 4),
            Text('Resolved',
                style: TextStyle(color: Colors.green, fontSize: 12)),
          ],
        ),
      );
    }

    // Pending complaint: Accept / Reject dikhao
    if (c.status == 'pending') {
      return Row(children: [
        // ? REJECT button
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _confirmReject(context, c.id, p),
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
        // ? ACCEPT button
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _confirmAccept(context, c.id, p),
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

    // Accepted complaint: Assign + Resolve dikhao
    if (c.status == 'accepted' || c.status == 'assigned') {
      return Row(children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => _showAssignDialog(context, c.id, p),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 8),
            ),
            child: const Text('Assign', style: TextStyle(fontSize: 12)),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ElevatedButton(
            onPressed: () => p.resolveComplaint(c.id),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              padding: const EdgeInsets.symmetric(vertical: 8),
            ),
            child: const Text('Resolve', style: TextStyle(fontSize: 12)),
          ),
        ),
      ]);
    }

    // Rejected complaint
    if (c.status == 'rejected') {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(6),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cancel, color: Colors.red, size: 14),
            SizedBox(width: 4),
            Text('Rejected',
                style: TextStyle(color: Colors.red, fontSize: 12)),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  // ???????????
  // Accept Confirm Dialog
  // ???????????
  void _confirmAccept(BuildContext context, int id, HostelProvider p) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Accept Complaint?'),
        content: const Text('Kya aap is complaint ko accept karna chahte hain?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await p.acceptComplaint(id);  // ? New provider method
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Complaint accepted!'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Accept'),
          ),
        ],
      ),
    );
  }

  // ???????????
  // Reject Confirm Dialog
  // ???????????
  void _confirmReject(BuildContext context, int id, HostelProvider p) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reject Complaint?'),
        content: const Text('Kya aap is complaint ko reject karna chahte hain?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await p.rejectComplaint(id);  // ? New provider method
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Complaint rejected.'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }

  // ???????????
  // Assign Dialog (existing ? unchanged)
  // ???????????
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
              Navigator.pop(ctx);
              await p.assignComplaint(complaintId, ctrl.text.trim());
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Complaint assigned!'),
                    backgroundColor: Colors.blue,
                  ),
                );
              }
            },
            child: const Text('Assign'),
          ),
        ],
      ),
    );
  }

  // ???????????
  // Add Complaint Dialog (Student ke liye)
  // ???????????
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
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    const SnackBar(
                        content: Text('Title aur Description required hain')),
                  );
                  return;
                }
                Navigator.pop(ctx);

                // ? FIX: Submit karo + list turant refresh hogi
                await p.submitComplaint(
                  title: titleCtrl.text.trim(),
                  description: descCtrl.text.trim(),
                  roomNumber: roomCtrl.text.trim(),
                  priority: priority,
                );

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Complaint submitted successfully!'),
                      backgroundColor: Colors.green,
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

  // ???????????
  // Helper: Badge widget
  // ???????????
  Widget _badge(String text, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          text,
          style: TextStyle(
              fontSize: 9, color: color, fontWeight: FontWeight.bold),
        ),
      );
}// lib/views/hostel/complaint_screen.dart
// FIXES:
//   1. Role-based view: Admin = all complaints + Accept/Reject/Assign/Resolve
//                       Student = sirf apni complaints, latest UPAR (desc order)
//   2. Student complaint submit ke baad list turant refresh hoti hai
//   3. Admin ke paas Accept / Reject buttons hain

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/hostel_provider.dart';
import '../../core/theme/app_theme.dart';

class ComplaintScreen extends StatefulWidget {
  const ComplaintScreen({super.key});

  @override
  State<ComplaintScreen> createState() => _ComplaintScreenState();
}

class _ComplaintScreenState extends State<ComplaintScreen> {
  // ? FIX: role track karo taaki screen alag dikhaye
  // Ye value aap AuthProvider ya SharedPreferences se lena
  // Abhi hostel_provider se pass ho raha hai
  bool get _isAdmin => context.read<HostelProvider>().isAdmin;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // ? FIX: role ke hisaab se alag fetch
      final p = context.read<HostelProvider>();
      if (p.isAdmin) {
        p.fetchComplaints();       // Admin: saari complaints
      } else {
        p.fetchMyComplaints();     // Student: sirf apni complaints
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<HostelProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),

      // ? FIX: Student ke liye FAB ? complaint submit karne ka button
      floatingActionButton: !_isAdmin
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
                      const Icon(Icons.inbox_outlined,
                          size: 64, color: Colors.grey),
                      const SizedBox(height: 12),
                      Text(
                        _isAdmin
                            ? 'No complaints received yet'
                            : 'You have not submitted any complaints yet',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 80),
                  // ? FIX: complaints already DESC order mein hain (backend se)
                  // Latest upar dikhega automatically
                  itemCount: p.complaints.length,
                  itemBuilder: (context, i) {
                    final c = p.complaints[i];
                    return _buildComplaintCard(context, c, p);
                  },
                ),
    );
  }

  // ???????????
  // Complaint Card
  // ???????????
  Widget _buildComplaintCard(
      BuildContext context, dynamic c, HostelProvider p) {
    final priorityColors = {
        'low': Colors.blue,
        'medium': Colors.orange,
        'high': Colors.red,
    };
    final statusColors = {
        'pending': Colors.orange,
        'accepted': Colors.green,   // ? NEW status
        'rejected': Colors.red,     // ? NEW status
        'assigned': Colors.blue,
        'resolved': Colors.green,
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
            // Title + Badges row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    c.title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ),
                Row(children: [
                  _badge(c.priority.toUpperCase(), pColor),
                  const SizedBox(width: 6),
                  _badge(c.status.toUpperCase(), sColor),
                ]),
              ],
            ),
            const SizedBox(height: 4),

            // Room + Date
            Text(
        'Room ${c.roomNumber} • ${c.date}',
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
            const SizedBox(height: 6),

            // Description
            Text(c.description,
                style: const TextStyle(fontSize: 12)),

            // Assigned to (agar hai)
            if (c.assignedTo != null && c.assignedTo!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
        'Assigned to: ${c.assignedTo}',
                style: const TextStyle(
                    fontSize: 11, color: AppTheme.primaryColor),
              ),
            ],

            // ? FIX: Admin ke liye buttons
            if (_isAdmin) ...[
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

  // ???????????
  // Admin Action Buttons
  // ???????????
  Widget _buildAdminButtons(
      BuildContext context, dynamic c, HostelProvider p) {
    // Agar already resolved hai to kuch nahi dikhao
    if (c.status == 'resolved') {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          borderRadius: BorderRadius.circular(6),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 14),
            SizedBox(width: 4),
            Text('Resolved',
                style: TextStyle(color: Colors.green, fontSize: 12)),
          ],
        ),
      );
    }

    // Pending complaint: Accept / Reject dikhao
    if (c.status == 'pending') {
      return Row(children: [
        // ? REJECT button
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _confirmReject(context, c.id, p),
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
        // ? ACCEPT button
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _confirmAccept(context, c.id, p),
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

    // Accepted complaint: Assign + Resolve dikhao
    if (c.status == 'accepted' || c.status == 'assigned') {
      return Row(children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => _showAssignDialog(context, c.id, p),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 8),
            ),
            child: const Text('Assign', style: TextStyle(fontSize: 12)),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ElevatedButton(
            onPressed: () => p.resolveComplaint(c.id),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              padding: const EdgeInsets.symmetric(vertical: 8),
            ),
            child: const Text('Resolve', style: TextStyle(fontSize: 12)),
          ),
        ),
      ]);
    }

    // Rejected complaint
    if (c.status == 'rejected') {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(6),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cancel, color: Colors.red, size: 14),
            SizedBox(width: 4),
            Text('Rejected',
                style: TextStyle(color: Colors.red, fontSize: 12)),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  // ???????????
  // Accept Confirm Dialog
  // ???????????
  void _confirmAccept(BuildContext context, int id, HostelProvider p) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Accept Complaint?'),
        content: const Text('Kya aap is complaint ko accept karna chahte hain?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await p.acceptComplaint(id);  // ? New provider method
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Complaint accepted!'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Accept'),
          ),
        ],
      ),
    );
  }

  // ???????????
  // Reject Confirm Dialog
  // ???????????
  void _confirmReject(BuildContext context, int id, HostelProvider p) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reject Complaint?'),
        content: const Text('Kya aap is complaint ko reject karna chahte hain?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await p.rejectComplaint(id);  // ? New provider method
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Complaint rejected.'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }

  // ???????????
  // Assign Dialog (existing ? unchanged)
  // ???????????
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
              Navigator.pop(ctx);
              await p.assignComplaint(complaintId, ctrl.text.trim());
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Complaint assigned!'),
                    backgroundColor: Colors.blue,
                  ),
                );
              }
            },
            child: const Text('Assign'),
          ),
        ],
      ),
    );
  }

  // ???????????
  // Add Complaint Dialog (Student ke liye)
  // ???????????
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
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    const SnackBar(
                        content: Text('Title aur Description required hain')),
                  );
                  return;
                }
                Navigator.pop(ctx);

                // ? FIX: Submit karo + list turant refresh hogi
                await p.submitComplaint(
                  title: titleCtrl.text.trim(),
                  description: descCtrl.text.trim(),
                  roomNumber: roomCtrl.text.trim(),
                  priority: priority,
                );

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Complaint submitted successfully!'),
                      backgroundColor: Colors.green,
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

  // ???????????
  // Helper: Badge widget
  // ???????????
  Widget _badge(String text, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          text,
          style: TextStyle(
              fontSize: 9, color: color, fontWeight: FontWeight.bold),
        ),
      );
}

