import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../managers/theme_manager.dart';
import '../root_screen.dart';
import 'login_screen.dart';

class UserAccessChoiceScreen extends StatelessWidget {
  const UserAccessChoiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeManager.instance.isDarkMode(context);
    final bg = ThemeManager.instance.bgColor(context);
    final cardBg = ThemeManager.instance.cardColor(context);
    final textColor = ThemeManager.instance.textColor(context);
    final subtextColor = ThemeManager.instance.subtextColor(context);
    final accent = ThemeManager.instance.accentColor(context);
    final hairline = ThemeManager.instance.hairlineColor(context);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),

              // Header Branding Icon
              Center(
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    border: Border.all(color: accent.withValues(alpha: 0.3), width: 2),
                  ),
                  child: Icon(Icons.restaurant_menu_rounded, color: accent, size: 48),
                ),
              ),

              const SizedBox(height: 24),

              Text(
                'Havelin',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'DancingScript',
                  fontSize: 54,
                  color: accent,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                'How would you like to proceed?',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),

              const SizedBox(height: 6),

              Text(
                'Select an access option to continue to your gourmet dining experience',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: subtextColor,
                  height: 1.4,
                ),
              ),

              const Spacer(),

              // Option 1: Login / Sign Up Access Card
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: accent.withValues(alpha: 0.4), width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: accent.withValues(alpha: isDark ? 0.15 : 0.08),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: accent.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.person_rounded, color: accent, size: 24),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Sign In / Create Account',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Access profile, address & order history',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: subtextColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.arrow_forward_ios_rounded, color: accent, size: 16),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Option 2: Direct Menu Access Card
              GestureDetector(
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const RootScreen(promptAddressSetup: true)),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: hairline),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: textColor.withValues(alpha: 0.08),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.explore_rounded, color: textColor, size: 24),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Explore Menu Directly',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Browse dishes as guest user',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: subtextColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.arrow_forward_ios_rounded, color: subtextColor, size: 16),
                    ],
                  ),
                ),
              ),

              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
