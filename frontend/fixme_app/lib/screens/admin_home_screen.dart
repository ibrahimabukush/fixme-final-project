// lib/screens/admin_home_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/auth_service.dart';

class AdminHomeScreen extends StatefulWidget {
  final int adminUserId;

  const AdminHomeScreen({
    super.key,
    required this.adminUserId,
  });

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen>
    with SingleTickerProviderStateMixin {
  final String baseUrl = 'http://localhost:8081';

  late TabController _tabController;

  List<dynamic> _pendingProviders = [];
  List<dynamic> _providers = [];
  List<dynamic> _customers = [];

  bool _isLoading = false;

  // ✅ search
  final _searchCtrl = TextEditingController();
  String _query = '';

  Map<String, String> get _headers => {
        'Accept': 'application/json',
      };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() => setState(() {}));
    _loadAll();

    _searchCtrl.addListener(() {
      setState(() => _query = _searchCtrl.text.trim().toLowerCase());
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadAll() async {
    setState(() => _isLoading = true);
    try {
      await Future.wait([
        _fetchPendingProviders(),
        _fetchProviders(),
        _fetchCustomers(),
      ]);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchPendingProviders() async {
    final uri = Uri.parse('$baseUrl/api/admin/providers/pending');
    final res = await http.get(uri, headers: _headers);
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as List<dynamic>;
      if (mounted) setState(() => _pendingProviders = data);
    } else {
      _showSnack('Failed to load pending providers: ${res.statusCode}');
    }
  }

  Future<void> _fetchProviders() async {
    final uri = Uri.parse('$baseUrl/api/admin/providers');
    final res = await http.get(uri, headers: _headers);
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as List<dynamic>;
      if (mounted) setState(() => _providers = data);
    } else {
      _showSnack('Failed to load providers: ${res.statusCode}');
    }
  }

  Future<void> _fetchCustomers() async {
    final uri = Uri.parse('$baseUrl/api/admin/customers');
    final res = await http.get(uri, headers: _headers);
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as List<dynamic>;
      if (mounted) setState(() => _customers = data);
    } else {
      _showSnack('Failed to load customers: ${res.statusCode}');
    }
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<bool> _confirm({
    required String title,
    required String message,
    required String okText,
  }) async {
    return (await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(okText),
              ),
            ],
          ),
        )) ??
        false;
  }

  Future<void> _approveProvider(int userId) async {
    final ok = await _confirm(
      title: 'Approve Provider',
      message: 'Are you sure you want to approve this provider?',
      okText: 'Approve',
    );
    if (!ok) return;

    final uri = Uri.parse('$baseUrl/api/admin/providers/$userId/approve');
    final res = await http.post(uri);

    if (res.statusCode == 200) {
      _showSnack('Provider approved ✅');
      await _loadAll();
    } else {
      _showSnack('Approve failed: ${res.statusCode} - ${res.body}');
    }
  }

  Future<void> _rejectProvider(int userId) async {
    final ok = await _confirm(
      title: 'Reject Provider',
      message: 'Are you sure you want to reject this provider?',
      okText: 'Reject',
    );
    if (!ok) return;

    final uri = Uri.parse('$baseUrl/api/admin/providers/$userId/reject');
    final res = await http.post(uri);

    if (res.statusCode == 200) {
      _showSnack('Provider rejected ❌');
      await _loadAll();
    } else {
      _showSnack('Reject failed: ${res.statusCode} - ${res.body}');
    }
  }

  Future<void> _deleteCustomer(int userId) async {
    final ok = await _confirm(
      title: 'Delete Customer',
      message: 'This action cannot be undone. Delete this customer?',
      okText: 'Delete',
    );
    if (!ok) return;

    final uri = Uri.parse('$baseUrl/api/admin/customers/$userId');
    final res = await http.delete(uri);

    if (res.statusCode == 200) {
      _showSnack('Customer deleted');
      await _loadAll();
    } else {
      _showSnack('Delete failed: ${res.statusCode}');
    }
  }

  Future<void> _deleteProvider(int userId) async {
    final ok = await _confirm(
      title: 'Delete Provider',
      message: 'This action cannot be undone. Delete this provider?',
      okText: 'Delete',
    );
    if (!ok) return;

    final uri = Uri.parse('$baseUrl/api/admin/providers/$userId');
    final res = await http.delete(uri);

    if (res.statusCode == 200) {
      _showSnack('Provider deleted');
      await _loadAll();
    } else {
      _showSnack('Delete failed: ${res.statusCode}');
    }
  }

  // ================= UI =================

  Widget _topBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      child: Material(
        elevation: 8,
        shadowColor: Colors.black12,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
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
                  color: const Color(0xFFF0F9FF),
                ),
                child: const Icon(
                  Icons.admin_panel_settings_outlined,
                  color: Color(0xFF0284C7),
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Admin Dashboard",
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                    SizedBox(height: 2),
                    Text(
                      "Approve providers • Manage users",
                      style: TextStyle(fontSize: 12.5, color: Colors.black54),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Refresh',
                onPressed: _loadAll,
                icon: const Icon(Icons.refresh),
              ),
              IconButton(
                tooltip: 'Logout',
                onPressed: () async {
                  await AuthService.logout();
                  if (!mounted) return;
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/login',
                    (route) => false,
                  );
                },
                icon: const Icon(Icons.logout),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statsRow() {
    Widget stat({
      required String label,
      required int value,
      required IconData icon,
      required Color bg,
      required Color fg,
    }) {
      return Expanded(
        child: Material(
          elevation: 6,
          shadowColor: Colors.black12,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            padding: const EdgeInsets.all(12),
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
                    color: bg,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: fg),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(label,
                          style: const TextStyle(
                              fontSize: 12.5, color: Colors.black54)),
                      const SizedBox(height: 2),
                      Text(
                        '$value',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w900),
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

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
      child: Row(
        children: [
          stat(
            label: 'Pending',
            value: _pendingProviders.length,
            icon: Icons.hourglass_bottom,
            bg: const Color(0xFFFFF7ED),
            fg: const Color(0xFFEA580C),
          ),
          const SizedBox(width: 10),
          stat(
            label: 'Providers',
            value: _providers.length,
            icon: Icons.storefront_outlined,
            bg: const Color(0xFFEFF6FF),
            fg: const Color(0xFF2563EB),
          ),
          const SizedBox(width: 10),
          stat(
            label: 'Customers',
            value: _customers.length,
            icon: Icons.directions_car_outlined,
            bg: const Color(0xFFECFDF5),
            fg: const Color(0xFF16A34A),
          ),
        ],
      ),
    );
  }

  Widget _searchBar() {
    final hint = _tabController.index == 0
        ? 'Search pending providers…'
        : _tabController.index == 1
            ? 'Search providers…'
            : 'Search customers…';

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
      child: Material(
        elevation: 6,
        shadowColor: Colors.black12,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFEAEAF2)),
          ),
          child: TextField(
            controller: _searchCtrl,
            decoration: InputDecoration(
              hintText: hint,
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _query.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Clear',
                      icon: const Icon(Icons.clear),
                      onPressed: () => _searchCtrl.clear(),
                    ),
              filled: true,
              fillColor: const Color(0xFFF6F7FB),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _tabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Material(
        elevation: 6,
        shadowColor: Colors.black12,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFEAEAF2)),
          ),
          child: Container(
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF6F7FB),
              borderRadius: BorderRadius.circular(14),
            ),
            child: TabBar(
              controller: _tabController,
              dividerColor: Colors.transparent,
              indicatorSize: TabBarIndicatorSize.tab,
              labelStyle: const TextStyle(fontWeight: FontWeight.w900),
              labelColor: Colors.black,
              unselectedLabelColor: Colors.black54,
              indicator: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFEAEAF2)),
              ),
              tabs: const [
                Tab(text: 'Pending'),
                Tab(text: 'Providers'),
                Tab(text: 'Customers'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _chip(String text, {IconData? icon}) {
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
            Icon(icon, size: 16),
            const SizedBox(width: 6),
          ],
          Text(text, style: const TextStyle(fontSize: 12.5)),
        ],
      ),
    );
  }

  Widget _sectionEmpty(String text) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(text, style: const TextStyle(color: Colors.black54)),
      ),
    );
  }

  Widget _userCard({
    required String title,
    required String subtitle,
    required Widget trailing,
    List<Widget>? chips,
  }) {
    return Material(
      elevation: 7,
      shadowColor: Colors.black12,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFEAEAF2)),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          leading: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.person_outline),
          ),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(subtitle),
              if (chips != null && chips.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(spacing: 8, runSpacing: 8, children: chips),
              ],
            ],
          ),
          trailing: trailing,
          isThreeLine: true,
        ),
      ),
    );
  }

  bool _matchQuery(Map<String, dynamic> obj, List<String> keys) {
    if (_query.isEmpty) return true;
    final hay = keys
        .map((k) => (obj[k] ?? '').toString().toLowerCase())
        .join(' | ');
    return hay.contains(_query);
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
              _statsRow(),
              _tabs(),
              const SizedBox(height: 10),
              _searchBar(),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : TabBarView(
                        controller: _tabController,
                        children: [
                          _buildPendingProvidersTab(),
                          _buildProvidersTab(),
                          _buildCustomersTab(),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= TABS =================

  Widget _buildPendingProvidersTab() {
    final filtered = _pendingProviders
        .where((e) => _matchQuery(e as Map<String, dynamic>, [
              'businessName',
              'firstName',
              'lastName',
              'email',
              'phone',
              'city',
            ]))
        .toList();

    if (filtered.isEmpty) {
      return _sectionEmpty(_query.isEmpty
          ? 'No providers waiting for approval.'
          : 'No results for "$_query".');
    }

    return RefreshIndicator(
      onRefresh: _fetchPendingProviders,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(14, 6, 14, 20),
        itemCount: filtered.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final p = filtered[index] as Map<String, dynamic>;
          final userId = p['userId'] as int;

          final fullName = '${p['firstName'] ?? ''} ${p['lastName'] ?? ''}'.trim();
          final businessName = (p['businessName'] ?? 'No business name').toString();
          final city = (p['city'] ?? '').toString();
          final email = (p['email'] ?? '').toString();
          final phone = (p['phone'] ?? '').toString();

          return _userCard(
            title: businessName,
            subtitle: [
              if (fullName.isNotEmpty) fullName,
              if (email.isNotEmpty) email,
              if (phone.isNotEmpty) phone,
            ].join('\n'),
            chips: [
              if (city.isNotEmpty) _chip(city, icon: Icons.location_on_outlined),
              _chip('Pending', icon: Icons.hourglass_bottom),
            ],
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: 'Approve',
                  icon: const Icon(Icons.check_circle_outline, color: Colors.green),
                  onPressed: () => _approveProvider(userId),
                ),
                IconButton(
                  tooltip: 'Reject',
                  icon: const Icon(Icons.cancel_outlined, color: Colors.red),
                  onPressed: () => _rejectProvider(userId),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProvidersTab() {
    final filtered = _providers
        .where((e) => _matchQuery(e as Map<String, dynamic>, [
              'firstName',
              'lastName',
              'email',
              'phone',
            ]))
        .toList();

    if (filtered.isEmpty) {
      return _sectionEmpty(_query.isEmpty ? 'No providers found.' : 'No results for "$_query".');
    }

    return RefreshIndicator(
      onRefresh: _fetchProviders,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(14, 6, 14, 20),
        itemCount: filtered.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final u = filtered[index] as Map<String, dynamic>;
          final userId = u['id'] as int;

          final fullName = '${u['firstName'] ?? ''} ${u['lastName'] ?? ''}'.trim();
          final email = (u['email'] ?? '').toString();
          final phone = (u['phone'] ?? '').toString();

          return _userCard(
            title: fullName.isEmpty ? 'Provider #$userId' : fullName,
            subtitle: [email, phone].where((s) => s.trim().isNotEmpty).join('\n'),
            chips: [_chip('Provider', icon: Icons.storefront_outlined)],
            trailing: IconButton(
              tooltip: 'Delete provider',
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () => _deleteProvider(userId),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCustomersTab() {
    final filtered = _customers
        .where((e) => _matchQuery(e as Map<String, dynamic>, [
              'firstName',
              'lastName',
              'email',
              'phone',
            ]))
        .toList();

    if (filtered.isEmpty) {
      return _sectionEmpty(_query.isEmpty ? 'No customers found.' : 'No results for "$_query".');
    }

    return RefreshIndicator(
      onRefresh: _fetchCustomers,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(14, 6, 14, 20),
        itemCount: filtered.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final u = filtered[index] as Map<String, dynamic>;
          final userId = u['id'] as int;

          final fullName = '${u['firstName'] ?? ''} ${u['lastName'] ?? ''}'.trim();
          final email = (u['email'] ?? '').toString();
          final phone = (u['phone'] ?? '').toString();

          return _userCard(
            title: fullName.isEmpty ? 'Customer #$userId' : fullName,
            subtitle: [email, phone].where((s) => s.trim().isNotEmpty).join('\n'),
            chips: [_chip('Customer', icon: Icons.directions_car_outlined)],
            trailing: IconButton(
              tooltip: 'Delete customer',
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () => _deleteCustomer(userId),
            ),
          );
        },
      ),
    );
  }
}
