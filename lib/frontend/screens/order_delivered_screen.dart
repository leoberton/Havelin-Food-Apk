import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../managers/cart_manager.dart';
import '../../managers/haptic_manager.dart';
import '../../managers/order_history_manager.dart';
import '../../managers/theme_manager.dart';
import '../../managers/toast_manager.dart';
import '../root_screen.dart';

class OrderDeliveredScreen extends StatefulWidget {
  final OrderModel order;

  const OrderDeliveredScreen({super.key, required this.order});

  @override
  State<OrderDeliveredScreen> createState() => _OrderDeliveredScreenState();
}

class _OrderDeliveredScreenState extends State<OrderDeliveredScreen>
    with SingleTickerProviderStateMixin {
  int _rating = 5;
  int _selectedTipAmount = 3;
  final Set<String> _selectedTags = {'Hot & Fresh', 'Super Fast'};
  final TextEditingController _reviewController = TextEditingController();
  late final AnimationController _pulseController;

  final List<String> _quickTags = const [
    'Hot & Fresh',
    'Super Fast',
    'Polite Courier',
    'Great Packaging',
    'Tasty Spices',
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _reviewController.dispose();
    _pulseController.dispose();
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
          body: Stack(
            children: [
              Positioned(
                top: -80,
                right: -60,
                child: AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    final opacity = lerpDouble(0.1, 0.25, _pulseController.value)!;
                    return _glowBlob(accent.withValues(alpha: opacity), 280);
                  },
                ),
              ),
              SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Top Header Navigation Bar
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(builder: (context) => const RootScreen()),
                                (route) => false,
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: cardBg,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: hairline),
                              ),
                              child: Icon(Icons.close_rounded, color: textColor, size: 20),
                            ),
                          ),
                          Text(
                            'ORDER DELIVERED',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.2,
                              color: accent,
                            ),
                          ),
                          const SizedBox(width: 40),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Delivery Success Icon Banner
                      AnimatedBuilder(
                        animation: _pulseController,
                        builder: (context, child) {
                          return Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: accent.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: accent,
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: accent.withValues(alpha: 0.3 * _pulseController.value),
                                  blurRadius: 24,
                                  spreadRadius: 4,
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.task_alt_rounded,
                              size: 55,
                              color: accent,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 20),

                      // Success Title & Subtitle
                      Text(
                        'Enjoy Your Meal!',
                        style: GoogleFonts.baloo2(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: textColor,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Order #${widget.order.orderId} was successfully delivered by Alex Johnson',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 13.5,
                          color: subtextColor,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Driver Profile Card
                      Container(
                        padding: const EdgeInsets.all(16),
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
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 26,
                                  backgroundColor: accent.withValues(alpha: 0.2),
                                  child: Icon(Icons.person_rounded, color: accent, size: 30),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Alex Johnson',
                                        style: GoogleFonts.poppins(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: textColor,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Senior Delivery Partner • Honda PCX',
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          color: subtextColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: Colors.amber.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.star, color: Colors.amber, size: 14),
                                      const SizedBox(width: 4),
                                      Text(
                                        '4.9',
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.amber,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Divider(color: hairline),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Add Courier Tip',
                                  style: GoogleFonts.poppins(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w600,
                                    color: textColor,
                                  ),
                                ),
                                Text(
                                  '100% goes to driver',
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    color: subtextColor,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [20, 30, 50, 100].map((amount) {
                                final isSelected = _selectedTipAmount == amount;
                                return Expanded(
                                  child: GestureDetector(
                                    onTap: () => setState(() => _selectedTipAmount = amount),
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 200),
                                      margin: const EdgeInsets.symmetric(horizontal: 4),
                                      padding: const EdgeInsets.symmetric(vertical: 8),
                                      decoration: BoxDecoration(
                                        color: isSelected ? accent : bg,
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(color: isSelected ? accent : hairline),
                                      ),
                                      child: Text(
                                        '₹$amount',
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.poppins(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: isSelected ? Colors.black : textColor,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Interactive 5-Star Rating Card
                      Container(
                        padding: const EdgeInsets.all(20),
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
                          children: [
                            Text(
                              'How was your food experience?',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Interactive Star Row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(5, (idx) {
                                final starNum = idx + 1;
                                final isFilled = starNum <= _rating;
                                return GestureDetector(
                                  onTap: () => setState(() => _rating = starNum),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 6.0),
                                    child: Icon(
                                      isFilled ? Icons.star_rounded : Icons.star_outline_rounded,
                                      color: isFilled ? Colors.amber : subtextColor.withValues(alpha: 0.4),
                                      size: 38,
                                    ),
                                  ),
                                );
                              }),
                            ),

                            const SizedBox(height: 18),
                            Divider(color: hairline),
                            const SizedBox(height: 14),

                            // Quick Feedback Tags
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'What did you love?',
                                style: GoogleFonts.poppins(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w600,
                                  color: textColor,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: _quickTags.map((tag) {
                                final isSelected = _selectedTags.contains(tag);
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      if (isSelected) {
                                        _selectedTags.remove(tag);
                                      } else {
                                        _selectedTags.add(tag);
                                      }
                                    });
                                  },
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                                    decoration: BoxDecoration(
                                      color: isSelected ? accent : bg,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(color: isSelected ? accent : hairline),
                                    ),
                                    child: Text(
                                      tag,
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                        color: isSelected ? Colors.black : subtextColor,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),

                            const SizedBox(height: 16),

                            // Optional Review Input Textfield
                            TextField(
                              controller: _reviewController,
                              style: GoogleFonts.poppins(color: textColor, fontSize: 13.5),
                              maxLines: 2,
                              decoration: InputDecoration(
                                hintText: 'Write a note for the restaurant & chef...',
                                hintStyle: GoogleFonts.poppins(color: subtextColor, fontSize: 12.5),
                                filled: true,
                                fillColor: bg,
                                contentPadding: const EdgeInsets.all(14),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(color: hairline),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(color: hairline),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(color: accent),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Delivered Items Brief Summary Card
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: hairline),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Order Summary',
                                  style: GoogleFonts.poppins(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: textColor,
                                  ),
                                ),
                                Text(
                                  '₹${widget.order.total.toStringAsFixed(0)}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: ThemeManager.instance.priceColor(context),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Column(
                              children: widget.order.items.map((cartItem) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: Row(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Image.asset(
                                          cartItem.foodItem.imagePath,
                                          width: 36,
                                          height: 36,
                                          fit: BoxFit.cover,
                                          errorBuilder: (c, e, s) => Container(
                                            width: 36,
                                            height: 36,
                                            color: accent.withValues(alpha: 0.2),
                                            child: Icon(Icons.fastfood, size: 18, color: accent),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          '${cartItem.quantity}x ${cartItem.foodItem.name}',
                                          style: GoogleFonts.poppins(
                                            fontSize: 13,
                                            color: textColor,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        '₹${cartItem.totalPrice.toStringAsFixed(0)}',
                                        style: GoogleFonts.poppins(
                                          fontSize: 13,
                                          color: subtextColor,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 28),

                      // Action Buttons: Primary Submit Rating & Re-order Secondary
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: () {
                            HapticManager.instance.heavyImpact();
                            OrderHistoryManager.instance.updateOrderStatus(widget.order.orderId, OrderStatus.delivered);
                            ToastManager.instance.show(
                              context,
                              'Thank you for your rating & feedback!',
                            );
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (context) => const RootScreen()),
                              (route) => false,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accent,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(27),
                            ),
                          ),
                          child: Text(
                            'Submit Review & Go Home',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: OutlinedButton(
                          onPressed: () {
                            for (var cartItem in widget.order.items) {
                              CartManager.instance.addItem(
                                cartItem.foodItem,
                                quantity: cartItem.quantity,
                                selectedAddOns: cartItem.selectedAddOns,
                              );
                            }
                            ToastManager.instance.show(
                              context,
                              'Re-ordered ${widget.order.items.length} items to cart!',
                            );
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (context) => const RootScreen()),
                              (route) => false,
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: hairline),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child: Text(
                            'Re-order This Feast',
                            style: GoogleFonts.poppins(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w600,
                              color: textColor,
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
}
