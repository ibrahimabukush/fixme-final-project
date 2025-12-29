import 'package:flutter/material.dart';
import '../models/vehicle.dart';
import '../services/vehicle_service.dart';

class EditCarScreen extends StatefulWidget {
  final int userId;
  final Vehicle vehicle;

  const EditCarScreen({
    super.key,
    required this.userId,
    required this.vehicle,
  });

  @override
  State<EditCarScreen> createState() => _EditCarScreenState();
}

class _EditCarScreenState extends State<EditCarScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _plateCtrl;
  late final TextEditingController _makeCtrl;
  late final TextEditingController _modelCtrl;
  late final TextEditingController _yearCtrl;

  bool _isLoading = false;

  final Map<String, String> _categoryLabels = const {
    'ALL': 'All',
    'GERMAN': 'German',
    'JAPANESE': 'Japanese',
    'KOREAN': 'Korean',
    'AMERICAN': 'American',
    'ELECTRIC': 'Electric',
  };

  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _plateCtrl = TextEditingController(text: widget.vehicle.plateNumber);
    _makeCtrl = TextEditingController(text: widget.vehicle.make);
    _modelCtrl = TextEditingController(text: widget.vehicle.model);
    _yearCtrl =
        TextEditingController(text: (widget.vehicle.year ?? '').toString());
    _selectedCategory = widget.vehicle.vehicleCategory;
  }

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

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final year = int.parse(_yearCtrl.text.trim());
      final category = _selectedCategory ?? 'ALL';

      await VehicleService.updateVehicle(
        widget.userId,
        widget.vehicle.id,
        _plateCtrl.text.trim(),
        _makeCtrl.text.trim(),
        _modelCtrl.text.trim(),
        year,
        category,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Car updated successfully ✅')),
      );

      Navigator.pop(context, true); // رجّع true عشان نعمل reload
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update car: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteCar() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete car"),
        content: Text(
          "Delete ${widget.vehicle.make} ${widget.vehicle.model} (${widget.vehicle.plateNumber}) ?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);

    try {
      await VehicleService.deleteVehicle(widget.userId, widget.vehicle.id);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Car deleted ✅')),
      );

      Navigator.pop(context, true); // عشان Home يعمل reload
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete car: $e')),
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
                                Icons.edit_outlined,
                                color: Color(0xFF4F46E5),
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Edit car",
                                    style: TextStyle(
                                      fontSize: 16.5,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    "Update car info",
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
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
                          ),
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Plate number is required'
                              : null,
                        ),
                        const SizedBox(height: 12),

                        TextFormField(
                          controller: _makeCtrl,
                          decoration: _dec(
                            label: 'Make',
                            icon: Icons.factory_outlined,
                          ),
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Make is required'
                              : null,
                        ),
                        const SizedBox(height: 12),

                        TextFormField(
                          controller: _modelCtrl,
                          decoration: _dec(
                            label: 'Model',
                            icon: Icons.directions_car_outlined,
                          ),
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Model is required'
                              : null,
                        ),
                        const SizedBox(height: 12),

                        TextFormField(
                          controller: _yearCtrl,
                          decoration: _dec(
                            label: 'Year',
                            icon: Icons.calendar_month_outlined,
                          ),
                          keyboardType: TextInputType.number,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Year is required';
                            }
                            final y = int.tryParse(v.trim());
                            if (y == null || y < 1970 || y > 2100) {
                              return 'Please enter a valid year';
                            }
                            return null;
                          },
                          onFieldSubmitted: (_) => _save(),
                        ),
                        const SizedBox(height: 12),

                        DropdownButtonFormField<String>(
                          value: _selectedCategory,
                          decoration: _dec(
                            label: 'Category',
                            icon: Icons.category_outlined,
                          ),
                          items: _categoryLabels.entries.map((e) {
                            return DropdownMenuItem<String>(
                              value: e.key,
                              child: Text(e.value),
                            );
                          }).toList(),
                          onChanged: (val) =>
                              setState(() => _selectedCategory = val),
                          validator: (val) =>
                              val == null ? 'Category is required' : null,
                        ),

                        const SizedBox(height: 18),

                        SizedBox(
                          height: 46,
                          child: _isLoading
                              ? const Center(child: CircularProgressIndicator())
                              : ElevatedButton(
                                  onPressed: _save,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF4F46E5),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  child: const Text(
                                    'Save changes',
                                    style:
                                        TextStyle(fontWeight: FontWeight.w800),
                                  ),
                                ),
                        ),

                        const SizedBox(height: 10),

                        SizedBox(
                          height: 46,
                          child: OutlinedButton.icon(
                            onPressed: _isLoading ? null : _deleteCar,
                            icon: const Icon(Icons.delete_outline),
                            label: const Text(
                              'Delete car',
                              style: TextStyle(fontWeight: FontWeight.w800),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                              side: const BorderSide(color: Colors.red),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
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
