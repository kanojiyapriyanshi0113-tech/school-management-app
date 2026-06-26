import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/transport_provider.dart';
import '../../core/theme/app_theme.dart';

class TransportDashboard extends StatelessWidget {
  const TransportDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<TransportProvider>();

    return RefreshIndicator(
      onRefresh: () => p.fetchAll(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          // Stats Grid
          GridView.count(
            crossAxisCount: 3, shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 8, mainAxisSpacing: 8,
            childAspectRatio: 1.6,
            children: [
              _statCard('Total Buses', '${p.totalVehicles}',
                Icons.directions_bus, Colors.blue),
              _statCard('Active', '${p.activeVehicles}',
                Icons.check_circle, Colors.green),
              _statCard('Maintenance', '${p.maintenanceCount}',
                Icons.build, Colors.orange),
              _statCard('Routes', '${p.totalRoutes}',
                Icons.route, Colors.purple),
              _statCard('Students', '${p.studentsWithTransport}',
                Icons.school, Colors.teal),
              _statCard('Drivers', '${p.totalVehicles}',
                Icons.person, Colors.indigo),
            ]),
          const SizedBox(height: 16),

          // Fee Summary
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                AppTheme.primaryColor, Colors.blue.shade700]),
              borderRadius: BorderRadius.circular(16)),
            child: Row(children: [
              const Icon(Icons.account_balance_wallet,
                color: Colors.white, size: 32),
              const SizedBox(width: 14),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Transport Fee Summary',
                  style: TextStyle(color: Colors.white70, fontSize: 12)),
                Text('Rs ${p.totalFeeCollected.toStringAsFixed(0)} collected',
                  style: const TextStyle(color: Colors.white,
                    fontSize: 18, fontWeight: FontWeight.bold)),
                Text('Rs ${p.totalFeePending.toStringAsFixed(0)} pending',
                  style: const TextStyle(color: Colors.white70, fontSize: 12)),
              ])),
            ])),
          const SizedBox(height: 16),

          // Vehicles Status
          _sectionTitle('Fleet Status'),
          const SizedBox(height: 8),
          if (p.vehicles.isEmpty)
            _emptyCard('No vehicles added', Icons.directions_bus)
          else
            ...p.vehicles.map((v) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _statusColor(v.status).withOpacity(0.1),
                    shape: BoxShape.circle),
                  child: Icon(Icons.directions_bus,
                    color: _statusColor(v.status))),
                title: Text(v.vehicleNumber,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(
 '${v.vehicleType} • ${v.driverName.isEmpty ? "No driver" : v.driverName}'),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center, children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: _statusColor(v.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8)),
                    child: Text(v.status.toUpperCase(),
                      style: TextStyle(fontSize: 10,
                        color: _statusColor(v.status),
                        fontWeight: FontWeight.bold))),
                  Text('${v.seatingCapacity} seats',
                    style: const TextStyle(fontSize: 10, color: Colors.grey)),
                ]),
              ))),
          const SizedBox(height: 16),

          // Routes
          _sectionTitle('Active Routes'),
          const SizedBox(height: 8),
          if (p.routes.isEmpty)
            _emptyCard('No routes added', Icons.route)
          else
            ...p.routes.map((r) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.route, color: Colors.green, size: 20)),
                  const SizedBox(width: 12),
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(r.routeName,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text('${r.startPoint} • ${r.endPoint}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ])),
                  Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    Text('Rs ${r.monthlyFee.toStringAsFixed(0)}/mo',
                      style: const TextStyle(
                        color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
                    Text('${r.totalDistance} km',
                      style: const TextStyle(fontSize: 11, color: Colors.grey)),
                  ]),
                ]),
              ))),
        ]),
      ),
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) =>
    Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.15))),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: 18,
          fontWeight: FontWeight.bold, color: color)),
        Text(label, style: const TextStyle(fontSize: 9, color: Colors.grey),
          textAlign: TextAlign.center),
      ]));

  Widget _sectionTitle(String title) => Text(title,
    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold));

  Widget _emptyCard(String msg, IconData icon) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white, borderRadius: BorderRadius.circular(12)),
    child: Row(children: [
      Icon(icon, color: Colors.grey.shade300, size: 32),
      const SizedBox(width: 12),
      Text(msg, style: const TextStyle(color: Colors.grey)),
    ]));

  Color _statusColor(String status) {
    switch (status) {
      case 'active': return Colors.green;
      case 'maintenance': return Colors.orange;
      default: return Colors.red;
    }
  }
}