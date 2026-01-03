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

  // ✅ NEW: service type selection
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

  Future<void> _useMyLocation() async {
    try {
      final enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enable location services')),
        );
        return;
      }

      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied || perm == LocationPermission.deniedForever) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permission denied')),
        );
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _lat = pos.latitude;
        _lng = pos.longitude;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location captured ✅')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to get location: $e')),
      );
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_lat == null || _lng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please use your location first')),
      );
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
        // ✅ NEW: send serviceType to backend
        serviceType: _selectedServiceType,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Request sent ✅')),
      );

      Navigator.pop(context, true); // true => refresh
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send request: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final v = widget.vehicle;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Request Service'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text(
                '${v.make} ${v.model} • ${v.plateNumber}',
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 6),
              Text(
                'Category: ${v.vehicleCategory}',
                style: const TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 16),

              // ✅ NEW: Service Type dropdown
              DropdownButtonFormField<String>(
                value: _selectedServiceType,
                decoration: const InputDecoration(
                  labelText: 'Service Type',
                  border: OutlineInputBorder(),
                ),
                items: _serviceTypes
                    .map((s) => DropdownMenuItem(
                          value: s,
                          child: Text(_serviceLabels[s] ?? s),
                        ))
                    .toList(),
                onChanged: _isLoading ? null : (v) => setState(() => _selectedServiceType = v ?? _selectedServiceType),
              ),

              const SizedBox(height: 12),

              TextFormField(
                controller: _descCtrl,
                minLines: 3,
                maxLines: 6,
                decoration: const InputDecoration(
                  labelText: 'Describe the problem',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Description required' : null,
              ),

              const SizedBox(height: 12),

              OutlinedButton.icon(
                onPressed: _isLoading ? null : _useMyLocation,
                icon: const Icon(Icons.my_location),
                label: Text(
                  _lat == null ? 'Use my location' : 'Location: $_lat, $_lng',
                ),
              ),

              const SizedBox(height: 16),

              SizedBox(
                height: 46,
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _submit,
                        child: const Text(
                          'Send Request',
                          style: TextStyle(fontWeight: FontWeight.w800),
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
