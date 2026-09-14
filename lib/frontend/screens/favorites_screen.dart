import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../managers/cart_manager.dart';
import '../../managers/favorites_manager.dart';
import '../../managers/theme_manager.dart';
import '../../managers/toast_manager.dart';
import 'food_detail_screen.dart';

class FavoritesScreen extends StatelessWidget {
  final VoidCallback onExploreTap;

  const FavoritesScreen({super.key, required this.onExploreTap});

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
        final isDark = ThemeManager.instance.isDarkMode(context);

        return Scaffold(
          backgroundColor: bg,
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
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
                            'Saved Favorites',
                            style: GoogleFonts.baloo2(
                              fontSize: 32,
                              fontWeight: FontWeight.w700,
                              color: textColor,
                            ),
                          ),
                        ],
                      ),
                      ValueListenableBuilder<List<FoodItem>>(
                        valueListenable: FavoritesManager.instance,
                        builder: (context, favorites, child) {
                          if (favorites.isEmpty) return const SizedBox.shrink();
                          return TextButton.icon(
                            onPressed: () {
                              FavoritesManager.instance.clearFavorites();
                              ToastManager.instance.show(
                                context,
                                'Favorites cleared',
                                icon: Icons.delete_outline_rounded,
                              );
                            },
                            icon: const Icon(Icons.delete_outline, size: 16, color: Colors.redAccent),
                            label: Text(
                              'Clear All',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.redAccent,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: ValueListenableBuilder<List<FoodItem>>(
                    valueListenable: FavoritesManager.instance,
                    builder: (context, favorites, child) {
                      if (favorites.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.favorite_border_rounded,
                                size: 80,
                                color: subtextColor.withValues(alpha: 0.3),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No Saved Favorites Yet',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Tap the heart icon on any food item to save it here!',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: subtextColor,
                                ),
                              ),
                              const SizedBox(height: 24),
                              ElevatedButton(
                                onPressed: onExploreTap,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: accent,
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                child: Text(
                                  'Explore Menu',
                                  style: GoogleFonts.poppins(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return GridView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
                        itemCount: favorites.length,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.75,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 16,
                        ),
                        itemBuilder: (context, index) {
                          final item = favorites[index];

                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => FoodDetailScreen(foodItem: item),
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: cardBg,
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(color: hairline),
                                boxShadow: [
                                  if (!isDark)
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.04),
                                      blurRadius: 10,
                                    ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Stack(
                                      children: [
                                        Center(
                                          child: Hero(
                                            tag: 'fav_${item.id}',
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(18),
                                              child: Image.asset(
                                                item.imagePath,
                                                fit: BoxFit.cover,
                                                errorBuilder: (c, e, s) => Container(
                                                  color: Colors.white10,
                                                  child: Icon(Icons.fastfood, color: accent, size: 50),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          top: 4,
                                          right: 4,
                                          child: GestureDetector(
                                            onTap: () {
                                              FavoritesManager.instance.toggleFavorite(item);
                                            },
                                            child: Container(
                                              padding: const EdgeInsets.all(6),
                                              decoration: BoxDecoration(
                                                color: isDark
                                                    ? Colors.black.withValues(alpha: 0.6)
                                                    : Colors.white.withValues(alpha: 0.9),
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(
                                                Icons.favorite,
                                                color: Colors.redAccent,
                                                size: 16,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    item.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: textColor,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        item.priceString,
                                        style: GoogleFonts.poppins(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: ThemeManager.instance.priceColor(context),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      ElevatedButton(
                                        onPressed: () {
                                          CartManager.instance.addItem(item);
                                          ToastManager.instance.show(
                                            context,
                                            '${item.name} added to cart',
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: accent,
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                        ),
                                        child: Text(
                                          '+ Cart',
                                          style: GoogleFonts.poppins(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
