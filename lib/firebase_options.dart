import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'core/config/api_keys.dart';

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
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: firebaseWebApiKey,
    appId: '1:985546482165:web:e041cd8ec2ec1cf11500bc',
    messagingSenderId: '985546482165',
    projectId: 'logired-d4dda',
    authDomain: 'logired-d4dda.firebaseapp.com',
    storageBucket: 'logired-d4dda.firebasestorage.app',
    measurementId: 'G-PK8EBYQQ4E',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: firebaseAndroidApiKey,
    appId: '1:985546482165:android:2bfb6026c844310c1500bc',
    messagingSenderId: '985546482165',
    projectId: 'logired-d4dda',
    storageBucket: 'logired-d4dda.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: firebaseIosApiKey,
    appId: '1:985546482165:ios:8ddb789dc4a38d1b1500bc',
    messagingSenderId: '985546482165',
    projectId: 'logired-d4dda',
    storageBucket: 'logired-d4dda.firebasestorage.app',
    iosBundleId: 'com.arthur.gloria.alhan.logired',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: firebaseIosApiKey,
    appId: '1:985546482165:ios:8ddb789dc4a38d1b1500bc',
    messagingSenderId: '985546482165',
    projectId: 'logired-d4dda',
    storageBucket: 'logired-d4dda.firebasestorage.app',
    iosBundleId: 'com.arthur.gloria.alhan.logired',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: firebaseWebApiKey,
    appId: '1:985546482165:web:7758c6a177094b5f1500bc',
    messagingSenderId: '985546482165',
    projectId: 'logired-d4dda',
    authDomain: 'logired-d4dda.firebaseapp.com',
    storageBucket: 'logired-d4dda.firebasestorage.app',
    measurementId: 'G-9NE12ZFS99',
  );
}
