// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
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
    apiKey: 'AIzaSyBpHhDby4eelIJfJ08nJi6lTMJYbEV3KjI',
    appId: '1:700521449595:web:67f2117da7a3c865577ade',
    messagingSenderId: '700521449595',
    projectId: 'sylau-apps',
    authDomain: 'sylau-apps.firebaseapp.com',
    storageBucket: 'sylau-apps.firebasestorage.app',
    measurementId: 'G-HYP9SF25NT',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB18cHFdkSr9L3C6F8xZY5qt85FbHkruro',
    appId: '1:700521449595:android:93dff910221890d0577ade',
    messagingSenderId: '700521449595',
    projectId: 'sylau-apps',
    storageBucket: 'sylau-apps.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBlf6tIbCnSS_zzelSG_-G56E4oLcawkKM',
    appId: '1:700521449595:ios:80b751742db77cc4577ade',
    messagingSenderId: '700521449595',
    projectId: 'sylau-apps',
    storageBucket: 'sylau-apps.firebasestorage.app',
    iosBundleId: 'com.example.syabrinaLaundryPpsi',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBlf6tIbCnSS_zzelSG_-G56E4oLcawkKM',
    appId: '1:700521449595:ios:80b751742db77cc4577ade',
    messagingSenderId: '700521449595',
    projectId: 'sylau-apps',
    storageBucket: 'sylau-apps.firebasestorage.app',
    iosBundleId: 'com.example.syabrinaLaundryPpsi',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBpHhDby4eelIJfJ08nJi6lTMJYbEV3KjI',
    appId: '1:700521449595:web:16f3e9da224f7c9d577ade',
    messagingSenderId: '700521449595',
    projectId: 'sylau-apps',
    authDomain: 'sylau-apps.firebaseapp.com',
    storageBucket: 'sylau-apps.firebasestorage.app',
    measurementId: 'G-7SWG549N5T',
  );

}