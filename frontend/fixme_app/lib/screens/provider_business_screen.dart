import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../services/provider_api.dart';

class ProviderBusinessScreen extends StatefulWidget {
  final int userId;

  const ProviderBusinessScreen({super.key, required this.userId});

  @override
  State<ProviderBusinessScreen> createState() => _ProviderBusinessScreenState();
}

class _ProviderBusinessScreenState extends State<ProviderBusinessScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _servicesCtrl = TextEditingController();
  final _hoursCtrl = TextEditingController();

  bool _loading = false;

  double? _lat;
  double? _lng;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _servicesCtrl.dispose();
    _hoursCtrl.dispose();
    super.dispose();
  }

  InputDecoration _dec(String label, IconData icon, {String? hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
    );
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
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) {
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
        const SnackBar(content: Text('Location saved ✅')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to get location: $e')),
      );
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    if (_lat == null || _lng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please click "Use my location" first')),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      await ProviderApi.saveBusiness(
        userId: widget.userId,
        businessName: _nameCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        services: _servicesCtrl.text.trim(),
        openingHours: _hoursCtrl.text.trim(),
        latitude: _lat!,
        longitude: _lng!,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Business saved ✅')),
      );

      Navigator.pop(context, true); // رجّع true لعمل refresh إذا بدك
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Provider Business')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameCtrl,
                decoration: _dec('Business name', Icons.storefront_outlined),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _descCtrl,
                minLines: 2,
                maxLines: 5,
                decoration: _dec('Description', Icons.description_outlined,
                    hint: 'Fast nearby help...'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _servicesCtrl,
                decoration: _dec('Services', Icons.build_outlined,
                    hint: 'Towing, Tires, Battery'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _hoursCtrl,
                decoration: _dec('Opening hours', Icons.access_time_outlined,
                    hint: 'Sun-Thu 09:00-18:00'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),

              OutlinedButton.icon(
                onPressed: _loading ? null : _useMyLocation,
                icon: const Icon(Icons.my_location),
                label: Text(
                  (_lat == null)
                      ? 'Use my location'
                      : 'Location: ${_lat!.toStringAsFixed(6)}, ${_lng!.toStringAsFixed(6)}',
                ),
              ),

              const SizedBox(height: 16),

              SizedBox(
                height: 46,
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _save,
                        child: const Text(
                          'Save',
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
