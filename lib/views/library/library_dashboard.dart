import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/library_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../models/library_model.dart';
import '../../providers/language_provider.dart';

class LibraryDashboard extends StatelessWidget {
  const LibraryDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<LibraryProvider>();
    if (p.isLoading) return const Center(child: CircularProgressIndicator());

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Library Overview', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10,
          childAspectRatio: 1.5,
          children: [
            _stat('Total Books', '${p.totalBooks}',    Icons.menu_book,    const Color(0xFF1565C0)),
            _stat('Issued Books', '${p.issuedBooks}',   Icons.book,         const Color(0xFFE65100)),
            _stat('Available', '${p.availableBooks}',Icons.check_circle, const Color(0xFF2E7D32)),
            _stat('Overdue', '${p.overdueCount}',  Icons.warning,      const Color(0xFFC62828)),
            _stat('Fine Collected', 'Rs ${p.totalFineCollected.toStringAsFixed(0)}', Icons.payments, const Color(0xFF6A1B9A)),
            _stat('Fine Pending', 'Rs ${p.totalFinePending.toStringAsFixed(0)}',   Icons.pending,  const Color(0xFF00838F)),
          ],
        ),
        const SizedBox(height: 16),

        // Overdue books alert
        if (p.overdueIssues.isNotEmpty) ...[
          Row(children: [
            const Icon(Icons.warning_amber, color: Colors.red, size: 20),
            const SizedBox(width: 6),
            Text('${p.overdueIssues.length} Overdue Book(s)',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.red)),
          ]),
          const SizedBox(height: 8),
          ...p.overdueIssues.map((issue) => Card(
            color: Colors.red.shade50,
            margin: const EdgeInsets.only(bottom: 8),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Expanded(child: Text(issue.bookTitle,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                    child: const Text('OVERDUE', style: TextStyle(fontSize: 10, color: Colors.red, fontWeight: FontWeight.bold))),
                ]),
                const SizedBox(height: 6),
                Text('${issue.userName} (${issue.userType.toUpperCase()}) - ${issue.admissionOrEmpId}',
                  style: const TextStyle(fontSize: 12)),
                Text('Due: ${issue.dueDate}  -  ${issue.overdueDays} day(s) overdue',
                  style: const TextStyle(fontSize: 11, color: Colors.red)),
                Text('Fine: Rs ${issue.calculatedFine.toStringAsFixed(0)} (Rs ${2}/day)',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Colors.red)),
              ]),
            ),
          )),
          const SizedBox(height: 16),
        ],

        // Settings card
        const Text('Library Settings', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Card(child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(children: [
            _settingRow('Student Loan Period', '${p.settings.issueDaysForStudent} days'),
            _settingRow('Staff Loan Period', '${p.settings.issueDaysForStaff} days'),
            _settingRow('Max Books (Student)', '${p.settings.maxBooksPerStudent} books'),
            _settingRow('Max Books (Staff)', '${p.settings.maxBooksPerStaff} books'),
            _settingRow('Fine per Day', 'Rs ${p.settings.finePerDay}'),
            _settingRow('Due Reminder', '${p.settings.dueSoonReminderDays} days before'),
            const SizedBox(height: 8),
            SizedBox(width: double.infinity, child: OutlinedButton.icon(
              onPressed: () => _showSettingsDialog(context, p),
              icon: const Icon(Icons.settings, size: 16),
              label: const Text('Update Settings'),
            )),
          ]),
        )),
        const SizedBox(height: 16),

        // Recent activity
        Text(context.watch<LanguageProvider>().t('recent_activity'), style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        ...p.issues.take(5).map((issue) {
          final color = issue.status == 'returned' ? Colors.green
            : issue.isOverdue ? Colors.red : Colors.blue;
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: Icon(issue.status == 'returned' ? Icons.assignment_return
                : issue.isOverdue ? Icons.warning : Icons.book, color: color),
              title: Text(issue.bookTitle, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              subtitle: Text('${issue.userName} - ${issue.issueDate}',
                style: const TextStyle(fontSize: 11)),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: Text(issue.isOverdue && issue.status != 'returned' ? 'OVERDUE' : issue.status.toUpperCase(),
                  style: TextStyle(fontSize: 9, color: color, fontWeight: FontWeight.bold))),
            ),
          );
        }),
      ]),
    );
  }

  Widget _stat(String label, String value, IconData icon, Color color) => Card(
    child: Padding(padding: const EdgeInsets.all(12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Container(padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: color, size: 18)),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
          Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        ]),
      ]),
    ),
  );

  Widget _settingRow(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
    ]),
  );

  void _showSettingsDialog(BuildContext context, LibraryProvider p) {
    int studentDays = p.settings.issueDaysForStudent;
    int staffDays = p.settings.issueDaysForStaff;
    double finePerDay = p.settings.finePerDay;
    int maxStudent = p.settings.maxBooksPerStudent;
    int maxStaff = p.settings.maxBooksPerStaff;
    int reminderDays = p.settings.dueSoonReminderDays;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: const Text('Library Settings'),
          content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
            _numField('Student Loan Days', studentDays, (v) => setS(() => studentDays = v)),
            _numField('Staff Loan Days', staffDays, (v) => setS(() => staffDays = v)),
            _numField('Max Books (Student)', maxStudent, (v) => setS(() => maxStudent = v)),
            _numField('Max Books (Staff)', maxStaff, (v) => setS(() => maxStaff = v)),
            _numField('Fine per Day (Rs)', finePerDay.toInt(), (v) => setS(() => finePerDay = v.toDouble())),
            _numField('Due Reminder (days before)', reminderDays, (v) => setS(() => reminderDays = v)),
          ])),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                p.updateSettings(LibrarySettingsModel(
                  maxBooksPerStudent: maxStudent, maxBooksPerStaff: maxStaff,
                  issueDaysForStudent: studentDays, issueDaysForStaff: staffDays,
                  finePerDay: finePerDay, dueSoonReminderDays: reminderDays,
                ));
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Settings updated!'), backgroundColor: Colors.green));
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _numField(String label, int value, Function(int) onChanged) {
    final ctrl = TextEditingController(text: '$value');
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: ctrl,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(labelText: label),
        onChanged: (v) { if (v.isNotEmpty) onChanged(int.tryParse(v) ?? value); },
      ),
    );
  }
}

