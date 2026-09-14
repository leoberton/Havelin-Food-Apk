import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class AnalyticsModel {
  final double totalRevenue;
  final int totalOrdersCount;
  final int pendingOrdersCount;
  final int completedOrdersCount;
  final int cancelledOrdersCount;
  final double averageOrderValue;
  final Map<String, int> topSellingDishes;
  final Map<int, int> hourlyOrderDistribution;
  final DateTime lastUpdated;

  AnalyticsModel({
    required this.totalRevenue,
    required this.totalOrdersCount,
    required this.pendingOrdersCount,
    required this.completedOrdersCount,
    required this.cancelledOrdersCount,
    required this.averageOrderValue,
    required this.topSellingDishes,
    required this.hourlyOrderDistribution,
    required this.lastUpdated,
  });

  Map<String, dynamic> toMap() {
    return {
      'totalRevenue': totalRevenue,
      'totalOrdersCount': totalOrdersCount,
      'pendingOrdersCount': pendingOrdersCount,
      'completedOrdersCount': completedOrdersCount,
      'cancelledOrdersCount': cancelledOrdersCount,
      'averageOrderValue': averageOrderValue,
      'topSellingDishes': topSellingDishes,
      'hourlyOrderDistribution': hourlyOrderDistribution.map((k, v) => MapEntry(k.toString(), v)),
      'lastUpdated': Timestamp.fromDate(lastUpdated),
    };
  }

  factory AnalyticsModel.fromMap(Map<String, dynamic> map) {
    DateTime parsedDate;
    final ts = map['lastUpdated'];
    if (ts is Timestamp) {
      parsedDate = ts.toDate();
    } else {
      parsedDate = DateTime.now();
    }

    final topMap = <String, int>{};
    if (map['topSellingDishes'] is Map) {
      (map['topSellingDishes'] as Map).forEach((k, v) {
        topMap[k.toString()] = (v as num?)?.toInt() ?? 0;
      });
    }

    final hourlyMap = <int, int>{};
    if (map['hourlyOrderDistribution'] is Map) {
      (map['hourlyOrderDistribution'] as Map).forEach((k, v) {
        final hour = int.tryParse(k.toString()) ?? 0;
        hourlyMap[hour] = (v as num?)?.toInt() ?? 0;
      });
    }

    return AnalyticsModel(
      totalRevenue: (map['totalRevenue'] as num?)?.toDouble() ?? 0.0,
      totalOrdersCount: (map['totalOrdersCount'] as num?)?.toInt() ?? 0,
      pendingOrdersCount: (map['pendingOrdersCount'] as num?)?.toInt() ?? 0,
      completedOrdersCount: (map['completedOrdersCount'] as num?)?.toInt() ?? 0,
      cancelledOrdersCount: (map['cancelledOrdersCount'] as num?)?.toInt() ?? 0,
      averageOrderValue: (map['averageOrderValue'] as num?)?.toDouble() ?? 0.0,
      topSellingDishes: topMap,
      hourlyOrderDistribution: hourlyMap,
      lastUpdated: parsedDate,
    );
  }
}

class AnalyticsBackendService {
  static final AnalyticsBackendService instance = AnalyticsBackendService._internal();

  AnalyticsBackendService._internal();

  /// 📊 Stream Real-Time Kitchen Revenue & Sales Analytics from Cloud Firestore
  Stream<AnalyticsModel> streamRealtimeAnalytics() {
    try {
      final db = FirebaseFirestore.instance;
      return db.collection('orders').snapshots().map((snapshot) {
        double revenue = 0.0;
        int totalOrders = snapshot.docs.length;
        int pendingOrders = 0;
        int completedOrders = 0;
        int cancelledOrders = 0;

        final dishCounts = <String, int>{};
        final hourlyCounts = <int, int>{};

        for (var doc in snapshot.docs) {
          final data = doc.data();
          final statusStr = data['status']?.toString().toLowerCase() ?? '';
          final total = (data['total'] as num?)?.toDouble() ?? 0.0;

          if (statusStr.contains('delivered') || statusStr.contains('completed')) {
            completedOrders++;
            revenue += total;
          } else if (statusStr.contains('cancel')) {
            cancelledOrders++;
          } else {
            pendingOrders++;
            revenue += total; // Include active order values in live pipeline
          }

          // Parse Timestamp for Hourly Distribution
          final ts = data['orderDate'];
          if (ts is Timestamp) {
            final hour = ts.toDate().hour;
            hourlyCounts[hour] = (hourlyCounts[hour] ?? 0) + 1;
          }

          // Parse Items for Top-Selling Dishes Leaderboard
          final items = data['items'];
          if (items is List) {
            for (var item in items) {
              if (item is Map) {
                final foodMap = item['foodItem'];
                final qty = (item['quantity'] as num?)?.toInt() ?? 1;
                if (foodMap is Map) {
                  final name = foodMap['name']?.toString() ?? 'Gourmet Dish';
                  dishCounts[name] = (dishCounts[name] ?? 0) + qty;
                }
              }
            }
          }
        }

        // Sort Top Selling Dishes
        final sortedDishes = Map.fromEntries(
          dishCounts.entries.toList()..sort((a, b) => b.value.compareTo(a.value)),
        );

        final avgOrderVal = totalOrders > 0 ? (revenue / totalOrders) : 0.0;

        return AnalyticsModel(
          totalRevenue: revenue,
          totalOrdersCount: totalOrders,
          pendingOrdersCount: pendingOrders,
          completedOrdersCount: completedOrders,
          cancelledOrdersCount: cancelledOrders,
          averageOrderValue: avgOrderVal,
          topSellingDishes: sortedDishes,
          hourlyOrderDistribution: hourlyCounts,
          lastUpdated: DateTime.now(),
        );
      });
    } catch (e) {
      debugPrint("Stream Analytics Note: $e");
      return Stream.value(
        AnalyticsModel(
          totalRevenue: 0.0,
          totalOrdersCount: 0,
          pendingOrdersCount: 0,
          completedOrdersCount: 0,
          cancelledOrdersCount: 0,
          averageOrderValue: 0.0,
          topSellingDishes: {},
          hourlyOrderDistribution: {},
          lastUpdated: DateTime.now(),
        ),
      );
    }
  }

  /// 💾 Record Daily Summary Snapshot to Cloud Firestore `analytics/daily_stats`
  Future<void> syncDailyAnalyticsSnapshot(AnalyticsModel analytics) async {
    try {
      final db = FirebaseFirestore.instance;
      final todayStr = "${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day}";
      await db.collection('analytics').doc(todayStr).set(analytics.toMap(), SetOptions(merge: true));
    } catch (e) {
      debugPrint("Sync Daily Analytics Note: $e");
    }
  }
}
