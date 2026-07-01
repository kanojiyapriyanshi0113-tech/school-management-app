import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/attendance_provider.dart';
import '../../providers/language_provider.dart';

class MarkAttendanceScreen extends StatefulWidget {
  const MarkAttendanceScreen({super.key});

  @override
  State<MarkAttendanceScreen> createState() => _MarkAttendanceScreenState();
}

class _MarkAttendanceScreenState extends State<MarkAttendanceScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => context.read<AttendanceProvider>().fetchStudentsForClass());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final provider = context.read<AttendanceProvider>();
    final picked = await showDatePicker(
      context: context,
      initialDate: provider.selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) provider.setDate(picked);
  }

  Future<void> _save() async {
    final provider = context.read<AttendanceProvider>();
    final ok = await provider.saveAttendance();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(ok ? 'Attendance saved!' : 'Already saved for this class & date'),
      backgroundColor: ok ? Colors.green : Colors.orange,
    ));
    if (ok) _tabController.animateTo(1);
  }

  Color _btnColor(AttendanceStatus status, AttendanceStatus current) {
    final active = status == current;
    switch (status) {
      case AttendanceStatus.present:
        return active ? Colors.green : Colors.green.withOpacity(0.12);
      case AttendanceStatus.absent:
        return active ? Colors.red : Colors.red.withOpacity(0.12);
      case AttendanceStatus.late:
        return active ? Colors.orange : Colors.orange.withOpacity(0.12);
    }
  }

  String _label(AttendanceStatus s) =>
      s == AttendanceStatus.present ? 'P' : s == AttendanceStatus.absent ? 'A' : 'L';

  String _backRoute(BuildContext ctx) {
    final role = ctx.read<AuthProvider>().user?.role;
    return role == 'staff'
        ? '/dashboard/staff'
        : role == 'student'
            ? '/dashboard/student'
            : role == 'parent'
                ? '/dashboard/parent'
                : '/dashboard/admin';
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AttendanceProvider>();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => context.go(_backRoute(context)),
        ),
        title: Text(context.watch<LanguageProvider>().t('mark_attendance')),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          tabs: [
            const Tab(text: 'Mark'),
            Tab(text: 'History (${provider.history.length})'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMarkTab(provider),
          _buildHistoryTab(provider),
        ],
      ),
    );
  }

  Widget _buildMarkTab(AttendanceProvider provider) {
    final isSaved = provider.isCurrentAttendanceSaved;

    return provider.isLoading
        ? const Center(child: CircularProgressIndicator())
        : Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Row(
                  children: [
                    // Date button — fixed width so dropdown gets enough space
                    SizedBox(
                      width: 148,
                      child: OutlinedButton.icon(
                        onPressed: isSaved ? null : _pickDate,
                        icon: const Icon(Icons.calendar_today_outlined, size: 16),
                        label: Text(
                          DateFormat('d MMM yyyy').format(provider.selectedDate),
                          style: const TextStyle(fontSize: 13),
                          overflow: TextOverflow.ellipsis,
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Class dropdown — takes remaining space, text ellipsis on overflow
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: provider.selectedClass,
                        isExpanded: true, // KEY FIX: prevents overflow
                        decoration: const InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 11),
                        ),
                        items: AttendanceProvider.classOptions
                            .map((c) => DropdownMenuItem(
                                  value: c,
                                  child: Text(
                                    c,
                                    overflow: TextOverflow.ellipsis, // KEY FIX
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                ))
                            .toList(),
                        onChanged: (v) {
                          if (v != null) context.read<AttendanceProvider>().setClass(v);
                        },
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  _summary('Present', provider.presentCount.toString(), Colors.green),
                  _summary('Absent', provider.absentCount.toString(), Colors.red),
                  _summary('Late', provider.lateCount.toString(), Colors.orange),
                  _summary('Total', provider.totalCount.toString(), AppTheme.primaryColor),
                ],
              ),

              if (isSaved)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.lock_outline, color: Colors.green.shade700, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Saved Attendance — view only',
                        style: TextStyle(
                          color: Colors.green.shade800,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 4),

              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: provider.students.length,
                  itemBuilder: (context, index) {
                    final s = provider.students[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                          child: Text(s.name[0],
                              style: const TextStyle(
                                  color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
                        ),
                        title: Text(s.name,
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                        subtitle: Text(s.rollNo,
                            style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: AttendanceStatus.values
                              .map((status) => Padding(
                                    padding: const EdgeInsets.only(left: 6),
                                    child: InkWell(
                                      onTap: isSaved
                                          ? null
                                          : () => context
                                              .read<AttendanceProvider>()
                                              .markStatus(s.id, status),
                                      borderRadius: BorderRadius.circular(8),
                                      child: Container(
                                        width: 34,
                                        height: 34,
                                        decoration: BoxDecoration(
                                          color: _btnColor(status, s.status),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        alignment: Alignment.center,
                                        child: Text(
                                          _label(status),
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                            color: status == s.status
                                                ? Colors.white
                                                : Colors.black38,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ))
                              .toList(),
                        ),
                      ),
                    );
                  },
                ),
              ),

              if (!isSaved)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _save,
                      child: Text(
                          'Save Attendance  (P: ${provider.presentCount} | A: ${provider.absentCount} | L: ${provider.lateCount})'),
                    ),
                  ),
                ),
            ],
          );
  }

  Widget _buildHistoryTab(AttendanceProvider provider) {
    if (provider.history.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.history, size: 64, color: Colors.grey),
            SizedBox(height: 12),
            Text('No saved attendance yet', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: provider.history.length,
      itemBuilder: (context, index) {
        final rec = provider.history[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(rec.className,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.lock_outline, size: 12, color: Colors.green.shade700),
                          const SizedBox(width: 4),
                          Text('Saved',
                              style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.green.shade700,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(DateFormat('d MMM yyyy').format(rec.date),
                    style: const TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 10),
                Row(children: [
                  _histStat('✅ ${rec.presentCount} Present', Colors.green),
                  const SizedBox(width: 10),
                  _histStat('❌ ${rec.absentCount} Absent', Colors.red),
                  if (rec.lateCount > 0) ...[
                    const SizedBox(width: 10),
                    _histStat('⏰ ${rec.lateCount} Late', Colors.orange),
                  ],
                ]),
                const SizedBox(height: 8),
                const Text('Edit not allowed after saving',
                    style: TextStyle(fontSize: 11, color: Colors.grey, fontStyle: FontStyle.italic)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _histStat(String text, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(text, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600)),
      );

  Widget _summary(String label, String value, Color color) => Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          child: Column(
            children: [
              Text(value,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
              Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
            ],
          ),
        ),
      );
}