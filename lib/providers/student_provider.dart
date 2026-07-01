import 'package:flutter/foundation.dart';
import '../services/api_service.dart';

enum LoadStatus { idle, loading, loaded, error }

// ?? Student Model ???????????
class StudentModel {
  final int id;
  final String admissionNo;
  final String rollNo;
  final String name;
  final String className;
  final String section;
  final String gender;
  final String dob;
  final String bloodGroup;
  final String phone;
  final String email;
  final String address;
  final String fatherName;
  final String motherName;
  final String parentPhone;
  final String parentEmail;
  final String parentOccupation;
  final String emergencyContact;
  final String medicalInfo;
  final String transport;
  final String busRoute;
  final String admissionDate;
  final String? photoUrl;
  final String status;

  StudentModel({
    required this.id,
    required this.admissionNo,
    required this.rollNo,
    required this.name,
    required this.className,
    required this.section,
    required this.gender,
    required this.dob,
    required this.bloodGroup,
    required this.phone,
    required this.email,
    required this.address,
    required this.fatherName,
    required this.motherName,
    required this.parentPhone,
    required this.parentEmail,
    required this.parentOccupation,
    required this.emergencyContact,
    required this.medicalInfo,
    required this.transport,
    required this.busRoute,
    required this.admissionDate,
    this.photoUrl,
    this.status = 'active',
  });
}

// ?? Fee Model ?????????
class StudentFeeModel {
  final int id;
  final String feeType;
  final double amount;
  final double paid;
  final String dueDate;
  final String status;

  StudentFeeModel({
    required this.id, required this.feeType, required this.amount,
    required this.paid, required this.dueDate, required this.status,
  });

  double get pending => amount - paid;
}

// ?? Attendance Model ????????
class StudentAttendanceModel {
  final String date;
  final String status;
  final String subject;

  StudentAttendanceModel({
    required this.date, required this.status, required this.subject,
  });
}

// ?? Student Provider ????????
class StudentProvider extends ChangeNotifier {
  List<StudentModel> _students = [];
  StudentModel? _selectedStudent;
  LoadStatus _status = LoadStatus.idle;
  String _searchQuery = '';
  String _filterClass = 'All'; // ? Default is 'All'
  String _filterStatus = 'All';
  String _sortBy = 'name';

  List<StudentModel> get students {
    var list = List<StudentModel>.from(_students);

    // ? FIXED: Compare with 'All' (not empty string '')
    if (_filterClass != 'All') {
      list = list.where((s) => s.className == _filterClass).toList();
    }

    if (_filterStatus != 'All') {
      list = list.where((s) => s.status == _filterStatus).toList();
    }

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list.where((s) =>
        s.name.toLowerCase().contains(q) ||
        s.admissionNo.toLowerCase().contains(q) ||
        s.rollNo.toLowerCase().contains(q) ||
        s.parentPhone.contains(q)).toList();
    }

    if (_sortBy == 'name') list.sort((a, b) => a.name.compareTo(b.name));
    if (_sortBy == 'roll') list.sort((a, b) => a.rollNo.compareTo(b.rollNo));
    return list;
  }

  StudentModel? get selectedStudent => _selectedStudent;
  LoadStatus get loadStatus => _status;
  bool get isLoading => _status == LoadStatus.loading;
  int get totalStudents => _students.length;
  int get activeStudents => _students.where((s) => s.status == 'active').length;

  Future<void> fetchStudents() async {
    _status = LoadStatus.loading;
    notifyListeners();
    try {
      final response = await apiService.get('/students');
      final data = response['data'] as List? ?? [];
      _students = data.map((j) => StudentModel(
        id: j['id'] ?? 0,
        admissionNo: j['admission_no'] ?? '',
        rollNo: j['roll_no'] ?? '',
        name: j['name'] ?? '',
        className: j['class_name'] ?? '',
        section: j['section'] ?? '',
        gender: j['gender'] ?? '',
        dob: j['dob'] ?? '',
        bloodGroup: j['blood_group'] ?? '',
        phone: j['phone'] ?? '',
        email: j['email'] ?? '',
        address: j['address'] ?? '',
        fatherName: j['father_name'] ?? '',
        motherName: j['mother_name'] ?? '',
        parentPhone: j['parent_phone'] ?? '',
        parentEmail: j['parent_email'] ?? '',
        parentOccupation: j['parent_occupation'] ?? '',
        emergencyContact: j['emergency_contact'] ?? '',
        medicalInfo: j['medical_info'] ?? '',
        transport: j['transport'] ?? '',
        busRoute: j['bus_route'] ?? '',
        admissionDate: j['admission_date'] ?? '',
        status: j['status'] ?? 'active',
      )).toList();
    } catch (e) {
      _students = [];
    }
    _status = LoadStatus.loaded;
    notifyListeners();
  }

  Future<bool> addStudent(StudentModel student) async {
    try {
      await apiService.post('/students', {
        'name': student.name,
        'roll_no': student.rollNo,
        'class_name': student.className,
        'section': student.section,
        'gender': student.gender,
        'dob': student.dob,
        'phone': student.phone,
        'email': student.email,
        'address': student.address,
        'father_name': student.fatherName,
        'mother_name': student.motherName,
        'parent_phone': student.parentPhone,
        'blood_group': student.bloodGroup,
        'admission_no': student.admissionNo,
        'admission_date': student.admissionDate,
        'transport': student.transport,
        'bus_route': student.busRoute,
        'status': student.status,
      });
      await fetchStudents();
      return true;
    } catch (e) {
      return false;
    }
  }
  Future<bool> updateStudent(int id, StudentModel student) async {
  try {
    await apiService.put('/students/$id', {
      'name': student.name,
      'roll_no': student.rollNo,
      'class_name': student.className,
      'section': student.section,
      'gender': student.gender,
      'dob': student.dob,
      'phone': student.phone,
      'email': student.email,
      'address': student.address,
      'father_name': student.fatherName,
      'mother_name': student.motherName,
      'parent_phone': student.parentPhone,
      'blood_group': student.bloodGroup,
      'admission_no': student.admissionNo,
      'admission_date': student.admissionDate,
      'transport': student.transport,
      'bus_route': student.busRoute,
      'status': student.status,
    });
    await fetchStudents();
    return true;
  } catch (e) {
    return false;
  }
}

StudentModel? getStudentById(int id) {
  try {
    return _students.firstWhere((s) => s.id == id);
  } catch (e) {
    return null;
  }
}

  Future<bool> deleteStudent(int id) async {
    try {
      await apiService.delete('/students/$id');
      _students.removeWhere((s) => s.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _students.removeWhere((s) => s.id == id);
      notifyListeners();
      return true;
    }
  }

  void selectStudent(int id) {
    _selectedStudent = _students.firstWhere((s) => s.id == id,
      orElse: () => _students.first);
    notifyListeners();
  }

  void setSearchQuery(String q) { _searchQuery = q; notifyListeners(); }

  // ? FIXED: Accept 'All' directly from UI chip
  void setClassFilter(String c) { _filterClass = c; notifyListeners(); }

  void setStatusFilter(String s) { _filterStatus = s; notifyListeners(); }
  void setSortBy(String s) { _sortBy = s; notifyListeners(); }
}

