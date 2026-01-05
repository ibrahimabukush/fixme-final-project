// lib/screens/provider/provider_jobs_screen.dart
import 'package:flutter/material.dart';
import '../../models/service_request.dart';
import '../../services/provider_requests_service.dart';
import 'provider_request_details_screen.dart';

class ProviderJobsScreen extends StatefulWidget {
  final int providerId;
  const ProviderJobsScreen({super.key, required this.providerId});

  @override
  State<ProviderJobsScreen> createState() => _ProviderJobsScreenState();
}

class _ProviderJobsScreenState extends State<ProviderJobsScreen> {
  late Future<List<ServiceRequest>> _future;

  @override
  void initState() {
    super.initState();
    _future = ProviderRequestsService.inbox(providerId: widget.providerId);
  }

  Future<void> _reload() async {
    setState(() {
      _future = ProviderRequestsService.inbox(providerId: widget.providerId);
    });
  }

  String _statusText(String status) {
    switch (status.toUpperCase()) {
      case 'WAITING_CUSTOMER':
        return 'Waiting for customer confirmation';
      case 'ACCEPTED':
        return 'Confirmed ✅';
      default:
        return status;
    }
  }

  Color _statusColor(String status) {
    switch (status.toUpperCase()) {
      case 'WAITING_CUSTOMER':
        return const Color(0xFFF59E0B); // amber
      case 'ACCEPTED':
        return const Color(0xFF10B981); // green
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
                  Icons.work_outline,
                  color: Color(0xFF2563EB),
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "My Jobs",
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                    SizedBox(height: 2),
                    Text(
                      "Accepted + Waiting customer confirmation",
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
                    child: const Icon(
                      Icons.work_off_outlined,
                      color: Color(0xFF4F46E5),
                      size: 30,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "No jobs yet",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "When you accept a request (or waiting for customer confirmation), it will appear here.",
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

  Widget _jobCard(ServiceRequest r) {
    final statusLabel = _statusText(r.status);
    final statusColor = _statusColor(r.status);

    final stage = (r.progressStage).toString().trim();
    final loc = '${r.latitude}, ${r.longitude}';

    return Material(
      elevation: 7,
      shadowColor: Colors.black12,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () async {
          final updated = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ProviderRequestDetailsScreen(
                providerId: widget.providerId,
                request: r,
              ),
            ),
          );
          if (updated == true) _reload();
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
                      '${r.make} ${r.model} • ${r.plateNumber}',
                      style: const TextStyle(fontWeight: FontWeight.w900),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 10,
                      runSpacing: 8,
                      children: [
                        _pill('Status: $statusLabel',
                            icon: Icons.info_outline, color: statusColor),
                        _pill('Stage: ${stage.isEmpty ? '-' : stage}',
                            icon: Icons.timeline_outlined),
                        _pill('Location', icon: Icons.place_outlined),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      loc,
                      style: const TextStyle(color: Colors.black54),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right),
            ],
          ),
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
            colors: [Color(0xFFF5F7FF), Color(0xFFFFFBEB)],
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
                            'Error:\n${snap.error}',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    }

                    final all = snap.data ?? [];

                    final list = all.where((r) {
                      final s = r.status.toUpperCase();
                      return s == 'WAITING_CUSTOMER' || s == 'ACCEPTED';
                    }).toList();

                    list.sort((a, b) {
                      int rank(ServiceRequest r) {
                        final s = r.status.toUpperCase();
                        if (s == 'WAITING_CUSTOMER') return 0;
                        if (s == 'ACCEPTED') return 1;
                        return 2;
                      }

                      final ra = rank(a);
                      final rb = rank(b);
                      if (ra != rb) return ra.compareTo(rb);

                      // if createdAt can be null in your model, protect it:
                      final ac = a.createdAt;
                      final bc = b.createdAt;
                      return bc.compareTo(ac);
                    });

                    if (list.isEmpty) return _emptyState();

                    return RefreshIndicator(
                      onRefresh: _reload,
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(14, 6, 14, 22),
                        itemCount: list.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (_, i) => _jobCard(list[i]),
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
