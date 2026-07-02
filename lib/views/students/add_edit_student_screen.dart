import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../providers/student_provider.dart';
import '../../services/api_service.dart';
import '../../providers/language_provider.dart';

class AddEditStudentScreen extends StatefulWidget {
  final bool isEdit;
  final int? studentId;
  const AddEditStudentScreen({super.key, required this.isEdit, this.studentId});
  @override
  State<AddEditStudentScreen> createState() => _AddEditStudentScreenState();
}

class _AddEditStudentScreenState extends State<AddEditStudentScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  bool _saving = false;
  final Map<String, String?> _uploadedDocs = {};

  final _name = TextEditingController();
  final _dob = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _address = TextEditingController();
  final _admissionNo = TextEditingController();
  final _rollNo = TextEditingController();
  final _admissionDate = TextEditingController();
  final _fatherName = TextEditingController();
  final _motherName = TextEditingController();
  final _parentPhone = TextEditingController();
  final _parentEmail = TextEditingController();
  final _parentOccupation = TextEditingController();
  final _emergencyContact = TextEditingController();
  final _medicalInfo = TextEditingController();

  // Fee tab fields
  final _admissionFee = TextEditingController(text: '5000');
  final _feeAmount = TextEditingController();
  final _transportFee = TextEditingController(text: '3500');
  final _hostelFee = TextEditingController(text: '5000');
  String _feeFrequency = 'Monthly';
  String _feePaymentMethod = 'Cash';
  bool _includeTransportFee = false;
  bool _includeHostelFee = false;

  String _gender = 'Male';
  String _bloodGroup = 'A+';
  String _className = 'Class 10';
  String _section = 'A';
  bool _hasTransport = false;
  String _busRoute = 'Route 1';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);

    if (widget.isEdit && widget.studentId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final provider = context.read<StudentProvider>();
        final student = provider.getStudentById(widget.studentId!);
        if (student == null) return;
        setState(() {
          _name.text = student.name;
          _dob.text = student.dob;
          _phone.text = student.phone;
          _email.text = student.email;
          _address.text = student.address;
          _admissionNo.text = student.admissionNo;
          _rollNo.text = student.rollNo;
          _admissionDate.text = student.admissionDate;
          _fatherName.text = student.fatherName;
          _motherName.text = student.motherName;
          _parentPhone.text = student.parentPhone;
          _parentEmail.text = student.parentEmail;
          _parentOccupation.text = student.parentOccupation;
          _emergencyContact.text = student.emergencyContact;
          _medicalInfo.text = student.medicalInfo;
          _gender = student.gender.isEmpty ? 'Male' : student.gender;
          _bloodGroup = student.bloodGroup.isEmpty ? 'A+' : student.bloodGroup;
          _className = student.className.isEmpty ? 'Class 10' : student.className;
          _section = student.section.isEmpty ? 'A' : student.section;
          _hasTransport = student.transport == 'yes';
          _busRoute = student.busRoute.isEmpty ? 'Route 1' : student.busRoute;
        });
      });
    } else {
      _generateAdmissionNo();
    }
  }

  void _generateAdmissionNo() {
    final year = DateTime.now().year.toString().substring(2);
    final classCode = _className
        .replaceAll('Class ', 'C')
        .replaceAll('Nursery', 'NUR')
        .replaceAll('LKG', 'LKG')
        .replaceAll('UKG', 'UKG');
    final random = DateTime.now().millisecondsSinceEpoch % 10000;
    _admissionNo.text = 'ADM$year$classCode${random.toString().padLeft(4, '0')}';
  }

  @override
  void dispose() {
    _tabController.dispose();
    _name.dispose(); _dob.dispose(); _phone.dispose(); _email.dispose();
    _address.dispose(); _admissionNo.dispose(); _rollNo.dispose();
    _admissionDate.dispose(); _fatherName.dispose(); _motherName.dispose();
    _parentPhone.dispose(); _parentEmail.dispose(); _parentOccupation.dispose();
    _emergencyContact.dispose(); _medicalInfo.dispose();
    _admissionFee.dispose();
    _feeAmount.dispose();
    _transportFee.dispose(); _hostelFee.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    // Extra safety checks for required fields
    if (_name.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Student name is required!'),
          backgroundColor: Colors.red));
      _tabController.animateTo(0); // Personal tab pe le jao
      return;
    }
    if (_admissionNo.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Admission number is required!'),
          backgroundColor: Colors.red));
      _tabController.animateTo(1); // Admission tab pe le jao
      return;
    }
    setState(() => _saving = true);

    final student = StudentModel(
      id: widget.studentId ?? 0,
      admissionNo: _admissionNo.text,
      rollNo: _rollNo.text,
      name: _name.text,
      className: _className,
      section: _section,
      gender: _gender,
      dob: _dob.text,
      bloodGroup: _bloodGroup,
      phone: _phone.text,
      email: _email.text,
      address: _address.text,
      fatherName: _fatherName.text,
      motherName: _motherName.text,
      parentPhone: _parentPhone.text,
      parentEmail: _parentEmail.text,
      parentOccupation: _parentOccupation.text,
      emergencyContact: _emergencyContact.text,
      medicalInfo: _medicalInfo.text,
      transport: _hasTransport ? 'yes' : 'no',
      busRoute: _hasTransport ? _busRoute : '',
      admissionDate: _admissionDate.text,
      status: 'active',
    );

    bool ok;
    int? newStudentId = widget.studentId;
    if (widget.isEdit && widget.studentId != null) {
      ok = await context.read<StudentProvider>().updateStudent(widget.studentId!, student);
    } else {
      ok = await context.read<StudentProvider>().addStudent(student);
      // Naya student create hone ke baad uska ID list mein latest milega
      if (ok) {
        final list = context.read<StudentProvider>().students;
        final match = list.where((s) => s.admissionNo == _admissionNo.text);
        if (match.isNotEmpty) newStudentId = match.first.id;
      }
    }

    // Fee records create karo (sirf naye student ke liye, agar fee set ki ho)
    if (ok && !widget.isEdit && newStudentId != null) {
      try {
        if (_feeAmount.text.isNotEmpty && double.tryParse(_feeAmount.text) != null) {
          await apiService.post('/fees', {
            'student_id': newStudentId,
            'fee_type': 'Fee',
            'amount': double.parse(_feeAmount.text),
            'due_date': '',
            'payment_mode': _feePaymentMethod,
            'status': 'pending',
          });
        }
        if (_admissionFee.text.isNotEmpty && double.tryParse(_admissionFee.text) != null) {
          await apiService.post('/fees', {
            'student_id': newStudentId,
            'fee_type': 'Admission Fee',
            'amount': double.parse(_admissionFee.text),
            'due_date': _admissionDate.text.isNotEmpty ? _admissionDate.text : '',
            'payment_mode': _feePaymentMethod,
            'status': 'pending',
          });
        }

        if (_includeTransportFee && _transportFee.text.isNotEmpty) {
          await apiService.post('/fees', {
            'student_id': newStudentId,
            'fee_type': 'Transport Fee',
            'amount': double.parse(_transportFee.text),
            'due_date': '',
            'payment_mode': _feePaymentMethod,
            'status': 'pending',
          });
        }
        if (_includeHostelFee && _hostelFee.text.isNotEmpty) {
          await apiService.post('/fees', {
            'student_id': newStudentId,
            'fee_type': 'Hostel Fee',
            'amount': double.parse(_hostelFee.text),
            'due_date': '',
            'payment_mode': _feePaymentMethod,
            'status': 'pending',
          });
        }
      } catch (_) {
        // Fee creation fail ho jaye toh bhi student creation success rahega
      }
    }

    setState(() => _saving = false);
    if (mounted) {
      if (ok && !widget.isEdit) {
        _showSuccessScreen(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(ok ? 'Student updated successfully!' : 'Failed. Please try again.'),
          backgroundColor: ok ? Colors.green : Colors.red,
        ));
        if (ok) context.go('/students');
      }
      if (ok) context.go('/students');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEdit ? context.watch<LanguageProvider>().t('edit_student') : context.watch<LanguageProvider>().t('add_new_student')),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => context.go('/students'),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          isScrollable: true,
          tabs: [
            Tab(text: context.watch<LanguageProvider>().t('personal')),
            Tab(text: context.watch<LanguageProvider>().t('admission')),
            Tab(text: context.watch<LanguageProvider>().t('parent')),
            Tab(text: context.watch<LanguageProvider>().t('fee')),
            Tab(text: context.watch<LanguageProvider>().t('documents')),
          ],
        ),
      ),
      body: Form(
        key: _formKey,
        child: TabBarView(
          controller: _tabController,
          children: [
            _personalTab(),
            _admissionTab(),
            _parentTab(),
            _feeTab(),
            _documentsTab(),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : Text(widget.isEdit ? 'Update Student' : 'Add Student'),
          ),
        ),
      ),
    );
  }

  Widget _personalTab() => SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(children: [
        Center(
          child: Stack(children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
              child: const Icon(Icons.person, size: 50, color: AppTheme.primaryColor),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                decoration: const BoxDecoration(color: AppTheme.primaryColor, shape: BoxShape.circle),
                child: IconButton(
                  icon: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
                  onPressed: () {},
                ),
              ),
            ),
          ]),
        ),
        const SizedBox(height: 20),
        _field(_name, 'Full Name *', Icons.person, required: true),
        const SizedBox(height: 14),
        TextFormField(
          controller: _dob,
          readOnly: true,
          decoration: const InputDecoration(
            labelText: 'Date of Birth *',
            prefixIcon: Icon(Icons.calendar_today),
            hintText: 'DD/MM/YYYY',
          ),
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: DateTime(2010),
              firstDate: DateTime(1990),
              lastDate: DateTime.now(),
            );
            if (picked != null) {
              setState(() {
                _dob.text =
                    '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
              });
            }
          },
          validator: (v) => (v == null || v.isEmpty) ? 'Date of Birth required' : null,
        ),
        const SizedBox(height: 14),
        DropdownButtonFormField<String>(
          value: _gender,
          decoration: const InputDecoration(labelText: 'Gender *', prefixIcon: Icon(Icons.people)),
          items: ['Male', 'Female', 'Other']
              .map((g) => DropdownMenuItem(value: g, child: Text(g)))
              .toList(),
          onChanged: (v) => setState(() => _gender = v!),
        ),
        const SizedBox(height: 14),
        DropdownButtonFormField<String>(
          value: _bloodGroup,
          decoration: const InputDecoration(labelText: 'Blood Group', prefixIcon: Icon(Icons.bloodtype)),
          items: ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-']
              .map((b) => DropdownMenuItem(value: b, child: Text(b)))
              .toList(),
          onChanged: (v) => setState(() => _bloodGroup = v!),
        ),
        const SizedBox(height: 14),
        _field(_phone, 'Phone', Icons.phone, type: TextInputType.phone),
        const SizedBox(height: 14),
        _field(_email, 'Email', Icons.email, type: TextInputType.emailAddress),
        const SizedBox(height: 14),
        _field(_address, 'Address *', Icons.location_on, required: true, maxLines: 3),
        const SizedBox(height: 14),
        _field(_medicalInfo, 'Medical Info', Icons.medical_services,
            maxLines: 2, hint: 'Allergies, conditions...'),
        const SizedBox(height: 14),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('School Transport',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                    Switch(
                      value: _hasTransport,
                      onChanged: (v) => setState(() => _hasTransport = v),
                    ),
                  ],
                ),
                if (_hasTransport) ...[
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: _busRoute,
                    decoration: const InputDecoration(
                        labelText: 'Bus Route', prefixIcon: Icon(Icons.directions_bus)),
                    items: ['Route 1', 'Route 2', 'Route 3', 'Route 4', 'Route 5']
                        .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                        .toList(),
                    onChanged: (v) => setState(() => _busRoute = v!),
                  ),
                ],
              ],
            ),
          ),
        ),
      ]));

  Widget _admissionTab() => SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(children: [
        TextFormField(
          controller: _admissionNo,
          readOnly: true,
          decoration: InputDecoration(
            labelText: 'Admission Number (Auto Generated)',
            prefixIcon: const Icon(Icons.badge),
            filled: true,
            fillColor: Colors.grey.shade50,
            suffixIcon: IconButton(
              icon: const Icon(Icons.refresh, color: Colors.blue),
              onPressed: _generateAdmissionNo,
              tooltip: 'Regenerate',
            ),
          ),
        ),
        const SizedBox(height: 14),
        TextFormField(
          controller: _rollNo,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Roll Number',
            prefixIcon: Icon(Icons.numbers),
            hintText: 'Enter roll number',
          ),
        ),
        const SizedBox(height: 14),
        DropdownButtonFormField<String>(
          value: _className,
          decoration: const InputDecoration(
              labelText: 'Class *', prefixIcon: Icon(Icons.class_)),
          items: [
            'Nursery', 'LKG', 'UKG', 'Class 1', 'Class 2', 'Class 3',
            'Class 4', 'Class 5', 'Class 6', 'Class 7', 'Class 8',
            'Class 9', 'Class 10', 'Class 11', 'Class 12'
          ].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
          onChanged: (v) {
            setState(() => _className = v!);
            _generateAdmissionNo();
          },
          validator: (v) => v == null ? 'Class required' : null,
        ),
        const SizedBox(height: 14),
        DropdownButtonFormField<String>(
          value: _section,
          decoration: const InputDecoration(
              labelText: 'Section *', prefixIcon: Icon(Icons.segment)),
          items: ['A', 'B', 'C', 'D']
              .map((s) => DropdownMenuItem(value: s, child: Text(s)))
              .toList(),
          onChanged: (v) {
            setState(() => _section = v!);
            _generateAdmissionNo();
          },
          validator: (v) => v == null ? 'Section required' : null,
        ),
        const SizedBox(height: 14),
        TextFormField(
          controller: _admissionDate,
          readOnly: true,
          decoration: const InputDecoration(
            labelText: 'Admission Date *',
            prefixIcon: Icon(Icons.date_range),
          ),
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2030),
            );
            if (picked != null) {
              setState(() {
                _admissionDate.text =
                    '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
              });
            }
          },
          validator: (v) => (v == null || v.isEmpty) ? 'Admission Date required' : null,
        ),
      ]));

  Widget _parentTab() => SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(children: [
        _field(_fatherName, "Father's Name *", Icons.person, required: true),
        const SizedBox(height: 14),
        _field(_motherName, "Mother's Name", Icons.person),
        const SizedBox(height: 14),
        _field(_parentPhone, 'Parent Phone *', Icons.phone,
            required: true, type: TextInputType.phone),
        const SizedBox(height: 14),
        _field(_parentEmail, 'Parent Email', Icons.email,
            type: TextInputType.emailAddress),
        const SizedBox(height: 14),
        _field(_parentOccupation, 'Occupation', Icons.work),
        const SizedBox(height: 14),
        _field(_emergencyContact, 'Emergency Contact *', Icons.emergency,
            required: true, type: TextInputType.phone),
      ]));

  void _showSuccessScreen(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black87,
      transitionDuration: const Duration(milliseconds: 400),
      transitionBuilder: (ctx, anim, _, child) => ScaleTransition(
        scale: CurvedAnimation(parent: anim, curve: Curves.elasticOut),
        child: child),
      pageBuilder: (ctx, _, __) => Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 120, height: 120,
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.green.shade200, width: 3)),
                  child: const Icon(Icons.check_circle_rounded,
                    color: Colors.green, size: 80)),
                const SizedBox(height: 24),
                const Text('Student Added!',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold,
                    color: Colors.green)),
                const SizedBox(height: 8),
                Text('${_name.text} has been successfully enrolled.',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  textAlign: TextAlign.center),
                const SizedBox(height: 32),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200)),
                  child: Column(children: [
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                      const Text('Student Details',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.green.shade100,
                          borderRadius: BorderRadius.circular(20)),
                        child: const Text('ENROLLED',
                          style: TextStyle(color: Colors.green,
                            fontWeight: FontWeight.bold, fontSize: 11))),
                    ]),
                    const Divider(height: 20),
                    _successRow(Icons.person, 'Name', _name.text),
                    const SizedBox(height: 8),
                    _successRow(Icons.class_, 'Class',
                      '$_className-$_section'),
                    const SizedBox(height: 8),
                    _successRow(Icons.numbers, 'Admission No',
                      _admissionNo.text),
                    const SizedBox(height: 8),
                    _successRow(Icons.receipt, 'Initial Fee',
                      'Rs ${_calculateTotalFee().toStringAsFixed(0)}'),
                    const SizedBox(height: 8),
                    _successRow(Icons.payment, 'Payment Method',
                      _feePaymentMethod),
                  ]),
                ),
                const SizedBox(height: 32),
                Row(children: [
                  Expanded(child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      // Reset form
                      _name.clear(); _admissionNo.clear();
                      _tabController.animateTo(0);
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Add Another'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12))))),
                  const SizedBox(width: 12),
                  Expanded(child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      context.go('/students');
                    },
                    icon: const Icon(Icons.people),
                    label: const Text('View Students'),
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
    );
  }

  Widget _successRow(IconData icon, String label, String value) =>
    Row(children: [
      Icon(icon, size: 16, color: Colors.grey),
      const SizedBox(width: 8),
      SizedBox(width: 110, child: Text(label,
        style: const TextStyle(color: Colors.grey, fontSize: 13))),
      Expanded(child: Text(value,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        overflow: TextOverflow.ellipsis)),
    ]);

  Widget _feeTab() => SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.08),
            borderRadius: BorderRadius.circular(10)),
          child: Row(children: [
            const Icon(Icons.info_outline, color: AppTheme.primaryColor, size: 18),
            const SizedBox(width: 8),
            Expanded(child: Text(
              'Set initial fee structure — fee records will be created automatically when student is added.',
              style: TextStyle(fontSize: 12, color: AppTheme.primaryColor.withOpacity(0.9)))),
          ]),
        ),
        const SizedBox(height: 18),
        const Text('Mandatory Fees', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 10),
        _field(_feeAmount, 'Fee Amount (Rs.) *', Icons.currency_rupee,
          type: TextInputType.number),
        const SizedBox(height: 14),
        _field(_admissionFee, 'Admission Fee (Rs.)', Icons.school,
          type: TextInputType.number),
        const SizedBox(height: 14),

        DropdownButtonFormField<String>(
          value: _feeFrequency,
          decoration: InputDecoration(
            labelText: 'Fee Frequency',
            prefixIcon: const Icon(Icons.repeat),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
          items: ['Monthly', 'Quarterly', 'Half-Yearly', 'Annual']
            .map((f) => DropdownMenuItem(value: f, child: Text(f))).toList(),
          onChanged: (v) => setState(() => _feeFrequency = v!),
        ),
        const SizedBox(height: 14),
        DropdownButtonFormField<String>(
          value: _feePaymentMethod,
          decoration: InputDecoration(
            labelText: 'Payment Method',
            prefixIcon: const Icon(Icons.payment),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
          items: [
            const DropdownMenuItem(value: 'Cash',
              child: Row(children: [Icon(Icons.money, size: 18, color: Colors.green),
                SizedBox(width: 8), Text('Cash')])),
            const DropdownMenuItem(value: 'UPI',
              child: Row(children: [Icon(Icons.qr_code, size: 18, color: Colors.blue),
                SizedBox(width: 8), Text('UPI')])),
            const DropdownMenuItem(value: 'Online Transfer',
              child: Row(children: [Icon(Icons.account_balance, size: 18, color: Colors.purple),
                SizedBox(width: 8), Text('Online Transfer')])),
            const DropdownMenuItem(value: 'Cheque',
              child: Row(children: [Icon(Icons.receipt, size: 18, color: Colors.orange),
                SizedBox(width: 8), Text('Cheque')])),
          ],
          onChanged: (v) => setState(() => _feePaymentMethod = v!),
        ),
        const SizedBox(height: 22),
        const Text('Optional Fees', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 10),
        Card(
          child: Column(children: [
            SwitchListTile(
              value: _includeTransportFee,
              onChanged: (v) => setState(() => _includeTransportFee = v),
              title: const Text('Transport Fee', style: TextStyle(fontSize: 13)),
              subtitle: _includeTransportFee
                ? Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: _field(_transportFee, 'Amount (Rs.)', Icons.directions_bus,
                      type: TextInputType.number))
                : null,
              secondary: const Icon(Icons.directions_bus, color: Colors.blue),
            ),
            const Divider(height: 1),
            SwitchListTile(
              value: _includeHostelFee,
              onChanged: (v) => setState(() => _includeHostelFee = v),
              title: const Text('Hostel Fee', style: TextStyle(fontSize: 13)),
              subtitle: _includeHostelFee
                ? Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: _field(_hostelFee, 'Amount (Rs.)', Icons.bed,
                      type: TextInputType.number))
                : null,
              secondary: const Icon(Icons.bed, color: Colors.purple),
            ),
          ]),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.08),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.green.withOpacity(0.2))),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Total Initial Fee', style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 13, color: Colors.green)),
            const SizedBox(height: 6),
            Text('Rs ${_calculateTotalFee().toStringAsFixed(0)}',
              style: const TextStyle(fontWeight: FontWeight.bold,
                fontSize: 22, color: Colors.green)),
          ]),
        ),
      ]));

  double _calculateTotalFee() {
    double total = (double.tryParse(_feeAmount.text) ?? 0) + (double.tryParse(_admissionFee.text) ?? 0);
    if (_includeTransportFee) total += double.tryParse(_transportFee.text) ?? 0;
    if (_includeHostelFee) total += double.tryParse(_hostelFee.text) ?? 0;
    return total;
  }

  Widget _documentsTab() => SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(children: [
        const Text('Upload Documents',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        _docUpload('Birth Certificate', Icons.description),
        _docUpload('Aadhar Card', Icons.credit_card),
        _docUpload('Transfer Certificate', Icons.transfer_within_a_station),
        _docUpload('Previous Report Card', Icons.grade),
        _docUpload('Profile Photo', Icons.photo),
      ]));

  Widget _field(
    TextEditingController ctrl,
    String label,
    IconData icon, {
    bool required = false,
    String? hint,
    TextInputType type = TextInputType.text,
    int maxLines = 1,
  }) =>
      TextFormField(
        controller: ctrl,
        keyboardType: type,
        maxLines: maxLines,
        maxLength: type == TextInputType.phone ? 10 : null,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon),
          counterText: type == TextInputType.phone ? '' : null,
        ),
        validator: required
            ? (v) {
                if (v == null || v.isEmpty) return '$label is required';
                if (type == TextInputType.phone && v.length != 10)
                  return 'Enter valid 10 digit number';
                return null;
              }
            : (v) {
                if (type == TextInputType.phone &&
                    v != null &&
                    v.isNotEmpty &&
                    v.length != 10) {
                  return 'Enter valid 10 digit number';
                }
                return null;
              },
      );

  Widget _docUpload(String label, IconData icon) {
    final uploaded = _uploadedDocs[label];
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Icon(icon, color: uploaded != null ? Colors.green : AppTheme.primaryColor),
        title: Text(label, style: const TextStyle(fontSize: 13)),
        subtitle: Text(
          uploaded != null ? uploaded : 'Tap to upload (PDF, JPG, PNG)',
          style: TextStyle(
              fontSize: 11, color: uploaded != null ? Colors.green : Colors.grey),
          overflow: TextOverflow.ellipsis,
        ),
        trailing: uploaded != null
            ? Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 18),
                const SizedBox(width: 4),
                OutlinedButton(
                  onPressed: () => setState(() => _uploadedDocs.remove(label)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                  child: const Text('Remove', style: TextStyle(fontSize: 11)),
                ),
              ])
            : OutlinedButton.icon(
                onPressed: () async {
                  try {
                    final picker = ImagePicker();
                    final image = await picker.pickImage(source: ImageSource.gallery);
                    if (image != null) {
                      setState(() => _uploadedDocs[label] = image.name);
                    }
                  } catch (e) {
                    if (mounted)
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                      );
                  }
                },
                icon: const Icon(Icons.upload, size: 16),
                label: const Text('Upload', style: TextStyle(fontSize: 12)),
              ),
      ),
    );
  }
}