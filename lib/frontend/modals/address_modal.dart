import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../backend/address_backend_service.dart';
import '../../managers/theme_manager.dart';
import '../../managers/toast_manager.dart';
import '../../managers/user_manager.dart';

void showAddressModalSheet(BuildContext context, {VoidCallback? onAddressSaved}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => AddressModalSheet(onAddressSaved: onAddressSaved),
  );
}

class AddressModalSheet extends StatefulWidget {
  final VoidCallback? onAddressSaved;

  const AddressModalSheet({super.key, this.onAddressSaved});

  @override
  State<AddressModalSheet> createState() => _AddressModalSheetState();
}

class _AddressModalSheetState extends State<AddressModalSheet> {
  late String _selectedTag;
  late final TextEditingController _streetController;
  late final TextEditingController _landmarkController;
  late final TextEditingController _cityController;

  final List<Map<String, dynamic>> _tagOptions = const [
    {'label': 'Home', 'icon': Icons.home_rounded},
    {'label': 'Work', 'icon': Icons.work_rounded},
    {'label': 'Other', 'icon': Icons.location_on_rounded},
  ];

  @override
  void initState() {
    super.initState();
    final current = UserManager.instance.value;
    _selectedTag = current.addressTag;
    _streetController = TextEditingController(text: current.addressLine1);
    _landmarkController = TextEditingController(text: current.landmark);
    _cityController = TextEditingController(text: current.addressLine2);
  }

  @override
  void dispose() {
    _streetController.dispose();
    _landmarkController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  void _useGpsLocation() {
    setState(() {
      _streetController.text = '742 Evergreen Terrace, Apt 4B';
      _landmarkController.text = 'Near Central Plaza Park';
      _cityController.text = 'New York, NY 10001';
    });
    ToastManager.instance.show(
      context,
      'GPS Location Detected',
      icon: Icons.my_location_rounded,
    );
  }

  void _saveAddress() {
    final street = _streetController.text.trim();
    final landmark = _landmarkController.text.trim();
    final city = _cityController.text.trim();

    if (street.isEmpty) {
      ToastManager.instance.show(
        context,
        'Please enter a valid street address',
        icon: Icons.warning_amber_rounded,
      );
      return;
    }

    final user = UserManager.instance.value;
    final addressModel = AddressModel(
      id: "ADDR_${DateTime.now().millisecondsSinceEpoch}",
      tag: _selectedTag,
      receiverName: user.name.isNotEmpty ? user.name : 'Customer',
      receiverPhone: user.phone,
      addressLine1: street,
      addressLine2: landmark,
      city: city.isNotEmpty ? city : 'Hyderabad',
      isDefault: true,
    );

    // Save to Cloud Firestore in background
    AddressBackendService.instance.saveAddress(
      user.phone.isNotEmpty ? user.phone : 'USER_GUEST',
      addressModel,
    );

    UserManager.instance.updateAddress(
      tag: _selectedTag,
      line1: street,
      line2: city.isNotEmpty ? city : 'Jubilee Hills, Hyderabad',
      landmark: landmark,
    );

    Navigator.pop(context);

    ToastManager.instance.show(
      context,
      'Delivery Address set to $_selectedTag',
      icon: Icons.location_on_rounded,
    );

    widget.onAddressSaved?.call();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeManager.instance,
      builder: (context, themeMode, child) {
        final cardBg = ThemeManager.instance.cardColor(context);
        final textColor = ThemeManager.instance.textColor(context);
        final subtextColor = ThemeManager.instance.subtextColor(context);
        final hairline = ThemeManager.instance.hairlineColor(context);
        final accent = ThemeManager.instance.accentColor(context);
        final isDark = ThemeManager.instance.isDarkMode(context);

        final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

        return AnimatedPadding(
          padding: EdgeInsets.only(bottom: bottomPadding),
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
              border: Border.all(color: accent.withValues(alpha: 0.3)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 24,
                  offset: const Offset(0, -6),
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 5,
                      decoration: BoxDecoration(
                        color: subtextColor.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: accent.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.location_on_rounded, color: accent, size: 22),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Delivery Address',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                              ),
                              Text(
                                'Where should we deliver your order?',
                                style: GoogleFonts.poppins(fontSize: 12, color: subtextColor),
                              ),
                            ],
                          ),
                        ],
                      ),

                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: hairline,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.close, color: subtextColor, size: 18),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  GestureDetector(
                    onTap: _useGpsLocation,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: accent.withValues(alpha: 0.4)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.my_location_rounded, color: accent, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            'Use GPS Current Location',
                            style: GoogleFonts.poppins(
                              fontSize: 13.5,
                              fontWeight: FontWeight.bold,
                              color: accent,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Text(
                    'Save Address As',
                    style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold, color: textColor),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: _tagOptions.map((opt) {
                      final label = opt['label'] as String;
                      final icon = opt['icon'] as IconData;
                      final isSelected = _selectedTag == label;

                      return Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedTag = label),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: isSelected ? accent : hairline,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected ? accent : hairline,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(icon, size: 16, color: isSelected ? Colors.black : textColor),
                                const SizedBox(width: 6),
                                Text(
                                  label,
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                    color: isSelected ? Colors.black : textColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 20),

                  Text(
                    'Street Address / Flat / Building',
                    style: GoogleFonts.poppins(fontSize: 12.5, fontWeight: FontWeight.w600, color: subtextColor),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _streetController,
                    style: GoogleFonts.poppins(color: textColor, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'e.g. 123 Gourmet Street, Suite 400',
                      hintStyle: GoogleFonts.poppins(color: subtextColor.withValues(alpha: 0.5), fontSize: 13),
                      prefixIcon: Icon(Icons.location_city_rounded, color: accent, size: 20),
                      filled: true,
                      fillColor: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF2F4F3),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide(color: hairline),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide(color: hairline),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide(color: accent, width: 1.5),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  Text(
                    'Landmark / Area (Optional)',
                    style: GoogleFonts.poppins(fontSize: 12.5, fontWeight: FontWeight.w600, color: subtextColor),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _landmarkController,
                    style: GoogleFonts.poppins(color: textColor, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'e.g. Near Central Park Tower',
                      hintStyle: GoogleFonts.poppins(color: subtextColor.withValues(alpha: 0.5), fontSize: 13),
                      prefixIcon: Icon(Icons.place_outlined, color: accent, size: 20),
                      filled: true,
                      fillColor: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF2F4F3),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide(color: hairline),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide(color: hairline),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide(color: accent, width: 1.5),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  Text(
                    'City, State & Zip Code',
                    style: GoogleFonts.poppins(fontSize: 12.5, fontWeight: FontWeight.w600, color: subtextColor),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _cityController,
                    style: GoogleFonts.poppins(color: textColor, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'e.g. New York, NY 10001',
                      hintStyle: GoogleFonts.poppins(color: subtextColor.withValues(alpha: 0.5), fontSize: 13),
                      prefixIcon: Icon(Icons.map_rounded, color: accent, size: 20),
                      filled: true,
                      fillColor: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF2F4F3),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide(color: hairline),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide(color: hairline),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide(color: accent, width: 1.5),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton.icon(
                      onPressed: _saveAddress,
                      icon: const Icon(Icons.check_circle_rounded, color: Colors.black),
                      label: Text(
                        'Save & Set Delivery Address',
                        style: GoogleFonts.poppins(
                          fontSize: 15.5,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                        elevation: 4,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
