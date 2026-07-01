import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/library_provider.dart';
import 'library_dashboard.dart';
import 'book_management_screen.dart';
import 'issue_book_screen.dart';
import 'return_book_screen.dart';
import 'my_books_screen.dart';
import 'library_notifications_screen.dart';
import 'library_reports_screen.dart';
import '../../providers/language_provider.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});
  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late bool isAdmin;

  @override
  void initState() {
    super.initState();
    final role = context.read<AuthProvider>().user?.role;
    isAdmin = role == 'admin';
    // Admin: 7 tabs, Staff: 6 tabs, Student/Parent: 4 tabs
    final tabCount = isAdmin ? 7 : 4;
    _tabController = TabController(length: tabCount, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LibraryProvider>().fetchAll();
    });
  }

  @override
  void dispose() { _tabController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final role = context.watch<AuthProvider>().user?.role;
    final isAdminRole = role == 'admin';
    final isStaff = role == 'staff';
    final unread = context.watch<LibraryProvider>().unreadNotifications.length;

    List<Tab> tabs;
    List<Widget> screens;

    if (isAdminRole) {
      tabs = const [
        Tab(text: 'Dashboard'),
        Tab(text: 'Books'),
        Tab(text: 'Issue Book'),
        Tab(text: 'Return Book'),
        Tab(text: 'Issued History'),
        Tab(text: 'Notifications'),
        Tab(text: 'Reports'),
      ];
      screens = const [
        LibraryDashboard(),
        BookManagementScreen(),
        IssueBookScreen(),
        ReturnBookScreen(),
        MyBooksScreen(),
        LibraryNotificationsScreen(),
        LibraryReportsScreen(),
      ];
    } else if (isStaff) {
      tabs = const [
        Tab(text: 'Browse Books'),
        Tab(text: 'Issue Book'),
        Tab(text: 'My Books'),
        Tab(text: 'Notifications'),
      ];
      screens = const [
        BookManagementScreen(),
        IssueBookScreen(),
        MyBooksScreen(),
        LibraryNotificationsScreen(),
      ];
    } else {
      // Student / Parent
      tabs = const [
        Tab(text: 'Browse Books'),
        Tab(text: 'Issue Book'),
        Tab(text: 'My Books'),
        Tab(text: 'Notifications'),
      ];
      screens = const [
        BookManagementScreen(),
        IssueBookScreen(),
        MyBooksScreen(),
        LibraryNotificationsScreen(),
      ];
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(context.watch<LanguageProvider>().t('library')),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () {
            context.go(role == 'student' ? '/dashboard/student'
              : role == 'staff' ? '/dashboard/staff'
              : role == 'parent' ? '/dashboard/parent'
              : '/dashboard/admin');
          },
        ),
        actions: [
          Stack(children: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              onPressed: () => _tabController.animateTo(tabs.length - 1)),
            if (unread > 0) Positioned(right: 8, top: 8,
              child: Container(
                width: 16, height: 16,
                decoration: const BoxDecoration(
                  color: Colors.red, shape: BoxShape.circle),
                child: Center(child: Text('$unread',
                  style: const TextStyle(color: Colors.white,
                    fontSize: 10, fontWeight: FontWeight.bold))))),
          ]),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: tabs,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: screens,
      ),
    );
  }
}

