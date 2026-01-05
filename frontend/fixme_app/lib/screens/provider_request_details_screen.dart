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
    _selectedStage = stage.isEmpty ? 'ON_THE_WAY' : stage.toUpperCase();
    if (!_stages.contains(_selectedStage)) _selectedStage = 'ON_THE_WAY';
  }

  // ---------- helpers ----------

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
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

  Color _stageColor(String stage) {
    switch (stage.toUpperCase()) {
      case 'ON_THE_WAY':
        return const Color(0xFF2563EB); // blue
      case 'DIAGNOSING':
        return const Color(0xFFF59E0B); // amber
      case 'FIXING':
        return const Color(0xFF7C3AED); // purple
      case 'DONE':
        return const Color(0xFF10B981); // green
      default:
        return const Color(0xFF6B7280);
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
              fontWeight: FontWeight.w800,
              color: color ?? const Color(0xFF111827),
            ),
          ),
        ],
      ),
    );
  }

  Widget _section({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Material(
      elevation: 8,
      shadowColor: Colors.black12,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFEAEAF2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: const Color(0xFFEEF2FF),
                  ),
                  child: Icon(icon, color: const Color(0xFF4F46E5)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _kv(String k, String v) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              k,
              style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.black87),
            ),
          ),
          Expanded(
            child: Text(
              v,
              style: const TextStyle(color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  // ---------- actions ----------

  Future<void> _saveStage() async {
    if (_loading) return;

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
        final s = (updated.progressStage).trim().toUpperCase();
        _selectedStage = s.isEmpty ? 'ON_THE_WAY' : s;
        if (!_stages.contains(_selectedStage)) _selectedStage = 'ON_THE_WAY';
      });

      _snack('Progress updated ✅');

      final stageNow = (updated.progressStage).toUpperCase();
      final statusNow = (updated.status).toUpperCase();

      // if marked done, go to history
      if (stageNow == 'DONE' || statusNow == 'DONE') {
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
      _snack('Failed: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _openChat(ServiceRequest r, {required bool readOnly}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatScreen(
          requestId: r.id,
          userId: widget.providerId,
          role: 'PROVIDER',
          readOnly: readOnly,
        ),
      ),
    );
    // optional: refresh details after chat (if you later add API to refresh request)
  }

  // ---------- build ----------

  @override
  Widget build(BuildContext context) {
    final r = _req;

    final status = (r.status).toUpperCase();
    final stageNow = (r.progressStage).toUpperCase();

    final isDone = status == 'DONE' || stageNow == 'DONE';
    final isWaitingCustomer = status == 'WAITING_CUSTOMER';

    // provider can edit ONLY after customer confirms => ACCEPTED
    final canEditProgress = status == 'ACCEPTED' && !isDone;

    // chat allowed after accept and later; in DONE make it read-only
    final canChat = status == 'WAITING_CUSTOMER' || status == 'ACCEPTED' || status == 'DONE';
    final readOnlyChat = status == 'DONE';

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
              // Top bar (same style as your other screens)
              Padding(
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
                            Icons.assignment_turned_in_outlined,
                            color: Color(0xFF2563EB),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Request Details",
                                style: TextStyle(fontWeight: FontWeight.w900),
                              ),
                              const SizedBox(height: 2),
                              Wrap(
                                spacing: 8,
                                runSpacing: 6,
                                children: [
                                  _pill(
                                    "Status: $status",
                                    icon: Icons.info_outline,
                                    color: _statusColor(status),
                                  ),
                                  _pill(
                                    "Stage: ${_stageLabel(stageNow.isEmpty ? 'ON_THE_WAY' : stageNow)}",
                                    icon: Icons.timeline_outlined,
                                    color: _stageColor(stageNow.isEmpty ? 'ON_THE_WAY' : stageNow),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        if (canChat)
                          IconButton(
                            tooltip: 'Chat',
                            onPressed: () => _openChat(r, readOnly: readOnlyChat),
                            icon: const Icon(Icons.chat_bubble_outline),
                          ),
                        IconButton(
                          tooltip: "Back",
                          onPressed: () => Navigator.pop(context, false),
                          icon: const Icon(Icons.arrow_back),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(14, 6, 14, 22),
                  children: [
                    _section(
                      title: 'Car details',
                      icon: Icons.directions_car_outlined,
                      children: [
                        _kv('Make', r.make),
                        _kv('Model', r.model),
                        _kv('Plate', r.plateNumber),
                        _kv('Year', (r.year ?? '-').toString()),
                        _kv('Category', _prettyCategory(r.vehicleCategory)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _section(
                      title: 'Problem details',
                      icon: Icons.report_gmailerrorred_outlined,
                      children: [
                        _kv('Description', r.description),
                        _kv('Location', '${r.latitude}, ${r.longitude}'),
                        _kv('Status', r.status),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _section(
                      title: 'Progress',
                      icon: Icons.timeline_outlined,
                      children: [
                        DropdownButtonFormField<String>(
                          value: _selectedStage,
                          decoration: InputDecoration(
                            labelText: 'Stage',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          items: _stages
                              .map(
                                (s) => DropdownMenuItem(
                                  value: s,
                                  child: Text(_stageLabel(s)),
                                ),
                              )
                              .toList(),
                          onChanged: (_loading || !canEditProgress)
                              ? null
                              : (v) => setState(() {
                                    _selectedStage = (v ?? _selectedStage).toUpperCase();
                                  }),
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
                                  style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
