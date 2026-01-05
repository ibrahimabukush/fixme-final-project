import 'dart:async';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String identifier;
  final String verificationType; // 'EMAIL' or 'PHONE'
  const ResetPasswordScreen({
    super.key,
    required this.identifier,
    required this.verificationType,
  });

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  static const int _cooldownSeconds = 30;

  final _formKey = GlobalKey<FormState>();

  final _codeCtrl = TextEditingController();
  final _newPassCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _isLoading = false;
  bool _hide1 = true;
  bool _hide2 = true;

  int _resendSec = _cooldownSeconds;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = _startResendTimer(_resendSec);
  }

  Timer _startResendTimer(int seconds) {
    _timer?.cancel();
    _resendSec = seconds;
    return Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (_resendSec <= 0) {
        t.cancel();
        setState(() => _resendSec = 0);
        return;
      }
      setState(() => _resendSec--);
    });
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  String _formatSeconds(int s) {
    final m = s ~/ 60;
    final r = s % 60;
    final mm = m.toString().padLeft(2, '0');
    final rr = r.toString().padLeft(2, '0');
    return '$mm:$rr';
  }

  Future<void> _reset() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      await AuthService.resetPassword(
        identifier: widget.identifier,
        tokenCode: _codeCtrl.text.trim(),
        newPassword: _newPassCtrl.text,
        confirmPassword: _confirmCtrl.text,
      );

      if (!mounted) return;
      _snack('Password updated. Please login.');
      Navigator.pop(context);
    } catch (e) {
      _snack('Error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _resend() async {
    setState(() => _isLoading = true);
    try {
      await AuthService.resendResetCode(
        identifier: widget.identifier.trim(),
        verificationType: widget.verificationType,
      );

      _snack('Reset code resent.');
      _timer = _startResendTimer(_cooldownSeconds);
    } catch (e) {
      // Even if backend rejects due to cooldown, keep the UI locked for 30 minutes.
      // This prevents the user from spamming the endpoint.
      if (_resendSec <= 0) {
        _timer = _startResendTimer(_cooldownSeconds);
      }
      _snack('Resend failed: $e');
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
  void dispose() {
    _timer?.cancel();
    _codeCtrl.dispose();
    _newPassCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
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
                              IconButton(
                                onPressed: _isLoading ? null : () => Navigator.pop(context),
                                icon: const Icon(Icons.arrow_back),
                              ),
                              const SizedBox(width: 4),
                              const Text(
                                "Reset Password",
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),

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
                                child: const Icon(Icons.password, color: Colors.white),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "FixMe",
                                      style: TextStyle(
                                        fontSize: 18.5,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      "Reset for: ${widget.identifier}",
                                      style: const TextStyle(color: Colors.black54),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          TextFormField(
                            controller: _codeCtrl,
                            keyboardType: TextInputType.number,
                            decoration: _dec(
                              label: 'Verification code',
                              icon: Icons.verified_outlined,
                              hint: '6-digit code',
                            ),
                            validator: (v) {
                              final t = (v ?? '').trim();
                              if (t.isEmpty) return 'Enter the code';
                              if (t.length != 6) return 'Code must be 6 digits';
                              return null;
                            },
                          ),

                          const SizedBox(height: 8),

                          // ✅ Resend row
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  _resendSec > 0
                                      ? "Resend available in ${_formatSeconds(_resendSec)}"
                                      : "Didn’t receive the code?",
                                  style: const TextStyle(color: Colors.black54),
                                ),
                              ),
                              TextButton(
                                onPressed: (_resendSec > 0 || _isLoading) ? null : _resend,
                                child: const Text('Resend'),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          TextFormField(
                            controller: _newPassCtrl,
                            obscureText: _hide1,
                            decoration: _dec(
                              label: 'New password',
                              icon: Icons.lock_outline,
                              suffix: IconButton(
                                onPressed: _isLoading ? null : () => setState(() => _hide1 = !_hide1),
                                icon: Icon(_hide1 ? Icons.visibility : Icons.visibility_off),
                              ),
                            ),
                            validator: (v) {
                              if ((v ?? '').isEmpty) return 'Enter new password';
                              if ((v ?? '').length < 6) return 'Password too short';
                              return null;
                            },
                          ),

                          const SizedBox(height: 12),

                          TextFormField(
                            controller: _confirmCtrl,
                            obscureText: _hide2,
                            decoration: _dec(
                              label: 'Confirm password',
                              icon: Icons.lock_outline,
                              suffix: IconButton(
                                onPressed: _isLoading ? null : () => setState(() => _hide2 = !_hide2),
                                icon: Icon(_hide2 ? Icons.visibility : Icons.visibility_off),
                              ),
                            ),
                            validator: (v) {
                              if ((v ?? '').isEmpty) return 'Confirm password';
                              if (v != _newPassCtrl.text) return 'Passwords do not match';
                              return null;
                            },
                          ),

                          const SizedBox(height: 16),

                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: _isLoading
                                ? const Center(child: CircularProgressIndicator())
                                : ElevatedButton(
                                    onPressed: _reset,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF4F46E5),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      elevation: 0,
                                    ),
                                    child: const Text(
                                      'Reset password',
                                      style: TextStyle(fontWeight: FontWeight.w900),
                                    ),
                                  ),
                          ),

                          const SizedBox(height: 10),

                          Text(
                            "Make sure your new password is strong and not used before.",
                            style: TextStyle(color: Colors.black.withOpacity(0.55), fontSize: 12.5),
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
