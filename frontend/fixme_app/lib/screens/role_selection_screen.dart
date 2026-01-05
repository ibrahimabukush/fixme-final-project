import 'package:flutter/material.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  void _goTo(BuildContext context, {required bool isLogin, required String role}) {
    Navigator.pushNamed(
      context,
      isLogin ? '/login' : '/signup',
      arguments: role,
    );
  }

  Widget _topHeader(BuildContext context) {
    return Material(
      elevation: 12,
      shadowColor: Colors.black12,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFEAEAF2)),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF2563EB), Color(0xFF4F46E5)],
                ),
              ),
              child: const Icon(Icons.car_repair, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'FixMe',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Choose your account type to continue',
                    style: TextStyle(color: Colors.black54),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Back',
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back),
            ),
          ],
        ),
      ),
    );
  }

  Widget _roleCard(
    BuildContext context, {
    required IconData icon,
    required Color accent,
    required String title,
    required String subtitle,
    required List<String> bullets,
    required String role,
  }) {
    return Material(
      elevation: 12,
      shadowColor: Colors.black12,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFEAEAF2)),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card header row
            Row(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    color: accent.withOpacity(0.12),
                  ),
                  child: Icon(icon, color: accent),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(color: Colors.black54, height: 1.2),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Bullets
            Column(
              children: bullets.map((b) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle_outline, size: 18, color: accent),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          b,
                          style: const TextStyle(color: Colors.black87),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 10),

            // Actions
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 46,
                    child: ElevatedButton(
                      onPressed: () => _goTo(context, isLogin: true, role: role),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accent,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Log in',
                        style: TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: SizedBox(
                    height: 46,
                    child: OutlinedButton(
                      onPressed: () => _goTo(context, isLogin: false, role: role),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: accent,
                        side: BorderSide(color: accent.withOpacity(0.35)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Create account',
                        style: TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _note() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFEAEAF2)),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline, size: 20),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Providers can start receiving requests after admin approval.',
              style: TextStyle(color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 700;
    final maxW = isMobile ? size.width * 0.92 : 720.0;

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
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxW),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _topHeader(context),
                    const SizedBox(height: 14),

                    Expanded(
                      child: ListView(
                        children: [
                          _roleCard(
                            context,
                            icon: Icons.directions_car_outlined,
                            accent: const Color(0xFF2563EB),
                            title: 'Customer',
                            subtitle: 'Add your vehicles and request roadside services.',
                            bullets: const [
                              'Create requests & track progress',
                              'Chat with the provider in-app',
                              'Save your cars and history',
                            ],
                            role: 'CUSTOMER',
                          ),
                          const SizedBox(height: 12),
                          _roleCard(
                            context,
                            icon: Icons.storefront_outlined,
                            accent: const Color(0xFF4F46E5),
                            title: 'Service Provider',
                            subtitle: 'Register your business (garage/towing) and get approved.',
                            bullets: const [
                              'Set business profile & categories',
                              'Accept jobs and update progress',
                              'Build trust with ratings (soon)',
                            ],
                            role: 'PROVIDER',
                          ),
                          const SizedBox(height: 14),
                          _note(),
                        ],
                      ),
                    ),

                    const SizedBox(height: 8),
                    const Center(
                      child: Text(
                        "© FixMe • Choose your path",
                        style: TextStyle(color: Colors.black45, fontSize: 12.5),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
