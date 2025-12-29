import 'dart:convert';
import 'package:http/http.dart' as http;

class ProviderApi {
  static const String baseUrl = 'http://localhost:8081';

  static Future<Map<String, dynamic>> saveBusiness({
    required int userId,
    required String businessName,
    required String description,
    required String services,
    required String openingHours,
    required double latitude,
    required double longitude,
  }) async {
    final url = Uri.parse('$baseUrl/api/providers/$userId/business');

    final body = jsonEncode({
      "businessName": businessName,

      // backend still requires them (nullable=false) -> send placeholders
      "city": "NA",
      "address": "NA",

      "description": description,
      "services": services,
      "openingHours": openingHours,

      // ✅ new fields
      "latitude": latitude,
      "longitude": longitude,
    });

    final res = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (res.statusCode != 200 && res.statusCode != 201) {
      throw Exception('Save business failed: ${res.body}');
    }

    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> getBusiness({required int userId}) async {
    final url = Uri.parse('$baseUrl/api/providers/$userId/business');

    final res = await http.get(url);

    if (res.statusCode != 200) {
      throw Exception('Get business failed: ${res.body}');
    }

    return jsonDecode(res.body) as Map<String, dynamic>;
  }
}
