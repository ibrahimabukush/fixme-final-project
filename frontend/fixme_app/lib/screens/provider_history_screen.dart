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
    _future = ProviderRequestsService.inbox(providerId: widget.providerId, status: 'DONE');
  }

  Future<void> _reload() async {
    setState(() {
      _future = ProviderRequestsService.inbox(providerId: widget.providerId, status: 'DONE');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('History (Done Jobs)'),
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

          final list = snap.data ?? [];
          if (list.isEmpty) {
            return const Center(child: Text('No done jobs yet'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) {
              final r = list[i];
              return Card(
                child: ListTile(
                  title: Text(
                    '${r.make} ${r.model} • ${r.plateNumber}',
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  subtitle: Text(
                    'Stage: ${r.progressStage}\nStatus: ${r.status}\nLocation: ${r.latitude}, ${r.longitude}',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () async {
                    // optional: open details read-only
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
                ),
              );
            },
          );
        },
      ),
    );
  }
}
