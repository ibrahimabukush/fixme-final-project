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
    // ✅ load all requests, then we filter in UI to show ACCEPTED + WAITING_CUSTOMER
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Jobs'),
        actions: [IconButton(onPressed: _reload, icon: const Icon(Icons.refresh))],
      ),
      body: FutureBuilder<List<ServiceRequest>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('Error: ${snap.error}'));
          }

          final all = snap.data ?? [];

          // ✅ show both: waiting customer + accepted
          final list = all.where((r) {
            final s = r.status.toUpperCase();
            return s == 'WAITING_CUSTOMER' || s == 'ACCEPTED';
          }).toList();

          // optional: sort so waiting customer comes first
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
            return b.createdAt.compareTo(a.createdAt);
          });

          if (list.isEmpty) {
            return const Center(child: Text('No jobs yet'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) {
              final r = list[i];
              final statusLabel = _statusText(r.status);

              return Card(
                child: ListTile(
                  title: Text(
                    '${r.make} ${r.model} • ${r.plateNumber}',
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  subtitle: Text(
                    'Status: $statusLabel\nStage: ${r.progressStage}\nLocation: ${r.latitude}, ${r.longitude}',
                  ),
                  trailing: const Icon(Icons.chevron_right),
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
                ),
              );
            },
          );
        },
      ),
    );
  }
}
