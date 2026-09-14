import 'package:flutter/material.dart';
import '../backend/firebase_manager.dart';
import 'cart_manager.dart';
import 'user_manager.dart';

enum OrderStatus {
  placed,
  cooking,
  outForDelivery,
  delivered,
  cancelled,
}

class OrderModel {
  final String orderId;
  final DateTime orderDate;
  final List<CartItem> items;
  final double subtotal;
  final double discount;
  final double deliveryFee;
  final double total;
  final OrderStatus status;
  final String deliveryAddress;
  final String paymentMethod;
  final String paymentStatus;
  final String transactionId;

  OrderModel({
    required this.orderId,
    required this.orderDate,
    required this.items,
    required this.subtotal,
    required this.discount,
    required this.deliveryFee,
    required this.total,
    required this.status,
    required this.deliveryAddress,
    this.paymentMethod = 'UPI Instant Pay',
    this.paymentStatus = 'PAID',
    this.transactionId = 'TXN_SUCCESS',
  });
}

class OrderHistoryManager extends ValueNotifier<List<OrderModel>> {
  static final OrderHistoryManager instance = OrderHistoryManager._internal();

  OrderHistoryManager._internal()
      : super([
          OrderModel(
            orderId: 'HV-9482',
            orderDate: DateTime.now().subtract(const Duration(hours: 2)),
            items: [
              CartItem(
                foodItem: const FoodItem(
                  id: 'beef_burger',
                  name: 'Angus Beef Burger',
                  priceString: '₹199',
                  price: 199.0,
                  imagePath: 'assets/images/beef burger.png',
                  description: 'Juicy Beef Burger with cheese',
                  rating: 4.5,
                ),
                quantity: 2,
              ),
              CartItem(
                foodItem: const FoodItem(
                  id: 'french_fries',
                  name: 'Crispy Fries',
                  priceString: '₹99',
                  price: 99.0,
                  imagePath: 'assets/images/french.png',
                  description: 'Crispy fries',
                  rating: 4.2,
                ),
                quantity: 1,
              ),
            ],
            subtotal: 48.0,
            discount: 14.40,
            deliveryFee: 3.50,
            total: 37.10,
            status: OrderStatus.delivered,
            deliveryAddress: '${UserManager.instance.value.addressLine1}, ${UserManager.instance.value.addressLine2}',
          ),
        ]);

  OrderModel createOrder({
    required List<CartItem> items,
    required double subtotal,
    required double discount,
    required double deliveryFee,
    String paymentMethod = 'UPI Instant Pay',
    String paymentStatus = 'PAID',
    String transactionId = 'TXN_SUCCESS',
  }) {
    final newOrder = OrderModel(
      orderId: 'HV-${(1000 + value.length * 137 + 52).toString()}',
      orderDate: DateTime.now(),
      items: List<CartItem>.from(items),
      subtotal: subtotal,
      discount: discount,
      deliveryFee: deliveryFee,
      total: (subtotal - discount) + deliveryFee,
      status: OrderStatus.cooking,
      deliveryAddress: '${UserManager.instance.value.addressLine1}, ${UserManager.instance.value.addressLine2}',
      paymentMethod: paymentMethod,
      paymentStatus: paymentStatus,
      transactionId: transactionId,
    );

    value = [newOrder, ...value];
    FirebaseManager.instance.pushOrderToCloud(newOrder);
    return newOrder;
  }

  void updateOrderStatus(String orderId, OrderStatus newStatus) {
    final list = List<OrderModel>.from(value);
    final index = list.indexWhere((o) => o.orderId == orderId);
    if (index != -1) {
      final old = list[index];
      list[index] = OrderModel(
        orderId: old.orderId,
        orderDate: old.orderDate,
        items: old.items,
        subtotal: old.subtotal,
        discount: old.discount,
        deliveryFee: old.deliveryFee,
        total: old.total,
        status: newStatus,
        deliveryAddress: old.deliveryAddress,
      );
      value = list;
      FirebaseManager.instance.updateOrderStatusInCloud(orderId, newStatus.name);
    }
  }

  void cancelOrder(String orderId) {
    final list = List<OrderModel>.from(value);
    final index = list.indexWhere((o) => o.orderId == orderId);
    if (index != -1) {
      final old = list[index];
      list[index] = OrderModel(
        orderId: old.orderId,
        orderDate: old.orderDate,
        items: old.items,
        subtotal: old.subtotal,
        discount: old.discount,
        deliveryFee: old.deliveryFee,
        total: old.total,
        status: OrderStatus.cancelled,
        deliveryAddress: old.deliveryAddress,
      );
      value = list;
      FirebaseManager.instance.updateOrderStatusInCloud(orderId, 'cancelled');
    }
  }

  OrderModel? get activeOrder {
    try {
      return value.firstWhere(
        (o) => o.status != OrderStatus.delivered && o.status != OrderStatus.cancelled,
      );
    } catch (_) {
      return null;
    }
  }
}
