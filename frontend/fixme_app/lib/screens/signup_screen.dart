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
  final _confirmCtrl = TextEditingController();

  String _role = 'CUSTOMER';
  String _verificationType = 'EMAIL'; // EMAIL or PHONE

  bool _loading = false;
  bool _hidePass = true;
  bool _hideConfirm = true;

  double _strength = 0.0; // 0..1

  @override
  void initState() {
    super.initState();
    _role = (widget.initialRole == 'PROVIDER') ? 'PROVIDER' : 'CUSTOMER';
    _passwordCtrl.addListener(_recalcStrength);
  }

  @override
  void dispose() {
    _passwordCtrl.removeListener(_recalcStrength);
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
  String _normalizeILPhone(String input) {
  var p = input.trim().replaceAll(' ', '').replaceAll('-', '');
  if (p.startsWith('+972')) return p;        // already international
  if (p.startsWith('0')) p = p.substring(1); // remove leading 0
  return '+972$p';
}


  bool _isValidIsraeliPhone(String phone) {
  final p = phone.trim().replaceAll(' ', '').replaceAll('-', '');
  final local = RegExp(r'^05\d{8}$');        // 0521234567
  final intl  = RegExp(r'^\+9725\d{8}$');    // +972521234567
  return local.hasMatch(p) || intl.hasMatch(p);
}


  void _recalcStrength() {
    final p = _passwordCtrl.text;
    double s = 0;
    if (p.length >= 8) s += 0.25;
    if (RegExp(r'[A-Z]').hasMatch(p)) s += 0.25;
    if (RegExp(r'[0-9]').hasMatch(p)) s += 0.25;
    if (RegExp(r'[^A-Za-z0-9]').hasMatch(p)) s += 0.25;

    if (s != _strength) setState(() => _strength = s);
  }

  String get _strengthText {
    if (_strength <= 0.25) return 'Weak';
    if (_strength <= 0.50) return 'Fair';
    if (_strength <= 0.75) return 'Good';
    return 'Strong';
  }

  Color get _strengthColor {
    if (_strength <= 0.25) return const Color(0xFFEF4444);
    if (_strength <= 0.50) return const Color(0xFFF59E0B);
    if (_strength <= 0.75) return const Color(0xFF10B981);
    return const Color(0xFF4F46E5);
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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      await AuthService.signup(
        firstName: _firstNameCtrl.text.trim(),
        lastName: _lastNameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        phone: (_verificationType == 'PHONE')
    ? _normalizeILPhone(_phoneCtrl.text)
    : _phoneCtrl.text.trim(),
        password: _passwordCtrl.text,
        confirmPassword: _confirmCtrl.text,
        role: _role,
        verificationType: _verificationType,
      );

      if (!mounted) return;

      _snack('Account created — check email/SMS for the verification code');

      final identifier = _verificationType == 'EMAIL'
          ? _emailCtrl.text.trim()
          : _phoneCtrl.text.trim();

      Navigator.pushReplacementNamed(
  context,
  '/verify',
  arguments: {
    'identifier': identifier,
    'password': _passwordCtrl.text,
    'role': _role,
    'verificationType': _verificationType,
  },
);

    } catch (e) {
      _snack('Signup failed: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Widget _header() {
    return Row(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF4F46E5), Color(0xFF2563EB)],
            ),
          ),
          child: const Icon(Icons.person_add_alt_1, color: Colors.white),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Create account',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 4),
              Text(
                'FixMe • ${_role == 'PROVIDER' ? 'Provider' : 'Customer'}',
                style: const TextStyle(color: Colors.black54),
              ),
            ],
          ),
        ),
        TextButton(
          onPressed: _loading ? null : () => Navigator.pushReplacementNamed(context, '/login'),
          child: const Text('Sign in'),
        ),
      ],
    );
  }

  Widget _roleChips() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ChoiceChip(
          label: const Text('Customer'),
          selected: _role == 'CUSTOMER',
          onSelected: _loading ? null : (_) => setState(() => _role = 'CUSTOMER'),
        ),
        const SizedBox(width: 12),
        ChoiceChip(
          label: const Text('Provider'),
          selected: _role == 'PROVIDER',
          onSelected: _loading ? null : (_) => setState(() => _role = 'PROVIDER'),
        ),
      ],
    );
  }

  Widget _verifyToggle() {
    final byEmail = _verificationType == 'EMAIL';

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF6F7FB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEAEAF2)),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: _loading ? null : () => setState(() => _verificationType = 'EMAIL'),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: byEmail ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
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
              onTap: _loading ? null : () => setState(() => _verificationType = 'PHONE'),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: !byEmail ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
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
    );
  }

  Widget _passwordStrengthBar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: _strength,
            minHeight: 8,
            backgroundColor: const Color(0xFFEAEAF2),
            valueColor: AlwaysStoppedAnimation(_strengthColor),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Text('Strength: ', style: TextStyle(color: Colors.black.withOpacity(0.6))),
            Text(
              _strengthText,
              style: TextStyle(fontWeight: FontWeight.w800, color: _strengthColor),
            ),
            const Spacer(),
            const Text('Use 8+, A-Z, 0-9, symbol', style: TextStyle(fontSize: 12, color: Colors.black54)),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 700;
    final cardWidth = isMobile ? size.width * 0.92 : 580.0;

    final needsEmail = _verificationType == 'EMAIL';
    final needsPhone = _verificationType == 'PHONE';

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
                    padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
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
                          _header(),
                          const SizedBox(height: 10),
                          Text(
                            _role == 'PROVIDER'
                                ? 'Create a provider account to offer services'
                                : 'Create a customer account to request assistance',
                            style: const TextStyle(color: Colors.black54),
                          ),

                          const SizedBox(height: 14),
                          _roleChips(),
                          const SizedBox(height: 16),

                          // Names responsive
                          if (!isMobile)
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _firstNameCtrl,
                                    decoration: _dec(label: 'First name', icon: Icons.badge_outlined),
                                    validator: (v) =>
                                        (v == null || v.trim().isEmpty) ? 'First name is required' : null,
                                    textInputAction: TextInputAction.next,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: TextFormField(
                                    controller: _lastNameCtrl,
                                    decoration: _dec(label: 'Last name', icon: Icons.badge_outlined),
                                    validator: (v) =>
                                        (v == null || v.trim().isEmpty) ? 'Last name is required' : null,
                                    textInputAction: TextInputAction.next,
                                  ),
                                ),
                              ],
                            )
                          else ...[
                            TextFormField(
                              controller: _firstNameCtrl,
                              decoration: _dec(label: 'First name', icon: Icons.badge_outlined),
                              validator: (v) => (v == null || v.trim().isEmpty) ? 'First name is required' : null,
                              textInputAction: TextInputAction.next,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _lastNameCtrl,
                              decoration: _dec(label: 'Last name', icon: Icons.badge_outlined),
                              validator: (v) => (v == null || v.trim().isEmpty) ? 'Last name is required' : null,
                              textInputAction: TextInputAction.next,
                            ),
                          ],

                          const SizedBox(height: 12),

                          TextFormField(
                            controller: _emailCtrl,
                            decoration: _dec(
                              label: 'Email',
                              icon: Icons.alternate_email,
                              hint: 'name@example.com',
                            ),
                            keyboardType: TextInputType.emailAddress,
                            validator: (v) {
                              if (!needsEmail) return null;
                              final t = (v ?? '').trim();
                              if (t.isEmpty) return 'Email is required for email verification';
                              if (!t.contains('@')) return 'Invalid email';
                              return null;
                            },
                            textInputAction: TextInputAction.next,
                          ),

                          const SizedBox(height: 12),

                          TextFormField(
                            controller: _phoneCtrl,
                            decoration: _dec(
                              label: 'Phone (Israel)',
                              icon: Icons.phone_outlined,
                              hint: '0521234567',
                            ),
                            keyboardType: TextInputType.phone,
                            validator: (v) {
                              if (!needsPhone) return null;
                              final t = (v ?? '').trim();
                              if (t.isEmpty) return 'Phone is required for SMS verification';
                              if (!_isValidIsraeliPhone(t)) return 'Enter 0521234567 or +972521234567';
                              return null;
                            },
                            textInputAction: TextInputAction.next,
                          ),

                          const SizedBox(height: 16),

                          const Text('Verification method', style: TextStyle(fontWeight: FontWeight.w900)),
                          const SizedBox(height: 10),
                          _verifyToggle(),

                          const SizedBox(height: 16),

                          TextFormField(
                            controller: _passwordCtrl,
                            obscureText: _hidePass,
                            decoration: _dec(
                              label: 'Password',
                              icon: Icons.lock_outline,
                              suffix: IconButton(
                                onPressed: _loading ? null : () => setState(() => _hidePass = !_hidePass),
                                icon: Icon(_hidePass ? Icons.visibility : Icons.visibility_off),
                              ),
                            ),
                            validator: (v) {
                              final p = v ?? '';
                              if (p.isEmpty) return 'Password is required';
                              if (p.length < 8) return 'At least 8 characters';
                              if (!RegExp(r'[A-Z]').hasMatch(p)) return 'Must contain at least one uppercase letter';
                              if (!RegExp(r'[0-9]').hasMatch(p)) return 'Must contain at least one number';
                              return null;
                            },
                            textInputAction: TextInputAction.next,
                          ),

                          const SizedBox(height: 10),
                          _passwordStrengthBar(),
                          const SizedBox(height: 12),

                          TextFormField(
                            controller: _confirmCtrl,
                            obscureText: _hideConfirm,
                            decoration: _dec(
                              label: 'Confirm password',
                              icon: Icons.lock_outline,
                              suffix: IconButton(
                                onPressed: _loading ? null : () => setState(() => _hideConfirm = !_hideConfirm),
                                icon: Icon(_hideConfirm ? Icons.visibility : Icons.visibility_off),
                              ),
                            ),
                            validator: (v) {
                              final c = v ?? '';
                              if (c.isEmpty) return 'Please re-enter password';
                              if (c != _passwordCtrl.text) return 'Passwords do not match';
                              return null;
                            },
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) => _submit(),
                          ),

                          const SizedBox(height: 18),

                          SizedBox(
                            height: 48,
                            child: _loading
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
                                      'Create account',
                                      style: TextStyle(fontWeight: FontWeight.w900),
                                    ),
                                  ),
                          ),

                          const SizedBox(height: 10),

                          Center(
                            child: TextButton(
                              onPressed: _loading ? null : () => Navigator.pushReplacementNamed(context, '/login'),
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
      ),
    );
  }
}
