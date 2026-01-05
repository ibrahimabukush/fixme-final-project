import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  // لو شغّال على Chrome / Web استخدم localhost
  static const String _baseUrl = 'http://localhost:8081';
  static String get baseUrl => _baseUrl;

  // لو بعدين شغلت على emulator:
  // static const String _baseUrl = 'http://10.0.2.2:8081';

  // ====== حالة الـ user الحالية (بعد الـ login) ======
  static String? _token;
  static int? _userId;
  static String? _role;

  static String? get token => _token;
  static int? get userId => _userId;
  static String? get role => _role;

  // ====== LOGIN (يرجع JWT + userId + role) ======
  static Future<void> login({
    required String identifier,
    required String password,
  }) async {
    final uri = Uri.parse('$_baseUrl/api/auth/login');

    final res = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'identifier': identifier,
        'password': password,
      }),
    );

    if (res.statusCode == 403) {
      final data = jsonDecode(res.body);
      final msg = data['error'] ?? 'Provider account not approved yet';
      throw Exception(msg);
    }

    if (res.statusCode != 200) {
      // backend sometimes returns: {"error":"..."}
      try {
        final data = jsonDecode(res.body);
        final msg = (data is Map && data['error'] != null)
            ? data['error'].toString()
            : res.body;
        throw Exception(msg);
      } catch (_) {
        throw Exception('Login failed: ${res.statusCode} - ${res.body}');
      }
    }

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    // backend: { "userId": 19, "role": "CUSTOMER", "token": "..." }

    _token = data['token'] as String?;
    _userId = (data['userId'] as num?)?.toInt();
    _role = data['role'] as String?;

    print('LOGIN OK -> userId=$_userId, role=$_role, token=$_token');

    if (_userId == null || _role == null) {
      throw Exception('Missing userId/role in login response: ${res.body}');
    }
  }

  // ====== SIGNUP ======
  static Future<void> signup({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String password,
    required String confirmPassword,
    required String role, // 'CUSTOMER' or 'PROVIDER'
    required String verificationType, // 'EMAIL' or 'PHONE'
  }) async {
    final url = Uri.parse('$_baseUrl/api/auth/signup');

    final body = jsonEncode({
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
      'password': password,
      'confirmPassword': confirmPassword,
      'role': role,
      'verificationType': verificationType,
    });

    final res = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (res.statusCode != 200 && res.statusCode != 201) {
      try {
        final data = jsonDecode(res.body);
        final msg = (data is Map && data['error'] != null)
            ? data['error'].toString()
            : res.body;
        throw Exception(msg);
      } catch (_) {
        throw Exception('Signup failed: ${res.statusCode} - ${res.body}');
      }
    }
  }

  // ====== VERIFY CODE ======
  static Future<void> verify(String tokenCode) async {
    final url = Uri.parse('$_baseUrl/api/auth/verify');

    final res = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'tokenCode': tokenCode}),
    );

    if (res.statusCode != 200) {
      try {
        final data = jsonDecode(res.body);
        final msg = (data is Map && data['error'] != null)
            ? data['error'].toString()
            : res.body;
        throw Exception(msg);
      } catch (_) {
        throw Exception('Verification failed: ${res.statusCode} - ${res.body}');
      }
    }
  }

  // ====== LOGOUT (يمسح الحالة المحلية) ======
  static Future<void> logout() async {
    _token = null;
    _userId = null;
    _role = null;
  }

  // ====== FORGOT PASSWORD: request reset code ======
  static Future<void> requestPasswordReset({
    required String identifier,
    required String verificationType, // 'EMAIL' or 'PHONE'
  }) async {
    final url = Uri.parse('$_baseUrl/api/auth/forgot-password/request');

    final res = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'identifier': identifier,
        'verificationType': verificationType,
      }),
    );

    if (res.statusCode != 200) {
      try {
        final data = jsonDecode(res.body);
        final msg = (data is Map && data['error'] != null)
            ? data['error'].toString()
            : res.body;
        throw Exception(msg);
      } catch (_) {
        throw Exception('Reset request failed: ${res.statusCode} - ${res.body}');
      }
    }
  }

  // ====== FORGOT PASSWORD: reset password ======
  static Future<void> resetPassword({
    required String identifier,
    required String tokenCode,
    required String newPassword,
    required String confirmPassword,
  }) async {
    final url = Uri.parse('$_baseUrl/api/auth/forgot-password/reset');

    final res = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'identifier': identifier,
        'tokenCode': tokenCode,
        'newPassword': newPassword,
        'confirmPassword': confirmPassword,
      }),
    );

    if (res.statusCode != 200) {
      try {
        final data = jsonDecode(res.body);
        final msg = (data is Map && data['error'] != null)
            ? data['error'].toString()
            : res.body;
        throw Exception(msg);
      } catch (_) {
        throw Exception('Reset failed: ${res.statusCode} - ${res.body}');
      }
    }
  }

  // ====== RESEND SIGNUP verification code ======
  static Future<void> resendSignupVerificationCode({
    required String identifier,
    required String verificationType, // 'EMAIL' or 'PHONE'
  }) async {
    final url = Uri.parse('$_baseUrl/api/auth/verify/resend');

    final res = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'identifier': identifier,
        'verificationType': verificationType,
      }),
    );

    if (res.statusCode != 200) {
      try {
        final data = jsonDecode(res.body);
        final msg = (data is Map && data['error'] != null)
            ? data['error'].toString()
            : res.body;
        throw Exception(msg);
      } catch (_) {
        throw Exception('Resend failed: ${res.statusCode} - ${res.body}');
      }
    }
  }

  // ✅ RESEND RESET password code
  // Backend enforces 30 minutes cooldown
  // Note: it uses the same endpoint "forgot-password/request"
  static Future<void> resendResetCode({
    required String identifier,
    required String verificationType, // 'EMAIL' or 'PHONE'
  }) async {
    await requestPasswordReset(
      identifier: identifier,
      verificationType: verificationType,
    );
  }
}
