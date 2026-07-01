import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/transport_provider.dart';
import 'transport_dashboard.dart';
import 'vehicle_management_screen.dart';
import 'route_management_screen.dart';
import 'student_transport_screen.dart';
import 'driver_management_screen.dart';
import 'transport_fee_screen.dart';
import 'transport_attendance_screen.dart';
import 'transport_tracking_screen.dart';
import 'transport_reports_screen.dart';
import '../../providers/language_provider.dart';

class TransportScreen extends StatefulWidget {
  const TransportScreen({super.key});
  @override
  State<TransportScreen> createState() => _TransportScreenState();
}

class _TransportScreenState extends State<TransportScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 9, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TransportProvider>().fetchAll();
      context.read<TransportProvider>().fetchStudents();
    });
  }

  @override
  void dispose() { _tabController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final role = context.watch<AuthProvider>().user?.role;
    return Scaffold(
      appBar: AppBar(
        title: Text(context.watch<LanguageProvider>().t('transport')),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => context.go(
            role == 'parent' ? '/dashboard/parent'
            : role == 'student' ? '/dashboard/student'
            : role == 'staff' ? '/dashboard/staff'
            : '/dashboard/admin')),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard, size: 18), text: 'Dashboard'),
            Tab(icon: Icon(Icons.directions_bus, size: 18), text: 'Vehicles'),
            Tab(icon: Icon(Icons.route, size: 18), text: 'Routes'),
            Tab(icon: Icon(Icons.people, size: 18), text: 'Students'),
            Tab(icon: Icon(Icons.person, size: 18), text: 'Drivers'),
            Tab(icon: Icon(Icons.payment, size: 18), text: 'Fees'),
            Tab(icon: Icon(Icons.how_to_reg, size: 18), text: 'Attendance'),
            Tab(icon: Icon(Icons.gps_fixed, size: 18), text: 'Live Track'),
            Tab(icon: Icon(Icons.bar_chart, size: 18), text: 'Reports'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          TransportDashboard(),
          VehicleManagementScreen(),
          RouteManagementScreen(),
          StudentTransportScreen(),
          DriverManagementScreen(),
          TransportFeeScreen(),
          TransportAttendanceScreen(),
          TransportTrackingScreen(),
          TransportReportsScreen(),
        ],
      ),
    );
  }
}


