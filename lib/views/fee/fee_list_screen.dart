import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../providers/fee_provider.dart';
import '../../providers/auth_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/language_provider.dart';

class FeeListScreen extends StatefulWidget {
  const FeeListScreen({super.key});
  @override
  State<FeeListScreen> createState() => _FeeListScreenState();
}

class _FeeListScreenState extends State<FeeListScreen> {
  String _filter = 'all';

  // School UPI ID ? change karo apna actual UPI ID
  static const String _schoolUpiId = '9819117133@kotakbank';
  static const String _schoolName = 'School Fee Payment';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) =>
      context.read<FeeProvider>().fetchFees());
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<FeeProvider>();
    final role = context.watch<AuthProvider>().user?.role;
    final isAdmin = role == 'admin' || role == 'staff';
    final fees = _filter == 'all' ? p.fees
      : p.fees.where((f) => f.status == _filter).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(context.watch<LanguageProvider>().t('fee_management')),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => context.go(
            role == 'student' ? '/dashboard/student'
            : role == 'parent' ? '/dashboard/parent'
            : '/dashboard/admin')),
        actions: [
          if (isAdmin) IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.go('/fees/create'),
            tooltip: 'Collect Fee'),
          if (!isAdmin) IconButton(
            icon: const Icon(Icons.qr_code),
            onPressed: () => _showQRPayment(context, 0, 'Fee Payment'),
            tooltip: 'Pay via QR'),
        ],
      ),
      body: Column(children: [
        // Summary row
        Container(
          color: Colors.white,
          padding: const EdgeInsets.all(14),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            _statCard('Total', p.fees.length.toString(), Colors.blue),
            _statCard('Paid', p.fees.where((f) => f.status == 'paid').length.toString(), Colors.green),
            _statCard('Pending', p.fees.where((f) => f.status == 'pending').length.toString(), Colors.orange),
            _statCard('Overdue', p.fees.where((f) => f.status == 'overdue').length.toString(), Colors.red),
          ])),

        // Filter chips
        SizedBox(height: 44,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            children: [
              _chip('all', 'All'),
              _chip('pending', 'Pending'),
              _chip('paid', 'Paid'),
              _chip('overdue', 'Overdue'),
            ],
          )),

        // Fee list
        Expanded(child: p.isLoading
          ? const Center(child: CircularProgressIndicator())
          : fees.isEmpty
            ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.receipt, size: 64, color: Colors.grey.shade300),
                const SizedBox(height: 12),
                const Text('No fees found', style: TextStyle(color: Colors.grey)),
              ]))
            : RefreshIndicator(
                onRefresh: () => context.read<FeeProvider>().fetchFees(),
                child: ListView.builder(
                  padding: const EdgeInsets.all(14),
                  itemCount: fees.length,
                  itemBuilder: (ctx, i) => _feeCard(ctx, fees[i], isAdmin, p),
                ),
              )),
      ]),
    );
  }

  Widget _feeCard(BuildContext ctx, fee, bool isAdmin, FeeProvider p) {
    final statusColors = {
        'paid': Colors.green,
        'pending': Colors.orange,
        'overdue': Colors.red,
    };
    final color = statusColors[fee.status] ?? Colors.grey;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(fee.studentName,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              Text(fee.feeType,
                style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ])),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8)),
              child: Text(fee.status.toUpperCase(),
                style: TextStyle(fontSize: 11, color: color,
                  fontWeight: FontWeight.bold))),
          ]),
          const Divider(height: 14),
          Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Rs ${fee.amount.toStringAsFixed(0)}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor)),
              Text('Due: ${fee.dueDate}',
                style: const TextStyle(fontSize: 11, color: Colors.grey)),
            ])),
          ]),
          const SizedBox(height: 10),

          // Admin buttons
          if (isAdmin && fee.status != 'paid') Row(children: [
            Expanded(child: ElevatedButton.icon(
              onPressed: () async {
                await p.updateFeeStatus(fee.id, 'paid');
                if (ctx.mounted) ScaffoldMessenger.of(ctx).showSnackBar(
                  const SnackBar(content: Text('Fee marked as paid!'),
                    backgroundColor: Colors.green));
              },
              icon: const Icon(Icons.check, size: 16),
              label: const Text('Mark Paid', style: TextStyle(fontSize: 12)),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            )),
            const SizedBox(width: 8),
            Expanded(child: OutlinedButton.icon(
              onPressed: () => context.go('/fees/receipt/${fee.id}'),
              icon: const Icon(Icons.receipt, size: 16),
              label: const Text('Receipt', style: TextStyle(fontSize: 12)),
            )),
          ]),

          // Admin: paid fees ki receipt history
          if (isAdmin && fee.status == 'paid') Row(children: [
            Expanded(child: OutlinedButton.icon(
              onPressed: () => context.go('/fees/receipt/${fee.id}'),
              icon: const Icon(Icons.receipt_long, size: 16),
              label: const Text('View Receipt', style: TextStyle(fontSize: 12)),
              style: OutlinedButton.styleFrom(foregroundColor: Colors.green),
            )),
          ]),

          // Student buttons ? QR Pay
          if (!isAdmin) ...[
            if (fee.status != 'paid') ...[
              Row(children: [
                Expanded(child: ElevatedButton.icon(
                  onPressed: () => context.go('/fees/payment/${fee.id}'),
                  icon: const Icon(Icons.qr_code, size: 16),
                  label: const Text('Pay via QR', style: TextStyle(fontSize: 12)),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                )),
                const SizedBox(width: 8),
                Expanded(child: OutlinedButton.icon(
                  onPressed: () => context.go('/fees/receipt/${fee.id}'),
                  icon: const Icon(Icons.receipt, size: 16),
                  label: const Text('Receipt', style: TextStyle(fontSize: 12)),
                )),
              ]),
            ] else ...[
              OutlinedButton.icon(
                onPressed: () => context.go('/fees/receipt/${fee.id}'),
                icon: const Icon(Icons.receipt, size: 16),
                label: const Text('View Receipt', style: TextStyle(fontSize: 12)),
              ),
            ],
          ],
        ]),
      ),
    );
  }

  void _showQRPayment(BuildContext context, double amount, String purpose) {
    // UPI payment string
    final upiString = amount > 0
      ? 'upi://pay?pa=$_schoolUpiId&pn=$_schoolName&am=${amount.toStringAsFixed(2)}&tn=$purpose&cu=INR'
      : 'upi://pay?pa=$_schoolUpiId&pn=$_schoolName&cu=INR';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 40, height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 16),
          const Text('Pay via QR Code',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text('Scan with any UPI app',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
          const SizedBox(height: 20),

          // QR Code
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                blurRadius: 10)]),
            child: QrImageView(
              data: upiString,
              version: QrVersions.auto,
              size: 220,
              backgroundColor: Colors.white,
            )),
          const SizedBox(height: 16),

          // Amount
          if (amount > 0) Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10)),
            child: Text('Amount: Rs ${amount.toStringAsFixed(0)}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold,
                color: Colors.green))),
          const SizedBox(height: 8),
          Text('UPI ID: $_schoolUpiId',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
          const SizedBox(height: 8),
          Text(purpose,
            style: const TextStyle(fontSize: 12),
            textAlign: TextAlign.center),
          const SizedBox(height: 16),

          // UPI Apps
          const Text('Pay using:',
            style: TextStyle(fontSize: 13, color: Colors.grey)),
          const SizedBox(height: 8),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            _upiApp('GPay', Colors.blue),
            const SizedBox(width: 12),
            _upiApp('PhonePe', Colors.purple),
            const SizedBox(width: 12),
            _upiApp('Paytm', Colors.teal),
            const SizedBox(width: 12),
            _upiApp('BHIM', Colors.orange),
          ]),
          const SizedBox(height: 16),
          SizedBox(width: double.infinity, child: OutlinedButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'))),
        ]),
      ),
    );
  }

  Widget _upiApp(String name, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: color.withOpacity(0.3))),
    child: Text(name, style: TextStyle(color: color, fontWeight: FontWeight.bold,
      fontSize: 12)));

  Widget _chip(String value, String label) => Padding(
    padding: const EdgeInsets.only(right: 8),
    child: FilterChip(
      label: Text(label, style: TextStyle(fontSize: 12,
        color: _filter == value ? Colors.white : Colors.black87)),
      selected: _filter == value,
      onSelected: (_) => setState(() => _filter = value),
      backgroundColor: Colors.white,
      selectedColor: AppTheme.primaryColor,
      checkmarkColor: Colors.white,
    ));

  Widget _statCard(String label, String value, Color color) => Column(children: [
    Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,
      color: color)),
    Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
  ]);
}




