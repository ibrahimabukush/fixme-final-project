import 'package:flutter/material.dart';
import '../models/service_request.dart';
import '../services/service_request_service.dart';

class MyRequestsScreen extends StatefulWidget {
  final int userId;

  const MyRequestsScreen({super.key, required this.userId});

  @override
  State<MyRequestsScreen> createState() => _MyRequestsScreenState();
}

class _MyRequestsScreenState extends State<MyRequestsScreen> {
  late Future<List<ServiceRequest>> _future;

  @override
  void initState() {
    super.initState();
    _future = ServiceRequestService.getMyRequests(userId: widget.userId);
  }

  Future<void> _reload() async {
    setState(() {
      _future = ServiceRequestService.getMyRequests(userId: widget.userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Requests')),
      body: FutureBuilder<List<ServiceRequest>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('Error: ${snap.error}'));
          }

          final items = snap.data ?? [];
          if (items.isEmpty) {
            return const Center(child: Text('No requests yet'));
          }

          return RefreshIndicator(
            onRefresh: _reload,
            child: ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) {
                final r = items[i];
                return Card(
                  child: ListTile(
                    title: Text('${r.make} ${r.model} • ${r.plateNumber}'),
                    subtitle: Text('Status: ${r.status}\n${r.createdAt}'),
                    isThreeLine: true,
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
