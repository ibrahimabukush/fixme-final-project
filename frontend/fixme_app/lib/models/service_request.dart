class ServiceRequest {
  final int id;

  final int? customerId; // provider needs it (optional for customer)
  final int vehicleId;

  final String plateNumber;
  final String make;
  final String model;
  final int? year;

  final String description;

  final String vehicleCategory;

  final double latitude;
  final double longitude;

  final double? distanceKm; // only for provider nearby

  final String status;
  final String createdAt;

  ServiceRequest({
    required this.id,
    required this.customerId,
    required this.vehicleId,
    required this.plateNumber,
    required this.make,
    required this.model,
    required this.year,
    required this.description,
    required this.vehicleCategory,
    required this.latitude,
    required this.longitude,
    required this.distanceKm,
    required this.status,
    required this.createdAt,
  });

  factory ServiceRequest.fromJson(Map<String, dynamic> json) {
    double toDouble(dynamic v) => (v as num).toDouble();
    int toInt(dynamic v) => (v as num).toInt();

    return ServiceRequest(
      id: toInt(json['id']),
      customerId: json['customerId'] == null ? null : toInt(json['customerId']),
      vehicleId: toInt(json['vehicleId']),
      plateNumber: (json['plateNumber'] as String?) ?? '',
      make: (json['make'] as String?) ?? '',
      model: (json['model'] as String?) ?? '',
      year: json['year'] == null ? null : toInt(json['year']),
      description: (json['description'] as String?) ?? '',
      vehicleCategory: (json['vehicleCategory'] as String?) ?? 'ALL',
      latitude: toDouble(json['latitude']),
      longitude: toDouble(json['longitude']),
      distanceKm: json['distanceKm'] == null ? null : toDouble(json['distanceKm']),
      status: (json['status'] as String?) ?? 'PENDING',
      createdAt: (json['createdAt'] as String?) ?? '',
    );
  }
}
