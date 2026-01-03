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
  bool _loadingBusiness = true;

  double? _lat;
  double? _lng;

  // ✅ categories
  final List<String> _allCategories = const [
    'GERMAN',
    'JAPANESE',
    'KOREAN',
    'AMERICAN',
    'ELECTRIC',
    'ALL',
  ];

  final Map<String, String> _categoryLabels = const {
    'GERMAN': 'German',
    'JAPANESE': 'Japanese',
    'KOREAN': 'Korean',
    'AMERICAN': 'American',
    'ELECTRIC': 'Electric',
    'ALL': 'All',
  };

  final Set<String> _selectedCategories = {};

  // ✅ NEW: offered services
  final List<String> _allServiceTypes = const [
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

  final Set<String> _selectedServices = {}; // ✅ NEW

  @override
  void initState() {
    super.initState();
    _loadBusiness();
  }

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

  // ✅ Load from backend and fill fields
  Future<void> _loadBusiness() async {
    setState(() => _loadingBusiness = true);

    try {
      final data = await ProviderApi.getBusiness(userId: widget.userId);

      _nameCtrl.text = (data['businessName'] ?? '').toString();
      _descCtrl.text = (data['description'] ?? '').toString();
      _servicesCtrl.text = (data['services'] ?? '').toString();
      _hoursCtrl.text = (data['openingHours'] ?? '').toString();

      final lat = data['latitude'];
      final lng = data['longitude'];
      if (lat != null && lng != null) {
        _lat = (lat as num).toDouble();
        _lng = (lng as num).toDouble();
      }

      // ✅ categories
      _selectedCategories.clear();
      final cats = data['categories'];
      if (cats is List) {
        for (final c in cats) {
          _selectedCategories.add(c.toString().toUpperCase());
        }
      } else if (cats is String && cats.trim().isNotEmpty) {
        final parts = cats.split(',');
        for (final p in parts) {
          _selectedCategories.add(p.trim().toUpperCase());
        }
      }

      // ✅ NEW: offeredServices
      _selectedServices.clear();
      final offered = data['offeredServices'];
      if (offered is List) {
        for (final s in offered) {
          _selectedServices.add(s.toString().toUpperCase());
        }
      } else if (offered is String && offered.trim().isNotEmpty) {
        final parts = offered.split(',');
        for (final p in parts) {
          _selectedServices.add(p.trim().toUpperCase());
        }
      }

      if (!mounted) return;
      setState(() => _loadingBusiness = false);
    } catch (e) {
      if (!mounted) return;
      setState(() => _loadingBusiness = false);

      final msg = e.toString();
      if (!msg.contains('404')) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load business: $e')),
        );
      }
    }
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

      final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

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

  void _toggleCategory(String c) {
    setState(() {
      if (c == 'ALL') {
        _selectedCategories
          ..clear()
          ..add('ALL');
        return;
      }

      _selectedCategories.remove('ALL');

      if (_selectedCategories.contains(c)) {
        _selectedCategories.remove(c);
      } else {
        _selectedCategories.add(c);
      }
    });
  }

  // ✅ NEW: toggle service
  void _toggleService(String s) {
    setState(() {
      if (_selectedServices.contains(s)) {
        _selectedServices.remove(s);
      } else {
        _selectedServices.add(s);
      }
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    if (_lat == null || _lng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please click "Use my location" first')),
      );
      return;
    }

    if (_selectedCategories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least 1 category')),
      );
      return;
    }

    // ✅ NEW
    if (_selectedServices.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least 1 service type')),
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
        categories: _selectedCategories.toList(),
        // ✅ NEW
        offeredServices: _selectedServices.toList(),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Business saved ✅')),
      );

      await _loadBusiness();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Widget _categoryChips() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Categories you support",
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _allCategories.map((c) {
              final selected = _selectedCategories.contains(c);
              return ChoiceChip(
                label: Text(_categoryLabels[c] ?? c),
                selected: selected,
                onSelected: _loading ? null : (_) => _toggleCategory(c),
              );
            }).toList(),
          ),
          const SizedBox(height: 6),
          Text(
            _selectedCategories.isEmpty
                ? "No category selected"
                : "Selected: ${_selectedCategories.map((e) => _categoryLabels[e] ?? e).join(', ')}",
            style: const TextStyle(color: Colors.black54),
          ),
        ],
      ),
    );
  }

  // ✅ NEW services chips
  Widget _serviceChips() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Service types you offer",
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _allServiceTypes.map((s) {
              final selected = _selectedServices.contains(s);
              return ChoiceChip(
                label: Text(_serviceLabels[s] ?? s),
                selected: selected,
                onSelected: _loading ? null : (_) => _toggleService(s),
              );
            }).toList(),
          ),
          const SizedBox(height: 6),
          Text(
            _selectedServices.isEmpty
                ? "No service selected"
                : "Selected: ${_selectedServices.map((e) => _serviceLabels[e] ?? e).join(', ')}",
            style: const TextStyle(color: Colors.black54),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingBusiness) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Provider Business'),
        actions: [
          IconButton(
            tooltip: "Refresh",
            onPressed: _loading ? null : _loadBusiness,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameCtrl,
                decoration: _dec('Business name', Icons.storefront_outlined),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _descCtrl,
                minLines: 2,
                maxLines: 5,
                decoration: _dec(
                  'Description',
                  Icons.description_outlined,
                  hint: 'Fast nearby help...',
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _servicesCtrl,
                decoration: _dec(
                  'Services (Text)',
                  Icons.build_outlined,
                  hint: 'Write a short text: Towing, Tires, Battery...',
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _hoursCtrl,
                decoration: _dec(
                  'Opening hours',
                  Icons.access_time_outlined,
                  hint: 'Sun-Thu 09:00-18:00',
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),

              // ✅ categories
              _categoryChips(),
              const SizedBox(height: 12),

              // ✅ NEW: offered services
              _serviceChips(),
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
