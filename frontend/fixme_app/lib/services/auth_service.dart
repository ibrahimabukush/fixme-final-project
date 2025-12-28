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
    final msg = data['error'] ?? 'حساب المزود غير مفعل بعد';
    throw Exception(msg);
  }

    if (res.statusCode != 200) {
      throw Exception('Login failed: ${res.statusCode} - ${res.body}');
    }

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    // شكل الرد من الـ backend:
    // { "userId": 19, "role": "ADMIN", "token": "eyJhbGciOi..." }

    _token = data['token'] as String?;
    _userId = (data['userId'] as num?)?.toInt();
    _role = data['role'] as String?;

    // debug صغير لو حاب تشوف بالقونصول:
    print('LOGIN OK -> userId=$_userId, role=$_role, token=$_token');

    if (_userId == null || _role == null) {
      // نخليها throw عشان تروح على catch في الشاشات
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

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Signup failed: ${response.statusCode} - ${response.body}');
    }
  }

  // ====== VERIFY CODE ======
  static Future<void> verify(String tokenCode) async {
    final url = Uri.parse('$_baseUrl/api/auth/verify');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'tokenCode': tokenCode}),
    );

    if (response.statusCode != 200) {
      throw Exception('Verification failed: ${response.statusCode} - ${response.body}');
    }
  }

  // ====== LOGOUT (يمسح الحالة المحلية) ======
  static Future<void> logout() async {
    _token = null;
    _userId = null;
    _role = null;
    // لو حاب تضيف مسح SharedPreferences بعدين، تحطه هون
  }
}
