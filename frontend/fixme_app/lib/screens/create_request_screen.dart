import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../models/vehicle.dart';
import '../services/service_request_service.dart';

class CreateRequestScreen extends StatefulWidget {
  final int userId;
  final Vehicle vehicle;

  const CreateRequestScreen({
    super.key,
    required this.userId,
    required this.vehicle,
  });

  @override
  State<CreateRequestScreen> createState() => _CreateRequestScreenState();
}

class _CreateRequestScreenState extends State<CreateRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descCtrl = TextEditingController();

  bool _isLoading = false;
  double? _lat;
  double? _lng;

  // ✅ Service types
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
    'GARAGE': 'Garage / General',
    'OIL_CHANGE': 'Oil change',
    'BRAKES': 'Brakes',
    'TIRES': 'Tires / Puncture',
    'GLASS': 'Broken glass',
    'FULL_SERVICE': 'Full service (טיפול كامل)',
    'TOWING': 'Towing (גרר)',
  };

  String _selectedServiceType = 'GARAGE';

  @override
  void dispose() {
    _descCtrl.dispose();
    super.dispose();
  }

  // ================= UI helpers =================

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

  Widget _card({required String title, required List<Widget> children}) {
    return Material(
      elevation: 10,
      shadowColor: Colors.black12,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFEAEAF2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15.5)),
            const SizedBox(height: 10),
            ...children,
          ],
        ),
      ),
    );
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  Future<void> _pickServiceType() async {
    if (_isLoading) return;

    final selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _BottomSheetCard(
        title: "Choose service type",
        child: ListView.separated(
          shrinkWrap: true,
          itemCount: _serviceTypes.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (_, i) {
            final s = _serviceTypes[i];
            final label = _serviceLabels[s] ?? s;
            final isSelected = _selectedServiceType == s;
            return ListTile(
              title: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
              trailing: isSelected ? const Icon(Icons.check) : const Icon(Icons.chevron_right),
              onTap: () => Navigator.pop(context, s),
            );
          },
        ),
      ),
    );

    if (selected != null) {
      setState(() => _selectedServiceType = selected);
    }
  }

  // ================= Location =================

  Future<void> _useMyLocation() async {
    try {
      final enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) {
        _snack('Please enable location services');
        return;
      }

      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied || perm == LocationPermission.deniedForever) {
        _snack('Location permission denied');
        return;
      }

      final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

      setState(() {
        _lat = pos.latitude;
        _lng = pos.longitude;
      });

      _snack('Location captured ✅');
    } catch (e) {
      _snack('Failed to get location: $e');
    }
  }

  // ================= Submit =================

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_lat == null || _lng == null) {
      _snack('Please use your location first');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await ServiceRequestService.createRequest(
        userId: widget.userId,
        vehicleId: widget.vehicle.id,
        description: _descCtrl.text.trim(),
        latitude: _lat!,
        longitude: _lng!,
        serviceType: _selectedServiceType,
      );

      _snack('Request sent ✅');
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      _snack('Failed to send request: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ================= Build =================

  @override
  Widget build(BuildContext context) {
    final v = widget.vehicle;
    final serviceLabel = _serviceLabels[_selectedServiceType] ?? _selectedServiceType;

    final hasLoc = _lat != null && _lng != null;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF5F7FF), Color(0xFFFFFBEB)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Top bar (modern)
              Padding(
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
                          child: const Icon(Icons.build_circle_outlined, color: Color(0xFF4F46E5)),
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Request Service",
                                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                              SizedBox(height: 2),
                              Text("Create a new request",
                                  style: TextStyle(color: Colors.black54, fontSize: 12.5)),
                            ],
                          ),
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

              Expanded(
                child: Form(
                  key: _formKey,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                    children: [
                      // Vehicle info card
                      _card(
                        title: "Vehicle",
                        children: [
                          Text(
                            "${v.make} ${v.model}",
                            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Plate: ${v.plateNumber} • Year: ${v.year ?? '-'}",
                            style: const TextStyle(color: Colors.black54),
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 10,
                            runSpacing: 8,
                            children: [
                              _pill("Category: ${v.vehicleCategory}"),
                              _pill("Vehicle ID: ${v.id}"),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Service type card
                      _card(
                        title: "Service type",
                        children: [
                          InkWell(
                            onTap: _pickServiceType,
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF6F7FB),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: const Color(0xFFEAEAF2)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.category_outlined),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      serviceLabel,
                                      style: const TextStyle(fontWeight: FontWeight.w800),
                                    ),
                                  ),
                                  const Icon(Icons.expand_more),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            "Pick the service you need so providers can respond faster.",
                            style: TextStyle(color: Colors.black54),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Description card
                      _card(
                        title: "Problem description",
                        children: [
                          TextFormField(
                            controller: _descCtrl,
                            minLines: 4,
                            maxLines: 7,
                            maxLength: 300,
                            decoration: InputDecoration(
                              hintText: "Example: Car won’t start, battery seems dead...",
                              prefixIcon: const Icon(Icons.notes_outlined),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            validator: (v) =>
                                (v == null || v.trim().isEmpty) ? 'Description required' : null,
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Location card
                      _card(
                        title: "Your location",
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: hasLoc ? const Color(0xFFECFDF5) : const Color(0xFFF6F7FB),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFFEAEAF2)),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  hasLoc ? Icons.check_circle_outline : Icons.my_location,
                                  color: hasLoc ? const Color(0xFF10B981) : Colors.black54,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    hasLoc
                                        ? "Captured: $_lat, $_lng"
                                        : "No location captured yet",
                                    style: const TextStyle(fontWeight: FontWeight.w700),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            height: 46,
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: _isLoading ? null : _useMyLocation,
                              style: OutlinedButton.styleFrom(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              ),
                              icon: const Icon(Icons.my_location),
                              label: Text(hasLoc ? "Update location" : "Use my location"),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),
                    ],
                  ),
                ),
              ),

              // Bottom action
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton.icon(
                          onPressed: _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4F46E5),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                          ),
                          icon: const Icon(Icons.send_outlined),
                          label: const Text(
                            "Send Request",
                            style: TextStyle(fontWeight: FontWeight.w900),
                          ),
                        ),
                ),
              ),
            ],
          ),
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
