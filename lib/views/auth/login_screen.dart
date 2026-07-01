import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../core/theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  static const List<Map<String, String>> _roles = [
    {'value': 'admin', 'label': 'Admin'},
    {'value': 'staff', 'label': 'Staff'},
    {'value': 'student', 'label': 'Student'},
    {'value': 'parent', 'label': 'Parent'},
  ];

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final auth = context.read<AuthProvider>();
    final success = await auth.login(
      _emailController.text.trim(),
      _passwordController.text,
    );
    if (!mounted) return;
    if (success) {
      switch (auth.user?.role) {
        case 'staff':   context.go('/dashboard/staff');   break;
        case 'student': context.go('/dashboard/student'); break;
        case 'parent':  context.go('/dashboard/parent');  break;
        default:        context.go('/dashboard/admin');
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.errorMessage ?? 'Login failed. Please check your credentials.'),
          backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    final loading = context.watch<AuthProvider>().status == AuthStatus.loading;
    final wide = MediaQuery.of(context).size.width > 700;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 24, offset: const Offset(0, 8))],
                ),
                clipBehavior: Clip.antiAlias,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth > 640;
                    final form = _buildForm(loading);
                    if (!isWide) return form;
                    return IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(flex: 4, child: _buildBrandPanel()),
                          Expanded(flex: 6, child: form),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBrandPanel() => Container(
    color: AppTheme.primaryColor,
    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 56, height: 56,
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
          child: const Icon(Icons.school, color: AppTheme.primaryColor, size: 30)),
        const SizedBox(height: 20),
        const Text('School Management\nSystem',
          style: TextStyle(color: Colors.white, fontSize: 22,
            fontWeight: FontWeight.bold, height: 1.3)),
        const SizedBox(height: 6),
        Text('Flutter + Go Backend',
          style: TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 13)),
        const SizedBox(height: 36),
        _feat(Icons.people_outline, 'Student Management'),
        _feat(Icons.event_available_outlined, 'Attendance Tracking'),
        _feat(Icons.payments_outlined, 'Fee Collection'),
        _feat(Icons.description_outlined, 'Exam & Results'),
        _feat(Icons.campaign_outlined, 'Notice Board'),
      ],
    ),
  );

  Widget _feat(IconData icon, String text) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Row(children: [
      Icon(icon, color: Colors.white.withOpacity(0.9), size: 18),
      const SizedBox(width: 10),
      Text(text, style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 13)),
    ]),
  );

  Widget _buildForm(bool loading) => Padding(
    padding: const EdgeInsets.all(40),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('Welcome Back',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor)),
        const SizedBox(height: 4),
        const Text('Sign in to your account',
          style: TextStyle(fontSize: 13, color: Colors.grey)),
        const SizedBox(height: 28),
        const Text('Login As',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 10),
        Consumer<AuthProvider>(
          builder: (context, auth, _) => Row(
            children: _roles.map((r) {
              final selected = auth.selectedRole == r['value'];
              return Expanded(child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: OutlinedButton(
                  onPressed: () => auth.setSelectedRole(r['value']!),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: selected ? AppTheme.primaryColor : Colors.white,
                    foregroundColor: selected ? Colors.white : Colors.black87,
                    side: BorderSide(
                      color: selected ? AppTheme.primaryColor : Colors.grey.shade300),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text(r['label']!,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                ),
              ));
            }).toList(),
          ),
        ),
        const SizedBox(height: 24),
        const Text('Email Address',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            hintText: 'Enter your email',
          ),
        ),
        const SizedBox(height: 20),
        const Text('Password',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          decoration: InputDecoration(
            hintText: 'Enter your password',
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
                size: 20),
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {},
            child: const Text('Forgot Password?',
              style: TextStyle(fontSize: 12)),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: loading ? null : _handleLogin,
            child: loading
              ? const SizedBox(width: 20, height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Text('Sign In',
                  style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ),
      ],
    ),
  );
}