import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../services/customer_api.dart';
import '../models/nearby_provider.dart';

class CustomerNearbyProvidersScreen extends StatefulWidget {
  final int userId;
  final int vehicleId;
  final String vehicleCategory; // "JAPANESE"
  final String serviceType;     // ✅ NEW e.g. "OIL_CHANGE"

  const CustomerNearbyProvidersScreen({
    super.key,
    required this.userId,
    required this.vehicleId,
    required this.vehicleCategory,
    required this.serviceType,
  });

  @override
  State<CustomerNearbyProvidersScreen> createState() => _CustomerNearbyProvidersScreenState();
}

class _CustomerNearbyProvidersScreenState extends State<CustomerNearbyProvidersScreen> {
  double _radiusKm = 10;
  double? _lat;
  double? _lng;

  final _descCtrl = TextEditingController();
  Future<List<NearbyProvider>>? _future;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getLocationAndLoad();
    });
  }

  @override
  void dispose() {
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _getLocationAndLoad() async {
    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('فعّل خدمات الموقع أولاً')));
      return;
    }

    LocationPermission perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) perm = await Geolocator.requestPermission();
    if (perm == LocationPermission.denied || perm == LocationPermission.deniedForever) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('صلاحية الموقع مرفوضة')));
      return;
    }

    final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    setState(() {
      _lat = pos.latitude;
      _lng = pos.longitude;

      _future = CustomerApi.getNearbyProviders(
        userId: widget.userId,
        lat: _lat!,
        lng: _lng!,
        radiusKm: _radiusKm,
        category: widget.vehicleCategory,
        serviceType: widget.serviceType, // ✅ NEW
      );
    });
  }

  Future<void> _sendRequest(NearbyProvider p) async {
    if (_lat == null || _lng == null) {
      await _getLocationAndLoad();
      if (_lat == null) return;
    }

    final desc = _descCtrl.text.trim();
    if (desc.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('اكتب وصف للمشكلة أولاً')));
      return;
    }

    try {
      // 1) create PENDING request (no provider)
      final created = await CustomerApi.createRequest(
        userId: widget.userId,
        vehicleId: widget.vehicleId,
        description: desc,
        lat: _lat!,
        lng: _lng!,
        serviceType: widget.serviceType, // ✅ NEW
      );

      // 2) assign to selected provider -> WAITING_PROVIDER
      final assigned = await CustomerApi.assignProvider(
        userId: widget.userId,
        requestId: created.id,
        providerId: p.providerId,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تم إرسال الطلب ✅ (Status: ${assigned.status})')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('فشل الإرسال: $e')));
    }
  }

  Widget _providerCard(NearbyProvider p) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        title: Text(p.businessName, style: const TextStyle(fontWeight: FontWeight.w900)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if ((p.description ?? '').trim().isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(p.description!, maxLines: 2, overflow: TextOverflow.ellipsis),
              ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 10,
              runSpacing: 6,
              children: [
                _pill('المسافة: ${p.distanceKm.toStringAsFixed(1)} كم'),
                _pill('التصنيفات: ${p.categories.join(", ")}'),
                _pill('الخدمة: ${widget.serviceType}'), // ✅ show selected service
              ],
            ),
          ],
        ),
        trailing: ElevatedButton(
          onPressed: () => _sendRequest(p),
          child: const Text('إرسال'),
        ),
      ),
    );
  }

  Widget _pill(String t) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Text(t, style: const TextStyle(fontSize: 12.5)),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Providers قريبين (${widget.vehicleCategory})'),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: _getLocationAndLoad,
            tooltip: 'تحديد موقعي',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            TextField(
              controller: _descCtrl,
              decoration: const InputDecoration(
                labelText: 'وصف المشكلة',
                hintText: 'مثال: السيارة مش راضية تشتغل...',
                border: OutlineInputBorder(),
              ),
              minLines: 1,
              maxLines: 3,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Text('نطاق البحث: ', style: TextStyle(fontWeight: FontWeight.w800)),
                const SizedBox(width: 10),
                DropdownButton<double>(
                  value: _radiusKm,
                  items: const [
                    DropdownMenuItem(value: 5, child: Text('5 كم')),
                    DropdownMenuItem(value: 10, child: Text('10 كم')),
                    DropdownMenuItem(value: 20, child: Text('20 كم')),
                    DropdownMenuItem(value: 50, child: Text('50 كم')),
                    DropdownMenuItem(value: 100, child: Text('100 كم')),
                    DropdownMenuItem(value: 150, child: Text('150 كم')),
                  ],
                  onChanged: (v) {
                    if (v == null) return;
                    setState(() => _radiusKm = v);
                    if (_lat != null && _lng != null) _getLocationAndLoad();
                  },
                ),
                const Spacer(),
                Text(_lat == null ? 'الموقع غير محدد' : 'تم تحديد الموقع ✅'),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: _future == null
                  ? const Center(child: Text('اضغط زر الموقع لتشوف الـ providers القريبين'))
                  : FutureBuilder<List<NearbyProvider>>(
                      future: _future,
                      builder: (context, snap) {
                        if (snap.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (snap.hasError) {
                          return Center(child: Text('خطأ: ${snap.error}'));
                        }
                        final list = snap.data ?? [];
                        if (list.isEmpty) {
                          return const Center(child: Text('ما في Providers مناسبين قريبين حالياً'));
                        }
                        return ListView.separated(
                          itemCount: list.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (_, i) => _providerCard(list[i]),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
