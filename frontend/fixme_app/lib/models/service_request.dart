class ServiceRequest {
  final int id;

  final int customerId;
  final int? providerId;

  final int vehicleId;
  final String plateNumber;
  final String make;
  final String model;
  final int? year;

  final String description;
  final String vehicleCategory;
  final String serviceType;

  final double latitude;
  final double longitude;

  final String status;          // e.g. WAITING_CUSTOMER, ACCEPTED ...
  final String progressStage;   // e.g. ON_THE_WAY, DIAGNOSING, FIXING, DONE
  final String createdAt;

  ServiceRequest({
    required this.id,
    required this.customerId,
    required this.providerId,
    required this.vehicleId,
    required this.plateNumber,
    required this.make,
    required this.model,
    required this.year,
    required this.description,
    required this.vehicleCategory,
    required this.serviceType,
    required this.latitude,
    required this.longitude,
    required this.status,
    required this.progressStage,
    required this.createdAt,
  });

  factory ServiceRequest.fromJson(Map<String, dynamic> j) {
    // progressStage ممكن يوصل null لو DB قديم أو الباكند ما رجّعه
    final ps = (j['progressStage'] ?? j['stage'] ?? 'ON_THE_WAY').toString();

    return ServiceRequest(
      id: (j['id'] as num).toInt(),

      customerId: (j['customerId'] as num).toInt(),
      providerId: (j['providerId'] == null) ? null : (j['providerId'] as num).toInt(),

      vehicleId: (j['vehicleId'] as num).toInt(),
      plateNumber: (j['plateNumber'] ?? '').toString(),
      make: (j['make'] ?? '').toString(),
      model: (j['model'] ?? '').toString(),
      year: (j['year'] == null) ? null : (j['year'] as num).toInt(),

      description: (j['description'] ?? '').toString(),
      vehicleCategory: (j['vehicleCategory'] ?? '').toString(),
      serviceType: (j['serviceType'] ?? '').toString(),
      latitude: (j['latitude'] as num).toDouble(),
      longitude: (j['longitude'] as num).toDouble(), 

      status: (j['status'] ?? '').toString(),
      progressStage: ps,
      createdAt: (j['createdAt'] ?? '').toString(),
    );
  }

  ServiceRequest copyWith({
    String? status,
    String? progressStage,
  }) {
    return ServiceRequest(
      id: id,
      customerId: customerId,
      providerId: providerId,
      vehicleId: vehicleId,
      plateNumber: plateNumber,
      make: make,
      model: model,
      year: year,
      description: description,
      vehicleCategory: vehicleCategory,
      serviceType:serviceType,
      latitude: latitude,
      longitude: longitude,
      status: status ?? this.status,
      progressStage: progressStage ?? this.progressStage,
      createdAt: createdAt,
    );
  }
}
