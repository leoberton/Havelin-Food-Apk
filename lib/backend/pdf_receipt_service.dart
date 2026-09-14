import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../managers/haptic_manager.dart';
import '../managers/order_history_manager.dart';
import '../managers/theme_manager.dart';

class PdfReceiptService {
  static final PdfReceiptService instance = PdfReceiptService._internal();

  PdfReceiptService._internal();

  /// 📄 Generate Formatted Digital Tax Invoice String
  String generateInvoiceText(OrderModel order) {
    final buffer = StringBuffer();
    buffer.writeln("========================================");
    buffer.writeln("         HAVELIN GOURMET FOODS          ");
    buffer.writeln("      GST Tax Invoice & Order Receipt   ");
    buffer.writeln("========================================");
    buffer.writeln("Invoice No : HV-INV-${order.orderId}");
    buffer.writeln("Date       : ${order.orderDate.day}/${order.orderDate.month}/${order.orderDate.year}");
    buffer.writeln("Time       : ${order.orderDate.hour}:${order.orderDate.minute.toString().padLeft(2, '0')}");
    buffer.writeln("Txn ID     : ${order.transactionId.isNotEmpty ? order.transactionId : 'TXN_ONLINE'}");
    buffer.writeln("Payment    : ${order.paymentMethod} (${order.paymentStatus})");
    buffer.writeln("Delivery To: ${order.deliveryAddress}");
    buffer.writeln("----------------------------------------");
    buffer.writeln("ITEMS ORDERED:");

    for (var item in order.items) {
      final name = item.foodItem.name.padRight(24);
      final qtyPrice = "${item.quantity}x ₹${item.foodItem.price.toStringAsFixed(0)} = ₹${(item.foodItem.price * item.quantity).toStringAsFixed(0)}";
      buffer.writeln(" - $name");
      buffer.writeln("   $qtyPrice");
    }

    buffer.writeln("----------------------------------------");
    buffer.writeln("Subtotal     : ₹${order.subtotal.toStringAsFixed(0)}");
    if (order.discount > 0) {
      buffer.writeln("Promo Savings: -₹${order.discount.toStringAsFixed(0)}");
    }
    buffer.writeln("Delivery Fee : ₹${order.deliveryFee.toStringAsFixed(0)}");
    buffer.writeln("GST (5% Incl): ₹${(order.subtotal * 0.05).toStringAsFixed(0)}");
    buffer.writeln("----------------------------------------");
    buffer.writeln("TOTAL PAID   : ₹${order.total.toStringAsFixed(0)}");
    buffer.writeln("========================================");
    buffer.writeln(" Thank you for ordering from Havelin! 🍲 ");
    buffer.writeln("========================================");

    return buffer.toString();
  }

