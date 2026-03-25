import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError('Platform not supported');
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: "AIzaSyDBpiAWsfdDZrdO_Sn7pAaX_xzGttAMeUA",
    appId: "wizzy-3a250.firebaseapp.com",
    messagingSenderId: "443299913856",
    projectId: 'wizzy-3a250',
    authDomain: 'wizzy-3a250.firebaseapp.com',
    storageBucket: 'wizzy-3a250.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: "AIzaSyDBpiAWsfdDZrdO_Sn7pAaX_xzGttAMeUA",
    appId: "1:443299913856:android:6ba6608a5a681def678665",
    messagingSenderId: "443299913856",
    projectId: 'wizzy-3a250',
    storageBucket: 'wizzy-3a250.appspot.com',
  );
}
