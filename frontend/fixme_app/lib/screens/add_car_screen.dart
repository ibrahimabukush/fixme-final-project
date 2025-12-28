import 'package:flutter/material.dart';
import '../services/vehicle_service.dart';
import 'customer_home_screen.dart';

class AddCarScreen extends StatefulWidget {
  final int userId;

  const AddCarScreen({super.key, required this.userId});

  @override
  State<AddCarScreen> createState() => _AddCarScreenState();
}

class _AddCarScreenState extends State<AddCarScreen> {
  final _formKey = GlobalKey<FormState>();
  final _plateCtrl = TextEditingController();
  final _makeCtrl = TextEditingController();
  final _modelCtrl = TextEditingController();
  final _yearCtrl = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _plateCtrl.dispose();
    _makeCtrl.dispose();
    _modelCtrl.dispose();
    _yearCtrl.dispose();
    super.dispose();
  }

  InputDecoration _dec({
    required String label,
    required IconData icon,
    String? hint,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final year = int.parse(_yearCtrl.text.trim());

      await VehicleService.addVehicle(
        userId: widget.userId,
        plateNumber: _plateCtrl.text.trim(),
        make: _makeCtrl.text.trim(),
        model: _modelCtrl.text.trim(),
        year: year,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Car added successfully ✅')),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => CustomerHomeScreen(userId: widget.userId),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add car: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 700;
    final cardWidth = isMobile ? size.width * 0.92 : 560.0;

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
              Color(0xFFFDF2F8),
            ],
          ),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: cardWidth),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Material(
                elevation: 12,
                shadowColor: Colors.black12,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(22, 18, 22, 22),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFEAEAF2)),
                  ),
                  child: Form(
                    key: _formKey,
                    child: ListView(
                      shrinkWrap: true,
                      children: [
                        // Header
                        Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                color: const Color(0xFFEEF2FF),
                              ),
                              child: const Icon(
                                Icons.directions_car_filled_outlined,
                                color: Color(0xFF4F46E5),
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Add a car",
                                    style: TextStyle(
                                      fontSize: 16.5,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    "FixMe • Customer garage",
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => CustomerHomeScreen(userId: widget.userId),
                                  ),
                                );
                              },
                              child: const Text("Back"),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _plateCtrl,
                          decoration: _dec(
                            label: 'Plate number',
                            icon: Icons.confirmation_number_outlined,
                            hint: 'e.g. 12-345-67',
                          ),
                          validator: (v) =>
                              (v == null || v.trim().isEmpty) ? 'Plate number is required' : null,
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 12),

                        TextFormField(
                          controller: _makeCtrl,
                          decoration: _dec(
                            label: 'Make',
                            icon: Icons.factory_outlined,
                            hint: 'e.g. Toyota',
                          ),
                          validator: (v) =>
                              (v == null || v.trim().isEmpty) ? 'Make is required' : null,
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 12),

                        TextFormField(
                          controller: _modelCtrl,
                          decoration: _dec(
                            label: 'Model',
                            icon: Icons.directions_car_outlined,
                            hint: 'e.g. Corolla',
                          ),
                          validator: (v) =>
                              (v == null || v.trim().isEmpty) ? 'Model is required' : null,
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 12),

                        TextFormField(
                          controller: _yearCtrl,
                          decoration: _dec(
                            label: 'Year',
                            icon: Icons.calendar_month_outlined,
                            hint: 'e.g. 2020',
                          ),
                          keyboardType: TextInputType.number,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return 'Year is required';
                            final y = int.tryParse(v.trim());
                            if (y == null || y < 1970 || y > 2100) return 'Please enter a valid year';
                            return null;
                          },
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _submit(),
                        ),

                        const SizedBox(height: 18),

                        SizedBox(
                          height: 46,
                          child: _isLoading
                              ? const Center(child: CircularProgressIndicator())
                              : ElevatedButton(
                                  onPressed: _submit,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF4F46E5),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  child: const Text(
                                    'Save car',
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
          ),
        ),
      ),
    );
  }
}
