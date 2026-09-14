import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../managers/theme_manager.dart';
import '../../managers/toast_manager.dart';

enum NotificationType { order, promo, system }

class NotificationModel {
  final String id;
  final String title;
  final String message;
  final String time;
  final IconData icon;
  final Color iconColor;
  final NotificationType type;
  bool isRead;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.time,
    required this.icon,
    required this.iconColor,
    required this.type,
    this.isRead = false,
  });
}

class AppNotificationFeedManager extends ValueNotifier<List<NotificationModel>> {
  static final AppNotificationFeedManager instance = AppNotificationFeedManager._internal();

  AppNotificationFeedManager._internal()
      : super([
          NotificationModel(
            id: 'notif_1',
            title: 'Order Out for Delivery',
            message: 'Your rider Rahul is 15 mins away with your meal. Get ready!',
            time: '2 mins ago',
            icon: Icons.delivery_dining_rounded,
            iconColor: const Color(0xFF3DEBB0),
            type: NotificationType.order,
            isRead: false,
          ),
          NotificationModel(
            id: 'notif_2',
            title: '30% OFF FIRST ORDER',
            message: 'Use promo code HAVELIN30 at checkout before midnight to get 30% off.',
            time: '1 hour ago',
            icon: Icons.local_offer_rounded,
            iconColor: Colors.amber,
            type: NotificationType.promo,
            isRead: false,
          ),
          NotificationModel(
            id: 'notif_3',
            title: 'Free Delivery Reward Unlocked',
            message: 'Congratulations! You unlocked free delivery for your next 3 orders.',
            time: '5 hours ago',
            icon: Icons.card_giftcard_rounded,
            iconColor: const Color(0xFF3DEBB0),
            type: NotificationType.promo,
            isRead: true,
          ),
          NotificationModel(
            id: 'notif_4',
            title: 'Welcome to Havelin Food',
            message: 'Explore our newly added chef specials and enjoy fast gourmet delivery.',
            time: '1 day ago',
            icon: Icons.stars_rounded,
            iconColor: Colors.purpleAccent,
            type: NotificationType.system,
            isRead: true,
          ),
        ]);

  int get unreadCount => value.where((n) => !n.isRead).length;

  void markAllAsRead() {
    for (var n in value) {
      n.isRead = true;
    }
    notifyListeners();
  }

  void markAsRead(String id) {
    final index = value.indexWhere((n) => n.id == id);
    if (index >= 0) {
      value[index].isRead = true;
      notifyListeners();
    }
  }

  void deleteNotification(String id) {
    final list = List<NotificationModel>.from(value);
    list.removeWhere((n) => n.id == id);
    value = list;
  }

  void clearAll() {
    value = [];
  }
}

class NotificationsScreen extends StatefulWidget {
  final VoidCallback? onBackTap;

  const NotificationsScreen({super.key, this.onBackTap});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  String _selectedCategory = 'All';

  final List<String> _categories = const ['All', 'Orders', 'Offers', 'System'];

  List<NotificationModel> _filterNotifications(List<NotificationModel> list) {
    if (_selectedCategory == 'Orders') {
      return list.where((n) => n.type == NotificationType.order).toList();
    } else if (_selectedCategory == 'Offers') {
      return list.where((n) => n.type == NotificationType.promo).toList();
    } else if (_selectedCategory == 'System') {
      return list.where((n) => n.type == NotificationType.system).toList();
    }
    return list;
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
                // Header Row
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: widget.onBackTap ?? () => Navigator.pop(context),
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
                        'Notifications',
                        style: GoogleFonts.baloo2(
                          fontSize: 30,
                          fontWeight: FontWeight.w700,
                          color: textColor,
                        ),
                      ),
                      const Spacer(),
                      ValueListenableBuilder<List<NotificationModel>>(
                        valueListenable: AppNotificationFeedManager.instance,
                        builder: (context, notifs, child) {
                          if (notifs.isEmpty) return const SizedBox.shrink();
                          return GestureDetector(
                            onTap: () {
                              AppNotificationFeedManager.instance.markAllAsRead();
                              ToastManager.instance.show(
                                context,
                                'All notifications marked as read',
                                icon: Icons.done_all_rounded,
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: accent.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Text(
                                'Mark Read',
                                style: GoogleFonts.poppins(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.bold,
                                  color: accent,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 6),

                // Category Filter Chips Row
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: _categories.map((cat) {
                      final isSelected = _selectedCategory == cat;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedCategory = cat),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(right: 10),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? accent : cardBg,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: isSelected ? accent : hairline,
                            ),
                          ),
                          child: Text(
                            cat,
                            style: GoogleFonts.poppins(
                              fontSize: 12.5,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              color: isSelected ? Colors.black : textColor,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 14),

                // Notification List / Empty State
                Expanded(
                  child: ValueListenableBuilder<List<NotificationModel>>(
                    valueListenable: AppNotificationFeedManager.instance,
                    builder: (context, notifs, child) {
                      final filtered = _filterNotifications(notifs);

                      if (filtered.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.notifications_none_rounded,
                                size: 75,
                                color: subtextColor.withValues(alpha: 0.3),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No Notifications Here',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'We will notify you when your food order updates.',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: subtextColor,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        itemCount: filtered.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final item = filtered[index];

                          return Dismissible(
                            key: Key(item.id),
                            direction: DismissDirection.endToStart,
                            onDismissed: (_) {
                              AppNotificationFeedManager.instance.deleteNotification(item.id);
                              ToastManager.instance.show(
                                context,
                                'Notification deleted',
                                icon: Icons.delete_outline,
                              );
                            },
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              decoration: BoxDecoration(
                                color: Colors.redAccent.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(22),
                              ),
                              child: const Icon(Icons.delete_forever_rounded, color: Colors.redAccent),
                            ),
                            child: GestureDetector(
                              onTap: () {
                                AppNotificationFeedManager.instance.markAsRead(item.id);
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: item.isRead
                                      ? cardBg
                                      : accent.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(22),
                                  border: Border.all(
                                    color: item.isRead
                                        ? hairline
                                        : accent.withValues(alpha: 0.3),
                                    width: item.isRead ? 1 : 1.5,
                                  ),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: item.iconColor.withValues(alpha: 0.15),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(item.icon, color: item.iconColor, size: 22),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  item.title,
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 14.5,
                                                    fontWeight: item.isRead ? FontWeight.w600 : FontWeight.bold,
                                                    color: textColor,
                                                  ),
                                                ),
                                              ),
                                              if (!item.isRead)
                                                Container(
                                                  width: 8,
                                                  height: 8,
                                                  margin: const EdgeInsets.only(left: 6),
                                                  decoration: BoxDecoration(
                                                    color: accent,
                                                    shape: BoxShape.circle,
                                                  ),
                                                ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            item.message,
                                            style: GoogleFonts.poppins(
                                              fontSize: 12.5,
                                              color: subtextColor,
                                              height: 1.35,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            item.time,
                                            style: GoogleFonts.poppins(
                                              fontSize: 11,
                                              color: subtextColor.withValues(alpha: 0.6),
                                              fontWeight: FontWeight.w500,
                                            ),
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
