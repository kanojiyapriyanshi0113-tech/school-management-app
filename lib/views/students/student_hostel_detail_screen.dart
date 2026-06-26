import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/hostel_provider.dart';

class StudentHostelDetailScreen extends StatefulWidget {
  const StudentHostelDetailScreen({super.key});
  @override
  State<StudentHostelDetailScreen> createState() =>
      _StudentHostelDetailScreenState();
}

class _StudentHostelDetailScreenState
    extends State<StudentHostelDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Demo data ??? baad mein API se aayega
  final _hostelInfo = {
        'hostelName': 'Boys Hostel A',
        'roomNumber': '101',
        'bedNumber': 'B1',
        'floor': '1st Floor',
        'roomType': 'Double Sharing',
        'joiningDate': '01 Apr 2025',
        'leavingDate': '31 Mar 2026',
        'wardenName': 'Mr. Sharma',
        'wardenPhone': '9876543210',
        'monthlyRent': 5000.0,
        'deposit':     10000.0,
  };

  final List<Map<String, dynamic>> _paymentHistory = [
    {'month': 'April 2025', 'amount': 5000.0, 'paid': 5000.0, 'date': '02 Apr 2025', 'status': 'paid'},
    {'month': 'May 2025', 'amount': 5000.0, 'paid': 5000.0, 'date': '01 May 2025', 'status': 'paid'},
    {'month': 'June 2025', 'amount': 5000.0, 'paid': 0.0, 'date': '--', 'status': 'pending'},
    {'month': 'July 2025', 'amount': 5000.0, 'paid': 0.0, 'date': '--', 'status': 'upcoming'},
    {'month': 'August 2025', 'amount': 5000.0, 'paid': 0.0, 'date': '--', 'status': 'upcoming'},
    {'month': 'September 2025','amount': 5000.0, 'paid': 0.0, 'date': '--', 'status': 'upcoming'},
  ];

  final List<Map<String, dynamic>> _roomHistory = [
    {'hostel': 'Boys Hostel A', 'room': '101', 'bed': 'B1', 'from': '01 Apr 2025', 'to': 'Present', 'reason': 'Initial Allotment'},
  ];

  final List<Map<String, dynamic>> _leaveHistory = [
    {'from': '10 May 2025', 'to': '12 May 2025', 'reason': 'Family function', 'status': 'approved', 'days': 3},
    {'from': '02 Jun 2025', 'to': '02 Jun 2025', 'reason': 'Medical checkup', 'status': 'approved', 'days': 1},
  ];

  double get _totalPaid => _paymentHistory
    .where((p) => p['status'] == 'paid')
    .fold(0.0, (sum, p) => sum + (p['paid'] as double));

  double get _totalPending => _paymentHistory
    .where((p) => p['status'] == 'pending')
    .fold(0.0, (sum, p) => sum + (p['amount'] as double));

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() { _tabController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Hostel'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => context.go('/dashboard/student'),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Fee Payment'),
            Tab(text: 'Room History'),
            Tab(text: 'Leave'),
            Tab(text: 'Complaint'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _overviewTab(),
          _feePaymentTab(),
          _roomHistoryTab(),
          _leaveTab(),
          _complaintTab(),
        ],
      ),
    );
  }

  // ?????? Tab 1: Overview ?????????????????????
  Widget _overviewTab() => SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Column(children: [
      // Hostel info card
      Card(child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              width: 50, height: 50,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.hotel, color: AppTheme.primaryColor, size: 28)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(_hostelInfo['hostelName'] as String,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text('Room ${_hostelInfo['roomNumber']} - Bed ${_hostelInfo['bedNumber']}',
                style: const TextStyle(color: Colors.grey, fontSize: 13)),
            ])),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10)),
              child: const Text('ACTIVE',
                style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 11))),
          ]),
          const Divider(height: 20),
          _infoRow('Floor',        _hostelInfo['floor'] as String),
          _infoRow('Room Type',    _hostelInfo['roomType'] as String),
          _infoRow('Joining Date', _hostelInfo['joiningDate'] as String),
          _infoRow('Leaving Date', _hostelInfo['leavingDate'] as String),
          _infoRow('Monthly Rent', '??"₹${(_hostelInfo['monthlyRent'] as double).toStringAsFixed(0)}'),
          _infoRow('Deposit Paid', '??"₹${(_hostelInfo['deposit'] as double).toStringAsFixed(0)}'),
        ]),
      )),
      const SizedBox(height: 12),

      // Fee summary
      Card(child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Fee Summary',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 12),
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            _feeStat('Paid', '??"₹${_totalPaid.toStringAsFixed(0)}',    Colors.green),
            _feeStat('Pending', '??"₹${_totalPending.toStringAsFixed(0)}', Colors.red),
            _feeStat('Deposit', '??"₹${(_hostelInfo['deposit'] as double).toStringAsFixed(0)}', Colors.blue),
          ]),
          if (_totalPending > 0) ...[
            const SizedBox(height: 12),
            SizedBox(width: double.infinity, child: ElevatedButton.icon(
              onPressed: () => _tabController.animateTo(1),
              icon: const Icon(Icons.payment),
              label: Text('Pay ??"₹${_totalPending.toStringAsFixed(0)} Now'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            )),
          ],
        ]),
      )),
      const SizedBox(height: 12),

      // Warden contact
      Card(child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Warden Contact',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 10),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: CircleAvatar(
              backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
              child: const Icon(Icons.person, color: AppTheme.primaryColor)),
            title: Text(_hostelInfo['wardenName'] as String,
              style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Text(_hostelInfo['wardenPhone'] as String),
            trailing: IconButton(
              icon: const Icon(Icons.call, color: Colors.green),
              onPressed: () {},
            ),
          ),
        ]),
      )),
      const SizedBox(height: 12),

      // Room facilities
      Card(child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Room Facilities',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 10),
          Wrap(spacing: 8, runSpacing: 8, children: [
            _facilityChip(Icons.wifi, 'WiFi',             Colors.blue),
            _facilityChip(Icons.local_laundry_service, 'Laundry', Colors.purple),
            _facilityChip(Icons.restaurant, 'Mess',             Colors.orange),
            _facilityChip(Icons.local_hospital,'Medical',         Colors.red),
            _facilityChip(Icons.security, 'Security',         Colors.green),
            _facilityChip(Icons.power, 'Power Backup',     Colors.teal),
          ]),
        ]),
      )),
    ]),
  );

  // ?????? Tab 2: Fee Payment ??????????????????
  Widget _feePaymentTab() => SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Column(children: [
      // Summary
      Card(child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          _feeStat('Total Paid', '??"₹${_totalPaid.toStringAsFixed(0)}',    Colors.green),
          _feeStat('Due Amount', '??"₹${_totalPending.toStringAsFixed(0)}', Colors.red),
          _feeStat('Monthly Rent', '??Rs \1,000',                               Colors.blue),
        ]),
      )),
      const SizedBox(height: 12),
      const Align(alignment: Alignment.centerLeft,
        child: Text('Payment History',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600))),
      const SizedBox(height: 8),
      ..._paymentHistory.map((p) {
        final statusColors = {
        'paid':     Colors.green,
        'pending':  Colors.red,
        'upcoming': Colors.grey,
        };
        final color = statusColors[p['status']] ?? Colors.grey;
        final isPending = p['status'] == 'pending';

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Row(children: [
                  Icon(
                    p['status'] == 'paid' ? Icons.check_circle
                      : p['status'] == 'pending' ? Icons.warning
                      : Icons.schedule,
                    color: color, size: 20),
                  const SizedBox(width: 8),
                  Text(p['month'] as String,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                ]),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8)),
                  child: Text((p['status'] as String).toUpperCase(),
                    style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.bold))),
              ]),
              const SizedBox(height: 6),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('Amount: ??"₹${(p['amount'] as double).toStringAsFixed(0)}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey)),
                if (p['status'] == 'paid')
                  Text('Paid on: ${p['date']}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ]),
              if (isPending) ...[
                const SizedBox(height: 8),
                SizedBox(width: double.infinity, child: ElevatedButton.icon(
                  onPressed: () => _showPaymentDialog(context, p['month'] as String, p['amount'] as double),
                  icon: const Icon(Icons.payment, size: 16),
                  label: Text('Pay ??"₹${(p['amount'] as double).toStringAsFixed(0)}'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 8)),
                )),
              ],
            ]),
          ),
        );
      }),
    ]),
  );

  // ?????? Tab 3: Room History ???????????????
  Widget _roomHistoryTab() => SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Room Allocation History',
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
      const SizedBox(height: 10),
      ..._roomHistory.map((r) => Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const Icon(Icons.meeting_room, color: AppTheme.primaryColor),
              const SizedBox(width: 8),
              Text('${r['hostel']} - Room ${r['room']} - Bed ${r['bed']}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            ]),
            const SizedBox(height: 8),
            _infoRow('From',   r['from'] as String),
            _infoRow('To',     r['to'] as String),
            _infoRow('Reason', r['reason'] as String),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: r['to'] == 'Present'
                  ? Colors.green.withOpacity(0.1)
                  : Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8)),
              child: Text(r['to'] == 'Present' ? 'CURRENT ROOM' : 'PREVIOUS',
                style: TextStyle(
                  fontSize: 10, fontWeight: FontWeight.bold,
                  color: r['to'] == 'Present' ? Colors.green : Colors.grey))),
          ]),
        ),
      )),
      const SizedBox(height: 20),
      const Text('Request Room Change',
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
      const SizedBox(height: 8),
      Card(child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Need a different room?',
            style: TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          const Text('Submit a room change request to the hostel admin.',
            style: TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 10),
          SizedBox(width: double.infinity, child: OutlinedButton.icon(
            onPressed: () => _showRoomChangeDialog(context),
            icon: const Icon(Icons.swap_horiz),
            label: const Text('Request Room Change'),
          )),
        ]),
      )),
    ]),
  );

  // ?????? Tab 4: Leave ??????????????????
  Widget _leaveTab() {
    final _reasonCtrl = TextEditingController();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Apply leave form
        Card(child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Apply for Leave',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 12),
            TextFormField(
              readOnly: true,
              decoration: const InputDecoration(
                labelText: 'From Date',
                prefixIcon: Icon(Icons.calendar_today)),
              onTap: () async {
                await showDatePicker(context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2026));
              },
            ),
            const SizedBox(height: 10),
            TextFormField(
              readOnly: true,
              decoration: const InputDecoration(
                labelText: 'To Date',
                prefixIcon: Icon(Icons.calendar_today)),
              onTap: () async {
                await showDatePicker(context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2026));
              },
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _reasonCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Reason',
                prefixIcon: Icon(Icons.info_outline)),
            ),
            const SizedBox(height: 12),
            SizedBox(width: double.infinity, child: ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Leave request submitted!'),
                    backgroundColor: Colors.green));
              },
              icon: const Icon(Icons.send),
              label: const Text('Submit Leave Request'),
            )),
          ]),
        )),
        const SizedBox(height: 16),
        const Text('Leave History',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        ..._leaveHistory.map((l) {
          final color = l['status'] == 'approved' ? Colors.green : Colors.orange;
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: Icon(
                l['status'] == 'approved' ? Icons.check_circle : Icons.pending,
                color: color),
              title: Text(l['reason'] as String,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              subtitle: Text('${l['from']} to ${l['to']}  (${l['days']} days)',
                style: const TextStyle(fontSize: 11)),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8)),
                child: Text((l['status'] as String).toUpperCase(),
                  style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.bold))),
            ),
          );
        }),
      ]),
    );
  }

  // ?????? Payment Dialog ??????????????????
  void _showPaymentDialog(BuildContext context, String month, double amount) {
    String paymentMethod = 'UPI';
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: Text('Pay Fee - $month'),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8)),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text('Amount to Pay:', style: TextStyle(fontWeight: FontWeight.w600)),
                Text('??"₹${amount.toStringAsFixed(0)}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor)),
              ]),
            ),
            const SizedBox(height: 14),
            const Align(alignment: Alignment.centerLeft,
              child: Text('Payment Method', style: TextStyle(fontWeight: FontWeight.w600))),
            const SizedBox(height: 8),
            ...[
              {'value': 'UPI', 'icon': Icons.phone_android, 'label': 'UPI / PhonePe / GPay'},
              {'value': 'NetBanking', 'icon': Icons.account_balance,'label': 'Net Banking'},
              {'value': 'Card', 'icon': Icons.credit_card, 'label': 'Credit / Debit Card'},
              {'value': 'Cash', 'icon': Icons.money, 'label': 'Cash (Pay at Office)'},
            ].map((method) => RadioListTile<String>(
              value: method['value'] as String,
              groupValue: paymentMethod,
              title: Row(children: [
                Icon(method['icon'] as IconData, size: 18, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                Text(method['label'] as String, style: const TextStyle(fontSize: 13)),
              ]),
              onChanged: (v) => setS(() => paymentMethod = v!),
              dense: true,
              contentPadding: EdgeInsets.zero,
            )),
          ]),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('Payment of ??"₹${amount.toStringAsFixed(0)} initiated via $paymentMethod!'),
                  backgroundColor: Colors.green));
                setState(() {
                  final idx = _paymentHistory.indexWhere((p) => p['month'] == month);
                  if (idx != -1) {
                    _paymentHistory[idx]['status'] = 'paid';
                    _paymentHistory[idx]['paid'] = amount;
                    _paymentHistory[idx]['date'] = 'Today';
                  }
                });
              },
              child: Text('Pay ??"₹${amount.toStringAsFixed(0)}'),
            ),
          ],
        ),
      ),
    );
  }

  // ?????• Room Change Dialog ??????????????????
  void _showRoomChangeDialog(BuildContext context) {
    final _reasonCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Request Room Change'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(labelText: 'Preferred Room Type'),
            items: ['Single', 'Double', 'Triple', 'Four Sharing']
              .map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
            onChanged: (_) {},
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _reasonCtrl,
            maxLines: 3,
            decoration: const InputDecoration(labelText: 'Reason for Change'),
          ),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Room change request submitted!'),
                  backgroundColor: Colors.green));
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  // ?????? Helper Widgets ??????????????????
  Widget _infoRow(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(children: [
      SizedBox(width: 110, child: Text(label,
        style: const TextStyle(color: Colors.grey, fontSize: 12))),
      Expanded(child: Text(value,
        style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12))),
    ]),
  );

  Widget _feeStat(String label, String val, Color color) => Column(children: [
    Text(val, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
    Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
  ]);

  Widget _facilityChip(IconData icon, String label, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: color.withOpacity(0.3))),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 14, color: color),
      const SizedBox(width: 4),
      Text(label, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w500)),
    ]),
  );

  Widget _complaintTab() {
    final _titleCtrl = TextEditingController();
    final _descCtrl = TextEditingController();
    String _category = 'Maintenance';
    bool _submitting = false;

    return StatefulBuilder(
      builder: (context, setS) => SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Header
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange.withOpacity(0.2))),
            child: Row(children: [
              const Icon(Icons.report_problem, color: Colors.orange, size: 24),
              const SizedBox(width: 10),
              const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Register Complaint', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Text('Your complaint will be sent to admin', style: TextStyle(fontSize: 11, color: Colors.grey)),
              ])),
            ])),
          const SizedBox(height: 16),

          // Complaint Form
          Card(child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('New Complaint', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _category,
                decoration: const InputDecoration(
                  labelText: 'Category *', prefixIcon: Icon(Icons.category)),
                items: ['Maintenance', 'Food', 'Cleanliness', 'Security',
 'Electricity', 'Water', 'Internet', 'Furniture', 'Other']
                  .map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (v) => setS(() => _category = v!),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _titleCtrl,
                decoration: const InputDecoration(
                  labelText: 'Complaint Title *',
                  prefixIcon: Icon(Icons.title),
                  hintText: 'Brief title of your complaint'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _descCtrl,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Description *',
                  prefixIcon: Icon(Icons.description),
                  alignLabelWithHint: true,
                  hintText: 'Describe your complaint in detail...'),
              ),
              const SizedBox(height: 16),
              SizedBox(width: double.infinity, child: ElevatedButton.icon(
                onPressed: _submitting ? null : () async {
                  if (_titleCtrl.text.isEmpty || _descCtrl.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please fill all fields'),
                        backgroundColor: Colors.red));
                    return;
                  }
                  setS(() => _submitting = true);
                  final ok = await context.read<HostelProvider>().addComplaint(
                    title: _titleCtrl.text,
                    description: _descCtrl.text,
                    category: _category,
                    priority: 'medium',
                    studentName: context.read<AuthProvider>().user?.name ?? 'Student',
                    roomNumber: _hostelInfo['room']?.toString() ?? '101',
                  );
                  setS(() => _submitting = false);
                  if (ok) {
                    _titleCtrl.clear();
                    _descCtrl.clear();
                  }
                  if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(ok ? 'Complaint submitted! Admin will review it.' : 'Failed to submit'),
                      backgroundColor: ok ? Colors.green : Colors.red));
                },
                icon: _submitting
                  ? const SizedBox(width: 16, height: 16,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Icon(Icons.send),
                label: Text(_submitting ? 'Submitting...' : 'Submit Complaint'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(vertical: 12)),
              )),
            ])),
          ),
          const SizedBox(height: 16),

          // Previous complaints
          const Text('My Complaints', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 10),
          _complaintCard('Room light not working', 'Electricity',
 'The light in my room has not been working for 2 days', 'pending', '20/06/2026'),
          _complaintCard('Food quality issue', 'Food',
 'The food quality has degraded in the last week', 'resolved', '15/06/2026'),
        ]),
      ),
    );
  }

  Widget _complaintCard(String title, String category, String desc, String status, String date) {
    final statusColors = {'pending': Colors.orange, 'resolved': Colors.green, 'rejected': Colors.red};
    final color = statusColors[status] ?? Colors.grey;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Expanded(child: Text(title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
              child: Text(status.toUpperCase(),
                style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.bold))),
          ]),
          const SizedBox(height: 4),
          Row(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
              child: Text(category, style: const TextStyle(fontSize: 10, color: Colors.blue))),
            const SizedBox(width: 8),
            Text(date, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          ]),
          const SizedBox(height: 6),
          Text(desc, style: const TextStyle(fontSize: 12, color: Colors.grey), maxLines: 2,
            overflow: TextOverflow.ellipsis),
        ]),
      ),
    );
  }
}