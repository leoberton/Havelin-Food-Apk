import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return ios;
      default:
        return android;
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDLYXlbb9RI7Z-wFpdV07-RbExkOmU0RnY',
    appId: '1:866750688120:android:00999f226e90b81f46768d',
    messagingSenderId: '866750688120',
    projectId: 'havelin-food-apk',
    storageBucket: 'havelin-food-apk.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDtiv1A68YzzNZvtCVU-RBM_jwK7vK_Is0',
    appId: '1:866750688120:ios:2c14817f029b515146768d',
    messagingSenderId: '866750688120',
    projectId: 'havelin-food-apk',
    storageBucket: 'havelin-food-apk.firebasestorage.app',
    iosBundleId: 'com.example.havelinFoodApk',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDLYXlbb9RI7Z-wFpdV07-RbExkOmU0RnY',
    appId: '1:866750688120:web:00999f226e90b81f46768d',
    messagingSenderId: '866750688120',
    projectId: 'havelin-food-apk',
    storageBucket: 'havelin-food-apk.firebasestorage.app',
  );
}
