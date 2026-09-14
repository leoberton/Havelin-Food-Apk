import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'notification_manager.dart';

class ReviewModel {
  final String reviewId;
  final String dishId;
  final String dishName;
  final String userId;
  final String userName;
  final String userAvatar;
  final double rating;
  final String comment;
  final DateTime timestamp;
  final bool isVerifiedBuyer;

  ReviewModel({
    required this.reviewId,
    required this.dishId,
    required this.dishName,
    required this.userId,
    required this.userName,
    this.userAvatar = '',
    required this.rating,
    required this.comment,
    required this.timestamp,
    this.isVerifiedBuyer = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'reviewId': reviewId,
      'dishId': dishId,
      'dishName': dishName,
      'userId': userId,
      'userName': userName,
      'userAvatar': userAvatar,
      'rating': rating,
      'comment': comment,
      'timestamp': Timestamp.fromDate(timestamp),
      'isVerifiedBuyer': isVerifiedBuyer,
    };
  }

  factory ReviewModel.fromMap(Map<String, dynamic> map) {
    DateTime parsedDate;
    final ts = map['timestamp'];
    if (ts is Timestamp) {
      parsedDate = ts.toDate();
    } else if (ts is String) {
      parsedDate = DateTime.tryParse(ts) ?? DateTime.now();
    } else {
      parsedDate = DateTime.now();
    }

    return ReviewModel(
      reviewId: map['reviewId']?.toString() ?? '',
      dishId: map['dishId']?.toString() ?? '',
      dishName: map['dishName']?.toString() ?? '',
      userId: map['userId']?.toString() ?? '',
      userName: map['userName']?.toString() ?? 'Gourmet Foodie',
      userAvatar: map['userAvatar']?.toString() ?? '',
      rating: (map['rating'] as num?)?.toDouble() ?? 5.0,
      comment: map['comment']?.toString() ?? '',
      timestamp: parsedDate,
      isVerifiedBuyer: map['isVerifiedBuyer'] == true,
    );
  }
}

class ReviewBackendService {
  static final ReviewBackendService instance = ReviewBackendService._internal();

  ReviewBackendService._internal();

  /// ⭐ Submit Customer Dish Review to Cloud Firestore
  Future<bool> submitReview({
    required String dishId,
    required String dishName,
    required String userId,
    required String userName,
    required double rating,
    required String comment,
    String userAvatar = '',
  }) async {
    final timestamp = DateTime.now();
    final reviewId = "REV_${timestamp.millisecondsSinceEpoch}";

    final review = ReviewModel(
      reviewId: reviewId,
      dishId: dishId,
      dishName: dishName,
      userId: userId,
      userName: userName,
      userAvatar: userAvatar,
      rating: rating,
      comment: comment,
      timestamp: timestamp,
      isVerifiedBuyer: true,
    );

    try {
      final db = FirebaseFirestore.instance;

      // 1. Write review document to Cloud Firestore
      await db.collection('reviews').doc(reviewId).set(review.toMap());

      // 2. Recalculate average rating & review count for the dish
      final dishReviewsQuery = await db
          .collection('reviews')
          .where('dishId', isEqualTo: dishId)
          .get();

      if (dishReviewsQuery.docs.isNotEmpty) {
        double totalRating = 0.0;
        for (var doc in dishReviewsQuery.docs) {
          totalRating += (doc.data()['rating'] as num?)?.toDouble() ?? 5.0;
        }
        final count = dishReviewsQuery.docs.length;
        final avgRating = double.parse((totalRating / count).toStringAsFixed(1));

        // 3. Update dish document in menu_dishes collection
        await db.collection('menu_dishes').doc(dishId).update({
          'rating': avgRating,
          'ratingCount': count,
        });
      }

      // 4. Trigger Push Notification Confirmation
      NotificationManager.instance.showNotification(
        title: "Review Published! ⭐",
        body: "Thank you $userName! Your ${rating.toStringAsFixed(1)}★ review for $dishName is now live!",
      );

      return true;
    } catch (e) {
      debugPrint("Cloud Dish Review Note: $e");
      return false;
    }
  }

  /// 📡 Stream Live Dish Reviews for a specific food item
  Stream<List<ReviewModel>> streamDishReviews(String dishId) {
    try {
      final db = FirebaseFirestore.instance;
      return db
          .collection('reviews')
          .where('dishId', isEqualTo: dishId)
          .snapshots()
          .map((snapshot) {
        final list = snapshot.docs.map((doc) => ReviewModel.fromMap(doc.data())).toList();
        list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        return list;
      });
    } catch (e) {
      debugPrint("Stream Dish Reviews Note: $e");
      return Stream.value([]);
    }
  }

  /// 👤 Stream Live Reviews written by a specific user
  Stream<List<ReviewModel>> streamUserReviews(String userId) {
    try {
      final db = FirebaseFirestore.instance;
      return db
          .collection('reviews')
          .where('userId', isEqualTo: userId)
          .snapshots()
          .map((snapshot) {
        final list = snapshot.docs.map((doc) => ReviewModel.fromMap(doc.data())).toList();
        list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        return list;
      });
    } catch (e) {
      debugPrint("Stream User Reviews Note: $e");
      return Stream.value([]);
    }
  }
}
