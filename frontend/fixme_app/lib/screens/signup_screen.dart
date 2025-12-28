import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class SignupScreen extends StatefulWidget {
  final String initialRole; // 'CUSTOMER' or 'PROVIDER'

  const SignupScreen({super.key, required this.initialRole});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();

  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();

  String _role = 'CUSTOMER';
  String _verificationType = 'EMAIL'; // 'EMAIL' or 'PHONE'
  bool _isLoading = false;

  bool _hidePass = true;
  bool _hideConfirm = true;

  @override
  void initState() {
    super.initState();
    _role = widget.initialRole;
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await AuthService.signup(
        firstName: _firstNameCtrl.text.trim(),
        lastName: _lastNameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        password: _passwordCtrl.text,
        confirmPassword: _confirmPasswordCtrl.text,
        role: _role,
        verificationType: _verificationType,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account created — check email/SMS for verification code'),
        ),
      );

      final identifier = _verificationType == 'EMAIL'
          ? _emailCtrl.text.trim()
          : _phoneCtrl.text.trim();

      Navigator.pushReplacementNamed(
        context,
        '/verify',
        arguments: {
          'identifier': identifier,
          'password': _passwordCtrl.text,
          'role': _role, // CUSTOMER / PROVIDER
        },
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Signup failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String get _roleTitle => _role == 'PROVIDER' ? "Provider" : "Customer";

  String get _subtitle {
    if (_role == 'PROVIDER') return "Create a provider account to offer services";
    return "Create a customer account to request assistance";
  }

  InputDecoration _dec({
    required String label,
    required IconData icon,
    Widget? suffix,
    String? hint,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon),
      suffixIcon: suffix,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 700;
    final cardWidth = isMobile ? size.width * 0.92 : 560.0;

    final verifyByEmail = _verificationType == 'EMAIL';

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
                  child: Form(
                    key: _formKey,
                    child: ListView(
                      shrinkWrap: true,
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
                                Icons.person_add_alt_1,
                                color: Color(0xFF4F46E5),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Create account",
                                    style: TextStyle(
                                      fontSize: 16.5,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    "FixMe • $_roleTitle",
                                    style: const TextStyle(
                                      fontSize: 12.5,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pushReplacementNamed(context, '/login');
                              },
                              child: const Text("Sign in"),
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),
                        Text(
                          _subtitle,
                          style: const TextStyle(fontSize: 12.5, color: Colors.black54),
                        ),

                        const SizedBox(height: 16),

                        // Role selector (chips)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ChoiceChip(
                              label: const Text('Customer'),
                              selected: _role == 'CUSTOMER',
                              onSelected: (_) => setState(() => _role = 'CUSTOMER'),
                            ),
                            const SizedBox(width: 12),
                            ChoiceChip(
                              label: const Text('Provider'),
                              selected: _role == 'PROVIDER',
                              onSelected: (_) => setState(() => _role = 'PROVIDER'),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Names row (responsive)
                        if (!isMobile)
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _firstNameCtrl,
                                  decoration: _dec(label: 'First name', icon: Icons.badge_outlined),
                                  validator: (v) =>
                                      v == null || v.trim().isEmpty ? 'First name is required' : null,
                                  textInputAction: TextInputAction.next,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextFormField(
                                  controller: _lastNameCtrl,
                                  decoration: _dec(label: 'Last name', icon: Icons.badge_outlined),
                                  validator: (v) =>
                                      v == null || v.trim().isEmpty ? 'Last name is required' : null,
                                  textInputAction: TextInputAction.next,
                                ),
                              ),
                            ],
                          )
                        else ...[
                          TextFormField(
                            controller: _firstNameCtrl,
                            decoration: _dec(label: 'First name', icon: Icons.badge_outlined),
                            validator: (v) =>
                                v == null || v.trim().isEmpty ? 'First name is required' : null,
                            textInputAction: TextInputAction.next,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _lastNameCtrl,
                            decoration: _dec(label: 'Last name', icon: Icons.badge_outlined),
                            validator: (v) =>
                                v == null || v.trim().isEmpty ? 'Last name is required' : null,
                            textInputAction: TextInputAction.next,
                          ),
                        ],

                        const SizedBox(height: 12),

                        // Email
                        TextFormField(
                          controller: _emailCtrl,
                          decoration: _dec(
                            label: 'Email',
                            icon: Icons.alternate_email,
                            hint: 'name@example.com',
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) {
                            if (_verificationType == 'EMAIL') {
                              if (v == null || v.trim().isEmpty) return 'Email is required for email verification';
                              if (!v.contains('@')) return 'Invalid email';
                            }
                            return null;
                          },
                          textInputAction: TextInputAction.next,
                        ),

                        const SizedBox(height: 12),

                        // Phone
                        TextFormField(
                          controller: _phoneCtrl,
                          decoration: _dec(
                            label: 'Phone (Israel)',
                            icon: Icons.phone_outlined,
                            hint: '05XXXXXXXX',
                          ),
                          keyboardType: TextInputType.phone,
                          validator: (v) {
                            if (_verificationType == 'PHONE') {
                              if (v == null || v.trim().isEmpty) return 'Phone is required for SMS verification';
                              if (v.trim().length < 9) return 'Invalid phone number';
                            }
                            return null;
                          },
                          textInputAction: TextInputAction.next,
                        ),

                        const SizedBox(height: 16),

                        // Verification method toggle (modern)
                        const Text(
                          'Verification method',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFF6F7FB),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFFEAEAF2)),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => setState(() => _verificationType = 'EMAIL'),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    decoration: BoxDecoration(
                                      color: verifyByEmail ? Colors.white : Colors.transparent,
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: const Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.mail_outline, size: 18),
                                        SizedBox(width: 8),
                                        Text('Email'),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => setState(() => _verificationType = 'PHONE'),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    decoration: BoxDecoration(
                                      color: !verifyByEmail ? Colors.white : Colors.transparent,
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: const Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.sms_outlined, size: 18),
                                        SizedBox(width: 8),
                                        Text('SMS'),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Password
                        TextFormField(
                          controller: _passwordCtrl,
                          obscureText: _hidePass,
                          decoration: _dec(
                            label: 'Password',
                            icon: Icons.lock_outline,
                            suffix: IconButton(
                              onPressed: () => setState(() => _hidePass = !_hidePass),
                              icon: Icon(_hidePass ? Icons.visibility : Icons.visibility_off),
                            ),
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Password is required';
                            if (v.length < 8) return 'At least 8 characters';
                            if (!RegExp(r'[A-Z]').hasMatch(v)) return 'Must contain at least one uppercase letter';
                            if (!RegExp(r'[0-9]').hasMatch(v)) return 'Must contain at least one number';
                            return null;
                          },
                          textInputAction: TextInputAction.next,
                        ),

                        const SizedBox(height: 12),

                        // Confirm Password
                        TextFormField(
                          controller: _confirmPasswordCtrl,
                          obscureText: _hideConfirm,
                          decoration: _dec(
                            label: 'Confirm password',
                            icon: Icons.lock_outline,
                            suffix: IconButton(
                              onPressed: () => setState(() => _hideConfirm = !_hideConfirm),
                              icon: Icon(_hideConfirm ? Icons.visibility : Icons.visibility_off),
                            ),
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Please re-enter password';
                            if (v != _passwordCtrl.text) return 'Passwords do not match';
                            return null;
                          },
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _submit(),
                        ),

                        const SizedBox(height: 18),

                        // Button
                        SizedBox(
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
                                    'Create account',
                                    style: TextStyle(fontWeight: FontWeight.w800),
                                  ),
                                ),
                        ),

                        const SizedBox(height: 10),

                        Center(
                          child: TextButton(
                            onPressed: () {
                              Navigator.pushReplacementNamed(context, '/login');
                            },
                            child: const Text('Already have an account? Sign in'),
                          ),
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
    );
  }
}
