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

  // ✅ filter/sort
  String _filter = 'ALL'; // ALL / ACTIVE / DONE
  bool _latestFirst = true;

  @override
  void initState() {
    super.initState();
    _future = ServiceRequestService.getMyRequests(userId: widget.userId);
  }

  Future<void> _reload() async {
    setState(() {
      _future = ServiceRequestService.getMyRequests(userId: widget.userId);
    });
    // ✅ لا تعمل await _future هون (RefreshIndicator already waits)
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

  Widget _pill(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Text(text, style: const TextStyle(fontSize: 12.5)),
    );
  }

  Color _statusColor(String statusUpper) {
    switch (statusUpper) {
      case 'DONE':
        return const Color(0xFF16A34A);
      case 'ACCEPTED':
        return const Color(0xFF2563EB);
      case 'WAITING_CUSTOMER':
        return const Color(0xFFF59E0B);
      case 'WAITING_PROVIDER':
      case 'PENDING':
      default:
        return const Color(0xFF6B7280);
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
    _reload();
  }

  // ✅ robust parsing (supports ISO + "yyyy-MM-dd HH:mm:ss" + fallback)
  DateTime _safeDate(String raw) {
    final s = raw.trim();
    // try ISO
    final iso = DateTime.tryParse(s);
    if (iso != null) return iso;

    // try "yyyy-MM-dd HH:mm:ss"
    try {
      final parts = s.split(' ');
      if (parts.length >= 2) {
        final d = parts[0].split('-').map(int.parse).toList();
        final t = parts[1].split(':').map((x) => int.parse(x)).toList();
        final y = d[0], m = d[1], day = d[2];
        final hh = t[0], mm = t[1], ss = t.length > 2 ? t[2] : 0;
        return DateTime(y, m, day, hh, mm, ss);
      }
    } catch (_) {}

    // fallback: now so sorting will not crash
    return DateTime.fromMillisecondsSinceEpoch(0);
  }

  String _prettyDate(String raw) {
    final dt = _safeDate(raw);
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    final hh = dt.hour.toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');
    return '$y-$m-$d  $hh:$mm';
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
                      Icons.receipt_long,
                      color: Color(0xFF4F46E5),
                      size: 30,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "No requests yet",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "When you send a service request, it will appear here.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black54),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    height: 46,
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4F46E5),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      icon: const Icon(Icons.arrow_back),
                      label: const Text(
                        "Back",
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

  Widget _requestCard(ServiceRequest r) {
    final statusUpper = r.status.toUpperCase().trim();
    final stageRaw = (r.progressStage).toString().trim(); // ✅ null-safe
    final stageText = stageRaw.isEmpty ? '-' : _stageLabel(stageRaw);

    final canChat =
        statusUpper == 'WAITING_CUSTOMER' || statusUpper == 'ACCEPTED' || statusUpper == 'DONE';

    final badgeColor = _statusColor(statusUpper);

    return Material(
      elevation: 6,
      shadowColor: Colors.black12,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: Colors.white,
          border: Border.all(color: const Color(0xFFEAEAF2)),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          leading: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: const Color(0xFFEEF2FF),
            ),
            child: const Icon(Icons.directions_car_filled_outlined, color: Color(0xFF4F46E5)),
          ),
          title: Text(
            '${r.make} ${r.model} • ${r.plateNumber}',
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 10,
                  runSpacing: 6,
                  children: [
                    _pill('Status: ${_statusLabel(r.status)}'),
                    _pill('Progress: $stageText'),
                    _pill('Date: ${_prettyDate(r.createdAt)}'),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: badgeColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: badgeColor.withOpacity(0.25)),
                      ),
                      child: Text(
                        statusUpper,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                          color: badgeColor,
                        ),
                      ),
                    ),
                    const Spacer(),
                    if (canChat)
                      TextButton.icon(
                        onPressed: () => _openChat(r),
                        icon: const Icon(Icons.chat_bubble_outline, size: 18),
                        label: const Text('Chat'),
                      )
                    else
                      const Text(
                        'Chat unavailable yet',
                        style: TextStyle(fontSize: 12.5, color: Colors.black54),
                      ),
                  ],
                ),
              ],
            ),
          ),
          onTap: canChat ? () => _openChat(r) : null,
        ),
      ),
    );
  }

  List<ServiceRequest> _applyFilterAndSort(List<ServiceRequest> items) {
    var list = List<ServiceRequest>.from(items);

    if (_filter == 'ACTIVE') {
      list = list.where((r) => r.status.toUpperCase() != 'DONE').toList();
    } else if (_filter == 'DONE') {
      list = list.where((r) => r.status.toUpperCase() == 'DONE').toList();
    }

    // ✅ always sortable (safeDate fallback)
    list.sort((a, b) {
      final da = _safeDate(a.createdAt);
      final db = _safeDate(b.createdAt);
      return _latestFirst ? db.compareTo(da) : da.compareTo(db);
    });

    return list;
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
                child: const Icon(Icons.history, color: Color(0xFF4F46E5)),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('My Requests', style: TextStyle(fontWeight: FontWeight.w900)),
                    SizedBox(height: 2),
                    Text('Track all your requests & chat',
                        style: TextStyle(fontSize: 12.5, color: Colors.black54)),
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

  // ✅ nicer pills for filter
  Widget _segButton(String label, String value) {
    final selected = _filter == value;
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: () => setState(() => _filter = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF4F46E5) : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: selected ? const Color(0xFF4F46E5) : const Color(0xFFE5E7EB)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w800,
            color: selected ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _filtersRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
      child: Row(
        children: [
          Material(
            elevation: 6,
            shadowColor: Colors.black12,
            borderRadius: BorderRadius.circular(18),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFEAEAF2)),
              ),
              child: Row(
                children: [
                  _segButton('All', 'ALL'),
                  const SizedBox(width: 8),
                  _segButton('Active', 'ACTIVE'),
                  const SizedBox(width: 8),
                  _segButton('Done', 'DONE'),
                ],
              ),
            ),
          ),
          const Spacer(),
          OutlinedButton.icon(
            onPressed: () => setState(() => _latestFirst = !_latestFirst),
            icon: const Icon(Icons.sort),
            label: Text(_latestFirst ? 'Latest' : 'Oldest'),
          ),
        ],
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
            colors: [Color(0xFFF5F7FF), Color(0xFFFDF2F8)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _topBar(),
              _filtersRow(),
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
                            'Error: ${snap.error}',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    }

                    final items = _applyFilterAndSort(snap.data ?? []);
                    if (items.isEmpty) return _emptyState();

                    return RefreshIndicator(
                      onRefresh: _reload,
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(14, 6, 14, 22),
                        itemCount: items.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (_, i) => _requestCard(items[i]),
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
