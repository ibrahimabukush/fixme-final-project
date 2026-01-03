import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/nearby_provider.dart';
import '../models/service_request.dart';

class CustomerApi {
  static const String baseUrl = 'http://localhost:8081';

  static Future<List<NearbyProvider>> getNearbyProviders({
    required int userId,
    required double lat,
    required double lng,
    required double radiusKm,
    required String category, // "JAPANESE"
    required String serviceType, // ✅ NEW
  }) async {
    final uri = Uri.parse(
      '$baseUrl/api/customers/$userId/providers/nearby'
      '?lat=$lat&lng=$lng&radiusKm=$radiusKm&category=$category&serviceType=$serviceType',
    );

    final res = await http.get(uri);
    if (res.statusCode != 200) {
      throw Exception('Nearby providers failed: ${res.body}');
    }

    final list = jsonDecode(res.body) as List;
    return list.map((e) => NearbyProvider.fromJson(e)).toList();
  }

  static Future<ServiceRequest> assignProvider({
    required int userId,
    required int requestId,
    required int providerId,
  }) async {
    final uri = Uri.parse('$baseUrl/api/customers/$userId/requests/$requestId/assign/$providerId');
    final res = await http.post(uri);

    if (res.statusCode != 200) {
      throw Exception('Assign failed: ${res.body}');
    }

    return ServiceRequest.fromJson(jsonDecode(res.body));
  }

  static Future<ServiceRequest> createRequest({
    required int userId,
    required int vehicleId,
    required String description,
    required double lat,
    required double lng,
    required String serviceType, // ✅ NEW
  }) async {
    final uri = Uri.parse('$baseUrl/api/customers/$userId/requests');

    final body = jsonEncode({
      "vehicleId": vehicleId,
      "description": description,
      "latitude": lat,
      "longitude": lng,
      "serviceType": serviceType, // ✅ NEW
    });

    final res = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (res.statusCode != 200 && res.statusCode != 201) {
      throw Exception('Create request failed: ${res.body}');
    }

    return ServiceRequest.fromJson(jsonDecode(res.body));
  }

  static Future<List<ServiceRequest>> myRequests({required int userId}) async {
    final uri = Uri.parse('$baseUrl/api/customers/$userId/requests');
    final res = await http.get(uri);

    if (res.statusCode != 200) {
      throw Exception('My requests failed: ${res.body}');
    }

    final list = jsonDecode(res.body) as List;
    return list.map((e) => ServiceRequest.fromJson(e)).toList();
  }

  static Future<ServiceRequest> confirmRequest({
    required int userId,
    required int requestId,
  }) async {
    final uri = Uri.parse('$baseUrl/api/customers/$userId/requests/$requestId/confirm');
    final res = await http.post(uri);

    if (res.statusCode != 200) {
      throw Exception('Confirm failed: ${res.body}');
    }

    return ServiceRequest.fromJson(jsonDecode(res.body));
  }
}
