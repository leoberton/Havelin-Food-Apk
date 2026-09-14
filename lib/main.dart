import 'dart:async';
import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'backend/auth_service.dart';
import 'backend/firebase_manager.dart';
import 'backend/notification_manager.dart';
import 'frontend/root_screen.dart';
import 'frontend/screens/no_internet_screen.dart';
import 'frontend/screens/user_access_choice_screen.dart';
import 'managers/cart_manager.dart';
import 'managers/favorites_manager.dart';
import 'managers/haptic_manager.dart';
import 'managers/theme_manager.dart';
import 'managers/user_manager.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const HavelinApp());

  // Initialize Firebase in background after UI is mounted
  Future.microtask(() async {
    try {
      await FirebaseManager.instance.initializeFirebase();
      await FirebaseManager.instance.syncUserProfile(UserManager.instance.value);
      await FirebaseManager.instance.seedMenuDishes(sampleDishes);
    } catch (e) {
      debugPrint("Firebase startup note: $e");
    }
  });
}

class HavelinApp extends StatelessWidget {
  const HavelinApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeManager.instance,
      builder: (context, themeMode, child) {
        return MaterialApp(
          title: 'Havelin',
          debugShowCheckedModeBanner: false,
          themeMode: themeMode,
          theme: ThemeManager.instance.lightThemeData,
          darkTheme: ThemeManager.instance.darkThemeData,
          builder: (context, child) => OnlineGuardWidget(child: child ?? const SizedBox()),
          home: const AnimatedEntrySplashScreen(),
        );
      },
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      await ThemeManager.instance.loadThemeMode();
      await HapticManager.instance.loadHapticsSetting();
      await UserManager.instance.loadLocalProfile();
      await FirebaseManager.instance.initializeFirebase();
      await NotificationManager.instance.initialize();

