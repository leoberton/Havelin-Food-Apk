import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../backend/firebase_manager.dart';
import '../../managers/theme_manager.dart';
import '../../managers/user_manager.dart';

class EditProfileScreen extends StatefulWidget {
  final String currentName;
  final String currentPhone;
  final String currentAddressLine1;
  final String currentAddressLine2;
  final String avatarImagePath;

  const EditProfileScreen({
    super.key,
    required this.currentName,
    required this.currentPhone,
    required this.currentAddressLine1,
    required this.currentAddressLine2,
    this.avatarImagePath = 'assets/images/profile.jpeg',
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen>
    with TickerProviderStateMixin {
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _address1Controller;
  late final TextEditingController _address2Controller;

  late String _currentAvatarPath;
  late final AnimationController _glowController;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentName);
    _phoneController = TextEditingController(text: widget.currentPhone);
    _address1Controller = TextEditingController(text: widget.currentAddressLine1);
    _address2Controller = TextEditingController(text: widget.currentAddressLine2);
    _currentAvatarPath = widget.avatarImagePath;

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _address1Controller.dispose();
    _address2Controller.dispose();
    _glowController.dispose();
    super.dispose();
  }

  Widget _glowBlob(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color, color.withValues(alpha: 0)],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _currentAvatarPath = pickedFile.path;
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking image: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  void _showImagePickerOptions(Color cardBg, Color textColor, Color accent) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(color: accent.withValues(alpha: 0.4)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: textColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Change Profile Photo',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 20),
              Material(
                color: Colors.transparent,
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.photo_library_outlined, color: accent),
                  ),
                  title: Text(
                    'Choose from Gallery',
                    style: GoogleFonts.poppins(color: textColor, fontWeight: FontWeight.w500),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  },
                ),
              ),
              Material(
                color: Colors.transparent,
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.camera_alt_outlined, color: accent),
                  ),
                  title: Text(
                    'Take a Photo',
                    style: GoogleFonts.poppins(color: textColor, fontWeight: FontWeight.w500),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  void _saveProfile(Color accent) async {
    String finalAvatarPath = _currentAvatarPath;

    if (_currentAvatarPath.startsWith('/') || _currentAvatarPath.contains('/data/')) {
      final cloudUrl = await FirebaseManager.instance.uploadProfilePhotoToStorage(_currentAvatarPath);
      if (cloudUrl != null) {
        finalAvatarPath = cloudUrl;
      }
    }

    UserManager.instance.updateProfile(
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      addressLine1: _address1Controller.text.trim(),
      addressLine2: _address2Controller.text.trim(),
      profileImagePath: finalAvatarPath,
    );

    final updatedData = {
      'name': _nameController.text.trim(),
      'phone': _phoneController.text.trim(),
      'addressLine1': _address1Controller.text.trim(),
      'addressLine2': _address2Controller.text.trim(),
      'avatarImagePath': finalAvatarPath,
    };

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Profile & Photo uploaded to Cloud Storage! 📸☁️'),
        duration: const Duration(seconds: 2),
        backgroundColor: accent,
      ),
    );

    Navigator.pop(context, updatedData);
  }

  Widget _buildAvatarImage() {
    if (_currentAvatarPath.startsWith('http://') || _currentAvatarPath.startsWith('https://')) {
      return Image.network(
        _currentAvatarPath,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Image.asset('assets/images/logo.png', fit: BoxFit.cover),
      );
    }
    if (_currentAvatarPath.startsWith('/') || _currentAvatarPath.contains('/data/')) {
      final file = File(_currentAvatarPath);
      if (file.existsSync()) {
        return Image.file(file, fit: BoxFit.cover);
      }
    }
    return Image.asset(
      _currentAvatarPath,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Image.asset('assets/images/logo.png', fit: BoxFit.cover),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeManager.instance,
      builder: (context, themeMode, child) {
        final bg = ThemeManager.instance.bgColor(context);
        final cardBg = ThemeManager.instance.cardColor(context);
        final textColor = ThemeManager.instance.textColor(context);
        final subtextColor = ThemeManager.instance.subtextColor(context);
        final hairline = ThemeManager.instance.hairlineColor(context);
        final accent = ThemeManager.instance.accentColor(context);

        return Scaffold(
          backgroundColor: bg,
          body: Stack(
            children: [
              Positioned(
                top: -80,
                right: -60,
                child: _glowBlob(accent.withValues(alpha: 0.10), 220),
              ),
              SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            behavior: HitTestBehavior.opaque,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: hairline,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.arrow_back_ios_new,
                                color: textColor,
                                size: 18,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Container(
                            width: 5,
                            height: 26,
                            decoration: BoxDecoration(
                              color: accent,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Edit Profile',
                            style: GoogleFonts.baloo2(
                              fontSize: 34,
                              fontWeight: FontWeight.w700,
                              color: textColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 26),

                      // Touchable Avatar photo hero
                      Center(
                        child: GestureDetector(
                          onTap: () => _showImagePickerOptions(cardBg, textColor, accent),
                          behavior: HitTestBehavior.opaque,
                          child: Stack(
                            children: [
                              AnimatedBuilder(
                                animation: _glowController,
                                builder: (context, child) {
                                  final glow = lerpDouble(10, 22, _glowController.value)!;
                                  return Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: accent.withValues(alpha: 0.35),
                                          blurRadius: glow,
                                          spreadRadius: 1,
                                        ),
                                      ],
                                    ),
                                    child: child,
                                  );
                                },
                                child: Container(
                                  width: 96,
                                  height: 96,
                                  padding: const EdgeInsets.all(3),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: accent.withValues(alpha: 0.6),
                                      width: 1.6,
                                    ),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(48),
                                    child: _buildAvatarImage(),
                                  ),
                                ),
                              ),
                              Positioned(
                                right: 0,
                                bottom: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: accent,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),

                      AnimatedBuilder(
                        animation: _glowController,
                        builder: (context, child) {
                          final glow = lerpDouble(10, 22, _glowController.value)!;
                          return Container(
                            decoration: BoxDecoration(
                              color: cardBg,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: accent.withValues(alpha: 0.45),
                                width: 1.2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: accent.withValues(alpha: 0.15),
                                  blurRadius: glow,
                                  spreadRadius: 0,
                                ),
                              ],
                            ),
                            child: child,
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildCustomTextField(
                                label: 'Full Name',
                                controller: _nameController,
                                icon: Icons.person_outline,
                                cardBg: cardBg,
                                hairline: hairline,
                                textColor: textColor,
                                subtextColor: subtextColor,
                                accent: accent,
                              ),
                              const SizedBox(height: 18),
                              Divider(color: hairline, height: 1),
                              const SizedBox(height: 18),
                              _buildCustomTextField(
                                label: 'Phone Number',
                                controller: _phoneController,
                                icon: Icons.phone_outlined,
                                keyboardType: TextInputType.phone,
                                cardBg: cardBg,
                                hairline: hairline,
                                textColor: textColor,
                                subtextColor: subtextColor,
                                accent: accent,
                              ),
                              const SizedBox(height: 18),
                              Divider(color: hairline, height: 1),
                              const SizedBox(height: 18),
                              _buildCustomTextField(
                                label: 'Address Line 1',
                                controller: _address1Controller,
                                icon: Icons.location_on_outlined,
                                cardBg: cardBg,
                                hairline: hairline,
                                textColor: textColor,
                                subtextColor: subtextColor,
                                accent: accent,
                              ),
                              const SizedBox(height: 18),
                              Divider(color: hairline, height: 1),
                              const SizedBox(height: 18),
                              _buildCustomTextField(
                                label: 'Address Line 2',
                                controller: _address2Controller,
                                icon: Icons.map_outlined,
                                cardBg: cardBg,
                                hairline: hairline,
                                textColor: textColor,
                                subtextColor: subtextColor,
                                accent: accent,
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),

                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () => _saveProfile(accent),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accent,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: Text(
                            'Save Changes',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCustomTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required Color cardBg,
    required Color hairline,
    required Color textColor,
    required Color subtextColor,
    required Color accent,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: subtextColor,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
          cursorColor: accent,
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: cardBg,
            prefixIcon: Icon(icon, color: accent, size: 20),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: hairline),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: accent, width: 1.2),
            ),
          ),
        ),
      ],
    );
  }
}
