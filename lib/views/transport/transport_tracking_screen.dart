import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'dart:math';
import '../../providers/transport_provider.dart';
import '../../providers/auth_provider.dart';
import '../../core/theme/app_theme.dart';

class TransportTrackingScreen extends StatefulWidget {
  const TransportTrackingScreen({super.key});
  @override
  State<TransportTrackingScreen> createState() => _TransportTrackingScreenState();
}

class _TransportTrackingScreenState extends State<TransportTrackingScreen> {
  Timer? _timer;
  final Random _random = Random();
  int _selectedBusIndex = 0;

  // Simulated bus data
  final List<Map<String, dynamic>> _buses = [
    {
      'id': 1,
      'number': 'MH-12-AB-1234',
      'driver': 'Ravi Kumar',
      'phone': '9876543210',
      'gpsId': 'GPS-001',
      'route': 'Route A - Main Road',
      'lat': 28.6139,
      'lng': 77.2090,
      'speed': 35,
      'status': 'On Route',
      'eta': '8 min',
      'stops': ['School Gate', 'Sector 5', 'Main Market', 'Bus Stand'],
      'currentStop': 1,
      'pickupTime': '7:30 AM',
      'dropTime': '2:00 PM',
      'isPickup': true,
      'passengers': 24,
      'capacity': 40,
    },
    {
      'id': 2,
      'number': 'MH-12-CD-5678',
      'driver': 'Suresh Singh',
      'phone': '9765432109',
      'gpsId': 'GPS-002',
      'route': 'Route B - Highway',
      'lat': 28.6200,
      'lng': 77.2150,
      'speed': 42,
      'status': 'On Route',
      'eta': '12 min',
      'stops': ['School Gate', 'Highway Cross', 'Sector 12', 'Township'],
      'currentStop': 2,
      'pickupTime': '7:45 AM',
      'dropTime': '2:15 PM',
      'isPickup': true,
      'passengers': 31,
      'capacity': 40,
    },
    {
      'id': 3,
      'number': 'MH-12-EF-9012',
      'driver': 'Mohan Verma',
      'phone': '9654321098',
      'gpsId': 'GPS-003',
      'route': 'Route C - City Loop',
      'lat': 28.6080,
      'lng': 77.2200,
      'speed': 28,
      'status': 'Delayed',
      'eta': '18 min',
      'stops': ['School Gate', 'City Center', 'Old Market', 'Lake Road'],
      'currentStop': 0,
      'pickupTime': '8:00 AM',
      'dropTime': '2:30 PM',
      'isPickup': false,
      'passengers': 18,
      'capacity': 35,
    },
  ];

  @override
  void initState() {
    super.initState();
    _startTracking();
  }

