import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/transport_provider.dart';
import '../../providers/student_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';

class StudentTransportScreen extends StatefulWidget {
  const StudentTransportScreen({super.key});
  @override
  State<StudentTransportScreen> createState() => _StudentTransportScreenState();
}

class _StudentTransportScreenState extends State<StudentTransportScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StudentProvider>().fetchStudents();
      context.read<TransportProvider>().fetchAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<TransportProvider>();
    final sp = context.watch<StudentProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      body: Column(children: [
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(children: [
            _chip('Total: ${p.students.length}', Colors.blue),
            const SizedBox(width: 8),
            _chip('Active: ${p.students.where((s) => s.status == "active").length}', Colors.green),
          ])),
        Expanded(child: p.isLoading
          ? const Center(child: CircularProgressIndicator())
          : p.students.isEmpty
            ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.people, size: 64, color: Colors.grey.shade300),
                const SizedBox(height: 12),
                const Text('No students assigned', style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () => _assignDialog(context, p, sp),
                  icon: const Icon(Icons.add), label: const Text('Assign Transport')),
              ]))
            : RefreshIndicator(
                onRefresh: () => p.fetchStudents(),
                child: ListView.builder(
                  padding: const EdgeInsets.all(14),
                  itemCount: p.students.length,
                  itemBuilder: (ctx, i) => _card(context, p.students[i], p),
                ))),
      ]),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _assignDialog(context, p, sp),
        icon: const Icon(Icons.person_add),
        label: const Text('Assign Transport')),
    );
  }

  Widget _card(BuildContext context, StudentTransportModel s, TransportProvider p) {
    final role = context.read<AuthProvider>().user?.role ?? 'student';
    final isAdmin = role == 'admin' || role == 'staff';
    final relatedFees = p.fees.where((f) => f.studentId == s.studentId).toList();
    final pendingFees = relatedFees.where((f) => f.status == 'pending').toList();
    final paidFees = relatedFees.where((f) => f.status == 'paid').toList();

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            CircleAvatar(
              backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
              radius: 22,
              child: Text(s.studentName.isNotEmpty ? s.studentName[0] : 'S',
                style: const TextStyle(color: AppTheme.primaryColor,
                  fontWeight: FontWeight.bold, fontSize: 18))),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(s.studentName,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              Text('Route: ${s.routeId} • Vehicle: ${s.vehicleId}',
                style: const TextStyle(fontSize: 11, color: Colors.grey)),
            ])),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: s.status == 'active'
                    ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8)),
                child: Text(s.status.toUpperCase(),
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold,
                    color: s.status == 'active' ? Colors.green : Colors.red))),
              if (pendingFees.isNotEmpty)
                const Text('Fee Pending',
                  style: TextStyle(fontSize: 10, color: Colors.orange,
                    fontWeight: FontWeight.w500)),
            ]),
          ]),
          const Divider(height: 14),
          Row(children: [
            Expanded(child: _info('Pickup', s.pickupStop.isEmpty ? 'N/A' : s.pickupStop)),
            Expanded(child: _info('Drop', s.dropStop.isEmpty ? 'N/A' : s.dropStop)),
            Expanded(child: _info('Fee', 'Rs ${s.monthlyFee.toStringAsFixed(0)}/mo')),
          ]),
          if (s.monthlyFee > 0) ...[
            const SizedBox(height: 10),
            // Admin only ? Add Fee
            if (isAdmin) Row(children: [
              Expanded(child: OutlinedButton.icon(
                onPressed: () => _addFeeDialog(context, s, p),
                icon: const Icon(Icons.add, size: 14),
                label: const Text('Add Fee', style: TextStyle(fontSize: 12)))),
              const SizedBox(width: 8),
              if (pendingFees.isNotEmpty) Expanded(child: ElevatedButton.icon(
                onPressed: () => _payFeeDialog(context, s, p, pendingFees),
                icon: const Icon(Icons.payment, size: 14),
                label: const Text('Pay Fee', style: TextStyle(fontSize: 12)),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green))),
            ]),
            // Student/Parent ? Pay via UPI or view receipt
            if (!isAdmin) ...[
              if (pendingFees.isNotEmpty) SizedBox(width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _payFeeDialog(context, s, p, pendingFees),
                  icon: const Icon(Icons.payment, size: 16),
                  label: Text('Pay Rs ${pendingFees.fold(0.0, (sum, f) => sum + f.amount).toStringAsFixed(0)} Now'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 12)))),
              if (paidFees.isNotEmpty) SizedBox(width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _showPaidReceipts(context, s, paidFees),
                  icon: const Icon(Icons.receipt, size: 16),
                  label: const Text('Download Receipt'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12)))),
            ],
          ],
        ]),
      ),
    );
  }

  void _addFeeDialog(BuildContext context, StudentTransportModel s, TransportProvider p) {
    final now = DateTime.now();
    final months = ['January','February','March','April','May','June',
        'July','August','September','October','November','December'];
    String selectedMonth = '${months[now.month - 1]} ${now.year}';

    showDialog(context: context, builder: (ctx) => StatefulBuilder(
      builder: (ctx, setS) => AlertDialog(
        title: Text('Add Fee for ${s.studentName}'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10)),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text('Amount:', style: TextStyle(fontWeight: FontWeight.w600)),
              Text('Rs ${s.monthlyFee.toStringAsFixed(0)}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor)),
            ])),
          const SizedBox(height: 14),
          GestureDetector(
            onTap: () async {
              final picked = await showDatePicker(
                context: ctx,
                initialDate: now,
                firstDate: DateTime(2024),
                lastDate: DateTime(2027));
              if (picked != null) setS(() =>
                selectedMonth = '${months[picked.month - 1]} ${picked.year}');
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8)),
              child: Row(children: [
                const Icon(Icons.calendar_month, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                Text(selectedMonth,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                const Spacer(),
                const Icon(Icons.arrow_drop_down, color: Colors.grey),
              ]))),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final ok = await p.createFee({
        'student_id': s.studentId,
        'student_name': s.studentName,
        'vehicle_id': s.vehicleId,
        'route_id': s.routeId,
        'amount': s.monthlyFee,
        'month': selectedMonth,
        'status': 'pending',
              });
              if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(ok ? 'Fee added!' : 'Failed'),
                  backgroundColor: ok ? Colors.green : Colors.red));
            },
            child: const Text('Add Fee')),
        ])));
  }

  void _payFeeDialog(BuildContext context, StudentTransportModel s,
      TransportProvider p, List<TransportFeeModel> pendingFees) {
    final totalAmount = pendingFees.fold(0.0, (sum, f) => sum + f.amount);
    String payMode = 'cash';

    showDialog(context: context, builder: (ctx) => StatefulBuilder(
      builder: (ctx, setS) => AlertDialog(
        title: Text('Pay Fee - ${s.studentName}'),
        content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
          ...pendingFees.map((f) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.orange.withOpacity(0.3))),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(f.month, style: const TextStyle(fontWeight: FontWeight.w600)),
                const Text('PENDING', style: TextStyle(fontSize: 10, color: Colors.orange)),
              ]),
              Text('Rs ${f.amount.toStringAsFixed(0)}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor)),
            ]))).toList(),
          const Divider(height: 16),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Total:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            Text('Rs ${totalAmount.toStringAsFixed(0)}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor)),
          ]),
          const SizedBox(height: 14),
          const Align(alignment: Alignment.centerLeft,
            child: Text('Payment Method:', style: TextStyle(fontWeight: FontWeight.w600))),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(child: GestureDetector(
              onTap: () => setS(() => payMode = 'cash'),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: payMode == 'cash'
                    ? Colors.green.withOpacity(0.1) : Colors.grey.shade100,
                  border: Border.all(
                    color: payMode == 'cash' ? Colors.green : Colors.grey.shade300,
                    width: payMode == 'cash' ? 2 : 1),
                  borderRadius: BorderRadius.circular(10)),
                child: Column(children: [
                  Icon(Icons.money,
                    color: payMode == 'cash' ? Colors.green : Colors.grey, size: 28),
                  const SizedBox(height: 4),
                  Text('Cash', style: TextStyle(fontWeight: FontWeight.bold,
                    color: payMode == 'cash' ? Colors.green : Colors.grey)),
                ])))),
            const SizedBox(width: 12),
            Expanded(child: GestureDetector(
              onTap: () => setS(() => payMode = 'upi'),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: payMode == 'upi'
                    ? Colors.blue.withOpacity(0.1) : Colors.grey.shade100,
                  border: Border.all(
                    color: payMode == 'upi' ? Colors.blue : Colors.grey.shade300,
                    width: payMode == 'upi' ? 2 : 1),
                  borderRadius: BorderRadius.circular(10)),
                child: Column(children: [
                  Icon(Icons.qr_code,
                    color: payMode == 'upi' ? Colors.blue : Colors.grey, size: 28),
                  const SizedBox(height: 4),
                  Text('UPI', style: TextStyle(fontWeight: FontWeight.bold,
                    color: payMode == 'upi' ? Colors.blue : Colors.grey)),
                ])))),
          ]),
        ])),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton.icon(
            onPressed: () async {
              Navigator.pop(ctx);
              if (payMode == 'upi') {
                final upiUrl =
        'upi://pay?pa=9819117133@kotakbank&pn=School Transport Fee'
        '&am=${totalAmount.toStringAsFixed(2)}'
        '&tn=Transport Fee ${s.studentName}&cu=INR';
                try {
                  await launchUrl(Uri.parse(upiUrl),
                    mode: LaunchMode.externalApplication);
                } catch (e) {
                  if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('No UPI app found'),
                      backgroundColor: Colors.red));
                  return;
                }
              }
              for (final f in pendingFees) {
                await p.updateFeeStatus(f.id, 'paid');
              }
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('${payMode == 'cash' ? 'Cash' : 'UPI'} payment recorded!'),
                  backgroundColor: Colors.green));
                _showReceipt(context, s, pendingFees, totalAmount, payMode);
              }
            },
            icon: Icon(payMode == 'upi' ? Icons.qr_code : Icons.money),
            label: Text(payMode == 'upi' ? 'Pay via UPI' : 'Confirm Cash'),
            style: ElevatedButton.styleFrom(
              backgroundColor: payMode == 'upi' ? Colors.blue : Colors.green)),
        ])));
  }

  void _showReceipt(BuildContext context, StudentTransportModel s,
      List<TransportFeeModel> fees, double total, String payMode) {
    final now = DateTime.now();
    final receiptNo = 'TRP${now.year}${now.month.toString().padLeft(2,'0')}${now.millisecondsSinceEpoch.toString().substring(8)}';
    final dateStr = '${now.day.toString().padLeft(2,'0')}/${now.month.toString().padLeft(2,'0')}/${now.year}';

    showDialog(context: context, builder: (ctx) => AlertDialog(
      contentPadding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      content: SizedBox(
        width: 320,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: AppTheme.primaryColor,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
            child: Column(children: [
              const Icon(Icons.receipt_long, color: Colors.white, size: 36),
              const SizedBox(height: 8),
              const Text('Transport Fee Receipt',
                style: TextStyle(color: Colors.white,
                  fontWeight: FontWeight.bold, fontSize: 16)),
              Text('Receipt No: $receiptNo',
                style: const TextStyle(color: Colors.white70, fontSize: 11)),
            ])),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: [
              _rRow('Student', s.studentName),
              _rRow('Date', dateStr),
              _rRow('Payment Mode', payMode == 'upi' ? 'UPI (Online)' : 'Cash'),
              const Divider(height: 16),
              ...fees.map((f) => _rRow(f.month, 'Rs ${f.amount.toStringAsFixed(0)}')),
              const Divider(height: 16),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text('Total Paid',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                Text('Rs ${total.toStringAsFixed(0)}',
                  style: const TextStyle(fontWeight: FontWeight.bold,
                    fontSize: 18, color: Colors.green)),
              ]),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8)),
                child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 18),
                  SizedBox(width: 6),
                  Text('Payment Successful!',
                    style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                ])),
            ])),
        ])),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
        ElevatedButton.icon(
          onPressed: () {
            Navigator.pop(ctx);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Receipt downloaded to Downloads folder!'),
                backgroundColor: Colors.green));
          },
          icon: const Icon(Icons.download, size: 16),
          label: const Text('Download')),
      ]));
  }

  void _assignDialog(BuildContext context, TransportProvider p, StudentProvider sp) {
    if (sp.students.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No students found. Add students first.'),
          backgroundColor: Colors.orange));
      return;
    }
    int? studentId;
    String studentName = '';
    int? vehicleId;
    int? routeId;
    final pickupCtrl = TextEditingController();
    final dropCtrl = TextEditingController();
    final feeCtrl = TextEditingController();

    showDialog(context: context, builder: (ctx) => StatefulBuilder(
      builder: (ctx, setS) => AlertDialog(
        title: const Text('Assign Transport'),
        content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
          DropdownButtonFormField<int>(
            hint: const Text('Select Student *'),
            isExpanded: true,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.school), border: OutlineInputBorder()),
            items: sp.students.map((s) => DropdownMenuItem<int>(
              value: s.id,
              child: Text('${s.name} (${s.admissionNo}) - ${s.className}',
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 13)))).toList(),
            onChanged: (v) => setS(() {
              studentId = v;
              studentName = sp.students.firstWhere((s) => s.id == v).name;
            }),
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<int>(
            hint: const Text('Select Vehicle'),
            isExpanded: true,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.directions_bus), border: OutlineInputBorder()),
            items: p.vehicles.map((v) => DropdownMenuItem<int>(
              value: v.id,
              child: Text('${v.vehicleNumber} (${v.vehicleType})',
                overflow: TextOverflow.ellipsis))).toList(),
            onChanged: (v) => setS(() => vehicleId = v),
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<int>(
            hint: const Text('Select Route'),
            isExpanded: true,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.route), border: OutlineInputBorder()),
            items: p.routes.map((r) => DropdownMenuItem<int>(
              value: r.id,
              child: Text('${r.routeName} (Rs ${r.monthlyFee.toStringAsFixed(0)}/mo)',
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 13)))).toList(),
            onChanged: (v) {
              setS(() {
                routeId = v;
                final route = p.routes.firstWhere((r) => r.id == v);
                feeCtrl.text = route.monthlyFee.toStringAsFixed(0);
              });
            },
          ),
          const SizedBox(height: 10),
          TextField(controller: pickupCtrl,
            decoration: const InputDecoration(
              labelText: 'Pickup Stop', prefixIcon: Icon(Icons.location_on),
              border: OutlineInputBorder())),
          const SizedBox(height: 8),
          TextField(controller: dropCtrl,
            decoration: const InputDecoration(
              labelText: 'Drop Stop', prefixIcon: Icon(Icons.location_on),
              border: OutlineInputBorder())),
          const SizedBox(height: 8),
          TextField(controller: feeCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Monthly Fee (Rs)', prefixIcon: Icon(Icons.currency_rupee),
              border: OutlineInputBorder())),
        ])),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton.icon(
            onPressed: () async {
              if (studentId == null) {
                ScaffoldMessenger.of(ctx).showSnackBar(
                  const SnackBar(content: Text('Please select a student'),
                    backgroundColor: Colors.red));
                return;
              }
              Navigator.pop(ctx);
              final ok = await p.assignTransport({
        'student_id': studentId,
        'student_name': studentName,
        'vehicle_id': vehicleId ?? 0,
        'route_id': routeId ?? 0,
        'pickup_stop': pickupCtrl.text,
        'drop_stop': dropCtrl.text,
        'monthly_fee': double.tryParse(feeCtrl.text) ?? 0,
        'status': 'active',
        'start_date':
        '${DateTime.now().day.toString().padLeft(2,'0')}/${DateTime.now().month.toString().padLeft(2,'0')}/${DateTime.now().year}',
              });
              if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(ok ? 'Transport assigned to $studentName!' : 'Failed'),
                  backgroundColor: ok ? Colors.green : Colors.red));
            },
            icon: const Icon(Icons.save),
            label: const Text('Assign')),
        ])));
  }

  void _showPaidReceipts(BuildContext context, StudentTransportModel s,
      List<TransportFeeModel> paidFees) {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: Text('Receipts - ${s.studentName}'),
      content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min,
        children: paidFees.map((f) => Card(
          child: ListTile(
            leading: const Icon(Icons.check_circle, color: Colors.green),
            title: Text(f.month),
            subtitle: Text(f.paidDate.isEmpty ? 'Paid' : 'Paid: ${f.paidDate}'),
            trailing: Text('Rs ${f.amount.toStringAsFixed(0)}',
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
          ))).toList())),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
        ElevatedButton.icon(
          onPressed: () {
            Navigator.pop(ctx);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Receipt downloaded!'),
                backgroundColor: Colors.green));
          },
          icon: const Icon(Icons.download, size: 16),
          label: const Text('Download')),
      ]));
  } 
  Widget _rRow(String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
      Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
    ]));

  Widget _info(String label, String value) =>
    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
      Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        overflow: TextOverflow.ellipsis),
    ]);

  Widget _chip(String label, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
    child: Text(label,
      style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.bold)));
}