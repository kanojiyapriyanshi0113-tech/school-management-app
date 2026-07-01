import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/library_provider.dart';
import '../../providers/auth_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/language_provider.dart';

class MyBooksScreen extends StatefulWidget {
  const MyBooksScreen({super.key});
  @override
  State<MyBooksScreen> createState() => _MyBooksScreenState();
}

class _MyBooksScreenState extends State<MyBooksScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) =>
      context.read<LibraryProvider>().fetchIssues());
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<LibraryProvider>();
    final user = context.watch<AuthProvider>().user;
    final isAdmin = user?.role == 'admin' || user?.role == 'staff';

    // Admin sees all issues, student/staff sees own
    final allIssues = isAdmin ? p.issues : p.issues.where((i) =>
      i.userId == (user?.id ?? 0)).toList();
    final activeIssues = allIssues.where((i) => i.status == 'issued').toList();
    final returnedIssues = allIssues.where((i) => i.status == 'returned').toList();
    final overdueIssues = allIssues.where((i) => i.isOverdue).toList();

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color(0xFFF0F4F8),
        body: Column(children: [
          // Summary
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(14),
            child: Column(children: [
              if (isAdmin)
                const Text('All Issued Books',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              if (!isAdmin)
                const Text('My Books',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                _statCard('Active', '${activeIssues.length}', Colors.blue),
                _statCard('Overdue', '${overdueIssues.length}', Colors.red),
                _statCard('Returned', '${returnedIssues.length}', Colors.green),
                _statCard('Total Fine',
        'Rs ${allIssues.fold(0.0, (s, i) => s + i.calculatedFine).toStringAsFixed(0)}',
                  Colors.orange),
              ]),
            ]),
          ),
          // Tabs
          TabBar(
            indicatorColor: AppTheme.primaryColor,
            labelColor: AppTheme.primaryColor,
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(text: context.watch<LanguageProvider>().t('active')),
              Tab(text: context.watch<LanguageProvider>().t('overdue')),
              Tab(text: 'History'),
            ],
          ),
          const Divider(height: 1),
          Expanded(child: TabBarView(children: [
            _issueList(activeIssues, 'No active books', context, p, isAdmin),
            _issueList(overdueIssues, 'No overdue books', context, p, isAdmin),
            _issueList(returnedIssues, 'No returned books', context, p, isAdmin),
          ])),
        ]),
      ),
    );
  }

  Widget _issueList(List issues, String emptyMsg, BuildContext context,
      LibraryProvider p, bool isAdmin) {
    if (issues.isEmpty) return Center(child: Column(
      mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.menu_book, size: 48, color: Colors.grey.shade300),
        const SizedBox(height: 8),
        Text(emptyMsg, style: const TextStyle(color: Colors.grey)),
      ]));

    return ListView.builder(
      padding: const EdgeInsets.all(14),
      itemCount: issues.length,
      itemBuilder: (ctx, i) {
        final issue = issues[i];
        final isOverdue = issue.isOverdue;
        final fine = issue.calculatedFine;

        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Book title
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Expanded(child: Text(issue.bookTitle,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  maxLines: 2, overflow: TextOverflow.ellipsis)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: issue.status == 'returned' ? Colors.green.withOpacity(0.1)
                      : isOverdue ? Colors.red.withOpacity(0.1)
                      : Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8)),
                  child: Text(
                    issue.status == 'returned' ? 'RETURNED'
                      : isOverdue ? 'OVERDUE' : 'ISSUED',
                    style: TextStyle(
                      fontSize: 10, fontWeight: FontWeight.bold,
                      color: issue.status == 'returned' ? Colors.green
                        : isOverdue ? Colors.red : Colors.blue))),
              ]),
              const SizedBox(height: 4),
              Text('by ${issue.bookAuthor}',
                style: const TextStyle(fontSize: 12, color: Colors.grey)),

              // User info (admin only)
              if (isAdmin) ...[
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8)),
                  child: Row(children: [
                    const Icon(Icons.person, size: 14, color: Colors.grey),
                    const SizedBox(width: 6),
                    Expanded(child: Text(
        '${issue.userName} (${issue.admissionOrEmpId}) ? ${issue.className}',
                      style: const TextStyle(fontSize: 12),
                      overflow: TextOverflow.ellipsis)),
                  ])),
              ],

              const Divider(height: 14),
              Row(children: [
                Expanded(child: _dateInfo('Issue Date', issue.issueDate, Colors.blue)),
                Expanded(child: _dateInfo('Due Date', issue.dueDate,
                  isOverdue ? Colors.red : Colors.orange)),
                if (issue.returnDate != null)
                  Expanded(child: _dateInfo('Return Date', issue.returnDate!, Colors.green)),
              ]),

              // Fine
              if (fine > 0) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.withOpacity(0.2))),
                  child: Row(children: [
                    const Icon(Icons.warning_amber, color: Colors.red, size: 16),
                    const SizedBox(width: 6),
                    Text('Fine: Rs ${fine.toStringAsFixed(0)}',
                      style: const TextStyle(color: Colors.red,
                        fontWeight: FontWeight.bold, fontSize: 13)),
                    if (issue.finePaid) ...[
                      const Spacer(),
                      const Text('PAID', style: TextStyle(color: Colors.green,
                        fontWeight: FontWeight.bold, fontSize: 11)),
                    ],
                  ])),
              ],

              // Return button
              if (issue.status == 'issued' && isAdmin) ...[
                const SizedBox(height: 10),
                SizedBox(width: double.infinity, child: ElevatedButton.icon(
                  onPressed: () => _returnBook(context, p, issue.id, fine),
                  icon: const Icon(Icons.assignment_return, size: 16),
                  label: Text(fine > 0
                    ? 'Return & Collect Fine (Rs ${fine.toStringAsFixed(0)})'
                    : 'Return Book'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: fine > 0 ? Colors.orange : Colors.green),
                )),
              ],
            ]),
          ),
        );
      },
    );
  }

  void _returnBook(BuildContext context, LibraryProvider p, int issueId, double fine) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Return Book'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          if (fine > 0) Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.08),
              borderRadius: BorderRadius.circular(8)),
            child: Row(children: [
              const Icon(Icons.warning_amber, color: Colors.red),
              const SizedBox(width: 8),
              Expanded(child: Text(
        'Outstanding fine: Rs ${fine.toStringAsFixed(0)}\nCollect before returning?',
                style: const TextStyle(fontSize: 13))),
            ])),
          if (fine == 0)
            const Text('Confirm book return?'),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel')),
          if (fine > 0) OutlinedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await p.returnBook(issueId, collectFine: false);
              if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Book returned (fine pending)'),
                  backgroundColor: Colors.orange));
            },
            child: const Text('Return Without Fine')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await p.returnBook(issueId, collectFine: fine > 0);
              if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(fine > 0
                  ? 'Book returned & fine collected!' : 'Book returned!'),
                  backgroundColor: Colors.green));
            },
            child: Text(fine > 0 ? 'Return & Collect Fine' : 'Confirm Return')),
        ],
      ),
    );
  }

  Widget _statCard(String label, String value, Color color) => Column(children: [
    Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
    Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
  ]);

  Widget _dateInfo(String label, String date, Color color) => Column(
    crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
    Text(date, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
  ]);
}

