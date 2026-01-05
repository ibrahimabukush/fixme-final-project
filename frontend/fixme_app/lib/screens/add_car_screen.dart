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

  // ✅ NEW: force model autocomplete rebuild when make changes
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

  // ✅ Big make list (UPPERCASE) + minimal models
  static final Map<String, Set<String>> _makeToModels = {
    // --- JAPAN ---
    'TOYOTA': {'COROLLA','CAMRY','YARIS','RAV4','PRIUS','HILUX','LAND CRUISER','AURIS'},
    'LEXUS': {'IS','ES','GS','RX','NX','UX','LS','LX'},
    'HONDA': {'CIVIC','ACCORD','CR-V','HR-V','JAZZ','FIT'},
    'ACURA': {'ILX','TLX','RDX','MDX'},
    'NISSAN': {'MICRA','SENTRA','ALTIMA','QASHQAI','X-TRAIL','JUKE'},
    'INFINITI': {'Q50','Q60','QX50','QX60','QX80'},
    'MAZDA': {'MAZDA2','MAZDA3','MAZDA6','CX-3','CX-5','CX-30'},
    'SUBARU': {'IMPREZA','FORESTER','OUTBACK','XV','LEGACY'},
    'MITSUBISHI': {'LANCER','OUTLANDER','ASX','PAJERO'},
    'SUZUKI': {'SWIFT','VITARA','BALENO','ALTO','IGNIS'},
    'ISUZU': {'D-MAX'},
    'DAIHATSU': {'TERIOS'},
    'HINO': {'GENERIC'},
    'MITSUOKA': {'GENERIC'},

    // --- KOREA ---
    'HYUNDAI': {'I10','I20','I30','ELANTRA','SONATA','TUCSON','SANTA FE','IONIQ'},
    'KIA': {'PICANTO','RIO','CEED','CERATO','SPORTAGE','SORENTO','EV6'},
    'GENESIS': {'G70','G80','G90','GV70','GV80'},
    'SSANGYONG': {'KORANDO','TIVOLI','REXTON'},

    // --- GERMANY ---
    'BMW': {'1 SERIES','3 SERIES','5 SERIES','7 SERIES','X1','X3','X5','X7'},
    'MINI': {'COOPER','COUNTRYMAN','CLUBMAN'},
    'MERCEDES': {'A CLASS','C CLASS','E CLASS','S CLASS','GLA','GLC','GLE'},
    'AUDI': {'A1','A3','A4','A6','Q3','Q5','Q7'},
    'VOLKSWAGEN': {'GOLF','POLO','PASSAT','TIGUAN','JETTA'},
    'SKODA': {'OCTAVIA','SUPERB','FABIA','KODIAQ','KAMIQ'},
    'SEAT': {'IBIZA','LEON','ATECA'},
    'CUPRA': {'FORMENTOR','LEON'},
    'PORSCHE': {'911','CAYENNE','MACAN','PANAMERA','TAYCAN'},
    'OPEL': {'CORSA','ASTRA','INSIGNIA'},
    'SMART': {'FORTWO','FORFOUR'},
    'MAYBACH': {'S-CLASS'},

    // --- FRANCE ---
    'PEUGEOT': {'208','308','2008','3008','508'},
    'CITROEN': {'C3','C4','C5','BERLINGO'},
    'RENAULT': {'CLIO','MEGANE','CAPTUR','KOLEOS'},
    'DS': {'DS3','DS4','DS7'},
    'BUGATTI': {'CHIRON'},

    // --- ITALY ---
    'FIAT': {'500','PANDA','TIPO'},
    'ALFA ROMEO': {'GIULIA','STELVIO','MITO'},
    'LANCIA': {'YPSILON'},
    'FERRARI': {'GENERIC'},
    'LAMBORGHINI': {'GENERIC'},
    'MASERATI': {'GHIBLI','LEVANTE','QUATTROPORTE'},
    'IVECO': {'DAILY'},
    'ABARTH': {'500'},

    // --- UK ---
    'LAND ROVER': {'RANGE ROVER','DISCOVERY','DEFENDER','EVOQUE'},
    'JAGUAR': {'XE','XF','F-PACE','E-PACE'},
    'ROLLS-ROYCE': {'GENERIC'},
    'BENTLEY': {'GENERIC'},
    'LOTUS': {'ELISE','EMIRA'},
    'ASTON MARTIN': {'GENERIC'},
    'MCLAREN': {'GENERIC'},
    'MG': {'ZS','HS'},

    // --- USA ---
    'TESLA': {'MODEL 3','MODEL S','MODEL X','MODEL Y'},
    'FORD': {'FOCUS','FIESTA','KUGA','MUSTANG','F-150'},
    'CHEVROLET': {'SPARK','CRUZE','MALIBU','SILVERADO'},
    'GMC': {'GENERIC'},
    'CADILLAC': {'GENERIC'},
    'BUICK': {'GENERIC'},
    'CHRYSLER': {'GENERIC'},
    'DODGE': {'GENERIC'},
    'JEEP': {'WRANGLER','CHEROKEE','GRAND CHEROKEE','COMPASS','RENEGADE'},
    'RAM': {'GENERIC'},

    // --- SWEDEN ---
    'VOLVO': {'S60','S90','XC40','XC60','XC90'},
    'SAAB': {'GENERIC'},
    'KOENIGSEGG': {'GENERIC'},

    // --- SPAIN ---
    'HISPANO SUIZA': {'GENERIC'},

    // --- CZECH/OTHER ---
    'TATRA': {'GENERIC'},

    // --- CHINA ---
    'BYD': {'GENERIC'},
    'GEELY': {'GENERIC'},
    'CHERY': {'GENERIC'},
    'GREAT WALL': {'GENERIC'},
    'HAVAL': {'GENERIC'},
    'MG (CHINA)': {'GENERIC'},
    'NIO': {'GENERIC'},
    'XPENG': {'GENERIC'},
    'HONGQI': {'GENERIC'},

    // --- INDIA ---
    'TATA': {'GENERIC'},
    'MAHINDRA': {'GENERIC'},
    'MARUTI': {'GENERIC'},

    // --- OTHER ---
    'SUZUKI (MARUTI)': {'GENERIC'},
    'DAEWOO': {'GENERIC'},
  };

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

  // ---------------------------
  // ✅ VALIDATION HELPERS
  // ---------------------------
  String _onlyDigits(String s) => s.replaceAll(RegExp(r'[^0-9]'), '');

  bool _isValidIsraeliPlate(String plate) {
    final p = plate.trim();
    final digits = _onlyDigits(p);
    if (!(digits.length == 7 || digits.length == 8)) return false;

    if (RegExp(r'^\d{7,8}$').hasMatch(p)) return true;

    final r7 = RegExp(r'^\d{2}([.\-])\d{3}\1\d{2}$');
    final r8 = RegExp(r'^\d{3}([.\-])\d{2}\1\d{3}$');
    return r7.hasMatch(p) || r8.hasMatch(p);
  }

  String _formatPlateStandard(String plate) {
    final d = _onlyDigits(plate);
    if (d.length == 7) {
      return '${d.substring(0, 2)}-${d.substring(2, 5)}-${d.substring(5, 7)}';
    }
    if (d.length == 8) {
      return '${d.substring(0, 3)}-${d.substring(3, 5)}-${d.substring(5, 8)}';
    }
    return plate.trim();
  }

  String _normMake(String s) => s.trim().toUpperCase();
  String _normModel(String s) => s.trim().toUpperCase();

  void _onMakeChanged([String? selected]) {
    setState(() {
      if (selected != null) _makeCtrl.text = selected;
      _modelCtrl.clear();
      _modelKey++; // ✅ important
    });
  }

  String? _validatePlate(String? v) {
    final plate = (v ?? '').trim();
    if (plate.isEmpty) return 'Plate number is required';
    if (!_isValidIsraeliPlate(plate)) {
      return 'Invalid Israeli plate.\nUse: 12-345-67 or 123-45-678 (also dots allowed) or digits only.';
    }
    return null;
  }

  String? _validateMake(String? v) {
    final make = _normMake(v ?? '');
    if (make.isEmpty) return 'Make is required';
    if (!_makeToModels.containsKey(make)) {
      return 'Unknown make. Choose one from the list (e.g., TOYOTA, BMW...).';
    }
    return null;
  }

  String? _validateModel(String? v) {
    final make = _normMake(_makeCtrl.text);
    if (make.isEmpty || !_makeToModels.containsKey(make)) {
      return 'Select a valid make first';
    }

    final model = _normModel(v ?? '');
    if (model.isEmpty) return 'Model is required';

    final models = _makeToModels[make]!;
    if (!models.contains(model)) {
      return 'Unknown model for $make. Choose from the list.';
    }
    return null;
  }

  String? _validateYear(String? v) {
    final s = (v ?? '').trim();
    if (s.isEmpty) return 'Year is required';
    final y = int.tryParse(s);
    if (y == null) return 'Year must be a number';

    final now = DateTime.now().year;
    if (y < 1970 || y > now + 1) {
      return 'Enter a valid year (1970 - ${now + 1})';
    }
    return null;
  }

  // ---------------------------
  // ✅ AUTOCOMPLETE WIDGETS
  // ---------------------------

  Widget _makeAutoComplete() {
    final makes = _makeToModels.keys.toList()..sort();

    return Autocomplete<String>(
      initialValue: TextEditingValue(text: _makeCtrl.text),
      optionsBuilder: (TextEditingValue text) {
        final q = _normMake(text.text);
        if (q.isEmpty) return makes;
        return makes.where((m) => m.contains(q));
      },
      onSelected: (val) => _onMakeChanged(val),
      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
        // keep synced
        controller.text = _makeCtrl.text;

        return TextFormField(
          controller: controller,
          focusNode: focusNode,
          decoration: _dec(
            label: 'Make',
            icon: Icons.factory_outlined,
            hint: 'Choose (Toyota, BMW, Audi...)',
          ),
          validator: _validateMake,
          onChanged: (v) {
            _makeCtrl.text = v;
            _onMakeChanged(); // ✅ clear model + rebuild
          },
          textInputAction: TextInputAction.next,
        );
      },
    );
  }

  Widget _modelAutoComplete() {
    final make = _normMake(_makeCtrl.text);
    final models = (_makeToModels[make] ?? {}).toList()..sort();

    return Autocomplete<String>(
      key: ValueKey(_modelKey), // ✅ core fix
      initialValue: TextEditingValue(text: _modelCtrl.text),
      optionsBuilder: (TextEditingValue text) {
        if (models.isEmpty) return const Iterable<String>.empty();
        final q = _normModel(text.text);
        if (q.isEmpty) return models;
        return models.where((m) => m.contains(q));
      },
      onSelected: (val) {
        setState(() {
          _modelCtrl.text = val;
        });
      },
      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
        controller.text = _modelCtrl.text;

        return TextFormField(
          controller: controller,
          focusNode: focusNode,
          enabled: models.isNotEmpty,
          decoration: _dec(
            label: 'Model',
            icon: Icons.directions_car_outlined,
            hint: models.isEmpty ? 'Select a valid make first' : 'Choose model',
          ),
          validator: _validateModel,
          onChanged: (v) {
            _modelCtrl.text = v;
            setState(() {});
          },
          textInputAction: TextInputAction.next,
        );
      },
    );
  }

  // ---------------------------
  // ✅ SUBMIT
  // ---------------------------

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final year = int.parse(_yearCtrl.text.trim());
      final category = _selectedCategory ?? 'ALL';

      final plate = _formatPlateStandard(_plateCtrl.text);
      final make = _normMake(_makeCtrl.text);
      final model = _normModel(_modelCtrl.text);

      await VehicleService.addVehicle(
        widget.userId,
        plate,
        make,
        model,
        year,
        category,
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
                                    builder: (_) =>
                                        CustomerHomeScreen(userId: widget.userId),
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
                            hint: '12-345-67 or 123-45-678',
                          ),
                          validator: _validatePlate,
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 12),

                        _makeAutoComplete(),
                        const SizedBox(height: 12),

                        _modelAutoComplete(),
                        const SizedBox(height: 12),

                        TextFormField(
                          controller: _yearCtrl,
                          decoration: _dec(
                            label: 'Year',
                            icon: Icons.calendar_month_outlined,
                            hint: 'e.g. 2020',
                          ),
                          keyboardType: TextInputType.number,
                          validator: _validateYear,
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 12),

                        DropdownButtonFormField<String>(
                          value: _selectedCategory,
                          decoration: _dec(
                            label: 'Category',
                            icon: Icons.category_outlined,
                          ),
                          items: _categoryLabels.entries
                              .map((e) => DropdownMenuItem(
                                    value: e.key,
                                    child: Text(e.value),
                                  ))
                              .toList(),
                          onChanged: (val) => setState(() => _selectedCategory = val),
                          validator: (val) =>
                              val == null ? 'Category is required' : null,
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
