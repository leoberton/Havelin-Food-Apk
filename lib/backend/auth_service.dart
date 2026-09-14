import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../managers/user_manager.dart';
import 'firebase_manager.dart';

class AuthService {
  static final AuthService instance = AuthService._internal();

  AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// 1. Email & Password Sign-Up
  Future<UserCredential?> signUpWithEmail({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      if (credential.user != null) {
        await credential.user!.updateDisplayName(name.trim());
        UserManager.instance.updateProfile(
          name: name,
          email: email,
          isNewAccount: true,
        );
        await FirebaseManager.instance.syncUserProfile(UserManager.instance.value);
      }
      return credential;
    } catch (e) {
      debugPrint("⚠️ Email Sign Up Error: $e");
      rethrow;
    }
  }

  /// 2. Email & Password Sign-In
  Future<UserCredential?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      if (credential.user != null) {
        UserManager.instance.updateProfile(
          name: credential.user!.displayName ?? 'User',
          email: credential.user!.email ?? email,
          isNewAccount: false,
        );
        await FirebaseManager.instance.fetchAndRestoreUserProfile();
        await FirebaseManager.instance.syncUserProfile(UserManager.instance.value);
      }
      return credential;
    } catch (e) {
      debugPrint("⚠️ Email Sign In Error: $e");
      rethrow;
    }
  }

  /// 3. Native Google Sign-In
  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) return null; // User cancelled flow

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);

      if (userCredential.user != null) {
        UserManager.instance.updateProfile(
          name: userCredential.user!.displayName ?? googleUser.displayName ?? 'Google User',
          email: userCredential.user!.email ?? googleUser.email,
          profileImagePath: googleUser.photoUrl ?? 'assets/images/logo.png',
          isNewAccount: false,
        );
        await FirebaseManager.instance.fetchAndRestoreUserProfile();
        await FirebaseManager.instance.syncUserProfile(UserManager.instance.value);
      }
      return userCredential;
    } catch (e) {
      debugPrint("⚠️ Google Sign In Error: $e");
      // Fallback if native GoogleSignIn fails on non-GMS devices
      try {
        final GoogleAuthProvider googleProvider = GoogleAuthProvider();
        googleProvider.addScope('email');
        return await _auth.signInWithProvider(googleProvider);
      } catch (_) {
        rethrow;
      }
    }
  }

  /// 4. Apple Provider Sign-In
  Future<UserCredential?> signInWithApple() async {
    try {
      final AppleAuthProvider appleProvider = AppleAuthProvider();
      final credential = await _auth.signInWithProvider(appleProvider);

      if (credential.user != null) {
        UserManager.instance.updateProfile(
          name: credential.user!.displayName ?? 'Apple User',
          email: credential.user!.email ?? '',
          isNewAccount: false,
        );
        await FirebaseManager.instance.fetchAndRestoreUserProfile();
        await FirebaseManager.instance.syncUserProfile(UserManager.instance.value);
      }
      return credential;
    } catch (e) {
      debugPrint("⚠️ Apple Sign In Error: $e");
      rethrow;
    }
  }

  /// 5. Phone Number SMS Verification
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(PhoneAuthCredential) onVerificationCompleted,
    required Function(FirebaseAuthException) onVerificationFailed,
    required Function(String verificationId, int? resendToken) onCodeSent,
    required Function(String verificationId) onCodeAutoRetrievalTimeout,
  }) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber.trim(),
        verificationCompleted: onVerificationCompleted,
        verificationFailed: onVerificationFailed,
        codeSent: onCodeSent,
        codeAutoRetrievalTimeout: onCodeAutoRetrievalTimeout,
      );
    } catch (e) {
      debugPrint("⚠️ Phone Verification Error: $e");
      rethrow;
    }
  }

  /// 6. Confirm Phone SMS OTP Code
  Future<UserCredential?> confirmPhoneOtp({
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode.trim(),
      );
      final userCredential = await _auth.signInWithCredential(credential);
      if (userCredential.user != null) {
        UserManager.instance.updateProfile(
          phone: userCredential.user!.phoneNumber ?? '',
          isNewAccount: false,
        );
        await FirebaseManager.instance.fetchAndRestoreUserProfile();
        await FirebaseManager.instance.syncUserProfile(UserManager.instance.value);
      }
      return userCredential;
    } catch (e) {
      debugPrint("⚠️ OTP Confirmation Error: $e");
      rethrow;
    }
  }

  /// 7. Send Password Reset Email
  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  /// 8. Sign Out
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
