import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../core/theme/app_theme.dart';
import 'package:image_picker/image_picker.dart';
import '../../providers/staff_provider.dart';
import '../../providers/language_provider.dart';

class AddEditStaffScreen extends StatefulWidget {
  final bool isEdit;
  final int? staffId;
  const AddEditStaffScreen({super.key, required this.isEdit, this.staffId});
  @override
  State<AddEditStaffScreen> createState() => _AddEditStaffScreenState();
}

class _AddEditStaffScreenState extends State<AddEditStaffScreen>
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
  String _gender = 'Male';

  final _empId = TextEditingController();
  final _joiningDate = TextEditingController();
  final _qualification = TextEditingController();
  final _experience = TextEditingController();
  String _designation = 'Teacher';
  String _department = 'Science';
  String _role = 'teacher';

  final List<String> _designations = [
    'Principal', 'Vice Principal', 'Teacher', 'Senior Teacher',
    'Accountant', 'Clerk', 'Librarian', 'Receptionist', 'Driver', 'Peon'
  ];

  final List<String> _departments = [
    'Science', 'Mathematics', 'English', 'Hindi', 'Social Science',
    'Administration', 'Accounts', 'Library', 'Transport', 'Sports'
  ];

  final List<String> _roles = [
    'admin', 'principal', 'teacher', 'accountant',
    'receptionist', 'librarian', 'transport'
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    if (widget.isEdit && widget.staffId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final provider = context.read<StaffProvider>();
        final staff = provider.getStaffById(widget.staffId!);
        if (staff == null) return;
        setState(() {
          _name.text = staff.name;
          _dob.text = staff.dob;
          _phone.text = staff.phone;
          _email.text = staff.email;
          _address.text = staff.address;
          _empId.text = staff.employeeId;
          _joiningDate.text = staff.joiningDate;
          _qualification.text = staff.qualification;
          _experience.text = staff.experience;
          _gender = staff.gender.isEmpty ? 'Male' : staff.gender;
          final validDesignations = ['Principal', 'Vice Principal', 'Teacher', 'Senior Teacher', 'Accountant', 'Clerk', 'Librarian', 'Receptionist', 'Driver', 'Peon'];
          final validDepartments = ['Science', 'Mathematics', 'English', 'Hindi', 'Social Science', 'Administration', 'Accounts', 'Library', 'Transport', 'Sports'];
          final validRoles = ['admin', 'principal', 'teacher', 'accountant', 'receptionist', 'librarian', 'transport'];
          _designation = validDesignations.contains(staff.designation) ? staff.designation : 'Teacher';
          _department = validDepartments.contains(staff.department) ? staff.department : 'Science';
          _role = validRoles.contains(staff.role) ? staff.role : 'teacher';
        });
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _name.dispose(); _dob.dispose(); _phone.dispose();
    _email.dispose(); _address.dispose(); _empId.dispose();
    _joiningDate.dispose(); _qualification.dispose(); _experience.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final staff = StaffModel(
      id: widget.staffId ?? 0,
      employeeId: _empId.text,
      name: _name.text,
      designation: _designation,
      department: _department,
      phone: _phone.text,
      email: _email.text,
      gender: _gender,
      dob: _dob.text,
      joiningDate: _joiningDate.text,
      qualification: _qualification.text,
      experience: _experience.text,
      address: _address.text,
      role: _role.toLowerCase(),
      status: 'active',
    );

    bool ok;
    if (widget.isEdit && widget.staffId != null) {
      ok = await context.read<StaffProvider>().updateStaff(widget.staffId!, staff);
    } else {
      ok = await context.read<StaffProvider>().addStaff(staff);
    }

    setState(() => _saving = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(ok
            ? (widget.isEdit ? 'Staff updated successfully!' : 'Staff added successfully!')
            : 'Failed. Please try again.'),
        backgroundColor: ok ? Colors.green : Colors.red,
      ));
      if (ok) context.go('/staff/list');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => context.go((() {
            final role = context.read<AuthProvider>().user?.role;
            return role == 'staff'
                ? '/dashboard/staff'
                : role == 'student'
                    ? '/dashboard/student'
                    : role == 'parent'
                        ? '/dashboard/parent'
                        : '/dashboard/admin';
          })()),
        ),
        title: Text(widget.isEdit ? 'Edit Staff' : 'Add New Staff'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            Tab(text: context.watch<LanguageProvider>().t('personal')),
            Tab(text: 'Professional'),
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
            _professionalTab(),
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
                : Text(widget.isEdit ? 'Update Staff' : 'Add Staff'),
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
                decoration: const BoxDecoration(
                    color: AppTheme.primaryColor, shape: BoxShape.circle),
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
          ),
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: DateTime(1990),
              firstDate: DateTime(1950),
              lastDate: DateTime.now(),
            );
            if (picked != null) {
              setState(() => _dob.text =
                  '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}');
            }
          },
          validator: (v) => (v == null || v.isEmpty) ? 'Date of Birth required' : null,
        ),
        const SizedBox(height: 14),
        DropdownButtonFormField<String>(
          value: _gender,
          decoration: const InputDecoration(
              labelText: 'Gender *', prefixIcon: Icon(Icons.people)),
          items: ['Male', 'Female', 'Other']
              .map((g) => DropdownMenuItem(value: g, child: Text(g)))
              .toList(),
          onChanged: (v) => setState(() => _gender = v!),
        ),
        const SizedBox(height: 14),
        _field(_phone, 'Phone Number *', Icons.phone,
            required: true, type: TextInputType.phone),
        const SizedBox(height: 14),
        _field(_email, 'Email Address *', Icons.email,
            required: true, type: TextInputType.emailAddress),
        const SizedBox(height: 14),
        _field(_address, 'Address', Icons.location_on, maxLines: 3),
      ]));

  Widget _professionalTab() => SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(children: [
        TextFormField(
          controller: _empId,
          readOnly: true,
          decoration: InputDecoration(
            labelText: 'Employee ID (Auto Generated)',
            prefixIcon: const Icon(Icons.badge),
            hintText: 'Will be auto generated',
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
        ),
        const SizedBox(height: 14),
        TextFormField(
          controller: _joiningDate,
          readOnly: true,
          decoration: const InputDecoration(
            labelText: 'Joining Date *',
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
              setState(() => _joiningDate.text =
                  '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}');
            }
          },
          validator: (v) => (v == null || v.isEmpty) ? 'Joining Date required' : null,
        ),
        const SizedBox(height: 14),
        DropdownButtonFormField<String>(
          value: _designation,
          decoration: const InputDecoration(
              labelText: 'Designation *', prefixIcon: Icon(Icons.work)),
          items: _designations
              .map((d) => DropdownMenuItem(value: d, child: Text(d)))
              .toList(),
          onChanged: (v) => setState(() => _designation = v!),
        ),
        const SizedBox(height: 14),
        DropdownButtonFormField<String>(
          value: _department,
          decoration: const InputDecoration(
              labelText: 'Department *', prefixIcon: Icon(Icons.category)),
          items: _departments
              .map((d) => DropdownMenuItem(value: d, child: Text(d)))
              .toList(),
          onChanged: (v) => setState(() => _department = v!),
        ),
        const SizedBox(height: 14),
        DropdownButtonFormField<String>(
          value: _role,
          decoration: const InputDecoration(
              labelText: 'System Role *', prefixIcon: Icon(Icons.security)),
          items: _roles
              .map((r) => DropdownMenuItem(value: r, child: Text(r.toUpperCase())))
              .toList(),
          onChanged: (v) => setState(() => _role = v!),
        ),
        const SizedBox(height: 14),
        _field(_qualification, 'Qualification *', Icons.school, required: true),
        const SizedBox(height: 14),
        _field(_experience, 'Experience (years)', Icons.history),
      ]));

  Widget _documentsTab() => SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(children: [
        const Text('Upload Documents',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        const Text('Upload required documents for verification',
            style: TextStyle(color: Colors.grey, fontSize: 13)),
        const SizedBox(height: 20),
        _docUpload('Aadhaar Card', Icons.credit_card),
        _docUpload('PAN Card', Icons.credit_card),
        _docUpload('Educational Certificates', Icons.school),
        _docUpload('Experience Certificate', Icons.work),
        _docUpload('Appointment Letter', Icons.description),
        _docUpload('Profile Photo', Icons.photo),
        _docUpload('Other Documents', Icons.attach_file),
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
                  final picker = ImagePicker();
                  final image = await picker.pickImage(source: ImageSource.gallery);
                  if (image != null) {
                    setState(() => _uploadedDocs[label] = image.name);
                  }
                },
                icon: const Icon(Icons.upload, size: 16),
                label: const Text('Upload', style: TextStyle(fontSize: 12)),
              ),
      ),
    );
  }
}