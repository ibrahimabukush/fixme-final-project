import 'package:flutter/material.dart';
import '../services/customer_api.dart';
import '../models/service_request.dart';
import 'chat_screen.dart';

class CustomerRequestsScreen extends StatefulWidget {
  final int userId;
  const CustomerRequestsScreen({super.key, required this.userId});

  @override
  State<CustomerRequestsScreen> createState() => _CustomerRequestsScreenState();
}

class _CustomerRequestsScreenState extends State<CustomerRequestsScreen> {
  late Future<List<ServiceRequest>> _future;

  /// ✅ Better UX: disable confirm per-request (not global)
  final Set<int> _confirmingIds = <int>{};

  @override
  void initState() {
    super.initState();
    _future = CustomerApi.myRequests(userId: widget.userId);
  }

  Future<void> _reload() async {
    setState(() {
      _future = CustomerApi.myRequests(userId: widget.userId);
    });
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _confirm(int requestId) async {
    if (_confirmingIds.contains(requestId)) return;

    setState(() => _confirmingIds.add(requestId));
    try {
      final r = await CustomerApi.confirmRequest(
        userId: widget.userId,
        requestId: requestId,
      );
      _snack('Confirmed ✅ (Status: ${r.status})');
      await _reload();
    } catch (e) {
      _snack('Confirm failed: $e');
    } finally {
      if (mounted) {
        setState(() => _confirmingIds.remove(requestId));
      }
    }
  }

  Future<void> _openChat(ServiceRequest r) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatScreen(
          requestId: r.id,
          userId: widget.userId,
          role: 'CUSTOMER',
          readOnly: (r.status.toUpperCase() == 'DONE'),
        ),
      ),
    );

    if (!mounted) return;
    await _reload(); // ✅ refresh after returning from chat
  }

  // ---------- UI helpers ----------

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

  String _prettyService(String? s) {
    final x = (s ?? '').toUpperCase();
    switch (x) {
      case 'GARAGE':
        return 'Garage / General';
      case 'OIL_CHANGE':
        return 'Oil change';
      case 'BRAKES':
        return 'Brakes';
      case 'TIRES':
        return 'Tires';
      case 'GLASS':
        return 'Glass';
      case 'FULL_SERVICE':
        return 'Full service';
      case 'TOWING':
        return 'Towing';
      case '':
        return 'Service: -';
      default:
        return x;
    }
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
          Text(text, style: const TextStyle(fontSize: 12.5)),
        ],
      ),
    );
  }

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
                  color: const Color(0xFFEEF2FF),
                ),
                child: const Icon(Icons.verified_outlined,
                    color: Color(0xFF4F46E5)),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Requests Need Confirm",
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                    SizedBox(height: 2),
                    Text(
                      "Only WAITING_CUSTOMER requests",
                      style: TextStyle(fontSize: 12.5, color: Colors.black54),
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
    );
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
                    child: const Icon(Icons.check_circle_outline,
                        color: Color(0xFF4F46E5), size: 30),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "No requests need confirmation ✅",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "When a provider accepts your request, it will appear here for confirmation.",
                    style: TextStyle(color: Colors.black54),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    height: 46,
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _reload,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4F46E5),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      icon: const Icon(Icons.refresh),
                      label: const Text(
                        "Refresh",
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

  Widget _requestCard(ServiceRequest r) {
    final desc = (r.description).trim();
    final status = r.status.toUpperCase();
    final service = _prettyService(r.serviceType);

    final isConfirmingThis = _confirmingIds.contains(r.id);

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
            child: const Icon(Icons.assignment_outlined, color: Color(0xFF2563EB)),
          ),
          title: Text(
            '${r.make} ${r.model} • ${r.plateNumber}',
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
                    _pill('Status: $status', icon: Icons.info_outline),
                    _pill('Category: ${_prettyCategory(r.vehicleCategory)}',
                        icon: Icons.category_outlined),
                    _pill(service, icon: Icons.build_outlined),
                  ],
                ),
              ],
            ),
          ),

          /// ✅ FIX OVERFLOW:
          /// trailing area height is limited, so keep actions in ONE ROW (not a Column)
          trailing: SizedBox(
            width: 150,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  tooltip: 'Chat',
                  icon: const Icon(Icons.chat_bubble_outline),
                  onPressed: () => _openChat(r),
                ),
                const SizedBox(width: 6),
                SizedBox(
                  height: 36,
                  child: ElevatedButton(
                    onPressed: isConfirmingThis ? null : () => _confirm(r.id),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: isConfirmingThis
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text(
                            'Confirm',
                            style: TextStyle(fontWeight: FontWeight.w800),
                          ),
                  ),
                ),
              ],
            ),
          ),

          onTap: () {
            showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text("Request details"),
                content: Text(
                  "Request ID: ${r.id}\n"
                  "Status: ${r.status}\n"
                  "Car: ${r.make} ${r.model}\n"
                  "Plate: ${r.plateNumber}\n"
                  "Year: ${r.year ?? '-'}\n"
                  "Category: ${_prettyCategory(r.vehicleCategory)}\n"
                  "Service: ${_prettyService(r.serviceType)}\n"
                  "Location: ${r.latitude}, ${r.longitude}\n\n"
                  "Description:\n${r.description}",
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
            colors: [Color(0xFFF5F7FF), Color(0xFFFDF2F8)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _topBar(),
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
                            'Failed to load requests:\n${snap.error}',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    }

                    final all = snap.data ?? [];

                    final list = all
                        .where((r) => r.status.toUpperCase() == 'WAITING_CUSTOMER')
                        .toList();

                    if (list.isEmpty) return _emptyState();

                    return RefreshIndicator(
                      onRefresh: _reload,
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(14, 6, 14, 22),
                        itemCount: list.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (_, i) => _requestCard(list[i]),
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
