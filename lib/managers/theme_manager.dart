import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeManager extends ValueNotifier<ThemeMode> {
  static final ThemeManager instance = ThemeManager._internal();

  ThemeManager._internal() : super(ThemeMode.dark) {
    loadThemeMode();
  }

  Future<void> loadThemeMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final modeStr = prefs.getString('app_theme_mode');
      if (modeStr != null) {
        if (modeStr == 'dark') value = ThemeMode.dark;
        if (modeStr == 'light') value = ThemeMode.light;
        if (modeStr == 'system') value = ThemeMode.system;
      }
    } catch (e) {
      debugPrint("Theme load note: $e");
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    value = mode;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('app_theme_mode', mode.name);
    } catch (e) {
      debugPrint("Theme save note: $e");
    }
  }

  bool isDarkMode(BuildContext context) {
    if (value == ThemeMode.system) {
      return MediaQuery.of(context).platformBrightness == Brightness.dark;
    }
    return value == ThemeMode.dark;
  }

  Color bgColor(BuildContext context) {
    return isDarkMode(context) ? const Color(0xFF000000) : const Color(0xFFF8FAFC);
  }

  Color cardColor(BuildContext context) {
    return isDarkMode(context) ? const Color(0xFF121212) : const Color(0xFFFFFFFF);
  }

  Color textColor(BuildContext context) {
    return isDarkMode(context) ? const Color(0xFFFFFFFF) : const Color(0xFF0F172A);
  }

  Color subtextColor(BuildContext context) {
    return isDarkMode(context) ? const Color(0x99FFFFFF) : const Color(0xFF64748B);
  }

  Color hairlineColor(BuildContext context) {
    return isDarkMode(context) ? const Color(0x1AFFFFFF) : const Color(0xFFE2E8F0);
  }

  Color accentColor(BuildContext context) {
    return isDarkMode(context) ? const Color(0xFF3DEBB0) : const Color(0xFF0D9488);
  }

  Color priceColor(BuildContext context) {
    return isDarkMode(context) ? const Color(0xFFFFC107) : const Color(0xFFD97706);
  }

  ThemeData get lightThemeData {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFF7F9F8),
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF00B884),
        brightness: Brightness.light,
        surface: Colors.white,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: const Color(0xFF00B884),
        contentTextStyle: GoogleFonts.poppins(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        behavior: SnackBarBehavior.floating,
      ),
      textTheme: GoogleFonts.poppinsTextTheme(ThemeData.light().textTheme),
    );
  }

  ThemeData get darkThemeData {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: Colors.black,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF3DEBB0),
        brightness: Brightness.dark,
        surface: const Color(0xFF121212),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: const Color(0xFF3DEBB0),
        contentTextStyle: GoogleFonts.poppins(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        behavior: SnackBarBehavior.floating,
      ),
      textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
    );
  }
}
