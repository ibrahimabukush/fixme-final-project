import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/service_request.dart';

class ProviderRequestsService {
  static const String baseUrl = 'http://localhost:8081';

  static Map<String, String> _headers([String? token]) => {
        'Content-Type': 'application/json',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      };

  // ✅ Existing: nearby requests
  static Future<List<ServiceRequest>> getNearbyRequests({
    required int providerId,
    double radiusKm = 10,
    String? token,
  }) async {
    final url = Uri.parse(
      '$baseUrl/api/providers/$providerId/requests/nearby?radiusKm=$radiusKm',
    );

    final res = await http.get(url, headers: _headers(token));

    if (res.statusCode != 200) {
      throw Exception('Failed to load nearby requests: ${res.body}');
    }

    final List<dynamic> list = jsonDecode(res.body) as List<dynamic>;
    return list
        .map((e) => ServiceRequest.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ✅ NEW: inbox (all / with optional status filter)
  static Future<List<ServiceRequest>> inbox({
    required int providerId,
    String? status, // e.g. WAITING_PROVIDER / WAITING_CUSTOMER / ACCEPTED / DONE
    String? token,
  }) async {
    final qp = <String, String>{};
    if (status != null && status.trim().isNotEmpty) {
      qp['status'] = status.trim();
    }

    final uri = Uri.parse('$baseUrl/api/providers/$providerId/requests')
        .replace(queryParameters: qp.isEmpty ? null : qp);

    final res = await http.get(uri, headers: _headers(token));

    if (res.statusCode != 200) {
      throw Exception('Failed to load inbox: ${res.body}');
    }

    final List<dynamic> list = jsonDecode(res.body) as List<dynamic>;
    return list
        .map((e) => ServiceRequest.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ✅ NEW: accept request (provider accepts => WAITING_CUSTOMER)
  static Future<ServiceRequest> accept({
    required int providerId,
    required int requestId,
    String? token,
  }) async {
    final uri = Uri.parse(
      '$baseUrl/api/providers/$providerId/requests/$requestId/accept',
    );

    final res = await http.post(uri, headers: _headers(token));

    if (res.statusCode != 200) {
      throw Exception('Accept failed: ${res.body}');
    }

    final Map<String, dynamic> data = jsonDecode(res.body) as Map<String, dynamic>;
    return ServiceRequest.fromJson(data);
  }

  // ✅ NEW: update progress stage (ON_THE_WAY / DIAGNOSING / FIXING / DONE)
  static Future<ServiceRequest> updateProgress({
    required int providerId,
    required int requestId,
    required String progressStage,
    String? token,
  }) async {
    final uri = Uri.parse(
      '$baseUrl/api/providers/$providerId/requests/$requestId/progress',
    );

    final body = jsonEncode({'progressStage': progressStage});

    final res = await http.put(uri, headers: _headers(token), body: body);

    if (res.statusCode != 200) {
      throw Exception('Update progress failed: ${res.body}');
    }

    final Map<String, dynamic> data = jsonDecode(res.body) as Map<String, dynamic>;
    return ServiceRequest.fromJson(data);
  }
}
