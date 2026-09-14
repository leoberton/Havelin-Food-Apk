import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../managers/cart_manager.dart';
import '../managers/order_history_manager.dart';
import 'firebase_manager.dart';

class NotificationManager {
  static final NotificationManager instance = NotificationManager._internal();

  NotificationManager._internal();

  final FlutterLocalNotificationsPlugin _localPlugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    try {
      const androidChannel = AndroidNotificationChannel(
        'havelin_orders_channel',
        'Order Status Updates',
        description: 'Notifications for live food order status changes',
        importance: Importance.high,
        playSound: true,
      );

      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosSettings = DarwinInitializationSettings();
      const initSettings = InitializationSettings(android: androidSettings, iOS: iosSettings);

      await _localPlugin.initialize(initSettings);

      final androidImplementation = _localPlugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      if (androidImplementation != null) {
        await androidImplementation.createNotificationChannel(androidChannel);
        await androidImplementation.requestNotificationsPermission();
      }

      final messaging = FirebaseMessaging.instance;
      await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      final fcmToken = await messaging.getToken();
      if (fcmToken != null) {
        debugPrint("🔑 FCM Registration Token: $fcmToken");
        await FirebaseManager.instance.saveFcmTokenToCloud(fcmToken);
      }

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        if (message.notification != null) {
          showNotification(
            title: message.notification!.title ?? 'Havelin Food Alert 🍲',
            body: message.notification!.body ?? 'Your order status was updated!',
          );
        }
      });

      _initialized = true;
      debugPrint("🔔 Notification Manager Initialized Successfully!");
    } catch (e) {
      debugPrint("⚠️ Notification init notice: $e");
    }
  }

  Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    try {
      const androidDetails = AndroidNotificationDetails(
        'havelin_orders_channel',
        'Order Status Updates',
        channelDescription: 'Notifications for live food order status changes',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@drawable/ic_stat_notification',
        largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
        color: Color(0xFF00A884),
        playSound: true,
      );

      const iosDetails = DarwinNotificationDetails(presentAlert: true, presentSound: true);
      const details = NotificationDetails(android: androidDetails, iOS: iosDetails);

      await _localPlugin.show(
        DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title,
        body,
        details,
        payload: payload,
      );
    } catch (e) {
      debugPrint("⚠️ Show notification notice: $e");
    }
  }

  /// 🔔 Module 1: Order Lifecycle Notification Engine
  Future<void> sendOrderStatusNotification({
    required String orderId,
    required OrderStatus status,
  }) async {
    String title = 'Havelin Order Update 🔔';
    String body = 'Order #$orderId status updated!';

    switch (status) {
      case OrderStatus.placed:
        title = 'Order Confirmed! 👨‍🍳';
        body = 'Chef is firing up the kitchen for Order #$orderId.';
        break;
      case OrderStatus.cooking:
        title = 'Cooking in Progress! 🔥';
        body = 'Your food for Order #$orderId is simmering in spices!';
        break;
      case OrderStatus.outForDelivery:
        title = 'Out for Delivery! 🛵💨';
        body = 'Rider Rahul is on his way with your hot food for #$orderId!';
        break;
      case OrderStatus.delivered:
        title = 'Order Delivered! 🎉';
        body = 'Order #$orderId has arrived! Bon Appétit 😋';
        break;
      case OrderStatus.cancelled:
        title = 'Order Cancelled ❌';
        body = 'Order #$orderId was cancelled. You can re-order anytime!';
        break;
    }

    await showNotification(title: title, body: body, payload: orderId);
    await FirebaseManager.instance.pushNotificationToCloudFeed(
      title: title,
      body: body,
      type: 'order',
      orderId: orderId,
    );
  }

  /// 🛒 Module 2: Abandoned Cart Notification Alert System
  void scheduleAbandonedCartReminder(List<CartItem> cartItems) {
    if (cartItems.isEmpty) return;
    final firstDish = cartItems.first.foodItem.name;
    Future.delayed(const Duration(seconds: 15), () {
      if (CartManager.instance.items.isNotEmpty) {
        showNotification(
          title: 'Your Cart misses you! 🛒🍔',
          body: '$firstDish is waiting in your cart. Complete order in 1 tap!',
          payload: 'cart',
        );
        FirebaseManager.instance.pushNotificationToCloudFeed(
          title: 'Your Cart misses you! 🛒🍔',
          body: '$firstDish is waiting in your cart. Complete order in 1 tap!',
          type: 'promo',
        );
      }
    });
  }
}
