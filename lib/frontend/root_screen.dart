import 'dart:ui';
import 'package:flutter/material.dart';

import '../managers/cart_manager.dart';
import '../managers/haptic_manager.dart';
import '../managers/theme_manager.dart';
import '../managers/user_manager.dart';
import 'modals/address_modal.dart';
import 'screens/cart_screen.dart';
import 'screens/favorites_screen.dart';
import 'screens/menu_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/search_screen.dart';

class RootScreen extends StatefulWidget {
  final bool promptAddressSetup;

  const RootScreen({super.key, this.promptAddressSetup = false});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.promptAddressSetup || !UserManager.instance.value.isAddressConfigured) {
        showAddressModalSheet(context);
      }
    });
  }

  void _goToTab(int index) {
    if (_selectedIndex != index) {
      HapticManager.instance.selectionClick();
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<UserData>(
      valueListenable: UserManager.instance,
      builder: (context, userData, child) {
        final bg = ThemeManager.instance.bgColor(context);
        final cardBg = ThemeManager.instance.cardColor(context);
        final subtextColor = ThemeManager.instance.subtextColor(context);
        final accent = ThemeManager.instance.accentColor(context);
        final hairline = ThemeManager.instance.hairlineColor(context);
        final isDark = ThemeManager.instance.isDarkMode(context);

        final mintTeal = accent;
        final activeTab = _selectedIndex;

        return Scaffold(
          backgroundColor: bg,
          extendBody: true,
          body: IndexedStack(
            index: _selectedIndex,
            children: [
              MenuScreen(onSearchTap: () => _goToTab(1)),
              SearchScreen(onBackTap: () => _goToTab(0)),
              FavoritesScreen(onExploreTap: () => _goToTab(0)),
              CartScreen(onBackTap: () => _goToTab(0)),
              ProfileScreen(onBackTap: () => _goToTab(0)),
            ],
          ),
          bottomNavigationBar: _buildIconOnlyLuxuryNavBar(
            activeTab: activeTab,
            cardBg: cardBg,
            isDark: isDark,
            mintTeal: mintTeal,
            subtextColor: subtextColor,
            hairline: hairline,
          ),
        );
      },
    );
  }

  /// 🌟 Minimalist Icon-Only Ultra-Luxury Floating Gourmet Glass Navigation Bar
  Widget _buildIconOnlyLuxuryNavBar({
    required int activeTab,
    required Color cardBg,
    required bool isDark,
    required Color mintTeal,
    required Color subtextColor,
    required Color hairline,
  }) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final navBarWidth = constraints.maxWidth;
                final tabWidth = navBarWidth / 5.0;
                final targetLeft = activeTab * tabWidth;

                return Container(
                  height: 58,
                  decoration: BoxDecoration(
                    color: cardBg.withValues(alpha: isDark ? 0.92 : 0.95),
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(
                      color: mintTeal.withValues(alpha: isDark ? 0.35 : 0.25),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: mintTeal.withValues(alpha: isDark ? 0.20 : 0.10),
                        blurRadius: 20,
                        spreadRadius: 1,
                        offset: const Offset(0, 4),
                      ),
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.45 : 0.08),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // 🌟 SMOOTH SLIDING GLOW ACTIVE PILL (ICON ONLY)
                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 280),
                        curve: Curves.fastOutSlowIn,
                        left: targetLeft + (tabWidth * 0.08),
                        top: 7,
                        width: tabWidth * 0.84,
                        height: 44,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                mintTeal.withValues(alpha: isDark ? 0.28 : 0.20),
                                mintTeal.withValues(alpha: isDark ? 0.14 : 0.08),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(
                              color: mintTeal.withValues(alpha: 0.65),
                              width: 1.2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: mintTeal.withValues(alpha: 0.25),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                        ),
                      ),

                      // ICON ONLY TABS (NO TEXT)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: _buildIconTabItem(
                              index: 0,
                              activeIndex: activeTab,
                              activeIcon: Icons.home_rounded,
                              inactiveIcon: Icons.home_outlined,
                              accent: mintTeal,
                              subtextColor: subtextColor,
                            ),
                          ),
                          Expanded(
                            child: _buildIconTabItem(
                              index: 1,
                              activeIndex: activeTab,
                              activeIcon: Icons.search_rounded,
                              inactiveIcon: Icons.search_outlined,
                              accent: mintTeal,
                              subtextColor: subtextColor,
                            ),
                          ),
                          Expanded(
                            child: _buildIconTabItem(
                              index: 2,
                              activeIndex: activeTab,
                              activeIcon: Icons.favorite_rounded,
                              inactiveIcon: Icons.favorite_border_rounded,
                              accent: mintTeal,
                              subtextColor: subtextColor,
                            ),
                          ),
                          Expanded(
                            child: _buildIconCartTabItem(
                              index: 3,
                              activeIndex: activeTab,
                              accent: mintTeal,
                              subtextColor: subtextColor,
                            ),
                          ),
                          Expanded(
                            child: _buildIconTabItem(
                              index: 4,
                              activeIndex: activeTab,
                              activeIcon: Icons.person_rounded,
                              inactiveIcon: Icons.person_outline_rounded,
                              accent: mintTeal,
                              subtextColor: subtextColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIconTabItem({
    required int index,
    required int activeIndex,
    required IconData activeIcon,
    required IconData inactiveIcon,
    required Color accent,
    required Color subtextColor,
  }) {
    final isSelected = activeIndex == index;

    return GestureDetector(
      onTap: () => _goToTab(index),
      behavior: HitTestBehavior.opaque,
      child: Center(
        child: AnimatedScale(
          duration: const Duration(milliseconds: 200),
          scale: isSelected ? 1.15 : 0.95,
          child: Icon(
            isSelected ? activeIcon : inactiveIcon,
            color: isSelected ? accent : subtextColor,
            size: isSelected ? 25 : 22,
          ),
        ),
      ),
    );
  }

  Widget _buildIconCartTabItem({
    required int index,
    required int activeIndex,
    required Color accent,
    required Color subtextColor,
  }) {
    final isSelected = activeIndex == index;

    return GestureDetector(
      onTap: () => _goToTab(index),
      behavior: HitTestBehavior.opaque,
      child: ValueListenableBuilder<List<CartItem>>(
        valueListenable: CartManager.instance,
        builder: (context, cartItems, child) {
          final totalItemCount = CartManager.instance.totalItemCount;

          return Center(
            child: AnimatedScale(
              duration: const Duration(milliseconds: 200),
              scale: isSelected ? 1.15 : 0.95,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(
                    isSelected ? Icons.shopping_bag_rounded : Icons.shopping_bag_outlined,
                    color: isSelected ? accent : subtextColor,
                    size: isSelected ? 25 : 22,
                  ),
                  if (totalItemCount > 0)
                    Positioned(
                      right: -6,
                      top: -4,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(
                          color: Colors.redAccent,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
                        child: Text(
                          '$totalItemCount',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8.5,
                            fontWeight: FontWeight.bold,
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
    );
  }
}
