import 'package:flutter/material.dart';
import '../models/service_request.dart';
import '../services/provider_requests_service.dart';
import 'provider_history_screen.dart';
import 'chat_screen.dart';

class ProviderRequestDetailsScreen extends StatefulWidget {
  final int providerId;
  final ServiceRequest request;

  const ProviderRequestDetailsScreen({
    super.key,
    required this.providerId,
    required this.request,
  });

  @override
  State<ProviderRequestDetailsScreen> createState() =>
      _ProviderRequestDetailsScreenState();
}

class _ProviderRequestDetailsScreenState
    extends State<ProviderRequestDetailsScreen> {
  late ServiceRequest _req;
  late String _selectedStage;
  bool _loading = false;

  static const List<String> _stages = [
    'ON_THE_WAY',
    'DIAGNOSING',
    'FIXING',
    'DONE',
  ];

  @override
  void initState() {
    super.initState();
    _req = widget.request;

    final stage = (_req.progressStage).trim();
    _selectedStage = stage.isEmpty ? 'ON_THE_WAY' : stage;
    if (!_stages.contains(_selectedStage)) _selectedStage = 'ON_THE_WAY';
  }

  String _stageLabel(String s) {
    switch (s) {
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

  Future<void> _saveStage() async {
    setState(() => _loading = true);
    try {
      final updated = await ProviderRequestsService.updateProgress(
        providerId: widget.providerId,
        requestId: _req.id,
        progressStage: _selectedStage,
      );

      if (!mounted) return;

      setState(() {
        _req = updated;
        _selectedStage = (updated.progressStage).trim().isEmpty
            ? 'ON_THE_WAY'
            : (updated.progressStage);
        if (!_stages.contains(_selectedStage)) _selectedStage = 'ON_THE_WAY';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Progress updated ✅')),
      );

      final stageNow = ((updated.progressStage)).toUpperCase();
      if (stageNow == 'DONE') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ProviderHistoryScreen(providerId: widget.providerId),
          ),
        );
        return;
      }

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Widget _card({required String title, required List<Widget> children}) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
            const SizedBox(height: 10),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _row(String k, String v) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(
              width: 110,
              child: Text(k, style: const TextStyle(fontWeight: FontWeight.w800))),
          Expanded(child: Text(v)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final r = _req;

    final status = (r.status).toUpperCase();
    final stageNow = ((r.progressStage)).toUpperCase();

    // ✅ DONE: read-only
    final isDone = status == 'DONE' || stageNow == 'DONE';

    // ✅ قبل تأكيد الزبون: لا تعديل progress
    final isWaitingCustomer = status == 'WAITING_CUSTOMER';

    // ✅ provider can edit ONLY after customer confirms => ACCEPTED
    final canEditProgress = status == 'ACCEPTED' && !isDone;

    // ✅ chat is available after accept (WAITING_CUSTOMER) and after confirm (ACCEPTED) and even DONE (read-only optional)
    final canChat = status == 'WAITING_CUSTOMER' || status == 'ACCEPTED' || status == 'DONE';
    final readOnlyChat = status == 'DONE';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Request Details'),
        actions: [
          if (canChat)
            IconButton(
              tooltip: 'Chat',
              icon: const Icon(Icons.chat_bubble_outline),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChatScreen(
                      requestId: r.id,
                      userId: widget.providerId,
                      role: 'PROVIDER',
                      readOnly: readOnlyChat,
                    ),
                  ),
                );
              },
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          _card(
            title: 'Car details',
            children: [
              _row('Make', r.make),
              _row('Model', r.model),
              _row('Plate', r.plateNumber),
              _row('Year', (r.year ?? '-').toString()),
              _row('Category', r.vehicleCategory),
            ],
          ),
          const SizedBox(height: 12),
          _card(
            title: 'Problem details',
            children: [
              _row('Description', r.description),
              _row('Location', '${r.latitude}, ${r.longitude}'),
              _row('Status', r.status),
            ],
          ),
          const SizedBox(height: 12),
          _card(
            title: 'Progress',
            children: [
              DropdownButtonFormField<String>(
                value: _selectedStage,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Stage',
                ),
                items: _stages
                    .map((s) => DropdownMenuItem(
                          value: s,
                          child: Text(_stageLabel(s)),
                        ))
                    .toList(),
                onChanged: (_loading || !canEditProgress)
                    ? null
                    : (v) => setState(() => _selectedStage = v ?? _selectedStage),
              ),

              if (isWaitingCustomer) ...[
                const SizedBox(height: 10),
                const Text(
                  'Waiting for customer confirmation. You can update progress only after the customer confirms.',
                  style: TextStyle(color: Colors.black54),
                ),
              ],

              if (isDone) ...[
                const SizedBox(height: 10),
                const Text(
                  'This job is completed. Progress cannot be changed.',
                  style: TextStyle(color: Colors.black54),
                ),
              ],

              const SizedBox(height: 12),
              SizedBox(
                height: 46,
                width: double.infinity,
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: canEditProgress ? _saveStage : null,
                        child: Text(
                          isDone
                              ? 'Already Done'
                              : isWaitingCustomer
                                  ? 'Waiting for customer confirm'
                                  : 'Save progress',
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
