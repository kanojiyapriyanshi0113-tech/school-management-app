import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../services/api_service.dart';

class HostelAdmissionForm extends StatefulWidget {
  const HostelAdmissionForm({super.key});
  @override
  State<HostelAdmissionForm> createState() => _HostelAdmissionFormState();
}

class _HostelAdmissionFormState extends State<HostelAdmissionForm>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  bool _saving = false;

  // Student
  List<Map<String, dynamic>> _studentList = [];
  int? _selectedStudentId;
  bool _loadingStudents = true;
  final _studentName = TextEditingController();
  final _admissionNo = TextEditingController();
  final _className = TextEditingController();
  final _section = TextEditingController();
  final _dob = TextEditingController();
  String _selectedGender = 'Male';
  String _bloodGroup = 'B+';

  // Parent
  final _fatherName = TextEditingController();
  final _motherName = TextEditingController();
  final _parentPhone = TextEditingController();
  final _parentEmail = TextEditingController();
  final _parentAddress = TextEditingController();
  final _emergencyContact = TextEditingController();
  final _emergencyName = TextEditingController();

  // Hostel
  List<Map<String, dynamic>> _hostelList = [];
  List<Map<String, dynamic>> _roomList = [];
  int? _selectedHostelId;
  int? _selectedRoomId;
  String _selectedHostelName = '';
  String _selectedRoomName = '';
  String _selectedBed = 'B1';
  final _joiningDate = TextEditingController();
  final _leavingDate = TextEditingController();
  String _mealPlan = 'Full Board';
  bool _hasAC = false;
  bool _hasAttachedBath = false;
  bool _loadingHostels = true;

  // Medical
  final _medicalCondition = TextEditingController();
  final _allergies = TextEditingController();
  final _doctorName = TextEditingController();
  final _doctorPhone = TextEditingController();
  String _bloodGroupMed = 'B+';

  // Fee
  String _feeType = 'Monthly';
  final _feeAmount = TextEditingController();
  String _paymentMode = 'Cash';
  final _advanceAmount = TextEditingController();

  final _beds = ['B1', 'B2', 'B3', 'B4'];
  final _bloodGroups = ['A+','A-','B+','B-','O+','O-','AB+','AB-'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _feeAmount.text = '5000';
    _loadStudents();
    _loadHostelData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _studentName.dispose(); _admissionNo.dispose(); _className.dispose();
    _section.dispose(); _dob.dispose(); _fatherName.dispose();
    _motherName.dispose(); _parentPhone.dispose(); _parentEmail.dispose();
    _parentAddress.dispose(); _emergencyContact.dispose(); _emergencyName.dispose();
    _joiningDate.dispose(); _leavingDate.dispose(); _medicalCondition.dispose();
    _allergies.dispose(); _doctorName.dispose(); _doctorPhone.dispose();
    _feeAmount.dispose(); _advanceAmount.dispose();
    super.dispose();
  }

  Future<void> _loadStudents() async {
    try {
      final res = await apiService.get('/students');
      setState(() {
        _studentList = List<Map<String, dynamic>>.from(res['data'] ?? []);
        _loadingStudents = false;
      });
    } catch (e) {
      setState(() => _loadingStudents = false);
    }
  }

  Future<void> _loadHostelData() async {
    try {
      final hRes = await apiService.get('/hostel');
      final data = List<Map<String, dynamic>>.from(hRes['data'] ?? []);
      setState(() {
        _hostelList = data;
        _loadingHostels = false;
        if (_hostelList.isNotEmpty) {
          _selectedHostelId = _hostelList[0]['id'];
          _selectedHostelName = _hostelList[0]['name'];
        }
      });
      await _loadRooms();
    } catch (e) {
      setState(() => _loadingHostels = false);
    }
  }

  Future<void> _loadRooms() async {
    if (_selectedHostelId == null) return;
    try {
      final rRes = await apiService.get('/hostel/rooms');
      final all = List<Map<String, dynamic>>.from(rRes['data'] ?? []);
      setState(() {
        _roomList = all.where((r) => r['hostel_id'] == _selectedHostelId).toList();
        if (_roomList.isNotEmpty) {
          _selectedRoomId = _roomList[0]['id'];
          _selectedRoomName = 'Room ${_roomList[0]['room_number']}';
        } else {
          _selectedRoomId = null;
          _selectedRoomName = '';
        }
      });
    } catch (e) {}
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields'),
          backgroundColor: Colors.red));
      return;
    }
    if (_selectedStudentId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a student'),
          backgroundColor: Colors.red));
      return;
    }
    setState(() => _saving = true);
    try {
      await apiService.post('/hostel/allocate', {
        'student_id': _selectedStudentId,
        'hostel_id': _selectedHostelId ?? 1,
        'room_id': _selectedRoomId ?? 1,
        'bed_number': _selectedBed,
        'joining_date': _joiningDate.text,
        'expected_leaving': _leavingDate.text,
        'monthly_fee': double.tryParse(_feeAmount.text) ?? 5000,
        'deposit': double.tryParse(_advanceAmount.text) ?? 0,
        'status': 'active',
        'fee_status': 'pending',
      });
      setState(() => _saving = false);
      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Row(children: [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 8),
              Text('Admission Successful!'),
            ]),
            content: SingleChildScrollView(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.green.withOpacity(0.3))),
                  child: Column(children: [
                    _confirmRow('Student', _studentName.text),
                    _confirmRow('Admission No', _admissionNo.text),
                    _confirmRow('Hostel', _selectedHostelName),
                    _confirmRow('Room', _selectedRoomName),
                    _confirmRow('Bed', _selectedBed),
                    _confirmRow('Joining', _joiningDate.text),
                    _confirmRow('Monthly Fee', 'Rs ${_feeAmount.text}'),
                  ]),
                ),
              ]),
            ),
            actions: [
              ElevatedButton.icon(
                onPressed: () { Navigator.pop(ctx); context.go('/hostel'); },
                icon: const Icon(Icons.check),
                label: const Text('Done'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      setState(() => _saving = false);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed: $e'), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hostel Admission Form'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => context.go('/hostel')),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabAlignment: TabAlignment.start,
          tabs: const [
            Tab(icon: Icon(Icons.person, size: 16), text: 'Student'),
            Tab(icon: Icon(Icons.family_restroom, size: 16), text: 'Parent'),
            Tab(icon: Icon(Icons.hotel, size: 16), text: 'Hostel'),
            Tab(icon: Icon(Icons.medical_services, size: 16), text: 'Medical'),
            Tab(icon: Icon(Icons.payment, size: 16), text: 'Fee'),
          ],
        ),
      ),
      body: Form(
        key: _formKey,
        child: Column(children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(children: List.generate(5, (i) => Expanded(child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: AnimatedBuilder(
                animation: _tabController,
                builder: (_, __) => LinearProgressIndicator(
                  value: _tabController.index >= i ? 1.0 : 0.0,
                  color: AppTheme.primaryColor,
                  backgroundColor: Colors.grey.shade200,
                  minHeight: 4,
                ),
              ),
            )))),
          ),
          Expanded(child: TabBarView(
            controller: _tabController,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _studentTab(),
              _parentTab(),
              _hostelTab(),
              _medicalTab(),
              _feeTab(),
            ],
          )),
          SafeArea(
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.all(14),
              child: Row(children: [
                AnimatedBuilder(
                  animation: _tabController,
                  builder: (_, __) => _tabController.index > 0
                    ? Expanded(child: OutlinedButton.icon(
                        onPressed: () => _tabController.animateTo(_tabController.index - 1),
                        icon: const Icon(Icons.arrow_back, size: 16),
                        label: const Text('Previous'),
                      ))
                    : const SizedBox.shrink(),
                ),
                const SizedBox(width: 10),
                Expanded(child: AnimatedBuilder(
                  animation: _tabController,
                  builder: (_, __) => _tabController.index < 4
                    ? ElevatedButton.icon(
                        onPressed: () => _tabController.animateTo(_tabController.index + 1),
                        icon: const Icon(Icons.arrow_forward, size: 16),
                        label: const Text('Next'),
                      )
                    : ElevatedButton.icon(
                        onPressed: _saving ? null : _submit,
                        icon: _saving
                          ? const SizedBox(width: 16, height: 16,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Icon(Icons.how_to_reg, size: 16),
                        label: Text(_saving ? 'Submitting...' : 'Submit Admission'),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                      ),
                )),
              ]),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _studentTab() => SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _sectionHeader('Select Student', Icons.person_search),
      const SizedBox(height: 12),
      _loadingStudents
        ? const Center(child: CircularProgressIndicator())
        : _studentList.isEmpty
          ? Column(children: [
              const Text('No students found. Add students first.',
                style: TextStyle(color: Colors.orange)),
              const SizedBox(height: 12),
              _f(_studentName, 'Or enter name manually *', Icons.person, req: true),
            ])
          : DropdownButtonFormField<int>(
              value: _selectedStudentId,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Select Student *',
                prefixIcon: Icon(Icons.person)),
              hint: const Text('Choose a student'),
              items: _studentList.map((s) => DropdownMenuItem<int>(
                value: s['id'] as int,
                child: Text(
        '${s['name']} - ${s['class_name'] ?? ''} ${s['section'] ?? ''}',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13)))).toList(),
              onChanged: (v) => setState(() {
                _selectedStudentId = v;
                final s = _studentList.firstWhere((st) => st['id'] == v);
                _studentName.text = s['name'] ?? '';
                _admissionNo.text = s['admission_no'] ?? '';
                _className.text = s['class_name'] ?? '';
                _section.text = s['section'] ?? '';
              }),
              validator: (v) => v == null ? 'Please select a student' : null,
            ),
      const SizedBox(height: 16),
      _sectionHeader('Student Details', Icons.person),
      const SizedBox(height: 12),
      _f(_studentName, 'Full Name', Icons.person),
      const SizedBox(height: 12),
      _f(_admissionNo, 'Admission Number', Icons.badge),
      const SizedBox(height: 12),
      Row(children: [
        Expanded(child: _f(_className, 'Class', Icons.class_)),
        const SizedBox(width: 12),
        Expanded(child: _f(_section, 'Section', Icons.segment)),
      ]),
      const SizedBox(height: 12),
      TextFormField(
        controller: _dob, readOnly: true,
        decoration: const InputDecoration(
          labelText: 'Date of Birth', prefixIcon: Icon(Icons.cake)),
        onTap: () async {
          final d = await showDatePicker(context: context,
            initialDate: DateTime(2010),
            firstDate: DateTime(1990),
            lastDate: DateTime.now());
          if (d != null) setState(() => _dob.text =
        '${d.day.toString().padLeft(2,'0')}/${d.month.toString().padLeft(2,'0')}/${d.year}');
        },
      ),
      const SizedBox(height: 12),
      DropdownButtonFormField<String>(
        value: _selectedGender,
        decoration: const InputDecoration(
          labelText: 'Gender', prefixIcon: Icon(Icons.people)),
        items: ['Male','Female','Other']
          .map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
        onChanged: (v) => setState(() => _selectedGender = v!),
      ),
      const SizedBox(height: 12),
      DropdownButtonFormField<String>(
        value: _bloodGroup,
        decoration: const InputDecoration(
          labelText: 'Blood Group', prefixIcon: Icon(Icons.bloodtype)),
        items: _bloodGroups
          .map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
        onChanged: (v) => setState(() => _bloodGroup = v!),
      ),
      const SizedBox(height: 16),
      _infoCard('Select student from dropdown to auto-fill details.'),
    ]),
  );

  Widget _parentTab() => SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _sectionHeader('Parent / Guardian Information', Icons.family_restroom),
      const SizedBox(height: 12),
      _f(_fatherName, "Father's Name *", Icons.person, req: true),
      const SizedBox(height: 12),
      _f(_motherName, "Mother's Name", Icons.person),
      const SizedBox(height: 12),
      _f(_parentPhone, 'Parent Phone *', Icons.phone,
        req: true, type: TextInputType.phone, maxLen: 10),
      const SizedBox(height: 12),
      _f(_parentEmail, 'Parent Email', Icons.email,
        type: TextInputType.emailAddress),
      const SizedBox(height: 12),
      _f(_parentAddress, 'Home Address *', Icons.location_on,
        req: true, lines: 3),
      const SizedBox(height: 20),
      _sectionHeader('Emergency Contact', Icons.emergency),
      const SizedBox(height: 12),
      _f(_emergencyName, 'Emergency Contact Name *', Icons.person_pin, req: true),
      const SizedBox(height: 12),
      _f(_emergencyContact, 'Emergency Phone *', Icons.phone,
        req: true, type: TextInputType.phone, maxLen: 10),
      const SizedBox(height: 12),
      _infoCard('Emergency contact will be notified in case of any emergency.'),
    ]),
  );

  Widget _hostelTab() => SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _sectionHeader('Hostel Allocation', Icons.hotel),
      const SizedBox(height: 12),
      _loadingHostels
        ? const Center(child: CircularProgressIndicator())
        : _hostelList.isEmpty
          ? const Text('No hostels available.',
              style: TextStyle(color: Colors.red))
          : DropdownButtonFormField<int>(
              value: _selectedHostelId,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Select Hostel *',
                prefixIcon: Icon(Icons.apartment)),
              items: _hostelList.map((h) => DropdownMenuItem<int>(
                value: h['id'] as int,
                child: Text(
        '${h['name']} (${(h['type'] as String).toUpperCase()})',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13)))).toList(),
              onChanged: (v) async {
                setState(() {
                  _selectedHostelId = v;
                  _selectedHostelName = _hostelList
                    .firstWhere((h) => h['id'] == v)['name'] as String;
                  _selectedRoomId = null;
                  _roomList = [];
                });
                await _loadRooms();
              },
              validator: (v) => v == null ? 'Required' : null,
            ),
      const SizedBox(height: 12),
      Row(children: [
        Expanded(child: _roomList.isEmpty
          ? Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8)),
              child: const Text('No rooms available',
                style: TextStyle(color: Colors.grey, fontSize: 13)))
          : DropdownButtonFormField<int>(
              value: _selectedRoomId,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Select Room *',
                prefixIcon: Icon(Icons.door_front_door)),
              items: _roomList.map((r) => DropdownMenuItem<int>(
                value: r['id'] as int,
                child: Text(
        'Room ${r['room_number']} • ${r['room_type']} • ${r['status']}',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12)))).toList(),
              onChanged: (v) => setState(() {
                _selectedRoomId = v;
                final room = _roomList.firstWhere((r) => r['id'] == v);
                _selectedRoomName = 'Room ${room['room_number']}';
                _feeAmount.text = room['monthly_rent'].toString().replaceAll('.0', '');
              }),
            )),
        const SizedBox(width: 12),
        SizedBox(width: 100, child: DropdownButtonFormField<String>(
          value: _selectedBed,
          decoration: const InputDecoration(labelText: 'Bed *'),
          items: _beds.map((b) =>
            DropdownMenuItem(value: b, child: Text(b))).toList(),
          onChanged: (v) => setState(() => _selectedBed = v!),
        )),
      ]),
      const SizedBox(height: 12),
      TextFormField(
        controller: _joiningDate, readOnly: true,
        decoration: const InputDecoration(
          labelText: 'Joining Date *',
          prefixIcon: Icon(Icons.calendar_today)),
        onTap: () async {
          final d = await showDatePicker(context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(2020),
            lastDate: DateTime(2030));
          if (d != null) setState(() => _joiningDate.text =
        '${d.day.toString().padLeft(2,'0')}/${d.month.toString().padLeft(2,'0')}/${d.year}');
        },
        validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
      ),
      const SizedBox(height: 12),
      TextFormField(
        controller: _leavingDate, readOnly: true,
        decoration: const InputDecoration(
          labelText: 'Expected Leaving Date',
          prefixIcon: Icon(Icons.calendar_today)),
        onTap: () async {
          final d = await showDatePicker(context: context,
            initialDate: DateTime.now().add(const Duration(days: 365)),
            firstDate: DateTime.now(),
            lastDate: DateTime(2030));
          if (d != null) setState(() => _leavingDate.text =
        '${d.day.toString().padLeft(2,'0')}/${d.month.toString().padLeft(2,'0')}/${d.year}');
        },
      ),
      const SizedBox(height: 12),
      DropdownButtonFormField<String>(
        value: _mealPlan,
        isExpanded: true,
        decoration: const InputDecoration(
          labelText: 'Meal Plan',
          prefixIcon: Icon(Icons.restaurant)),
        items: ['Full Board','Half Board','Breakfast Only','No Meals']
          .map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
        onChanged: (v) => setState(() => _mealPlan = v!),
      ),
      const SizedBox(height: 16),
      _sectionHeader('Room Facilities', Icons.settings),
      const SizedBox(height: 8),
      Card(child: Column(children: [
        SwitchListTile(
          title: const Text('Air Conditioned (AC)',
            style: TextStyle(fontSize: 13)),
          subtitle: const Text('Extra Rs 2000/month',
            style: TextStyle(fontSize: 11)),
          value: _hasAC,
          onChanged: (v) => setState(() => _hasAC = v),
        ),
        SwitchListTile(
          title: const Text('Attached Bathroom',
            style: TextStyle(fontSize: 13)),
          subtitle: const Text('Extra Rs 500/month',
            style: TextStyle(fontSize: 11)),
          value: _hasAttachedBath,
          onChanged: (v) => setState(() => _hasAttachedBath = v),
        ),
      ])),
    ]),
  );

  Widget _medicalTab() => SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _sectionHeader('Medical Information', Icons.medical_services),
      const SizedBox(height: 12),
      DropdownButtonFormField<String>(
        value: _bloodGroupMed,
        decoration: const InputDecoration(
          labelText: 'Blood Group *',
          prefixIcon: Icon(Icons.bloodtype)),
        items: _bloodGroups
          .map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
        onChanged: (v) => setState(() => _bloodGroupMed = v!),
      ),
      const SizedBox(height: 12),
      _f(_medicalCondition, 'Medical Conditions', Icons.healing, lines: 2,
        hint: 'Diabetes, Asthma, Heart condition, etc.'),
      const SizedBox(height: 12),
      _f(_allergies, 'Allergies', Icons.warning_amber, lines: 2,
        hint: 'Food, medicine, or other allergies'),
      const SizedBox(height: 20),
      _sectionHeader('Doctor Information', Icons.local_hospital),
      const SizedBox(height: 12),
      _f(_doctorName, 'Family Doctor Name', Icons.person),
      const SizedBox(height: 12),
      _f(_doctorPhone, 'Doctor Phone', Icons.phone,
        type: TextInputType.phone, maxLen: 10),
      const SizedBox(height: 12),
      _infoCard('Medical information is confidential and used only in emergencies.'),
    ]),
  );

  Widget _feeTab() => SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _sectionHeader('Fee Structure', Icons.payments),
      const SizedBox(height: 12),
      DropdownButtonFormField<String>(
        value: _feeType,
        decoration: const InputDecoration(
          labelText: 'Fee Type *',
          prefixIcon: Icon(Icons.receipt)),
        items: ['Monthly','Quarterly','Half Yearly','Annual']
          .map((f) => DropdownMenuItem(value: f, child: Text(f))).toList(),
        onChanged: (v) => setState(() => _feeType = v!),
      ),
      const SizedBox(height: 12),
      TextFormField(
        controller: _feeAmount,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          labelText: 'Fee Amount (Rs.) *',
          prefixIcon: Icon(Icons.currency_rupee)),
        validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
        onChanged: (_) => setState(() {}),
      ),
      const SizedBox(height: 12),
      DropdownButtonFormField<String>(
        value: _paymentMode,
        decoration: const InputDecoration(
          labelText: 'Payment Mode',
          prefixIcon: Icon(Icons.payment)),
        items: ['Cash','Online Transfer','Cheque','DD']
          .map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
        onChanged: (v) => setState(() => _paymentMode = v!),
      ),
      const SizedBox(height: 12),
      TextFormField(
        controller: _advanceAmount,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          labelText: 'Security Deposit (Rs.)',
          prefixIcon: Icon(Icons.currency_rupee),
          hintText: 'Refundable security deposit'),
      ),
      const SizedBox(height: 16),
      Card(
        color: Colors.blue.withOpacity(0.05),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Fee Summary',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const Divider(),
            _feeRow('Hostel Rent', 'Rs ${_feeAmount.text}/month'),
            _feeRow('Meal Plan', _mealPlan),
            _feeRow('AC Charges',
              _hasAC ? 'Rs 2000/month' : 'Not applicable'),
            _feeRow('Attached Bath',
              _hasAttachedBath ? 'Rs 500/month' : 'Not applicable'),
            _feeRow('Security Deposit',
              _advanceAmount.text.isEmpty ? 'Rs 0' : 'Rs ${_advanceAmount.text}'),
            const Divider(),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text('Total Monthly Fee',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              Text('Rs ${_calculateTotal()}',
                style: const TextStyle(fontWeight: FontWeight.bold,
                  fontSize: 16, color: Colors.green)),
            ]),
          ]),
        ),
      ),
      const SizedBox(height: 12),
      Card(
        color: Colors.orange.withOpacity(0.05),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Terms & Conditions',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 8),
            ...[
        'Fee is due by 10th of every month',
        'Late payment attracts Rs 100/day penalty',
        'One month notice required before vacating',
        'Security deposit refunded after room inspection',
        'Visitors allowed only in designated areas',
            ].map((t) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(children: [
                const Icon(Icons.check_circle_outline,
                  size: 14, color: Colors.orange),
                const SizedBox(width: 6),
                Expanded(child: Text(t,
                  style: const TextStyle(fontSize: 11))),
              ]),
            )),
          ]),
        ),
      ),
    ]),
  );

  String _calculateTotal() {
    int base = int.tryParse(_feeAmount.text) ?? 5000;
    if (_hasAC) base += 2000;
    if (_hasAttachedBath) base += 500;
    return base.toString();
  }

  Widget _sectionHeader(String title, IconData icon) => Row(children: [
    Container(width: 4, height: 20,
      decoration: BoxDecoration(
        color: AppTheme.primaryColor,
        borderRadius: BorderRadius.circular(2))),
    const SizedBox(width: 8),
    Icon(icon, color: AppTheme.primaryColor, size: 18),
    const SizedBox(width: 6),
    Expanded(child: Text(title,
      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
      overflow: TextOverflow.ellipsis)),
  ]);

  Widget _infoCard(String text) => Container(
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: Colors.blue.withOpacity(0.05),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: Colors.blue.withOpacity(0.2))),
    child: Row(children: [
      const Icon(Icons.info_outline, color: Colors.blue, size: 16),
      const SizedBox(width: 8),
      Expanded(child: Text(text,
        style: const TextStyle(fontSize: 11, color: Colors.blue))),
    ]),
  );

  Widget _feeRow(String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
    ]));

  Widget _confirmRow(String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Row(children: [
      SizedBox(width: 100,
        child: Text(label,
          style: const TextStyle(fontSize: 12, color: Colors.grey))),
      Expanded(child: Text(value,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        overflow: TextOverflow.ellipsis)),
    ]));

  Widget _f(TextEditingController c, String label, IconData icon, {
    bool req = false, String? hint,
    TextInputType type = TextInputType.text,
    int lines = 1, int? maxLen,
  }) => TextFormField(
    controller: c, keyboardType: type, maxLines: lines, maxLength: maxLen,
    decoration: InputDecoration(
      labelText: label, hintText: hint, prefixIcon: Icon(icon),
      counterText: maxLen != null ? '' : null),
    validator: req
      ? (v) => (v == null || v.isEmpty) ? '$label required' : null
      : null,
  );
}