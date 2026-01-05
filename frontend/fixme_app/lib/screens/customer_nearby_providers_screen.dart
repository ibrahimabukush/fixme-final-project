import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../services/customer_api.dart';
import '../models/nearby_provider.dart';

class CustomerNearbyProvidersScreen extends StatefulWidget {
  final int userId;
  final int vehicleId;
  final String vehicleCategory; // "JAPANESE"
  final String serviceType; // e.g. "OIL_CHANGE"

  const CustomerNearbyProvidersScreen({
    super.key,
    required this.userId,
    required this.vehicleId,
    required this.vehicleCategory,
    required this.serviceType,
  });

  @override
  State<CustomerNearbyProvidersScreen> createState() =>
      _CustomerNearbyProvidersScreenState();
}

class _CustomerNearbyProvidersScreenState
    extends State<CustomerNearbyProvidersScreen> {
  double _radiusKm = 10;
  double? _lat;
  double? _lng;

  final _descCtrl = TextEditingController();
  Future<List<NearbyProvider>>? _future;

  bool _loadingLocation = false;
  bool _sending = false;

  // ✅ nicer radius options
  static const List<double> _radiusOptions = [5, 10, 20, 50, 100, 150];

  // UI helpers
  String _prettyCategory(String v) {
    switch (v.toUpperCase()) {
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

  String _prettyService(String s) {
    switch (s.toUpperCase()) {
      case 'GARAGE':
        return 'Garage / General';
      case 'OIL_CHANGE':
        return 'Oil change';
      case 'BRAKES':
        return 'Brakes';
      case 'TIRES':
        return 'Tires / Puncture';
      case 'GLASS':
        return 'Broken glass';
      case 'FULL_SERVICE':
        return 'Full service';
      case 'TOWING':
        return 'Towing';
      default:
        return s;
    }
  }

  @override
  void initState() {
    super.initState();
    // auto load once screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) => _getLocationAndLoad());
  }

  @override
  void dispose() {
    _descCtrl.dispose();
    super.dispose();
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _getLocationAndLoad() async {
    setState(() => _loadingLocation = true);
    try {
      final enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) {
        _snack('فعّل خدمات الموقع أولاً');
        return;
      }

      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) {
        _snack('صلاحية الموقع مرفوضة');
        return;
      }

      final pos =
          await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

      setState(() {
        _lat = pos.latitude;
        _lng = pos.longitude;

        _future = CustomerApi.getNearbyProviders(
          userId: widget.userId,
          lat: _lat!,
          lng: _lng!,
          radiusKm: _radiusKm,
          category: widget.vehicleCategory,
          serviceType: widget.serviceType,
        );
      });
    } catch (e) {
      _snack('Failed to get location: $e');
    } finally {
      if (mounted) setState(() => _loadingLocation = false);
    }
  }

  Future<void> _sendRequest(NearbyProvider p) async {
    if (_sending) return;

    if (_lat == null || _lng == null) {
      await _getLocationAndLoad();
      if (_lat == null || _lng == null) return;
    }

    final desc = _descCtrl.text.trim();
    if (desc.isEmpty) {
      _snack('اكتب وصف للمشكلة أولاً');
      return;
    }

    setState(() => _sending = true);

    try {
      // 1) create PENDING request
      final created = await CustomerApi.createRequest(
        userId: widget.userId,
        vehicleId: widget.vehicleId,
        description: desc,
        lat: _lat!,
        lng: _lng!,
        serviceType: widget.serviceType,
      );

      // 2) assign to selected provider -> WAITING_PROVIDER
      final assigned = await CustomerApi.assignProvider(
        userId: widget.userId,
        requestId: created.id,
        providerId: p.providerId,
      );

      _snack('تم إرسال الطلب ✅ (Status: ${assigned.status})');

      // optional: refresh list after sending
      await _getLocationAndLoad();
    } catch (e) {
      _snack('فشل الإرسال: $e');
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  // ---------------- UI ----------------

  Widget _pill(String t, {IconData? icon}) => Container(
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
            Text(t, style: const TextStyle(fontSize: 12.5)),
          ],
        ),
      );

  Widget _topBar() {
    return Padding(
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
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: const Color(0xFFEFF6FF),
                ),
                child: const Icon(Icons.storefront_outlined,
                    color: Color(0xFF2563EB)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Nearby Providers",
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "Category: ${_prettyCategory(widget.vehicleCategory)} • Service: ${_prettyService(widget.serviceType)}",
                      style:
                          const TextStyle(fontSize: 12.5, color: Colors.black54),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: "Locate",
                onPressed: _loadingLocation ? null : _getLocationAndLoad,
                icon: _loadingLocation
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.my_location),
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
    );
  }

  Widget _descriptionCard() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 6, 14, 10),
      child: Material(
        elevation: 7,
        shadowColor: Colors.black12,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFEAEAF2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("وصف المشكلة",
                  style: TextStyle(fontWeight: FontWeight.w900)),
              const SizedBox(height: 8),
              TextField(
                controller: _descCtrl,
                minLines: 2,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'مثال: السيارة مش راضية تشتغل...',
                  prefixIcon: const Icon(Icons.edit_note_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 8,
                children: [
                  _pill('نطاق: ${_radiusKm.toStringAsFixed(0)} كم',
                      icon: Icons.radar),
                  _pill(_lat == null ? 'الموقع غير محدد' : 'تم تحديد الموقع ✅',
                      icon: Icons.location_on_outlined),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _radiusChips() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
      child: Material(
        elevation: 6,
        shadowColor: Colors.black12,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFEAEAF2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("نطاق البحث",
                  style: TextStyle(fontWeight: FontWeight.w900)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _radiusOptions.map((km) {
                  final selected = _radiusKm == km;
                  return ChoiceChip(
                    label: Text('${km.toStringAsFixed(0)} كم'),
                    selected: selected,
                    onSelected: _loadingLocation
                        ? null
                        : (_) async {
                            setState(() => _radiusKm = km);
                            // refresh if location already exists
                            if (_lat != null && _lng != null) {
                              await _getLocationAndLoad();
                            }
                          },
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _providerCard(NearbyProvider p) {
    final desc = (p.description ?? '').trim();

    return Material(
      elevation: 7,
      shadowColor: Colors.black12,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: Colors.white,
          border: Border.all(color: const Color(0xFFEAEAF2)),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          leading: Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: const Color(0xFFEFF6FF),
            ),
            child:
                const Icon(Icons.storefront_outlined, color: Color(0xFF2563EB)),
          ),
          title: Text(
            p.businessName,
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
                const SizedBox(height: 8),
                Wrap(
                  spacing: 10,
                  runSpacing: 8,
                  children: [
                    _pill('${p.distanceKm.toStringAsFixed(1)} كم',
                        icon: Icons.social_distance),
                    _pill('تصنيفات: ${p.categories.join(", ")}',
                        icon: Icons.category_outlined),
                    _pill(_prettyService(widget.serviceType),
                        icon: Icons.build_outlined),
                  ],
                ),
              ],
            ),
          ),
          trailing: SizedBox(
            height: 40,
            child: ElevatedButton.icon(
              onPressed: _sending ? null : () => _sendRequest(p),
              icon: _sending
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.send_outlined, size: 18),
              label: const Text(
                'إرسال',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
          onTap: () {
            showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: Text(p.businessName),
                content: Text(
                  "Provider ID: ${p.providerId}\n"
                  "Distance: ${p.distanceKm.toStringAsFixed(2)} km\n"
                  "Categories: ${p.categories.join(", ")}\n\n"
                  "Description:\n${(p.description ?? '-')}",
                ),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Close")),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _emptyState(String title, String subtitle) {
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
                    child: const Icon(Icons.search_outlined,
                        color: Color(0xFF4F46E5), size: 30),
                  ),
                  const SizedBox(height: 12),
                  Text(title,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.black54),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    height: 46,
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _loadingLocation ? null : _getLocationAndLoad,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4F46E5),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      icon: const Icon(Icons.my_location),
                      label: const Text(
                        "تحديد موقعي",
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

  // ---------------- Build ----------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // same modern background in your app
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
              _topBar(),
              _descriptionCard(),
              _radiusChips(),
              Expanded(
                child: _future == null
                    ? _emptyState(
                        "ابدأ بتحديد موقعك",
                        "اضغط زر الموقع لعرض الـ providers القريبين حسب التصنيف والخدمة.",
                      )
                    : FutureBuilder<List<NearbyProvider>>(
                        future: _future,
                        builder: (context, snap) {
                          if (snap.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }
                          if (snap.hasError) {
                            return _emptyState(
                              "فشل تحميل الـ providers",
                              "${snap.error}",
                            );
                          }

                          final list = snap.data ?? [];
                          if (list.isEmpty) {
                            return _emptyState(
                              "ما في Providers مناسبين",
                              "جرّب توسّع النطاق أو تأكد من اختيار الخدمة/التصنيف.",
                            );
                          }

                          return RefreshIndicator(
                            onRefresh: _getLocationAndLoad,
                            child: ListView.separated(
                              padding:
                                  const EdgeInsets.fromLTRB(14, 6, 14, 22),
                              itemCount: list.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 10),
                              itemBuilder: (_, i) => _providerCard(list[i]),
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
