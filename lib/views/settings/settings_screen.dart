import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/language_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/auth_provider.dart';
import '../../core/theme/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    final theme = context.watch<ThemeProvider>();
    final role = context.watch<AuthProvider>().user?.role ?? 'student';

    final backRoute = role == 'admin' ? '/dashboard/admin'
      : role == 'staff' ? '/dashboard/staff'
      : role == 'parent' ? '/dashboard/parent'
      : '/dashboard/student';

    return Scaffold(
      appBar: AppBar(
        title: Text(lang.t('settings')),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => context.go(backRoute)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _sectionHeader(lang.t('change_language'), Icons.language),
          const SizedBox(height: 10),
          Card(child: Column(children: [
            _languageTile(context, lang, 'en', 'English', 'English'),
            const Divider(height: 1),
            _languageTile(context, lang, 'hi', 'हिन्दी', 'Hindi'),
            const Divider(height: 1),
            _languageTile(context, lang, 'mr', 'मराठी', 'Marathi'),
          ])),
          const SizedBox(height: 20),
          _sectionHeader(lang.t('theme'), Icons.palette),
          const SizedBox(height: 10),
          Card(child: ListTile(
            leading: Icon(
              theme.themeMode == ThemeMode.dark ? Icons.dark_mode : Icons.light_mode,
              color: theme.themeMode == ThemeMode.dark ? Colors.indigo : Colors.amber),
            title: Text(theme.themeMode == ThemeMode.dark ? 'Dark Mode' : 'Light Mode'),
            trailing: Switch(
              value: theme.themeMode == ThemeMode.dark,
              onChanged: (_) => theme.toggle()),
          )),
          const SizedBox(height: 20),
          _sectionHeader('App Info', Icons.info_outline),
          const SizedBox(height: 10),
          Card(child: ListTile(
            leading: const Icon(Icons.school, color: AppTheme.primaryColor),
            title: Text(lang.t('app_name')),
            subtitle: const Text('Version 1.0.0'),
          )),
        ],
      ),
    );
  }

  Widget _languageTile(BuildContext context, LanguageProvider lang,
      String code, String nativeName, String engName) {
    final isSelected = lang.langCode == code;
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: isSelected ? AppTheme.primaryColor : Colors.grey.shade100,
        child: Text(nativeName[0],
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey.shade600,
            fontWeight: FontWeight.bold))),
      title: Text(nativeName,
        style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
      subtitle: Text(engName, style: const TextStyle(fontSize: 11)),
      trailing: isSelected
        ? Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              borderRadius: BorderRadius.circular(12)),
            child: const Text('✓',
              style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)))
        : const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: () async {
        await lang.setLanguage(code);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(lang.t('language_changed')),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2)));
        }
      },
    );
  }

  Widget _sectionHeader(String title, IconData icon) => Row(children: [
    Icon(icon, color: AppTheme.primaryColor, size: 18),
    const SizedBox(width: 8),
    Text(title, style: const TextStyle(
      fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.primaryColor)),
  ]);
}