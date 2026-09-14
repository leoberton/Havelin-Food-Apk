import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'notification_manager.dart';

class LoyaltyAccountModel {
  final String userId;
  final int totalCoins;
  final int lifetimeEarned;
  final int lifetimeRedeemed;
  final String tier; // 'Silver', 'Gold', 'Platinum'
  final DateTime lastUpdated;

  LoyaltyAccountModel({
    required this.userId,
    required this.totalCoins,
    required this.lifetimeEarned,
    required this.lifetimeRedeemed,
    required this.tier,
    required this.lastUpdated,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'totalCoins': totalCoins,
      'lifetimeEarned': lifetimeEarned,
      'lifetimeRedeemed': lifetimeRedeemed,
      'tier': tier,
      'lastUpdated': Timestamp.fromDate(lastUpdated),
    };
  }

  factory LoyaltyAccountModel.fromMap(Map<String, dynamic> map) {
    DateTime parsedDate;
    final ts = map['lastUpdated'];
    if (ts is Timestamp) {
      parsedDate = ts.toDate();
    } else {
      parsedDate = DateTime.now();
    }

    final total = (map['totalCoins'] as num?)?.toInt() ?? 100;
    String calculatedTier = 'Silver';
    if (total >= 500) {
      calculatedTier = 'Platinum';
    } else if (total >= 250) {
      calculatedTier = 'Gold';
    }

    return LoyaltyAccountModel(
      userId: map['userId']?.toString() ?? '',
      totalCoins: total,
      lifetimeEarned: (map['lifetimeEarned'] as num?)?.toInt() ?? 100,
      lifetimeRedeemed: (map['lifetimeRedeemed'] as num?)?.toInt() ?? 0,
      tier: map['tier']?.toString() ?? calculatedTier,
      lastUpdated: parsedDate,
    );
  }
}

class LoyaltyBackendService {
  static final LoyaltyBackendService instance = LoyaltyBackendService._internal();

  LoyaltyBackendService._internal();

  /// 🪙 Award Havelin Coins (10 Coins per ₹100 spent) on Order Completion
  Future<int> awardCoinsForOrder(String userId, double orderAmount) async {
    final earned = ((orderAmount / 100) * 10).round().clamp(10, 500);
    final effectiveUserId = userId.isNotEmpty ? userId : 'USER_GUEST';

    try {
      final db = FirebaseFirestore.instance;
      final docRef = db.collection('users').doc(effectiveUserId).collection('loyalty').doc('coins');

      final snap = await docRef.get();
      int currentCoins = 100;
      int lifetimeEarned = 100;
      int lifetimeRedeemed = 0;

      if (snap.exists && snap.data() != null) {
        final data = snap.data()!;
        currentCoins = (data['totalCoins'] as num?)?.toInt() ?? 100;
        lifetimeEarned = (data['lifetimeEarned'] as num?)?.toInt() ?? 100;
        lifetimeRedeemed = (data['lifetimeRedeemed'] as num?)?.toInt() ?? 0;
      }

      final newTotal = currentCoins + earned;
      final newLifetime = lifetimeEarned + earned;

      String newTier = 'Silver';
      if (newTotal >= 500) {
        newTier = 'Platinum 👑';
      } else if (newTotal >= 250) {
        newTier = 'Gold 🌟';
      }

      final updatedModel = LoyaltyAccountModel(
        userId: effectiveUserId,
        totalCoins: newTotal,
        lifetimeEarned: newLifetime,
        lifetimeRedeemed: lifetimeRedeemed,
        tier: newTier,
        lastUpdated: DateTime.now(),
      );

      await docRef.set(updatedModel.toMap(), SetOptions(merge: true));

      NotificationManager.instance.showNotification(
        title: "+$earned Havelin Coins Earned! 🪙",
        body: "You earned $earned cashback coins on your ₹${orderAmount.toStringAsFixed(0)} order! Balance: $newTotal Coins.",
      );

      return earned;
    } catch (e) {
      debugPrint("Award Coins Note: $e");
      return 0;
    }
  }

  /// 🛍️ Redeem Coins for Instant Order Bill Discount (10 Coins = ₹10 Discount)
  Future<bool> redeemCoins(String userId, int coinsToRedeem) async {
    final effectiveUserId = userId.isNotEmpty ? userId : 'USER_GUEST';

    try {
      final db = FirebaseFirestore.instance;
      final docRef = db.collection('users').doc(effectiveUserId).collection('loyalty').doc('coins');

      final snap = await docRef.get();
      if (!snap.exists || snap.data() == null) return false;

      final data = snap.data()!;
      int currentCoins = (data['totalCoins'] as num?)?.toInt() ?? 0;
      int lifetimeEarned = (data['lifetimeEarned'] as num?)?.toInt() ?? 0;
      int lifetimeRedeemed = (data['lifetimeRedeemed'] as num?)?.toInt() ?? 0;

      if (currentCoins < coinsToRedeem) return false;

      final newTotal = currentCoins - coinsToRedeem;
      final newRedeemed = lifetimeRedeemed + coinsToRedeem;

      String newTier = 'Silver';
      if (newTotal >= 500) {
        newTier = 'Platinum 👑';
      } else if (newTotal >= 250) {
        newTier = 'Gold 🌟';
      }

      final updatedModel = LoyaltyAccountModel(
        userId: effectiveUserId,
        totalCoins: newTotal,
        lifetimeEarned: lifetimeEarned,
        lifetimeRedeemed: newRedeemed,
        tier: newTier,
        lastUpdated: DateTime.now(),
      );

      await docRef.set(updatedModel.toMap(), SetOptions(merge: true));
      return true;
    } catch (e) {
      debugPrint("Redeem Coins Note: $e");
      return false;
    }
  }

  /// 📡 Stream Real-Time User Loyalty Coins Account
  Stream<LoyaltyAccountModel> streamUserLoyalty(String userId) {
    try {
      final db = FirebaseFirestore.instance;
      final effectiveUserId = userId.isNotEmpty ? userId : 'USER_GUEST';
      return db
          .collection('users')
          .doc(effectiveUserId)
          .collection('loyalty')
          .doc('coins')
          .snapshots()
          .map((doc) {
        if (doc.exists && doc.data() != null) {
          return LoyaltyAccountModel.fromMap(doc.data()!);
        }
        return LoyaltyAccountModel(
          userId: effectiveUserId,
          totalCoins: 120,
          lifetimeEarned: 120,
          lifetimeRedeemed: 0,
          tier: 'Silver',
          lastUpdated: DateTime.now(),
        );
      });
    } catch (e) {
      debugPrint("Stream Loyalty Note: $e");
      return Stream.value(
        LoyaltyAccountModel(
          userId: userId,
          totalCoins: 120,
          lifetimeEarned: 120,
          lifetimeRedeemed: 0,
          tier: 'Silver',
          lastUpdated: DateTime.now(),
        ),
      );
    }
  }
}
