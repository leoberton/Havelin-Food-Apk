import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../managers/cart_manager.dart';
import 'firebase_manager.dart';

class CloudMenuService {
  static final CloudMenuService instance = CloudMenuService._internal();

  CloudMenuService._internal();

  FirebaseFirestore get _db => FirebaseFirestore.instance;

  /// 🍲 1. Stream Live Dishes & Stock Availability from Cloud Firestore
  Stream<List<FoodItem>> streamCloudDishes() {
    if (!FirebaseManager.instance.isFirebaseInitialized) return const Stream.empty();

    return _db.collection('dishes').snapshots().map((snapshot) {
      if (snapshot.docs.isEmpty) return sampleDishes;

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return FoodItem(
          id: data['id'] ?? doc.id,
          name: data['name'] ?? '',
          priceString: '₹${(data['price'] as num?)?.toStringAsFixed(0) ?? "180"}',
          price: (data['price'] as num?)?.toDouble() ?? 180.0,
          category: data['category'] ?? 'Biryani',
          rating: (data['rating'] as num?)?.toDouble() ?? 4.5,
          imagePath: data['imagePath'] ?? 'assets/images/logo.png',
          description: data['description'] ?? '',
        );
      }).toList();
    });
  }

  /// 🍲 2. Toggle Dish Stock Status (In-Stock / Sold-Out)
  Future<void> toggleDishStockStatus(String dishId, bool isAvailable) async {
    if (!FirebaseManager.instance.isFirebaseInitialized) return;
    try {
      await _db.collection('dishes').doc(dishId).update({
        'isAvailable': isAvailable,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      debugPrint("🍲 Dish $dishId availability set to $isAvailable in Cloud!");
    } catch (e) {
      debugPrint("⚠️ Could not update dish stock: $e");
    }
  }

  /// 🍲 3. Add New Dish to Cloud Firestore
  Future<void> addNewDishToCloud(FoodItem item) async {
    if (!FirebaseManager.instance.isFirebaseInitialized) return;
    try {
      await _db.collection('dishes').doc(item.id.isNotEmpty ? item.id : item.name).set({
        'id': item.id,
        'name': item.name,
        'category': item.category,
        'price': item.price,
        'rating': item.rating,
        'imagePath': item.imagePath,
        'description': item.description,
        'isAvailable': true,
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      debugPrint("🍲 Added new dish ${item.name} to Cloud Firestore!");
    } catch (e) {
      debugPrint("⚠️ Error adding dish: $e");
    }
  }

  /// 🍲 4. Update Dish Price Live in Cloud Firestore
  Future<void> updateDishPrice(String dishId, double newPrice) async {
    if (!FirebaseManager.instance.isFirebaseInitialized) return;
    try {
      await _db.collection('dishes').doc(dishId).update({
        'price': newPrice,
        'priceString': '₹${newPrice.toStringAsFixed(0)}',
        'updatedAt': FieldValue.serverTimestamp(),
      });
      debugPrint("💰 Dish $dishId price updated to ₹$newPrice in Cloud!");
    } catch (e) {
      debugPrint("⚠️ Could not update dish price: $e");
    }
  }
}
