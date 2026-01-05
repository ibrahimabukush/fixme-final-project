import 'package:flutter/material.dart';
import '../../models/service_request.dart';
import '../../services/provider_requests_service.dart';
import 'provider_request_details_screen.dart';

class ProviderHistoryScreen extends StatefulWidget {
  final int providerId;
  const ProviderHistoryScreen({super.key, required this.providerId});

  @override
  State<ProviderHistoryScreen> createState() => _ProviderHistoryScreenState();
}

class _ProviderHistoryScreenState extends State<ProviderHistoryScreen> {
  late Future<List<ServiceRequest>> _future;

  @override
  void initState() {
    super.initState();
    _future = ProviderRequestsService.inbox(
      providerId: widget.providerId,
      status: 'DONE',
    );
  }

  Future<void> _reload() async {
    setState(() {
      _future = ProviderRequestsService.inbox(
        providerId: widget.providerId,
        status: 'DONE',
      );
    });
  }

  // ---------- UI helpers ----------

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
                child: const Icon(Icons.history,
                    color: Color(0xFF4F46E5)),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "History (Done Jobs)",
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                    SizedBox(height: 2),
                    Text(
                      "Completed requests only",
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
                    "No done jobs yet",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "When you finish a request, it will appear here.",
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

  Widget _historyCard(ServiceRequest r) {
    final stage = (r.progressStage).toString().trim();
    final status = (r.status).toString().toUpperCase();

    return Material(
      elevation: 7,
      shadowColor: Colors.black12,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ProviderRequestDetailsScreen(
                providerId: widget.providerId,
                request: r,
              ),
            ),
          );
          _reload();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
                child: const Icon(Icons.directions_car_outlined,
                    color: Color(0xFF2563EB)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${r.make} ${r.model} • ${r.plateNumber}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 14.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 10,
                      runSpacing: 8,
                      children: [
                        if (stage.isNotEmpty) _pill('Stage: $stage', icon: Icons.timeline_outlined),
                        _pill('Status: $status', icon: Icons.verified_outlined),
                        _pill(
                          '${r.latitude}, ${r.longitude}',
                          icon: Icons.location_on_outlined,
                        ),
                      ],
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

  // ---------- Build ----------

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
                            'Failed to load history:\n${snap.error}',
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
                        itemCount: list.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (_, i) => _historyCard(list[i]),
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
