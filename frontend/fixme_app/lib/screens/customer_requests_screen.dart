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

  Future<void> _confirm(int requestId) async {
    try {
      final r =
          await CustomerApi.confirmRequest(userId: widget.userId, requestId: requestId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Confirmed ✅ (Status: ${r.status})')),
      );
      _reload();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Confirm failed: $e')),
      );
    }
  }

  void _openChat(ServiceRequest r) {
    Navigator.push(
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Requests Need Confirm'),
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

          // ✅ ONLY requests waiting for customer confirmation
          final list =
              all.where((r) => r.status.toUpperCase() == 'WAITING_CUSTOMER').toList();

          if (list.isEmpty) {
            return const Center(child: Text('No requests need confirmation ✅'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(14),
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
                  subtitle: Text('Status: ${r.status}\nCategory: ${r.vehicleCategory}'),
                  trailing: Wrap(
                    spacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      IconButton(
                        tooltip: 'Chat',
                        icon: const Icon(Icons.chat_bubble_outline),
                        onPressed: () => _openChat(r),
                      ),
                      ElevatedButton(
                        onPressed: () => _confirm(r.id),
                        child: const Text('Confirm'),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