  void _startTracking() {
    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (mounted) setState(() {
        for (var bus in _buses) {
          bus['lat'] = (bus['lat'] as double) + (_random.nextDouble() - 0.5) * 0.001;
          bus['lng'] = (bus['lng'] as double) + (_random.nextDouble() - 0.5) * 0.001;
          bus['speed'] = 20 + _random.nextInt(40);
          final etaMins = 5 + _random.nextInt(15);
          bus['eta'] = '$etaMins min';
        }
      });
    });
  }

  @override
  void dispose() { _timer?.cancel(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final role = context.watch<AuthProvider>().user?.role ?? 'student';
    final bus = _buses[_selectedBusIndex];

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      body: Column(children: [
        // Bus selector
        Container(
          color: Colors.white,
          padding: const EdgeInsets.all(12),
          child: Column(children: [
            Row(children: [
              const Icon(Icons.gps_fixed, color: Colors.red, size: 16),
              const SizedBox(width: 6),
              const Text('LIVE', style: TextStyle(color: Colors.red,
                fontWeight: FontWeight.bold, fontSize: 12)),
              const SizedBox(width: 4),
              Text('GPS Tracking - ${_buses.length} Buses Active',
                style: const TextStyle(fontSize: 12, color: Colors.grey)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6)),
                child: const Text('All Systems Online',
                  style: TextStyle(fontSize: 10, color: Colors.green,
                    fontWeight: FontWeight.bold))),
            ]),
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(children: _buses.asMap().entries.map((e) {
                final selected = e.key == _selectedBusIndex;
                final b = e.value;
                return GestureDetector(
                  onTap: () => setState(() => _selectedBusIndex = e.key),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: selected ? AppTheme.primaryColor : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: selected ? AppTheme.primaryColor : Colors.grey.shade300)),
                    child: Column(children: [
                      Text(b['number'], style: TextStyle(
                        fontSize: 11, fontWeight: FontWeight.bold,
                        color: selected ? Colors.white : Colors.black87)),
                      Text('GPS: ${b['gpsId']}', style: TextStyle(
                        fontSize: 9, color: selected ? Colors.white70 : Colors.grey)),
                    ])));
              }).toList()),
            ),
          ])),

        // Map area
        Container(
          height: 220,
          margin: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: const Color(0xFFE8F5E9)),
          clipBehavior: Clip.antiAlias,
          child: Stack(children: [
            // Road grid
            CustomPaint(size: Size.infinite, painter: _RoadPainter()),

            // All bus positions
            ..._buses.asMap().entries.map((e) {
              final b = e.value;
              final isSelected = e.key == _selectedBusIndex;
              return LayoutBuilder(builder: (ctx, constraints) {
                final x = ((b['lat'] as double) - 28.605) * 80000 + constraints.maxWidth * 0.3;
                final y = ((b['lng'] as double) - 77.205) * 80000 + constraints.maxHeight * 0.3;
                return Positioned(
                  left: x.clamp(10, constraints.maxWidth - 50),
                  top: y.clamp(10, constraints.maxHeight - 50),
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedBusIndex = e.key),
                    child: Column(children: [
                      Container(
                        padding: EdgeInsets.all(isSelected ? 8 : 5),
                        decoration: BoxDecoration(
                          color: isSelected ? AppTheme.primaryColor : Colors.orange,
                          shape: BoxShape.circle,
                          boxShadow: [BoxShadow(
                            color: (isSelected ? AppTheme.primaryColor : Colors.orange)
                              .withOpacity(0.4), blurRadius: 8)]),
                        child: Icon(Icons.directions_bus,
                          color: Colors.white, size: isSelected ? 20 : 14)),
                      if (isSelected) Container(
                        margin: const EdgeInsets.only(top: 2),
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: [BoxShadow(
                            color: Colors.black.withOpacity(0.1), blurRadius: 4)]),
                        child: Text('${b['speed']} km/h',
                          style: const TextStyle(fontSize: 8,
                            fontWeight: FontWeight.bold))),
                    ])));
              });
            }).toList(),

            // School
            const Positioned(right: 16, bottom: 16,
              child: Column(children: [
                Icon(Icons.school, color: Colors.red, size: 22),
                Text('School', style: TextStyle(fontSize: 8,
                  fontWeight: FontWeight.bold, color: Colors.red)),
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
                  Text('LIVE GPS', style: TextStyle(color: Colors.white,
                    fontSize: 10, fontWeight: FontWeight.bold)),
                ]))),

            // GPS ID badge
            Positioned(top: 8, left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue.shade800,
                  borderRadius: BorderRadius.circular(8)),
                child: Text('${bus['gpsId']}',
                  style: const TextStyle(color: Colors.white,
                    fontSize: 10, fontWeight: FontWeight.bold)))),
          ])),

        // Bus details
        Expanded(child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(children: [
            // Status card
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(children: [
                  Row(children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.directions_bus,
                        color: AppTheme.primaryColor, size: 28)),
                    const SizedBox(width: 12),
                    Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(bus['number'],
                        style: const TextStyle(fontWeight: FontWeight.bold,
                          fontSize: 16)),
                      Text(bus['route'],
                        style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    ])),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: bus['status'] == 'Delayed'
                          ? Colors.orange.withOpacity(0.1)
                          : Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8)),
                      child: Text(bus['status'],
                        style: TextStyle(
                          color: bus['status'] == 'Delayed'
                            ? Colors.orange : Colors.green,
                          fontWeight: FontWeight.bold, fontSize: 12))),
                  ]),
                  const Divider(height: 16),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                    _statItem('Speed', '${bus['speed']} km/h', Icons.speed, Colors.blue),
                    _statItem('ETA', bus['eta'], Icons.timer, Colors.orange),
                    _statItem('Passengers',
                      '${bus['passengers']}/${bus['capacity']}',
                      Icons.people, Colors.purple),
                    _statItem(bus['isPickup'] ? 'Pickup' : 'Drop',
                      bus['isPickup'] ? bus['pickupTime'] : bus['dropTime'],
                      bus['isPickup'] ? Icons.wb_sunny : Icons.nights_stay,
                      Colors.teal),
                  ]),
                ])),
            ),
            const SizedBox(height: 10),

            // Driver card
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(children: [
                  Row(children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: Colors.teal.withOpacity(0.1),
                      child: Text((bus['driver'] as String)[0],
                        style: const TextStyle(fontSize: 20,
                          fontWeight: FontWeight.bold, color: Colors.teal))),
                    const SizedBox(width: 12),
                    Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(bus['driver'],
                        style: const TextStyle(fontWeight: FontWeight.bold,
                          fontSize: 15)),
                      Row(children: [
                        const Icon(Icons.gps_fixed, size: 12, color: Colors.green),
                        const SizedBox(width: 4),
                        Text('GPS ID: ${bus['gpsId']}',
                          style: const TextStyle(color: Colors.green,
                            fontSize: 11, fontWeight: FontWeight.w500)),
                      ]),
                      Text(bus['phone'],
                        style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    ])),
                    Column(children: [
                      IconButton(
                        onPressed: () => _callDriver(context, bus['phone']),
                        icon: const Icon(Icons.call, color: Colors.green, size: 28),
                        tooltip: 'Call Driver'),
                      const Text('Call', style: TextStyle(fontSize: 10,
                        color: Colors.green)),
                    ]),
                  ]),
                  const Divider(height: 16),
                  Row(children: [
                    Expanded(child: _infoBox('GPS Device', bus['gpsId'],
                      Icons.gps_fixed, Colors.blue)),
                    const SizedBox(width: 8),
                    Expanded(child: _infoBox('Location Update',
                      'Every 3 sec', Icons.refresh, Colors.green)),
                    const SizedBox(width: 8),
                    Expanded(child: _infoBox('Coordinates',
                      '${(bus['lat'] as double).toStringAsFixed(4)},${(bus['lng'] as double).toStringAsFixed(4)}',
                      Icons.location_on, Colors.red)),
                  ]),
                ])),
            ),
            const SizedBox(height: 10),

            // Route stops
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Route Stops',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 12),
                  ...(bus['stops'] as List).asMap().entries.map((e) {
                    final isPast = e.key < (bus['currentStop'] as int);
                    final isCurrent = e.key == (bus['currentStop'] as int);
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Column(children: [
                        Container(
                          width: isCurrent ? 16 : 12,
                          height: isCurrent ? 16 : 12,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isPast ? Colors.green
                              : isCurrent ? AppTheme.primaryColor
                              : Colors.grey.shade300,
                            border: isCurrent ? Border.all(
                              color: AppTheme.primaryColor, width: 2) : null)),
                        if (e.key < (bus['stops'] as List).length - 1)
                          Container(width: 2, height: 36,
                            color: isPast ? Colors.green : Colors.grey.shade200),
                      ]),
                      const SizedBox(width: 12),
                      Expanded(child: Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isCurrent
                              ? AppTheme.primaryColor.withOpacity(0.08)
                              : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            border: isCurrent ? Border.all(
                              color: AppTheme.primaryColor.withOpacity(0.3)) : null),
                          child: Row(children: [
                            Expanded(child: Text(e.value,
                              style: TextStyle(
                                fontWeight: isCurrent
                                  ? FontWeight.bold : FontWeight.normal,
                                color: isPast ? Colors.grey : Colors.black87))),
                            if (isPast)
                              const Icon(Icons.check_circle,
                                color: Colors.green, size: 16),
                            if (isCurrent) Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor,
                                borderRadius: BorderRadius.circular(4)),
                              child: const Text('NOW',
                                style: TextStyle(color: Colors.white,
                                  fontSize: 9, fontWeight: FontWeight.bold))),
                          ])))),
                    ]);
                  }).toList(),
                ])),
            ),
            const SizedBox(height: 10),

            // Admin only — all buses summary
            if (role == 'admin' || role == 'staff') ...[
              const Align(alignment: Alignment.centerLeft,
                child: Text('All Buses Overview',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
              const SizedBox(height: 8),
              ..._buses.map((b) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle),
                    child: const Icon(Icons.directions_bus,
                      color: AppTheme.primaryColor, size: 20)),
                  title: Text(b['number'],
                    style: const TextStyle(fontWeight: FontWeight.bold,
                      fontSize: 13)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Driver: ${b['driver']} | GPS: ${b['gpsId']}',
                      style: const TextStyle(fontSize: 11)),
                    Text('Phone: ${b['phone']}',
                      style: const TextStyle(fontSize: 11, color: Colors.grey)),
                  ]),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text('${b['speed']} km/h',
                      style: const TextStyle(fontWeight: FontWeight.bold,
                        fontSize: 12, color: AppTheme.primaryColor)),
                    Text(b['eta'],
                      style: const TextStyle(fontSize: 10, color: Colors.grey)),
                  ]),
                ))),
            ],
            const SizedBox(height: 16),
          ]),
        )),
      ]),
    );
  }

  void _callDriver(BuildContext context, String phone) {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Call Driver'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.call, color: Colors.green, size: 48),
        const SizedBox(height: 12),
        Text(phone, style: const TextStyle(fontSize: 20,
          fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        const Text('Driver Contact Number',
          style: TextStyle(color: Colors.grey)),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx),
          child: const Text('Cancel')),
        ElevatedButton.icon(
          onPressed: () {
            Navigator.pop(ctx);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Calling $phone...'),
                backgroundColor: Colors.green));
          },
          icon: const Icon(Icons.call),
          label: const Text('Call Now'),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green)),
      ]));
  }

  Widget _statItem(String label, String value, IconData icon, Color color) =>
    Column(children: [
      Icon(icon, color: color, size: 20),
      const SizedBox(height: 4),
      Text(value, style: TextStyle(fontWeight: FontWeight.bold,
        fontSize: 12, color: color)),
      Text(label, style: const TextStyle(fontSize: 9, color: Colors.grey)),
    ]);

  Widget _infoBox(String label, String value, IconData icon, Color color) =>
    Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10)),
      child: Column(children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: 10,
          fontWeight: FontWeight.bold, color: color),
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis),
        Text(label, style: const TextStyle(fontSize: 9, color: Colors.grey),
          textAlign: TextAlign.center),
      ]));
}

class _RoadPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = const Color(0xFFE8F5E9));
    final road = Paint()
      ..color = Colors.white..strokeWidth = 12..strokeCap = StrokeCap.round;
    final dashed = Paint()
      ..color = Colors.yellow.shade200..strokeWidth = 2;
    for (int i = 1; i < 4; i++) {
      canvas.drawLine(Offset(0, size.height * i / 4),
        Offset(size.width, size.height * i / 4), road);
      canvas.drawLine(Offset(size.width * i / 4, 0),
        Offset(size.width * i / 4, size.height), road);
    }
  }
  @override bool shouldRepaint(covariant CustomPainter old) => false;
}

