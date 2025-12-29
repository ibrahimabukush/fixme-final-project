class Vehicle {
  final int id;
  final String make;
  final String model;
  final int? year;
  final String plateNumber;
  final String vehicleCategory;

  Vehicle({
    required this.id,
    required this.make,
    required this.model,
    required this.year,
    required this.plateNumber,
    required this.vehicleCategory,
  });

  static int _parseInt(dynamic v, {int fallback = 0}) {
    if (v == null) return fallback;
    if (v is int) return v;
    return int.tryParse(v.toString()) ?? fallback;
  }

  static int? _parseNullableInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: _parseInt(json['id']),
      make: (json['make'] ?? '').toString(),
      model: (json['model'] ?? '').toString(),
      year: _parseNullableInt(json['year']),
      plateNumber: (json['plateNumber'] ?? '').toString(),
      vehicleCategory: (json['vehicleCategory'] ?? 'ALL').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'make': make,
      'model': model,
      'year': year,
      'plateNumber': plateNumber,
      'vehicleCategory': vehicleCategory,
    };
  }
}
