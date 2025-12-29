import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/service_request.dart';

class ProviderRequestsService {
  static const String baseUrl = 'http://localhost:8081';

  static Future<List<ServiceRequest>> getNearbyRequests({
    required int providerId,
    required double latitude,
    required double longitude,
    double radiusKm = 10,
  }) async {
    final url = Uri.parse(
      '$baseUrl/api/providers/$providerId/requests/nearby'
      '?radiusKm=$radiusKm&latitude=$latitude&longitude=$longitude',
    );

    final res = await http.get(url);
    if (res.statusCode != 200) {
      throw Exception('Failed: ${res.body}');
    }

    final List<dynamic> list = jsonDecode(res.body) as List<dynamic>;
    return list
        .map((e) => ServiceRequest.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
