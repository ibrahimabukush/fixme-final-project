import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../models/service_request.dart';
import '../services/provider_requests_service.dart';

class ProviderNearbyRequestsScreen extends StatefulWidget {
  final int userId; // providerId

  const ProviderNearbyRequestsScreen({super.key, required this.userId});

  @override
  State<ProviderNearbyRequestsScreen> createState() =>
      _ProviderNearbyRequestsScreenState();
}

class _ProviderNearbyRequestsScreenState
    extends State<ProviderNearbyRequestsScreen> {
  double _radiusKm = 10;

  late Future<List<ServiceRequest>> _future;

  double? _lat;
  double? _lng;

  @override
  void initState() {
    super.initState();
    _future = _loadNearby();
  }

  Future<Position> _getMyLocation() async {
    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) {
      throw Exception("Location services are disabled");
    }

    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }

    if (perm == LocationPermission.denied ||
        perm == LocationPermission.deniedForever) {
      throw Exception("Location permission denied");
    }

    return Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  Future<List<ServiceRequest>> _loadNearby() async {
    // 1) get provider current location
    final pos = await _getMyLocation();
    _lat = pos.latitude;
    _lng = pos.longitude;

    // 2) call backend
    return ProviderRequestsService.getNearbyRequests(
      providerId: widget.userId,
      latitude: _lat!,
      longitude: _lng!,
      radiusKm: _radiusKm,
    );
  }

  Future<void> _reload() async {
    setState(() {
      _future = _loadNearby();
    });
  }

  String _prettyCategory(String v) {
    switch (v) {
      case 'ALL':
        return 'All';
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
        return v;
    }
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

  Widget _requestCard(ServiceRequest r) {
    final distanceText = (r.distanceKm == null)
        ? "Distance: -"
        : "Distance: ${r.distanceKm!.toStringAsFixed(1)} km";

    final desc = (r.description ?? '').trim();

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
          leading: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: const Color(0xFFEFF6FF),
            ),
            child: const Icon(Icons.place_outlined, color: Color(0xFF2563EB)),
          ),
          title: Text(
            "${r.make} ${r.model} • ${r.plateNumber}",
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (desc.isNotEmpty)
                  Text(
                    desc,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.black54),
                  ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 10,
                  runSpacing: 6,
                  children: [
                    _pill("Category: ${_prettyCategory(r.vehicleCategory)}"),
                    _pill(distanceText),
                    _pill("Status: ${r.status}"),
                  ],
                ),
              ],
            ),
          ),
          trailing: ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Accept will be added next ✅")),
              );
            },
            child: const Text("Accept"),
          ),
          onTap: () {
            showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text("Request details"),
                content: Text(
                  "Request ID: ${r.id}\n"
                  "Customer ID: ${r.customerId ?? '-'}\n"
                  "Vehicle: ${r.make} ${r.model}\n"
                  "Plate: ${r.plateNumber}\n"
                  "Year: ${r.year ?? '-'}\n"
                  "Category: ${_prettyCategory(r.vehicleCategory)}\n"
                  "Distance: ${(r.distanceKm ?? 0).toStringAsFixed(2)} km\n"
                  "Location: ${r.latitude}, ${r.longitude}\n\n"
                  "Description:\n${r.description ?? ''}",
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Close"),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF5F7FF),
              Color(0xFFFFFBEB),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Top bar
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
                child: Material(
                  elevation: 8,
                  shadowColor: Colors.black12,
                  borderRadius: BorderRadius.circular(18),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFEAEAF2)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            color: const Color(0xFFEFF6FF),
                          ),
                          child: const Icon(
                            Icons.assignment_outlined,
                            color: Color(0xFF2563EB),
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Nearby Requests",
                                style: TextStyle(fontWeight: FontWeight.w900),
                              ),
                              SizedBox(height: 2),
                              Text(
                                "Requests around you",
                                style: TextStyle(
                                  fontSize: 12.5,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          tooltip: "Refresh",
                          onPressed: _reload,
                          icon: const Icon(Icons.refresh),
                        ),
                        IconButton(
                          tooltip: "Back",
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Radius selector
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 4, 14, 10),
                child: Material(
                  elevation: 6,
                  shadowColor: Colors.black12,
                  borderRadius: BorderRadius.circular(18),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFEAEAF2)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.tune, size: 20),
                        const SizedBox(width: 10),
                        const Text("Radius:",
                            style: TextStyle(fontWeight: FontWeight.w800)),
                        const SizedBox(width: 10),
                        DropdownButton<double>(
                          value: _radiusKm,
                          items: const [
                            DropdownMenuItem(value: 5, child: Text("5 km")),
                            DropdownMenuItem(value: 10, child: Text("10 km")),
                            DropdownMenuItem(value: 20, child: Text("20 km")),
                            DropdownMenuItem(value: 50, child: Text("50 km")),
                          ],
                          onChanged: (v) {
                            if (v == null) return;
                            setState(() => _radiusKm = v);
                            _reload();
                          },
                        ),
                        const Spacer(),
                        Text("${_radiusKm.toInt()} km",
                            style: const TextStyle(color: Colors.black54)),
                      ],
                    ),
                  ),
                ),
              ),

              Expanded(
                child: FutureBuilder<List<ServiceRequest>>(
                  future: _future,
                  builder: (context, snap) {
                    if (snap.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snap.hasError) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            "Failed to load nearby requests:\n${snap.error}",
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    }

                    final list = snap.data ?? [];
                    if (list.isEmpty) {
                      return const Center(
                        child: Text(
                          "No nearby requests right now.",
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: _reload,
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(14, 6, 14, 22),
                        itemBuilder: (_, i) => _requestCard(list[i]),
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 10),
                        itemCount: list.length,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