      // Run cloud sync in background without blocking app boot UI
      unawaited(FirebaseManager.instance.syncUserProfile(UserManager.instance.value));
      unawaited(FirebaseManager.instance.seedMenuDishes(sampleDishes));
      unawaited(FavoritesManager.instance.loadCloudAndLocalFavorites());
    } catch (e) {
      debugPrint("AuthWrapper init note: $e");
    } finally {
      if (mounted) {
        setState(() {
          _initialized = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const OnboardingScreen();
    }

    return StreamBuilder<User?>(
      stream: AuthService.instance.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          return const RootScreen(promptAddressSetup: false);
        }
        return const OnboardingScreen();
      },
    );
  }
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _glowController;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeManager.instance,
      builder: (context, themeMode, child) {
        final bg = ThemeManager.instance.bgColor(context);
        final textColor = ThemeManager.instance.textColor(context);
        final subtextColor = ThemeManager.instance.subtextColor(context);
        final accent = ThemeManager.instance.accentColor(context);
        final isDark = ThemeManager.instance.isDarkMode(context);
        final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;

        final mintTeal = accent;
        final mintGlow = isDark ? const Color(0xFF6FF0C4) : const Color(0xFF14B8A6);

        return Scaffold(
          backgroundColor: bg,
          body: Stack(
            children: [
              // Ambient Mint Glow behind central food image
              Positioned(
                top: MediaQuery.of(context).size.height * 0.18,
                left: 0,
                right: 0,
                child: Center(
                  child: AnimatedBuilder(
                    animation: _glowController,
                    builder: (context, child) {
                      final opacity = lerpDouble(0.12, 0.30, _glowController.value)!;
                      final size = lerpDouble(280.0, 340.0, _glowController.value)!;
                      return Container(
                        width: size,
                        height: size,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              mintTeal.withValues(alpha: opacity),
                              mintTeal.withValues(alpha: 0.0),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              SafeArea(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 12.0),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight - 24.0,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                              // Top Brand & Energetic Title Group
                              Column(
                                children: [
                                  const SizedBox(height: 12),

                                  // Glowing Cursive Brand Logo
                                  Text(
                                    'Havelin',
                                    style: TextStyle(
                                      fontFamily: 'DancingScript',
                                      fontSize: 60,
                                      color: mintTeal,
                                      fontWeight: FontWeight.bold,
                                      shadows: [
                                        Shadow(
                                          color: mintTeal.withValues(alpha: 0.8),
                                          blurRadius: 24,
                                        ),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(height: 16),

                                  // Energetic Title
                                  Text(
                                    'Craving\nGourmet Goodness? 🔥',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.baloo2(
                                      fontSize: 36,
                                      fontWeight: FontWeight.w800,
                                      color: textColor,
                                      height: 1.15,
                                    ),
                                  ),

                                  const SizedBox(height: 10),

                                  // Subtitle
                                  Text(
                                    'Freshly prepared by 4.9★ chefs & delivered\npiping hot in 20 minutes.',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.poppins(
                                      fontSize: 13.5,
                                      color: subtextColor,
                                      height: 1.4,
                                    ),
                                  ),

                                  const SizedBox(height: 28),

                                  // Energetic Floating Food Badges Grid
                                  AnimatedBuilder(
                                    animation: _glowController,
                                    builder: (context, child) {
                                      final pulse = lerpDouble(0.96, 1.04, _glowController.value)!;
                                      return Transform.scale(
                                        scale: pulse,
                                        child: Container(
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            color: cardBg.withValues(alpha: isDark ? 0.4 : 0.6),
                                            borderRadius: BorderRadius.circular(28),
                                            border: Border.all(
                                              color: mintTeal.withValues(alpha: 0.25),
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: mintTeal.withValues(alpha: isDark ? 0.15 : 0.08),
                                                blurRadius: 20,
                                                spreadRadius: 2,
                                              ),
                                            ],
                                          ),
                                          child: Wrap(
                                            alignment: WrapAlignment.center,
                                            spacing: 10,
                                            runSpacing: 12,
                                            children: [
                                              _buildEnergeticBadge('🍲 Dum Biryani', Colors.amber, isDark),
                                              _buildEnergeticBadge('🍕 Neapolitan Pizza', Colors.deepOrangeAccent, isDark),
                                              _buildEnergeticBadge('🍔 Angus Burger', Colors.lightBlueAccent, isDark),
                                              _buildEnergeticBadge('⚡ 20-Min Delivery', const Color(0xFF00A884), isDark),
                                              _buildEnergeticBadge('⭐ 4.9★ Rated', Colors.purpleAccent, isDark),
                                              _buildEnergeticBadge('🍰 Lava Cake', Colors.pinkAccent, isDark),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),

                            // Bottom Pinned "Get started" CTA Button
                            Padding(
                              padding: const EdgeInsets.only(top: 20.0, bottom: 12.0),
                              child: SizedBox(
                                width: double.infinity,
                                height: 56,
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const UserAccessChoiceScreen(),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    elevation: 8,
                                    shadowColor: mintTeal.withValues(alpha: 0.4),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                  ),
                                  child: Ink(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [mintTeal, mintGlow],
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                      ),
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            'Get started',
                                            style: GoogleFonts.poppins(
                                              fontSize: 17.5,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          const Icon(
                                            Icons.arrow_forward_rounded,
                                            color: Colors.black,
                                            size: 22,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEnergeticBadge(String label, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.18 : 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.5), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.2),
            blurRadius: 10,
          ),
        ],
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.white : Colors.black87,
        ),
      ),
    );
  }
}

class AnimatedEntrySplashScreen extends StatefulWidget {
  const AnimatedEntrySplashScreen({super.key});

  @override
  State<AnimatedEntrySplashScreen> createState() => _AnimatedEntrySplashScreenState();
}

class _AnimatedEntrySplashScreenState extends State<AnimatedEntrySplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeIn,
    );

    _scaleAnimation = Tween<double>(begin: 0.70, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutBack),
    );

    _animController.forward();

    // Display animated Havelin text for exactly 3.0 seconds before auto-navigating
    Future.delayed(const Duration(milliseconds: 3000), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, anim, secAnim) => const AuthWrapper(),
            transitionsBuilder: (context, anim, secAnim, child) {
              return FadeTransition(opacity: anim, child: child);
            },
            transitionDuration: const Duration(milliseconds: 600),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const mintTeal = Color(0xFF00A884);

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Stack(
        children: [
          // Centered Ambient Mint Glow
          Center(
            child: Container(
              width: 360,
              height: 360,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    mintTeal.withValues(alpha: 0.28),
                    mintTeal.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),

          // First Page: ONLY Animated "Havelin" Written Text (No Photos)
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Havelin',
                      style: TextStyle(
                        fontFamily: 'DancingScript',
                        fontSize: 84,
                        color: mintTeal,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            color: mintTeal.withValues(alpha: 0.7),
                            blurRadius: 32,
                          ),
                          Shadow(
                            color: Colors.black45,
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Gourmet Food Experience 🍲',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.white70,
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
