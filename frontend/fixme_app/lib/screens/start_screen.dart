import 'package:flutter/material.dart';

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  void _go(BuildContext context) {
    Navigator.pushNamed(context, '/role');
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 700;
    final maxW = isMobile ? size.width * 0.92 : 620.0;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
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
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxW),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const SizedBox(height: 8),

                    // Top logo card
                    Material(
                      elevation: 12,
                      shadowColor: Colors.black12,
                      borderRadius: BorderRadius.circular(24),
                      child: Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: const Color(0xFFEAEAF2)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 58,
                              height: 58,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(18),
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color(0xFF2563EB),
                                    Color(0xFF4F46E5),
                                  ],
                                ),
                              ),
                              child: const Icon(
                                Icons.car_repair,
                                color: Colors.white,
                                size: 30,
                              ),
                            ),
                            const SizedBox(width: 14),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "FixMe",
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    "Fast help • Clear pricing • Trusted providers",
                                    style: TextStyle(
                                      color: Colors.black54,
                                      height: 1.2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Hero card
                    Expanded(
                      child: Material(
                        elevation: 12,
                        shadowColor: Colors.black12,
                        borderRadius: BorderRadius.circular(24),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: const Color(0xFFEAEAF2)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Roadside services,\nmade simple.",
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w900,
                                  height: 1.1,
                                ),
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                "Request help in seconds, chat with the provider, and track progress until the job is done.",
                                style: TextStyle(
                                  color: Colors.black54,
                                  height: 1.3,
                                ),
                              ),

                              const SizedBox(height: 16),

                              Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children: const [
                                  _FeaturePill(
                                    icon: Icons.flash_on_outlined,
                                    text: "Quick requests",
                                  ),
                                  _FeaturePill(
                                    icon: Icons.chat_bubble_outline,
                                    text: "In-app chat",
                                  ),
                                  _FeaturePill(
                                    icon: Icons.location_on_outlined,
                                    text: "Live location",
                                  ),
                                  _FeaturePill(
                                    icon: Icons.verified_outlined,
                                    text: "Verified accounts",
                                  ),
                                ],
                              ),

                              const Spacer(),

                              // ✅ ONLY Get started (no Continue as card, no More options)
                              SizedBox(
                                width: double.infinity,
                                height: 52,
                                child: ElevatedButton(
                                  onPressed: () => _go(context),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF4F46E5),
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "Get started",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w900,
                                          fontSize: 16,
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      Icon(Icons.arrow_forward_rounded),
                                    ],
                                  ),
                                ),
                              ),

                              const SizedBox(height: 10),

                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF6F7FB),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: const Color(0xFFEAEAF2)),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(Icons.info_outline, size: 18),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        "Choose Customer or Provider. Providers receive requests after admin approval.",
                                        style: TextStyle(
                                          color: Colors.black54,
                                          height: 1.2,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    const Text(
                      "© FixMe • Built with Flutter",
                      style: TextStyle(color: Colors.black45, fontSize: 12.5),
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

class _FeaturePill extends StatelessWidget {
  final IconData icon;
  final String text;

  const _FeaturePill({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
