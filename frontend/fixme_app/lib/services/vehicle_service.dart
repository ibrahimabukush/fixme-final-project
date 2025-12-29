import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/vehicle.dart';

class VehicleService {
  // لو شغال على Chrome خليك على localhost
  // لو رح تشغّل على Android emulator غيّرها لـ 10.0.2.2
  static const String baseUrl = 'http://localhost:8081';

  static Future<Map<String, dynamic>> addVehicle(
    int userId,
    String plateNumber,
    String make,
    String model,
    int year,
    String vehicleCategory,
  ) async {
    final url = Uri.parse('$baseUrl/api/customers/$userId/vehicles');

    final body = jsonEncode({
      'plateNumber': plateNumber,
      'make': make,
      'model': model,
      'year': year,
      'vehicleCategory': vehicleCategory, // لازم يطابق enum في الباك
    });

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
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
  static Future<Map<String, dynamic>> updateVehicle(
  int userId,
  int vehicleId,
  String plateNumber,
  String make,
  String model,
  int year,
  String vehicleCategory,
) async {
  final url = Uri.parse('$baseUrl/api/customers/$userId/vehicles/$vehicleId');

  final body = jsonEncode({
    'plateNumber': plateNumber,
    'make': make,
    'model': model,
    'year': year,
    'vehicleCategory': vehicleCategory,
  });

  final response = await http.put(
    url,
    headers: {'Content-Type': 'application/json'},
    body: body,
  );

  if (response.statusCode != 200) {
    throw Exception('Failed to update vehicle: ${response.body}');
  }

  return jsonDecode(response.body) as Map<String, dynamic>;
}
static Future<void> deleteVehicle(int userId, int vehicleId) async {
  final url = Uri.parse('$baseUrl/api/customers/$userId/vehicles/$vehicleId');

  final response = await http.delete(url);

  if (response.statusCode != 204 && response.statusCode != 200) {
    throw Exception('Failed to delete vehicle: ${response.body}');
  }
}

}
