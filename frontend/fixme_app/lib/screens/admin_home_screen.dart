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
  // Web/Windows: localhost. Emulator: 10.0.2.2
  final String baseUrl = 'http://localhost:8081';

  late TabController _tabController;

  List<dynamic> _pendingProviders = [];
  List<dynamic> _providers = [];
  List<dynamic> _customers = [];

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadAll();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // If you later want to secure endpoints with JWT:
  // Map<String, String> get _authHeaders => {
  //   'Accept': 'application/json',
  //   'Content-Type': 'application/json',
  //   if (AuthService.token != null) 'Authorization': 'Bearer ${AuthService.token}',
  // };

  Map<String, String> get _headers => {
        'Accept': 'application/json',
      };

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
                child: const Icon(Icons.admin_panel_settings_outlined,
                    color: Color(0xFF0284C7)),
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

  Widget _chip(String text, {IconData? icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(999),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // Modern background
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
              Padding(
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
                    child: TabBar(
                      controller: _tabController,
                      labelStyle: const TextStyle(fontWeight: FontWeight.w800),
                      tabs: const [
                        Tab(text: 'Pending'),
                        Tab(text: 'Providers'),
                        Tab(text: 'Customers'),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
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

  Widget _buildPendingProvidersTab() {
    if (_pendingProviders.isEmpty) {
      return _sectionEmpty('No providers waiting for approval.');
    }

    return RefreshIndicator(
      onRefresh: _fetchPendingProviders,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(14, 6, 14, 20),
        itemCount: _pendingProviders.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final p = _pendingProviders[index] as Map<String, dynamic>;
          final userId = p['userId'] as int;

          final fullName =
              '${p['firstName'] ?? ''} ${p['lastName'] ?? ''}'.trim();
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
    if (_providers.isEmpty) {
      return _sectionEmpty('No providers found.');
    }

    return RefreshIndicator(
      onRefresh: _fetchProviders,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(14, 6, 14, 20),
        itemCount: _providers.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final u = _providers[index] as Map<String, dynamic>;
          final userId = u['id'] as int;

          final fullName =
              '${u['firstName'] ?? ''} ${u['lastName'] ?? ''}'.trim();
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
    if (_customers.isEmpty) {
      return _sectionEmpty('No customers found.');
    }

    return RefreshIndicator(
      onRefresh: _fetchCustomers,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(14, 6, 14, 20),
        itemCount: _customers.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final u = _customers[index] as Map<String, dynamic>;
          final userId = u['id'] as int;

          final fullName =
              '${u['firstName'] ?? ''} ${u['lastName'] ?? ''}'.trim();
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
