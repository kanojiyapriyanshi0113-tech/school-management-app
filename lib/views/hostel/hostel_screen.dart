import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/hostel_provider.dart';
import '../../core/theme/app_theme.dart';
import 'hostel_dashboard.dart';
import 'hostel_master_screen.dart';
import 'room_management_screen.dart';
import 'student_hostel_screen.dart';
import 'hostel_fee_screen.dart';
import 'hostel_attendance_screen.dart';
import 'complaint_screen.dart';
import 'hostel_reports_screen.dart';
import '../../providers/language_provider.dart';

class HostelScreen extends StatefulWidget {
  const HostelScreen({super.key});
  @override
  State<HostelScreen> createState() => _HostelScreenState();
}

class _HostelScreenState extends State<HostelScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 8, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HostelProvider>().fetchAll();
    });
  }

  @override
  void dispose() { _tabController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final role = context.watch<AuthProvider>().user?.role;
    return Scaffold(
      appBar: AppBar(
        title: Text(context.watch<LanguageProvider>().t('hostel')),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () {
            final r = context.read<AuthProvider>().user?.role;
            context.go(r == 'staff' ? '/dashboard/staff' : '/dashboard/admin');
          },
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            Tab(text: 'Dashboard'),
            Tab(text: 'Hostels'),
            Tab(text: 'Rooms'),
            Tab(text: context.watch<LanguageProvider>().t('students')),
            Tab(text: 'Fees'),
            Tab(text: context.watch<LanguageProvider>().t('attendance')),
            Tab(text: 'Complaints'),
            Tab(text: 'Reports'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          HostelDashboard(),
          HostelMasterScreen(),
          RoomManagementScreen(),
          StudentHostelScreen(),
          HostelFeeScreen(),
          HostelAttendanceScreen(),
          ComplaintScreen(),
          HostelReportsScreen(),
        ],
      ),
    );
  }
}

