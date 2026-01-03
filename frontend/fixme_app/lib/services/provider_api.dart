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
    required List<String> categories,
    required List<String> offeredServices,
  }) async {
    final url = Uri.parse('$baseUrl/api/providers/$userId/business');

    final bodyMap = {
      "businessName": businessName,

      // backend requires them (nullable=false)
      "city": "NA",
      "address": "NA",

      "description": description,
      "services": services,
      "openingHours": openingHours,

      // ✅ vehicle categories
      "categories": categories,

      // ✅ NEW: service types offered
      "offeredServices": offeredServices,

      "latitude": latitude,
      "longitude": longitude,
    };

    final res = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(bodyMap),
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
