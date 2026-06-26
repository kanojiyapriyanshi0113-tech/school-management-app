import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/staff_provider.dart';
import '../../providers/auth_provider.dart';
import '../../core/theme/app_theme.dart';

class LeaveManagementScreen extends StatefulWidget {
  const LeaveManagementScreen({super.key});
  @override
  State<LeaveManagementScreen> createState() => _LeaveManagementScreenState();
}

class _LeaveManagementScreenState extends State<LeaveManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    final isAdmin = context.read<AuthProvider>().user?.role == 'admin';
    // Admin: All Leaves + Pending + Apply
    // Staff: All Leaves + Apply (Pending nahi)
    _tabController = TabController(length: isAdmin ? 3 : 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StaffProvider>().fetchStaff();
    });
  }

  @override
  void dispose() { _tabController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final isAdmin = context.watch<AuthProvider>().user?.role == 'admin';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Leave Management'),
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
          tabs: [
            const Tab(text: 'All Leaves'),
            if (isAdmin) const Tab(text: 'Pending'),
            const Tab(text: 'Apply Leave'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _allLeaves(),
          if (isAdmin) _pendingLeaves(),
          _applyLeave(),
        ],
      ),
    );
  }

  Widget _allLeaves() {
    final leaves = context.watch<StaffProvider>().leaves;
    return leaves.isEmpty
      ? const Center(child: Text('No leave records', style: TextStyle(color: Colors.grey)))
      : ListView.builder(
          padding: const EdgeInsets.all(14),
          itemCount: leaves.length,
          itemBuilder: (context, i) => _leaveCard(leaves[i]),
        );
  }

  Widget _pendingLeaves() {
    final p = context.watch<StaffProvider>();
    final pending = p.pendingLeaves;
    return pending.isEmpty
      ? const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.check_circle, size: 64, color: Colors.green),
          SizedBox(height: 12),
          Text('No pending requests!', style: TextStyle(fontSize: 16, color: Colors.grey)),
        ]))
      : ListView.builder(
          padding: const EdgeInsets.all(14),
          itemCount: pending.length,
          itemBuilder: (context, i) => Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  CircleAvatar(backgroundColor: Colors.orange.withOpacity(0.1),
                    child: const Icon(Icons.beach_access, color: Colors.orange)),
                  const SizedBox(width: 10),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(pending[i].staffName, style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(pending[i].leaveType, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  ])),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                    child: const Text('PENDING', style: TextStyle(color: Colors.orange, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ]),
                const SizedBox(height: 10),
                Row(children: [
                  const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text('${pending[i].fromDate} • ${pending[i].toDate} (${pending[i].days} day${pending[i].days > 1 ? 's' : ''})',
                    style: const TextStyle(fontSize: 12)),
                ]),
                const SizedBox(height: 6),
                Text(pending[i].reason, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(child: OutlinedButton.icon(
                    onPressed: () => context.read<StaffProvider>().rejectLeave(pending[i].id),
                    icon: const Icon(Icons.close, size: 16, color: Colors.red),
                    label: const Text('Reject', style: TextStyle(color: Colors.red)),
                    style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.red)),
                  )),
                  const SizedBox(width: 10),
                  Expanded(child: ElevatedButton.icon(
                    onPressed: () => context.read<StaffProvider>().approveLeave(pending[i].id),
                    icon: const Icon(Icons.check, size: 16),
                    label: const Text('Approve'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  )),
                ]),
              ]),
            ),
          ),
        );
  }

  Widget _applyLeave() {
    final _formKey = GlobalKey<FormState>();
    final _reason = TextEditingController();
    String leaveType = 'Casual Leave';

    return StatefulBuilder(
      builder: (context, setS) => SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            const Text('Leave Balance', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            Row(children: [
              _balanceCard('Casual', 8, 12, Colors.blue),
              const SizedBox(width: 8),
              _balanceCard('Sick', 5, 10, Colors.orange),
              const SizedBox(width: 8),
              _balanceCard('Earned', 15, 30, Colors.green),
            ]),
            const SizedBox(height: 20),
            const Text('Apply for Leave', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: leaveType,
              decoration: const InputDecoration(labelText: 'Leave Type', prefixIcon: Icon(Icons.beach_access)),
              items: ['Casual Leave', 'Sick Leave', 'Earned Leave', 'Emergency Leave']
                .map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
              onChanged: (v) => setS(() => leaveType = v!),
            ),
            const SizedBox(height: 14),
            TextFormField(
              readOnly: true,
              decoration: const InputDecoration(labelText: 'From Date', prefixIcon: Icon(Icons.calendar_today)),
              onTap: () async {
                await showDatePicker(context: context,
                  initialDate: DateTime.now(), firstDate: DateTime.now(), lastDate: DateTime(2026));
              },
            ),
            const SizedBox(height: 14),
            TextFormField(
              readOnly: true,
              decoration: const InputDecoration(labelText: 'To Date', prefixIcon: Icon(Icons.calendar_today)),
              onTap: () async {
                await showDatePicker(context: context,
                  initialDate: DateTime.now(), firstDate: DateTime.now(), lastDate: DateTime(2026));
              },
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _reason,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Reason *', prefixIcon: Icon(Icons.info_outline)),
              validator: (v) => (v == null || v.isEmpty) ? 'Reason required' : null,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  await Future.delayed(const Duration(seconds: 1));
                  if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Leave applied successfully!'), backgroundColor: Colors.green));
                }
              },
              child: const Text('Submit Leave Request'),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _leaveCard(LeaveModel leave) {
    final statusColors = {'pending': Colors.orange, 'approved': Colors.green, 'rejected': Colors.red};
    final color = statusColors[leave.status] ?? Colors.grey;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(backgroundColor: color.withOpacity(0.1),
          child: Icon(Icons.beach_access, color: color)),
        title: Text(leave.staffName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        subtitle: Text('${leave.leaveType} • ${leave.fromDate} (${leave.days} day${leave.days > 1 ? 's' : ''})',
          style: const TextStyle(fontSize: 11)),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
          child: Text(leave.status.toUpperCase(),
            style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _balanceCard(String type, int used, int total, Color color) => Expanded(
    child: Card(child: Padding(
      padding: const EdgeInsets.all(10),
      child: Column(children: [
        Text('${total - used}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
        Text('$type Left', style: const TextStyle(fontSize: 10, color: Colors.grey)),
        Text('$used/$total', style: TextStyle(fontSize: 9, color: color)),
      ]),
    )),
  );
}