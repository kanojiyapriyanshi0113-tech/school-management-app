import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/notice_provider.dart';
import '../../providers/auth_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/language_provider.dart';

class NoticeBoardScreen extends StatefulWidget {
  const NoticeBoardScreen({super.key});
  @override
  State<NoticeBoardScreen> createState() => _NoticeBoardScreenState();
}

class _NoticeBoardScreenState extends State<NoticeBoardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NoticeProvider>().fetchNotices();
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<NoticeProvider>();
    final role = context.watch<AuthProvider>().user?.role;
    final canCreate = role == 'admin' || role == 'staff';

    return Scaffold(
      appBar: AppBar(
        title: Text(context.watch<LanguageProvider>().t('notices')),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () {
            final r = context.read<AuthProvider>().user?.role;
            context.go(r == 'staff' ? '/dashboard/staff'
              : r == 'student' ? '/dashboard/student'
              : r == 'parent' ? '/dashboard/parent'
              : '/dashboard/admin');
          },
        ),
      ),
      // Sirf admin aur staff ko New Notice button dikhega
      floatingActionButton: canCreate
        ? FloatingActionButton.extended(
            onPressed: () => context.go('/notices/create'),
            icon: const Icon(Icons.add),
            label: const Text('New Notice'),
            backgroundColor: AppTheme.primaryColor,
          )
        : null,
      body: p.isLoading
        ? const Center(child: CircularProgressIndicator())
        : p.notices.isEmpty
          ? const Center(child: Text('No notices', style: TextStyle(color: Colors.grey)))
          : ListView.builder(
              padding: const EdgeInsets.all(14),
              itemCount: p.notices.length,
              itemBuilder: (context, i) {
                final n = p.notices[i];
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Expanded(child: Text(n.title,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8)),
                          child: const Text('ALL',
                            style: TextStyle(fontSize: 10, color: AppTheme.primaryColor,
                              fontWeight: FontWeight.bold))),
                      ]),
                      const SizedBox(height: 4),
                      Text(n.date, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                      const SizedBox(height: 6),
                      Text(n.description, style: const TextStyle(fontSize: 13)),
                    ]),
                  ),
                );
              },
            ),
    );
  }
}

