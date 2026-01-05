import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'provider_home_screen.dart';
import 'admin_home_screen.dart';
import 'customer_home_screen.dart';
import 'forgot_password_screen.dart';


class LoginScreen extends StatefulWidget {
  final int initialTab; // 0=Customer, 1=Provider, 2=Admin
  const LoginScreen({super.key, this.initialTab = 0});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  final _identifierCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  bool _isLoading = false;
  bool _hidePass = true;
  late TabController _tabController;

  bool get isCustomer => _tabController.index == 0;
  bool get isProvider => _tabController.index == 1;
  bool get isAdmin => _tabController.index == 2;

  String? get _currentRole {
    if (isCustomer) return 'CUSTOMER';
    if (isProvider) return 'PROVIDER';
    return null; // Admin no signup
  }

  String get _roleTitle {
    if (isAdmin) return "Admin";
    if (isProvider) return "Provider";
    return "Customer";
  }

  String get _subtitle {
    if (isAdmin) return "Sign in with admin credentials";
    if (isProvider) return "Sign in to manage your services";
    return "Sign in to request assistance";
  }

  IconData get _identifierIcon {
    if (isAdmin) return Icons.admin_panel_settings_outlined;
    return Icons.alternate_email;
  }

  String get _identifierLabel {
    if (isAdmin) return "Admin email / phone";
    return "Email or phone";
  }

  @override
  void initState() {
    super.initState();

    final safeIndex = widget.initialTab.clamp(0, 2);
    _tabController = TabController(length: 3, vsync: this, initialIndex: safeIndex);

    _tabController.addListener(() {
      setState(() {}); // update UI labels/subtitle when switching
    });
  }

  @override
  void dispose() {
    _identifierCtrl.dispose();
    _passwordCtrl.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final identifier = _identifierCtrl.text.trim();
    final password = _passwordCtrl.text;

    setState(() => _isLoading = true);

    try {
      await AuthService.login(
        identifier: identifier,
        password: password,
      );

      if (!mounted) return;

      final userId = AuthService.userId;
      final role = AuthService.role;

      if (userId == null || role == null) {
        _snack('Failed to read user data from server');
        return;
      }

      final mismatch =
          (isAdmin && role != 'ADMIN') ||
          (isProvider && role != 'PROVIDER') ||
          (isCustomer && role != 'CUSTOMER');

      if (mismatch) {
        await AuthService.logout();
        _snack('Role mismatch (your role is: $role)');
        return;
      }

      _snack('Logged in successfully');

      if (role == 'CUSTOMER') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => CustomerHomeScreen(userId: userId)),
        );
      } else if (role == 'PROVIDER') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => ProviderHomeScreen(userId: userId)),
        );
      } else if (role == 'ADMIN') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => AdminHomeScreen(adminUserId: userId),
          ),
        );
      } else {
        _snack('Unknown role from server: $role');
      }
    } catch (e) {
      _snack('Login error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  InputDecoration _dec({
    required String label,
    required IconData icon,
    String? hint,
    Widget? suffix,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon),
      suffixIcon: suffix,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 700;
    final cardWidth = isMobile ? size.width * 0.92 : 540.0;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF5F7FF), Color(0xFFFDF2F8)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: cardWidth),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Material(
                  elevation: 14,
                  shadowColor: Colors.black12,
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: const Color(0xFFEAEAF2)),
                    ),
                    child: Form(
                      key: _formKey,
                      child: ListView(
                        shrinkWrap: true,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 54,
                                height: 54,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(18),
                                  gradient: const LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [Color(0xFF4F46E5), Color(0xFF2563EB)],
                                  ),
                                ),
                                child: const Icon(Icons.car_repair, color: Colors.white),
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "FixMe",
                                      style: TextStyle(
                                        fontSize: 18.5,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                    SizedBox(height: 3),
                                    Text(
                                      "Welcome back",
                                      style: TextStyle(color: Colors.black54),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFF6F7FB),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFFEAEAF2)),
                            ),
                            child: TabBar(
                              controller: _tabController,
                              indicatorSize: TabBarIndicatorSize.tab,
                              dividerColor: Colors.transparent,
                              indicator: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                color: Colors.white,
                                border: Border.all(color: const Color(0xFFEAEAF2)),
                              ),
                              labelColor: Colors.black,
                              unselectedLabelColor: Colors.black54,
                              tabs: const [
                                Tab(text: 'Customer'),
                                Tab(text: 'Provider'),
                                Tab(text: 'Admin'),
                              ],
                            ),
                          ),

                          const SizedBox(height: 14),

                          Text(
                            "Login as $_roleTitle",
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
                          ),
                          const SizedBox(height: 4),
                          Text(_subtitle, style: const TextStyle(color: Colors.black54)),

                          const SizedBox(height: 14),

                          TextFormField(
                            controller: _identifierCtrl,
                            textInputAction: TextInputAction.next,
                            decoration: _dec(
                              label: _identifierLabel,
                              icon: _identifierIcon,
                              hint: isAdmin ? 'admin@example.com' : 'name@example.com or 05XXXXXXXX',
                            ),
                            validator: (v) {
                              final t = (v ?? '').trim();
                              if (t.isEmpty) return 'Please enter email/phone';
                              return null;
                            },
                          ),

                          const SizedBox(height: 12),

                          TextFormField(
                            controller: _passwordCtrl,
                            obscureText: _hidePass,
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) => _submit(),
                            decoration: _dec(
                              label: 'Password',
                              icon: Icons.lock_outline,
                              suffix: IconButton(
                                onPressed: _isLoading ? null : () => setState(() => _hidePass = !_hidePass),
                                icon: Icon(_hidePass ? Icons.visibility : Icons.visibility_off),
                              ),
                            ),
                            validator: (v) {
                              final t = (v ?? '');
                              if (t.isEmpty) return 'Please enter password';
                              return null;
                            },
                          ),

                          const SizedBox(height: 10),

                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  isAdmin
                                      ? 'Admin accounts are created by the system.'
                                      : 'New here? Create an account below.',
                                  style: const TextStyle(fontSize: 12.5, color: Colors.black54),
                                ),
                              ),
                              TextButton(
                                onPressed: _isLoading
    ? null
    : () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
        );
      },

                                child: const Text('Forgot?'),
                              ),
                            ],
                          ),

                          const SizedBox(height: 6),

                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: _isLoading
                                ? const Center(child: CircularProgressIndicator())
                                : ElevatedButton(
                                    onPressed: _submit,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF4F46E5),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      elevation: 0,
                                    ),
                                    child: const Text(
                                      'Sign in',
                                      style: TextStyle(fontWeight: FontWeight.w900),
                                    ),
                                  ),
                          ),

                          const SizedBox(height: 10),

                          if (!isAdmin)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text("Don’t have an account? "),
                                TextButton(
                                  onPressed: _isLoading
                                      ? null
                                      : () {
                                          Navigator.pushNamed(
                                            context,
                                            '/signup',
                                            arguments: _currentRole ?? 'CUSTOMER',
                                          );
                                        },
                                  child: Text(
                                    isProvider ? "Create Provider account" : "Create Customer account",
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
