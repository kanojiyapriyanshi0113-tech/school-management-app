import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/fee_provider.dart';
import '../../providers/auth_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/language_provider.dart';

class FeePaymentScreen extends StatefulWidget {
  final int feeId;
  const FeePaymentScreen({super.key, required this.feeId});
  @override
  State<FeePaymentScreen> createState() => _FeePaymentScreenState();
}

class _FeePaymentScreenState extends State<FeePaymentScreen> {
  static const String _upiId = '9819117133@kotakbank';
  static const String _merchantName = 'School Fee Payment';
  bool _paying = false;

  String _buildUpiUrl(double amount, String purpose) =>
        'upi://pay?pa=$_upiId&pn=$_merchantName&am=${amount.toStringAsFixed(2)}&tn=$purpose&cu=INR';

  @override
  Widget build(BuildContext context) {
    final p = context.watch<FeeProvider>();
    final role = context.watch<AuthProvider>().user?.role;
    final isAdmin = role == 'admin' || role == 'staff';
    FeeModel? fee;
    try {
      fee = p.fees.firstWhere((f) => f.id == widget.feeId);
    } catch (_) {}

    if (fee == null) return Scaffold(
      appBar: AppBar(title: const Text('Fee Details')),
      body: const Center(child: CircularProgressIndicator()));

    final upiUrl = _buildUpiUrl(
      fee.pending, '${fee.feeType} - ${fee.studentName}');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fee Details & Payment'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => context.go('/fees')),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [

          // Fee Info Card
          Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(children: [
                // Student header
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12)),
                  child: Row(children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: AppTheme.primaryColor.withOpacity(0.15),
                      child: Text(
                        fee.studentName.isNotEmpty
                          ? fee.studentName[0].toUpperCase() : 'S',
                        style: const TextStyle(fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor))),
                    const SizedBox(width: 12),
                    Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(fee.studentName,
                        style: const TextStyle(fontWeight: FontWeight.bold,
                          fontSize: 16)),
                      Text(fee.feeType,
                        style: const TextStyle(color: Colors.grey, fontSize: 13)),
                    ])),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: _statusColor(fee.status).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8)),
                      child: Text(fee.status.toUpperCase(),
                        style: TextStyle(fontSize: 11,
                          color: _statusColor(fee.status),
                          fontWeight: FontWeight.bold))),
                  ])),
                const SizedBox(height: 16),

                _row('Total Fee', 'Rs ${fee.amount.toStringAsFixed(0)}', Colors.black87),
                _row('Paid', 'Rs ${fee.paidAmount.toStringAsFixed(0)}', Colors.green),
                _row('Pending', 'Rs ${fee.pending.toStringAsFixed(0)}', Colors.orange),
                _row('Due Date', fee.dueDate, Colors.red),
                if (fee.paidDate.isNotEmpty)
                  _row('Paid Date', fee.paidDate, Colors.green),
                const Divider(height: 20),

                // Amount box
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [
                      AppTheme.primaryColor, Colors.blue.shade700]),
                    borderRadius: BorderRadius.circular(12)),
                  child: Column(children: [
                    const Text('Amount to Pay',
                      style: TextStyle(color: Colors.white70, fontSize: 13)),
                    const SizedBox(height: 4),
                    Text('Rs ${fee.pending.toStringAsFixed(0)}',
                      style: const TextStyle(color: Colors.white,
                        fontSize: 28, fontWeight: FontWeight.bold)),
                  ])),
              ])),
          ),
          const SizedBox(height: 16),

          // Payment section
          if (fee.status != 'paid') ...[
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  const Text('Pay Now',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  const Text('Tap to pay directly from your UPI app',
                    style: TextStyle(color: Colors.grey, fontSize: 12)),
                  const SizedBox(height: 16),

                  // UPI App buttons
                  Row(children: [
                    Expanded(child: _upiBtn('GPay', Icons.g_mobiledata,
                      Colors.blue, 'tez://upi/pay?pa=$_upiId&pn=$_merchantName&am=${fee.pending.toStringAsFixed(2)}&tn=${fee.feeType}&cu=INR')),
                    const SizedBox(width: 8),
                    Expanded(child: _upiBtn('PhonePe', Icons.phone_android,
                      Colors.purple, 'phonepe://pay?pa=$_upiId&pn=$_merchantName&am=${fee.pending.toStringAsFixed(2)}&tn=${fee.feeType}&cu=INR')),
                    const SizedBox(width: 8),
                    Expanded(child: _upiBtn('Paytm', Icons.account_balance_wallet,
                      Colors.teal, 'paytmmp://pay?pa=$_upiId&pn=$_merchantName&am=${fee.pending.toStringAsFixed(2)}&tn=${fee.feeType}&cu=INR')),
                  ]),
                  const SizedBox(height: 12),

                  // Pay Now button
                  SizedBox(width: double.infinity, child: ElevatedButton.icon(
                    onPressed: _paying ? null : () => _launchUpi(upiUrl),
                    icon: _paying
                      ? const SizedBox(width: 16, height: 16,
                          child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                      : const Icon(Icons.payment),
                    label: Text(_paying ? 'Opening UPI...'
                      : 'Pay Rs ${fee.pending.toStringAsFixed(0)} Now'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 14)),
                  )),
                  const SizedBox(height: 10),

                  // QR Code
                  SizedBox(width: double.infinity, child: OutlinedButton.icon(
                    onPressed: () => _showQR(context, fee!, upiUrl),
                    icon: const Icon(Icons.qr_code),
                    label: const Text('Show QR Code'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12)),
                  )),
                ])),
            ),
          ] else ...[
            Card(
              color: Colors.green.withOpacity(0.08),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 40),
                  const SizedBox(width: 16),
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('Fee Paid!',
                      style: TextStyle(fontWeight: FontWeight.bold,
                        fontSize: 16, color: Colors.green)),
                    if (fee.paidDate.isNotEmpty)
                      Text('Paid on: ${fee.paidDate}',
                        style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  ]),
                ])),
            ),
          ],
          const SizedBox(height: 12),

          // Receipt
          SizedBox(width: double.infinity, child: OutlinedButton.icon(
            onPressed: () => context.go('/fees/receipt/${fee!.id}'),
            icon: const Icon(Icons.receipt),
            label: Text(context.watch<LanguageProvider>().t('view_receipt')),
          )),
        ]),
      ),
    );
  }

  Future<void> _launchUpi(String url) async {
  setState(() => _paying = true);
  try {
    final uri = Uri.parse(url);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (e) {
    // Try fallback generic UPI
    try {
      final fallback = Uri.parse(
 'upi://pay?pa=$_upiId&pn=$_merchantName&cu=INR');
      await launchUrl(fallback, mode: LaunchMode.externalApplication);
    } catch (e2) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please open your UPI app and pay to: $_upiId'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 5)));
    }
  }
  setState(() => _paying = false);
}

  void _showQR(BuildContext context, FeeModel fee, String upiUrl) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 40, height: 4,
            decoration: BoxDecoration(color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 16),
          const Text('Scan to Pay',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text('Rs ${fee.pending.toStringAsFixed(0)} • ${fee.feeType}',
            style: const TextStyle(color: Colors.grey, fontSize: 13)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(
                color: Colors.grey.withOpacity(0.2), blurRadius: 10)]),
            child: QrImageView(
              data: upiUrl, version: QrVersions.auto,
              size: 200, backgroundColor: Colors.white)),
          const SizedBox(height: 12),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Icon(Icons.account_balance_wallet, size: 16, color: Colors.grey),
            const SizedBox(width: 6),
            const Text('UPI: $_upiId',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () {
                Clipboard.setData(const ClipboardData(text: _upiId));
                ScaffoldMessenger.of(ctx).showSnackBar(
                  const SnackBar(content: Text('UPI ID copied!'),
                    backgroundColor: Colors.green));
              },
              child: const Icon(Icons.copy, size: 16, color: Colors.blue)),
          ]),
          const SizedBox(height: 16),
          SizedBox(width: double.infinity, child: OutlinedButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'))),
        ]),
      ),
    );
  }

  Widget _upiBtn(String label, IconData icon, Color color, String url) =>
    GestureDetector(
      onTap: () => _launchUpi(url),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.3))),
        child: Column(children: [
          Icon(icon, color: color, size: 26),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: color,
            fontWeight: FontWeight.bold, fontSize: 12)),
        ])));

  Widget _row(String label, String value, Color color) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey)),
      Text(value, style: TextStyle(fontSize: 13,
        fontWeight: FontWeight.w600, color: color)),
    ]));

  Color _statusColor(String status) {
    switch (status) {
      case 'paid': return Colors.green;
      case 'overdue': return Colors.red;
      default: return Colors.orange;
    }
  }
}


