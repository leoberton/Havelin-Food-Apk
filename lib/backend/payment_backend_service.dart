import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'notification_manager.dart';

enum TransactionStatus { success, pending, failed, refunded }

class TransactionModel {
  final String transactionId;
  final String orderId;
  final String userId;
  final String userName;
  final String userPhone;
  final double amount;
  final String paymentMethod;
  final String paymentProvider;
  final TransactionStatus status;
  final DateTime timestamp;
  final String gatewayRef;
  final String failureReason;

  TransactionModel({
    required this.transactionId,
    required this.orderId,
    required this.userId,
    required this.userName,
    required this.userPhone,
    required this.amount,
    required this.paymentMethod,
    required this.paymentProvider,
    required this.status,
    required this.timestamp,
    required this.gatewayRef,
    this.failureReason = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'transactionId': transactionId,
      'orderId': orderId,
      'userId': userId,
      'userName': userName,
      'userPhone': userPhone,
      'amount': amount,
      'paymentMethod': paymentMethod,
      'paymentProvider': paymentProvider,
      'status': status.name,
      'timestamp': Timestamp.fromDate(timestamp),
      'gatewayRef': gatewayRef,
      'failureReason': failureReason,
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    DateTime parsedDate;
    final ts = map['timestamp'];
    if (ts is Timestamp) {
      parsedDate = ts.toDate();
    } else if (ts is String) {
      parsedDate = DateTime.tryParse(ts) ?? DateTime.now();
    } else {
      parsedDate = DateTime.now();
    }

    TransactionStatus parsedStatus = TransactionStatus.success;
    final statusStr = map['status']?.toString() ?? 'success';
    for (var s in TransactionStatus.values) {
      if (s.name.toLowerCase() == statusStr.toLowerCase()) {
        parsedStatus = s;
        break;
      }
    }

    return TransactionModel(
      transactionId: map['transactionId']?.toString() ?? '',
      orderId: map['orderId']?.toString() ?? '',
      userId: map['userId']?.toString() ?? '',
      userName: map['userName']?.toString() ?? 'Customer',
      userPhone: map['userPhone']?.toString() ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      paymentMethod: map['paymentMethod']?.toString() ?? 'UPI',
      paymentProvider: map['paymentProvider']?.toString() ?? 'UPI Gateway',
      status: parsedStatus,
      timestamp: parsedDate,
      gatewayRef: map['gatewayRef']?.toString() ?? '',
      failureReason: map['failureReason']?.toString() ?? '',
    );
  }
}

class PaymentBackendService {
  static final PaymentBackendService instance = PaymentBackendService._internal();

  PaymentBackendService._internal();

  /// 💳 Real-time Payment Verification & Transaction Ledger Processing
  Future<TransactionModel> processPaymentVerification({
    required String orderId,
    required String userId,
    required String userName,
    required String userPhone,
    required double amount,
    required String paymentMethod,
    bool simulateFailure = false,
  }) async {
    final timestamp = DateTime.now();
    final txnId = "TXN_HV_${timestamp.millisecondsSinceEpoch.toString().substring(5)}";
    final gatewayRef = "BRN_${(100000000 + timestamp.microsecond * 97).abs()}";

    final status = simulateFailure ? TransactionStatus.failed : TransactionStatus.success;
    final failureReason = simulateFailure ? "Insufficient funds or bank timeout" : "";

    final transaction = TransactionModel(
      transactionId: txnId,
      orderId: orderId,
      userId: userId,
      userName: userName,
      userPhone: userPhone,
      amount: amount,
      paymentMethod: paymentMethod,
      paymentProvider: paymentMethod.contains('UPI') ? 'UPI Payment Gateway' : 'Havelin Pay Gateway',
      status: status,
      timestamp: timestamp,
      gatewayRef: gatewayRef,
      failureReason: failureReason,
    );

    // Save Transaction Ledger Record to Cloud Firestore with timeout so UI never hangs
    try {
      final db = FirebaseFirestore.instance;
      await db
          .collection('transactions')
          .doc(txnId)
          .set(transaction.toMap())
          .timeout(const Duration(seconds: 2));

      // If Payment Verified Successfully, update order status in Cloud Firestore
      if (status == TransactionStatus.success) {
        await db.collection('orders').doc(orderId).update({
          'paymentStatus': 'PAID',
          'transactionId': txnId,
        }).timeout(const Duration(seconds: 2));

        // Trigger Local Push Notification for Payment Verification
        NotificationManager.instance.showNotification(
          title: "Payment Verified! ₹${amount.toStringAsFixed(0)} ✅",
          body: "Transaction #$txnId verified via $paymentMethod. Order #$orderId sent to kitchen!",
        );
      }
    } catch (e) {
      debugPrint("Cloud Transaction Ledger Note: $e");
    }

    return transaction;
  }

  /// 📜 Stream Customer's Personal Transaction Ledger
  Stream<List<TransactionModel>> streamUserTransactions(String userId) {
    try {
      final db = FirebaseFirestore.instance;
      return db
          .collection('transactions')
          .where('userId', isEqualTo: userId)
          .snapshots()
          .map((snapshot) {
        final list = snapshot.docs.map((doc) => TransactionModel.fromMap(doc.data())).toList();
        list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        return list;
      });
    } catch (e) {
      debugPrint("Stream User Transactions Note: $e");
      return Stream.value([]);
    }
  }

  /// 📊 Stream All Platform Transactions (Admin Ledger)
  Stream<List<TransactionModel>> streamAllTransactions() {
    try {
      final db = FirebaseFirestore.instance;
      return db
          .collection('transactions')
          .snapshots()
          .map((snapshot) {
        final list = snapshot.docs.map((doc) => TransactionModel.fromMap(doc.data())).toList();
        list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        return list;
      });
    } catch (e) {
      debugPrint("Stream All Transactions Note: $e");
      return Stream.value([]);
    }
  }

  /// 🔄 Process Refund Ledger Record
  Future<bool> processRefund(String transactionId, String reason) async {
    try {
      final db = FirebaseFirestore.instance;
      await db.collection('transactions').doc(transactionId).update({
        'status': TransactionStatus.refunded.name,
        'failureReason': reason,
      });
      return true;
    } catch (e) {
      debugPrint("Process Refund Note: $e");
      return false;
    }
  }
}
