import 'package:flutter/material.dart';
import '../models/vehicle.dart';
import '../services/vehicle_service.dart';
import '../services/auth_service.dart';
import 'add_car_screen.dart';
import 'profile_screen.dart';

class CustomerHomeScreen extends StatefulWidget {
  final int userId;

  const CustomerHomeScreen({super.key, required this.userId});

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  late Future<List<Vehicle>> _vehiclesFuture;

  @override
  void initState() {
    super.initState();
    _vehiclesFuture = VehicleService.getVehicles(userId: widget.userId);
  }

  Future<void> _reload() async {
    setState(() {
      _vehiclesFuture = VehicleService.getVehicles(userId: widget.userId);
    });
  }

  void _goToAddCar() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddCarScreen(userId: widget.userId),
      ),
    ).then((_) => _reload());
  }

  void _goToProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProfileScreen(userId: widget.userId),
      ),
    );
  }

  Future<void> _logout() async {
    await AuthService.logout();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
  }

  Widget _emptyState() {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Material(
            elevation: 10,
            shadowColor: Colors.black12,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFEAEAF2)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      color: const Color(0xFFEEF2FF),
                    ),
                    child: const Icon(
                      Icons.directions_car_filled_outlined,
                      color: Color(0xFF4F46E5),
                      size: 30,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "No cars yet",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "Add your first car to manage services and requests easily.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black54),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    height: 46,
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _goToAddCar,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4F46E5),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      icon: const Icon(Icons.add),
                      label: const Text(
                        "Add first car",
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _vehicleCard(Vehicle v) {
    return Material(
      elevation: 6,
      shadowColor: Colors.black12,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: Colors.white,
          border: Border.all(color: const Color(0xFFEAEAF2)),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          leading: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: const Color(0xFFEEF2FF),
            ),
            child: const Icon(
              Icons.directions_car_filled_outlined,
              color: Color(0xFF4F46E5),
            ),
          ),
          title: Text(
            "${v.make} ${v.model}",
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              "Plate: ${v.plateNumber}   •   Year: ${v.year}",
              style: const TextStyle(color: Colors.black54),
            ),
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            // لاحقاً: افتح صفحة تفاصيل السيارة / طلب خدمة / صيانة
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // خلفية مودرن
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF5F7FF),
              Color(0xFFFDF2F8),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // AppBar مودرن (بدون AppBar الرسمي عشان شكل أجمل)
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
                child: Material(
                  elevation: 8,
                  shadowColor: Colors.black12,
                  borderRadius: BorderRadius.circular(18),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFEAEAF2)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            color: const Color(0xFFEEF2FF),
                          ),
                          child: const Icon(
                            Icons.home_outlined,
                            color: Color(0xFF4F46E5),
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Customer Home",
                                style: TextStyle(fontWeight: FontWeight.w900),
                              ),
                              SizedBox(height: 2),
                              Text(
                                "Your garage",
                                style: TextStyle(fontSize: 12.5, color: Colors.black54),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: _goToProfile,
                          tooltip: 'Profile',
                          icon: const Icon(Icons.person_outline),
                        ),
                        IconButton(
                          onPressed: _reload,
                          tooltip: 'Refresh',
                          icon: const Icon(Icons.refresh),
                        ),
                        IconButton(
                          onPressed: _logout,
                          tooltip: 'Logout',
                          icon: const Icon(Icons.logout),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // المحتوى
              Expanded(
                child: FutureBuilder<List<Vehicle>>(
                  future: _vehiclesFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            "Failed to load cars: ${snapshot.error}",
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    }

                    final vehicles = snapshot.data ?? [];
                    if (vehicles.isEmpty) return _emptyState();

                    return RefreshIndicator(
                      onRefresh: _reload,
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(14, 6, 14, 90),
                        itemBuilder: (_, i) => _vehicleCard(vehicles[i]),
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemCount: vehicles.length,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),

      // زر إضافة مودرن
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _goToAddCar,
        backgroundColor: const Color(0xFF4F46E5),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text(
          "Add car",
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}
