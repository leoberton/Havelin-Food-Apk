import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../managers/cart_manager.dart';
import '../../managers/coupon_manager.dart';
import '../../managers/favorites_manager.dart';
import '../../managers/theme_manager.dart';
import '../../managers/toast_manager.dart';
import '../../managers/user_manager.dart';
import '../../backend/firebase_manager.dart';
import '../modals/address_modal.dart';
import 'food_detail_screen.dart';
import 'notifications_screen.dart';

class MenuScreen extends StatefulWidget {
  final VoidCallback onSearchTap;

  const MenuScreen({super.key, required this.onSearchTap});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen>
    with TickerProviderStateMixin {
  late final AnimationController _glowController;
  late final PageController _bannerPageController;
  int _selectedCategoryIndex = 0;
  int _currentBannerIndex = 0;

  final List<Map<String, dynamic>> _categories = const [
    {'name': 'All', 'icon': Icons.restaurant_menu_rounded},
    {'name': 'Biriyani', 'icon': Icons.rice_bowl_rounded},
    {'name': 'Burger', 'icon': Icons.lunch_dining_rounded},
    {'name': 'Pizza', 'icon': Icons.local_pizza_rounded},
    {'name': 'Drinks', 'icon': Icons.local_drink_rounded},
    {'name': 'Dessert', 'icon': Icons.cake_rounded},
    {'name': 'Sides', 'icon': Icons.fastfood_rounded},
  ];

  final List<Map<String, dynamic>> _promoBanners = const [
    {
      'title': 'CRAVE IT? GET 30% OFF',
      'code': 'HAVELIN30',
      'subtitle': 'On your first gourmet order above ₹299',
      'image': 'assets/images/beef burger.png',
      'badge': 'FLASH DEAL',
      'cta': 'Claim 30% Off',
      'colors': [Color(0xFF0F766E), Color(0xFF0D9488), Color(0xFF14B8A6)],
      'badgeColor': Color(0xFFFFD700),
    },
    {
      'title': 'SPECIAL DUM BIRIYANI',
      'code': 'BIRIYANI20',
      'subtitle': 'Authentic Hyderabadi Dum Spices',
      'image': 'assets/images/chicken biriyani 1.jpeg',
      'badge': 'CHEF SPECIAL',
      'cta': 'Order Biriyani',
      'colors': [Color(0xFFC2410C), Color(0xFFEA580C), Color(0xFFF97316)],
      'badgeColor': Color(0xFFFFFFFF),
    },
    {
      'title': 'CHEF WOODFIRED PIZZA',
      'code': 'WEEKEND20',
      'subtitle': 'Fresh buffalo mozzarella & sweet basil',
      'image': 'assets/images/pizza.png',
      'badge': 'HOT & CRISPY',
      'cta': 'Explore Pizzas',
      'colors': [Color(0xFFBE123C), Color(0xFFE11D48), Color(0xFFF43F5E)],
      'badgeColor': Color(0xFFFFD700),
    },
  ];

  final List<FoodItem> _allFoodItems = const [
    // BIRIYANI CATEGORY
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

  List<FoodItem> get _displayedFoodItems {
    final selectedCat = _categories[_selectedCategoryIndex]['name'] as String;
    if (selectedCat == 'All') {
      return _allFoodItems;
    }
    return _allFoodItems.where((item) => item.category == selectedCat).toList();
  }

  @override
  void initState() {
    super.initState();
    _bannerPageController = PageController(viewportFraction: 0.92);
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    // Sync Live Online Menu Catalog with Cloud Firestore
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FirebaseManager.instance.seedMenuDishes(_allFoodItems);
    });
  }

