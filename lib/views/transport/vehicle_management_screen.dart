import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/transport_provider.dart';
import '../../core/theme/app_theme.dart';

class VehicleManagementScreen extends StatefulWidget {
  const VehicleManagementScreen({super.key});
  @override
  State<VehicleManagementScreen> createState() => _VehicleManagementScreenState();
}

class _VehicleManagementScreenState extends State<VehicleManagementScreen> {
  final _search = TextEditingController();
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final p = context.watch<TransportProvider>();
    final vehicles = _query.isEmpty ? p.vehicles
      : p.vehicles.where((v) =>
          v.vehicleNumber.toLowerCase().contains(_query.toLowerCase()) ||
          v.driverName.toLowerCase().contains(_query.toLowerCase())).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      body: Column(children: [
        // Search
        Padding(
          padding: const EdgeInsets.all(14),
          child: TextField(
            controller: _search,
            decoration: InputDecoration(
              hintText: 'Search vehicle...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _query.isNotEmpty
                ? IconButton(icon: const Icon(Icons.clear),
                    onPressed: () => setState(() { _search.clear(); _query = ''; }))
                : null,
              filled: true, fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none)),
            onChanged: (v) => setState(() => _query = v),
          )),

        // Stats
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(children: [
            _chip('Total: ${p.vehicles.length}', Colors.blue),
            const SizedBox(width: 8),
            _chip('Active: ${p.vehicles.where((v) => v.status == "active").length}', Colors.green),
            const SizedBox(width: 8),
            _chip('Inactive: ${p.vehicles.where((v) => v.status != "active").length}', Colors.orange),
          ])),
        const SizedBox(height: 8),

