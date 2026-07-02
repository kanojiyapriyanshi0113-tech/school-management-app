import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/transport_provider.dart';
import '../../core/theme/app_theme.dart';

class RouteManagementScreen extends StatefulWidget {
  const RouteManagementScreen({super.key});
  @override
  State<RouteManagementScreen> createState() => _RouteManagementScreenState();
}

class _RouteManagementScreenState extends State<RouteManagementScreen> {
  @override
  Widget build(BuildContext context) {
    final p = context.watch<TransportProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      body: p.isLoading
        ? const Center(child: CircularProgressIndicator())
        : p.routes.isEmpty
          ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.route, size: 64, color: Colors.grey.shade300),
              const SizedBox(height: 12),
              const Text('No routes found', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () => _addRouteDialog(context),
                icon: const Icon(Icons.add), label: const Text('Add Route')),
            ]))
          : RefreshIndicator(
              onRefresh: () => p.fetchRoutes(),
              child: ListView.builder(
                padding: const EdgeInsets.all(14),
                itemCount: p.routes.length,
                itemBuilder: (ctx, i) => _routeCard(ctx, p.routes[i], p),
              )),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addRouteDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Route')),
    );
  }

  Widget _routeCard(BuildContext context, RouteModel r, TransportProvider p) =>
    Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.route, color: Colors.green)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(r.routeName,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              Text('Code: ${r.routeCode}',
                style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ])),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: r.status == 'active'
                  ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8)),
              child: Text(r.status.toUpperCase(),
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold,
                  color: r.status == 'active' ? Colors.green : Colors.red))),
          ]),
          const Divider(height: 14),
          Row(children: [
            const Icon(Icons.location_on, size: 14, color: Colors.red),
            const SizedBox(width: 4),
            Text(r.startPoint, style: const TextStyle(fontSize: 12)),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 6),
              child: Icon(Icons.arrow_forward, size: 14, color: Colors.grey)),
            const Icon(Icons.location_on, size: 14, color: Colors.green),
            const SizedBox(width: 4),
            Expanded(child: Text(r.endPoint,
              style: const TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis)),
          ]),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(child: _info('Distance', '${r.totalDistance} km')),
            Expanded(child: _info('Duration', r.duration)),
            Expanded(child: _info('Monthly Fee', 'Rs ${r.monthlyFee.toStringAsFixed(0)}')),
          ]),
          const SizedBox(height: 6),
          Row(children: [
            Expanded(child: _info('Morning', r.morningTime.isEmpty ? 'N/A' : r.morningTime)),
            Expanded(child: _info('Evening', r.eveningTime.isEmpty ? 'N/A' : r.eveningTime)),
          ]),
          if (r.stops.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text('Stops: ${r.stops}',
              style: const TextStyle(fontSize: 11, color: Colors.grey)),
          ],
          const SizedBox(height: 8),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red, size: 20),
              onPressed: () async {
                await p.deleteRoute(r.id);
                if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Route deleted'),
                    backgroundColor: Colors.orange));
              }),
          ]),
        ]),
      ),
    );

  void _addRouteDialog(BuildContext context) {
    final _nameCtrl = TextEditingController();
    final _codeCtrl = TextEditingController();
    final _startCtrl = TextEditingController();
    final _endCtrl = TextEditingController();
    final _distCtrl = TextEditingController();
    final _durCtrl = TextEditingController();
    final _morningCtrl = TextEditingController();
    final _eveningCtrl = TextEditingController();
    final _stopsCtrl = TextEditingController();
  
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Route'),
        content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: _nameCtrl,
            decoration: const InputDecoration(labelText: 'Route Name *')),
          const SizedBox(height: 8),
          TextField(controller: _codeCtrl,
            decoration: const InputDecoration(labelText: 'Route Code')),
          const SizedBox(height: 8),
          TextField(controller: _startCtrl,
            decoration: const InputDecoration(labelText: 'Start Point *')),
          const SizedBox(height: 8),
          TextField(controller: _endCtrl,
            decoration: const InputDecoration(labelText: 'End Point *')),
          const SizedBox(height: 8),
          TextField(controller: _distCtrl, keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Distance (km)')),
          const SizedBox(height: 8),
          TextField(controller: _durCtrl,
            decoration: const InputDecoration(labelText: 'Duration (e.g. 45 min)')),
          const SizedBox(height: 8),
          TextField(controller: _morningCtrl,
            decoration: const InputDecoration(labelText: 'Morning Time (e.g. 7:30 AM)')),
          const SizedBox(height: 8),
          TextField(controller: _eveningCtrl,
            decoration: const InputDecoration(labelText: 'Evening Time (e.g. 3:00 PM)')),
          const SizedBox(height: 8),
          TextField(controller: _stopsCtrl,
            decoration: const InputDecoration(
              labelText: 'Stops (comma separated)',
              hintText: 'Stop 1, Stop 2, Stop 3')),

        ])),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (_nameCtrl.text.isEmpty) return;
              Navigator.pop(ctx);
              final ok = await context.read<TransportProvider>().addRoute({
        'route_name': _nameCtrl.text,
        'route_code': _codeCtrl.text,
        'start_point': _startCtrl.text,
        'end_point': _endCtrl.text,
        'total_distance': double.tryParse(_distCtrl.text) ?? 0,
        'duration': _durCtrl.text,
        'morning_time': _morningCtrl.text,
        'evening_time': _eveningCtrl.text,
        'stops': _stopsCtrl.text,
        'monthly_fee': 0,
        'status': 'active',
              });
              if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(ok ? 'Route added!' : 'Failed'),
                  backgroundColor: ok ? Colors.green : Colors.red));
            },
            child: const Text('Add')),
        ]));
  }

  Widget _info(String label, String value) => Column(
    crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
    Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
      overflow: TextOverflow.ellipsis),
  ]);
}