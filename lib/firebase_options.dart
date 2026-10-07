import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class FirebaseOptionsConfig {
  static const _apiKey = String.fromEnvironment('FIREBASE_API_KEY');
  static const _projectId = String.fromEnvironment('FIREBASE_PROJECT_ID');
  static const _messagingSenderId =
      String.fromEnvironment('FIREBASE_MESSAGING_SENDER_ID');
  static const _androidAppId =
      String.fromEnvironment('FIREBASE_ANDROID_APP_ID');
  static const _webAppId = String.fromEnvironment('FIREBASE_WEB_APP_ID');
  static const _authDomain = String.fromEnvironment(
    'FIREBASE_AUTH_DOMAIN',
  );

  static bool get isConfigured =>
      _apiKey.isNotEmpty &&
      _projectId.isNotEmpty &&
      _messagingSenderId.isNotEmpty &&
      (kIsWeb ? _webAppId.isNotEmpty : _androidAppId.isNotEmpty);

  static FirebaseOptions get currentPlatform {
    if (!isConfigured) {
      throw StateError('Firebase configuration is incomplete.');
    }
    return FirebaseOptions(
      apiKey: _apiKey,
      appId: kIsWeb ? _webAppId : _androidAppId,
      messagingSenderId: _messagingSenderId,
      projectId: _projectId,
      authDomain: kIsWeb && _authDomain.isNotEmpty ? _authDomain : null,
    );
  }
}
