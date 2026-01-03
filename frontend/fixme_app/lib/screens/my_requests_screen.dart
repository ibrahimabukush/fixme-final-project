import 'package:flutter/material.dart';
import '../models/service_request.dart';
import '../services/service_request_service.dart';
import 'chat_screen.dart';

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

  String _stageLabel(String s) {
    switch (s.toUpperCase()) {
      case 'ON_THE_WAY':
        return 'On the way';
      case 'DIAGNOSING':
        return 'Diagnosing';
      case 'FIXING':
        return 'Fixing';
      case 'DONE':
        return 'Done';
      default:
        return s;
    }
  }

  String _statusLabel(String s) {
    switch (s.toUpperCase()) {
      case 'PENDING':
        return 'Pending (waiting for provider)';
      case 'WAITING_PROVIDER':
        return 'Waiting for provider';
      case 'WAITING_CUSTOMER':
        return 'Waiting for your confirmation';
      case 'ACCEPTED':
        return 'Confirmed ✅';
      case 'DONE':
        return 'Completed ✅';
      default:
        return s;
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
    _reload(); // ✅ reload automatically after returning from chat
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Requests'),
        actions: [
          IconButton(onPressed: _reload, icon: const Icon(Icons.refresh)),
        ],
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

                final status = (r.status).trim();
                final stageRaw = ((r.progressStage)).trim();
                final stageText = stageRaw.isEmpty ? '-' : _stageLabel(stageRaw);

                final statusUpper = status.toUpperCase();
                final canChat = statusUpper == 'WAITING_CUSTOMER' ||
                    statusUpper == 'ACCEPTED' ||
                    statusUpper == 'DONE';

                return Card(
                  child: ListTile(
                    title: Text(
                      '${r.make} ${r.model} • ${r.plateNumber}',
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    subtitle: Text(
                      'Status: ${_statusLabel(status)}\n'
                      'Progress: $stageText\n'
                      '${r.createdAt}',
                    ),
                    isThreeLine: true,
                    trailing: canChat
                        ? IconButton(
                            tooltip: 'Chat',
                            icon: const Icon(Icons.chat_bubble_outline),
                            onPressed: () => _openChat(r),
                          )
                        : null,
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
