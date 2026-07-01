import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/student_provider.dart';
import '../../services/api_service.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/language_provider.dart';

class CreateFeeScreen extends StatefulWidget {
  const CreateFeeScreen({super.key});
  @override
  State<CreateFeeScreen> createState() => _CreateFeeScreenState();
}

class _CreateFeeScreenState extends State<CreateFeeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amount = TextEditingController();
  final _dueDate = TextEditingController();
  String _feeType = 'Tuition Fee';
  String _paymentMode = 'Cash';
  int? _selectedStudentId;
  StudentModel? _selectedStudent;
  bool _saving = false;

  final Map<String, double> _feeStructure = {
        'Tuition Fee': 12500,
        'Transport Fee': 3500,
        'Exam Fee': 2000,
        'Library Fee': 500,
        'Sports Fee': 800,
        'Laboratory Fee': 1200,
        'Hostel Fee': 5000,
        'Miscellaneous': 1000,
  };

  final List<String> _feeTypes = [
 'Tuition Fee', 'Transport Fee', 'Exam Fee', 'Library Fee',
 'Sports Fee', 'Laboratory Fee', 'Hostel Fee', 'Miscellaneous',
  ];

  @override
  void initState() {
    super.initState();
    _amount.text = _feeStructure[_feeType]!.toStringAsFixed(0);
    WidgetsBinding.instance.addPostFrameCallback((_) =>
      context.read<StudentProvider>().fetchStudents());
  }

  @override
  void dispose() {
    _amount.dispose(); _dueDate.dispose();
    super.dispose();
  }

  double get _totalFee => double.tryParse(_amount.text) ?? 0;
  double get _finalPayable => _totalFee;

  @override
  Widget build(BuildContext context) {
    final students = context.watch<StudentProvider>().students;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.watch<LanguageProvider>().t('collect_fee')),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => context.go('/fees')),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

            // Student Selection
            _sectionHeader('Select Student', Icons.person_search),
            const SizedBox(height: 10),
            Card(child: Padding(
              padding: const EdgeInsets.all(14),
              child: DropdownButtonFormField<int>(
                value: _selectedStudentId,
                isExpanded: true,
                hint: const Text('Choose student'),
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.school),
                  border: InputBorder.none),
                items: students.map((s) => DropdownMenuItem<int>(
                  value: s.id,
                  child: Text('${s.name} - ${s.className} ${s.section}',
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13)))).toList(),
                onChanged: (v) {
                  setState(() {
                    _selectedStudentId = v;
                    _selectedStudent = students.firstWhere((s) => s.id == v);
                  });
                },
                validator: (v) => v == null ? 'Please select a student' : null,
              ),
            )),

            // Student Fee Summary
            if (_selectedStudent != null) ...[
              const SizedBox(height: 16),
              _sectionHeader('Fee Summary', Icons.summarize),
              const SizedBox(height: 10),
              Card(
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(children: [
                    Row(children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                        child: Text(
                          _selectedStudent!.name.isNotEmpty
                            ? _selectedStudent!.name[0].toUpperCase() : 'S',
                          style: const TextStyle(fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor))),
                      const SizedBox(width: 14),
                      Expanded(child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(_selectedStudent!.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                        Text('${_selectedStudent!.className} - ${_selectedStudent!.section}',
                          style: const TextStyle(color: Colors.grey, fontSize: 12)),
                        Text('Adm: ${_selectedStudent!.admissionNo}',
                          style: const TextStyle(color: Colors.grey, fontSize: 11)),
                      ])),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8)),
                        child: const Text('ACTIVE',
                          style: TextStyle(color: Colors.green,
                            fontWeight: FontWeight.bold, fontSize: 11))),
                    ]),
                    const Divider(height: 20),
                    _feeRow('Fee Type', _feeType, Colors.black87),
                    _feeRow('Total Amount', 'Rs ${_totalFee.toStringAsFixed(0)}', Colors.black87),
                    _feeRow('Paid', 'Rs 0', Colors.green),
                    _feeRow('Pending', 'Rs ${_totalFee.toStringAsFixed(0)}', Colors.orange),
                    _feeRow('Next Due', _dueDate.text.isEmpty ? 'Not set' : _dueDate.text, Colors.red),
                    _feeRow('Late Fine', 'Rs 0', Colors.red),
                    const Divider(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(10)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Final Payable',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          Text('Rs ${_finalPayable.toStringAsFixed(0)}',
                            style: const TextStyle(fontWeight: FontWeight.bold,
                              fontSize: 18, color: AppTheme.primaryColor)),
                        ])),
                  ]),
                ),
              ),
            ],

            const SizedBox(height: 16),
            _sectionHeader('Fee Details', Icons.receipt),
            const SizedBox(height: 10),
            Card(child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(children: [
                DropdownButtonFormField<String>(
                  value: _feeType,
                  decoration: const InputDecoration(
                    labelText: 'Fee Type *',
                    prefixIcon: Icon(Icons.category),
                    border: InputBorder.none),
                  items: _feeTypes.map((t) =>
                    DropdownMenuItem(value: t, child: Text(t))).toList(),
                  onChanged: (v) => setState(() {
                    _feeType = v!;
                    _amount.text = _feeStructure[v]!.toStringAsFixed(0);
                  }),
                ),
                const Divider(),
                TextFormField(
                  controller: _amount,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Amount (Rs.) *',
                    prefixIcon: Icon(Icons.currency_rupee),
                    border: InputBorder.none),
                  onChanged: (_) => setState(() {}),
                  validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                ),
                const Divider(),
                TextFormField(
                  controller: _dueDate,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Due Date *',
                    prefixIcon: Icon(Icons.calendar_today),
                    border: InputBorder.none),
                  onTap: () async {
                    final d = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now().add(const Duration(days: 30)),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2030));
                    if (d != null) setState(() =>
                      _dueDate.text =
        '${d.day.toString().padLeft(2,'0')}/${d.month.toString().padLeft(2,'0')}/${d.year}');
                  },
                  validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                ),
                const Divider(),
                DropdownButtonFormField<String>(
                  value: _paymentMode,
                  decoration: const InputDecoration(
                    labelText: 'Payment Method *',
                    prefixIcon: Icon(Icons.payment),
                    border: InputBorder.none),
                  items: ['Cash', 'Online Transfer', 'Cheque', 'UPI', 'DD']
                    .map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
                  onChanged: (v) => setState(() => _paymentMode = v!),
                ),
              ]),
            )),

            const SizedBox(height: 20),
            SizedBox(width: double.infinity, child: ElevatedButton.icon(
              onPressed: _saving ? null : _submit,
              icon: _saving
                ? const SizedBox(width: 18, height: 18,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Icon(Icons.payment),
              label: Text(_saving ? 'Processing...' :
 'Collect Fee - Rs ${_finalPayable.toStringAsFixed(0)}'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                backgroundColor: Colors.green),
            )),
          ]),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await apiService.post('/fees', {
        'student_id': _selectedStudentId,
        'fee_type': _feeType,
        'amount': double.tryParse(_amount.text) ?? 0,
        'due_date': _dueDate.text,
        'payment_mode': _paymentMode,
        'status': 'pending',
      });
      setState(() => _saving = false);
      if (mounted) _showSuccessScreen();
    } catch (e) {
      setState(() => _saving = false);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed: $e'), backgroundColor: Colors.red));
    }
  }

  void _showSuccessScreen() {
    final amount = _finalPayable.toStringAsFixed(0);
    final studentName = _selectedStudent?.name ?? 'Student';
    final txnId = 'TXN${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black87,
      transitionDuration: const Duration(milliseconds: 400),
      transitionBuilder: (ctx, anim, _, child) => ScaleTransition(
        scale: CurvedAnimation(parent: anim, curve: Curves.elasticOut),
        child: child),
      pageBuilder: (ctx, _, __) => Scaffold(
        backgroundColor: Colors.transparent,
        body: Container(
          color: Colors.white,
          width: double.infinity,
          height: double.infinity,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Success animation circle
                  Container(
                    width: 120, height: 120,
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.green.shade200, width: 3)),
                    child: const Icon(Icons.check_circle_rounded,
                      color: Colors.green, size: 80)),
                  const SizedBox(height: 24),
                  const Text('Fee Collected!',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold,
                      color: Colors.green)),
                  const SizedBox(height: 8),
                  Text('Payment received successfully',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
                  const SizedBox(height: 32),

                  // Receipt card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200)),
                    child: Column(children: [
                      // Transaction ID header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Receipt', style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.green.shade100,
                              borderRadius: BorderRadius.circular(20)),
                            child: const Text('PAID',
                              style: TextStyle(color: Colors.green,
                                fontWeight: FontWeight.bold, fontSize: 12))),
                        ]),
                      const Divider(height: 20),
                      _receiptRow(Icons.person, 'Student', studentName),
                      const SizedBox(height: 10),
                      _receiptRow(Icons.category, 'Fee Type', _feeType),
                      const SizedBox(height: 10),
                      _receiptRow(Icons.payment, 'Payment Mode', _paymentMode),
                      const SizedBox(height: 10),
                      _receiptRow(Icons.calendar_today, 'Due Date', _dueDate.text),
                      const SizedBox(height: 10),
                      _receiptRow(Icons.tag, 'Transaction ID', txnId),
                      const Divider(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Amount Paid',
                            style: TextStyle(fontWeight: FontWeight.bold,
                              fontSize: 16)),
                          Text('₹$amount',
                            style: const TextStyle(fontWeight: FontWeight.bold,
                              fontSize: 22, color: Colors.green)),
                        ]),
                    ]),
                  ),
                  const SizedBox(height: 32),

                  // Buttons
                  Row(children: [
                    Expanded(child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        // Reset form for new entry
                        setState(() {
                          _selectedStudentId = null;
                          _selectedStudent = null;
                          _amount.text = _feeStructure[_feeType]!.toStringAsFixed(0);
                          _dueDate.clear();
                        });
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('New Fee'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12))))),
                    const SizedBox(width: 12),
                    Expanded(child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        context.go('/fees');
                      },
                      icon: const Icon(Icons.list_alt),
                      label: const Text('View Fees'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12))))),
                  ]),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _receiptRow(IconData icon, String label, String value) =>
    Row(children: [
      Icon(icon, size: 16, color: Colors.grey),
      const SizedBox(width: 8),
      SizedBox(width: 100, child: Text(label,
        style: const TextStyle(color: Colors.grey, fontSize: 13))),
      Expanded(child: Text(value,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        textAlign: TextAlign.end,
        overflow: TextOverflow.ellipsis)),
    ]);

  Widget _sectionHeader(String title, IconData icon) => Row(children: [
    Container(width: 4, height: 18,
      decoration: BoxDecoration(
        color: AppTheme.primaryColor, borderRadius: BorderRadius.circular(2))),
    const SizedBox(width: 8),
    Icon(icon, color: AppTheme.primaryColor, size: 18),
    const SizedBox(width: 6),
    Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
  ]);

  Widget _feeRow(String label, String value, Color color) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey)),
      Text(value, style: TextStyle(fontSize: 13,
        fontWeight: FontWeight.w600, color: color)),
    ]));
}


