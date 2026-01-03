// lib/services/provider_requests_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/service_request.dart';

class ProviderRequestsService {
  static const String baseUrl = 'http://localhost:8081';

  // Inbox: GET /api/providers/{providerId}/requests?status=...
  // If status == null -> returns all provider requests
  static Future<List<ServiceRequest>> inbox({
    required int providerId,
    String? status,
  }) async {
    final uri = Uri.parse('$baseUrl/api/providers/$providerId/requests')
        .replace(queryParameters: status == null ? null : {'status': status});

    final res = await http.get(uri);
    if (res.statusCode != 200) {
      throw Exception('Inbox failed: ${res.body}');
    }

    final List<dynamic> list = jsonDecode(res.body) as List<dynamic>;
    return list.map((e) => ServiceRequest.fromJson(e as Map<String, dynamic>)).toList();
  }

  // Accept: POST /api/providers/{providerId}/requests/{requestId}/accept
  static Future<ServiceRequest> accept({
    required int providerId,
    required int requestId,
  }) async {
    final uri = Uri.parse('$baseUrl/api/providers/$providerId/requests/$requestId/accept');

    final res = await http.post(uri);
    if (res.statusCode != 200) {
      throw Exception('Accept failed: ${res.body}');
    }

    return ServiceRequest.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  // Update progress: PATCH /api/providers/{providerId}/requests/{requestId}/progress?stage=...
  static Future<ServiceRequest> updateProgress({
    required int providerId,
    required int requestId,
    required String progressStage, // ON_THE_WAY | DIAGNOSING | FIXING | DONE
  }) async {
    final uri = Uri.parse(
      '$baseUrl/api/providers/$providerId/requests/$requestId/progress?stage=$progressStage',
    );

    final res = await http.patch(uri);
    if (res.statusCode != 200) {
      throw Exception('Update progress failed: ${res.body}');
    }

    return ServiceRequest.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }
}
