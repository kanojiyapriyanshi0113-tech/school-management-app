import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../views/auth/login_screen.dart';
import '../views/auth/splash_screen.dart';
import '../views/dashboard/admin_dashboard.dart';
import '../views/dashboard/student_dashboard.dart';
import '../views/dashboard/parent_dashboard.dart';
import '../views/staff/staff_dashboard.dart';
import '../views/students/student_list_screen.dart';
import '../views/students/student_detail_screen.dart';
import '../views/students/add_edit_student_screen.dart';
import '../views/students/student_hostel_detail_screen.dart';
import '../views/attendance/attendance_screen.dart';
import '../views/attendance/mark_attendance_screen.dart';
import '../views/fee/fee_list_screen.dart';
import '../views/fee/create_fee_screen.dart';
import '../views/exam/exam_list_screen.dart';
import '../views/exam/exam_dashboard.dart';
import '../views/exam/create_exam_screen.dart';
import '../views/exam/marks_entry_screen.dart';
import '../views/exam/result_screen.dart';
import '../views/notices/notice_board_screen.dart';
import '../views/notices/create_notice_screen.dart';
import '../views/timetable/timetable_screen.dart';
import '../views/library/library_screen.dart';
import '../views/transport/transport_screen.dart';
import '../views/transport/student_transport_view.dart';
import '../views/hostel/hostel_screen.dart';
import '../views/hostel/hostel_admission_form.dart';
import '../views/reports/reports_screen.dart';
import '../views/settings/settings_screen.dart';
import '../views/staff/staff_list_screen.dart';
import '../views/staff/staff_detail_screen.dart';
import '../views/staff/add_edit_staff_screen.dart';
import '../views/staff/staff_attendance_screen.dart';
import '../views/staff/leave_management_screen.dart';
import '../views/staff/salary_screen.dart';
import '../views/staff/staff_timetable_screen.dart';
import '../views/staff/staff_reports_screen.dart';
import '../views/classes/class_management_screen.dart';
import '../views/student/student_homework_screen.dart';
import '../views/student/student_id_card_screen.dart';
import '../views/student/student_leave_screen.dart';
import '../views/parent/parent_homework_screen.dart';
import '../views/parent/parent_message_screen.dart';
import '../views/reports/report_detail_screen.dart';
import '../views/fee/fee_receipt_screen.dart';
import '../views/fee/fee_payment_screen.dart';
import '../views/students/student_progress_screen.dart';
import '../views/transport/transport_tracking_screen.dart';
import '../views/admission/admission_screen.dart';
import '../views/teacher/teacher_dashboard.dart';
import '../views/teacher/teacher_attendance_screen.dart';
import '../views/teacher/teacher_homework_screen.dart';
import '../views/teacher/teacher_marks_screen.dart';
import '../views/settings/settings_screen.dart';

class AppRouter {
  static final _key = GlobalKey<NavigatorState>();

