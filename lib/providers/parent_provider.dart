import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ChildModel {
  final int id;
  final String name, admissionNo, className, section, rollNo;
  final String status, fatherName, motherName, parentPhone, parentEmail;
  final String dob, gender, bloodGroup, photo;

  const ChildModel({
    required this.id, required this.name, required this.admissionNo,
    required this.className, required this.section, required this.rollNo,
    required this.status, required this.fatherName, required this.motherName,
    required this.parentPhone, required this.parentEmail,
    required this.dob, required this.gender, required this.bloodGroup,
    this.photo = '',
  });

  String get classWithSection => '$className-$section';
  String get initial => name.isNotEmpty ? name[0].toUpperCase() : '?';

  factory ChildModel.fromJson(Map<String, dynamic> j) => ChildModel(
    id:           (j['id'] ?? 0) as int,
    name:         j['name'] ?? '',
    admissionNo:  j['admission_no'] ?? '',
    className:    j['class_name'] ?? '',
    section:      j['section'] ?? '',
    rollNo:       j['roll_no'] ?? '',
    status:       j['status'] ?? 'active',
    fatherName:   j['father_name'] ?? '',
    motherName:   j['mother_name'] ?? '',
    parentPhone:  j['parent_phone'] ?? '',
    parentEmail:  j['parent_email'] ?? '',
    dob:          j['dob'] ?? '',
    gender:       j['gender'] ?? '',
    bloodGroup:   j['blood_group'] ?? '',
    photo:        j['photo'] ?? '',
  );
}

class ClassGroup {
  final String className, section;
  final List<ChildModel> children;
  const ClassGroup({required this.className, required this.section, required this.children});
  String get label => '$className - $section';
}

class ParentProvider extends ChangeNotifier {
  final _api = ApiService();

  List<ClassGroup> _classGroups = [];
  List<ChildModel> _allChildren = [];
  ChildModel? _selectedChild;
  bool _loading = false;
  String? _error;

  List<ClassGroup> get classGroups => _classGroups;
  List<ChildModel> get allChildren => _allChildren;
  ChildModel? get selectedChild => _selectedChild;
  bool get isLoading => _loading;
  String? get error => _error;
  int get totalChildren => _allChildren.length;

  void selectChild(ChildModel child) {
    _selectedChild = child;
    notifyListeners();
  }

  Future<void> fetchMyChildren() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final res = await _api.get('/parent/children');
      final groups = (res['data'] as List? ?? []);

      _classGroups = groups.map((g) {
        final students = (g['students'] as List? ?? [])
            .map((s) => ChildModel.fromJson(s as Map<String, dynamic>))
            .toList();
        return ClassGroup(
          className: g['class_name'] ?? '',
          section:   g['section'] ?? '',
          children:  students,
        );
      }).toList();

      // Flat list
      _allChildren = _classGroups.expand((g) => g.children).toList();

      // Auto-select first child
      if (_selectedChild == null && _allChildren.isNotEmpty) {
        _selectedChild = _allChildren.first;
      }

      _loading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _loading = false;

      // Fallback mock data (jab tak backend live na ho)
      _classGroups = [
        ClassGroup(className: 'Class 10', section: 'A', children: [
          const ChildModel(id: 1, name: 'Rahul Kumar', admissionNo: 'ADM001',
            className: 'Class 10', section: 'A', rollNo: 'R001', status: 'active',
            fatherName: 'Suresh Kumar', motherName: 'Meena Kumar',
            parentPhone: '9876543210', parentEmail: 'parent@school.com',
            dob: '15 Mar 2009', gender: 'Male', bloodGroup: 'B+'),
        ]),
        ClassGroup(className: 'Class 8', section: 'B', children: [
          const ChildModel(id: 2, name: 'Priya Kumar', admissionNo: 'ADM042',
            className: 'Class 8', section: 'B', rollNo: 'R042', status: 'active',
            fatherName: 'Suresh Kumar', motherName: 'Meena Kumar',
            parentPhone: '9876543210', parentEmail: 'parent@school.com',
            dob: '22 Jul 2011', gender: 'Female', bloodGroup: 'A+'),
        ]),
        ClassGroup(className: 'Class 5', section: 'A', children: [
          const ChildModel(id: 3, name: 'Ankit Kumar', admissionNo: 'ADM118',
            className: 'Class 5', section: 'A', rollNo: 'R118', status: 'active',
            fatherName: 'Suresh Kumar', motherName: 'Meena Kumar',
            parentPhone: '9876543210', parentEmail: 'parent@school.com',
            dob: '10 Jan 2014', gender: 'Male', bloodGroup: 'O+'),
        ]),
      ];
      _allChildren = _classGroups.expand((g) => g.children).toList();
      if (_selectedChild == null && _allChildren.isNotEmpty) {
        _selectedChild = _allChildren.first;
      }
      notifyListeners();
    }
  }
}