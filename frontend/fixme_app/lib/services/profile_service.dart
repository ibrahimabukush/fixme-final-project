// lib/services/profile_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'auth_service.dart';
import '../models/user_profile.dart';

class ProfileService {
  // GET /api/profile/{userId}
  static Future<UserProfile> fetchProfile(int userId) async {
    final uri = Uri.parse('${AuthService.baseUrl}/api/profile/$userId');
    final res = await http.get(uri);

    if (res.statusCode != 200) {
      throw Exception('Failed to load profile: ${res.statusCode} - ${res.body}');
    }

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    return UserProfile.fromJson(data);
  }

  // PUT /api/profile/{userId}
  static Future<UserProfile> updateProfile(UserProfile profile) async {
    final uri = Uri.parse('${AuthService.baseUrl}/api/profile/${profile.userId}');
    final res = await http.put(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(profile.toJson()),
    );

    if (res.statusCode != 200) {
      throw Exception('Failed to update profile: ${res.statusCode} - ${res.body}');
    }

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    return UserProfile.fromJson(data);
  }

  // POST /api/profile/{userId}/avatar  (multipart)
  static Future<UserProfile> uploadAvatar({
    required int userId,
    required List<int> fileBytes,
    required String fileName,
  }) async {
    final uri = Uri.parse('${AuthService.baseUrl}/api/profile/$userId/avatar');

    final request = http.MultipartRequest('POST', uri)
      ..files.add(
        http.MultipartFile.fromBytes(
          'file',
          fileBytes,
          filename: fileName,
        ),
      );

    final streamed = await request.send();
    final res = await http.Response.fromStream(streamed);

    if (res.statusCode != 200) {
      throw Exception('Failed to upload avatar: ${res.statusCode} - ${res.body}');
    }

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    return UserProfile.fromJson(data);
  }
}