  static final router = GoRouter(
    navigatorKey: _key,
    initialLocation: '/splash',
    redirect: (context, state) {
      final auth = context.read<AuthProvider>();
      final loggedIn = auth.isAuthenticated;
      final onLogin = state.matchedLocation == '/login';
      if (!loggedIn && !onLogin) return '/login';
      if (loggedIn && onLogin) {
        switch (auth.user?.role) {
          case 'staff':   return '/dashboard/staff';
          case 'student': return '/dashboard/student';
          case 'parent':  return '/dashboard/parent';
          default:        return '/dashboard/admin';
        }
      }
      if (loggedIn) {
        final role = auth.user?.role;
        final loc = state.matchedLocation;
        if (role == 'student') {
          if (loc.startsWith('/dashboard/admin') ||
              loc.startsWith('/dashboard/staff') ||
              loc.startsWith('/staff/')) {
            return '/dashboard/student';
          }
        }
        if (role == 'staff') {
          if (loc.startsWith('/dashboard/admin') ||
              loc.startsWith('/dashboard/student') ||
              loc.startsWith('/dashboard/parent')) {
            return '/dashboard/staff';
          }
        }
        if (role == 'parent') {
          if (loc.startsWith('/dashboard/admin') ||
              loc.startsWith('/dashboard/staff') ||
              loc.startsWith('/dashboard/student')) {
            return '/dashboard/parent';
          }
        }
      }
      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (c, s) => const SplashScreen()),
      GoRoute(path: '/login',  builder: (c, s) => const LoginScreen()),
      GoRoute(path: '/dashboard/admin',   builder: (c, s) => const AdminDashboard()),
      GoRoute(path: '/dashboard/staff',   builder: (c, s) => const StaffDashboard()),
      GoRoute(path: '/dashboard/student', builder: (c, s) => const StudentDashboard()),
      GoRoute(path: '/dashboard/parent',  builder: (c, s) => const ParentDashboard()),

      // Students
      GoRoute(
        path: '/students',
        builder: (c, s) => const StudentListScreen(),
        routes: [
          GoRoute(path: 'add', builder: (c, s) => const AddEditStudentScreen(isEdit: false)),
          GoRoute(
            path: ':id',
            builder: (c, s) => StudentDetailScreen(studentId: int.parse(s.pathParameters['id']!)),
            routes: [
              GoRoute(
                path: 'edit',
                builder: (c, s) => AddEditStudentScreen(
                  isEdit: true,
                  studentId: int.parse(s.pathParameters['id']!)),
              ),
            ],
          ),
        ],
      ),

      // Student portal
      GoRoute(path: '/student/hostel',   builder: (c, s) => const StudentHostelDetailScreen()),
      GoRoute(path: '/student/homework', builder: (c, s) => const StudentHomeworkScreen()),
      GoRoute(path: '/student/idcard',   builder: (c, s) => const StudentIdCardScreen()),
      GoRoute(path: '/student/leave',    builder: (c, s) => const StudentLeaveScreen()),
      GoRoute(path: '/student/progress', builder: (c, s) => const StudentProgressScreen()),

      // Parent portal
      GoRoute(path: '/parent/homework', builder: (c, s) => const ParentHomeworkScreen()),
      GoRoute(path: '/parent/message',  builder: (c, s) => const ParentMessageScreen()),

      // Attendance
      GoRoute(
        path: '/attendance',
        builder: (c, s) => const AttendanceScreen(),
        routes: [
          GoRoute(path: 'mark', builder: (c, s) => const MarkAttendanceScreen()),
        ],
      ),

      // Fees
      GoRoute(
        path: '/fees',
        builder: (c, s) => const FeeListScreen(),
        routes: [
          GoRoute(path: 'create', builder: (c, s) => const CreateFeeScreen()),
        ],
      ),
      GoRoute(path: '/fees/receipt/:id',
        builder: (c, s) => FeeReceiptScreen(feeId: int.parse(s.pathParameters['id']!))),
      GoRoute(path: '/fees/payment/:id',
        builder: (c, s) => FeePaymentScreen(feeId: int.parse(s.pathParameters['id']!))),

      // ?? Exams ?????????????
      GoRoute(path: '/exams',         builder: (c, s) => const ExamDashboard()),
      GoRoute(path: '/exams/list',    builder: (c, s) => const ExamListScreen()),
      GoRoute(path: '/exams/create',  builder: (c, s) => const CreateExamScreen()),
      GoRoute(path: '/exams/marks',   builder: (c, s) => const MarksEntryScreen()),
      GoRoute(path: '/exams/results', builder: (c, s) => const ResultScreen()),
      // ??????????

      // Notices
      GoRoute(
        path: '/notices',
        builder: (c, s) => const NoticeBoardScreen(),
        routes: [
          GoRoute(path: 'create', builder: (c, s) => const CreateNoticeScreen()),
        ],
      ),

      GoRoute(path: '/timetable',  builder: (c, s) => const TimetableScreen()),
      GoRoute(path: '/library',    builder: (c, s) => const LibraryScreen()),
      GoRoute(path: '/transport', builder: (c, s) {
        final role = c.read<AuthProvider>().user?.role ?? 'student';
        return (role == 'admin' || role == 'staff')
          ? const TransportScreen()
          : const StudentTransportView();
      }),
      GoRoute(path: '/transport/tracking', builder: (c, s) => const TransportTrackingScreen()),
      GoRoute(path: '/hostel',           builder: (c, s) => const HostelScreen()),
      GoRoute(path: '/hostel/admission', builder: (c, s) => const HostelAdmissionForm()),
      GoRoute(path: '/reports',          builder: (c, s) => const ReportsScreen()),
      GoRoute(path: '/settings',         builder: (c, s) => const SettingsScreen()),
      GoRoute(path: '/reports/:type',
        builder: (c, s) => ReportDetailScreen(
          reportType: Uri.decodeComponent(s.pathParameters['type']!))),
      GoRoute(path: '/classes',    builder: (c, s) => const ClassManagementScreen()),
      GoRoute(path: '/admission',  builder: (c, s) => const AdmissionScreen()),

      // Staff module
      GoRoute(path: '/staff/dashboard',  builder: (c, s) => const StaffDashboard()),
      GoRoute(path: '/staff/list',       builder: (c, s) => const StaffListScreen()),
      GoRoute(path: '/staff/add',        builder: (c, s) => const AddEditStaffScreen(isEdit: false)),
      GoRoute(path: '/staff/attendance', builder: (c, s) => const StaffAttendanceScreen()),
      GoRoute(path: '/staff/leave',      builder: (c, s) => const LeaveManagementScreen()),
      GoRoute(path: '/staff/salary',     builder: (c, s) => const SalaryScreen()),
      GoRoute(path: '/staff/timetable',  builder: (c, s) => const StaffTimetableScreen()),
      GoRoute(path: '/staff/reports',    builder: (c, s) => const StaffReportsScreen()),
      GoRoute(
        path: '/staff/:id',
        builder: (c, s) => StaffDetailScreen(staffId: int.parse(s.pathParameters['id']!)),
        routes: [
          GoRoute(
            path: 'edit',
            builder: (c, s) => AddEditStaffScreen(
              isEdit: true,
              staffId: int.parse(s.pathParameters['id']!)),
          ),
        ],
      ),

      // Teacher module
      GoRoute(path: '/teacher/dashboard',  builder: (c, s) => const TeacherDashboard()),
      GoRoute(path: '/teacher/attendance', builder: (c, s) => const TeacherAttendanceScreen()),
      GoRoute(path: '/teacher/homework',   builder: (c, s) => const TeacherHomeworkScreen()),
      GoRoute(path: '/teacher/marks',      builder: (c, s) => const TeacherMarksScreen()),
    ],
  );
}