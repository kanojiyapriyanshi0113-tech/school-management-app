import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/transport_provider.dart';
import '../../core/theme/app_theme.dart';
import 'dart:async';
import 'dart:math';

class StudentTransportView extends StatefulWidget {
  const StudentTransportView({super.key});
  @override
  State<StudentTransportView> createState() => _StudentTransportViewState();
}

class _StudentTransportViewState extends State<StudentTransportView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Timer? _locationTimer;
  double _busLat = 28.6139;
  double _busLng = 77.2090;
  double _busSpeed = 0;
  String _busStatus = 'In Transit';
  String _eta = '8 min';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) =>
      context.read<TransportProvider>().fetchAll());
    // Simulate live location
    _locationTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      setState(() {
        _busLat += (Random().nextDouble() - 0.5) * 0.001;
        _busLng += (Random().nextDouble() - 0.5) * 0.001;
        _busSpeed = (25 + Random().nextInt(30)).toDouble();
        final etaMins = 5 + Random().nextInt(10);
        _eta = '$etaMins min';
      });
    });
  }

  @override
  void dispose() { _tabController.dispose(); _locationTimer?.cancel(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<TransportProvider>();
    final user = context.watch<AuthProvider>().user;
    final role = user?.role ?? 'student';
    final isParent = role == 'parent';  

    final myTransport = p.students.toList();
    final myFeesList = p.fees.toList();
    final myFees = myFeesList;
    return Scaffold(
      appBar: AppBar(
        title: Text(isParent ? "Child's Transport" : 'My Transport'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () {
            final role = context.read<AuthProvider>().user?.role ?? 'student';
            context.go(role == 'parent' ? '/dashboard/parent' : '/dashboard/student');
          }),
        actions: [
          IconButton(icon: const Icon(Icons.notifications_outlined),
            onPressed: () => _showNotifications(context)),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            Tab(icon: const Icon(Icons.directions_bus, size: 16),
              text: isParent ? 'Dashboard' : 'My Bus'),
            const Tab(icon: Icon(Icons.gps_fixed, size: 16), text: 'Live Track'),
            const Tab(icon: Icon(Icons.route, size: 16), text: 'Route'),
            const Tab(icon: Icon(Icons.payment, size: 16), text: 'Fees'),
            const Tab(icon: Icon(Icons.report_problem, size: 16), text: 'Support'),
            if (isParent) const Tab(icon: Icon(Icons.how_to_reg, size: 16), text: 'Attendance'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _busDetailsTab(context, p, myTransport, user),
          _liveTrackTab(context, p, myTransport),
          _routeTab(context, p, myTransport),
          _feesTab(context, myFees, p),
          _supportTab(context),
          if (isParent) _attendanceTab(context, p, myTransport),
        ],
      ),
    );
  }

  // ?? Tab 1: Bus Details ???????????
  Widget _busDetailsTab(BuildContext context, TransportProvider p,
      List myTransport, user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        // Bus status card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
              AppTheme.primaryColor, Colors.blue.shade700]),
            borderRadius: BorderRadius.circular(16)),
          child: Column(children: [
            Row(children: [
              const Icon(Icons.directions_bus, color: Colors.white, size: 36),
              const SizedBox(width: 12),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Your Bus', style: TextStyle(color: Colors.white70, fontSize: 12)),
                Text(myTransport.isEmpty ? 'Not Assigned'
                  : _getVehicleNumber(p, myTransport[0].vehicleId),
                  style: const TextStyle(color: Colors.white,
                    fontWeight: FontWeight.bold, fontSize: 20)),
              ])),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8)),
                child: Row(children: [
                  Container(width: 8, height: 8,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle, color: Colors.greenAccent)),
                  const SizedBox(width: 6),
                  Text(_busStatus,
                    style: const TextStyle(color: Colors.white,
                      fontSize: 11, fontWeight: FontWeight.bold)),
                ])),
            ]),
            const SizedBox(height: 14),
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              _busStatItem('Speed', '$_busSpeed km/h', Icons.speed),
              _busStatItem('ETA', _eta, Icons.timer),
              _busStatItem('Status', 'On Route', Icons.check_circle),
            ]),
          ])),
        const SizedBox(height: 16),

        if (myTransport.isEmpty)
          _emptyCard('No transport assigned', 'Contact admin to assign transport',
            Icons.directions_bus)
        else ...[
          ...myTransport.map((t) {
            final vehicle = _getVehicle(p, t.vehicleId);
            final route = _getRoute(p, t.routeId);
            return Column(children: [
              // Transport Pass
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(children: [
                    Row(children: [
                      const Icon(Icons.badge, color: AppTheme.primaryColor),
                      const SizedBox(width: 8),
                      const Text('Transport Pass',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6)),
                        child: const Text('ACTIVE',
                          style: TextStyle(color: Colors.green,
                            fontWeight: FontWeight.bold, fontSize: 10))),
                    ]),
                    const Divider(height: 16),
                    _detailRow(Icons.person, 'Name', t.studentName),
                    _detailRow(Icons.directions_bus, 'Bus',
                      _getVehicleNumber(p, t.vehicleId)),
                    _detailRow(Icons.route, 'Route',
                      route?.routeName ?? 'N/A'),
                    _detailRow(Icons.location_on, 'Pickup Stop',
                      t.pickupStop.isEmpty ? 'N/A' : t.pickupStop),
                    _detailRow(Icons.location_off, 'Drop Stop',
                      t.dropStop.isEmpty ? 'N/A' : t.dropStop),
                    _detailRow(Icons.wb_sunny, 'Morning',
                      route?.morningTime ?? 'N/A'),
                    _detailRow(Icons.nights_stay, 'Evening',
                      route?.eveningTime ?? 'N/A'),
                  ]))),
              const SizedBox(height: 10),

              // Driver Details
              if (vehicle != null && vehicle.driverName.isNotEmpty)
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(children: [
                      const Row(children: [
                        Icon(Icons.person, color: Colors.teal),
                        SizedBox(width: 8),
                        Text('Driver Details',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      ]),
                      const Divider(height: 16),
                      Row(children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: Colors.teal.withOpacity(0.1),
                          child: Text(vehicle.driverName[0],
                            style: const TextStyle(fontSize: 20,
                              fontWeight: FontWeight.bold, color: Colors.teal))),
                        const SizedBox(width: 14),
                        Expanded(child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(vehicle.driverName,
                            style: const TextStyle(fontWeight: FontWeight.bold,
                              fontSize: 15)),
                          Text(vehicle.driverPhone.isEmpty
                            ? 'Contact school for details'
                            : vehicle.driverPhone,
                            style: const TextStyle(color: Colors.grey, fontSize: 12)),
                        ])),
                        if (vehicle.driverPhone.isNotEmpty)
                          IconButton(
                            icon: const Icon(Icons.call, color: Colors.green),
                            onPressed: () => launchUrl(
                              Uri.parse('tel:${vehicle.driverPhone}'))),
                      ]),
                    ]))),
              const SizedBox(height: 10),
            ]);
          }),
        ],
      ]),
    );
  }

  // ?? Tab 2: Live Tracking ?????????
  Widget _liveTrackTab(BuildContext context, TransportProvider p,
      List myTransport) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        // Live status
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05),
              blurRadius: 10)]),
          child: Column(children: [
            Row(children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle),
                child: const Icon(Icons.circle, color: Colors.red, size: 12)),
              const SizedBox(width: 8),
              const Text('LIVE', style: TextStyle(fontWeight: FontWeight.bold,
                color: Colors.red, fontSize: 13)),
              const Spacer(),
              Text('Updated just now',
                style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
            ]),
            const SizedBox(height: 14),
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              _liveStatCard('Speed', '$_busSpeed km/h', Icons.speed, Colors.blue),
              _liveStatCard('ETA', _eta, Icons.timer, Colors.orange),
              _liveStatCard('Status', _busStatus, Icons.directions_bus, Colors.green),
            ]),
          ])),
        const SizedBox(height: 14),

        // Map simulation
        Container(
          height: 280,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: const Color(0xFFE8F5E9)),
          clipBehavior: Clip.antiAlias,
          child: Stack(children: [
            CustomPaint(size: Size.infinite, painter: _RoadPainter()),
            // School marker
            const Positioned(left: 12, top: 12,
              child: Column(children: [
                Icon(Icons.school, color: Colors.red, size: 28),
                Text('School', style: TextStyle(fontSize: 9,
                  fontWeight: FontWeight.bold, color: Colors.red)),
              ])),
            // Bus marker
            LayoutBuilder(builder: (ctx, constraints) {
              final x = (_busLat - 28.61) * 50000 + constraints.maxWidth * 0.5;
              final y = (_busLng - 77.20) * 50000 + constraints.maxHeight * 0.4;
              return Positioned(
                left: x.clamp(20, constraints.maxWidth - 60),
                top: y.clamp(20, constraints.maxHeight - 60),
                child: Column(children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(
                        color: AppTheme.primaryColor.withOpacity(0.4),
                        blurRadius: 10)]),
                    child: const Icon(Icons.directions_bus,
                      color: Colors.white, size: 20)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: [BoxShadow(
                        color: Colors.black.withOpacity(0.1), blurRadius: 4)]),
                    child: Text('$_busSpeed km/h',
                      style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold))),
                ]));
            }),
            // Pickup stop
            const Positioned(right: 20, bottom: 40,
              child: Column(children: [
                Icon(Icons.location_on, color: Colors.green, size: 24),
                Text('Your Stop', style: TextStyle(fontSize: 9,
                  fontWeight: FontWeight.bold, color: Colors.green)),
              ])),
            // Live badge
            Positioned(top: 8, right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black87, borderRadius: BorderRadius.circular(8)),
                child: const Row(children: [
                  Icon(Icons.circle, color: Colors.red, size: 8),
                  SizedBox(width: 4),
                  Text('LIVE', style: TextStyle(color: Colors.white,
                    fontSize: 10, fontWeight: FontWeight.bold)),
                ]))),
          ])),
        const SizedBox(height: 14),

        // ETA Card
        Card(child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            const Icon(Icons.timer, color: Colors.orange, size: 32),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              const Text('Estimated Arrival at Your Stop',
                style: TextStyle(color: Colors.grey, fontSize: 12)),
              Text(_eta, style: const TextStyle(fontSize: 24,
                fontWeight: FontWeight.bold, color: Colors.orange)),
            ])),
            Column(children: [
              Text('${_busLat.toStringAsFixed(4)}, ${_busLng.toStringAsFixed(4)}',
                style: const TextStyle(fontSize: 9, color: Colors.grey)),
              const Text('Current Location',
                style: TextStyle(fontSize: 9, color: Colors.grey)),
            ]),
          ]))),
      ]));
  }

  // ?? Tab 3: Route ???????????
  Widget _routeTab(BuildContext context, TransportProvider p, List myTransport) {
    if (myTransport.isEmpty) return _emptyCard(
 'No Route Assigned', 'Contact admin', Icons.route);

    final route = _getRoute(p, myTransport[0].routeId);
    if (route == null) return _emptyCard('Route not found', '', Icons.route);

    final stops = route.stops.isEmpty ? ['School', 'Stop 1', 'Stop 2', 'Your Stop']
      : route.stops.split(',').map((s) => s.trim()).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        Card(child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(route.routeName,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 4),
            Text('${route.startPoint} • ${route.endPoint}',
              style: const TextStyle(color: Colors.grey, fontSize: 12)),
            const Divider(height: 16),
            Row(children: [
              Expanded(child: _infoBox('Distance', '${route.totalDistance} km', Icons.straighten)),
              Expanded(child: _infoBox('Duration', route.duration.isEmpty ? 'N/A' : route.duration, Icons.timer)),
            ]),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(child: _infoBox('Morning', route.morningTime.isEmpty ? 'N/A' : route.morningTime, Icons.wb_sunny)),
              Expanded(child: _infoBox('Evening', route.eveningTime.isEmpty ? 'N/A' : route.eveningTime, Icons.nights_stay)),
            ]),
          ]))),
        const SizedBox(height: 14),
        const Align(alignment: Alignment.centerLeft,
          child: Text('Bus Stops', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15))),
        const SizedBox(height: 10),
        ...stops.asMap().entries.map((e) {
          final isMyStop = e.value.toLowerCase().contains('your') ||
            e.value == (myTransport[0].pickupStop);
          final isFirst = e.key == 0;
          final isLast = e.key == stops.length - 1;
          return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Column(children: [
              Container(
                width: isMyStop ? 16 : 12, height: isMyStop ? 16 : 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isFirst ? Colors.red
                    : isLast ? Colors.green
                    : isMyStop ? AppTheme.primaryColor : Colors.grey.shade300,
                  border: isMyStop ? Border.all(
                    color: AppTheme.primaryColor, width: 2) : null)),
              if (e.key < stops.length - 1)
                Container(width: 2, height: 40, color: Colors.grey.shade300),
            ]),
            const SizedBox(width: 12),
            Expanded(child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isMyStop
                  ? AppTheme.primaryColor.withOpacity(0.08) : Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: isMyStop
                  ? Border.all(color: AppTheme.primaryColor.withOpacity(0.3)) : null),
              child: Row(children: [
                Expanded(child: Text(e.value,
                  style: TextStyle(fontWeight: isMyStop
                    ? FontWeight.bold : FontWeight.normal))),
                if (isMyStop)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      borderRadius: BorderRadius.circular(6)),
                    child: const Text('YOUR STOP',
                      style: TextStyle(color: Colors.white, fontSize: 9,
                        fontWeight: FontWeight.bold))),
              ]))),
          ]);
        }).toList(),
      ]));
  }

  // ?? Tab 4: Fees ????????????
  Widget _feesTab(BuildContext context, List myFees, TransportProvider p) {
    final pendingFees = myFees.where((f) => f.status == 'pending').toList();
    final paidFees = myFees.where((f) => f.status == 'paid').toList();
    final total = myFees.fold(0.0, (s, f) => s + f.amount);
    final paid = paidFees.fold(0.0, (s, f) => s + f.amount);
    final pending = pendingFees.fold(0.0, (s, f) => s + f.amount);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        // Summary
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [Colors.green.shade600, Colors.green.shade400]),
            borderRadius: BorderRadius.circular(16)),
          child: Column(children: [
            const Text('Fee Summary', style: TextStyle(color: Colors.white70, fontSize: 12)),
            Text('Rs ${total.toStringAsFixed(0)}',
              style: const TextStyle(color: Colors.white, fontSize: 28,
                fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              _feeStatItem('Paid', 'Rs ${paid.toStringAsFixed(0)}', Colors.white),
              Container(width: 1, height: 30, color: Colors.white30),
              _feeStatItem('Pending', 'Rs ${pending.toStringAsFixed(0)}',
                pending > 0 ? Colors.yellow.shade200 : Colors.white),
            ]),
          ])),
        const SizedBox(height: 14),

        // Pay now
        if (pendingFees.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange.withOpacity(0.3))),
            child: Column(children: [
              Row(children: [
                const Icon(Icons.warning_amber, color: Colors.orange),
                const SizedBox(width: 8),
                Text('${pendingFees.length} Pending Payment(s)',
                  style: const TextStyle(fontWeight: FontWeight.bold,
                    color: Colors.orange)),
              ]),
              const SizedBox(height: 10),
              ...pendingFees.map((f) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                  Text(f.month),
                  Text('Rs ${f.amount.toStringAsFixed(0)}',
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                ]))),
              const SizedBox(height: 10),
              SizedBox(width: double.infinity, child: ElevatedButton.icon(
                onPressed: () => _payNow(context, pendingFees),
                icon: const Icon(Icons.payment),
                label: Text('Pay Rs ${pending.toStringAsFixed(0)} Now'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(vertical: 12)))),
            ])),
          const SizedBox(height: 14),
        ],

        // Paid history
        if (paidFees.isNotEmpty) ...[
          const Align(alignment: Alignment.centerLeft,
            child: Text('Payment History',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15))),
          const SizedBox(height: 8),
          ...paidFees.map((f) => Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFE8F5E9),
                child: Icon(Icons.check_circle, color: Colors.green)),
              title: Text(f.month, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(f.paidDate.isEmpty ? 'Paid' : 'Paid: ${f.paidDate}'),
              trailing: Column(mainAxisAlignment: MainAxisAlignment.center,
                children: [
                Text('Rs ${f.amount.toStringAsFixed(0)}',
                  style: const TextStyle(fontWeight: FontWeight.bold,
                    fontSize: 14, color: Colors.green)),
                GestureDetector(
                  onTap: () => _downloadReceipt(context, f),
                  child: const Text('Download',
                    style: TextStyle(fontSize: 11, color: AppTheme.primaryColor,
                      decoration: TextDecoration.underline))),
              ]),
            ))),
        ],

        if (myFees.isEmpty) _emptyCard('No fees added', 'Contact admin', Icons.receipt),
      ]));
  }

  // ?? Tab 5: Support ?????????
  Widget _supportTab(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        const Text('Complaint & Support',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        const SizedBox(height: 12),
        _supportCard(context, 'Report Missing Bus',
 'Bus did not arrive at stop', Icons.directions_bus_filled, Colors.red,
          () => _submitComplaint(context, 'Missing Bus')),
        _supportCard(context, 'Raise Transport Issue',
 'Any transport related problem', Icons.report_problem, Colors.orange,
          () => _submitComplaint(context, 'Transport Issue')),
        _supportCard(context, 'Contact Transport Office',
 'Call transport coordinator', Icons.phone, Colors.blue,
          () => launchUrl(Uri.parse('tel:9999999999'))),
        _supportCard(context, 'Request Stop Change',
 'Request to change pickup/drop stop', Icons.edit_location, Colors.purple,
          () => _submitRequest(context, 'Stop Change Request')),
        _supportCard(context, 'Temporary Cancellation',
 'I will not use bus today/tomorrow', Icons.cancel, Colors.grey,
          () => _submitRequest(context, 'Temporary Cancellation')),
      ]));
  }

  // ?? Tab 6: Attendance (Parent only) ?????????
  Widget _attendanceTab(BuildContext context, TransportProvider p, List myTransport) {
    final history = List.generate(7, (i) {
      final d = DateTime.now().subtract(Duration(days: i));
      return {
        'date': '${d.day.toString().padLeft(2,'0')}/${d.month.toString().padLeft(2,'0')}/${d.year}',
        'boarding': i % 3 != 2 ? 'Present' : 'Absent',
        'drop': i % 4 != 3 ? 'Present' : 'Absent',
      };
    });

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        // Summary
        Row(children: [
          Expanded(child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12)),
            child: Column(children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 28),
              const SizedBox(height: 4),
              const Text('Present', style: TextStyle(color: Colors.green,
                fontWeight: FontWeight.bold, fontSize: 16)),
              Text('${history.where((h) => h['boarding'] == 'Present').length} days',
                style: const TextStyle(color: Colors.grey, fontSize: 11)),
            ]))),
          const SizedBox(width: 10),
          Expanded(child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12)),
            child: Column(children: [
              const Icon(Icons.cancel, color: Colors.red, size: 28),
              const SizedBox(height: 4),
              const Text('Absent', style: TextStyle(color: Colors.red,
                fontWeight: FontWeight.bold, fontSize: 16)),
              Text('${history.where((h) => h['boarding'] == 'Absent').length} days',
                style: const TextStyle(color: Colors.grey, fontSize: 11)),
            ]))),
        ]),
        const SizedBox(height: 16),
        const Align(alignment: Alignment.centerLeft,
          child: Text('Travel History (Last 7 Days)',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15))),
        const SizedBox(height: 8),
        ...history.map((h) => Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(children: [
              Expanded(child: Text(h['date']!,
                style: const TextStyle(fontWeight: FontWeight.w600))),
              _attChip('Board', h['boarding']!),
              const SizedBox(width: 8),
              _attChip('Drop', h['drop']!),
            ])))),
      ]));
  }

  // ?? Dialogs ??????????
  void _payNow(BuildContext context, List pendingFees) {
    final total = pendingFees.fold(0.0, (s, f) => s + (f as TransportFeeModel).amount);
    String payMode = 'upi';

    showDialog(context: context, builder: (ctx) => StatefulBuilder(
      builder: (ctx, setS) => AlertDialog(
        title: const Text('Pay Transport Fee'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12)),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text('Total Amount',
                style: TextStyle(fontWeight: FontWeight.w600)),
              Text('Rs ${total.toStringAsFixed(0)}',
                style: const TextStyle(fontSize: 20,
                  fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
            ])),
          const SizedBox(height: 16),
          const Align(alignment: Alignment.centerLeft,
            child: Text('Payment Method:',
              style: TextStyle(fontWeight: FontWeight.w600))),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(child: GestureDetector(
              onTap: () => setS(() => payMode = 'upi'),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: payMode == 'upi'
                    ? Colors.blue.withOpacity(0.1) : Colors.grey.shade50,
                  border: Border.all(
                    color: payMode == 'upi' ? Colors.blue : Colors.grey.shade300,
                    width: payMode == 'upi' ? 2 : 1),
                  borderRadius: BorderRadius.circular(12)),
                child: Column(children: [
                  Icon(Icons.qr_code,
                    color: payMode == 'upi' ? Colors.blue : Colors.grey, size: 32),
                  const SizedBox(height: 6),
                  Text('UPI / QR', style: TextStyle(fontWeight: FontWeight.bold,
                    color: payMode == 'upi' ? Colors.blue : Colors.grey)),
                  Text('GPay, PhonePe, Paytm', style: TextStyle(fontSize: 10,
                    color: payMode == 'upi' ? Colors.blue.shade300 : Colors.grey)),
                ])))),
            const SizedBox(width: 12),
            Expanded(child: GestureDetector(
              onTap: () => setS(() => payMode = 'cash'),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: payMode == 'cash'
                    ? Colors.green.withOpacity(0.1) : Colors.grey.shade50,
                  border: Border.all(
                    color: payMode == 'cash' ? Colors.green : Colors.grey.shade300,
                    width: payMode == 'cash' ? 2 : 1),
                  borderRadius: BorderRadius.circular(12)),
                child: Column(children: [
                  Icon(Icons.money,
                    color: payMode == 'cash' ? Colors.green : Colors.grey, size: 32),
                  const SizedBox(height: 6),
                  Text('Cash', style: TextStyle(fontWeight: FontWeight.bold,
                    color: payMode == 'cash' ? Colors.green : Colors.grey)),
                  Text('Pay at school', style: TextStyle(fontSize: 10,
                    color: payMode == 'cash' ? Colors.green.shade300 : Colors.grey)),
                ])))),
          ]),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton.icon(
            onPressed: () async {
              Navigator.pop(ctx);
              if (payMode == 'upi') {
                final upiUrl = 'upi://pay?pa=9819117133@kotakbank'
        '&pn=School Transport Fee&am=${total.toStringAsFixed(2)}'
        '&tn=Transport Fee&cu=INR';
                try {
                  await launchUrl(Uri.parse(upiUrl),
                    mode: LaunchMode.externalApplication);
                } catch (_) {
                  if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('No UPI app found'),
                      backgroundColor: Colors.red));
                }
              } else {
                if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please pay cash at school office'),
                    backgroundColor: Colors.orange));
              }
            },
            icon: Icon(payMode == 'upi' ? Icons.qr_code : Icons.money),
            label: Text(payMode == 'upi' ? 'Open UPI App' : 'OK, Will Pay Cash'),
            style: ElevatedButton.styleFrom(
              backgroundColor: payMode == 'upi' ? Colors.blue : Colors.green)),
        ])));
  }

  void _downloadReceipt(BuildContext context, TransportFeeModel f) {
    final receiptNo = 'TRP${f.id}${DateTime.now().year}';
    showDialog(context: context, builder: (ctx) => AlertDialog(
      contentPadding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      content: SizedBox(width: 320, child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: double.infinity, padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(color: AppTheme.primaryColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
          child: Column(children: [
            const Icon(Icons.receipt_long, color: Colors.white, size: 40),
            const SizedBox(height: 8),
            const Text('Transport Fee Receipt',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
            Text('Receipt: $receiptNo',
              style: const TextStyle(color: Colors.white70, fontSize: 11)),
          ])),
        Padding(padding: const EdgeInsets.all(20), child: Column(children: [
          _rRow('Month', f.month),
          _rRow('Amount', 'Rs ${f.amount.toStringAsFixed(0)}'),
          _rRow('Status', 'PAID ?'),
          _rRow('Paid Date', f.paidDate.isEmpty ? 'N/A' : f.paidDate),
          _rRow('Receipt No', receiptNo),
          const SizedBox(height: 12),
          Container(
            width: double.infinity, padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10)),
            child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.verified, color: Colors.green, size: 20),
              SizedBox(width: 8),
              Text('Payment Verified', style: TextStyle(color: Colors.green,
                fontWeight: FontWeight.bold)),
            ])),
        ])),
      ])),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
        ElevatedButton.icon(
          onPressed: () {
            Navigator.pop(ctx);
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Receipt $receiptNo downloaded!'),
              backgroundColor: Colors.green));
          },
          icon: const Icon(Icons.download, size: 16),
          label: const Text('Download')),
      ]));
  }

  void _submitComplaint(BuildContext context, String type) {
    final ctrl = TextEditingController();
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: Text(type),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: ctrl, maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Describe the issue...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)))),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(ctx);
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('$type submitted! Admin will respond soon.'),
              backgroundColor: Colors.green));
          },
          child: const Text('Submit')),
      ]));
  }

  void _submitRequest(BuildContext context, String type) {
    final ctrl = TextEditingController();
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: Text(type),
      content: TextField(controller: ctrl, maxLines: 3,
        decoration: InputDecoration(
          hintText: 'Details...',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)))),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(ctx);
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('$type submitted! Pending approval.'),
              backgroundColor: Colors.orange));
          },
          child: const Text('Submit')),
      ]));
  }

  void _showNotifications(BuildContext context) {
    showModalBottomSheet(context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          Container(width: 40, height: 4,
            decoration: BoxDecoration(color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 12),
          const Text('Notifications',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          _notifItem('Bus delayed by 10 minutes', '2 min ago', Colors.orange),
          _notifItem('Bus departed from school', '30 min ago', Colors.blue),
          _notifItem('Fee due: June 2026', '1 day ago', Colors.red),
          _notifItem('Route updated for tomorrow', '2 days ago', Colors.purple),
        ])));
  }

  // ?? Helpers ??????????
  VehicleModel? _getVehicle(TransportProvider p, int id) {
    try { return p.vehicles.firstWhere((v) => v.id == id); }
    catch (_) { return null; }
  }

  RouteModel? _getRoute(TransportProvider p, int id) {
    try { return p.routes.firstWhere((r) => r.id == id); }
    catch (_) { return null; }
  }

  String _getVehicleNumber(TransportProvider p, int id) =>
    _getVehicle(p, id)?.vehicleNumber ?? 'N/A';

  Widget _busStatItem(String label, String value, IconData icon) =>
    Column(children: [
      Icon(icon, color: Colors.white70, size: 18),
      const SizedBox(height: 4),
      Text(value, style: const TextStyle(color: Colors.white,
        fontWeight: FontWeight.bold, fontSize: 13)),
      Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10)),
    ]);

  Widget _liveStatCard(String label, String value, IconData icon, Color color) =>
    Column(children: [
      Icon(icon, color: color, size: 22),
      const SizedBox(height: 4),
      Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14,
        color: color)),
      Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
    ]);

  Widget _feeStatItem(String label, String value, Color color) =>
    Column(children: [
      Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold,
        fontSize: 16)),
      Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
    ]);

  Widget _detailRow(IconData icon, String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(children: [
      Icon(icon, size: 16, color: Colors.grey),
      const SizedBox(width: 8),
      Text('$label: ', style: const TextStyle(color: Colors.grey, fontSize: 13)),
      Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600,
        fontSize: 13), overflow: TextOverflow.ellipsis)),
    ]));

  Widget _infoBox(String label, String value, IconData icon) => Container(
    margin: const EdgeInsets.only(right: 8, bottom: 8),
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(color: Colors.grey.shade50,
      borderRadius: BorderRadius.circular(10)),
    child: Row(children: [
      Icon(icon, size: 16, color: Colors.grey),
      const SizedBox(width: 6),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
      ]),
    ]));

  Widget _supportCard(BuildContext context, String title, String subtitle,
      IconData icon, Color color, VoidCallback onTap) =>
    Card(margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Container(padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: color.withOpacity(0.1),
            shape: BoxShape.circle),
          child: Icon(icon, color: color)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap));

  Widget _attChip(String label, String status) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: status == 'Present'
        ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
      borderRadius: BorderRadius.circular(6)),
    child: Text('$label: $status',
      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold,
        color: status == 'Present' ? Colors.green : Colors.red)));

  Widget _notifItem(String msg, String time, Color color) => Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: color.withOpacity(0.08),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: color.withOpacity(0.2))),
    child: Row(children: [
      Icon(Icons.notifications, color: color, size: 18),
      const SizedBox(width: 10),
      Expanded(child: Text(msg, style: const TextStyle(fontSize: 13))),
      Text(time, style: const TextStyle(fontSize: 10, color: Colors.grey)),
    ]));

  Widget _emptyCard(String title, String subtitle, IconData icon) =>
    Container(padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(color: Colors.white,
        borderRadius: BorderRadius.circular(16)),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(icon, size: 48, color: Colors.grey.shade300),
        const SizedBox(height: 12),
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        if (subtitle.isNotEmpty) Text(subtitle,
          style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ]));

  Widget _rRow(String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
      Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
    ]));
}

class _RoadPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = const Color(0xFFE8F5E9));
    final road = Paint()..color = Colors.white..strokeWidth = 10..strokeCap = StrokeCap.round;
    for (int i = 1; i < 4; i++) {
      canvas.drawLine(Offset(0, size.height * i / 4),
        Offset(size.width, size.height * i / 4), road);
      canvas.drawLine(Offset(size.width * i / 4, 0),
        Offset(size.width * i / 4, size.height), road);
    }
  }
  @override bool shouldRepaint(covariant CustomPainter old) => false;
}