  @override
  void dispose() {
    _bannerPageController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  Widget _riseIn({required int index, required Widget child}) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 360 + index * 60),
      curve: Curves.easeOutCubic,
      builder: (context, value, child2) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 16),
            child: child2,
          ),
        );
      },
      child: child,
    );
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

        final displayedItems = _displayedFoodItems;

        return Scaffold(
          backgroundColor: bg,
          body: Stack(
            children: [
              Positioned(
                top: -90,
                right: -70,
                child: AnimatedBuilder(
                  animation: _glowController,
                  builder: (context, child) {
                    final opacity = lerpDouble(0.08, 0.20, _glowController.value)!;
                    return _glowBlob(accent.withValues(alpha: opacity), 280);
                  },
                ),
              ),
              SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(top: 10.0, bottom: 95.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Energetic Column 1: Top Navigation Bar with Pulse Dot & Actions
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ValueListenableBuilder<UserData>(
                              valueListenable: UserManager.instance,
                              builder: (context, user, child) {
                                if (user.isNewAccount) {
                                  // NEW ACCOUNT: Show address changing option chip
                                  return GestureDetector(
                                    onTap: () => showAddressModalSheet(context),
                                    behavior: HitTestBehavior.opaque,
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: accent.withValues(alpha: 0.15),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(Icons.location_on_rounded, color: accent, size: 18),
                                        ),
                                        const SizedBox(width: 10),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Container(
                                                  width: 6,
                                                  height: 6,
                                                  decoration: const BoxDecoration(
                                                    color: Color(0xFF10B981),
                                                    shape: BoxShape.circle,
                                                  ),
                                                ),
                                                const SizedBox(width: 5),
                                                Text(
                                                  'DELIVER TO (${user.addressTag.toUpperCase()})',
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 10.5,
                                                    fontWeight: FontWeight.w800,
                                                    letterSpacing: 1.1,
                                                    color: accent,
                                                  ),
                                                ),
                                                const SizedBox(width: 4),
                                                Icon(Icons.keyboard_arrow_down_rounded, color: subtextColor, size: 16),
                                              ],
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              user.addressLine1.split(',').first,
                                              style: GoogleFonts.poppins(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                color: textColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                } else {
                                  // EXISTING ACCOUNT: Hide address changing chip & show welcome greeting
                                  return Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: accent.withValues(alpha: 0.15),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(Icons.person_rounded, color: accent, size: 18),
                                      ),
                                      const SizedBox(width: 10),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'WELCOME BACK',
                                            style: GoogleFonts.poppins(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w800,
                                              letterSpacing: 1.1,
                                              color: accent,
                                            ),
                                          ),
                                          Text(
                                            user.name,
                                            style: GoogleFonts.poppins(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              color: textColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  );
                                }
                              },
                            ),
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: widget.onSearchTap,
                                  behavior: HitTestBehavior.opaque,
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: cardBg,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(color: hairline),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
                                          blurRadius: 10,
                                        ),
                                      ],
                                    ),
                                    child: Icon(Icons.search_rounded, color: accent, size: 20),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => const NotificationsScreen()),
                                    );
                                  },
                                  behavior: HitTestBehavior.opaque,
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: cardBg,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(color: hairline),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
                                          blurRadius: 10,
                                        ),
                                      ],
                                    ),
                                    child: Stack(
                                      children: [
                                        Icon(Icons.notifications_none_rounded, color: textColor, size: 20),
                                        ValueListenableBuilder<List<NotificationModel>>(
                                          valueListenable: AppNotificationFeedManager.instance,
                                          builder: (context, notifs, child) {
                                            final hasUnread = AppNotificationFeedManager.instance.unreadCount > 0;
                                            if (!hasUnread) return const SizedBox.shrink();
                                            return Positioned(
                                              top: 0,
                                              right: 0,
                                              child: Container(
                                                width: 8,
                                                height: 8,
                                                decoration: const BoxDecoration(
                                                  color: Colors.redAccent,
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Energetic Column 2: Big Bold Energetic Headline & Subtitle
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'EXPLORE & ORDER',
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.5,
                                    color: accent,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Gourmet Menu',
                                  style: GoogleFonts.baloo2(
                                    fontSize: 34,
                                    fontWeight: FontWeight.w800,
                                    color: textColor,
                                    height: 1.1,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: accent.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: accent.withValues(alpha: 0.3)),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.local_fire_department_rounded, color: accent, size: 16),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${_allFoodItems.length} Dishes',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: accent,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Energetic Column 3: High-Impact Vibrant Gradient Promo Carousel (Height 190)
                      _riseIn(
                        index: 0,
                        child: SizedBox(
                          height: 190,
                          child: PageView.builder(
                            controller: _bannerPageController,
                            onPageChanged: (idx) => setState(() => _currentBannerIndex = idx),
                            itemCount: _promoBanners.length,
                            itemBuilder: (context, index) {
                              final banner = _promoBanners[index];
                              final List<Color> gradientColors = banner['colors'] as List<Color>;
                              final Color badgeColor = banner['badgeColor'] as Color;

                              return Container(
                                margin: const EdgeInsets.symmetric(horizontal: 6),
                                padding: const EdgeInsets.fromLTRB(20, 18, 16, 18),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: gradientColors,
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(28),
                                  boxShadow: [
                                    BoxShadow(
                                      color: gradientColors.first.withValues(alpha: 0.4),
                                      blurRadius: 16,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: Colors.black.withValues(alpha: 0.3),
                                              borderRadius: BorderRadius.circular(12),
                                              border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                                            ),
                                            child: Text(
                                              banner['badge'] as String,
                                              style: GoogleFonts.poppins(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w900,
                                                color: badgeColor,
                                                letterSpacing: 1.0,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          Text(
                                            banner['title'] as String,
                                            maxLines: 2,
                                            style: GoogleFonts.poppins(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w800,
                                              color: Colors.white,
                                              height: 1.15,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            banner['subtitle'] as String,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.poppins(
                                              fontSize: 12,
                                              color: Colors.white.withValues(alpha: 0.85),
                                            ),
                                          ),
                                          const SizedBox(height: 14),
                                          GestureDetector(
                                            onTap: () {
                                              CouponManager.instance.applyCoupon(banner['code'] as String, 50.0);
                                              ToastManager.instance.show(
                                                context,
                                                'Coupon ${banner['code']} applied!',
                                              );
                                            },
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.circular(20),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black.withValues(alpha: 0.15),
                                                    blurRadius: 8,
                                                  ),
                                                ],
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                    banner['cta'] as String,
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.w800,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 4),
                                                  const Icon(Icons.arrow_forward_rounded, color: Colors.black, size: 14),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Container(
                                      width: 110,
                                      height: 110,
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.white.withValues(alpha: 0.4), width: 2),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withValues(alpha: 0.25),
                                            blurRadius: 12,
                                          ),
                                        ],
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(55),
                                        child: Image.asset(
                                          banner['image'] as String,
                                          fit: BoxFit.cover,
                                          errorBuilder: (c, e, s) => Container(
                                            color: Colors.white10,
                                            child: const Icon(Icons.fastfood, size: 55, color: Colors.white),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(_promoBanners.length, (idx) {
                          final isSelected = _currentBannerIndex == idx;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: isSelected ? 22 : 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: isSelected ? accent : subtextColor.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 24),

                      // Category Horizontal Filters Bar
                      _riseIn(
                        index: 1,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            children: List.generate(_categories.length, (idx) {
                              final cat = _categories[idx];
                              final isSelected = _selectedCategoryIndex == idx;

                              return GestureDetector(
                                onTap: () => setState(() => _selectedCategoryIndex = idx),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 250),
                                  margin: const EdgeInsets.only(right: 12),
                                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: isSelected ? accent : cardBg,
                                    borderRadius: BorderRadius.circular(22),
                                    border: Border.all(
                                      color: isSelected ? accent : hairline,
                                      width: isSelected ? 1.5 : 1,
                                    ),
                                    boxShadow: [
                                      if (isSelected)
                                        BoxShadow(
                                          color: accent.withValues(alpha: 0.25),
                                          blurRadius: 10,
                                        ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        cat['icon'] as IconData,
                                        size: 16,
                                        color: isSelected ? Colors.black : subtextColor,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        cat['name'] as String,
                                        style: GoogleFonts.poppins(
                                          fontSize: 13.5,
                                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                          color: isSelected ? Colors.black : subtextColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Popular Dishes',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                            Text(
                              '${displayedItems.length} Items',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: accent,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Food Items Grid View
                      if (displayedItems.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 40.0),
                          child: Center(
                            child: Column(
                              children: [
                                Icon(Icons.fastfood_outlined, size: 60, color: subtextColor.withValues(alpha: 0.3)),
                                const SizedBox(height: 12),
                                Text(
                                  'No items in this category yet',
                                  style: GoogleFonts.poppins(color: textColor, fontWeight: FontWeight.bold, fontSize: 15),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: displayedItems.length,
                            separatorBuilder: (context, index) => const SizedBox(height: 14),
                            itemBuilder: (context, index) {
                              final item = displayedItems[index];

                              return _riseIn(
                                index: index + 2,
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => FoodDetailScreen(foodItem: item),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color: cardBg,
                                      borderRadius: BorderRadius.circular(26),
                                      border: Border.all(color: hairline),
                                      boxShadow: [
                                        if (!isDark)
                                          BoxShadow(
                                            color: Colors.black.withValues(alpha: 0.04),
                                            blurRadius: 12,
                                            offset: const Offset(0, 4),
                                          ),
                                      ],
                                    ),
                                    child: Row(
                                      children: [
                                        // Left Image Thumbnail (110x110) with Rating Badge
                                        Stack(
                                          children: [
                                            Hero(
                                              tag: item.id,
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(20),
                                                child: Image.asset(
                                                  item.imagePath,
                                                  width: 110,
                                                  height: 110,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (c, e, s) => Container(
                                                    width: 110,
                                                    height: 110,
                                                    color: Colors.white10,
                                                    child: Icon(Icons.fastfood, color: accent, size: 50),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Positioned(
                                              top: 6,
                                              left: 6,
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: Colors.black.withValues(alpha: 0.75),
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    const Icon(Icons.star, color: Colors.amber, size: 12),
                                                    const SizedBox(width: 3),
                                                    Text(
                                                      '${item.rating}',
                                                      style: GoogleFonts.poppins(
                                                        fontSize: 10.5,
                                                        fontWeight: FontWeight.bold,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(width: 16),

                                        // Right Content Details
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      item.name,
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                      style: GoogleFonts.poppins(
                                                        fontSize: 16,
                                                        fontWeight: FontWeight.bold,
                                                        color: textColor,
                                                      ),
                                                    ),
                                                  ),
                                                  ValueListenableBuilder<List<FoodItem>>(
                                                    valueListenable: FavoritesManager.instance,
                                                    builder: (context, favs, child) {
                                                      final isFav = FavoritesManager.instance.isFavorite(item.id);

                                                      return GestureDetector(
                                                        onTap: () {
                                                          FavoritesManager.instance.toggleFavorite(item);
                                                        },
                                                        behavior: HitTestBehavior.opaque,
                                                        child: Container(
                                                          padding: const EdgeInsets.all(6),
                                                          decoration: BoxDecoration(
                                                            color: isDark
                                                                ? Colors.black.withValues(alpha: 0.5)
                                                                : Colors.grey.withValues(alpha: 0.1),
                                                            shape: BoxShape.circle,
                                                          ),
                                                          child: Icon(
                                                            isFav ? Icons.favorite : Icons.favorite_border,
                                                            color: isFav ? Colors.redAccent : subtextColor,
                                                            size: 16,
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                item.description,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: GoogleFonts.poppins(
                                                  fontSize: 12,
                                                  color: subtextColor,
                                                  height: 1.35,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Text(
                                                    item.priceString,
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 17,
                                                      fontWeight: FontWeight.bold,
                                                      color: ThemeManager.instance.priceColor(context),
                                                    ),
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
                                                              boxShadow: [
                                                                BoxShadow(
                                                                  color: accent.withValues(alpha: 0.3),
                                                                  blurRadius: 8,
                                                                ),
                                                              ],
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
                                                          boxShadow: [
                                                            BoxShadow(
                                                              color: accent.withValues(alpha: 0.35),
                                                              blurRadius: 8,
                                                            ),
                                                          ],
                                                        ),
                                                        child: Row(
                                                          mainAxisSize: MainAxisSize.min,
                                                          children: [
                                                            GestureDetector(
                                                              onTap: () => CartManager.instance.decrementQuantity(item),
                                                              behavior: HitTestBehavior.opaque,
                                                              child: const Padding(
                                                                padding: EdgeInsets.symmetric(horizontal: 9, vertical: 6),
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
                                                                padding: EdgeInsets.symmetric(horizontal: 9, vertical: 6),
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
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
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
}
