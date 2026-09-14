import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'notification_manager.dart';

class ChatMessageModel {
  final String messageId;
  final String orderId;
  final String senderId;
  final String senderName;
  final String senderRole; // 'customer' | 'rider' | 'kitchen'
  final String text;
  final DateTime timestamp;
  final bool isRead;

  ChatMessageModel({
    required this.messageId,
    required this.orderId,
    required this.senderId,
    required this.senderName,
    required this.senderRole,
    required this.text,
    required this.timestamp,
    this.isRead = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'messageId': messageId,
      'orderId': orderId,
      'senderId': senderId,
      'senderName': senderName,
      'senderRole': senderRole,
      'text': text,
      'timestamp': Timestamp.fromDate(timestamp),
      'isRead': isRead,
    };
  }

  factory ChatMessageModel.fromMap(Map<String, dynamic> map) {
    DateTime parsedDate;
    final ts = map['timestamp'];
    if (ts is Timestamp) {
      parsedDate = ts.toDate();
    } else if (ts is String) {
      parsedDate = DateTime.tryParse(ts) ?? DateTime.now();
    } else {
      parsedDate = DateTime.now();
    }

    return ChatMessageModel(
      messageId: map['messageId']?.toString() ?? '',
      orderId: map['orderId']?.toString() ?? '',
      senderId: map['senderId']?.toString() ?? '',
      senderName: map['senderName']?.toString() ?? 'User',
      senderRole: map['senderRole']?.toString() ?? 'customer',
      text: map['text']?.toString() ?? '',
      timestamp: parsedDate,
      isRead: map['isRead'] == true,
    );
  }
}

class SupportChatService {
  static final SupportChatService instance = SupportChatService._internal();

  SupportChatService._internal();

  /// 💬 Send Chat Message to Cloud Firestore `support_chats/{orderId}/messages/{messageId}`
  Future<bool> sendMessage({
    required String orderId,
    required String senderId,
    required String senderName,
    required String senderRole,
    required String text,
  }) async {
    final timestamp = DateTime.now();
    final messageId = "MSG_${timestamp.millisecondsSinceEpoch}";

    final message = ChatMessageModel(
      messageId: messageId,
      orderId: orderId,
      senderId: senderId,
      senderName: senderName,
      senderRole: senderRole,
      text: text,
      timestamp: timestamp,
    );

    try {
      final db = FirebaseFirestore.instance;
      await db
          .collection('support_chats')
          .doc(orderId)
          .collection('messages')
          .doc(messageId)
          .set(message.toMap());

      // If message is from Rider/Kitchen, notify customer
      if (senderRole != 'customer') {
        NotificationManager.instance.showNotification(
          title: "New Message from $senderName 💬",
          body: text,
        );
      }

      return true;
    } catch (e) {
      debugPrint("Cloud Support Chat Send Note: $e");
      return false;
    }
  }

  /// 📡 Stream Real-Time Chat Messages for an Order
  Stream<List<ChatMessageModel>> streamChatMessages(String orderId) {
    try {
      final db = FirebaseFirestore.instance;
      return db
          .collection('support_chats')
          .doc(orderId)
          .collection('messages')
          .orderBy('timestamp', descending: false)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) => ChatMessageModel.fromMap(doc.data())).toList();
      });
    } catch (e) {
      debugPrint("Stream Chat Messages Note: $e");
      return Stream.value([]);
    }
  }
}
