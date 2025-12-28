// lib/models/user_profile.dart

class UserProfile {
  final int userId;
  String firstName;
  String lastName;
  String email;
  String phone;
  String? profileImageUrl;

  UserProfile({
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    this.profileImageUrl,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      // السيرفر ممكن يرجّع userId أو id، فندعم الاثنين
      userId: (json['userId'] ?? json['id']) is int
          ? (json['userId'] ?? json['id']) as int
          : ((json['userId'] ?? json['id']) as num).toInt(),
      firstName: (json['firstName'] ?? '') as String,
      lastName: (json['lastName'] ?? '') as String,
      email: (json['email'] ?? '') as String,
      phone: (json['phone'] ?? '') as String,
      profileImageUrl: json['profileImageUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
      'profileImageUrl': profileImageUrl,
    };
  }
}
