import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'add_car_screen.dart';

class VerifyScreen extends StatefulWidget {
  const VerifyScreen({super.key});

  @override
  State<VerifyScreen> createState() => _VerifyScreenState();
}

class _VerifyScreenState extends State<VerifyScreen> {
  final _codeCtrl = TextEditingController();
  bool _isLoading = false;

  String? _identifier; // email or phone
  String? _password;   // signup password (for auto-login)
  String? _role;       // CUSTOMER / PROVIDER

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) {
      _identifier = args['identifier'] as String?;
      _password = args['password'] as String?;
      _role = args['role'] as String?;
    }
  }

  @override
  void dispose() {
    _codeCtrl.dispose();
    super.dispose();
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _submit() async {
    final code = _codeCtrl.text.trim();

    if (code.isEmpty) {
      _snack('Please enter the verification code.');
      return;
    }

    if (_identifier == null || _password == null || _role == null) {
      _snack('Missing signup data (identifier/password/role).');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1) Verify only
      await AuthService.verify(code);

      // 2) Provider: don’t login automatically
      if (_role == 'PROVIDER') {
        _snack('Account verified. Your provider account will be activated after admin approval.');
        if (!mounted) return;

        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
        return;
      }

      // 3) Customer: auto-login
      await AuthService.login(
        identifier: _identifier!,
        password: _password!,
      );

      final userId = AuthService.userId;
      final backendRole = AuthService.role;

      if (userId == null || backendRole == null) {
        _snack('Failed to get user data after verification.');
        return;
      }

      _snack('Verified and logged in successfully.');

      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => AddCarScreen(userId: userId)),
        (route) => false,
      );
    } catch (e) {
      _snack('Verification failed: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final accountText = (_identifier != null && _identifier!.isNotEmpty)
        ? _identifier!
        : 'your account';

    final subtitle = (_role == 'PROVIDER')
        ? 'Enter the code to verify your account. Providers require admin approval after verification.'
        : 'Enter the code to verify your account. After verification, you will be logged in automatically.';

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF5F7FF), Color(0xFFFFFBEB)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            child: Column(
              children: [
                // Header card
                Material(
                  elevation: 10,
                  shadowColor: Colors.black12,
                  borderRadius: BorderRadius.circular(22),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: const Color(0xFFEAEAF2)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            color: const Color(0xFFEFF6FF),
                          ),
                          child: const Icon(Icons.verified_outlined, color: Color(0xFF2563EB)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Verify your account',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Code sent to: $accountText',
                                style: const TextStyle(color: Colors.black54),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // Body card
                Expanded(
                  child: Material(
                    elevation: 10,
                    shadowColor: Colors.black12,
                    borderRadius: BorderRadius.circular(22),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: const Color(0xFFEAEAF2)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            subtitle,
                            style: const TextStyle(color: Colors.black54),
                          ),
                          const SizedBox(height: 16),

                          TextField(
                            controller: _codeCtrl,
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.done,
                            onSubmitted: (_) => _submit(),
                            decoration: InputDecoration(
                              labelText: 'Verification Code',
                              hintText: 'e.g. 123456',
                              prefixIcon: const Icon(Icons.lock_outline),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),

                          const Spacer(),

                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _submit,
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : const Text('Verify & Continue'),
                            ),
                          ),

                          const SizedBox(height: 10),

                          Center(
                            child: TextButton(
                              onPressed: _isLoading
                                  ? null
                                  : () => Navigator.pushNamedAndRemoveUntil(
                                        context,
                                        '/login',
                                        (route) => false,
                                      ),
                              child: const Text('Back to Login'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
