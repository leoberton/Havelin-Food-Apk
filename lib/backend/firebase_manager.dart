import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import '../managers/cart_manager.dart';
import '../managers/order_history_manager.dart';
import '../managers/user_manager.dart';
import 'auth_service.dart';
import 'firebase_options.dart';

class FirebaseManager {
  static final FirebaseManager instance = FirebaseManager._internal();

  FirebaseManager._internal();

  FirebaseFirestore get _db => FirebaseFirestore.instance;

  bool _isFirebaseInitialized = false;
  bool get isFirebaseInitialized => _isFirebaseInitialized;

  /// STEP 1: Initialize Firebase Core safely
  Future<void> initializeFirebase() async {
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      }
      _isFirebaseInitialized = true;
      debugPrint("✅ Firebase Cloud Services Initialized Successfully!");
    } catch (e) {
      debugPrint("⚠️ Firebase init notice: $e");
    }
  }

  /// STEP 2: Save or Sync User Profile to Firestore collection `users`
  Future<void> syncUserProfile(UserData user) async {
    if (!_isFirebaseInitialized) return;
    try {
      final currentUser = AuthService.instance.currentUser;
      final docId = (currentUser != null && currentUser.uid.isNotEmpty)
          ? currentUser.uid
          : (user.phone.isNotEmpty ? user.phone : (user.email.isNotEmpty ? user.email : 'user_demo'));

      final userDoc = _db.collection('users').doc(docId);
      await userDoc.set({
        'uid': currentUser?.uid ?? '',
        'name': user.name,
        'phone': user.phone,
        'email': user.email,
        'addressTag': user.addressTag,
        'addressLine1': user.addressLine1,
        'addressLine2': user.addressLine2,
        'landmark': user.landmark,
        'profileImagePath': user.profileImagePath,
        'isAddressConfigured': user.isAddressConfigured,
        'isNewAccount': user.isNewAccount,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      debugPrint("☁️ User Profile synced to Cloud Firestore ($docId): ${user.name}");
    } catch (e) {
      debugPrint("⚠️ Could not sync user profile to cloud: $e");
    }
  }

  /// STEP 2B: Fetch and Restore User Profile from Cloud Firestore on Login
  Future<void> fetchAndRestoreUserProfile() async {
    if (!_isFirebaseInitialized) return;
    try {
      final currentUser = AuthService.instance.currentUser;
      if (currentUser == null) return;

      final docRef = _db.collection('users').doc(currentUser.uid);
      final snapshot = await docRef.get();

      if (snapshot.exists && snapshot.data() != null) {
        final data = snapshot.data()!;
        UserManager.instance.updateProfile(
          name: data['name']?.toString() ?? currentUser.displayName ?? 'Foodie',
          email: data['email']?.toString() ?? currentUser.email ?? '',
          phone: data['phone']?.toString() ?? currentUser.phoneNumber ?? '',
          addressTag: data['addressTag']?.toString() ?? 'Home',
          addressLine1: data['addressLine1']?.toString() ?? '',
          addressLine2: data['addressLine2']?.toString() ?? '',
          landmark: data['landmark']?.toString() ?? '',
          profileImagePath: data['profileImagePath']?.toString() ?? 'assets/images/logo.png',
          isNewAccount: false,
        );
        debugPrint("☁️ Successfully restored saved Cloud profile for ${currentUser.email}!");
      }
    } catch (e) {
      debugPrint("⚠️ Could not fetch user profile from cloud: $e");
    }
  }

  /// STEP 3: Push New Order to Firestore collection `orders`
  Future<void> pushOrderToCloud(OrderModel order) async {
    if (!_isFirebaseInitialized) return;
    try {
      await _db.collection('orders').doc(order.orderId).set({
        'orderId': order.orderId,
        'orderDate': order.orderDate.toIso8601String(),
        'items': order.items.map((item) => {
          'id': item.foodItem.id,
          'name': item.foodItem.name,
          'price': item.foodItem.price,
          'quantity': item.quantity,
        }).toList(),
        'subtotal': order.subtotal,
        'discount': order.discount,
        'deliveryFee': order.deliveryFee,
        'total': order.total,
        'status': order.status.name,
        'deliveryAddress': order.deliveryAddress,
        'paymentMethod': order.paymentMethod,
        'paymentStatus': order.paymentStatus,
        'transactionId': order.transactionId,
        'createdAt': FieldValue.serverTimestamp(),
      });
      debugPrint("🚀 Order ${order.orderId} pushed live to Cloud Firestore!");
    } catch (e) {
      debugPrint("⚠️ Could not push order to Cloud Firestore: $e");
    }
  }

  /// STEP 4: Stream Order Updates Live from Firestore
  Stream<String?> listenToOrderStatus(String orderId) {
    if (!_isFirebaseInitialized) return const Stream.empty();
    return _db.collection('orders').doc(orderId).snapshots().map((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        return snapshot.data()!['status'] as String?;
      }
      return null;
    });
  }

  /// STEP 5: Update Order Status in Cloud Firestore
  Future<void> updateOrderStatusInCloud(String orderId, String newStatus) async {
    if (!_isFirebaseInitialized) return;
    try {
      await _db.collection('orders').doc(orderId).update({
        'status': newStatus,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      debugPrint("⚡ Order $orderId status updated to $newStatus in Cloud!");
    } catch (e) {
      debugPrint("⚠️ Could not update order status in cloud: $e");
    }
  }

  /// STEP 6: Seed Menu Dishes Batch to Cloud Firestore
  Future<void> seedMenuDishes(List<FoodItem> dishes) async {
    if (!_isFirebaseInitialized) return;
    try {
      final batch = _db.batch();
      for (var item in dishes) {
        final docRef = _db.collection('dishes').doc(item.id.isNotEmpty ? item.id : item.name);
        batch.set(docRef, {
          'id': item.id,
          'name': item.name,
          'category': item.category,
          'rating': item.rating,
          'price': item.price,
          'description': item.description,
          'imagePath': item.imagePath,
        }, SetOptions(merge: true));
      }
      await batch.commit();
      debugPrint("🍲 Seeded ${dishes.length} gourmet dishes to Cloud Firestore!");
    } catch (e) {
      debugPrint("⚠️ Error seeding dishes: $e");
    }
  }

  /// STEP 6B: Stream Live Online Menu Updates from Cloud Firestore
  Stream<List<FoodItem>> streamLiveMenuFromCloud() {
    if (!_isFirebaseInitialized) return const Stream.empty();
    return _db.collection('dishes').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return FoodItem(
          id: data['id'] ?? doc.id,
          name: data['name'] ?? 'Gourmet Dish',
          priceString: '₹${data['price'] ?? 199}',
          price: (data['price'] as num?)?.toDouble() ?? 199.0,
          imagePath: data['imagePath'] ?? 'assets/images/logo.png',
          category: data['category'] ?? 'Biriyani',
          rating: (data['rating'] as num?)?.toDouble() ?? 4.8,
          description: data['description'] ?? 'Piping hot gourmet dish.',
        );
      }).toList();
    });
  }

  /// STEP 7: Upload User Profile Photo to Firebase Cloud Storage
  Future<String?> uploadProfilePhotoToStorage(String localFilePath) async {
    if (!_isFirebaseInitialized) return null;
    try {
      final file = File(localFilePath);
      if (!file.existsSync()) return null;

      final userId = AuthService.instance.currentUser?.uid ?? 'guest_user';
      final fileName = 'avatar_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = FirebaseStorage.instance.ref().child('user_avatars').child(userId).child(fileName);

      final uploadTask = await ref.putFile(file);
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      debugPrint("📸 Profile photo uploaded to Cloud Storage! URL: $downloadUrl");
      return downloadUrl;
    } catch (e) {
      debugPrint("⚠️ Cloud Storage upload notice: $e");
      return null;
    }
  }

  /// STEP 8: Sync User Favorites to Cloud Firestore
  Future<void> syncFavoriteDishToCloud(FoodItem item, bool isFav) async {
    if (!_isFirebaseInitialized) return;
    try {
      final userId = AuthService.instance.currentUser?.uid ?? 'guest_user';
      final favDocRef = _db.collection('users').doc(userId).collection('favorites').doc(item.id.isNotEmpty ? item.id : item.name);

      if (isFav) {
        await favDocRef.set({
          'id': item.id,
          'name': item.name,
          'category': item.category,
          'price': item.price,
          'rating': item.rating,
          'imagePath': item.imagePath,
          'description': item.description,
          'savedAt': FieldValue.serverTimestamp(),
        });
        debugPrint("❤️ Added ${item.name} to Cloud Firestore favorites!");
      } else {
        await favDocRef.delete();
        debugPrint("🤍 Removed ${item.name} from Cloud Firestore favorites!");
      }
    } catch (e) {
      debugPrint("⚠️ Cloud Favorites sync notice: $e");
    }
  }

  /// STEP 9: Fetch User Favorites from Cloud Firestore
  Future<List<FoodItem>> fetchUserFavoritesFromCloud() async {
    if (!_isFirebaseInitialized) return [];
    try {
      final userId = AuthService.instance.currentUser?.uid ?? 'guest_user';
      final snapshot = await _db.collection('users').doc(userId).collection('favorites').get();

      final list = snapshot.docs.map((doc) {
        final data = doc.data();
        return FoodItem(
          id: data['id'] ?? doc.id,
          name: data['name'] ?? '',
          priceString: '₹${(data['price'] as num?)?.toStringAsFixed(0) ?? "180"}',
          price: (data['price'] as num?)?.toDouble() ?? 15.0,
          category: data['category'] ?? 'Biryani',
          rating: (data['rating'] as num?)?.toDouble() ?? 4.5,
          imagePath: data['imagePath'] ?? 'assets/images/logo.png',
          description: data['description'] ?? '',
        );
      }).toList();

      debugPrint("❤️ Fetched ${list.length} favorites from Cloud Firestore!");
      return list;
    } catch (e) {
      debugPrint("⚠️ Could not fetch favorites from cloud: $e");
      return [];
    }
  }

  /// STEP 10: Save FCM Push Notification Device Token to Cloud Firestore
  Future<void> saveFcmTokenToCloud(String token) async {
    if (!_isFirebaseInitialized) return;
    try {
      final userId = AuthService.instance.currentUser?.uid ?? 'guest_user';
      await _db.collection('users').doc(userId).set({
        'fcmToken': token,
        'notificationsEnabled': true,
        'lastTokenUpdate': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      debugPrint("🔔 FCM Device Token saved to Cloud Firestore for user $userId!");
    } catch (e) {
      debugPrint("⚠️ Could not save FCM token to cloud: $e");
    }
  }

  /// STEP 11: Push Notification to Cloud Firestore Feed
  Future<void> pushNotificationToCloudFeed({
    required String title,
    required String body,
    required String type,
    String? orderId,
  }) async {
    if (!_isFirebaseInitialized) return;
    try {
      final userId = AuthService.instance.currentUser?.uid ?? 'guest_user';
      await _db.collection('users').doc(userId).collection('notifications').add({
        'title': title,
        'body': body,
        'type': type,
        'orderId': orderId ?? '',
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
      debugPrint("🔔 Notification pushed live to Cloud Firestore Feed!");
    } catch (e) {
      debugPrint("⚠️ Cloud Notification Feed notice: $e");
    }
  }
}
