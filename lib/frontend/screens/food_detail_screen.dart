import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../backend/review_backend_service.dart';
import '../../managers/cart_manager.dart';
import '../../managers/favorites_manager.dart';
import '../../managers/theme_manager.dart';
import '../../managers/toast_manager.dart';
import '../../managers/user_manager.dart';

class FoodDetailScreen extends StatefulWidget {
  final FoodItem foodItem;

  const FoodDetailScreen({super.key, required this.foodItem});

  @override
  State<FoodDetailScreen> createState() => _FoodDetailScreenState();
}

class _FoodDetailScreenState extends State<FoodDetailScreen>
    with SingleTickerProviderStateMixin {
  int _quantity = 1;
  late String _selectedCustomizationOption;
  final Set<String> _selectedAddOnIds = {};
  final TextEditingController _notesController = TextEditingController();
  late final AnimationController _glowController;

  @override
  void initState() {
    super.initState();
    _selectedCustomizationOption = _customizationOptions.first;
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _notesController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  List<AddOn> get _availableAddOns {
    switch (widget.foodItem.category) {
      case 'Drinks':
        return const [
          AddOn(id: 'extra_ice', name: 'Extra Ice Cubes', price: 0.50, imagePath: ''),
          AddOn(id: 'lemon_slice', name: 'Fresh Lemon Slice', price: 0.50, imagePath: ''),
          AddOn(id: 'mint_infusion', name: 'Mint Leaves Infusion', price: 0.80, imagePath: ''),
          AddOn(id: 'upgrade_size', name: 'Upgraded 500ml Size', price: 1.50, imagePath: ''),
        ];
      case 'Dessert':
        return const [
          AddOn(id: 'vanilla_icecream', name: 'Vanilla Bean Ice Cream Scoop', price: 2.00, imagePath: ''),
          AddOn(id: 'choco_fudge', name: 'Warm Chocolate Fudge Drizzle', price: 1.50, imagePath: ''),
          AddOn(id: 'whipped_cream', name: 'Whipped Cream Topping', price: 1.00, imagePath: ''),
          AddOn(id: 'hazelnuts', name: 'Crushed Roasted Hazelnuts', price: 1.20, imagePath: ''),
        ];
      case 'Biriyani':
        return const [
          AddOn(id: 'cucumber_raita', name: 'Cucumber Mint Raita', price: 1.50, imagePath: ''),
          AddOn(id: 'boiled_egg', name: 'Extra Boiled Egg', price: 1.00, imagePath: ''),
          AddOn(id: 'salan_gravy', name: 'Mirchi Ka Salan Gravy', price: 2.00, imagePath: ''),
          AddOn(id: 'fried_onions', name: 'Extra Fried Onions & Cashews', price: 1.80, imagePath: ''),
        ];
      case 'Pizza':
        return const [
          AddOn(id: 'extra_mozzarella', name: 'Extra Buffalo Mozzarella', price: 2.50, imagePath: ''),
          AddOn(id: 'stuffed_crust', name: 'Cheesy Garlic Stuffed Crust', price: 3.00, imagePath: ''),
          AddOn(id: 'chipotle_dip', name: 'Chipotle Dip', price: 1.50, imagePath: ''),
          AddOn(id: 'jalapenos', name: 'Sliced Jalapeños', price: 1.00, imagePath: ''),
        ];
      case 'Sides':
        return const [
          AddOn(id: 'cheese_sauce', name: 'Melted Cheese Sauce Dip', price: 2.00, imagePath: ''),
          AddOn(id: 'garlic_aioli', name: 'Garlic Aioli Dip', price: 1.50, imagePath: ''),
          AddOn(id: 'bacon_bits', name: 'Extra Loaded Bacon Bits', price: 2.20, imagePath: ''),
        ];
      case 'Burger':
      default:
        return const [
          AddOn(id: 'extra_cheese', name: 'Extra Cheddar Cheese', price: 1.50, imagePath: ''),
          AddOn(id: 'double_patty', name: 'Double Patty Upgrade', price: 4.00, imagePath: ''),
          AddOn(id: 'crispy_bacon', name: 'Crispy Bacon Strip', price: 2.00, imagePath: ''),
          AddOn(id: 'truffle_mayo', name: 'Truffle Mayo Dip', price: 1.50, imagePath: ''),
        ];
    }
  }

  String get _customizationTitle {
    switch (widget.foodItem.category) {
      case 'Drinks':
        return 'Temperature & Ice Level';
      case 'Dessert':
        return 'Serving Preference';
      case 'Pizza':
        return 'Crust Selection';
      case 'Sides':
        return 'Seasoning Style';
      case 'Biriyani':
      case 'Burger':
      default:
        return 'Spice Level';
    }
  }

  List<String> get _customizationOptions {
    switch (widget.foodItem.category) {
      case 'Drinks':
        return const ['Extra Chilled', 'Normal Ice', 'Less Ice', 'No Ice'];
      case 'Dessert':
        return const ['Serve Chilled', 'Warm & Fresh', 'Extra Sweet'];
      case 'Pizza':
        return const ['Woodfired Classic', 'Thin Crust', 'Spicy Crust'];
      case 'Sides':
        return const ['Truffle Salt', 'Peri Peri Spice', 'Classic Salt'];
      case 'Biriyani':
      case 'Burger':
      default:
        return const ['Mild', 'Medium', 'Hot', 'Extra Spicy'];
    }
  }

  String get _caloriesText {
    switch (widget.foodItem.category) {
      case 'Drinks':
        return '140 kcal';
      case 'Dessert':
        return '320 kcal';
      case 'Biriyani':
        return '680 kcal';
      case 'Pizza':
        return '520 kcal';
      case 'Sides':
        return '380 kcal';
      case 'Burger':
      default:
        return '580 kcal';
    }
  }

  double get _calculateTotal {
    double base = widget.foodItem.price;
    double addOnsSum = 0.0;
    for (var addon in _availableAddOns) {
      if (_selectedAddOnIds.contains(addon.id)) {
        addOnsSum += addon.price;
      }
    }
    return (base + addOnsSum) * _quantity;
  }

  List<AddOn> get _getSelectedAddOnObjects {
    return _availableAddOns.where((a) => _selectedAddOnIds.contains(a.id)).toList();
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

        final total = _calculateTotal;
        final currentAddOns = _availableAddOns;
        final custTitle = _customizationTitle;
        final custOptions = _customizationOptions;
        final calories = _caloriesText;

        return Scaffold(
          backgroundColor: bg,
          body: Stack(
            children: [
              Positioned(
                top: -80,
                right: -60,
                child: AnimatedBuilder(
                  animation: _glowController,
                  builder: (context, child) {
                    final opacity = lerpDouble(0.08, 0.18, _glowController.value)!;
                    return _glowBlob(accent.withValues(alpha: opacity), 260);
                  },
                ),
              ),

              CustomScrollView(
                slivers: [
                  // Full-Bleed Parallax Header Image
                  SliverAppBar(
                    expandedHeight: 380,
                    pinned: true,
                    elevation: 0,
                    backgroundColor: bg,
                    leading: Padding(
                      padding: const EdgeInsets.only(left: 16.0, top: 8.0, bottom: 8.0),
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          decoration: BoxDecoration(
                            color: isDark ? Colors.black.withValues(alpha: 0.65) : Colors.white.withValues(alpha: 0.85),
                            shape: BoxShape.circle,
                            border: Border.all(color: hairline),
                          ),
                          child: Icon(Icons.arrow_back_ios_new, color: textColor, size: 18),
                        ),
                      ),
                    ),
                    actions: [
                      ValueListenableBuilder<List<FoodItem>>(
                        valueListenable: FavoritesManager.instance,
                        builder: (context, favs, child) {
                          final isFav = FavoritesManager.instance.isFavorite(widget.foodItem.id);
                          return Padding(
                            padding: const EdgeInsets.only(right: 16.0, top: 8.0, bottom: 8.0),
                            child: GestureDetector(
                              onTap: () => FavoritesManager.instance.toggleFavorite(widget.foodItem),
                              behavior: HitTestBehavior.opaque,
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: isDark ? Colors.black.withValues(alpha: 0.65) : Colors.white.withValues(alpha: 0.85),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: hairline),
                                ),
                                child: Icon(
                                  isFav ? Icons.favorite : Icons.favorite_border,
                                  color: isFav ? Colors.redAccent : subtextColor,
                                  size: 20,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                    flexibleSpace: FlexibleSpaceBar(
                      background: Stack(
                        fit: StackFit.expand,
                        children: [
                          Hero(
                            tag: widget.foodItem.id,
                            child: Image.asset(
                              widget.foodItem.imagePath,
                              fit: BoxFit.cover,
                              errorBuilder: (c, e, s) => Container(
                                color: cardBg,
                                child: Icon(Icons.fastfood, color: accent, size: 100),
                              ),
                            ),
                          ),
                          // Subtle Gradient Overlays
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.black.withValues(alpha: 0.6),
                                  Colors.transparent,
                                  bg.withValues(alpha: 0.95),
                                ],
                                stops: const [0.0, 0.45, 1.0],
                              ),
                            ),
                          ),
                          // Category Badge overlay on image bottom left
                          Positioned(
                            bottom: 20,
                            left: 20,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                              decoration: BoxDecoration(
                                color: accent,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: accent.withValues(alpha: 0.4),
                                    blurRadius: 10,
                                  ),
                                ],
                              ),
                              child: Text(
                                widget.foodItem.category.toUpperCase(),
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Content Body
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title & Base Price
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  widget.foodItem.name,
                                  style: GoogleFonts.baloo2(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w800,
                                    color: textColor,
                                    height: 1.15,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Text(
                                '₹${widget.foodItem.price.toStringAsFixed(0)}',
                                style: GoogleFonts.poppins(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: ThemeManager.instance.priceColor(context),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Quick Info Badges Bar
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.amber.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: Colors.amber.withValues(alpha: 0.4)),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.star_rounded, color: Colors.amber, size: 18),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${widget.foodItem.rating}',
                                      style: GoogleFonts.poppins(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.amber,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: cardBg,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: hairline),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.timer_outlined, color: subtextColor, size: 16),
                                    const SizedBox(width: 6),
                                    Text(
                                      '15-20 min',
                                      style: GoogleFonts.poppins(fontSize: 12.5, color: subtextColor, fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: cardBg,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: hairline),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.local_fire_department_rounded, color: Colors.orangeAccent, size: 16),
                                    const SizedBox(width: 4),
                                    Text(
                                      calories,
                                      style: GoogleFonts.poppins(fontSize: 12.5, color: subtextColor, fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),
                          Text(
                            'Description',
                            style: GoogleFonts.poppins(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.foodItem.description,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: subtextColor,
                              height: 1.6,
                            ),
                          ),

                          const SizedBox(height: 26),
                          Divider(color: hairline),
                          const SizedBox(height: 16),

                          // Dynamic Customization Option Selector (e.g. Temperature for Drinks, Spice Level for Biriyani/Burgers)
                          Text(
                            custTitle,
                            style: GoogleFonts.poppins(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 12),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: custOptions.map((option) {
                                final isSelected = _selectedCustomizationOption == option;
                                return GestureDetector(
                                  onTap: () => setState(() => _selectedCustomizationOption = option),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    margin: const EdgeInsets.only(right: 10),
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: isSelected ? accent : cardBg,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(color: isSelected ? accent : hairline),
                                    ),
                                    child: Text(
                                      option,
                                      style: GoogleFonts.poppins(
                                        fontSize: 12.5,
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                        color: isSelected ? Colors.black : subtextColor,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),

                          const SizedBox(height: 26),
                          Divider(color: hairline),
                          const SizedBox(height: 16),

                          // Dynamic Category Add-Ons & Extras Section
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Add-ons & Extras',
                                style: GoogleFonts.poppins(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                              ),
                              Text(
                                'Optional',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: subtextColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Column(
                            children: currentAddOns.map((addon) {
                              final isChecked = _selectedAddOnIds.contains(addon.id);
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    if (isChecked) {
                                      _selectedAddOnIds.remove(addon.id);
                                    } else {
                                      _selectedAddOnIds.add(addon.id);
                                    }
                                  });
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  margin: const EdgeInsets.only(bottom: 10),
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: cardBg,
                                    borderRadius: BorderRadius.circular(18),
                                    border: Border.all(
                                      color: isChecked ? accent : hairline,
                                      width: isChecked ? 1.5 : 1,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 22,
                                        height: 22,
                                        decoration: BoxDecoration(
                                          color: isChecked ? accent : Colors.transparent,
                                          borderRadius: BorderRadius.circular(6),
                                          border: Border.all(
                                            color: isChecked ? accent : subtextColor,
                                            width: 1.5,
                                          ),
                                        ),
                                        child: isChecked
                                            ? const Icon(Icons.check, size: 15, color: Colors.white)
                                            : null,
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Text(
                                          addon.name,
                                          style: GoogleFonts.poppins(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: textColor,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        '+₹${addon.price.toStringAsFixed(0)}',
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: ThemeManager.instance.priceColor(context),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),

                          const SizedBox(height: 20),

                          // Quantity Selector Card
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: cardBg,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: hairline),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Quantity',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: textColor,
                                  ),
                                ),
                                Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        if (_quantity > 1) {
                                          setState(() => _quantity--);
                                        }
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: hairline,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Icon(Icons.remove, color: textColor, size: 18),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 18),
                                      child: Text(
                                        '$_quantity',
                                        style: GoogleFonts.poppins(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: textColor,
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        setState(() => _quantity++);
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: accent,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: const Icon(Icons.add, color: Colors.white, size: 18),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Customer Reviews & Community Ratings Section
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Customer Reviews ⭐',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                              ),
                              TextButton.icon(
                                onPressed: () {
                                  _showWriteReviewModal(context, cardBg, textColor, subtextColor, accent, hairline);
                                },
                                icon: Icon(Icons.rate_review_outlined, color: accent, size: 16),
                                label: Text(
                                  'Write Review',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.bold,
                                    color: accent,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),

                          StreamBuilder<List<ReviewModel>>(
                            stream: ReviewBackendService.instance.streamDishReviews(widget.foodItem.id),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return const Center(child: CircularProgressIndicator(color: Color(0xFF00A884)));
                              }
                              final reviews = snapshot.data ?? [];
                              if (reviews.isEmpty) {
                                return Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: cardBg,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: hairline),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.star_half_rounded, color: Colors.amber, size: 24),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          'No reviews yet. Be the first foodie to rate ${widget.foodItem.name}!',
                                          style: GoogleFonts.poppins(fontSize: 12, color: subtextColor),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }

                              return Column(
                                children: reviews.map((rev) {
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 10),
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color: cardBg,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(color: hairline),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                CircleAvatar(
                                                  radius: 14,
                                                  backgroundColor: accent.withValues(alpha: 0.15),
                                                  child: Text(
                                                    rev.userName.isNotEmpty ? rev.userName[0].toUpperCase() : 'G',
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.bold,
                                                      color: accent,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  rev.userName,
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.bold,
                                                    color: textColor,
                                                  ),
                                                ),
                                                if (rev.isVerifiedBuyer) ...[
                                                  const SizedBox(width: 6),
                                                  const Icon(Icons.verified, color: Colors.green, size: 14),
                                                ],
                                              ],
                                            ),
                                            Row(
                                              children: List.generate(5, (starIndex) {
                                                return Icon(
                                                  starIndex < rev.rating ? Icons.star_rounded : Icons.star_border_rounded,
                                                  color: Colors.amber,
                                                  size: 15,
                                                );
                                              }),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          rev.comment,
                                          style: GoogleFonts.poppins(fontSize: 12, color: textColor),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              );
                            },
                          ),

                          const SizedBox(height: 120),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // Floating Bottom CTA Bar
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                    border: Border.all(color: hairline),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.6 : 0.08),
                        blurRadius: 20,
                        offset: const Offset(0, -6),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Total Price', style: GoogleFonts.poppins(fontSize: 12, color: subtextColor)),
                          const SizedBox(height: 2),
                          Text(
                            '₹${total.toStringAsFixed(0)}',
                            style: GoogleFonts.poppins(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: ThemeManager.instance.priceColor(context),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 54,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            CartManager.instance.addItem(
                              widget.foodItem,
                              quantity: _quantity,
                              selectedAddOns: _getSelectedAddOnObjects,
                            );
                            ToastManager.instance.show(
                              context,
                              'Added $_quantity x ${widget.foodItem.name} to cart',
                            );
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accent,
                            foregroundColor: Colors.black,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 28),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(27),
                            ),
                          ),
                          icon: const Icon(Icons.shopping_bag_rounded, color: Colors.black),
                          label: Text(
                            'Add to Cart',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
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

  void _showWriteReviewModal(
    BuildContext context,
    Color cardBg,
    Color textColor,
    Color subtextColor,
    Color accent,
    Color hairline,
  ) {
    double selectedRating = 5.0;
    final commentController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => SingleChildScrollView(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              border: Border.all(color: accent.withValues(alpha: 0.3)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: subtextColor.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Rate ${widget.foodItem.name} ⭐',
                  style: GoogleFonts.poppins(fontSize: 17, fontWeight: FontWeight.bold, color: textColor),
                ),
                Text(
                  'Share your gourmet dining feedback with fellow foodies!',
                  style: GoogleFonts.poppins(fontSize: 11.5, color: subtextColor),
                ),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    final starValue = (index + 1).toDouble();
                    return IconButton(
                      onPressed: () {
                        setModalState(() => selectedRating = starValue);
                      },
                      icon: Icon(
                        index < selectedRating ? Icons.star_rounded : Icons.star_border_rounded,
                        color: Colors.amber,
                        size: 36,
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: commentController,
                  maxLines: 3,
                  style: GoogleFonts.poppins(color: textColor, fontSize: 13.5),
                  decoration: InputDecoration(
                    hintText: 'Describe taste, presentation, spices...',
                    hintStyle: GoogleFonts.poppins(color: subtextColor, fontSize: 13),
                    filled: true,
                    fillColor: hairline.withValues(alpha: 0.2),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: hairline),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () async {
                      final user = UserManager.instance.value;
                      final commentText = commentController.text.trim();
                      final finalComment = commentText.isNotEmpty ? commentText : 'Delicious gourmet dish! Highly recommended.';

                      Navigator.pop(context);

                      await ReviewBackendService.instance.submitReview(
                        dishId: widget.foodItem.id,
                        dishName: widget.foodItem.name,
                        userId: user.phone.isNotEmpty ? user.phone : 'USER_GUEST',
                        userName: user.name.isNotEmpty ? user.name : 'Gourmet Foodie',
                        rating: selectedRating,
                        comment: finalComment,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    child: Text(
                      'Publish Review ⭐',
                      style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
