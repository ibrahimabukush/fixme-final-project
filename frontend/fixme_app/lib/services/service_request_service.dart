import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/service_request.dart';

class ServiceRequestService {
  static const String baseUrl = 'http://localhost:8081';

  static Future<ServiceRequest> createRequest({
    required int userId,
    required int vehicleId,
    required String description,
    required double latitude,
    required double longitude,
    required String serviceType, // ✅ NEW
  }) async {
    final url = Uri.parse('$baseUrl/api/customers/$userId/requests');

    final body = jsonEncode({
      'vehicleId': vehicleId,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'serviceType': serviceType, // ✅ NEW
    });

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to create request: ${response.body}');
    }

    return ServiceRequest.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  static Future<List<ServiceRequest>> getMyRequests({required int userId}) async {
    final url = Uri.parse('$baseUrl/api/customers/$userId/requests');

    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception('Failed to load requests: ${response.body}');
    }

    final List<dynamic> list = jsonDecode(response.body) as List<dynamic>;
    return list
        .map((e) => ServiceRequest.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
