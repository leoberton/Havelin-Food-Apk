import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../backend/analytics_backend_service.dart';
import '../../backend/firebase_manager.dart';
import '../../backend/notification_manager.dart';
import '../../managers/theme_manager.dart';

class AdminKitchenDashboard extends StatefulWidget {
  const AdminKitchenDashboard({super.key});

  @override
  State<AdminKitchenDashboard> createState() => _AdminKitchenDashboardState();
}

class _AdminKitchenDashboardState extends State<AdminKitchenDashboard> {
  String _selectedFilter = 'All';

  final List<String> _filterTabs = [
    'All',
    'Pending',
    'Preparing',
    'Out for Delivery',
    'Delivered',
  ];

  @override
  Widget build(BuildContext context) {
    final bg = ThemeManager.instance.bgColor(context);
    final cardBg = ThemeManager.instance.cardColor(context);
    final textColor = ThemeManager.instance.textColor(context);
    final subtextColor = ThemeManager.instance.subtextColor(context);
    final hairline = ThemeManager.instance.hairlineColor(context);
    final accent = ThemeManager.instance.accentColor(context);
    final isDark = ThemeManager.instance.isDarkMode(context);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: cardBg,
        elevation: 0,
        centerTitle: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Kitchen Admin Dashboard 👨‍🍳',
              style: GoogleFonts.poppins(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            Text(
              'Real-Time Order Control & Kitchen Manager',
              style: GoogleFonts.poppins(fontSize: 11, color: subtextColor),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Simulate Test Live Order',
            icon: const Icon(Icons.add_shopping_cart_rounded, color: Color(0xFF00A884)),
            onPressed: () => _simulateTestLiveOrder(context),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // 📊 Real-Time Revenue & Sales Analytics Header Card
          StreamBuilder<AnalyticsModel>(
            stream: AnalyticsBackendService.instance.streamRealtimeAnalytics(),
            builder: (context, analyticsSnap) {
              final analytics = analyticsSnap.data ?? AnalyticsModel(
                totalRevenue: 0.0,
                totalOrdersCount: 0,
                pendingOrdersCount: 0,
                completedOrdersCount: 0,
                cancelledOrdersCount: 0,
                averageOrderValue: 0.0,
                topSellingDishes: {},
                hourlyOrderDistribution: {},
                lastUpdated: DateTime.now(),
              );

              return Container(
                margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: accent.withValues(alpha: 0.4)),
                  boxShadow: [
                    BoxShadow(
                      color: accent.withValues(alpha: 0.12),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Live Kitchen Revenue 📊',
                              style: GoogleFonts.poppins(fontSize: 12, color: subtextColor),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '₹${analytics.totalRevenue.toStringAsFixed(0)}',
                              style: GoogleFonts.poppins(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: accent,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: accent.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'Avg Order Size',
                                style: GoogleFonts.poppins(fontSize: 10, color: subtextColor),
                              ),
                              Text(
                                '₹${analytics.averageOrderValue.toStringAsFixed(0)}',
                                style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold, color: textColor),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildMetricTile(
                            'Active Orders',
                            '${analytics.pendingOrdersCount}',
                            Colors.amber,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildMetricTile(
                            'Delivered',
                            '${analytics.completedOrdersCount}',
                            Colors.green,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildMetricTile(
                            'Total Orders',
                            '${analytics.totalOrdersCount}',
                            accent,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),

          // Filter Tabs Bar
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            color: cardBg,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: _filterTabs.map((tab) {
                  final isSelected = _selectedFilter == tab;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(
                        tab,
                        style: GoogleFonts.poppins(
                          fontSize: 12.5,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected ? Colors.black : textColor,
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: accent,
                      backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                      onSelected: (val) {
                        if (val) setState(() => _selectedFilter = tab);
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          Divider(height: 1, color: hairline),

          // Real-Time Orders Stream Builder
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('orders')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFF00A884)),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return _buildEmptyState(textColor, subtextColor, accent);
                }

                final allDocs = snapshot.data!.docs;
                final filteredDocs = allDocs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final status = (data['status'] ?? 'pending').toString().toLowerCase();
                  if (_selectedFilter == 'All') return true;
                  if (_selectedFilter == 'Pending') return status == 'pending';
                  if (_selectedFilter == 'Preparing') return status == 'preparing';
                  if (_selectedFilter == 'Out for Delivery') return status == 'out_for_delivery';
                  if (_selectedFilter == 'Delivered') return status == 'delivered';
                  return true;
                }).toList();

                if (filteredDocs.isEmpty) {
                  return Center(
                    child: Text(
                      'No $_selectedFilter orders right now.',
                      style: GoogleFonts.poppins(color: subtextColor, fontSize: 14),
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredDocs.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    final doc = filteredDocs[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final orderId = doc.id;
                    final status = (data['status'] ?? 'pending').toString();
                    final total = (data['total'] as num?)?.toDouble() ?? 0.0;
                    final paymentMethod = data['paymentMethod'] ?? 'UPI';
                    final items = (data['items'] as List<dynamic>?) ?? [];
                    final address = data['deliveryAddress'] ?? 'Standard Delivery';

                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: _getStatusBorderColor(status)),
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
                          // Header: Order ID & Status Badge
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '#$orderId',
                                style: GoogleFonts.poppins(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                              ),
                              _buildStatusBadge(status),
                            ],
                          ),

                          const SizedBox(height: 8),

                          // Customer Address & Payment Tag
                          Row(
                            children: [
                              Icon(Icons.location_on_rounded, size: 16, color: accent),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  address,
                                  style: GoogleFonts.poppins(fontSize: 12.5, color: subtextColor),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  paymentMethod,
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blueAccent,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),
                          Divider(height: 1, color: hairline),
                          const SizedBox(height: 10),

                          // Items List
                          Column(
                            children: items.map((itemMap) {
                              final name = itemMap['name'] ?? 'Dish';
                              final qty = itemMap['quantity'] ?? 1;
                              final price = (itemMap['price'] as num?)?.toDouble() ?? 0.0;
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '${qty}x $name',
                                      style: GoogleFonts.poppins(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: textColor,
                                      ),
                                    ),
                                    Text(
                                      '₹${(price * qty).toStringAsFixed(0)}',
                                      style: GoogleFonts.poppins(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: ThemeManager.instance.priceColor(context),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),

                          const SizedBox(height: 10),
                          Divider(height: 1, color: hairline),
                          const SizedBox(height: 10),

                          // Total Amount & Action Buttons
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Total Amount', style: GoogleFonts.poppins(fontSize: 11, color: subtextColor)),
                                  Text(
                                    '₹${total.toStringAsFixed(0)}',
                                    style: GoogleFonts.poppins(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: accent,
                                    ),
                                  ),
                                ],
                              ),

                              // Interactive Kitchen Control Buttons
                              _buildKitchenActionButtons(context, orderId, status),
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
    );
  }

  Widget _buildEmptyState(Color textColor, Color subtextColor, Color accent) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.soup_kitchen_rounded, size: 80, color: subtextColor.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          Text(
            'Kitchen Queue is Clear',
            style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
          ),
          const SizedBox(height: 6),
          Text(
            'New customer orders will stream live in real-time!',
            style: GoogleFonts.poppins(fontSize: 13, color: subtextColor),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => _simulateTestLiveOrder(context),
            icon: const Icon(Icons.add_task_rounded, color: Colors.black),
            label: Text(
              'Simulate Test Live Order',
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.black),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: accent,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKitchenActionButtons(BuildContext context, String orderId, String currentStatus) {
    switch (currentStatus.toLowerCase()) {
      case 'pending':
        return ElevatedButton(
          onPressed: () => _updateStatus(orderId, 'preparing', 'Kitchen accepted order! 👨‍🍳 Preparing food now.'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00A884),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: Text('Accept Order 👨‍🍳', style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12)),
        );
      case 'preparing':
        return ElevatedButton(
          onPressed: () => _updateStatus(orderId, 'out_for_delivery', 'Order dispatched! 🛵 Rider Rahul on the way.'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.amber,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: Text('Dispatch Rider 🛵', style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12)),
        );
      case 'out_for_delivery':
        return ElevatedButton(
          onPressed: () => _updateStatus(orderId, 'delivered', 'Order Delivered! 🎉 Enjoy your hot meal.'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueAccent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: Text('Mark Delivered ✅', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
        );
      case 'delivered':
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            'Completed ✅',
            style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.green),
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildStatusBadge(String status) {
    Color bg;
    Color text;
    String label;

    switch (status.toLowerCase()) {
      case 'pending':
        bg = Colors.amber.withValues(alpha: 0.2);
        text = Colors.amber;
        label = 'Pending 🟡';
        break;
      case 'preparing':
        bg = const Color(0xFF00A884).withValues(alpha: 0.2);
        text = const Color(0xFF00A884);
        label = 'Preparing 👨‍🍳';
        break;
      case 'out_for_delivery':
        bg = Colors.blue.withValues(alpha: 0.2);
        text = Colors.blueAccent;
        label = 'On The Way 🛵';
        break;
      case 'delivered':
        bg = Colors.green.withValues(alpha: 0.2);
        text = Colors.green;
        label = 'Delivered ✅';
        break;
      default:
        bg = Colors.grey.withValues(alpha: 0.2);
        text = Colors.grey;
        label = status.toUpperCase();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
      child: Text(
        label,
        style: GoogleFonts.poppins(fontSize: 11.5, fontWeight: FontWeight.bold, color: text),
      ),
    );
  }

  Color _getStatusBorderColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.amber.withValues(alpha: 0.4);
      case 'preparing':
        return const Color(0xFF00A884).withValues(alpha: 0.5);
      case 'out_for_delivery':
        return Colors.blueAccent.withValues(alpha: 0.5);
      case 'delivered':
        return Colors.green.withValues(alpha: 0.4);
      default:
        return Colors.white12;
    }
  }

  Future<void> _updateStatus(String orderId, String newStatus, String notifMessage) async {
    await FirebaseManager.instance.updateOrderStatusInCloud(orderId, newStatus);
    await FirebaseManager.instance.pushNotificationToCloudFeed(
      title: 'Order Status Update 🔔',
      body: notifMessage,
      type: 'order_status',
      orderId: orderId,
    );
    await NotificationManager.instance.showNotification(
      title: 'Order Update #$orderId',
      body: notifMessage,
      payload: orderId,
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Order #$orderId updated to $newStatus! ⚡'),
          backgroundColor: const Color(0xFF00A884),
        ),
      );
    }
  }

  Future<void> _simulateTestLiveOrder(BuildContext context) async {
    final testOrderId = 'HV-${1000 + (DateTime.now().millisecondsSinceEpoch % 8999)}';
    await FirebaseFirestore.instance.collection('orders').doc(testOrderId).set({
      'orderId': testOrderId,
      'createdAt': FieldValue.serverTimestamp(),
      'status': 'pending',
      'total': 449.0,
      'subtotal': 419.0,
      'discount': 0.0,
      'deliveryFee': 30.0,
      'deliveryAddress': 'Flat 402, Green Valley Apartments, Jubilee Hills',
      'paymentMethod': 'Direct UPI (GPay)',
      'items': [
        {'name': 'Hyderabadi Chicken Biryani', 'quantity': 2, 'price': 180.0},
        {'name': 'Chilled Coca-Cola 330ml', 'quantity': 2, 'price': 45.0},
      ],
    });

    await NotificationManager.instance.showNotification(
      title: 'New Live Order Received! 🔔',
      body: 'Order #$testOrderId for ₹449 placed via UPI.',
      payload: testOrderId,
    );

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Simulated Live Order #$testOrderId pushed to Cloud! 🚀'),
          backgroundColor: const Color(0xFF00A884),
        ),
      );
    }
  }

  Widget _buildMetricTile(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(fontSize: 10, color: color, fontWeight: FontWeight.w600),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }
}
