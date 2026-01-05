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

  /// ✅ forces Model Autocomplete rebuild when Make changes
  int _modelKey = 0;

  final Map<String, String> _categoryLabels = const {
    'ALL': 'All',
    'GERMAN': 'German',
    'JAPANESE': 'Japanese',
    'KOREAN': 'Korean',
    'AMERICAN': 'American',
    'ELECTRIC': 'Electric',
  };

  String? _selectedCategory;

  /// ✅ Use SAME style as AddCar: UPPERCASE dataset
  static const Map<String, List<String>> _makeToModels = {
    'TOYOTA': ['COROLLA', 'CAMRY', 'YARIS', 'RAV4', 'PRIUS', 'LAND CRUISER'],
    'HONDA': ['CIVIC', 'ACCORD', 'CR-V', 'FIT', 'HR-V'],
    'HYUNDAI': ['I10', 'I20', 'I30', 'ELANTRA', 'TUCSON', 'KONA'],
    'KIA': ['PICANTO', 'RIO', 'CEED', 'SPORTAGE', 'SORENTO'],
    'MAZDA': ['2', '3', '6', 'CX-3', 'CX-5', 'CX-30'],
    'NISSAN': ['MICRA', 'JUKE', 'QASHQAI', 'X-TRAIL', 'SENTRA'],
    'BMW': ['1 SERIES', '3 SERIES', '5 SERIES', 'X1', 'X3', 'X5'],
    'MERCEDES': ['A CLASS', 'C CLASS', 'E CLASS', 'GLA', 'GLC', 'GLE'],
    'AUDI': ['A3', 'A4', 'A6', 'Q3', 'Q5', 'Q7'],
    'VOLKSWAGEN': ['GOLF', 'POLO', 'PASSAT', 'TIGUAN', 'T-ROC'],
    'SKODA': ['FABIA', 'OCTAVIA', 'SUPERB', 'KAROQ', 'KODIAQ'],
    'TESLA': ['MODEL 3', 'MODEL S', 'MODEL X', 'MODEL Y'],
    'FORD': ['FIESTA', 'FOCUS', 'MONDEO', 'KUGA', 'EXPLORER'],
    'CHEVROLET': ['SPARK', 'CRUZE', 'MALIBU', 'TAHOE'],
  };

  List<String> get _allMakes => _makeToModels.keys.toList()..sort();

  String _norm(String s) => s.trim().toUpperCase();

  String? _normalizeMake(String input) {
    final t = _norm(input);
    if (t.isEmpty) return null;
    // exact match in UPPERCASE dataset
    if (_makeToModels.containsKey(t)) return t;
    return null;
  }

  bool _isValidMake(String input) => _normalizeMake(input) != null;

  bool _isValidModelForMake({
    required String makeInput,
    required String modelInput,
  }) {
    final mk = _normalizeMake(makeInput);
    if (mk == null) return false;
    final models = _makeToModels[mk] ?? const [];
    final model = _norm(modelInput);
    return models.any((x) => _norm(x) == model);
  }

  bool _isValidIsraelPlate(String s) {
    final v = s.trim();
    final r7 = RegExp(r'^\d{2}-\d{3}-\d{2}$');
    final r8 = RegExp(r'^\d{3}-\d{2}-\d{3}$');
    return r7.hasMatch(v) || r8.hasMatch(v);
  }

  int get _maxYear => DateTime.now().year + 1;

  @override
  void initState() {
    super.initState();

    _plateCtrl = TextEditingController(text: widget.vehicle.plateNumber);

    // ✅ normalize existing values to UPPERCASE like AddCar
    final makeUpper = _normalizeMake(widget.vehicle.make) ?? _norm(widget.vehicle.make);
    _makeCtrl = TextEditingController(text: makeUpper);

    final models = _makeToModels[makeUpper] ?? const <String>[];
    final existingModel = _norm(widget.vehicle.model);
    final modelUpper = models.firstWhere(
      (m) => _norm(m) == existingModel,
      orElse: () => _norm(widget.vehicle.model),
    );
    _modelCtrl = TextEditingController(text: modelUpper);

    _yearCtrl = TextEditingController(text: (widget.vehicle.year ?? '').toString());
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

  void _onMakeChanged({String? selected, String? typed}) {
    setState(() {
      if (selected != null) _makeCtrl.text = selected;
      if (typed != null) _makeCtrl.text = typed;

      // ✅ always reset model when make changes
      _modelCtrl.clear();

      // ✅ force Model Autocomplete rebuild
      _modelKey++;
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final year = int.parse(_yearCtrl.text.trim());
      final category = _selectedCategory ?? 'ALL';

      final makeCanonical = _normalizeMake(_makeCtrl.text) ?? _norm(_makeCtrl.text);
      final modelCanonical = _norm(_modelCtrl.text);

      await VehicleService.updateVehicle(
        widget.userId,
        widget.vehicle.id,
        _plateCtrl.text.trim(),
        makeCanonical,
        modelCanonical,
        year,
        category,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Car updated successfully ✅')),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update car: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _fieldTitle(String t) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(t, style: const TextStyle(fontWeight: FontWeight.w900)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 700;
    final cardWidth = isMobile ? size.width * 0.92 : 560.0;

    final makeCanonical = _normalizeMake(_makeCtrl.text);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF5F7FF), Color(0xFFFDF2F8)],
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
                              child: const Icon(Icons.edit_outlined,
                                  color: Color(0xFF4F46E5)),
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
                                    "Update car info safely",
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

                        _fieldTitle("Plate number"),
                        TextFormField(
                          controller: _plateCtrl,
                          decoration: _dec(
                            label: 'Plate number',
                            icon: Icons.confirmation_number_outlined,
                            hint: '12-345-67 or 123-45-678',
                          ),
                          validator: (v) {
                            final x = (v ?? '').trim();
                            if (x.isEmpty) return 'Plate number is required';
                            if (!_isValidIsraelPlate(x)) {
                              return 'Invalid Israeli plate. Use 12-345-67 or 123-45-678';
                            }
                            return null;
                          },
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 12),

                        _fieldTitle("Make"),
                        Autocomplete<String>(
                          initialValue: TextEditingValue(text: _makeCtrl.text),
                          optionsBuilder: (TextEditingValue value) {
                            final q = _norm(value.text);
                            if (q.isEmpty) return _allMakes;
                            return _allMakes.where((m) => m.contains(q));
                          },
                          onSelected: (sel) => _onMakeChanged(selected: sel),
                          fieldViewBuilder: (context, textCtrl, focusNode, onSubmitted) {
                            // ✅ Use the controller provided by Autocomplete
                            return TextFormField(
                              controller: textCtrl,
                              focusNode: focusNode,
                              decoration: _dec(
                                label: 'Make',
                                icon: Icons.factory_outlined,
                                hint: 'TOYOTA, BMW, HYUNDAI...',
                              ),
                              validator: (v) {
                                final x = (v ?? '').trim();
                                if (x.isEmpty) return 'Make is required';
                                if (!_isValidMake(x)) return 'Unknown make. Choose from list.';
                                return null;
                              },
                              onChanged: (v) {
                                _makeCtrl.text = v; // keep your main controller synced
                                _onMakeChanged(typed: v);
                              },
                              textInputAction: TextInputAction.next,
                            );
                          },
                        ),
                        const SizedBox(height: 12),

                        _fieldTitle("Model"),
                        Autocomplete<String>(
                          key: ValueKey(_modelKey),
                          initialValue: TextEditingValue(text: _modelCtrl.text),
                          optionsBuilder: (TextEditingValue value) {
                            final mk = _normalizeMake(_makeCtrl.text);
                            final models = mk == null
                                ? const <String>[]
                                : (_makeToModels[mk] ?? const <String>[]);

                            final q = _norm(value.text);
                            if (q.isEmpty) return models;
                            return models.where((m) => _norm(m).contains(q));
                          },
                          onSelected: (sel) => setState(() => _modelCtrl.text = sel),
                          fieldViewBuilder: (context, textCtrl, focusNode, onSubmitted) {
                            return TextFormField(
                              controller: textCtrl, // ✅ use autocomplete controller
                              focusNode: focusNode,
                              enabled: makeCanonical != null && !_isLoading,
                              decoration: _dec(
                                label: 'Model',
                                icon: Icons.directions_car_outlined,
                                hint: makeCanonical == null ? 'Select make first' : 'Choose model',
                              ),
                              validator: (v) {
                                final x = (v ?? '').trim();
                                if (x.isEmpty) return 'Model is required';
                                if (!_isValidModelForMake(makeInput: _makeCtrl.text, modelInput: x)) {
                                  return 'Model not valid for selected make';
                                }
                                return null;
                              },
                              onChanged: (v) => _modelCtrl.text = v, // sync
                              textInputAction: TextInputAction.next,
                            );
                          },
                        ),
                        const SizedBox(height: 12),

                        _fieldTitle("Year"),
                        TextFormField(
                          controller: _yearCtrl,
                          decoration: _dec(
                            label: 'Year',
                            icon: Icons.calendar_month_outlined,
                            hint: 'e.g. 2020',
                          ),
                          keyboardType: TextInputType.number,
                          validator: (v) {
                            final x = (v ?? '').trim();
                            if (x.isEmpty) return 'Year is required';
                            final y = int.tryParse(x);
                            if (y == null) return 'Year must be a number';
                            if (y < 1970 || y > _maxYear) {
                              return 'Enter a valid year (1970 - $_maxYear)';
                            }
                            return null;
                          },
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _save(),
                        ),
                        const SizedBox(height: 12),

                        _fieldTitle("Category"),
                        DropdownButtonFormField<String>(
                          value: _selectedCategory,
                          decoration: _dec(
                            label: 'Category',
                            icon: Icons.category_outlined,
                          ),
                          items: _categoryLabels.entries
                              .map((e) => DropdownMenuItem<String>(
                                    value: e.key,
                                    child: Text(e.value),
                                  ))
                              .toList(),
                          onChanged: _isLoading ? null : (val) => setState(() => _selectedCategory = val),
                          validator: (val) => val == null ? 'Category is required' : null,
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
                                    style: TextStyle(fontWeight: FontWeight.w800),
                                  ),
                                ),
                        ),

                        const SizedBox(height: 6),
                        const Text(
                          "Tip: Choose Make/Model from suggestions to avoid mistakes.",
                          style: TextStyle(fontSize: 12.5, color: Colors.black54),
                          textAlign: TextAlign.center,
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
