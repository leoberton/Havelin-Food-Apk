import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'live_driver_gps_service.dart';
import 'loyalty_backend_service.dart';
import 'notification_manager.dart';

enum OrderPipelineStage { placed, cooking, outForDelivery, delivered, cancelled }

class OrderPipelineBackendService {
  static final OrderPipelineBackendService instance = OrderPipelineBackendService._internal();

  OrderPipelineBackendService._internal();

  /// 🛵 State Machine Transition: Advance Order Status in Cloud Firestore
  Future<bool> transitionOrderStatus({
    required String orderId,
    required OrderPipelineStage targetStage,
    required String userId,
    required double orderTotal,
  }) async {
    try {
      final db = FirebaseFirestore.instance;
      final orderRef = db.collection('orders').doc(orderId);

      final Map<String, dynamic> updateMap = {
        'status': targetStage.name,
        'lastUpdated': Timestamp.fromDate(DateTime.now()),
      };

      if (targetStage == OrderPipelineStage.outForDelivery) {
        updateMap['riderName'] = 'Rider Rahul';
        updateMap['riderPhone'] = '+91 98765 43210';
        updateMap['riderVehicle'] = 'TVS Ntorq 125 (TS 09 EQ 8812)';

        // Start live driver GPS route simulation in background
        LiveDriverGpsService.instance.startDriverGpsSimulation(orderId);

        NotificationManager.instance.showNotification(
          title: "Order Dispatched! 🛵",
          body: "Rider Rahul has picked up your order #$orderId and is heading to your address!",
        );
      } else if (targetStage == OrderPipelineStage.cooking) {
        NotificationManager.instance.showNotification(
          title: "Kitchen is Preparing Your Food! 👨‍🍳",
          body: "Order #$orderId accepted by Executive Chef Vikram. Fresh gourmet cooking in progress!",
        );
      } else if (targetStage == OrderPipelineStage.delivered) {
        updateMap['paymentStatus'] = 'PAID';

        // Award Havelin Cashback Coins automatically!
        await LoyaltyBackendService.instance.awardCoinsForOrder(userId, orderTotal);

        NotificationManager.instance.showNotification(
          title: "Order Delivered! Enjoy your meal! 🍲✅",
          body: "Order #$orderId delivered successfully. Rate your dishes in App!",
        );
      }

      await orderRef.update(updateMap);
      return true;
    } catch (e) {
      debugPrint("Order Pipeline Transition Note: $e");
      return false;
    }
  }

  /// 📡 Stream Real-Time Pipeline Status for an Order
  Stream<OrderPipelineStage> streamOrderPipelineStage(String orderId) {
    try {
      final db = FirebaseFirestore.instance;
      return db.collection('orders').doc(orderId).snapshots().map((doc) {
        if (doc.exists && doc.data() != null) {
          final statusStr = doc.data()!['status']?.toString().toLowerCase() ?? 'placed';
          for (var stage in OrderPipelineStage.values) {
            if (stage.name.toLowerCase() == statusStr) {
              return stage;
            }
          }
        }
        return OrderPipelineStage.placed;
      });
    } catch (e) {
      debugPrint("Stream Pipeline Stage Note: $e");
      return Stream.value(OrderPipelineStage.placed);
    }
  }
}
