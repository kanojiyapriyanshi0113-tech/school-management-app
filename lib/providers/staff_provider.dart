import 'package:flutter/foundation.dart';
import '../services/api_service.dart';

// ?? Staff Model ??????
class StaffModel {
  final int id;
  final String employeeId;
  final String name;
  final String designation;
  final String department;
  final String phone;
  final String email;
  final String gender;
  final String dob;
  final String joiningDate;
  final String qualification;
  final String experience;
  final String address;
  final String role;
  final String status;

  StaffModel({
    required this.id,
    required this.employeeId,
    required this.name,
    required this.designation,
    required this.department,
    required this.phone,
    required this.email,
    required this.gender,
    required this.dob,
    required this.joiningDate,
    required this.qualification,
    required this.experience,
    required this.address,
    required this.role,
    required this.status,
  });
}

// ?? Leave Model ??????
class LeaveModel {
  final int id;
  final int staffId;
  final String staffName;
  final String leaveType;
  final String fromDate;
  final String toDate;
  final String reason;
  final String status;
  final int days;

  LeaveModel({
    required this.id, required this.staffId, required this.staffName,
    required this.leaveType, required this.fromDate, required this.toDate,
    required this.reason, required this.status, required this.days,
  });
}

// ?? Salary Model ???????????
class SalaryModel {
  final int id;
  final int staffId;
  final String staffName;
  final String month;
  final double basic;
  final double hra;
  final double allowances;
  final double deductions;
  final double net;
  final String status;

  double get basicSalary => basic;
  double get ta => allowances;
  double get grossSalary => basic + hra + allowances;
  double get totalDeduction => deductions;
  double get netSalary => net;

  SalaryModel({
    required this.id, required this.staffId, required this.staffName,
    required this.month, required this.basic, required this.hra,
    required this.allowances, required this.deductions,
    required this.net, required this.status,
  });
}

// ?? Staff Provider ??????????
class StaffProvider extends ChangeNotifier {
  List<StaffModel> _staffList = [];
  List<LeaveModel> _leaves = [];
  List<SalaryModel> _salaries = [];
  bool _isLoading = false;
  String _searchQuery = '';
  String _filterDept = 'All';

  List<StaffModel> get staffList {
    var list = List<StaffModel>.from(_staffList);
    if (_filterDept != 'All') {
      list = list.where((s) => s.department == _filterDept).toList();
    }
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list.where((s) =>
        s.name.toLowerCase().contains(q) ||
        s.employeeId.toLowerCase().contains(q) ||
        s.designation.toLowerCase().contains(q)).toList();
    }
    return list;
  }

  List<LeaveModel> get leaves => _leaves;
  List<LeaveModel> get pendingLeaves => _leaves.where((l) => l.status == 'pending').toList();
  List<SalaryModel> get salaries => _salaries;
  bool get isLoading => _isLoading;
  int get totalStaff => _staffList.length;
  int get activeStaff => _staffList.where((s) => s.status == 'active').length;
