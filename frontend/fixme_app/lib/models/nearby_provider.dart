class NearbyProvider {
  final int providerId;        // mapped from backend: userId
  final int businessId;        // optional but useful
  final String businessName;
  final String? description;
  final double latitude;
  final double longitude;
  final double distanceKm;
  final List<String> categories;

  NearbyProvider({
    required this.providerId,
    required this.businessId,
    required this.businessName,
    required this.latitude,
    required this.longitude,
    required this.distanceKm,
    required this.categories,
    this.description,
  });

  factory NearbyProvider.fromJson(Map<String, dynamic> j) {
    // backend sends categories as Set => comes as List in JSON
    final cats = (j['categories'] as List?) ?? const [];

    return NearbyProvider(
      // ✅ backend field name is userId (provider user id)
      providerId: ((j['userId'] ?? 0) as num).toInt(),

      // ✅ backend has businessId
      businessId: ((j['businessId'] ?? 0) as num).toInt(),

      businessName: (j['businessName'] ?? '').toString(),
      description: j['description']?.toString(),

      // ✅ protect against nulls (won’t crash)
      latitude: ((j['latitude'] ?? 0) as num).toDouble(),
      longitude: ((j['longitude'] ?? 0) as num).toDouble(),
      distanceKm: ((j['distanceKm'] ?? 0) as num).toDouble(),

      categories: cats.map((e) => e.toString()).toList(),
    );
  }
}
