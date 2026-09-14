import 'dart:math' as math;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../managers/user_manager.dart';

class AddressModel {
  final String id;
  final String tag; // 'Home', 'Work', 'Office', 'Other'
  final String receiverName;
  final String receiverPhone;
  final String addressLine1;
  final String addressLine2;
  final String city;
  final String pincode;
  final double latitude;
  final double longitude;
  final bool isDefault;

  AddressModel({
    required this.id,
    required this.tag,
    required this.receiverName,
    required this.receiverPhone,
    required this.addressLine1,
    required this.addressLine2,
    this.city = 'Hyderabad',
    this.pincode = '500081',
    this.latitude = 17.4485,
    this.longitude = 78.3802,
    this.isDefault = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tag': tag,
      'receiverName': receiverName,
      'receiverPhone': receiverPhone,
      'addressLine1': addressLine1,
      'addressLine2': addressLine2,
      'city': city,
      'pincode': pincode,
      'latitude': latitude,
      'longitude': longitude,
      'isDefault': isDefault,
    };
  }

  factory AddressModel.fromMap(Map<String, dynamic> map) {
    return AddressModel(
      id: map['id']?.toString() ?? '',
      tag: map['tag']?.toString() ?? 'Home',
      receiverName: map['receiverName']?.toString() ?? '',
      receiverPhone: map['receiverPhone']?.toString() ?? '',
      addressLine1: map['addressLine1']?.toString() ?? '',
      addressLine2: map['addressLine2']?.toString() ?? '',
      city: map['city']?.toString() ?? 'Hyderabad',
      pincode: map['pincode']?.toString() ?? '500081',
      latitude: (map['latitude'] as num?)?.toDouble() ?? 17.4485,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 78.3802,
      isDefault: map['isDefault'] == true,
    );
  }
}

class DeliveryCalculationResult {
  final double distanceKm;
  final double deliveryFee;
  final int estimatedMinutes;
  final String distanceFormatted;

  DeliveryCalculationResult({
    required this.distanceKm,
    required this.deliveryFee,
    required this.estimatedMinutes,
    required this.distanceFormatted,
  });
}

class AddressBackendService {
  static final AddressBackendService instance = AddressBackendService._internal();

  AddressBackendService._internal();

  // Kitchen Central Coordinates (Jubilee Hills, Hyderabad)
  static const double kitchenLat = 17.4325;
  static const double kitchenLng = 78.4072;

  /// 📍 Save or Update Address in Cloud Firestore `users/{userId}/addresses/{addressId}`
  Future<bool> saveAddress(String userId, AddressModel address) async {
    try {
      final db = FirebaseFirestore.instance;
      final effectiveUserId = userId.isNotEmpty ? userId : 'USER_GUEST';
      final addrRef = db.collection('users').doc(effectiveUserId).collection('addresses').doc(address.id);

      // If this address is set as default, unset default on other addresses
      if (address.isDefault) {
        final allAddrDocs = await db.collection('users').doc(effectiveUserId).collection('addresses').get();
        for (var doc in allAddrDocs.docs) {
          if (doc.id != address.id) {
            await doc.reference.update({'isDefault': false});
          }
        }

        // Sync with primary UserManager state
        UserManager.instance.updateAddress(
          tag: address.tag,
          line1: address.addressLine1,
          line2: address.addressLine2,
          landmark: address.city,
        );
      }

      await addrRef.set(address.toMap(), SetOptions(merge: true));
      return true;
    } catch (e) {
      debugPrint("Cloud Address Save Note: $e");
      return false;
    }
  }

  /// ⭐ Set Primary Default Address in Cloud Firestore
  Future<bool> setDefaultAddress(String userId, String addressId) async {
    try {
      final db = FirebaseFirestore.instance;
      final effectiveUserId = userId.isNotEmpty ? userId : 'USER_GUEST';
      final addressesCol = db.collection('users').doc(effectiveUserId).collection('addresses');

      final snapshot = await addressesCol.get();
      AddressModel? targetAddr;

      for (var doc in snapshot.docs) {
        final isTarget = (doc.id == addressId);
        await doc.reference.update({'isDefault': isTarget});
        if (isTarget) {
          targetAddr = AddressModel.fromMap(doc.data());
        }
      }

      if (targetAddr != null) {
        UserManager.instance.updateAddress(
          tag: targetAddr.tag,
          line1: targetAddr.addressLine1,
          line2: targetAddr.addressLine2,
          landmark: targetAddr.city,
        );
      }

      return true;
    } catch (e) {
      debugPrint("Set Default Address Note: $e");
      return false;
    }
  }

  /// 🗑️ Delete Address from Cloud Firestore
  Future<bool> deleteAddress(String userId, String addressId) async {
    try {
      final db = FirebaseFirestore.instance;
      final effectiveUserId = userId.isNotEmpty ? userId : 'USER_GUEST';
      await db.collection('users').doc(effectiveUserId).collection('addresses').doc(addressId).delete();
      return true;
    } catch (e) {
      debugPrint("Delete Address Note: $e");
      return false;
    }
  }

  /// 📡 Stream Saved Addresses from Cloud Firestore
  Stream<List<AddressModel>> streamUserAddresses(String userId) {
    try {
      final db = FirebaseFirestore.instance;
      final effectiveUserId = userId.isNotEmpty ? userId : 'USER_GUEST';
      return db
          .collection('users')
          .doc(effectiveUserId)
          .collection('addresses')
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) => AddressModel.fromMap(doc.data())).toList();
      });
    } catch (e) {
      debugPrint("Stream Addresses Note: $e");
      return Stream.value([]);
    }
  }

  /// 📏 Calculate Geo-Distance (Haversine Formula), Delivery Fee & Time
  DeliveryCalculationResult calculateDeliveryDetails({
    required double userLat,
    required double userLng,
    required double subtotal,
  }) {
    // Haversine Formula for distance between kitchen and delivery location
    final dLat = (kitchenLat - userLat) * math.pi / 180.0;
    final dLng = (kitchenLng - userLng) * math.pi / 180.0;

    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(userLat * math.pi / 180.0) *
            math.cos(kitchenLat * math.pi / 180.0) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);

    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    const earthRadiusKm = 6371.0;
    final distanceKm = double.parse((earthRadiusKm * c).toStringAsFixed(1));

    // Dynamic Delivery Fee Pricing Rules
    double deliveryFee = 30.0;
    if (subtotal >= 299.0) {
      deliveryFee = 0.0; // Free delivery for orders above ₹299
    } else if (distanceKm < 3.0) {
      deliveryFee = 20.0;
    } else if (distanceKm <= 7.0) {
      deliveryFee = 35.0;
    } else {
      deliveryFee = 50.0;
    }

    // Estimated Delivery Time (15m Prep + 3m per km)
    final estMinutes = (15 + (distanceKm * 3.0)).round();

    return DeliveryCalculationResult(
      distanceKm: distanceKm,
      deliveryFee: deliveryFee,
      estimatedMinutes: estMinutes,
      distanceFormatted: "$distanceKm km",
    );
  }
}
