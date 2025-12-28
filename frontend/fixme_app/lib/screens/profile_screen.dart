// lib/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services/profile_service.dart';
import '../services/auth_service.dart';
import '../models/user_profile.dart';

class ProfileScreen extends StatefulWidget {
  final int userId;

  const ProfileScreen({super.key, required this.userId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserProfile? _profile;
  bool _loading = true;
  bool _saving = false;

  final _firstCtrl = TextEditingController();
  final _lastCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();

  int _imageVersion = 0;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  bool _isValidIsraeliPhone(String phone) {
    // 05 + 8 digits (10 digits total)
    final reg = RegExp(r'^05\d{8}$');
    return reg.hasMatch(phone);
  }

  Future<void> _loadProfile() async {
    setState(() => _loading = true);
    try {
      final p = await ProfileService.fetchProfile(widget.userId);
      if (!mounted) return;

      setState(() {
        _profile = p;
        _firstCtrl.text = p.firstName;
        _lastCtrl.text = p.lastName;
        _phoneCtrl.text = p.phone;
        _emailCtrl.text = p.email;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load profile: $e')),
      );
    }
  }

  Future<void> _saveProfile() async {
    if (_profile == null) return;

    final phone = _phoneCtrl.text.trim();
    if (!_isValidIsraeliPhone(phone)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid Israeli phone like 0521234567')),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      _profile!
        ..firstName = _firstCtrl.text.trim()
        ..lastName = _lastCtrl.text.trim()
        ..phone = phone;

      final updated = await ProfileService.updateProfile(_profile!);
      if (!mounted) return;

      setState(() => _profile = updated);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Changes saved successfully')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save profile: $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    final bytes = await picked.readAsBytes();
    final fileName = picked.name;

    setState(() => _saving = true);
    try {
      final updated = await ProfileService.uploadAvatar(
        userId: widget.userId,
        fileBytes: bytes,
        fileName: fileName,
      );

      if (!mounted) return;
      setState(() {
        _profile = updated;
        _imageVersion++;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile photo updated')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload photo: $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

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
                  color: const Color(0xFFEEF2FF),
                ),
                child: const Icon(
                  Icons.person_outline,
                  color: Color(0xFF4F46E5),
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Profile",
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                    SizedBox(height: 2),
                    Text(
                      "Edit your personal info",
                      style: TextStyle(fontSize: 12.5, color: Colors.black54),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: _loadProfile,
                tooltip: 'Refresh',
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _avatarSection() {
    final imgUrl = _profile?.profileImageUrl;
    String? fullUrl;
    if (imgUrl != null && imgUrl.isNotEmpty) {
      fullUrl = '${AuthService.baseUrl}$imgUrl?v=$_imageVersion';
    }

    return Center(
      child: Stack(
        children: [
          CircleAvatar(
            radius: 54,
            backgroundColor: Colors.grey.shade200,
            backgroundImage: fullUrl != null ? NetworkImage(fullUrl) : null,
            child: fullUrl == null
                ? const Icon(Icons.person, size: 54, color: Colors.black54)
                : null,
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Material(
              elevation: 6,
              shape: const CircleBorder(),
              child: InkWell(
                onTap: _pickAndUploadImage,
                customBorder: const CircleBorder(),
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF4F46E5),
                  ),
                  child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _fieldCard({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    bool readOnly = false,
    TextInputType keyboardType = TextInputType.text,
    String? hint,
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
        child: TextField(
          controller: controller,
          readOnly: readOnly,
          keyboardType: keyboardType,
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

  @override
  void dispose() {
    _firstCtrl.dispose();
    _lastCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

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
              Color(0xFFFDF2F8),
            ],
          ),
        ),
        child: SafeArea(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : (_profile == null)
                  ? const Center(child: Text('Profile not found'))
                  : Column(
                      children: [
                        _modernHeader(),
                        Expanded(
                          child: RefreshIndicator(
                            onRefresh: _loadProfile,
                            child: ListView(
                              padding: const EdgeInsets.fromLTRB(14, 6, 14, 22),
                              children: [
                                const SizedBox(height: 6),
                                _avatarSection(),
                                const SizedBox(height: 14),

                                _fieldCard(
                                  label: 'First name',
                                  controller: _firstCtrl,
                                  icon: Icons.badge_outlined,
                                  hint: 'e.g., Ibrahim',
                                ),
                                const SizedBox(height: 10),

                                _fieldCard(
                                  label: 'Last name',
                                  controller: _lastCtrl,
                                  icon: Icons.badge_outlined,
                                  hint: 'e.g., Abu Kush',
                                ),
                                const SizedBox(height: 10),

                                _fieldCard(
                                  label: 'Email',
                                  controller: _emailCtrl,
                                  icon: Icons.email_outlined,
                                  readOnly: true,
                                ),
                                const SizedBox(height: 10),

                                _fieldCard(
                                  label: 'Phone (Israel)',
                                  controller: _phoneCtrl,
                                  icon: Icons.phone_outlined,
                                  keyboardType: TextInputType.phone,
                                  hint: '0521234567',
                                ),
                                const SizedBox(height: 16),

                                SizedBox(
                                  height: 48,
                                  child: ElevatedButton.icon(
                                    onPressed: _saving ? null : _saveProfile,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF4F46E5),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                    ),
                                    icon: _saving
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
                                      _saving ? 'Saving...' : 'Save changes',
                                      style: const TextStyle(fontWeight: FontWeight.w800),
                                    ),
                                  ),
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
