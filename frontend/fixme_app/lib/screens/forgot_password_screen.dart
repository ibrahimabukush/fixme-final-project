import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'reset_password_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identifierCtrl = TextEditingController();

  bool _isLoading = false;
  String _method = 'EMAIL'; // EMAIL or PHONE

  @override
  void dispose() {
    _identifierCtrl.dispose();
    super.dispose();
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
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

  Future<void> _send() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final identifier = _identifierCtrl.text.trim();

      await AuthService.requestPasswordReset(
        identifier: identifier,
        verificationType: _method,
      );

      if (!mounted) return;

      _snack('If the account exists, a code was sent.');

      Navigator.pushReplacement(
  context,
  MaterialPageRoute(
    builder: (_) => ResetPasswordScreen(
      identifier: identifier,
      verificationType: _method, // ✅ pass EMAIL / PHONE
    ),
  ),
);

    } catch (e) {
      _snack('Error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 700;
    final cardWidth = isMobile ? size.width * 0.92 : 540.0;

    Widget methodChip({
      required String title,
      required String value,
      required IconData icon,
    }) {
      final selected = _method == value;

      return InkWell(
        onTap: _isLoading ? null : () => setState(() => _method = value),
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: selected ? Colors.white : const Color(0xFFF6F7FB),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? const Color(0xFF4F46E5) : const Color(0xFFEAEAF2),
              width: selected ? 1.4 : 1.0,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 6),
                    )
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: selected ? const Color(0xFF4F46E5) : Colors.black54),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: selected ? const Color(0xFF4F46E5) : Colors.black87,
                ),
              ),
            ],
          ),
        ),
      );
    }

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
                          // Top row: back + brand
                          Row(
                            children: [
                              IconButton(
                                onPressed: _isLoading ? null : () => Navigator.pop(context),
                                icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                              ),
                              const SizedBox(width: 4),
                              Container(
                                width: 46,
                                height: 46,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  gradient: const LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [Color(0xFF4F46E5), Color(0xFF2563EB)],
                                  ),
                                ),
                                child: const Icon(Icons.car_repair, color: Colors.white),
                              ),
                              const SizedBox(width: 10),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "FixMe",
                                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      "Reset your password",
                                      style: TextStyle(color: Colors.black54),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 14),

                          const Text(
                            "Forgot password?",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            "Enter your email/phone and choose how you want to receive the verification code.",
                            style: TextStyle(color: Colors.black54),
                          ),

                          const SizedBox(height: 16),

                          // Identifier
                          TextFormField(
                            controller: _identifierCtrl,
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) => _send(),
                            decoration: _dec(
                              label: 'Email or phone',
                              icon: Icons.alternate_email,
                              hint: 'name@example.com or 05XXXXXXXX',
                            ),
                            validator: (v) {
                              if ((v ?? '').trim().isEmpty) return 'Please enter email/phone';
                              return null;
                            },
                          ),

                          const SizedBox(height: 14),

                          // Method selector (modern)
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF6F7FB),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFFEAEAF2)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Send code via",
                                  style: TextStyle(fontWeight: FontWeight.w900),
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    Expanded(
                                      child: methodChip(
                                        title: "Email",
                                        value: "EMAIL",
                                        icon: Icons.email_outlined,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: methodChip(
                                        title: "Phone",
                                        value: "PHONE",
                                        icon: Icons.phone_outlined,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 14),

                          // Button
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: _isLoading
                                ? const Center(child: CircularProgressIndicator())
                                : ElevatedButton(
                                    onPressed: _send,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF4F46E5),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      elevation: 0,
                                    ),
                                    child: const Text(
                                      'Send code',
                                      style: TextStyle(fontWeight: FontWeight.w900),
                                    ),
                                  ),
                          ),

                          const SizedBox(height: 10),

                          // Small help text
                          const Text(
                            "Tip: If you don’t receive a code, check the identifier and try again.",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 12.5, color: Colors.black54),
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
