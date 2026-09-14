import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'firebase_manager.dart';

class DriverGpsModel {
  final String driverName;
  final String driverPhone;
  final double rating;
  final String vehicleNumber;
  final double latitude;
  final double longitude;
  final double progress; // 0.0 to 1.0 along route
  final int etaMinutes;
  final String statusText;

  DriverGpsModel({
    required this.driverName,
    required this.driverPhone,
    required this.rating,
    required this.vehicleNumber,
    required this.latitude,
    required this.longitude,
    required this.progress,
    required this.etaMinutes,
    required this.statusText,
  });

  factory DriverGpsModel.fromMap(Map<String, dynamic> map) {
    return DriverGpsModel(
      driverName: map['driverName'] ?? 'Rahul Verma 🛵',
      driverPhone: map['driverPhone'] ?? '+91 98765 43210',
      rating: (map['rating'] as num?)?.toDouble() ?? 4.9,
      vehicleNumber: map['vehicleNumber'] ?? 'TS 09 EV 4821',
      latitude: (map['latitude'] as num?)?.toDouble() ?? 17.4435,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 78.3772,
      progress: (map['progress'] as num?)?.toDouble() ?? 0.2,
      etaMinutes: (map['etaMinutes'] as num?)?.toInt() ?? 12,
      statusText: map['statusText'] ?? 'Heading to restaurant 👨‍🍳',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'driverName': driverName,
      'driverPhone': driverPhone,
      'rating': rating,
      'vehicleNumber': vehicleNumber,
      'latitude': latitude,
      'longitude': longitude,
      'progress': progress,
      'etaMinutes': etaMinutes,
      'statusText': statusText,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}

class LiveDriverGpsService {
  static final LiveDriverGpsService instance = LiveDriverGpsService._internal();

  LiveDriverGpsService._internal();

  FirebaseFirestore get _db => FirebaseFirestore.instance;

  final Map<String, Timer> _activeSimulations = {};

  // Restaurant Kitchen Location: Jubilee Hills, Hyderabad (17.4325, 78.4072)
  static const double kitchenLat = 17.4325;
  static const double kitchenLng = 78.4072;

  // Customer Home Location: Madhapur, Hyderabad (17.4485, 78.3802)
  static const double customerLat = 17.4485;
  static const double customerLng = 78.3802;

  /// 🛰️ 1. Stream Live Driver GPS Location from Cloud Firestore
  Stream<DriverGpsModel?> streamDriverGps(String orderId) {
    if (!FirebaseManager.instance.isFirebaseInitialized) return const Stream.empty();
    return _db
        .collection('orders')
        .doc(orderId)
        .collection('driver_gps')
        .doc('live')
        .snapshots()
        .map((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        return DriverGpsModel.fromMap(snapshot.data()!);
      }
      return DriverGpsModel(
        driverName: 'Rahul Verma 🛵',
        driverPhone: '+91 98765 43210',
        rating: 4.9,
        vehicleNumber: 'TS 09 EV 4821',
        latitude: kitchenLat,
        longitude: kitchenLng,
        progress: 0.15,
        etaMinutes: 14,
        statusText: 'Rider assigned! Heading to kitchen 👨‍🍳',
      );
    });
  }

  /// 🛰️ 2. Start Real-time Simulated Driver GPS Movement to Cloud Firestore
  void startDriverGpsSimulation(String orderId) {
    _activeSimulations[orderId]?.cancel();

    double currentProgress = 0.05;

    _activeSimulations[orderId] = Timer.periodic(const Duration(seconds: 4), (timer) async {
      currentProgress += 0.08;

      if (currentProgress >= 1.0) {
        currentProgress = 1.0;
        timer.cancel();
        _activeSimulations.remove(orderId);
      }

      // Calculate current lat/lng along straight-line route
      final curLat = kitchenLat + (customerLat - kitchenLat) * currentProgress;
      final curLng = kitchenLng + (customerLng - kitchenLng) * currentProgress;
      final remainingMins = ((1.0 - currentProgress) * 15).round().clamp(1, 15);

      String statusMsg;
      if (currentProgress < 0.25) {
        statusMsg = 'Rider Rahul is picking up your order from kitchen 👨‍🍳';
      } else if (currentProgress < 0.85) {
        statusMsg = 'Rider Rahul is driving on route to your delivery address 🛵💨';
      } else {
        statusMsg = 'Rider Rahul is nearby! Arriving at your doorstep 📍';
      }

      final gpsData = DriverGpsModel(
        driverName: 'Rahul Verma 🛵',
        driverPhone: '+91 98765 43210',
        rating: 4.9,
        vehicleNumber: 'TS 09 EV 4821',
        latitude: curLat,
        longitude: curLng,
        progress: currentProgress,
        etaMinutes: remainingMins,
        statusText: statusMsg,
      );

      try {
        if (FirebaseManager.instance.isFirebaseInitialized) {
          await _db
              .collection('orders')
              .doc(orderId)
              .collection('driver_gps')
              .doc('live')
              .set(gpsData.toMap(), SetOptions(merge: true));
          debugPrint("🛰️ Updated Driver GPS for #$orderId: Lat $curLat, Lng $curLng (${(currentProgress * 100).toInt()}%)");
        }
      } catch (e) {
        debugPrint("⚠️ Driver GPS update notice: $e");
      }
    });
  }

  /// 🛰️ 3. Stop Simulation
  void stopSimulation(String orderId) {
    _activeSimulations[orderId]?.cancel();
    _activeSimulations.remove(orderId);
  }
}
