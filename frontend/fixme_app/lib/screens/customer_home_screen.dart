import 'package:flutter/material.dart';
import '../models/vehicle.dart';
import '../services/vehicle_service.dart';
import '../services/auth_service.dart';
import 'add_car_screen.dart';
import 'profile_screen.dart';
import 'edit_car_screen.dart';
import 'customer_nearby_providers_screen.dart';
import 'customer_requests_screen.dart';
import 'my_requests_screen.dart';

class CustomerHomeScreen extends StatefulWidget {
  final int userId;

  const CustomerHomeScreen({super.key, required this.userId});

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  late Future<List<Vehicle>> _vehiclesFuture;

  // ✅ UI state
  final _searchCtrl = TextEditingController();
  String _filterCategory = 'ALL';

  @override
  void initState() {
    super.initState();
    _vehiclesFuture = VehicleService.getVehicles(userId: widget.userId);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _reload() async {
    setState(() {
      _vehiclesFuture = VehicleService.getVehicles(userId: widget.userId);
    });
  }

  void _goToAddCar() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddCarScreen(userId: widget.userId)),
    ).then((_) => _reload());
  }

  void _goToProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ProfileScreen(userId: widget.userId)),
    );
  }

  void _goToMyRequests() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CustomerRequestsScreen(userId: widget.userId),
      ),
    );
  }

  void _goToHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => MyRequestsScreen(userId: widget.userId)),
    );
  }

  Future<void> _logout() async {
    await AuthService.logout();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
  }

  // ✅ service types
  static const List<String> _serviceTypes = [
    'GARAGE',
    'OIL_CHANGE',
    'BRAKES',
    'TIRES',
    'GLASS',
    'FULL_SERVICE',
    'TOWING',
  ];

  final Map<String, String> _serviceLabels = const {
    'GARAGE': 'Garage service',
    'OIL_CHANGE': 'Oil change service',
    'BRAKES': 'Brakes repair  service',
    'TIRES': 'Tires / Puncture repair service',
    'GLASS': 'Broken glass repair service',
    'FULL_SERVICE': 'Full service',
    'TOWING': 'Towing service',
  };

  Future<String?> _pickServiceType() async {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _BottomSheetCard(
        title: 'Choose service type',
        child: ListView.separated(
          shrinkWrap: true,
          itemCount: _serviceTypes.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (_, i) {
            final s = _serviceTypes[i];
            return ListTile(
              title: Text(
                _serviceLabels[s] ?? s,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.pop(context, s),
            );
          },
        ),
      ),
    );
  }

  // ================== UI PIECES ==================

  Widget _topBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      child: Material(
        elevation: 10,
        shadowColor: Colors.black12,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFEAEAF2)),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: const Color(0xFFEEF2FF),
                ),
                child: const Icon(
                  Icons.directions_car_filled_outlined,
                  color: Color(0xFF4F46E5),
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("FixMe",
                        style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                    SizedBox(height: 2),
                    Text("Customer • Your garage",
                        style: TextStyle(color: Colors.black54, fontSize: 12.5)),
                  ],
                ),
              ),
              IconButton(
                tooltip: "Requests",
                onPressed: _goToMyRequests,
                icon: const Icon(Icons.receipt_long),
              ),
              IconButton(
                tooltip: "History",
                onPressed: _goToHistory,
                icon: const Icon(Icons.history),
              ),
              IconButton(
                tooltip: "Profile",
                onPressed: _goToProfile,
                icon: const Icon(Icons.person_outline),
              ),
              IconButton(
                tooltip: "Refresh",
                onPressed: _reload,
                icon: const Icon(Icons.refresh),
              ),
              IconButton(
                tooltip: "Logout",
                onPressed: _logout,
                icon: const Icon(Icons.logout),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statsBanner({required int carsCount}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
      child: Material(
        elevation: 10,
        shadowColor: Colors.black12,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFEEF2FF), Color(0xFFFFFBEB)],
            ),
            border: Border.all(color: const Color(0xFFEAEAF2)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Quick actions",
                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14.5),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Cars in your garage: $carsCount",
                      style: const TextStyle(color: Colors.black54),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        _miniAction(icon: Icons.add, label: "Add car", onTap: _goToAddCar),
                        _miniAction(
                          icon: Icons.receipt_long,
                          label: "Requests",
                          onTap: _goToMyRequests,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  color: Colors.white.withOpacity(0.85),
                ),
                child: const Icon(Icons.bolt, color: Color(0xFF4F46E5), size: 28),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _miniAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFEAEAF2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
          ],
        ),
      ),
    );
  }

  Widget _searchAndFilter() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchCtrl,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: "Search make / model / plate...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Color(0xFFEAEAF2)),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          _filterChip(),
        ],
      ),
    );
  }

  Widget _filterChip() {
    String label(String c) {
      switch (c.toUpperCase()) {
        case 'GERMAN':
          return 'German';
        case 'JAPANESE':
          return 'Japanese';
        case 'KOREAN':
          return 'Korean';
        case 'AMERICAN':
          return 'American';
        case 'ELECTRIC':
          return 'Electric';
        default:
          return 'All';
      }
    }

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () async {
        final selected = await showModalBottomSheet<String>(
          context: context,
          backgroundColor: Colors.transparent,
          builder: (_) => _BottomSheetCard(
            title: "Filter by category",
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final c in const ['ALL', 'GERMAN', 'JAPANESE', 'KOREAN', 'AMERICAN', 'ELECTRIC'])
                  ListTile(
                    title: Text(label(c), style: const TextStyle(fontWeight: FontWeight.w700)),
                    trailing: _filterCategory == c ? const Icon(Icons.check) : null,
                    onTap: () => Navigator.pop(context, c),
                  ),
              ],
            ),
          ),
        );

        if (selected != null) {
          setState(() => _filterCategory = selected);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFEAEAF2)),
        ),
        child: Row(
          children: [
            const Icon(Icons.tune, size: 18),
            const SizedBox(width: 6),
            Text(label(_filterCategory), style: const TextStyle(fontWeight: FontWeight.w800)),
          ],
        ),
      ),
    );
  }

  // ================= EMPTY STATE =================

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
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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

  // ================= VEHICLE CARD =================

  Future<void> _deleteCar(Vehicle v) async {
    final confirm = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _BottomSheetCard(
        title: "Delete car?",
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Delete ${v.make} ${v.model} (${v.plateNumber}) ?",
              style: const TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context, false),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text("Cancel"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEF4444),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text("Delete", style: TextStyle(fontWeight: FontWeight.w900)),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );

    if (confirm != true) return;

    try {
      await VehicleService.deleteVehicle(widget.userId, v.id);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Car deleted ✅")),
      );
      _reload();
    } catch (e) {
      if (!mounted) return;

      final msg = e.toString();

      // ✅ Friendly message for FK constraint / has requests
      if (msg.contains('HAS_REQUESTS') ||
          msg.contains('Cannot delete') ||
          msg.contains('constraint') ||
          msg.contains('409')) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              "You can't delete this car because it has service requests. Check History/Requests.",
            ),
            action: SnackBarAction(
              label: "History",
              onPressed: _goToHistory,
            ),
          ),
        );
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to delete car: $e")),
      );
    }
  }

  Widget _vehicleCard(Vehicle v) {
    String catLabel(String c) {
      switch (c.toUpperCase()) {
        case 'GERMAN':
          return 'German';
        case 'JAPANESE':
          return 'Japanese';
        case 'KOREAN':
          return 'Korean';
        case 'AMERICAN':
          return 'American';
        case 'ELECTRIC':
          return 'Electric';
        default:
          return 'All';
      }
    }

    return Material(
      elevation: 8,
      shadowColor: Colors.black12,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white,
          border: Border.all(color: const Color(0xFFEAEAF2)),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: const Color(0xFFEEF2FF),
                    ),
                    child: const Icon(
                      Icons.directions_car_filled_outlined,
                      color: Color(0xFF4F46E5),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${v.make} ${v.model}",
                          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15.5),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Plate: ${v.plateNumber} • Year: ${v.year ?? '-'}",
                          style: const TextStyle(color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: "Edit",
                    onPressed: () async {
                      final changed = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EditCarScreen(userId: widget.userId, vehicle: v),
                        ),
                      );
                      if (changed == true) _reload();
                    },
                    icon: const Icon(Icons.edit_outlined),
                  ),
                  IconButton(
                    tooltip: "Delete",
                    onPressed: () => _deleteCar(v),
                    icon: const Icon(Icons.delete_outline),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _pill("Category: ${catLabel(v.vehicleCategory)}"),
                  const SizedBox(width: 8),
                  _pill("ID: ${v.id}"),
                ],
              ),
              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final serviceType = await _pickServiceType();
                    if (serviceType == null) return;

                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CustomerNearbyProvidersScreen(
                          userId: widget.userId,
                          vehicleId: v.id,
                          vehicleCategory: v.vehicleCategory,
                          serviceType: serviceType,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4F46E5),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  icon: const Icon(Icons.near_me_outlined),
                  label: const Text(
                    "Request service",
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _pill(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Text(text, style: const TextStyle(fontSize: 12.5)),
    );
  }

  // ================= FILTERING =================

  List<Vehicle> _applyFilters(List<Vehicle> vehicles) {
    final q = _searchCtrl.text.trim().toLowerCase();

    return vehicles.where((v) {
      final inSearch = q.isEmpty ||
          v.make.toLowerCase().contains(q) ||
          v.model.toLowerCase().contains(q) ||
          v.plateNumber.toLowerCase().contains(q);

      final inCategory = _filterCategory == 'ALL' || (v.vehicleCategory.toUpperCase() == _filterCategory);

      return inSearch && inCategory;
    }).toList();
  }

  // ================= BUILD =================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF5F7FF), Color(0xFFFDF2F8)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _topBar(),

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

                    final vehiclesAll = snapshot.data ?? [];
                    if (vehiclesAll.isEmpty) return _emptyState();

                    final vehicles = _applyFilters(vehiclesAll);

                    return RefreshIndicator(
                      onRefresh: _reload,
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(0, 0, 0, 92),
                        children: [
                          _statsBanner(carsCount: vehiclesAll.length),
                          _searchAndFilter(),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
                            child: Text(
                              "Your cars (${vehicles.length})",
                              style: const TextStyle(fontWeight: FontWeight.w900),
                            ),
                          ),
                          if (vehicles.isEmpty)
                            Padding(
                              padding: const EdgeInsets.all(18),
                              child: _hintCard(
                                title: "No results",
                                subtitle: "Try a different search or reset the filter.",
                                icon: Icons.search_off_outlined,
                              ),
                            )
                          else
                            Padding(
                              padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
                              child: Column(
                                children: [
                                  for (final v in vehicles) ...[
                                    _vehicleCard(v),
                                    const SizedBox(height: 10),
                                  ],
                                ],
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _goToAddCar,
        backgroundColor: const Color(0xFF4F46E5),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text("Add car", style: TextStyle(fontWeight: FontWeight.w800)),
      ),
    );
  }

  Widget _hintCard({required String title, required String subtitle, required IconData icon}) {
    return Material(
      elevation: 10,
      shadowColor: Colors.black12,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white,
          border: Border.all(color: const Color(0xFFEAEAF2)),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: const Color(0xFFEEF2FF),
              ),
              child: Icon(icon, color: const Color(0xFF4F46E5)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
                  const SizedBox(height: 3),
                  Text(subtitle, style: const TextStyle(color: Colors.black54)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =================== BottomSheet Reusable ===================

class _BottomSheetCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _BottomSheetCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Material(
          borderRadius: BorderRadius.circular(20),
          elevation: 14,
          shadowColor: Colors.black12,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFEAEAF2)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const Divider(height: 1),
                const SizedBox(height: 10),
                child,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
