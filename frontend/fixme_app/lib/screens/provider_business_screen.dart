import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ProviderBusinessScreen extends StatefulWidget {
  final int userId;

  const ProviderBusinessScreen({
    super.key,
    required this.userId,
  });

  @override
  State<ProviderBusinessScreen> createState() => _ProviderBusinessScreenState();
}

class _ProviderBusinessScreenState extends State<ProviderBusinessScreen> {
  final _formKey = GlobalKey<FormState>();

  final _businessNameController = TextEditingController();
  final _cityController = TextEditingController();
  final _addressController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _servicesController = TextEditingController();
  final _openingHoursController = TextEditingController();

  bool _isSubmitting = false;

  // Web: localhost, Android Emulator: 10.0.2.2
  final String baseUrl = kIsWeb ? 'http://localhost:8081' : 'http://10.0.2.2:8081';

  Future<void> _saveBusiness() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final uri = Uri.parse('$baseUrl/api/providers/${widget.userId}/business');

      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'businessName': _businessNameController.text.trim(),
          'city': _cityController.text.trim(),
          'address': _addressController.text.trim(),
          'description': _descriptionController.text.trim(),
          'services': _servicesController.text.trim(),
          'openingHours': _openingHoursController.text.trim(),
        }),
      );

      if (!mounted) return;

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Business details saved ✅')),
        );

        // إذا بدك بعد الحفظ ينقلك لصفحة معينة:
        // Navigator.pop(context);

      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to save (${response.statusCode}): ${response.body}',
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Server connection error: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  void dispose() {
    _businessNameController.dispose();
    _cityController.dispose();
    _addressController.dispose();
    _descriptionController.dispose();
    _servicesController.dispose();
    _openingHoursController.dispose();
    super.dispose();
  }

  // ---------- UI helpers (Modern cards) ----------

  Widget _modernHeader() {
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
              IconButton(
                onPressed: () => Navigator.pop(context),
                tooltip: 'Back',
                icon: const Icon(Icons.arrow_back),
              ),
              const SizedBox(width: 4),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: const Color(0xFFFFF7ED),
                ),
                child: const Icon(
                  Icons.storefront_outlined,
                  color: Color(0xFFEA580C),
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Business Profile",
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                    SizedBox(height: 2),
                    Text(
                      "Tell customers about your garage",
                      style: TextStyle(fontSize: 12.5, color: Colors.black54),
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

  Widget _cardField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Material(
      elevation: 6,
      shadowColor: Colors.black12,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: Colors.white,
          border: Border.all(color: const Color(0xFFEAEAF2)),
        ),
        child: TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            labelText: label,
            hintText: hint,
            prefixIcon: Icon(icon),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      ),
    );
  }

  Widget _saveButton() {
    return SizedBox(
      height: 48,
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isSubmitting ? null : _saveBusiness,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4F46E5),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        icon: _isSubmitting
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.save_outlined),
        label: Text(
          _isSubmitting ? 'Saving...' : 'Save business details',
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
    );
  }

  // ---------- Build ----------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // Modern background gradient
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
              _modernHeader(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(14, 6, 14, 22),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _cardField(
                          controller: _businessNameController,
                          label: 'Business name *',
                          icon: Icons.badge_outlined,
                          hint: 'e.g., FixMe Garage Center',
                          validator: (v) =>
                              (v == null || v.trim().isEmpty) ? 'Business name is required' : null,
                        ),
                        const SizedBox(height: 10),
                        _cardField(
                          controller: _cityController,
                          label: 'City *',
                          icon: Icons.location_city_outlined,
                          hint: 'e.g., Beersheba',
                          validator: (v) =>
                              (v == null || v.trim().isEmpty) ? 'City is required' : null,
                        ),
                        const SizedBox(height: 10),
                        _cardField(
                          controller: _addressController,
                          label: 'Full address *',
                          icon: Icons.place_outlined,
                          hint: 'Street, number, area...',
                          validator: (v) =>
                              (v == null || v.trim().isEmpty) ? 'Address is required' : null,
                        ),
                        const SizedBox(height: 10),
                        _cardField(
                          controller: _descriptionController,
                          label: 'Short description (optional)',
                          icon: Icons.description_outlined,
                          hint: 'What do you specialize in?',
                          maxLines: 3,
                        ),
                        const SizedBox(height: 10),
                        _cardField(
                          controller: _servicesController,
                          label: 'Services (comma separated)',
                          icon: Icons.build_outlined,
                          hint: 'Towing, Tires, Diagnostics, Oil change...',
                        ),
                        const SizedBox(height: 10),
                        _cardField(
                          controller: _openingHoursController,
                          label: 'Opening hours',
                          icon: Icons.schedule_outlined,
                          hint: 'Sun-Thu 08:00-18:00',
                        ),
                        const SizedBox(height: 16),
                        _saveButton(),
                      ],
                    ),
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
