import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'provider_home_screen.dart';
import 'admin_home_screen.dart';
import 'customer_home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _identifierCtrl = TextEditingController();
  final TextEditingController _passwordCtrl = TextEditingController();

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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _identifierCtrl.dispose();
    _passwordCtrl.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final identifier = _identifierCtrl.text.trim();
    final password = _passwordCtrl.text;

    if (identifier.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter email/phone and password')),
      );
      return;
    }

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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to read user data from server')),
        );
        return;
      }

      // Ensure selected tab matches real role
      if (isAdmin && role != 'ADMIN' ||
          isProvider && role != 'PROVIDER' ||
          isCustomer && role != 'CUSTOMER') {
        await AuthService.logout();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Role mismatch (your role is: $role)')),
        );
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Logged in successfully')),
      );

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
          MaterialPageRoute(builder: (_) => AdminHomeScreen(adminUserId: userId)),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unknown role from server: $role')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login error: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 700;
    final cardWidth = isMobile ? size.width * 0.92 : 520.0;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF5F7FF),
              Color(0xFFFDF2F8),
            ],
          ),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: cardWidth),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Material(
                elevation: 12,
                shadowColor: Colors.black12,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(22, 18, 22, 22),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFEAEAF2)),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header
                      Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              color: const Color(0xFFEEF2FF),
                            ),
                            child: const Icon(
                              Icons.car_repair,
                              color: Color(0xFF4F46E5),
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "FixMe",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  "Welcome back",
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 18),

                      // Tabs (modern container)
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF6F7FB),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: TabBar(
                          controller: _tabController,
                          indicatorSize: TabBarIndicatorSize.tab,
                          dividerColor: Colors.transparent,
                          indicator: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
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

                      const SizedBox(height: 18),

                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Login as $_roleTitle",
                          style: const TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          _subtitle,
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: Colors.black54,
                          ),
                        ),
                      ),

                      const SizedBox(height: 14),

                      // Email/Phone
                      TextField(
                        controller: _identifierCtrl,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          labelText: 'Email or phone',
                          prefixIcon: const Icon(Icons.alternate_email),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Password
                      TextField(
                        controller: _passwordCtrl,
                        obscureText: _hidePass,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _submit(),
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            onPressed: () => setState(() => _hidePass = !_hidePass),
                            icon: Icon(
                              _hidePass ? Icons.visibility : Icons.visibility_off,
                            ),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Button
                      SizedBox(
                        width: double.infinity,
                        height: 46,
                        child: _isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : ElevatedButton(
                                onPressed: _submit,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF4F46E5),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                child: const Text(
                                  'Sign in',
                                  style: TextStyle(fontWeight: FontWeight.w800),
                                ),
                              ),
                      ),

                      const SizedBox(height: 12),

                      // Signup link (not for admin)
                      if (!isAdmin)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Don’t have an account? "),
                            TextButton(
                              onPressed: () {
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
    );
  }
}