        // List
        Expanded(child: p.isLoading
          ? const Center(child: CircularProgressIndicator())
          : vehicles.isEmpty
            ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.directions_bus, size: 64, color: Colors.grey.shade300),
                const SizedBox(height: 12),
                const Text('No vehicles found', style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () => _addVehicleDialog(context),
                  icon: const Icon(Icons.add), label: const Text('Add Vehicle')),
              ]))
            : RefreshIndicator(
                onRefresh: () => p.fetchVehicles(),
                child: ListView.builder(
                  padding: const EdgeInsets.all(14),
                  itemCount: vehicles.length,
                  itemBuilder: (ctx, i) => _vehicleCard(ctx, vehicles[i], p),
                ))),
      ]),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addVehicleDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Vehicle')),
    );
  }

  Widget _vehicleCard(BuildContext context, VehicleModel v, TransportProvider p) =>
    Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.directions_bus, color: AppTheme.primaryColor)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(v.vehicleNumber,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              Text('${v.vehicleType} • ${v.seatingCapacity} seats',
                style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ])),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: v.status == 'active'
                  ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8)),
              child: Text(v.status.toUpperCase(),
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold,
                  color: v.status == 'active' ? Colors.green : Colors.red))),
          ]),
          const Divider(height: 14),
          Row(children: [
            Expanded(child: _info('Driver', v.driverName.isEmpty ? 'Not assigned' : v.driverName)),
            Expanded(child: _info('Phone', v.driverPhone.isEmpty ? 'N/A' : v.driverPhone)),
          ]),
          const SizedBox(height: 6),
          Row(children: [
            Expanded(child: _info('Route', v.assignedRoute.isEmpty ? 'Not assigned' : v.assignedRoute)),
            Expanded(child: _info('Fuel', v.fuelType)),
          ]),
          const SizedBox(height: 6),
          Row(children: [
            Expanded(child: _info('Insurance', v.insuranceExpiry.isEmpty ? 'N/A' : v.insuranceExpiry)),
            Expanded(child: _info('Fitness', v.fitnessExpiry.isEmpty ? 'N/A' : v.fitnessExpiry)),
          ]),
          const SizedBox(height: 8),
          Row(children: [
            if (v.gpsEnabled) const Icon(Icons.gps_fixed, size: 14, color: Colors.green),
            if (v.gpsEnabled) const SizedBox(width: 4),
            if (v.gpsEnabled) const Text('GPS', style: TextStyle(fontSize: 11, color: Colors.green)),
            if (v.isAC) const SizedBox(width: 8),
            if (v.isAC) const Icon(Icons.ac_unit, size: 14, color: Colors.blue),
            if (v.isAC) const Text(' AC', style: TextStyle(fontSize: 11, color: Colors.blue)),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red, size: 20),
              onPressed: () => _deleteVehicle(context, v, p)),
          ]),
        ]),
      ),
    );

  void _deleteVehicle(BuildContext context, VehicleModel v, TransportProvider p) {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Delete Vehicle'),
      content: Text('Delete ${v.vehicleNumber}?'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () async {
            Navigator.pop(ctx);
            await p.deleteVehicle(v.id);
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: const Text('Delete')),
      ]));
  }

  void _addVehicleDialog(BuildContext context) {
    final _numCtrl = TextEditingController();
    final _driverCtrl = TextEditingController();
    final _phoneCtrl = TextEditingController();
    final _licenseCtrl = TextEditingController();
    final _routeCtrl = TextEditingController();
    final _capacityCtrl = TextEditingController(text: '40');
    String _type = 'Bus';
    String _fuel = 'Diesel';
    bool _ac = false;
    bool _gps = true;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: const Text('Add Vehicle'),
          content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(controller: _numCtrl,
              decoration: const InputDecoration(labelText: 'Vehicle Number *', prefixIcon: Icon(Icons.directions_bus))),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _type,
              decoration: const InputDecoration(labelText: 'Vehicle Type'),
              items: ['Bus', 'Mini Bus', 'Van', 'Auto']
                .map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
              onChanged: (v) => setS(() => _type = v!)),
            const SizedBox(height: 10),
            TextField(controller: _capacityCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Seating Capacity', prefixIcon: Icon(Icons.event_seat))),
            const SizedBox(height: 10),
            TextField(controller: _driverCtrl,
              decoration: const InputDecoration(labelText: 'Driver Name', prefixIcon: Icon(Icons.person))),
            const SizedBox(height: 10),
            TextField(controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'Driver Phone', prefixIcon: Icon(Icons.phone))),
            const SizedBox(height: 10),
            TextField(controller: _licenseCtrl,
              decoration: const InputDecoration(labelText: 'License Number', prefixIcon: Icon(Icons.badge))),
            const SizedBox(height: 10),
            TextField(controller: _routeCtrl,
              decoration: const InputDecoration(labelText: 'Assigned Route', prefixIcon: Icon(Icons.route))),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _fuel,
              decoration: const InputDecoration(labelText: 'Fuel Type'),
              items: ['Diesel', 'Petrol', 'CNG', 'Electric']
                .map((f) => DropdownMenuItem(value: f, child: Text(f))).toList(),
              onChanged: (v) => setS(() => _fuel = v!)),
            const SizedBox(height: 8),
            Row(children: [
              Checkbox(value: _ac, onChanged: (v) => setS(() => _ac = v!)),
              const Text('AC'),
              const SizedBox(width: 16),
              Checkbox(value: _gps, onChanged: (v) => setS(() => _gps = v!)),
              const Text('GPS'),
            ]),
          ])),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                if (_numCtrl.text.isEmpty) return;
                Navigator.pop(ctx);
                final ok = await context.read<TransportProvider>().addVehicle({
        'vehicle_number': _numCtrl.text,
        'vehicle_type': _type,
        'seating_capacity': int.tryParse(_capacityCtrl.text) ?? 40,
        'driver_name': _driverCtrl.text,
        'driver_phone': _phoneCtrl.text,
        'driver_license': _licenseCtrl.text,
        'assigned_route': _routeCtrl.text,
        'fuel_type': _fuel,
        'is_ac': _ac,
        'gps_enabled': _gps,
        'status': 'active',
                });
                if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(ok ? 'Vehicle added!' : 'Failed'),
                    backgroundColor: ok ? Colors.green : Colors.red));
              },
              child: const Text('Add')),
          ])));
  }

  Widget _info(String label, String value) => Column(
    crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
    Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
      overflow: TextOverflow.ellipsis),
  ]);

  Widget _chip(String label, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
    child: Text(label, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.bold)));
}