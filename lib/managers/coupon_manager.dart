import 'package:flutter/material.dart';

class Coupon {
  final String code;
  final String title;
  final String description;
  final double discountPercent; // e.g. 0.30 for 30%
  final double flatDiscount; // e.g. 5.0 for $5 off
  final double minOrderAmount;

  const Coupon({
    required this.code,
    required this.title,
    required this.description,
    this.discountPercent = 0.0,
    this.flatDiscount = 0.0,
    this.minOrderAmount = 0.0,
  });
}

class CouponManager extends ValueNotifier<Coupon?> {
  static final CouponManager instance = CouponManager._internal();

  CouponManager._internal() : super(null);

  final List<Coupon> availableCoupons = const [
    Coupon(
      code: 'HAVELIN30',
      title: '30% OFF First Order',
      description: 'Get 30% discount on orders above ₹299',
      discountPercent: 0.30,
      minOrderAmount: 299.0,
    ),
    Coupon(
      code: 'WEEKEND20',
      title: '20% OFF Weekend Special',
      description: 'Save 20% on all pizzas & burgers above ₹199',
      discountPercent: 0.20,
      minOrderAmount: 199.0,
    ),
    Coupon(
      code: 'FREEDEL',
      title: 'Free Delivery',
      description: 'Flat ₹30 off delivery fee',
      flatDiscount: 30.0,
      minOrderAmount: 0.0,
    ),
  ];

  bool applyCoupon(String code, double currentSubtotal) {
    final coupon = availableCoupons.firstWhere(
      (c) => c.code.toUpperCase() == code.trim().toUpperCase(),
      orElse: () => const Coupon(code: '', title: '', description: ''),
    );

    if (coupon.code.isEmpty) return false;
    if (currentSubtotal < coupon.minOrderAmount) return false;

    value = coupon;
    return true;
  }

  void removeCoupon() {
    value = null;
  }

  double calculateDiscount(double subtotal) {
    if (value == null) return 0.0;
    if (value!.discountPercent > 0) {
      return subtotal * value!.discountPercent;
    }
    return value!.flatDiscount;
  }
}
