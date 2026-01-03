// lib/screens/provider_home_screen.dart
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'profile_screen.dart';
import 'provider_business_screen.dart';
import 'provider_nearby_requests_screen.dart';
import 'provider_jobs_screen.dart';
import 'provider_history_screen.dart';

class ProviderHomeScreen extends StatelessWidget {
  final int userId;

  const ProviderHomeScreen({
    super.key,
    required this.userId,
  });

  void _openProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProfileScreen(userId: userId),
      ),
    );
  }

  void _openBusinessProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProviderBusinessScreen(userId: userId),
      ),
    );
  }

  void _openNearbyRequests(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProviderNearbyRequestsScreen(userId: userId),
      ),
    );
  }

  void _openJobs(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProviderJobsScreen(providerId: userId),
      ),
    );
  }

  // ✅ NEW: History page (DONE jobs)
  void _openHistory(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProviderHistoryScreen(providerId: userId),
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    await AuthService.logout();
    if (!context.mounted) return;
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/login',
      (route) => false,
    );
  }

  Widget _topBar(BuildContext context) {
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
                  color: const Color(0xFFEFF6FF),
                ),
                child: const Icon(
                  Icons.handyman_outlined,
                  color: Color(0xFF2563EB),
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Provider Dashboard",
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                    SizedBox(height: 2),
                    Text(
                      "Manage your business & requests",
                      style: TextStyle(fontSize: 12.5, color: Colors.black54),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Profile',
                onPressed: () => _openProfile(context),
                icon: const Icon(Icons.person_outline),
              ),
              IconButton(
                tooltip: 'Logout',
                onPressed: () => _logout(context),
                icon: const Icon(Icons.logout),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _actionCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      elevation: 7,
      shadowColor: Colors.black12,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFEAEAF2)),
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: const Color(0xFFF3F4F6),
                ),
                child: Icon(icon, color: const Color(0xFF111827)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
                    const SizedBox(height: 4),
                    Text(subtitle, style: const TextStyle(color: Colors.black54)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
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
            colors: [
              Color(0xFFF5F7FF),
              Color(0xFFFFFBEB),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _topBar(context),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(14, 6, 14, 22),
                  child: Column(
                    children: [
                      _actionCard(
                        context: context,
                        title: "Business Profile",
                        subtitle: "Edit garage info, services, opening hours",
                        icon: Icons.storefront_outlined,
                        onTap: () => _openBusinessProfile(context),
                      ),
                      const SizedBox(height: 10),

                      _actionCard(
                        context: context,
                        title: "Nearby Requests",
                        subtitle: "View requests near your location",
                        icon: Icons.assignment_outlined,
                        onTap: () => _openNearbyRequests(context),
                      ),

                      const SizedBox(height: 10),
                      _actionCard(
                        context: context,
                        title: "My Jobs",
                        subtitle: "See confirmed jobs & update progress",
                        icon: Icons.work_outline,
                        onTap: () => _openJobs(context),
                      ),

                      const SizedBox(height: 10),
                      // ✅ NEW: History
                      _actionCard(
                        context: context,
                        title: "History",
                        subtitle: "Done jobs history",
                        icon: Icons.history,
                        onTap: () => _openHistory(context),
                      ),

                      const SizedBox(height: 10),
                      _actionCard(
                        context: context,
                        title: "Earnings (Coming Soon)",
                        subtitle: "Track completed jobs and payouts",
                        icon: Icons.payments_outlined,
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Earnings screen is coming soon.")),
                          );
                        },
                      ),

                      const SizedBox(height: 10),
                      _actionCard(
                        context: context,
                        title: "My Profile",
                        subtitle: "Update your personal details & photo",
                        icon: Icons.person_outline,
                        onTap: () => _openProfile(context),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