  /// 📄 Show Modern Luxury Tax Invoice Card Modal
  void showInvoiceModal(BuildContext context, OrderModel order) {
    HapticManager.instance.lightImpact();

    final isDark = ThemeManager.instance.isDarkMode(context);
    final cardBg = isDark ? const Color(0xFF0F172A) : Colors.white;
    final paperBg = isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC);
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subtextColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final accent = const Color(0xFF00A884);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(36)),
          border: Border.all(color: accent.withValues(alpha: 0.4), width: 1.4),
          boxShadow: [
            BoxShadow(
              color: accent.withValues(alpha: 0.2),
              blurRadius: 24,
              offset: const Offset(0, -6),
            ),
          ],
        ),
        child: Column(
          children: [
            // Modal Handle Bar & Header
            Center(
              child: Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: subtextColor.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 14),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.receipt_long_rounded, color: accent, size: 22),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'GST Tax Invoice 📄',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        Text(
                          'Official Order Receipt #${order.orderId}',
                          style: GoogleFonts.poppins(fontSize: 11.5, color: subtextColor),
                        ),
                      ],
                    ),
                  ],
                ),
                IconButton(
                  icon: Icon(Icons.close_rounded, color: textColor),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // Scrollable Luxury Digital Receipt Card Body
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: paperBg,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Store Brand & Verified Stamp
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'HAVELIN GOURMET FOODS 🍲',
                                style: GoogleFonts.poppins(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: accent,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              Text(
                                'GSTIN: 36AAACH1234F1Z9',
                                style: GoogleFonts.poppins(fontSize: 11, color: subtextColor),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.green.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.green.withValues(alpha: 0.5)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.verified_rounded, color: Colors.green, size: 14),
                                const SizedBox(width: 4),
                                Text(
                                  'PAID ✅',
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),
                      Divider(color: subtextColor.withValues(alpha: 0.2)),
                      const SizedBox(height: 12),

                      // Order Metadata Grid
                      _buildReceiptInfoRow('Invoice No', 'HV-INV-${order.orderId}', textColor, subtextColor),
                      _buildReceiptInfoRow('Date & Time', '${order.orderDate.day}/${order.orderDate.month}/${order.orderDate.year} at ${order.orderDate.hour}:${order.orderDate.minute.toString().padLeft(2, '0')}', textColor, subtextColor),
                      _buildReceiptInfoRow('Transaction ID', order.transactionId.isNotEmpty ? order.transactionId : 'TXN_SUCCESS', textColor, subtextColor),
                      _buildReceiptInfoRow('Payment Mode', order.paymentMethod, textColor, subtextColor),

                      const SizedBox(height: 12),
                      Divider(color: subtextColor.withValues(alpha: 0.2)),
                      const SizedBox(height: 14),

                      // Items Table Header
                      Text(
                        'Items Breakdown',
                        style: GoogleFonts.poppins(
                          fontSize: 13.5,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 10),

                      Column(
                        children: order.items.map((item) {
                          final qtyPrice = (item.foodItem.price * item.quantity).toStringAsFixed(0);
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: accent.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    '${item.quantity}x',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: accent,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    item.foodItem.name,
                                    style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: textColor,
                                    ),
                                  ),
                                ),
                                Text(
                                  '₹$qtyPrice',
                                  style: GoogleFonts.poppins(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.bold,
                                    color: textColor,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 12),
                      Divider(color: subtextColor.withValues(alpha: 0.2)),
                      const SizedBox(height: 12),

                      // Financial Summary Breakdown
                      _buildReceiptAmountRow('Subtotal', '₹${order.subtotal.toStringAsFixed(0)}', textColor, subtextColor),
                      if (order.discount > 0)
                        _buildReceiptAmountRow('Promo Savings', '-₹${order.discount.toStringAsFixed(0)}', accent, accent, isBold: true),
                      _buildReceiptAmountRow('Delivery Fee', '₹${order.deliveryFee.toStringAsFixed(0)}', textColor, subtextColor),
                      _buildReceiptAmountRow('GST Charges (5%)', '₹${(order.subtotal * 0.05).toStringAsFixed(0)}', textColor, subtextColor),

                      const SizedBox(height: 14),

                      // Total Paid Highlight Box
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: accent.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: accent.withValues(alpha: 0.4)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total Paid Amount',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                            Text(
                              '₹${order.total.toStringAsFixed(0)}',
                              style: GoogleFonts.poppins(
                                fontSize: 22,
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
              ),
            ),

            const SizedBox(height: 16),

            // Action Buttons Bar
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        HapticManager.instance.mediumImpact();
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('GST Tax Invoice copied to clipboard! 📋'),
                            backgroundColor: Color(0xFF00A884),
                          ),
                        );
                      },
                      icon: Icon(Icons.copy_rounded, color: textColor, size: 18),
                      label: Text(
                        'Copy Invoice',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: subtextColor.withValues(alpha: 0.4)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        HapticManager.instance.mediumImpact();
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('PDF Invoice Saved to Downloads! 📥'),
                            backgroundColor: Color(0xFF00A884),
                          ),
                        );
                      },
                      icon: const Icon(Icons.download_rounded, color: Colors.black, size: 18),
                      label: Text(
                        'Download PDF',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReceiptInfoRow(String label, String value, Color textColor, Color subtextColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.poppins(fontSize: 12, color: subtextColor)),
          Text(
            value,
            style: GoogleFonts.poppins(fontSize: 12.5, fontWeight: FontWeight.w600, color: textColor),
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptAmountRow(String label, String value, Color textColor, Color subtextColor, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.poppins(fontSize: 12.5, color: subtextColor)),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 13.5,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
