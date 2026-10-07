import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import '../models/app_user.dart';

class AuthService {
  AuthService._();
  static final AuthService _instance = AuthService._();
  factory AuthService() => _instance;

  String? _verificationId;
  ConfirmationResult? _webConfirmation;

  bool get isConfigured => Firebase.apps.isNotEmpty;

  FirebaseAuth get _auth {
    if (!isConfigured) {
      throw StateError(
        'Firebase is not configured. Add the Firebase dart-define values '
        'before using phone sign-in.',
      );
    }
    return FirebaseAuth.instance;
  }

  Future<void> sendOtp(String phone) async {
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    if (digits.length != 10) {
      throw ArgumentError('Enter a valid 10-digit mobile number.');
    }

    final fullPhoneNumber = '+91$digits';
    if (kIsWeb) {
      _webConfirmation = await _auth.signInWithPhoneNumber(fullPhoneNumber);
      return;
    }

    _verificationId = null;
    final completion = Completer<void>();
    await _auth.verifyPhoneNumber(
      phoneNumber: fullPhoneNumber,
      verificationCompleted: (credential) async {
        try {
          await _auth.signInWithCredential(credential);
          if (!completion.isCompleted) completion.complete();
        } catch (error, stackTrace) {
          if (!completion.isCompleted) {
            completion.completeError(error, stackTrace);
          }
        }
      },
      verificationFailed: (error) {
        if (!completion.isCompleted) {
          completion.completeError(
            StateError(error.message ?? 'Firebase phone verification failed.'),
          );
        }
      },
      codeSent: (verificationId, _) {
        _verificationId = verificationId;
        if (!completion.isCompleted) completion.complete();
      },
      codeAutoRetrievalTimeout: (verificationId) {
        _verificationId = verificationId;
      },
    );
    await completion.future.timeout(
      const Duration(seconds: 70),
      onTimeout: () {
        if (_verificationId == null) {
          throw TimeoutException(
              'Timed out waiting for Firebase to send an OTP.');
        }
      },
    );
  }

  Future<AppUser> verifyOtp(String phone, String otp) async {
    final trimmedOtp = otp.trim();
    if (trimmedOtp.length < 4) {
      throw ArgumentError('Enter the verification code sent to your phone.');
    }

    UserCredential credential;
    if (kIsWeb) {
      final confirmation = _webConfirmation;
      if (confirmation == null) {
        throw StateError('Request a verification code before submitting it.');
      }
      credential = await confirmation.confirm(trimmedOtp);
      _webConfirmation = null;
    } else {
      final verificationId = _verificationId;
      if (verificationId == null) {
        throw StateError('Request a verification code before submitting it.');
      }
      credential = await _auth.signInWithCredential(
        PhoneAuthProvider.credential(
          verificationId: verificationId,
          smsCode: trimmedOtp,
        ),
      );
      _verificationId = null;
    }

    final user = credential.user;
    if (user == null) {
      throw StateError('Firebase completed sign-in without returning a user.');
    }

    return _loadProfile(user, phone);
  }

  Future<AppUser?> restoreSession() async {
    final user = isConfigured ? _auth.currentUser : null;
    if (user == null) return null;
    return _loadProfile(user, user.phoneNumber ?? '');
  }

  Future<AppUser> _loadProfile(User user, String fallbackPhone) async {
    final profile = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    final data = profile.data() ?? const <String, dynamic>{};
    final digits =
        (user.phoneNumber ?? fallbackPhone).replaceAll(RegExp(r'\D'), '');
    final districts = data['allowedDistricts'];
    final villages = data['allowedVillageIds'];
    return AppUser(
      phone: digits,
      displayName: data['displayName'] as String? ??
          user.displayName ??
          'VanRozgar User',
      role: data['role'] as String? ?? 'villager',
      allowedDistricts:
          districts is List ? districts.whereType<String>().toList() : const [],
      allowedVillageIds:
          villages is List ? villages.whereType<String>().toList() : const [],
      loggedInAt: DateTime.now(),
    );
  }

  Future<void> clearSession() async {
    if (isConfigured) await _auth.signOut();
  }
}
