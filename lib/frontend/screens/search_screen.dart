import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../managers/cart_manager.dart';
import '../../managers/favorites_manager.dart';
import '../../managers/theme_manager.dart';
import '../../managers/toast_manager.dart';
import 'food_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  final VoidCallback onBackTap;

  const SearchScreen({super.key, required this.onBackTap});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with TickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  late final AnimationController _glowController;

  final List<String> _recentSearches = [
    'Biriyani',
    'Cheeseburger',
    'Truffle Pizza',
    'Iced Matcha',
    'Chocolate Cake',
  ];

  final List<FoodItem> _allFoodItems = const [
    // BIRIYANI
    FoodItem(
      id: 'hyderabadi_chicken_biriyani',
      name: 'Hyderabadi Chicken Biriyani',
      priceString: '₹180',
      price: 180.0,
      imagePath: 'assets/images/chicken biriyani 1.jpeg',
      description: 'Authentic Hyderabadi dum biriyani cooked with tender chicken, aromatic basmati rice, saffron, and traditional spices.',
      rating: 4.9,
      category: 'Biriyani',
    ),
    FoodItem(
      id: 'lucknowi_chicken_biriyani',
      name: 'Awadhi Lucknowi Biriyani',
      priceString: '₹220',
      price: 220.0,
      imagePath: 'assets/images/chicken biriyani 2.jpeg',
      description: 'Royal Awadhi style chicken biriyani slow-cooked in a sealed clay pot with kewra water and caramelised onions.',
      rating: 4.8,
      category: 'Biriyani',
    ),
    FoodItem(
      id: 'smoky_dum_biriyani',
      name: 'Smoky Dum Biriyani',
      priceString: '₹195',
      price: 195.0,
      imagePath: 'assets/images/chicken biriyani 3.jpeg',
      description: 'Charcoal-infused smoky chicken biriyani layered with fragrant long-grain basmati and fresh mint leaves.',
      rating: 4.7,
      category: 'Biriyani',
    ),
    FoodItem(
      id: 'tikka_biriyani',
      name: 'Chicken Tikka Biriyani',
      priceString: '₹210',
      price: 210.0,
      imagePath: 'assets/images/chicken biriyani 4.jpeg',
      description: 'Tender tandoori chicken tikka pieces embedded in rich spiced biriyani rice served with cucumber raita.',
      rating: 4.9,
      category: 'Biriyani',
    ),
    FoodItem(
      id: 'mutton_dum_biriyani',
      name: 'Royal Mutton Dum Biriyani',
      priceString: '₹280',
      price: 280.0,
      imagePath: 'assets/images/mutton biriyani 2.jpeg',
      description: 'Succulent slow-cooked mutton shank biriyani infused with cardamom, cloves, ghee, and golden fried cashews.',
      rating: 4.9,
      category: 'Biriyani',
    ),
    FoodItem(
      id: 'chettinad_mutton_biriyani',
      name: 'Chettinad Spicy Mutton Biriyani',
      priceString: '₹290',
      price: 290.0,
      imagePath: 'assets/images/mutton biriyani 3.jpeg',
      description: 'Fiery South Indian Chettinad style mutton biriyani packed with freshly ground roasted pepper masala.',
      rating: 4.8,
      category: 'Biriyani',
    ),
    FoodItem(
      id: 'button_mushroom_biriyani',
      name: 'Button Mushroom Biriyani',
      priceString: '₹160',
      price: 160.0,
      imagePath: 'assets/images/button biriyani 1.jpg',
      description: 'Fresh button mushrooms and farm vegetables tossed in fragrant basmati rice and aromatic biriyani spices.',
      rating: 4.6,
      category: 'Biriyani',
    ),

    // BURGERS & CHICKEN
    FoodItem(
      id: 'beef_burger',
      name: 'Angus Beef Burger Premium',
      priceString: '₹199',
      price: 199.0,
      imagePath: 'assets/images/beef burger.png',
      description: 'Big juicy Angus Beef Burger with double cheddar, lettuce, heirloom tomato, caramelized onions and signature truffle sauce.',
      rating: 4.9,
      category: 'Burger',
    ),
    FoodItem(
      id: 'double_burger',
      name: 'Double Smash Cheeseburger',
      priceString: '₹249',
      price: 249.0,
      imagePath: 'assets/images/hamburger-chips.png',
      description: 'Loaded with double smash beef patties, melted sharp cheddar, dill pickles, and crispy garlic chips.',
      rating: 4.8,
      category: 'Burger',
    ),
    FoodItem(
      id: 'crispy_chicken_burger',
      name: 'Classic Crispy Chicken Burger',
      priceString: '₹169',
      price: 169.0,
      imagePath: 'assets/images/burger.png',
      description: 'Golden crispy chicken breast fillet with chipotle mayo, crunchy purple cabbage slaw, and toasted brioche bun.',
      rating: 4.7,
      category: 'Burger',
    ),
    FoodItem(
      id: 'zesty_fried_chicken',
      name: 'Zesty Fried Chicken Wings',
      priceString: '₹179',
      price: 179.0,
      imagePath: 'assets/images/friedchicken.jpeg',
      description: 'Extra crunchy buttermilk fried chicken wings tossed in secret house spice rub served with honey mustard dip.',
      rating: 4.8,
      category: 'Burger',
    ),

    // PIZZA
    FoodItem(
      id: 'cheese_pizza',
      name: 'Artisan Margherita Pizza',
      priceString: '₹249',
      price: 249.0,
      imagePath: 'assets/images/pizza.png',
      description: 'Hand-tossed sourdough pizza with San Marzano tomato sauce, fresh buffalo mozzarella, and sweet basil.',
      rating: 4.8,
      category: 'Pizza',
    ),
    FoodItem(
      id: 'pepperoni_pizza',
      name: 'Supreme Pepperoni Feast',
      priceString: '₹349',
      price: 349.0,
      imagePath: 'assets/images/pizz.png',
      description: 'Loaded edge-to-edge with spicy Italian pepperoni, extra mozzarella, crushed red pepper flakes, and oregano.',
      rating: 4.9,
      category: 'Pizza',
    ),
    FoodItem(
      id: 'bbq_chicken_pizza',
      name: 'BBQ Smoked Chicken Pizza',
      priceString: '₹379',
      price: 379.0,
      imagePath: 'assets/images/pizza 1.jpeg',
      description: 'Sweet smoked BBQ chicken chunks, red onions, cilantro, and blend of smoked gouda and mozzarella cheese.',
      rating: 4.7,
      category: 'Pizza',
    ),
    FoodItem(
      id: 'four_cheese_pizza',
      name: 'Four Cheese Gourmet Pizza',
      priceString: '₹329',
      price: 329.0,
      imagePath: 'assets/images/pizza 2.jpeg',
      description: 'Rich white base pizza with mozzarella, gorgonzola, parmesan reggiano, and creamy ricotta cheese.',
      rating: 4.8,
      category: 'Pizza',
    ),
    FoodItem(
      id: 'truffle_mushroom_pizza',
      name: 'Truffle Wild Mushroom Pizza',
      priceString: '₹359',
      price: 359.0,
      imagePath: 'assets/images/pizza 3.jpeg',
      description: 'Sautéed cremini and porcini mushrooms drizzled with white truffle oil, fresh thyme, and fontina cheese.',
      rating: 4.9,
      category: 'Pizza',
    ),
    FoodItem(
      id: 'spicy_veggie_pizza',
      name: 'Spicy Veggie Supreme Pizza',
      priceString: '₹279',
      price: 279.0,
      imagePath: 'assets/images/Pizza 4.jpeg',
      description: 'Bell peppers, black olives, sweet corn, jalapeños, red onions, and house tomato sauce on crispy thin crust.',
      rating: 4.6,
      category: 'Pizza',
    ),
    FoodItem(
      id: 'paneer_tikka_pizza',
      name: 'Paneer Tikka Fusion Pizza',
      priceString: '₹299',
      price: 299.0,
      imagePath: 'assets/images/pizaa 5.jpeg',
      description: 'Marinated paneer tikka cubes, capsicum, mint chutney swirl, and mozzarella cheese on woodfired crust.',
      rating: 4.7,
      category: 'Pizza',
    ),
    FoodItem(
      id: 'smoky_sausage_pizza',
      name: 'Smoky Sausage Crust Pizza',
      priceString: '₹339',
      price: 339.0,
      imagePath: 'assets/images/pizza 6.jpeg',
      description: 'Italian sausage crumbles, caramelized garlic, roasted red peppers, and cheesy stuffed crust edge.',
      rating: 4.7,
      category: 'Pizza',
    ),

    // DRINKS
    FoodItem(
      id: 'coca_cola',
      name: 'Chilled Coca-Cola 330ml',
      priceString: '₹40',
      price: 40.0,
      imagePath: 'assets/images/cococola .jpeg',
      description: 'Classic ice-cold carbonated Coca-Cola original taste for maximum refreshment.',
      rating: 4.9,
      category: 'Drinks',
    ),
    FoodItem(
      id: 'pepsi',
      name: 'Crisp Pepsi Can 330ml',
      priceString: '₹40',
      price: 40.0,
      imagePath: 'assets/images/pepsi.jpeg',
      description: 'Chilled refreshing Pepsi cola can with bold citrus undertones.',
      rating: 4.8,
      category: 'Drinks',
    ),
    FoodItem(
      id: 'fanta',
      name: 'Sparkling Fanta Orange',
      priceString: '₹40',
      price: 40.0,
      imagePath: 'assets/images/fanta.jpeg',
      description: 'Bubbly orange soda packed with bright fruity flavor.',
      rating: 4.7,
      category: 'Drinks',
    ),
    FoodItem(
      id: 'frooti',
      name: 'Mango Frooti Nectar',
      priceString: '₹35',
      price: 35.0,
      imagePath: 'assets/images/frooti.jpeg',
      description: 'Sweet Alphonso mango juice nectar chilled to perfection.',
      rating: 4.8,
      category: 'Drinks',
    ),
    FoodItem(
      id: 'real_mixed_juice',
      name: 'Real Mixed Fruit Juice',
      priceString: '₹55',
      price: 55.0,
      imagePath: 'assets/images/real juice.jpeg',
      description: '100% natural blend of guava, apple, orange, and mango juice without added preservatives.',
      rating: 4.8,
      category: 'Drinks',
    ),
    FoodItem(
      id: 'real_orange_juice',
      name: 'Real Fresh Orange Juice',
      priceString: '₹55',
      price: 55.0,
      imagePath: 'assets/images/real juice orange.jpeg',
      description: 'Freshly pressed Valencia orange juice packed with natural Vitamin C.',
      rating: 4.9,
      category: 'Drinks',
    ),

    // DESSERTS
    FoodItem(
      id: 'belgian_choco_cake',
      name: 'Belgian Chocolate Cake',
      priceString: '₹129',
      price: 129.0,
      imagePath: 'assets/images/dessert.png',
      description: 'Decadent triple layer dark Belgian chocolate sponge cake with rich chocolate ganache topping.',
      rating: 4.9,
      category: 'Dessert',
    ),
    FoodItem(
      id: 'triple_choco_pancake',
      name: 'Triple Choco Pancake Stack',
      priceString: '₹149',
      price: 149.0,
      imagePath: 'assets/images/chocopancake.png',
      description: 'Fluffy buttermilk pancakes drizzled with Nutella, white chocolate chips, and fresh berries.',
      rating: 4.8,
      category: 'Dessert',
    ),
    FoodItem(
      id: 'choco_waffles',
      name: 'Golden Chocolate Waffles',
      priceString: '₹159',
      price: 159.0,
      imagePath: 'assets/images/chocowafles.png',
      description: 'Crispy Liege waffle topped with warm milk chocolate drizzle, whipped cream, and chocolate curls.',
      rating: 4.9,
      category: 'Dessert',
    ),
    FoodItem(
      id: 'red_velvet_cupcake',
      name: 'Red Velvet Lava Cupcake',
      priceString: '₹99',
      price: 99.0,
      imagePath: 'assets/images/dessert 1.jpeg',
      description: 'Moist red velvet sponge with molten cream cheese filling and crushed vanilla crumbs.',
      rating: 4.7,
      category: 'Dessert',
    ),
    FoodItem(
      id: 'strawberry_cheesecake',
      name: 'Strawberry Cheesecake Slice',
      priceString: '₹139',
      price: 139.0,
      imagePath: 'assets/images/dessert2.png',
      description: 'Classic New York style baked cheesecake topped with fresh strawberry glaze and graham cracker crust.',
      rating: 4.8,
      category: 'Dessert',
    ),
    FoodItem(
      id: 'tiramisu_delight',
      name: 'Tiramisu Espresso Delight',
      priceString: '₹149',
      price: 149.0,
      imagePath: 'assets/images/dessert 3.jpeg',
      description: 'Italian ladyfingers soaked in espresso coffee layered with mascarpone cream and cocoa powder.',
      rating: 4.9,
      category: 'Dessert',
    ),
    FoodItem(
      id: 'choco_brownie_fudge',
      name: 'Artisan Choco Brownie Fudge',
      priceString: '₹119',
      price: 119.0,
      imagePath: 'assets/images/dessert5.jpg',
      description: 'Warm fudgy chocolate brownie with toasted walnuts and hot fudge syrup.',
      rating: 4.8,
      category: 'Dessert',
    ),
    FoodItem(
      id: 'blueberry_tart',
      name: 'Blueberry Tart Delight',
      priceString: '₹129',
      price: 129.0,
      imagePath: 'assets/images/dessert6.jpeg',
      description: 'Crisp pastry shell filled with vanilla custard and topped with fresh wild blueberries.',
      rating: 4.7,
      category: 'Dessert',
    ),

    // SIDES
    FoodItem(
      id: 'french_fries',
      name: 'Crispy Truffle Fries',
      priceString: '₹99',
      price: 99.0,
      imagePath: 'assets/images/french.png',
      description: 'Golden crispy Yukon gold potato fries seasoned with black truffle salt and served with garlic aioli.',
      rating: 4.8,
      category: 'Sides',
    ),
  ];

  List<FoodItem> _filteredItems = [];

  @override
  void initState() {
    super.initState();
    _filteredItems = List.from(_allFoodItems);
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _controller.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    final query = _controller.text.trim().toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredItems = List.from(_allFoodItems);
      } else {
        _filteredItems = _allFoodItems
            .where((item) =>
                item.name.toLowerCase().contains(query) ||
                item.description.toLowerCase().contains(query) ||
                item.category.toLowerCase().contains(query))
            .toList();
      }
    });
  }

  void _addSearchQueryToHistory(String query) {
    if (query.trim().isEmpty) return;
    final trimmed = query.trim();
    setState(() {
      _recentSearches.removeWhere((item) => item.toLowerCase() == trimmed.toLowerCase());
      _recentSearches.insert(0, trimmed);
      if (_recentSearches.length > 8) {
        _recentSearches.removeLast();
      }
    });
  }

  @override
  void dispose() {
    _controller.removeListener(_onSearchChanged);
    _controller.dispose();
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

  void _showFilterModal(BuildContext context, Color cardBg, Color textColor, Color subtextColor, Color accent) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          border: Border.all(color: accent.withValues(alpha: 0.4)),
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
            const SizedBox(height: 18),
            Text(
              'Filter & Sort',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 16),
            Text('Sort By', style: GoogleFonts.poppins(color: subtextColor, fontSize: 13)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                FilterChip(
                  label: const Text('Highest Rating'),
                  selected: true,
                  onSelected: (v) {},
                  selectedColor: accent,
                  labelStyle: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                FilterChip(
                  label: const Text('Fastest Delivery'),
                  selected: false,
                  onSelected: (v) {},
                  labelStyle: GoogleFonts.poppins(color: subtextColor),
                ),
                FilterChip(
                  label: const Text('Price: Low to High'),
                  selected: false,
                  onSelected: (v) {},
                  labelStyle: GoogleFonts.poppins(color: subtextColor),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: accent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                ),
                child: Text(
                  'Apply Filters',
                  style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
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

        final isSearching = _controller.text.trim().isNotEmpty;

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
                    return _glowBlob(accent.withValues(alpha: opacity), 240);
                  },
                ),
              ),
              SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Bar
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              GestureDetector(
                                onTap: widget.onBackTap,
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
                                'Search Food',
                                style: GoogleFonts.baloo2(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w700,
                                  color: textColor,
                                ),
                              ),
                            ],
                          ),
                          GestureDetector(
                            onTap: () => _showFilterModal(context, cardBg, textColor, subtextColor, accent),
                            behavior: HitTestBehavior.opaque,
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: cardBg,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: hairline),
                              ),
                              child: Icon(Icons.tune_rounded, color: accent, size: 20),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Search TextField Box
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: TextField(
                        controller: _controller,
                        style: GoogleFonts.poppins(color: textColor, fontSize: 14.5),
                        onSubmitted: (val) => _addSearchQueryToHistory(val),
                        decoration: InputDecoration(
                          hintText: 'Search biriyani, pizza, burger, drinks...',
                          hintStyle: GoogleFonts.poppins(color: subtextColor, fontSize: 13.5),
                          prefixIcon: Icon(Icons.search, color: accent),
                          suffixIcon: _controller.text.isNotEmpty
                              ? IconButton(
                                  icon: Icon(Icons.clear, color: subtextColor),
                                  onPressed: () {
                                    _controller.clear();
                                  },
                                )
                              : null,
                          filled: true,
                          fillColor: cardBg,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(22),
                            borderSide: BorderSide(color: hairline),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(22),
                            borderSide: BorderSide(color: hairline),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(22),
                            borderSide: BorderSide(color: accent, width: 1.5),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // RECENT SEARCHES CHIPS: Shown ONLY BEFORE typing/searching!
                    if (!isSearching && _recentSearches.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.history_rounded, size: 16, color: accent),
                                const SizedBox(width: 6),
                                Text(
                                  'Recent Searches',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: textColor,
                                  ),
                                ),
                              ],
                            ),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _recentSearches.clear();
                                });
                              },
                              child: Text(
                                'Clear All',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: accent,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: _recentSearches.map((tag) {
                              return GestureDetector(
                                onTap: () {
                                  _controller.text = tag;
                                  _addSearchQueryToHistory(tag);
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(right: 8),
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                                  decoration: BoxDecoration(
                                    color: cardBg,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: hairline),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.north_west_rounded, size: 12, color: subtextColor),
                                      const SizedBox(width: 6),
                                      Text(
                                        tag,
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          color: subtextColor,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Search Status Header
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Text(
                        isSearching
                            ? 'Found ${_filteredItems.length} Dishes for "${_controller.text.trim()}"'
                            : 'All Delicious Dishes (${_filteredItems.length})',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Results Dish List
                    Expanded(
                      child: _filteredItems.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.search_off_rounded,
                                    size: 70,
                                    color: subtextColor.withValues(alpha: 0.3),
                                  ),
                                  const SizedBox(height: 14),
                                  Text(
                                    'No matching dishes found',
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: textColor,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Try searching for "biriyani", "burger", "pizza", or "drinks"',
                                    style: GoogleFonts.poppins(fontSize: 13, color: subtextColor),
                                  ),
                                ],
                              ),
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
                              itemCount: _filteredItems.length,
                              separatorBuilder: (context, index) => const SizedBox(height: 14),
                              itemBuilder: (context, index) {
                                final item = _filteredItems[index];

                                return GestureDetector(
                                  onTap: () {
                                    _addSearchQueryToHistory(item.name);
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
                                      borderRadius: BorderRadius.circular(22),
                                      border: Border.all(color: hairline),
                                      boxShadow: [
                                        if (!isDark)
                                          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6),
                                      ],
                                    ),
                                    child: Row(
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(16),
                                          child: Image.asset(
                                            item.imagePath,
                                            width: 80,
                                            height: 80,
                                            fit: BoxFit.cover,
                                            errorBuilder: (c, e, s) => Container(
                                              width: 80,
                                              height: 80,
                                              color: Colors.white10,
                                              child: Icon(Icons.fastfood, color: accent),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 14),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                item.name,
                                                style: GoogleFonts.poppins(
                                                  fontSize: 15.5,
                                                  fontWeight: FontWeight.bold,
                                                  color: textColor,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Row(
                                                children: [
                                                  const Icon(Icons.star, color: Colors.amber, size: 14),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    '${item.rating}',
                                                    style: GoogleFonts.poppins(color: subtextColor, fontSize: 12),
                                                  ),
                                                  const SizedBox(width: 10),
                                                  Text(
                                                    '15-20 min',
                                                    style: GoogleFonts.poppins(color: subtextColor, fontSize: 11.5),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 6),
                                              Text(
                                                item.priceString,
                                                style: GoogleFonts.poppins(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                  color: ThemeManager.instance.priceColor(context),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Column(
                                          children: [
                                            ValueListenableBuilder<List<FoodItem>>(
                                              valueListenable: FavoritesManager.instance,
                                              builder: (context, favs, child) {
                                                final isFav = FavoritesManager.instance.isFavorite(item.id);

                                                return IconButton(
                                                  icon: Icon(
                                                    isFav ? Icons.favorite : Icons.favorite_border,
                                                    color: isFav ? Colors.redAccent : subtextColor,
                                                    size: 20,
                                                  ),
                                                  onPressed: () {
                                                    FavoritesManager.instance.toggleFavorite(item);
                                                  },
                                                );
                                              },
                                            ),
                                            ValueListenableBuilder<List<CartItem>>(
                                              valueListenable: CartManager.instance,
                                              builder: (context, cartItems, child) {
                                                final qty = CartManager.instance.getItemQuantity(item.id);

                                                if (qty == 0) {
                                                  return GestureDetector(
                                                    onTap: () {
                                                      CartManager.instance.addItem(item);
                                                      ToastManager.instance.show(
                                                        context,
                                                        '${item.name} added to cart',
                                                      );
                                                    },
                                                    child: Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                                                      decoration: BoxDecoration(
                                                        color: accent,
                                                        borderRadius: BorderRadius.circular(16),
                                                      ),
                                                      child: Row(
                                                        children: [
                                                          const Icon(Icons.add, color: Colors.black, size: 16),
                                                          const SizedBox(width: 4),
                                                          Text(
                                                            'Add',
                                                            style: GoogleFonts.poppins(
                                                              fontSize: 12,
                                                              fontWeight: FontWeight.bold,
                                                              color: Colors.black,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  );
                                                }

                                                return Container(
                                                  decoration: BoxDecoration(
                                                    color: accent,
                                                    borderRadius: BorderRadius.circular(18),
                                                  ),
                                                  child: Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      GestureDetector(
                                                        onTap: () => CartManager.instance.decrementQuantity(item),
                                                        behavior: HitTestBehavior.opaque,
                                                        child: const Padding(
                                                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                                          child: Icon(Icons.remove, color: Colors.black, size: 15),
                                                        ),
                                                      ),
                                                      Text(
                                                        '$qty',
                                                        style: GoogleFonts.poppins(
                                                          fontSize: 13,
                                                          fontWeight: FontWeight.w900,
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                      GestureDetector(
                                                        onTap: () => CartManager.instance.incrementQuantity(item),
                                                        behavior: HitTestBehavior.opaque,
                                                        child: const Padding(
                                                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                                          child: Icon(Icons.add, color: Colors.black, size: 15),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
                                            ),
                                          ],
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
              ),
            ],
          ),
        );
      },
    );
  }
}
