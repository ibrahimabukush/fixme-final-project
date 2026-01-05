import 'package:flutter/material.dart';
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
  late Future<List<ServiceRequest>> _future;

  /// ✅ Better UX: disable accept per-request (not global)
  final Set<int> _acceptingIds = <int>{};

  @override
  void initState() {
    super.initState();
    _future = _loadInbox();
  }

  Future<List<ServiceRequest>> _loadInbox() {
    return ProviderRequestsService.inbox(
      providerId: widget.userId,
      status: 'WAITING_PROVIDER',
    );
  }

  Future<void> _reload() async {
    setState(() {
      _future = _loadInbox();
    });
    await _future;
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

  Color _statusColor(String status) {
    switch (status.toUpperCase()) {
      case 'WAITING_PROVIDER':
        return const Color(0xFFF59E0B); // amber
      case 'WAITING_CUSTOMER':
        return const Color(0xFFF97316); // orange
      case 'ACCEPTED':
        return const Color(0xFF10B981); // green
      case 'DONE':
        return const Color(0xFF6366F1); // indigo
      default:
        return const Color(0xFF6B7280); // gray
    }
  }

  Widget _pill(String text, {IconData? icon, Color? color}) {
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
            Icon(icon, size: 14, color: color ?? const Color(0xFF111827)),
            const SizedBox(width: 6),
          ],
          Text(
            text,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: color ?? const Color(0xFF111827),
            ),
          ),
        ],
      ),
    );
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _accept(ServiceRequest r) async {
    if (_acceptingIds.contains(r.id)) return;

    setState(() => _acceptingIds.add(r.id));
    try {
      final updated = await ProviderRequestsService.accept(
        providerId: widget.userId,
        requestId: r.id,
      );

      _snack("Accepted ✅ (Status: ${updated.status})");
      await _reload();
    } catch (e) {
      _snack("Accept failed: $e");
    } finally {
      if (mounted) setState(() => _acceptingIds.remove(r.id));
    }
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
                    child: const Icon(Icons.inbox_outlined,
                        color: Color(0xFF4F46E5), size: 30),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "No requests right now",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "When new requests are assigned to you, they will appear here.",
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
                child: const Icon(
                  Icons.inbox_outlined,
                  color: Color(0xFF2563EB),
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Inbox Requests",
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                    SizedBox(height: 2),
                    Text(
                      "Assigned to you (WAITING_PROVIDER)",
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

  Widget _requestCard(ServiceRequest r) {
    final desc = (r.description).trim();
    final status = r.status.toUpperCase();
    final isAcceptingThis = _acceptingIds.contains(r.id);

    return Material(
      elevation: 7,
      shadowColor: Colors.black12,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text("Request details"),
              content: Text(
                "Request ID: ${r.id}\n"
                "Customer ID: ${r.customerId}\n"
                "Vehicle: ${r.make} ${r.model}\n"
                "Plate: ${r.plateNumber}\n"
                "Year: ${r.year ?? '-'}\n"
                "Category: ${_prettyCategory(r.vehicleCategory)}\n"
                "Status: ${r.status}\n"
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
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: Colors.white,
            border: Border.all(color: const Color(0xFFEAEAF2)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: const Color(0xFFEFF6FF),
                ),
                child: const Icon(Icons.assignment_outlined,
                    color: Color(0xFF2563EB)),
              ),
              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${r.make} ${r.model} • ${r.plateNumber}",
                      style: const TextStyle(fontWeight: FontWeight.w900),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    if (desc.isNotEmpty)
                      Text(
                        desc,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.black54),
                      ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      runSpacing: 8,
                      children: [
                        _pill(
                          "Status: $status",
                          icon: Icons.info_outline,
                          color: _statusColor(status),
                        ),
                        _pill(
                          "Category: ${_prettyCategory(r.vehicleCategory)}",
                          icon: Icons.category_outlined,
                        ),
                        _pill(
                          "Customer: ${r.customerId}",
                          icon: Icons.person_outline,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 10),

              // ✅ No overflow: fixed width + min height
              SizedBox(
                width: 120,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: 38,
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: (status == 'WAITING_PROVIDER' && !isAcceptingThis)
                            ? () => _accept(r)
                            : null,
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: isAcceptingThis
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text(
                                "Accept",
                                style: TextStyle(fontWeight: FontWeight.w800),
                              ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _pill("Details", icon: Icons.chevron_right),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------- Build ----------

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
                            "Failed to load inbox requests:\n${snap.error}",
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    }

                    final list = snap.data ?? [];
                    if (list.isEmpty) return _emptyState();

                    return RefreshIndicator(
                      onRefresh: _reload,
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(14, 6, 14, 22),
                        itemBuilder: (_, i) => _requestCard(list[i]),
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
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
