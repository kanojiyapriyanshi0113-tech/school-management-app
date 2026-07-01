import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ─── All translations ─────────────────────────────────────────────────────────
const Map<String, Map<String, String>> _t = {
  'en': {
    // App
    'app_name': 'School Management System',
    'school_management': 'School Management System',

    // Auth
    'welcome_back': 'Welcome Back',
    'sign_in_account': 'Sign in to your account',
    'login_as': 'Login As',
    'email_address': 'Email Address',
    'password': 'Password',
    'forgot_password': 'Forgot Password?',
    'sign_in': 'Sign In',
    'admin': 'Admin',
    'staff': 'Staff',
    'student': 'Student',
    'parent': 'Parent',

    // Dashboards
    'dashboard': 'Dashboard',
    'admin_dashboard': 'School Management System',
    'student_dashboard': 'Student Dashboard',
    'parent_dashboard': 'Parent Dashboard',
    'staff_dashboard': 'Staff Dashboard',
    'overview': 'Overview',
    'quick_actions': 'Quick Actions',
    'recent_activity': 'Recent Activity',
    'hello': 'Hello',
    'student_portal': 'Student Portal',
    'parent_portal': 'Parent Portal',

    // Menu items
    'students': 'Students',
    'fees': 'Fees',
    'exams': 'Exams',
    'attendance': 'Attendance',
    'notices': 'Notices',
    'library': 'Library',
    'transport': 'Transport',
    'hostel': 'Hostel',
    'reports': 'Reports',
    'settings': 'Settings',
    'logout': 'Logout',
    'admissions': 'Admissions',
    'classes': 'Classes',
    'staff_menu': 'Staff',
    'homework': 'Homework',
    'timetable': 'Timetable',

    // Stats
    'total_students': 'Total Students',
    'total_staff': 'Total Staff',
    'present_today': 'Present Today',
    'fee_collected': 'Fee Collected',
    'exams_scheduled': 'Exams Scheduled',
    'pending_fees': 'Pending Fees',

    // Students
    'add_student': 'Add Student',
    'edit_student': 'Edit Student',
    'student_profile': 'Student Profile',
    'personal': 'Personal',
    'admission': 'Admission',
    'academic': 'Academic',
    'fee': 'Fee',
    'documents': 'Documents',
    'health': 'Health',
    'active': 'Active',
    'inactive': 'Inactive',
    'search': 'Search',
    'add_new_student': 'Add New Student',

    // Fees
    'collect_fee': 'Collect Fee',
    'fee_management': 'Fee Management',
    'fee_type': 'Fee Type',
    'amount': 'Amount',
    'due_date': 'Due Date',
    'payment_method': 'Payment Method',
    'paid': 'Paid',
    'pending': 'Pending',
    'overdue': 'Overdue',
    'mark_paid': 'Mark Paid',
    'receipt': 'Receipt',
    'fee_receipt': 'Fee Receipt',
    'download_pdf': 'Download PDF',
    'tuition_fee': 'Tuition Fee',
    'transport_fee': 'Transport Fee',
    'hostel_fee': 'Hostel Fee',
    'exam_fee': 'Exam Fee',
    'library_fee': 'Library Fee',
    'total': 'Total',
    'view_receipt': 'View Receipt',
    'cash': 'Cash',
    'upi': 'UPI',
    'online_transfer': 'Online Transfer',
    'cheque': 'Cheque',
    'fee_collected_success': 'Fee Collected!',
    'payment_received': 'Payment received successfully',

    // Exams
    'exam_management': 'Exam Management',
    'create_exam': 'Create Exam',
    'drafts': 'Drafts',
    'published': 'Published',
    'publish': 'Publish',
    'cancel': 'Cancel',
    'marks': 'Marks',
    'results': 'Results',
    'new_exam': 'New Exam',

    // Attendance
    'mark_attendance': 'Mark Attendance',
    'present': 'Present',
    'absent': 'Absent',
    'late': 'Late',
    'total_present': 'Present',
    'total_absent': 'Absent',

    // Notices
    'new_notice': 'New Notice',
    'all': 'All',

    // Reports
    'reports_analytics': 'Reports & Analytics',
    'export_pdf': 'Export PDF',
    'all_reports': 'All Reports',

    // Settings
    'language': 'Language',
    'theme': 'Theme',
    'change_language': 'Change Language',
    'select_language': 'Select Language',
    'english': 'English',
    'hindi': 'Hindi',
    'marathi': 'Marathi',
    'language_changed': 'Language changed successfully',

    // Common
    'save': 'Save',
    'update': 'Update',
    'delete': 'Delete',
    'confirm': 'Confirm',
    'no': 'No',
    'yes': 'Yes',
    'loading': 'Loading...',
    'no_data': 'No data found',
    'error': 'Something went wrong',
    'success': 'Success',
    'back': 'Back',
    'view_all': 'View All',
    'refresh': 'Refresh',
    'add': 'Add',
    'edit': 'Edit',
    'name': 'Name',
    'class': 'Class',
    'section': 'Section',
    'roll_no': 'Roll No',
    'admission_no': 'Admission No',
    'phone': 'Phone',
    'email': 'Email',
    'address': 'Address',
    'date_of_birth': 'Date of Birth',
    'gender': 'Gender',
    'blood_group': 'Blood Group',
    'father_name': 'Father Name',
    'mother_name': 'Mother Name',
    'my_children': 'My Children',
    'enrolled': 'enrolled',
    'message': 'Message',
    'notifications': 'Notifications',
    'profile': 'Profile',
    'administrator': 'Administrator',
  },

  'hi': {
    // App
    'app_name': 'स्कूल प्रबंधन प्रणाली',
    'school_management': 'स्कूल प्रबंधन प्रणाली',

    // Auth
    'welcome_back': 'वापस स्वागत है',
    'sign_in_account': 'अपने खाते में साइन इन करें',
    'login_as': 'इस रूप में लॉगिन करें',
    'email_address': 'ईमेल पता',
    'password': 'पासवर्ड',
    'forgot_password': 'पासवर्ड भूल गए?',
    'sign_in': 'साइन इन करें',
    'admin': 'व्यवस्थापक',
    'staff': 'कर्मचारी',
    'student': 'छात्र',
    'parent': 'अभिभावक',

    // Dashboards
    'dashboard': 'डैशबोर्ड',
    'admin_dashboard': 'स्कूल प्रबंधन प्रणाली',
    'student_dashboard': 'छात्र डैशबोर्ड',
    'parent_dashboard': 'अभिभावक डैशबोर्ड',
    'staff_dashboard': 'कर्मचारी डैशबोर्ड',
    'overview': 'अवलोकन',
    'quick_actions': 'त्वरित क्रियाएं',
    'recent_activity': 'हालिया गतिविधि',
    'hello': 'नमस्ते',
    'student_portal': 'छात्र पोर्टल',
    'parent_portal': 'अभिभावक पोर्टल',

    // Menu items
    'students': 'छात्र',
    'fees': 'शुल्क',
    'exams': 'परीक्षाएं',
    'attendance': 'उपस्थिति',
    'notices': 'सूचनाएं',
    'library': 'पुस्तकालय',
    'transport': 'परिवहन',
    'hostel': 'छात्रावास',
    'reports': 'रिपोर्ट',
    'settings': 'सेटिंग',
    'logout': 'लॉगआउट',
    'admissions': 'प्रवेश',
    'classes': 'कक्षाएं',
    'homework': 'गृहकार्य',
    'timetable': 'समय सारिणी',

    // Stats
    'total_students': 'कुल छात्र',
    'total_staff': 'कुल कर्मचारी',
    'present_today': 'आज उपस्थित',
    'fee_collected': 'शुल्क संग्रह',
    'exams_scheduled': 'निर्धारित परीक्षाएं',
    'pending_fees': 'बकाया शुल्क',

    // Students
    'add_student': 'छात्र जोड़ें',
    'edit_student': 'छात्र संपादित करें',
    'student_profile': 'छात्र प्रोफ़ाइल',
    'personal': 'व्यक्तिगत',
    'admission': 'प्रवेश',
    'academic': 'शैक्षणिक',
    'fee': 'शुल्क',
    'documents': 'दस्तावेज़',
    'health': 'स्वास्थ्य',
    'active': 'सक्रिय',
    'inactive': 'निष्क्रिय',
    'search': 'खोजें',
    'add_new_student': 'नया छात्र जोड़ें',

    // Fees
    'collect_fee': 'शुल्क संग्रह',
    'fee_management': 'शुल्क प्रबंधन',
    'fee_type': 'शुल्क प्रकार',
    'amount': 'राशि',
    'due_date': 'देय तिथि',
    'payment_method': 'भुगतान विधि',
    'paid': 'भुगतान',
    'pending': 'लंबित',
    'overdue': 'अतिदेय',
    'mark_paid': 'भुगतान चिह्नित करें',
    'receipt': 'रसीद',
    'fee_receipt': 'शुल्क रसीद',
    'download_pdf': 'PDF डाउनलोड करें',
    'tuition_fee': 'ट्यूशन शुल्क',
    'transport_fee': 'परिवहन शुल्क',
    'hostel_fee': 'छात्रावास शुल्क',
    'exam_fee': 'परीक्षा शुल्क',
    'library_fee': 'पुस्तकालय शुल्क',
    'total': 'कुल',
    'view_receipt': 'रसीद देखें',
    'cash': 'नकद',
    'upi': 'यूपीआई',
    'online_transfer': 'ऑनलाइन ट्रांसफर',
    'cheque': 'चेक',
    'fee_collected_success': 'शुल्क संग्रहित!',
    'payment_received': 'भुगतान सफलतापूर्वक प्राप्त हुआ',

    // Exams
    'exam_management': 'परीक्षा प्रबंधन',
    'create_exam': 'परीक्षा बनाएं',
    'drafts': 'मसौदे',
    'published': 'प्रकाशित',
    'publish': 'प्रकाशित करें',
    'cancel': 'रद्द करें',
    'marks': 'अंक',
    'results': 'परिणाम',
    'new_exam': 'नई परीक्षा',

    // Attendance
    'mark_attendance': 'उपस्थिति दर्ज करें',
    'present': 'उपस्थित',
    'absent': 'अनुपस्थित',
    'late': 'देर से',
    'total_present': 'उपस्थित',
    'total_absent': 'अनुपस्थित',

    // Notices
    'new_notice': 'नई सूचना',
    'all': 'सभी',

    // Reports
    'reports_analytics': 'रिपोर्ट और विश्लेषण',
    'export_pdf': 'PDF निर्यात करें',
    'all_reports': 'सभी रिपोर्ट',

    // Settings
    'language': 'भाषा',
    'theme': 'थीम',
    'change_language': 'भाषा बदलें',
    'select_language': 'भाषा चुनें',
    'english': 'अंग्रेज़ी',
    'hindi': 'हिन्दी',
    'marathi': 'मराठी',
    'language_changed': 'भाषा सफलतापूर्वक बदली गई',

    // Common
    'save': 'सहेजें',
    'update': 'अपडेट करें',
    'delete': 'हटाएं',
    'confirm': 'पुष्टि करें',
    'no': 'नहीं',
    'yes': 'हां',
    'loading': 'लोड हो रहा है...',
    'no_data': 'कोई डेटा नहीं मिला',
    'error': 'कुछ गलत हो गया',
    'success': 'सफलता',
    'back': 'वापस',
    'view_all': 'सभी देखें',
    'refresh': 'ताज़ा करें',
    'add': 'जोड़ें',
    'edit': 'संपादित करें',
    'name': 'नाम',
    'class': 'कक्षा',
    'section': 'अनुभाग',
    'roll_no': 'रोल नंबर',
    'admission_no': 'प्रवेश संख्या',
    'phone': 'फ़ोन',
    'email': 'ईमेल',
    'address': 'पता',
    'date_of_birth': 'जन्म तिथि',
    'gender': 'लिंग',
    'blood_group': 'रक्त समूह',
    'father_name': 'पिता का नाम',
    'mother_name': 'माता का नाम',
    'my_children': 'मेरे बच्चे',
    'enrolled': 'नामांकित',
    'message': 'संदेश',
    'notifications': 'सूचनाएं',
    'profile': 'प्रोफ़ाइल',
    'administrator': 'व्यवस्थापक',
  },

  'mr': {
    // App
    'app_name': 'शाळा व्यवस्थापन प्रणाली',
    'school_management': 'शाळा व्यवस्थापन प्रणाली',

    // Auth
    'welcome_back': 'परत स्वागत आहे',
    'sign_in_account': 'आपल्या खात्यात साइन इन करा',
    'login_as': 'म्हणून लॉगिन करा',
    'email_address': 'ईमेल पत्ता',
    'password': 'पासवर्ड',
    'forgot_password': 'पासवर्ड विसरलात?',
    'sign_in': 'साइन इन करा',
    'admin': 'प्रशासक',
    'staff': 'कर्मचारी',
    'student': 'विद्यार्थी',
    'parent': 'पालक',

    // Dashboards
    'dashboard': 'डॅशबोर्ड',
    'admin_dashboard': 'शाळा व्यवस्थापन प्रणाली',
    'student_dashboard': 'विद्यार्थी डॅशबोर्ड',
    'parent_dashboard': 'पालक डॅशबोर्ड',
    'staff_dashboard': 'कर्मचारी डॅशबोर्ड',
    'overview': 'आढावा',
    'quick_actions': 'त्वरित क्रिया',
    'recent_activity': 'अलीकडील क्रियाकलाप',
    'hello': 'नमस्कार',
    'student_portal': 'विद्यार्थी पोर्टल',
    'parent_portal': 'पालक पोर्टल',

    // Menu items
    'students': 'विद्यार्थी',
    'fees': 'शुल्क',
    'exams': 'परीक्षा',
    'attendance': 'उपस्थिती',
    'notices': 'सूचना',
    'library': 'ग्रंथालय',
    'transport': 'वाहतूक',
    'hostel': 'वसतिगृह',
    'reports': 'अहवाल',
    'settings': 'सेटिंग्ज',
    'logout': 'लॉगआउट',
    'admissions': 'प्रवेश',
    'classes': 'वर्ग',
    'homework': 'गृहपाठ',
    'timetable': 'वेळापत्रक',

    // Stats
    'total_students': 'एकूण विद्यार्थी',
    'total_staff': 'एकूण कर्मचारी',
    'present_today': 'आज उपस्थित',
    'fee_collected': 'शुल्क संकलन',
    'exams_scheduled': 'नियोजित परीक्षा',
    'pending_fees': 'प्रलंबित शुल्क',

    // Students
    'add_student': 'विद्यार्थी जोडा',
    'edit_student': 'विद्यार्थी संपादित करा',
    'student_profile': 'विद्यार्थी प्रोफाइल',
    'personal': 'वैयक्तिक',
    'admission': 'प्रवेश',
    'academic': 'शैक्षणिक',
    'fee': 'शुल्क',
    'documents': 'कागदपत्रे',
    'health': 'आरोग्य',
    'active': 'सक्रिय',
    'inactive': 'निष्क्रिय',
    'search': 'शोधा',
    'add_new_student': 'नवीन विद्यार्थी जोडा',

    // Fees
    'collect_fee': 'शुल्क गोळा करा',
    'fee_management': 'शुल्क व्यवस्थापन',
    'fee_type': 'शुल्क प्रकार',
    'amount': 'रक्कम',
    'due_date': 'देय तारीख',
    'payment_method': 'पेमेंट पद्धत',
    'paid': 'भरलेले',
    'pending': 'प्रलंबित',
    'overdue': 'थकीत',
    'mark_paid': 'भरलेले म्हणून चिन्हांकित करा',
    'receipt': 'पावती',
    'fee_receipt': 'शुल्क पावती',
    'download_pdf': 'PDF डाउनलोड करा',
    'tuition_fee': 'शिक्षण शुल्क',
    'transport_fee': 'वाहतूक शुल्क',
    'hostel_fee': 'वसतिगृह शुल्क',
    'exam_fee': 'परीक्षा शुल्क',
    'library_fee': 'ग्रंथालय शुल्क',
    'total': 'एकूण',
    'view_receipt': 'पावती पहा',
    'cash': 'रोख',
    'upi': 'यूपीआय',
    'online_transfer': 'ऑनलाइन हस्तांतरण',
    'cheque': 'धनादेश',
    'fee_collected_success': 'शुल्क गोळा केले!',
    'payment_received': 'पेमेंट यशस्वीरित्या प्राप्त झाले',

    // Exams
    'exam_management': 'परीक्षा व्यवस्थापन',
    'create_exam': 'परीक्षा तयार करा',
    'drafts': 'मसुदे',
    'published': 'प्रकाशित',
    'publish': 'प्रकाशित करा',
    'cancel': 'रद्द करा',
    'marks': 'गुण',
    'results': 'निकाल',
    'new_exam': 'नवीन परीक्षा',

    // Attendance
    'mark_attendance': 'उपस्थिती नोंदवा',
    'present': 'उपस्थित',
    'absent': 'अनुपस्थित',
    'late': 'उशिरा',
    'total_present': 'उपस्थित',
    'total_absent': 'अनुपस्थित',

    // Notices
    'new_notice': 'नवीन सूचना',
    'all': 'सर्व',

    // Reports
    'reports_analytics': 'अहवाल आणि विश्लेषण',
    'export_pdf': 'PDF निर्यात करा',
    'all_reports': 'सर्व अहवाल',

    // Settings
    'language': 'भाषा',
    'theme': 'थीम',
    'change_language': 'भाषा बदला',
    'select_language': 'भाषा निवडा',
    'english': 'इंग्रजी',
    'hindi': 'हिंदी',
    'marathi': 'मराठी',
    'language_changed': 'भाषा यशस्वीरित्या बदलली',

    // Common
    'save': 'जतन करा',
    'update': 'अपडेट करा',
    'delete': 'हटवा',
    'confirm': 'पुष्टी करा',
    'no': 'नाही',
    'yes': 'होय',
    'loading': 'लोड होत आहे...',
    'no_data': 'कोणताही डेटा आढळला नाही',
    'error': 'काहीतरी चुकले',
    'success': 'यशस्वी',
    'back': 'मागे',
    'view_all': 'सर्व पहा',
    'refresh': 'ताज़े करा',
    'add': 'जोडा',
    'edit': 'संपादित करा',
    'name': 'नाव',
    'class': 'वर्ग',
    'section': 'विभाग',
    'roll_no': 'रोल नंबर',
    'admission_no': 'प्रवेश क्रमांक',
    'phone': 'फोन',
    'email': 'ईमेल',
    'address': 'पत्ता',
    'date_of_birth': 'जन्म तारीख',
    'gender': 'लिंग',
    'blood_group': 'रक्त गट',
    'father_name': 'वडिलांचे नाव',
    'mother_name': 'आईचे नाव',
    'my_children': 'माझी मुले',
    'enrolled': 'नोंदणी केलेले',
    'message': 'संदेश',
    'notifications': 'सूचना',
    'profile': 'प्रोफाइल',
    'administrator': 'प्रशासक',
  },
};

class LanguageProvider extends ChangeNotifier {
  String _langCode = 'en';
  static const _key = 'lang_code';

  String get langCode => _langCode;
  String get langName {
    switch (_langCode) {
      case 'hi': return 'हिन्दी';
      case 'mr': return 'मराठी';
      default: return 'English';
    }
  }

  LanguageProvider() { _load(); }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_key) ?? 'en';
    _langCode = code;
    notifyListeners();
  }

  Future<void> setLanguage(String code) async {
    _langCode = code;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, code);
  }

  // Main translation function
  String t(String key) =>
    _t[_langCode]?[key] ?? _t['en']?[key] ?? key;
}

// Extension for easy access from BuildContext
extension LanguageExtension on BuildContext {
  String t(String key) {
    try {
      return read<LanguageProvider>().t(key);
    } catch (_) {
      return key;
    }
  }
  String tWatch(String key) {
    try {
      return watch<LanguageProvider>().t(key);
    } catch (_) {
      return key;
    }
  }
}
