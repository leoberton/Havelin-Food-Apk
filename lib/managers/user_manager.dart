import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../backend/firebase_manager.dart';

class UserData {
  final String name;
  final String email;
  final String phone;
  final String addressTag;
  final String addressLine1;
  final String addressLine2;
  final String landmark;
  final String profileImagePath;
  final bool isAddressConfigured;
  final bool isNewAccount;

  UserData({
    this.name = 'Alex Morgan',
    this.email = 'alex.morgan@example.com',
    this.phone = '+1 (555) 234-5678',
    this.addressTag = 'Home',
    this.addressLine1 = '123 Gourmet Street, Suite 400',
    this.addressLine2 = 'New York, NY 10001',
    this.landmark = 'Near Central Park',
    this.profileImagePath = 'assets/images/logo.png',
    this.isAddressConfigured = false,
    this.isNewAccount = false,
  });

  UserData copyWith({
    String? name,
    String? email,
    String? phone,
    String? addressTag,
    String? addressLine1,
    String? addressLine2,
    String? landmark,
    String? profileImagePath,
    bool? isAddressConfigured,
    bool? isNewAccount,
  }) {
    return UserData(
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      addressTag: addressTag ?? this.addressTag,
      addressLine1: addressLine1 ?? this.addressLine1,
      addressLine2: addressLine2 ?? this.addressLine2,
      landmark: landmark ?? this.landmark,
      profileImagePath: profileImagePath ?? this.profileImagePath,
      isAddressConfigured: isAddressConfigured ?? this.isAddressConfigured,
      isNewAccount: isNewAccount ?? this.isNewAccount,
    );
  }
}

class UserManager extends ValueNotifier<UserData> {
  static final UserManager instance = UserManager._internal();

  UserManager._internal() : super(UserData()) {
    loadLocalProfile();
  }

  Future<void> loadLocalProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedName = prefs.getString('user_name');
      final savedEmail = prefs.getString('user_email');
      final savedPhone = prefs.getString('user_phone');
      final savedTag = prefs.getString('user_address_tag');
      final savedLine1 = prefs.getString('user_address_line1');
      final savedLine2 = prefs.getString('user_address_line2');
      final savedLandmark = prefs.getString('user_landmark');
      final savedImg = prefs.getString('user_profile_img');
      final savedIsConfig = prefs.getBool('user_is_address_config');

      if (savedName != null || savedLine1 != null || savedImg != null) {
        value = UserData(
          name: savedName ?? value.name,
          email: savedEmail ?? value.email,
          phone: savedPhone ?? value.phone,
          addressTag: savedTag ?? value.addressTag,
          addressLine1: savedLine1 ?? value.addressLine1,
          addressLine2: savedLine2 ?? value.addressLine2,
          landmark: savedLandmark ?? value.landmark,
          profileImagePath: savedImg ?? value.profileImagePath,
          isAddressConfigured: savedIsConfig ?? value.isAddressConfigured,
        );
      }
    } catch (e) {
      debugPrint("Local profile load note: $e");
    }
  }

  Future<void> saveLocalProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_name', value.name);
      await prefs.setString('user_email', value.email);
      await prefs.setString('user_phone', value.phone);
      await prefs.setString('user_address_tag', value.addressTag);
      await prefs.setString('user_address_line1', value.addressLine1);
      await prefs.setString('user_address_line2', value.addressLine2);
      await prefs.setString('user_landmark', value.landmark);
      await prefs.setString('user_profile_img', value.profileImagePath);
      await prefs.setBool('user_is_address_config', value.isAddressConfigured);
    } catch (e) {
      debugPrint("Local profile save note: $e");
    }
  }

  void updateProfile({
    String? name,
    String? email,
    String? phone,
    String? addressTag,
    String? addressLine1,
    String? addressLine2,
    String? landmark,
    String? profileImagePath,
    bool? isNewAccount,
  }) {
    value = value.copyWith(
      name: (name != null && name.trim().isNotEmpty) ? name.trim() : null,
      email: (email != null && email.trim().isNotEmpty) ? email.trim() : null,
      phone: (phone != null && phone.trim().isNotEmpty) ? phone.trim() : null,
      addressTag: (addressTag != null && addressTag.trim().isNotEmpty) ? addressTag.trim() : null,
      addressLine1: (addressLine1 != null && addressLine1.trim().isNotEmpty) ? addressLine1.trim() : null,
      addressLine2: (addressLine2 != null && addressLine2.trim().isNotEmpty) ? addressLine2.trim() : null,
      landmark: (landmark != null && landmark.trim().isNotEmpty) ? landmark.trim() : null,
      profileImagePath: (profileImagePath != null && profileImagePath.trim().isNotEmpty) ? profileImagePath.trim() : null,
      isNewAccount: isNewAccount,
    );
    saveLocalProfile();
    FirebaseManager.instance.syncUserProfile(value);
  }

  void updateAddress({
    required String tag,
    required String line1,
    required String line2,
    String? landmark,
  }) {
    value = value.copyWith(
      addressTag: tag,
      addressLine1: line1,
      addressLine2: line2,
      landmark: landmark ?? '',
      isAddressConfigured: true,
    );
    saveLocalProfile();
    FirebaseManager.instance.syncUserProfile(value);
  }

  void logout() async {
    value = UserData();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    } catch (_) {}
  }
}
