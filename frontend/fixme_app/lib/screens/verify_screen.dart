import 'dart:async';
import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import 'add_car_screen.dart';

class VerifyScreen extends StatefulWidget {
  const VerifyScreen({super.key});

  @override
  State<VerifyScreen> createState() => _VerifyScreenState();
}

class _VerifyScreenState extends State<VerifyScreen> {
  static const int _len = 6;
  static const int _cooldownSeconds = 30;

  final List<TextEditingController> _ctrls =
      List.generate(_len, (_) => TextEditingController());
  final List<FocusNode> _nodes = List.generate(_len, (_) => FocusNode());

  bool _isLoading = false;

  String? _identifier; // email or phone
  String? _password; // signup password (for auto-login)
  String? _role; // CUSTOMER / PROVIDER
  String? _verificationType; // EMAIL / PHONE  ✅ new

  // resend timer
  int _resendSec = _cooldownSeconds;
  Timer? _timer;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) {
      _identifier = args['identifier'] as String?;
      _password = args['password'] as String?;
      _role = args['role'] as String?;
      _verificationType = args['verificationType'] as String?; // ✅
    }

    _startTimerOnce();
  }

  void _startTimerOnce() {
    _timer ??= Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (_resendSec <= 0) {
        t.cancel();
        _timer = null;
        return;
      }
      setState(() => _resendSec--);
    });
  }

  void _restartTimer() {
    setState(() => _resendSec = _cooldownSeconds);
    _timer?.cancel();
    _timer = null;
    _startTimerOnce();
  }

  @override
  void dispose() {
    for (final c in _ctrls) {
      c.dispose();
    }
    for (final n in _nodes) {
      n.dispose();
    }
    _timer?.cancel();
    super.dispose();
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  String _code() => _ctrls.map((c) => c.text.trim()).join();

  void _clearAll() {
    for (final c in _ctrls) {
      c.clear();
    }
    FocusScope.of(context).requestFocus(_nodes.first);
  }

  void _handlePaste(String value) {
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.length < _len) return;

    for (int i = 0; i < _len; i++) {
      _ctrls[i].text = digits[i];
    }
    FocusScope.of(context).unfocus();
    _submit();
  }

  Future<void> _submit() async {
    final code = _code();

    if (code.length != _len) {
      _snack('Please enter the 6-digit code.');
      return;
    }

    if (_identifier == null || _password == null || _role == null) {
      _snack('Missing signup data (identifier/password/role).');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await AuthService.verify(code);

      // Provider: don’t auto-login
      if (_role == 'PROVIDER') {
        _snack('Account verified. Your provider account will be activated after admin approval.');
        if (!mounted) return;
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
        return;
      }

      // Customer: auto-login
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
      _clearAll();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _formatMMSS(int s) {
    final m = (s ~/ 60).toString().padLeft(2, '0');
    final sec = (s % 60).toString().padLeft(2, '0');
    return '$m:$sec';
  }

  int? _extractRemainingSeconds(String error) {
    // backend message: "Resend available in X seconds"
    final match = RegExp(r'in\s+(\d+)\s+seconds').firstMatch(error);
    if (match == null) return null;
    return int.tryParse(match.group(1)!);
  }

  bool _looksLikeCooldownMessage(String error) {
    // Our backend currently throws: "You can resend code every 30 minutes"
    return error.toLowerCase().contains('resend') &&
        error.toLowerCase().contains('30') &&
        error.toLowerCase().contains('second');
  }

  Future<void> _resend() async {
    if (_identifier == null || _verificationType == null) {
      _snack('Missing identifier/verificationType.');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await AuthService.resendSignupVerificationCode(
        identifier: _identifier!,
        verificationType: _verificationType!, // EMAIL / PHONE
      );

      _snack('Code resent.');
      _restartTimer();
    } catch (e) {
      // If backend returns remaining seconds, sync timer
      final remaining = _extractRemainingSeconds(e.toString());
      if (remaining != null && remaining > 0) {
        setState(() => _resendSec = remaining);
        _timer?.cancel();
        _timer = null;
        _startTimerOnce();
        _snack('Please wait ${_formatMMSS(remaining)} before resending.');
      } else if (_looksLikeCooldownMessage(e.toString())) {
        // Backend enforces 30 minutes cooldown; keep UI locked as well
        _restartTimer();
        _snack('You can resend the code every 30 seconds.');
      } else {
        _snack('Resend failed: $e');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _headerCard(String accountText, String subtitle) {
    return Material(
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
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF2563EB), Color(0xFF4F46E5)],
                ),
              ),
              child: const Icon(Icons.verified_outlined, color: Colors.white),
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
                  Text('Code sent to: $accountText',
                      style: const TextStyle(color: Colors.black54)),
                  const SizedBox(height: 6),
                  Text(subtitle, style: const TextStyle(color: Colors.black54)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _otpBox(int i) {
    return SizedBox(
      width: 48,
      child: TextField(
        controller: _ctrls[i],
        focusNode: _nodes[i],
        enabled: !_isLoading,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
        decoration: InputDecoration(
          counterText: "",
          filled: true,
          fillColor: const Color(0xFFF6F7FB),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFEAEAF2)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFF4F46E5), width: 1.6),
          ),
        ),
        onChanged: (v) {
          if (v.length > 1) {
            _handlePaste(v);
            return;
          }

          final digit = v.replaceAll(RegExp(r'\D'), '');
          if (digit != v) {
            _ctrls[i].text = digit;
            _ctrls[i].selection = TextSelection.fromPosition(
              TextPosition(offset: _ctrls[i].text.length),
            );
          }

          if (digit.isNotEmpty) {
            if (i < _len - 1) {
              FocusScope.of(context).requestFocus(_nodes[i + 1]);
            } else {
              FocusScope.of(context).unfocus();
            }
          } else {
            if (i > 0) {
              FocusScope.of(context).requestFocus(_nodes[i - 1]);
            }
          }

          if (_code().length == _len) {
            _submit();
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final accountText = (_identifier != null && _identifier!.isNotEmpty)
        ? _identifier!
        : 'your account';

    final subtitle = (_role == 'PROVIDER')
        ? 'Enter the 6-digit code. Providers require admin approval after verification.'
        : 'Enter the 6-digit code. After verification, you will be logged in automatically.';

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
                _headerCard(accountText, subtitle),
                const SizedBox(height: 14),

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
                          const Text(
                            'Verification Code',
                            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15.5),
                          ),
                          const SizedBox(height: 10),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: List.generate(_len, (i) => _otpBox(i)),
                          ),

                          const SizedBox(height: 14),

                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  _resendSec > 0
                                      ? "Resend available in ${_formatMMSS(_resendSec)}"
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

                          const Spacer(),

                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF4F46E5),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text(
                                      'Verify & Continue',
                                      style: TextStyle(fontWeight: FontWeight.w900),
                                    ),
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
