import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../services/provider_api.dart';

class DayHours {
  TimeOfDay open;
  TimeOfDay close;

  DayHours({required this.open, required this.close});
}

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
    'GARAGE': 'Garage services',
    'OIL_CHANGE': 'Oil change services',
    'BRAKES': 'Brakes repair',
    'TIRES': 'Tires & wheels services',
    'GLASS': 'Broken glass repair',
    'FULL_SERVICE': 'Full service',
    'TOWING': 'Towing services',
  };

  final Set<String> _selectedServices = {};

  // ✅ Opening Hours Schedule (no typing)
  final List<String> _days = const ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"];
  final Map<String, String> _dayLabels = const {
    "SUN": "Sunday",
    "MON": "Monday",
    "TUE": "Tuesday",
    "WED": "Wednesday",
    "THU": "Thursday",
    "FRI": "Friday",
    "SAT": "Saturday",
  };

  /// Stores selected working days and their hours
  /// Format: {"MON": DayHours(...), "TUE": DayHours(...)}
  final Map<String, DayHours> _schedule = {};

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
    super.dispose();
  }

  // ---------- UI helpers ----------
  InputDecoration _dec(String label, IconData icon, {String? hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: const Color(0xFFF9FAFB),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF4F46E5), width: 1.6),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    );
  }

  Widget _sectionTitle(String t, {String? sub}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(t, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13.5)),
          if (sub != null) ...[
            const SizedBox(height: 3),
            Text(sub, style: const TextStyle(color: Colors.black54, fontSize: 12.5)),
          ],
        ],
      ),
    );
  }

  Widget _pill(String text, {IconData? icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14),
            const SizedBox(width: 6),
          ],
          Flexible(child: Text(text, style: const TextStyle(fontSize: 12.5))),
        ],
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Material(
      elevation: 10,
      shadowColor: Colors.black12,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFEAEAF2)),
        ),
        child: child,
      ),
    );
  }

  // ---------- Schedule helpers ----------
  String _two(int n) => n.toString().padLeft(2, '0');

  String _scheduleToJson() {
    final m = <String, dynamic>{};
    _schedule.forEach((day, h) {
      m[day] = {
        "open": "${_two(h.open.hour)}:${_two(h.open.minute)}",
        "close": "${_two(h.close.hour)}:${_two(h.close.minute)}",
      };
    });
    return jsonEncode(m);
  }

  TimeOfDay _parseTime(String s, {TimeOfDay fallback = const TimeOfDay(hour: 9, minute: 0)}) {
    final parts = s.split(":");
    if (parts.length != 2) return fallback;
    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    if (h == null || m == null) return fallback;
    return TimeOfDay(hour: h, minute: m);
  }

  bool _isCloseBeforeOrEqualOpen(DayHours h) {
    final openMin = h.open.hour * 60 + h.open.minute;
    final closeMin = h.close.hour * 60 + h.close.minute;
    // allow overnight? if you want overnight, return false here
    return closeMin <= openMin;
  }

  // ---------- Load from backend ----------
  Future<void> _loadBusiness() async {
    setState(() => _loadingBusiness = true);

    try {
      final data = await ProviderApi.getBusiness(userId: widget.userId);

      _nameCtrl.text = (data['businessName'] ?? '').toString();
      _descCtrl.text = (data['description'] ?? '').toString();
      _servicesCtrl.text = (data['services'] ?? '').toString();

      // ✅ Parse openingHours JSON (new format)
      _schedule.clear();
      final oh = (data['openingHours'] ?? '').toString().trim();
      if (oh.startsWith('{')) {
        try {
          final decoded = jsonDecode(oh);
          if (decoded is Map) {
            decoded.forEach((day, range) {
              if (range is Map) {
                final open = (range["open"] ?? "09:00").toString();
                final close = (range["close"] ?? "18:00").toString();
                final key = day.toString().toUpperCase();
                if (_dayLabels.containsKey(key)) {
                  _schedule[key] = DayHours(
                    open: _parseTime(open, fallback: const TimeOfDay(hour: 9, minute: 0)),
                    close: _parseTime(close, fallback: const TimeOfDay(hour: 18, minute: 0)),
                  );
                }
              }
            });
          }
        } catch (_) {
          // old free-text format (ignore)
        }
      }

      final lat = data['latitude'];
      final lng = data['longitude'];
      if (lat != null && lng != null) {
        _lat = (lat as num).toDouble();
        _lng = (lng as num).toDouble();
      }

      // categories
      _selectedCategories.clear();
      final cats = data['categories'];
      if (cats is List) {
        for (final c in cats) {
          _selectedCategories.add(c.toString().toUpperCase());
        }
      } else if (cats is String && cats.trim().isNotEmpty) {
        for (final p in cats.split(',')) {
          _selectedCategories.add(p.trim().toUpperCase());
        }
      }

      // offeredServices
      _selectedServices.clear();
      final offered = data['offeredServices'];
      if (offered is List) {
        for (final s in offered) {
          _selectedServices.add(s.toString().toUpperCase());
        }
      } else if (offered is String && offered.trim().isNotEmpty) {
        for (final p in offered.split(',')) {
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

  // ---------- Location ----------
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
        const SnackBar(content: Text('Location saved ✅')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to get location: $e')),
      );
    }
  }

  // ---------- Chips logic ----------
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

  void _toggleService(String s) {
    setState(() {
      if (_selectedServices.contains(s)) {
        _selectedServices.remove(s);
      } else {
        _selectedServices.add(s);
      }
    });
  }

  // ---------- Opening hours picker ----------
  Widget _openingHoursPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle("Opening hours", sub: "Select working days, then choose open/close time"),
        const SizedBox(height: 8),

        ..._days.map((d) {
          final selected = _schedule.containsKey(d);
          final h = _schedule[d];

          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Switch(
                      value: selected,
                      onChanged: _loading
                          ? null
                          : (v) {
                              setState(() {
                                if (v) {
                                  _schedule[d] = DayHours(
                                    open: const TimeOfDay(hour: 9, minute: 0),
                                    close: const TimeOfDay(hour: 18, minute: 0),
                                  );
                                } else {
                                  _schedule.remove(d);
                                }
                              });
                            },
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _dayLabels[d] ?? d,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                    if (selected)
                      _pill(
                        "${h!.open.format(context)} - ${h.close.format(context)}",
                        icon: Icons.access_time,
                      ),
                  ],
                ),
                if (selected) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _loading
                              ? null
                              : () async {
                                  final t = await showTimePicker(
                                    context: context,
                                    initialTime: h!.open,
                                  );
                                  if (t != null) {
                                    setState(() => _schedule[d]!.open = t);
                                  }
                                },
                          child: Text("Open: ${h!.open.format(context)}"),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _loading
                              ? null
                              : () async {
                                  final t = await showTimePicker(
                                    context: context,
                                    initialTime: h.close,
                                  );
                                  if (t != null) {
                                    setState(() => _schedule[d]!.close = t);
                                  }
                                },
                          child: Text("Close: ${h.close.format(context)}"),
                        ),
                      ),
                    ],
                  ),
                  if (_isCloseBeforeOrEqualOpen(h))
                    const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Text(
                        "Close time must be after open time.",
                        style: TextStyle(color: Colors.red, fontSize: 12.5),
                      ),
                    ),
                ],
              ],
            ),
          );
        }),

        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _schedule.isEmpty
              ? [_pill("No working days selected", icon: Icons.info_outline)]
              : _schedule.keys
                  .map((d) => _pill(_dayLabels[d] ?? d, icon: Icons.calendar_month_outlined))
                  .toList(),
        ),
      ],
    );
  }

  // ---------- Save ----------
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

    if (_selectedServices.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least 1 service type')),
      );
      return;
    }

    if (_schedule.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least 1 working day')),
      );
      return;
    }

    // validate schedule times
    for (final e in _schedule.entries) {
      if (_isCloseBeforeOrEqualOpen(e.value)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fix opening hours for ${_dayLabels[e.key] ?? e.key}')),
        );
        return;
      }
    }

    setState(() => _loading = true);

    try {
      await ProviderApi.saveBusiness(
        userId: widget.userId,
        businessName: _nameCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        services: _servicesCtrl.text.trim(),

        // ✅ now saved as JSON string
        openingHours: _scheduleToJson(),

        latitude: _lat!,
        longitude: _lng!,
        categories: _selectedCategories.toList(),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle("Categories you support", sub: "Select what cars you can handle"),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _allCategories.map((c) {
            final selected = _selectedCategories.contains(c);
            return ChoiceChip(
              label: Text(_categoryLabels[c] ?? c),
              selected: selected,
              onSelected: _loading ? null : (_) => _toggleCategory(c),
              selectedColor: const Color(0xFFEEF2FF),
              labelStyle: TextStyle(
                fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
              ),
              side: BorderSide(
                color: selected ? const Color(0xFF4F46E5) : const Color(0xFFE5E7EB),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _selectedCategories.isEmpty
              ? [_pill("No category selected", icon: Icons.info_outline)]
              : _selectedCategories
                  .map((e) => _pill(_categoryLabels[e] ?? e, icon: Icons.category_outlined))
                  .toList(),
        ),
      ],
    );
  }

  Widget _serviceChips() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle("Service types you offer", sub: "Pick services you provide"),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _allServiceTypes.map((s) {
            final selected = _selectedServices.contains(s);
            return ChoiceChip(
              label: Text(_serviceLabels[s] ?? s),
              selected: selected,
              onSelected: _loading ? null : (_) => _toggleService(s),
              selectedColor: const Color(0xFFECFDF5),
              labelStyle: TextStyle(
                fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
              ),
              side: BorderSide(
                color: selected ? const Color(0xFF16A34A) : const Color(0xFFE5E7EB),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _selectedServices.isEmpty
              ? [_pill("No service selected", icon: Icons.info_outline)]
              : _selectedServices
                  .map((e) => _pill(_serviceLabels[e] ?? e, icon: Icons.build_outlined))
                  .toList(),
        ),
      ],
    );
  }

  Widget _locationCard() {
    final hasLoc = _lat != null && _lng != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle("Business location", sub: "Used to show customers nearby"),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            OutlinedButton.icon(
              onPressed: _loading ? null : _useMyLocation,
              icon: const Icon(Icons.my_location),
              label: Text(hasLoc ? 'Update location' : 'Use my location'),
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
            if (hasLoc)
              _pill(
                '${_lat!.toStringAsFixed(6)}, ${_lng!.toStringAsFixed(6)}',
                icon: Icons.location_on_outlined,
              ),
          ],
        ),
        if (!hasLoc)
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text(
              "No location saved yet.",
              style: TextStyle(color: Colors.black54, fontSize: 12.5),
            ),
          ),
      ],
    );
  }

  // ---------- Build ----------
  @override
  Widget build(BuildContext context) {
    if (_loadingBusiness) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 700;
    final cardWidth = isMobile ? size.width * 0.94 : 640.0;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF5F7FF), Color(0xFFFDF2F8)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: cardWidth),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: _card(
                  child: Form(
                    key: _formKey,
                    child: ListView(
                      shrinkWrap: true,
                      children: [
                        // Header
                        Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                color: const Color(0xFFEEF2FF),
                              ),
                              child: const Icon(
                                Icons.storefront_outlined,
                                color: Color(0xFF4F46E5),
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Provider Business",
                                    style: TextStyle(
                                      fontSize: 16.5,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    "Update your workshop profile",
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
                              onPressed: _loading ? null : _loadBusiness,
                              icon: const Icon(Icons.refresh),
                            ),
                            IconButton(
                              tooltip: "Back",
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.arrow_back),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Fields
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
                        const SizedBox(height: 14),

                        // ✅ Opening hours (picker)
                        _openingHoursPicker(),
                        const SizedBox(height: 16),

                        // Chips sections
                        _categoryChips(),
                        const SizedBox(height: 16),
                        _serviceChips(),
                        const SizedBox(height: 16),

                        // Location
                        _locationCard(),
                        const SizedBox(height: 18),

                        // Save button
                        SizedBox(
                          height: 46,
                          child: _loading
                              ? const Center(child: CircularProgressIndicator())
                              : ElevatedButton(
                                  onPressed: _save,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF4F46E5),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
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
              ),
            ),
          ),
        ),
      ),
    );
  }
}
