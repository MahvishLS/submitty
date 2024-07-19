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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyAs4FWfTm0Yx0gOXlcqRLyxeZ8AFxV4qAo',
    appId: '1:498549547748:web:ae841b66decba4310a82f1',
    messagingSenderId: '498549547748',
    projectId: 'submittyapp',
    authDomain: 'submittyapp.firebaseapp.com',
    storageBucket: 'submittyapp.appspot.com',
    measurementId: 'G-0KGV45JSK6',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAKN9BoXiAWISPntJ4216ATQe-Q30-Udhg',
    appId: '1:498549547748:android:171ca2d20c337e840a82f1',
    messagingSenderId: '498549547748',
    projectId: 'submittyapp',
    storageBucket: 'submittyapp.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBt4jwk9LoBMBwRY-WbGb9lDDSWDSkxlBk',
    appId: '1:498549547748:ios:d2ad85a4e460e35a0a82f1',
    messagingSenderId: '498549547748',
    projectId: 'submittyapp',
    storageBucket: 'submittyapp.appspot.com',
    iosBundleId: 'com.example.myClass',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBt4jwk9LoBMBwRY-WbGb9lDDSWDSkxlBk',
    appId: '1:498549547748:ios:d2ad85a4e460e35a0a82f1',
    messagingSenderId: '498549547748',
    projectId: 'submittyapp',
    storageBucket: 'submittyapp.appspot.com',
    iosBundleId: 'com.example.myClass',
  );
}