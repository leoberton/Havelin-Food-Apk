import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../managers/coupon_manager.dart';
import 'firebase_manager.dart';

class CouponValidationResult {
  final bool isValid;
  final String message;
  final Coupon? coupon;
  final double discountAmount;

  CouponValidationResult({
    required this.isValid,
    required this.message,
    this.coupon,
    this.discountAmount = 0.0,
  });
}

class CouponBackendService {
  static final CouponBackendService instance = CouponBackendService._internal();

  CouponBackendService._internal();

  FirebaseFirestore get _db => FirebaseFirestore.instance;

  /// 🎟️ Validate Coupon Server-Side via Cloud Firestore
  Future<CouponValidationResult> validateCouponInCloud({
    required String code,
    required double cartSubtotal,
  }) async {
    final cleanCode = code.trim().toUpperCase();

    // Fallback to local CouponManager if Firebase offline
    final Coupon? localCoupon = CouponManager.instance.availableCoupons.firstWhere(
      (c) => c.code.toUpperCase() == cleanCode,
      orElse: () => const Coupon(
        code: '',
        title: '',
        description: '',
        discountPercent: 0,
        flatDiscount: 0,
        minOrderAmount: 0,
      ),
    );

    if (!FirebaseManager.instance.isFirebaseInitialized || localCoupon?.code.isNotEmpty == true) {
      if (localCoupon == null || localCoupon.code.isEmpty) {
        return CouponValidationResult(isValid: false, message: 'Invalid promo code! ❌');
      }
      if (cartSubtotal < localCoupon.minOrderAmount) {
        return CouponValidationResult(
          isValid: false,
          message: 'Min order value of ₹${localCoupon.minOrderAmount.toStringAsFixed(0)} required for ${localCoupon.code}!',
        );
      }
      final discount = localCoupon.flatDiscount > 0
          ? localCoupon.flatDiscount
          : (cartSubtotal * localCoupon.discountPercent);

      return CouponValidationResult(
        isValid: true,
        message: 'Coupon ${localCoupon.code} applied! Saved ₹${discount.toStringAsFixed(0)} 🎉',
        coupon: localCoupon,
        discountAmount: discount,
      );
    }

    try {
      final snapshot = await _db.collection('coupons').doc(cleanCode).get();

      if (!snapshot.exists || snapshot.data() == null) {
        return CouponValidationResult(isValid: false, message: 'Invalid promo code! ❌');
      }

      final data = snapshot.data()!;
      final isActive = data['isActive'] ?? true;
      final minOrder = (data['minOrderAmount'] as num?)?.toDouble() ?? 299.0;
      final flatDisc = (data['flatDiscount'] as num?)?.toDouble() ?? 0.0;
      final percDisc = (data['discountPercent'] as num?)?.toDouble() ?? 0.0;

      if (!isActive) {
        return CouponValidationResult(isValid: false, message: 'This promo code has expired! ⚠️');
      }

      if (cartSubtotal < minOrder) {
        return CouponValidationResult(
          isValid: false,
          message: 'Add items worth ₹${(minOrder - cartSubtotal).toStringAsFixed(0)} more to apply $cleanCode!',
        );
      }

      final discount = flatDisc > 0 ? flatDisc : (cartSubtotal * percDisc);

      final appliedCoupon = Coupon(
        code: cleanCode,
        title: data['title'] ?? 'Special Promo Discount',
        description: data['description'] ?? 'Saved ₹${discount.toStringAsFixed(0)} on this order',
        discountPercent: percDisc,
        flatDiscount: flatDisc,
        minOrderAmount: minOrder,
      );

      return CouponValidationResult(
        isValid: true,
        message: 'Coupon $cleanCode applied! Saved ₹${discount.toStringAsFixed(0)} 🎉',
        coupon: appliedCoupon,
        discountAmount: discount,
      );
    } catch (e) {
      debugPrint("⚠️ Coupon validation error: $e");
      return CouponValidationResult(isValid: false, message: 'Could not verify promo code.');
    }
  }
}