int get presentToday => (_staffList.length * 0.9).toInt();
int get absentToday => (_staffList.length * 0.1).toInt();
int get newJoinings => 2;

  Future<void> fetchStaff() async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await apiService.get('/staff');
      final data = response['data'] as List? ?? [];
      _staffList = data.map((j) => StaffModel(
        id: j['id'] ?? 0,
        employeeId: j['employee_id'] ?? '',
        name: j['name'] ?? '',
        designation: j['designation'] ?? '',
        department: j['department'] ?? '',
        phone: j['phone'] ?? '',
        email: j['email'] ?? '',
        gender: j['gender'] ?? '',
        dob: j['dob'] ?? '',
        joiningDate: j['joining_date'] ?? '',
        qualification: j['qualification'] ?? '',
        experience: j['experience'] ?? '',
        address: j['address'] ?? '',
        role: j['role'] ?? 'staff',
        status: j['status'] ?? 'active',
      )).toList();
    } catch (e) {
      _staffList = [];
    }

    // Demo leaves
    _leaves = [
      LeaveModel(id: 1, staffId: 1, staffName: 'Priya Sharma', leaveType: 'Sick Leave',
        fromDate: '18 Jun 2025', toDate: '19 Jun 2025', reason: 'Fever',
        status: 'pending', days: 2),
      LeaveModel(id: 2, staffId: 2, staffName: 'Amit Verma', leaveType: 'Casual Leave',
        fromDate: '22 Jun 2025', toDate: '22 Jun 2025', reason: 'Personal work',
        status: 'approved', days: 1),
    ];

    // Demo salaries
    _salaries = [
      SalaryModel(id: 1, staffId: 1, staffName: 'Dr. Rajesh Kumar', month: 'June 2025',
        basic: 70000, hra: 14000, allowances: 8000, deductions: 7400, net: 84600, status: 'paid'),
      SalaryModel(id: 2, staffId: 2, staffName: 'Priya Sharma', month: 'June 2025',
        basic: 45000, hra: 9000, allowances: 5000, deductions: 4750, net: 54250, status: 'pending'),
    ];

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> addStaff(StaffModel staff) async {
    try {
      await apiService.post('/staff', {
        'name': staff.name,
        'employee_id': staff.employeeId,
        'designation': staff.designation,
        'department': staff.department,
        'phone': staff.phone,
        'email': staff.email,
        'gender': staff.gender,
        'dob': staff.dob,
        'joining_date': staff.joiningDate,
        'qualification': staff.qualification,
        'experience': staff.experience,
        'address': staff.address,
        'role': staff.role,
        'status': staff.status,
      });
      await fetchStaff();
      return true;
    } catch (e) {
      return false;
    }
  }
  Future<bool> updateStaff(int id, StaffModel staff) async {
  try {
    await apiService.put('/staff/$id', {
      'name': staff.name,
      'designation': staff.designation,
      'department': staff.department,
      'phone': staff.phone,
      'email': staff.email,
      'gender': staff.gender,
      'dob': staff.dob,
      'joining_date': staff.joiningDate,
      'qualification': staff.qualification,
      'experience': staff.experience,
      'address': staff.address,
      'role': staff.role,
      'status': staff.status,
    });
    await fetchStaff();
    return true;
  } catch (e) {
    return false;
  }
}

StaffModel? getStaffById(int id) {
  try {
    return _staffList.firstWhere((s) => s.id == id);
  } catch (e) {
    return null;
  }
}

  Future<bool> deleteStaff(int id) async {
    try {
      await apiService.delete('/staff/$id');
      _staffList.removeWhere((s) => s.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _staffList.removeWhere((s) => s.id == id);
      notifyListeners();
      return true;
    }
  }

  Future<bool> approveLeave(int leaveId) async {
    final idx = _leaves.indexWhere((l) => l.id == leaveId);
    if (idx != -1) {
      _leaves[idx] = LeaveModel(
        id: _leaves[idx].id, staffId: _leaves[idx].staffId,
        staffName: _leaves[idx].staffName, leaveType: _leaves[idx].leaveType,
        fromDate: _leaves[idx].fromDate, toDate: _leaves[idx].toDate,
        reason: _leaves[idx].reason, status: 'approved', days: _leaves[idx].days,
      );
      notifyListeners();
    }
    return true;
  }

  Future<bool> rejectLeave(int leaveId) async {
    final idx = _leaves.indexWhere((l) => l.id == leaveId);
    if (idx != -1) {
      _leaves[idx] = LeaveModel(
        id: _leaves[idx].id, staffId: _leaves[idx].staffId,
        staffName: _leaves[idx].staffName, leaveType: _leaves[idx].leaveType,
        fromDate: _leaves[idx].fromDate, toDate: _leaves[idx].toDate,
        reason: _leaves[idx].reason, status: 'rejected', days: _leaves[idx].days,
      );
      notifyListeners();
    }
    return true;
  }

  void setSearchQuery(String q) { _searchQuery = q; notifyListeners(); }
  void setDeptFilter(String dept) { _filterDept = dept; notifyListeners(); }
}

