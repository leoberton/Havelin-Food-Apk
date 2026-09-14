import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../backend/notification_manager.dart';
import '../../managers/cart_manager.dart';
import '../../managers/coupon_manager.dart';
import '../../managers/order_history_manager.dart';
import '../../managers/theme_manager.dart';
import '../../managers/user_manager.dart';
import '../modals/address_modal.dart';
import '../modals/payment_gateway_sheet.dart';
import 'order_success_screen.dart';

class CartScreen extends StatefulWidget {
  final VoidCallback onBackTap;

  const CartScreen({super.key, required this.onBackTap});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final TextEditingController _promoController = TextEditingController();

  @override
  void dispose() {
    _promoController.dispose();
    super.dispose();
  }

  void _showCheckoutConfirmation(
    double subtotal,
    double discount,
    double deliveryFee,
    double total,
    Color cardBg,
    Color textColor,
    Color subtextColor,
    Color accent,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Icon(Icons.check_circle_outline, color: accent, size: 26),
            const SizedBox(width: 10),
            Text(
              'Confirm Order',
              style: GoogleFonts.poppins(color: textColor, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you ready to place your order with Havelin Express Delivery?',
              style: GoogleFonts.poppins(color: subtextColor, fontSize: 13.5),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total Amount:', style: GoogleFonts.poppins(color: subtextColor)),
                Text(
                  '₹${total.toStringAsFixed(0)}',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.poppins(color: subtextColor)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);

              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => PaymentGatewaySheet(
                  amount: total,
                  onPaymentSuccess: (option, txnId) {
                    final newOrder = OrderHistoryManager.instance.createOrder(
                      items: List.from(CartManager.instance.value),
                      subtotal: subtotal,
                      discount: discount,
                      deliveryFee: deliveryFee,
                      paymentMethod: option.title,
                      paymentStatus: 'PAID',
                      transactionId: txnId,
                    );

                    NotificationManager.instance.sendOrderStatusNotification(
                      orderId: newOrder.orderId,
                      status: OrderStatus.placed,
                    );

                    CartManager.instance.clearCart();
                    CouponManager.instance.removeCoupon();

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OrderSuccessScreen(order: newOrder),
                      ),
                    );
                  },
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: accent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: Text(
              'Place Order',
              style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.bold),
            ),
          ),
        ],
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

        return Container(
          color: bg,
          child: SafeArea(
            child: Column(
              children: [
                // Header Row
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                  child: Row(
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
                        'Cart',
                        style: GoogleFonts.baloo2(
                          fontSize: 34,
                          fontWeight: FontWeight.w700,
                          color: textColor,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                Expanded(
                  child: ValueListenableBuilder<List<CartItem>>(
                    valueListenable: CartManager.instance,
                    builder: (context, items, child) {
                      if (items.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.shopping_cart_outlined,
                                size: 80,
                                color: subtextColor.withValues(alpha: 0.3),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Your Cart is Empty',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Explore the menu and add your favorite dishes!',
                                style: GoogleFonts.poppins(fontSize: 13, color: subtextColor),
                              ),
                            ],
                          ),
                        );
                      }

                      final subtotal = CartManager.instance.subtotal;
                      const deliveryFee = 30.0;

                      return ValueListenableBuilder<Coupon?>(
                        valueListenable: CouponManager.instance,
                        builder: (context, appliedCoupon, child) {
                          final discount = CouponManager.instance.calculateDiscount(subtotal);
                          final total = (subtotal - discount + deliveryFee).clamp(0.0, 9999.0);

                          return SingleChildScrollView(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Cart Items List
                                ListView.separated(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: items.length,
                                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                                  itemBuilder: (context, index) {
                                    final cartItem = items[index];
                                    final itemTotal = cartItem.foodItem.price * cartItem.quantity;

                                    return Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: cardBg,
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(color: hairline),
                                        boxShadow: [
                                          if (!ThemeManager.instance.isDarkMode(context))
                                            BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6),
                                        ],
                                      ),
                                      child: Row(
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(14),
                                            child: Image.asset(
                                              cartItem.foodItem.imagePath,
                                              width: 65,
                                              height: 65,
                                              fit: BoxFit.cover,
                                              errorBuilder: (c, e, s) => Container(
                                                width: 65,
                                                height: 65,
                                                color: Colors.white10,
                                                child: Icon(Icons.fastfood, color: accent),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  cartItem.foodItem.name,
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.bold,
                                                    color: textColor,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  '₹${itemTotal.toStringAsFixed(2)}',
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                    color: ThemeManager.instance.priceColor(context),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              GestureDetector(
                                                onTap: () {
                                                  CartManager.instance.updateQuantity(
                                                    index,
                                                    cartItem.quantity - 1,
                                                  );
                                                },
                                                child: Container(
                                                  padding: const EdgeInsets.all(6),
                                                  decoration: BoxDecoration(
                                                    color: hairline,
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: Icon(Icons.remove, color: textColor, size: 16),
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                                child: Text(
                                                  '${cartItem.quantity}',
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.bold,
                                                    color: textColor,
                                                  ),
                                                ),
                                              ),
                                              GestureDetector(
                                                onTap: () {
                                                  CartManager.instance.updateQuantity(
                                                    index,
                                                    cartItem.quantity + 1,
                                                  );
                                                },
                                                child: Container(
                                                  padding: const EdgeInsets.all(6),
                                                  decoration: BoxDecoration(
                                                    color: accent,
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: const Icon(Icons.add, color: Colors.black, size: 16),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),

                                const SizedBox(height: 24),

                                // Promo Code & Coupon Section Title
                                Text(
                                  'Promo Code & Coupons',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: textColor,
                                  ),
                                ),
                                const SizedBox(height: 10),

                                // Quick Coupon Chips Selector
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: CouponManager.instance.availableCoupons.map((coupon) {
                                      final isApplied = appliedCoupon?.code == coupon.code;
                                      return GestureDetector(
                                        onTap: () {
                                          if (isApplied) {
                                            CouponManager.instance.removeCoupon();
                                          } else {
                                            final ok = CouponManager.instance.applyCoupon(coupon.code, subtotal);
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text(ok ? 'Applied ${coupon.code}' : 'Coupon not valid for this subtotal'),
                                                backgroundColor: ok ? accent : Colors.redAccent,
                                              ),
                                            );
                                          }
                                        },
                                        child: Container(
                                          margin: const EdgeInsets.only(right: 10),
                                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                          decoration: BoxDecoration(
                                            color: isApplied ? accent : cardBg,
                                            borderRadius: BorderRadius.circular(16),
                                            border: Border.all(
                                              color: isApplied ? accent : hairline,
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(
                                                isApplied ? Icons.check_circle : Icons.local_offer_outlined,
                                                size: 15,
                                                color: isApplied ? Colors.black : accent,
                                              ),
                                              const SizedBox(width: 6),
                                              Text(
                                                coupon.code,
                                                style: GoogleFonts.poppins(
                                                  fontSize: 12.5,
                                                  fontWeight: FontWeight.bold,
                                                  color: isApplied ? Colors.black : textColor,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),

                                 const SizedBox(height: 24),

                                 // Delivery Address Card
                                 ValueListenableBuilder<UserData>(
                                   valueListenable: UserManager.instance,
                                   builder: (context, user, child) {
                                     return Container(
                                       padding: const EdgeInsets.all(16),
                                       decoration: BoxDecoration(
                                         color: cardBg,
                                         borderRadius: BorderRadius.circular(22),
                                         border: Border.all(color: accent.withValues(alpha: 0.3)),
                                       ),
                                       child: Column(
                                         crossAxisAlignment: CrossAxisAlignment.start,
                                         children: [
                                           Row(
                                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                             children: [
                                               Row(
                                                 children: [
                                                   Icon(Icons.location_on_rounded, color: accent, size: 18),
                                                   const SizedBox(width: 6),
                                                   Text(
                                                     'Delivery Location (${user.addressTag})',
                                                     style: GoogleFonts.poppins(
                                                       fontSize: 14,
                                                       fontWeight: FontWeight.bold,
                                                       color: textColor,
                                                     ),
                                                   ),
                                                 ],
                                               ),
                                               GestureDetector(
                                                 onTap: () => showAddressModalSheet(context),
                                                 child: Container(
                                                   padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                                   decoration: BoxDecoration(
                                                     color: accent.withValues(alpha: 0.15),
                                                     borderRadius: BorderRadius.circular(12),
                                                   ),
                                                   child: Text(
                                                     'Change',
                                                     style: GoogleFonts.poppins(
                                                       fontSize: 11.5,
                                                       fontWeight: FontWeight.bold,
                                                       color: accent,
                                                     ),
                                                   ),
                                                 ),
                                               ),
                                             ],
                                           ),
                                           const SizedBox(height: 6),
                                           Text(
                                             '${user.addressLine1}, ${user.addressLine2}',
                                             style: GoogleFonts.poppins(fontSize: 12.5, color: subtextColor),
                                           ),
                                         ],
                                       ),
                                     );
                                   },
                                 ),

                                 const SizedBox(height: 24),

                                // Order Summary Card
                                Container(
                                  padding: const EdgeInsets.all(18),
                                  decoration: BoxDecoration(
                                    color: cardBg,
                                    borderRadius: BorderRadius.circular(24),
                                    border: Border.all(color: hairline),
                                  ),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text('Subtotal', style: GoogleFonts.poppins(color: subtextColor, fontSize: 13.5)),
                                          Text('₹${subtotal.toStringAsFixed(0)}', style: GoogleFonts.poppins(color: textColor, fontSize: 14, fontWeight: FontWeight.w600)),
                                        ],
                                      ),
                                      if (discount > 0) ...[
                                        const SizedBox(height: 8),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text('Promo Discount (${appliedCoupon?.code})', style: GoogleFonts.poppins(color: accent, fontSize: 13.5, fontWeight: FontWeight.w600)),
                                            Text('-₹${discount.toStringAsFixed(0)}', style: GoogleFonts.poppins(color: accent, fontSize: 14, fontWeight: FontWeight.bold)),
                                          ],
                                        ),
                                      ],
                                      const SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text('Delivery Fee', style: GoogleFonts.poppins(color: subtextColor, fontSize: 13.5)),
                                          Text('₹${deliveryFee.toStringAsFixed(0)}', style: GoogleFonts.poppins(color: textColor, fontSize: 14, fontWeight: FontWeight.w600)),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Divider(color: hairline),
                                      const SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text('Total', style: GoogleFonts.poppins(color: textColor, fontSize: 16, fontWeight: FontWeight.bold)),
                                          Text(
                                            '₹${total.toStringAsFixed(0)}',
                                            style: GoogleFonts.poppins(
                                              color: ThemeManager.instance.priceColor(context),
                                              fontSize: 22,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 24),

                                // Checkout CTA Button
                                SizedBox(
                                  width: double.infinity,
                                  height: 54,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      _showCheckoutConfirmation(
                                        subtotal,
                                        discount,
                                        deliveryFee,
                                        total,
                                        cardBg,
                                        textColor,
                                        subtextColor,
                                        accent,
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: accent,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(27)),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Proceed to Checkout',
                                          style: GoogleFonts.poppins(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        const Icon(Icons.arrow_forward, color: Colors.black, size: 20),
                                      ],
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 30),
                              ],
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
