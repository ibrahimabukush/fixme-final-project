class Vehicle {
  final int id;
  final String plateNumber;
  final String make;
  final String model;
  final int year;

  Vehicle({
    required this.id,
    required this.plateNumber,
    required this.make,
    required this.model,
    required this.year,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['id'] as int,
      plateNumber: json['plateNumber'] as String,
      make: json['make'] as String,
      model: json['model'] as String,
      year: json['year'] as int,
    );
  }
}
