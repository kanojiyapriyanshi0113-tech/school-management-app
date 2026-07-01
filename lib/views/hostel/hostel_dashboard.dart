import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/hostel_provider.dart';
import '../../core/theme/app_theme.dart';

class HostelDashboard extends StatelessWidget {
  const HostelDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<HostelProvider>();
    if (p.isLoading) return const Center(child: CircularProgressIndicator());

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Hostel Overview',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),

        // Stats grid
        GridView.count(
          shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10,
          childAspectRatio: 1.5,
          children: [
            _statCard('Total Hostels', '${p.totalHostels}',   Icons.apartment,      const Color(0xFF1565C0)),
            _statCard('Total Rooms', '${p.totalRooms}',     Icons.meeting_room,   const Color(0xFF2E7D32)),
            _statCard('Occupied Rooms', '${p.occupiedRooms}',  Icons.bed,            const Color(0xFFE65100)),
            _statCard('Vacant Rooms', '${p.vacantRooms}',    Icons.door_back_door, const Color(0xFF00838F)),
            _statCard('Total Beds', '${p.totalBeds}',      Icons.single_bed,     const Color(0xFF6A1B9A)),
            _statCard('Occupied Beds', '${p.occupiedBeds}',   Icons.person,         const Color(0xFF0288D1)),
            _statCard('Available Beds', '${p.availableBeds}',  Icons.check_circle,   const Color(0xFF2E7D32)),
            _statCard('Maintenance', '${p.maintenanceRooms}',Icons.build,         const Color(0xFFC62828)),
            _statCard('Boys Hostels', '${p.boysHostels}',    Icons.man,            const Color(0xFF1565C0)),
            _statCard('Girls Hostels', '${p.girlsHostels}',   Icons.woman,          const Color(0xFFE91E63)),
            _statCard('Students', '${p.totalStudents}',  Icons.school,         const Color(0xFF00838F)),
            _statCard('Pending Fees', '₹${p.pendingFees.toStringAsFixed(0)}', Icons.warning, const Color(0xFFC62828)),
          ],
        ),
        const SizedBox(height: 20),

        // Occupancy progress
        const Text('Occupancy Status',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
        const SizedBox(height: 10),
        Card(child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(children: [
            _occupancyBar('Overall Beds',
              p.occupiedBeds, p.totalBeds, AppTheme.primaryColor),
            const SizedBox(height: 12),
            _occupancyBar('Occupied Rooms',
              p.occupiedRooms, p.totalRooms, Colors.orange),
            const SizedBox(height: 12),
            _occupancyBar('Boys Hostel A',
              24, 30, Colors.blue),
            const SizedBox(height: 12),
            _occupancyBar('Girls Hostel B',
              20, 25, Colors.pink),
          ]),
        )),
        const SizedBox(height: 20),

        // Hostel wise summary
        const Text('Hostel-wise Summary',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
        const SizedBox(height: 10),
        ...p.hostels.map((h) => Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: h.type == 'boys'
                ? Colors.blue.withOpacity(0.1)
                : Colors.pink.withOpacity(0.1),
              child: Icon(h.type == 'boys' ? Icons.man : Icons.woman,
                color: h.type == 'boys' ? Colors.blue : Colors.pink)),
            title: Text(h.name,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            subtitle: Text('Warden: ${h.wardenName} ? Floors: ${h.floors}',
              style: const TextStyle(fontSize: 11)),
            trailing: Column(mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text('${h.occupiedRooms}/${h.totalRooms}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const Text('Rooms', style: TextStyle(fontSize: 10, color: Colors.grey)),
            ]),
          ),
        )),
        const SizedBox(height: 20),

        // Pending complaints
        const Text('Pending Complaints',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
        const SizedBox(height: 10),
        Card(child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            _complaintStat('Pending', '${p.complaints.where((c) => c.status == "pending").length}',  Colors.red),
            _complaintStat('Assigned', '${p.complaints.where((c) => c.status == "assigned").length}', Colors.orange),
            _complaintStat('Resolved', '${p.complaints.where((c) => c.status == "resolved").length}', Colors.green),
          ]),
        )),
      ]),
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) => Card(
    child: Padding(padding: const EdgeInsets.all(12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Container(padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: color, size: 18)),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
          Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        ]),
      ]),
    ),
  );

  Widget _occupancyBar(String label, int occupied, int total, Color color) {
    final pct = total > 0 ? occupied / total : 0.0;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: const TextStyle(fontSize: 12)),
        Text('$occupied/$total (${(pct * 100).toStringAsFixed(0)}%)',
          style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.bold)),
      ]),
      const SizedBox(height: 4),
      ClipRRect(borderRadius: BorderRadius.circular(6),
        child: LinearProgressIndicator(value: pct, color: color,
          backgroundColor: color.withOpacity(0.15), minHeight: 8)),
    ]);
  }

  Widget _complaintStat(String label, String val, Color color) => Column(children: [
    Text(val, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
    Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
  ]);
}

