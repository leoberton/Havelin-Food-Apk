import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../backend/pdf_receipt_service.dart';
import '../../managers/order_history_manager.dart';
import '../../managers/theme_manager.dart';
import 'order_delivered_screen.dart';
import 'order_tracking_screen.dart';

class OrderHistoryScreen extends StatelessWidget {
  final VoidCallback onBackTap;

  const OrderHistoryScreen({super.key, required this.onBackTap});

  void _showDigitalReceipt(
    BuildContext context,
    OrderModel order,
    Color cardBg,
    Color textColor,
    Color subtextColor,
    Color hairline,
    Color accent,
  ) {
    PdfReceiptService.instance.showInvoiceModal(context, order);
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

        return Scaffold(
          backgroundColor: bg,
          body: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: onBackTap,
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: hairline,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.arrow_back_ios_new, color: textColor, size: 18),
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
                        'Order History',
                        style: GoogleFonts.baloo2(
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          color: textColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: ValueListenableBuilder<List<OrderModel>>(
                    valueListenable: OrderHistoryManager.instance,
                    builder: (context, orders, child) {
                      if (orders.isEmpty) {
                        return Center(
                          child: Text(
                            'No order history yet!',
                            style: GoogleFonts.poppins(fontSize: 16, color: subtextColor),
                          ),
                        );
                      }

                      return ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        itemCount: orders.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 14),
                        itemBuilder: (context, index) {
                          final order = orders[index];
                          final isDelivered = order.status == OrderStatus.delivered;

                          return Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: cardBg,
                              borderRadius: BorderRadius.circular(22),
                              border: Border.all(color: hairline),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Order #${order.orderId}',
                                      style: GoogleFonts.poppins(
                                        fontSize: 15.5,
                                        fontWeight: FontWeight.bold,
                                        color: textColor,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: (isDelivered ? accent : Colors.amber).withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        isDelivered ? 'Delivered' : 'Active',
                                        style: GoogleFonts.poppins(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: isDelivered ? accent : Colors.amber,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  '${order.items.length} Items • ₹${order.total.toStringAsFixed(0)}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    color: ThemeManager.instance.priceColor(context),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 14),
                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton.icon(
                                        onPressed: () {
                                          _showDigitalReceipt(
                                            context,
                                            order,
                                            cardBg,
                                            textColor,
                                            subtextColor,
                                            hairline,
                                            accent,
                                          );
                                        },
                                        icon: const Icon(Icons.receipt_long, size: 16),
                                        label: const Text('Receipt'),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: textColor,
                                          side: BorderSide(color: hairline),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    if (!isDelivered)
                                      Expanded(
                                        child: ElevatedButton.icon(
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => OrderTrackingScreen(order: order),
                                              ),
                                            );
                                          },
                                          icon: const Icon(Icons.location_searching, size: 16, color: Colors.black),
                                          label: Text(
                                            'Track Live',
                                            style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.bold),
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: accent,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                          ),
                                        ),
                                      )
                                    else
                                      Expanded(
                                        child: ElevatedButton.icon(
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => OrderDeliveredScreen(order: order),
                                              ),
                                            );
                                          },
                                          icon: const Icon(Icons.task_alt_rounded, size: 16, color: Colors.black),
                                          label: Text(
                                            'View Summary',
                                            style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.bold),
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: accent,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
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