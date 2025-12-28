import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/vehicle.dart';
class VehicleService {
  // لو شغال على Chrome خليك على localhost
  // لو رح تشغّل على Android emulator غيّرها لـ 10.0.2.2
  static const String baseUrl = 'http://localhost:8081';

  static Future<Map<String, dynamic>> addVehicle({
    required int userId,
    required String plateNumber,
    required String make,
    required String model,
    required int year,
  }) async {
    final url = Uri.parse('$baseUrl/api/customers/$userId/vehicles');

    final body = jsonEncode({
      'plateNumber': plateNumber,
      'make': make,
      'model': model,
      'year': year,
    });

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to add vehicle: ${response.body}');
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }
  static Future<List<Vehicle>> getVehicles({required int userId}) async {
    final url = Uri.parse('$baseUrl/api/customers/$userId/vehicles');

    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception('Failed to load vehicles: ${response.body}');
    }

    final List<dynamic> list = jsonDecode(response.body) as List<dynamic>;
    return list.map((e) => Vehicle.fromJson(e as Map<String, dynamic>)).toList();
  }
}
